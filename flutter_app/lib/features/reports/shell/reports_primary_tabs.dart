import 'package:flutter/material.dart';

import '../reports_bi_tab.dart';

/// Primary Reports BI tabs — [TabBar] chrome (not filter ChoiceChips).
class ReportsPrimaryTabs extends StatefulWidget {
  const ReportsPrimaryTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ReportsBiTab selected;
  final ValueChanged<ReportsBiTab> onSelected;

  @override
  State<ReportsPrimaryTabs> createState() => _ReportsPrimaryTabsState();
}

class _ReportsPrimaryTabsState extends State<ReportsPrimaryTabs>
    with SingleTickerProviderStateMixin {
  static const _tabs = ReportsBiTabX.primaryTabs;

  late final TabController _controller;

  int _indexFor(ReportsBiTab tab) {
    final i = _tabs.indexOf(tab);
    return i < 0 ? 0 : i;
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: _indexFor(widget.selected),
    );
    _controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_controller.indexIsChanging) return;
    final tab = _tabs[_controller.index];
    if (tab != widget.selected) widget.onSelected(tab);
  }

  @override
  void didUpdateWidget(covariant ReportsPrimaryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _indexFor(widget.selected);
    if (next != _controller.index) {
      _controller.animateTo(next);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: TabBar(
        controller: _controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [for (final t in _tabs) Tab(text: t.shortLabel)],
      ),
    );
  }
}
