import 'dart:convert';
import 'dart:io';
import 'package:dua/domain/entities/dua.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  final String _bookmarksKey = 'bookmarked_duas';
  final ValueNotifier<List<DuaEntity>> bookmarkedDuas =
      ValueNotifier<List<DuaEntity>>([]);

  // Singleton instance
  static final BookmarkService _instance = BookmarkService._internal();

  factory BookmarkService() {
    return _instance;
  }

  BookmarkService._internal() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];

      final List<DuaEntity> loadedBookmarks = bookmarksJson.map((jsonStr) {
        final Map<String, dynamic> map = json.decode(jsonStr);
        return DuaEntity(
          id: map['id'],
          languageId: map['languageId'],
          groups: map['groups'],
          name: map['name'],
          context: map['context'],
          source: map['source'],
          indopak: map['indopak'],
          clean: map['clean'],
          transliteration: map['transliteration'],
          translation: map['translation'],
          note: map['note'],
          reference: map['reference'],
          audio: map['audio'],
          categoryId: map['categoryId'],
          subcategoryId: map['subcategoryId'],
        );
      }).toList();

      bookmarkedDuas.value = loadedBookmarks;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading bookmarks: $e');
      }
    }
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = bookmarkedDuas.value.map((dua) {
        return json.encode({
          'id': dua.id,
          'languageId': dua.languageId,
          'groups': dua.groups,
          'name': dua.name,
          'context': dua.context,
          'source': dua.source,
          'indopak': dua.indopak,
          'clean': dua.clean,
          'transliteration': dua.transliteration,
          'translation': dua.translation,
          'note': dua.note,
          'reference': dua.reference,
          'audio': dua.audio,
          'categoryId': dua.categoryId,
          'subcategoryId': dua.subcategoryId,
        });
      }).toList();

      await prefs.setStringList(_bookmarksKey, bookmarksJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving bookmarks: $e');
      }
    }
  }

  bool isDuaBookmarked(int duaId) {
    return bookmarkedDuas.value.any((dua) => dua.id == duaId);
  }

  Future<void> toggleBookmark(DuaEntity dua) async {
    if (isDuaBookmarked(dua.id)) {
      bookmarkedDuas.value =
          bookmarkedDuas.value.where((d) => d.id != dua.id).toList();
    } else {
      bookmarkedDuas.value = [...bookmarkedDuas.value, dua];
    }
    await _saveBookmarks();
  }

  Future<void> removeBookmark(int duaId) async {
    bookmarkedDuas.value =
        bookmarkedDuas.value.where((dua) => dua.id != duaId).toList();
    await _saveBookmarks();
  }

  List<DuaEntity> getAllBookmarks() {
    return bookmarkedDuas.value;
  }

  // Export bookmarks to a JSON file in user-selected directory
  Future<Map<String, dynamic>> exportBookmarks() async {
    try {
      // Let user select save directory
      String? directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath == null) {
        // User canceled directory selection
        return {'success': false, 'path': null, 'usedFallback': false};
      }

      final fileName =
          'dua_bookmarks_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '$directoryPath/$fileName';

      // Create a list of maps to export
      final bookmarksData = bookmarkedDuas.value
          .map((dua) => {
                'id': dua.id,
                'languageId': dua.languageId,
                'groups': dua.groups,
                'name': dua.name,
                'context': dua.context,
                'source': dua.source,
                'indopak': dua.indopak,
                'clean': dua.clean,
                'transliteration': dua.transliteration,
                'translation': dua.translation,
                'note': dua.note,
                'reference': dua.reference,
                'audio': dua.audio,
                'categoryId': dua.categoryId,
                'subcategoryId': dua.subcategoryId,
              })
          .toList();

      // Convert to JSON string with indentation for readability
      final jsonString = json.encode(bookmarksData);

      try {
        // Try to write to file
        final file = File(filePath);
        await file.writeAsString(jsonString);

        if (kDebugMode) {
          print('Bookmarks exported to: $filePath');
        }

        return {'success': true, 'path': filePath, 'usedFallback': false};
      } catch (writeError) {
        // If writing to the selected directory fails, try writing to a public directory as fallback
        if (kDebugMode) {
          print('Error writing to selected directory: $writeError');
          print('Trying fallback to public directory');
        }

        Directory? fallbackDir;
        if (Platform.isAndroid) {
          // For Android, try to use Downloads directory
          fallbackDir = Directory('/storage/emulated/0/Download');
          if (!await fallbackDir.exists()) {
            // If standard Download directory doesn't exist, try to get public directory
            fallbackDir = await getExternalStorageDirectory();
          }
        } else {
          // For iOS, use Documents directory which is accessible via Files app
          fallbackDir = await getApplicationDocumentsDirectory();
        }

        if (fallbackDir == null) {
          throw Exception('Could not find a suitable directory for fallback');
        }

        // Create a DuaApp directory in the fallback location
        final appFolder = Directory('${fallbackDir.path}/DuaApp');
        if (!await appFolder.exists()) {
          await appFolder.create(recursive: true);
        }

        final fallbackFilePath = '${appFolder.path}/$fileName';
        final fallbackFile = File(fallbackFilePath);
        await fallbackFile.writeAsString(jsonString);

        if (kDebugMode) {
          print('Bookmarks exported to fallback location: $fallbackFilePath');
        }

        return {
          'success': true,
          'path': fallbackFilePath,
          'usedFallback': true
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error exporting bookmarks: $e');
      }
      return {
        'success': false,
        'path': null,
        'error': e.toString(),
        'usedFallback': false
      };
    }
  }

  // Import bookmarks from a JSON file
  Future<bool> importBookmarks(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      final List<DuaEntity> importedDuas = jsonData.map<DuaEntity>((item) {
        return DuaEntity(
          id: item['id'],
          languageId: item['languageId'],
          groups: item['groups'],
          name: item['name'],
          context: item['context'],
          source: item['source'],
          indopak: item['indopak'],
          clean: item['clean'],
          transliteration: item['transliteration'],
          translation: item['translation'],
          note: item['note'],
          reference: item['reference'],
          audio: item['audio'],
          categoryId: item['categoryId'],
          subcategoryId: item['subcategoryId'],
        );
      }).toList();

      // Option to merge with existing bookmarks or replace them
      // Here we're replacing the entire list
      bookmarkedDuas.value = importedDuas;
      await _saveBookmarks();

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error importing bookmarks: $e');
      }
      return false;
    }
  }

  // Import bookmarks from backup JSON string
  Future<bool> importBookmarksFromJson(String jsonString) async {
    try {
      final List<dynamic> jsonData = json.decode(jsonString);

      final List<DuaEntity> importedDuas = jsonData.map<DuaEntity>((item) {
        return DuaEntity(
          id: item['id'],
          languageId: item['languageId'],
          groups: item['groups'],
          name: item['name'],
          context: item['context'] ?? '',
          source: item['source'] ?? '',
          indopak: item['indopak'] ?? '',
          clean: item['clean'] ?? '',
          transliteration: item['transliteration'] ?? '',
          translation: item['translation'] ?? '',
          note: item['note'] ?? '',
          reference: item['reference'] ?? '',
          audio: item['audio'] ?? 0,
          categoryId: item['categoryId'] ?? 0,
          subcategoryId: item['subcategoryId'] ?? 0,
        );
      }).toList();

      // Merge with existing bookmarks
      final List<DuaEntity> mergedList = [...bookmarkedDuas.value];

      // Add only non-duplicate bookmarks
      for (final importedDua in importedDuas) {
        if (!isDuaBookmarked(importedDua.id)) {
          mergedList.add(importedDua);
        }
      }

      bookmarkedDuas.value = mergedList;
      await _saveBookmarks();

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error importing bookmarks from JSON: $e');
      }
      return false;
    }
  }
}
