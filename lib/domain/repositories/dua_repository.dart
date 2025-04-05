import 'package:dua/domain/entities/dua.dart';

abstract class DuaRepository {
  Future<List<DuaEntity>> getAllDuas();
}
