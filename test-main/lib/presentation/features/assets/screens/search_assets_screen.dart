import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/inputs/search_field.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/asset_bloc.dart';
import '../widgets/asset_tile.dart';
import '../widgets/asset_table_view.dart';

class SearchAssetsScreen extends StatefulWidget {
  const SearchAssetsScreen({Key? key}) : super(key: key);

  @override
  State<SearchAssetsScreen> createState() => _SearchAssetsScreenState();
}

class _SearchAssetsScreenState extends State<SearchAssetsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1; // Index for the Search tab
  final GlobalKey _statusColumnKey = GlobalKey(); // Key สำหรับคอลัมน์ Status
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ตรวจสอบ tab ที่เลือกเมื่อ bloc มีการเปลี่ยนแปลง
      final bloc = context.read<AssetBloc>();
      _tabController.index = bloc.isTableView ? 1 : 0;

      bloc.loadAssets();
    });

    _tabController.addListener(() {
      final bloc = context.read<AssetBloc>();
      if (_tabController.index == 0 && bloc.isTableView) {
        bloc.toggleViewMode();
      } else if (_tabController.index == 1 && !bloc.isTableView) {
        bloc.toggleViewMode();
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.pushReplacementNamed(
      context,
      ['/', '/searchAssets', '/scanRfid', '/reports', '/export'][index],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(
        title: const Text('Asset Search'),
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.white,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.view_list), text: 'List View'),
                Tab(icon: Icon(Icons.grid_on), text: 'Table View'),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AssetBloc>().loadAssets();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: Column(
        children: [
          // ส่วนค้นหาที่สวยงาม
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withAlpha(25),
                  Colors.white,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(25),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: SearchField(
              controller: _searchController,
              onChanged: (value) {
                context.read<AssetBloc>().setSearchQuery(value);
              },
              hintText: 'Search for assets...',
            ),
          ),

          // ส่วนแสดงผลลัพธ์
          Expanded(
            child: Consumer<AssetBloc>(
              builder: (context, bloc, child) {
                if (bloc.status == AssetStatus.loading) {
                  return _buildLoadingView();
                } else if (bloc.status == AssetStatus.error) {
                  return _buildErrorView(bloc.errorMessage);
                } else if (bloc.filteredAssets.isEmpty) {
                  return _buildEmptyResults();
                } else {
                  return _buildResultsView(bloc);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // สร้างหน้าโหลดที่สวยงาม
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading assets...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // สร้างหน้าแสดงข้อผิดพลาด
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              'Error loading assets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AssetBloc>().loadAssets();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // สร้างหน้าเมื่อไม่พบผลลัพธ์
  Widget _buildEmptyResults() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: Colors.blue.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No assets found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Try using different search terms',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              onPressed: () {
                _searchController.clear();
                context.read<AssetBloc>().setSearchQuery('');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // สร้างหน้าแสดงผลลัพธ์
  Widget _buildResultsView(AssetBloc bloc) {
    return Stack(
      children: [
        TabBarView(
          controller: _tabController,
          children: [
            // List View
            _buildListView(bloc),

            // Table View
            _buildTableView(bloc),
          ],
        ),

        // FAB สำหรับกลับไปด้านบน (แสดงเฉพาะเมื่อมีผลลัพธ์มากกว่า 10 รายการ)
        if (bloc.filteredAssets.length > 10)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              mini: true,
              onPressed: () {
                // สร้างความเชื่อมโยงกับ ScrollController (ถ้าต้องการ)
                // หรือโค้ดอย่างง่ายสำหรับความเข้ากันได้
                final scrollController = PrimaryScrollController.of(context);
                if (scrollController != null) {
                  scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: const Icon(Icons.arrow_upward),
              tooltip: 'Scroll to top',
            ),
          ),
      ],
    );
  }

  Widget _buildListView(AssetBloc bloc) {
    return Column(
      children: [
        // ส่วนหัวแสดงจำนวนผลลัพธ์
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Found ${bloc.filteredAssets.length} assets',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),

        // รายการสินทรัพย์
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: bloc.filteredAssets.length,
            itemBuilder: (context, index) {
              final asset = bloc.filteredAssets[index];
              return AssetTile(asset: asset);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableView(AssetBloc bloc) {
    return Column(
      children: [
        // ส่วนหัวแสดงจำนวนผลลัพธ์
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Found ${bloc.filteredAssets.length} assets',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),

        // ตารางสินทรัพย์
        Expanded(
          child: AssetTableView(
            assets: bloc.filteredAssets,
            statusColumnKey: _statusColumnKey,
            bloc: bloc,
          ),
        ),
      ],
    );
  }
}
