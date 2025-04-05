import 'package:dua/core/base/base_presenter.dart';
import 'package:dua/domain/entities/dua.dart';
import 'package:dua/domain/usecases/get_all_duas.dart';
import 'package:dua/presentation/all_duas/presenter/all_duas_ui_state.dart';

class AllDuasPresenter extends BasePresenter<AllDuasUiState> {
  final GetAllDuas getAllDuas;

  final Obs<AllDuasUiState> uiState = Obs(AllDuasUiState.empty());

  AllDuasUiState get currentUiState => uiState.value;
  List<DuaEntity> _allDuas = []; // Store all duas to filter locally

  AllDuasPresenter(this.getAllDuas);

  @override
  void onInit() {
    super.onInit();
    _fetchAllDuas();
  }

  Future<void> _fetchAllDuas() async {
    uiState.value = currentUiState.copyWith(isLoading: true);
    try {
      _allDuas = await getAllDuas();
      print(
          'AllDuasPresenter: _fetchAllDuas: ${_allDuas.length} duas retrieved');
      print('AllDuasPresenter: _fetchAllDuas: ${_allDuas[0].name}');
      _applyFilters();
    } catch (e) {
      uiState.value = currentUiState.copyWith(
        isLoading: false,
        userMessage: 'Failed to load duas: $e',
      );
    }
  }

  // Apply both language and search filters
  void _applyFilters() {
    if (_allDuas.isEmpty) return;

    final filteredDuas = _allDuas.where((dua) {
      // Filter by language
      final languageMatches = dua.languageId == currentUiState.selectedLanguage;

      // Filter by search query if provided
      final searchQuery = currentUiState.searchQuery.toLowerCase();
      final nameMatches =
          searchQuery.isEmpty || dua.name.toLowerCase().contains(searchQuery);

      return languageMatches && nameMatches;
    }).toList();

    uiState.value = currentUiState.copyWith(
      isLoading: false,
      duas: filteredDuas,
    );
  }

  // Toggle between Bangla and English
  void toggleLanguage() {
    final newLanguage = currentUiState.selectedLanguage == 'bn' ? 'en' : 'bn';
    uiState.value = currentUiState.copyWith(selectedLanguage: newLanguage);
    _applyFilters();
  }

  // Update search query
  void updateSearchQuery(String query) {
    uiState.value = currentUiState.copyWith(searchQuery: query);
    _applyFilters();
  }

  @override
  void refresh() {
    _fetchAllDuas();
  }

  @override
  Future<void> addUserMessage(String message) async {
    uiState.value = currentUiState.copyWith(userMessage: message);
  }

  @override
  Future<void> toggleLoading({required bool loading}) async {
    uiState.value = currentUiState.copyWith(isLoading: loading);
  }
}
