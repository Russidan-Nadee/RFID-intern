import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/dashboard_bloc.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_stats.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToTabByIndex(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(title: const Text('Asset Management Dashboard')),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<DashboardBloc>(
        builder: (context, bloc, child) {
          if (bloc.status == DashboardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (bloc.status == DashboardStatus.error) {
            return Center(child: Text('Error: ${bloc.errorMessage}'));
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  DashboardHeader(),
                  SizedBox(height: 24),
                  DashboardStats(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
