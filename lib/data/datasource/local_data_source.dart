import 'package:dua/data/services/database/database_service.dart';
import 'package:dua/domain/entities/dua.dart';

abstract class LocalDataSource {
  Future<List<DuaEntity>> getAllDuas();
}

class LocalDataSourceImpl implements LocalDataSource {
  final DuaDatabase database;

  LocalDataSourceImpl(this.database);

  @override
  Future<List<DuaEntity>> getAllDuas() async {
    print('DuaLocalDataSource: getAllDuas');
    try {
      final List<Dua> duasList = await database.getAllDuas();
      print(
          'DuaLocalDataSource: getAllDuas: ${duasList.length} duas retrieved');

      // Convert database models to entities with null checks
      final List<DuaEntity> entities = duasList.map((dua) {
        return DuaEntity(
          id: dua.id,
          languageId: dua.languageId ?? '',
          groups: dua.groups, // Handle potential null value
          name: dua.name ?? '',
          context: dua.context ?? '',
          source: dua.source ?? '',
          indopak: dua.indopak ?? '',
          clean: dua.clean ?? '',
          transliteration: dua.transliteration ?? '',
          translation: dua.translation ?? '',
          note: dua.note ?? '',
          reference: dua.reference ?? '',
          audio: dua.audio ?? 0,
          categoryId: dua.categoryId ?? 0,
          subcategoryId: dua.subcategoryId ?? 0,
        );
      }).toList();
      print('DuaLocalDataSource: getAllDuas: ${entities[0].name}');

      return entities;
    } catch (e, stackTrace) {
      print('DuaLocalDataSource ERROR: $e');
      print('DuaLocalDataSource STACK: $stackTrace');

      // Return empty list on error instead of propagating error
      return [];
    }
  }
}
