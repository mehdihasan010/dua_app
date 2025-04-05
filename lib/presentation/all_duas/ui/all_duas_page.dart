import 'package:dua/core/di/service_locator.dart';
import 'package:dua/core/external_libs/presentable_widget_builder.dart';
import 'package:dua/presentation/all_duas/presenter/all_duas_presenter.dart';
import 'package:dua/presentation/dua_details/ui/dua_details_page.dart';
import 'package:flutter/material.dart';

class AllDuasPage extends StatelessWidget {
  const AllDuasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final presenter = locate<AllDuasPresenter>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Duas'),
        centerTitle: true,
        actions: [
          // Language toggle button
          PresentableWidgetBuilder(
            presenter: presenter,
            builder: () {
              final isEnglish =
                  presenter.currentUiState.selectedLanguage == 'en';
              return Container(
                margin: const EdgeInsets.only(right: 4),
                child: InkWell(
                  onTap: presenter.toggleLanguage,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      isEnglish ? 'বাং' : 'EN',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Compact refresh button
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: presenter.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search duas...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          // Dua list
          Expanded(
            child: PresentableWidgetBuilder(
              presenter: presenter,
              builder: () {
                final state = presenter.currentUiState;

                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.duas == null || state.duas!.isEmpty) {
                  return const Center(child: Text('No duas found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: state.duas!.length,
                  itemBuilder: (context, index) {
                    final dua = state.duas![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DuaDetailsPage(dua: dua),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            dua.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
