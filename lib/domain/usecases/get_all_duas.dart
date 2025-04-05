import 'package:dua/domain/entities/dua.dart';
import 'package:dua/domain/repositories/dua_repository.dart';

class GetAllDuas {
  final DuaRepository repository;

  GetAllDuas(this.repository);

  Future<List<DuaEntity>> call() async {
    return await repository.getAllDuas();
  }
}
