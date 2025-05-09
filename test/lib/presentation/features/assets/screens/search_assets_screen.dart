import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/inputs/search_field.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/asset_bloc.dart';
import '../widgets/asset_tile.dart';

class SearchAssetsScreen extends StatefulWidget {
  const SearchAssetsScreen({Key? key}) : super(key: key);

  @override
  State<SearchAssetsScreen> createState() => _SearchAssetsScreenState();
}

class _SearchAssetsScreenState extends State<SearchAssetsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1; // Index for the Search tab

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetBloc>().loadAssets();
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.pushReplacementNamed(
      context,
      ['/', '/searchAssets', '/scanRfid', '/viewAssets', '/export'][index],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(title: const Text('Search Assets')),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: Column(
        children: [
          SearchField(
            controller: _searchController,
            onChanged: (value) {
              context.read<AssetBloc>().setSearchQuery(value);
            },
            hintText: 'Search by ID, category, brand...',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<AssetBloc>(
              builder: (context, bloc, child) {
                if (bloc.status == AssetStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (bloc.status == AssetStatus.error) {
                  return Center(child: Text('Error: ${bloc.errorMessage}'));
                } else if (bloc.filteredAssets.isEmpty) {
                  return const Center(
                    child: Text(
                      'No assets found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: bloc.filteredAssets.length,
                    itemBuilder:
                        (context, index) =>
                            AssetTile(asset: bloc.filteredAssets[index]),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
