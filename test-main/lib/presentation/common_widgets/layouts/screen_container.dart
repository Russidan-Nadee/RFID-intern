// ไฟล์ lib/presentation/common_widgets/layouts/screen_container.dart
import 'package:flutter/material.dart';

class ScreenContainer extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  const ScreenContainer({
    Key? key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
