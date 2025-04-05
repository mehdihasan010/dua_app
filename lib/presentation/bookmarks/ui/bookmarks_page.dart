// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:dua/core/di/service_locator.dart';
import 'package:dua/core/services/bookmark_service.dart';
import 'package:dua/domain/entities/dua.dart';
import 'package:dua/presentation/dua_details/ui/dua_details_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  late final BookmarkService _bookmarkService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bookmarkService = locate<BookmarkService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Duas'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'import') {
                _importBookmarks();
              } else if (value == 'export') {
                _exportBookmarks();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 8),
                    Text('Import Bookmarks'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Bookmarks'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          ValueListenableBuilder<List<DuaEntity>>(
            valueListenable: _bookmarkService.bookmarkedDuas,
            builder: (context, bookmarkedDuas, _) {
              if (bookmarkedDuas.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_outline,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No bookmarked duas yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add duas to your bookmarks by tapping the bookmark icon',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: bookmarkedDuas.length,
                itemBuilder: (context, index) {
                  final dua = bookmarkedDuas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DuaDetailsPage(dua: dua),
                          ),
                        ).then((_) {
                          // Refresh the list when returning from details page
                          setState(() {});
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dua.name,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (dua.transliteration.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      dua.transliteration,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.bookmark_remove),
                              onPressed: () {
                                _removeBookmark(dua.id);
                              },
                              tooltip: 'Remove bookmark',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _removeBookmark(int duaId) async {
    await _bookmarkService.removeBookmark(duaId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dua removed from bookmarks'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    setState(() {});
  }

  // Check and request storage permissions
  Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      // Request Android permissions
      final androidSdk = await _getAndroidSdkVersion();

      if (androidSdk >= 33) {
        // For Android 13+ (API 33+)
        final photoStatus = await Permission.photos.request();
        final videoStatus = await Permission.videos.request();
        final audioStatus = await Permission.audio.request();

        if (photoStatus.isGranted) {
          return true;
        } else {
          _showPermissionDeniedDialog(true);
          return false;
        }
      } else if (androidSdk >= 29) {
        // For Android 10-12 (API 29-32)
        final status = await Permission.storage.request();
        if (status.isGranted) {
          return true;
        } else {
          _showPermissionDeniedDialog(true);
          return false;
        }
      } else {
        // For Android 9 and below (API 28-)
        final status = await Permission.storage.request();
        if (status.isGranted) {
          return true;
        } else {
          _showPermissionDeniedDialog(false);
          return false;
        }
      }
    } else if (Platform.isIOS) {
      // iOS permissions are handled by file_picker automatically
      return true;
    }

    return false;
  }

  // Helper to get Android SDK version
  Future<int> _getAndroidSdkVersion() async {
    try {
      if (Platform.isAndroid) {
        return int.parse(Platform.operatingSystemVersion.split(' ').first);
      }
    } catch (e) {
      // If we can't determine the version, assume a safe default
    }
    return 29; // Default to Android 10
  }

  // Show dialog when permission is denied
  void _showPermissionDeniedDialog(bool isAndroid10OrAbove) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: Text(
            isAndroid10OrAbove
                ? 'Storage permission is required to import/export bookmarks. Please note that on Android 10+ there are limitations on which folders apps can write to, even with permissions. If export fails, try selecting a different folder or use the app\'s document folder.'
                : 'Storage permission is required to import/export bookmarks. Please grant permission in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _exportBookmarks() async {
    try {
      // First check permissions
      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final bookmarkCount = _bookmarkService.bookmarkedDuas.value.length;
      if (bookmarkCount == 0) {
        _showMessage('No bookmarks to export');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Call the service to select directory and save file
      final result = await _bookmarkService.exportBookmarks();

      setState(() {
        _isLoading = false;
      });

      // User might have canceled the directory selection
      if (!result['success'] || result['path'] == null) {
        if (result.containsKey('error')) {
          _showMessage(
              'Failed to export bookmarks: ${result['error'].toString().split(":").first}');
        }
        return;
      }

      final filePath = result['path'];
      final usedFallback = result['usedFallback'];

      if (usedFallback) {
        // Show dialog with option to share or view location
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Bookmarks Exported'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Due to permission restrictions, bookmarks were saved to an alternative location:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(filePath),
                  const SizedBox(height: 16),
                  const Text(
                    'Would you like to share the file or try to open its location?',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _shareExportedFile(filePath);
                  },
                  child: const Text('Share File'),
                ),
                if (Platform.isAndroid)
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showMessage(
                          'Directory: ${Directory(filePath).parent.path}');
                    },
                    child: const Text('Show Path'),
                  ),
              ],
            ),
          );
        }
      } else {
        // Show simple success message
        _showMessage('Bookmarks exported successfully to selected folder');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.toString().contains("Operation not permitted") ||
          e.toString().contains("Permission denied")) {
        _showMessage('Permission error: Cannot write to the selected location');
      } else {
        _showMessage(
            'Failed to export bookmarks: ${e.toString().split(":").first}');
      }
    }
  }

  void _shareExportedFile(String filePath) {
    try {
      Share.shareXFiles([XFile(filePath)], text: 'Dua App Bookmarks');
    } catch (e) {
      _showMessage('Failed to share file: ${e.toString().split(":").first}');
    }
  }

  Future<void> _importBookmarks() async {
    try {
      // First check permissions
      final hasPermission = await _checkPermissions();
      if (!hasPermission) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Open file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      setState(() {
        _isLoading = false;
      });

      if (result == null || result.files.isEmpty) {
        return; // User canceled the picker
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        _showMessage('Invalid file path');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final success = await _bookmarkService.importBookmarks(filePath);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showMessage('Bookmarks imported successfully');
      } else {
        _showMessage('Failed to import bookmarks');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error importing bookmarks');
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          backgroundColor: Colors.white,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
