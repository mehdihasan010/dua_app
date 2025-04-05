import 'package:drift/drift.dart';
import 'package:dua/data/datasource/local_data_source.dart';
import 'package:dua/domain/entities/dua.dart';
import 'package:dua/domain/repositories/dua_repository.dart';

class DuaRepositoryImpl implements DuaRepository {
  final LocalDataSource localDataSource;

  DuaRepositoryImpl(this.localDataSource);

  @override
  Future<List<DuaEntity>> getAllDuas() async {
    final duasData = await localDataSource.getAllDuas();
    return duasData;
  }
}

// JSON column mapper for 'groups' (since it's JSON)
class JsonColumnMapper extends TypeConverter<String, String?> {
  const JsonColumnMapper();
  @override
  String fromSql(String? fromDb) {
    // Improve null safety by returning an empty string for null values
    if (fromDb == null) {
      print('JsonColumnMapper: Received null value from database');
      return '';
    }
    try {
      // Try to validate if it's proper JSON
      return fromDb;
    } catch (e) {
      print('JsonColumnMapper: Error parsing JSON from database: $e');
      return '';
    }
  }

  @override
  String? toSql(String value) => value;
}
