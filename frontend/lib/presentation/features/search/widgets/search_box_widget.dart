import 'package:flutter/material.dart';

class SearchBoxWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;
  final Color cardColor;
  final VoidCallback? onClear;
  final Widget? prefix;
  final bool showResultCount;
  final int resultCount;
  final bool isLoading;
  final Color? primaryColor;

  // =================== Multi-Select Parameters ===================
  final bool isMultiSelectMode;
  final int selectedCount;

  const SearchBoxWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search for assets...',
    this.cardColor = const Color(0xFFF5F5F8),
    this.onClear,
    this.prefix,
    this.showResultCount = false,
    this.resultCount = 0,
    this.isLoading = false,
    this.primaryColor,

    // =================== Multi-Select Parameters ===================
    this.isMultiSelectMode = false,
    this.selectedCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color highlightColor = primaryColor ?? Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // ช่องค้นหา
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      prefixIcon:
                          prefix ??
                          const Icon(Icons.search, color: Colors.grey),
                      hintText: hintText,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                      if (onClear != null) onClear!();
                    },
                  ),
              ],
            ),
          ),

          // แสดงจำนวนที่พบ
          if (showResultCount)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  isLoading
                      ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            highlightColor,
                          ),
                        ),
                      )
                      : Icon(
                        Icons.info_outline,
                        size: 16,
                        color: highlightColor,
                      ),
                  const SizedBox(width: 8),
                  Text(
                    isLoading ? 'กำลังค้นหา...' : _buildResultText(),
                    style: TextStyle(
                      color: highlightColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // =================== Helper Methods ===================
  String _buildResultText() {
    String baseText = 'พบ $resultCount รายการ';

    if (isMultiSelectMode && selectedCount > 0) {
      baseText += ' เลือก $selectedCount รายการ';
    }

    return baseText;
  }
}
