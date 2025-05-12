import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../blocs/navigation_bloc.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationBloc>(
      builder: (context, bloc, _) {
        return Scaffold(
          body: child,
          bottomNavigationBar: AppBottomNavigation(
            currentIndex: bloc.currentIndex,
            onTap: (index) {
              bloc.setCurrentIndex(index);
              NavigationService.navigateToTabByIndex(context, index);
            },
          ),
        );
      },
    );
  }
}
