import 'package:dua/data/services/database/database_service.dart';

class DuaEntity {
  final int id;
  final String languageId;
  final String groups;
  final String name;
  final String context;
  final String source;
  final String indopak;
  final String clean;
  final String transliteration;
  final String translation;
  final String note;
  final String reference;
  final int audio;
  final int categoryId;
  final int subcategoryId;

  const DuaEntity({
    required this.id,
    required this.languageId,
    required this.groups,
    required this.name,
    required this.context,
    required this.source,
    required this.indopak,
    required this.clean,
    required this.transliteration,
    required this.translation,
    required this.note,
    required this.reference,
    required this.audio,
    required this.categoryId,
    required this.subcategoryId,
  });

  factory DuaEntity.fromDatabaseModel(Dua data) {
    return DuaEntity(
      id: data.id,
      languageId: data.languageId ?? '',
      groups: data.groups,
      name: data.name ?? '',
      context: data.context ?? '',
      source: data.source ?? '',
      indopak: data.indopak ?? '',
      clean: data.clean ?? '',
      transliteration: data.transliteration ?? '',
      translation: data.translation ?? '',
      note: data.note ?? '',
      reference: data.reference ?? '',
      audio: data.audio ?? 0,
      categoryId: data.categoryId ?? 0,
      subcategoryId: data.subcategoryId ?? 0,
    );
  }
}
