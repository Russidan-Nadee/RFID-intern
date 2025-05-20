// lib/presentation/features/dashboard/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/status/loading_error_widget.dart';
import '../widgets/asset_notification_item.dart';
import '../blocs/dashboard_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().loadDashboardData();
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    NavigationService.navigateToTabByIndex(context, index);
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดโทนสีหลัก
    final primaryColor = const Color(0xFF6A5ACD); // สีม่วงสไลวันเดอร์
    final backgroundColor = Colors.white;
    final cardColor = const Color(0xFFF5F5F8); // สีเทาอ่อนสำหรับการ์ด
    final lightPrimaryColor = const Color(
      0xFFE6E4F4,
    ); // สีม่วงอ่อนแทน withOpacity

    return ScreenContainer(
      backgroundColor: backgroundColor,
      statusBarColor: const Color(0xFFE0E0E0), // สีเทาสำหรับ StatusBar
      appBar: AppBar(
        title: Text(
          'Asset Management Dashboard',
          style: TextStyle(
            color: primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: primaryColor),
            onPressed: () {
              Navigator.pushNamed(context, RouteConstants.settings);
            },
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<DashboardBloc>(
        builder: (context, bloc, _) {
          if (bloc.status == DashboardStatus.loading) {
            return LoadingWidget(primaryColor: primaryColor);
          } else if (bloc.status == DashboardStatus.error) {
            return ErrorDisplayWidget(
              errorMessage: bloc.errorMessage,
              onRetry: () => bloc.loadDashboardData(),
              primaryColor: primaryColor,
            );
          } else {
            return _buildHomeContent(
              context,
              bloc,
              primaryColor,
              cardColor,
              lightPrimaryColor,
            );
          }
        },
      ),
    );
  }

  // แสดงเนื้อหาหน้า Home - ใช้ข้อมูลจาก bloc
  Widget _buildHomeContent(
    BuildContext context,
    DashboardBloc bloc,
    Color primaryColor,
    Color cardColor,
    Color lightPrimaryColor,
  ) {
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async {
        await bloc.loadDashboardData();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงจำนวนสินทรัพย์ทั้งหมด
            _buildTotalAssetsCard(primaryColor, lightPrimaryColor, bloc),

            const SizedBox(height: 24),

            // หัวข้อการแจ้งเตือนล่าสุด
            _buildNotificationHeader(primaryColor),
            const SizedBox(height: 12),

            // รายการการแจ้งเตือน
            _buildNotificationList(
              context,
              bloc,
              primaryColor,
              cardColor,
              lightPrimaryColor,
            ),

            // เพิ่มส่วนดูทรัพย์สินทั้งหมดที่ด้านล่าง
            const SizedBox(height: 32),
            _buildViewAllButton(context, bloc, primaryColor),

            // เพิ่มพื้นที่ว่างด้านล่าง
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAssetsCard(
    Color primaryColor,
    Color lightPrimaryColor,
    DashboardBloc bloc,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: lightPrimaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.inventory_2, size: 32, color: primaryColor),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'สินทรัพย์ทั้งหมด',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              Text(
                '${bloc.totalAssets} รายการ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationHeader(Color primaryColor) {
    return Row(
      children: [
        Icon(Icons.notifications, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          'การแจ้งเตือนล่าสุด',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    DashboardBloc bloc,
    Color primaryColor,
    Color cardColor,
    Color lightPrimaryColor,
  ) {
    if (!bloc.hasData) {
      return Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 16),
            Text('ไม่มีการแจ้งเตือนล่าสุด'),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: bloc.latestAssets.length,
      itemBuilder: (context, index) {
        final asset = bloc.latestAssets[index];
        return AssetNotificationItem(
          asset: asset,
          onTap: () => bloc.navigateToAssetDetails(context, asset),
          primaryColor: primaryColor,
          lightPrimaryColor: lightPrimaryColor,
        );
      },
    );
  }

  Widget _buildViewAllButton(
    BuildContext context,
    DashboardBloc bloc,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      width: double.infinity,
      child: InkWell(
        onTap: () => bloc.navigateToSearch(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.search, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'ดูทรัพย์สินทั้งหมด',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
