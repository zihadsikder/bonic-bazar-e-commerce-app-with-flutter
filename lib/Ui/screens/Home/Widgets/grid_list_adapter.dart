import 'package:eClassify/Ui/screens/Home/home_screen.dart';
import 'package:eClassify/Utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import 'package:flutter/material.dart';

enum ListUiType { Grid, List }

class GridListAdapter extends StatelessWidget {
  final ListUiType type;
  final Widget? Function(BuildContext, int) builder;
  final Widget Function(BuildContext, int)? listSaperator;
  final int total;
  final int? crossAxisCount;
  final double? height;
  final Axis? listAxis;
  final ScrollController? controller;
  final bool? isNotSidePadding;

  const GridListAdapter({
    super.key,
    required this.type,
    required this.builder,
    required this.total,
    this.crossAxisCount,
    this.height,
    this.listAxis,
    this.listSaperator,
    this.controller,
    this.isNotSidePadding,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ListUiType.List) {
      return SizedBox(
        height: listAxis == Axis.horizontal ? height : null,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
              horizontal: isNotSidePadding != null ? 0 : sidePadding),
          scrollDirection: listAxis ?? Axis.vertical,
          physics: const BouncingScrollPhysics(),
          itemBuilder: builder,
          itemCount: total,
          separatorBuilder: listSaperator ?? ((c, i) => Container()),
        ),
      );
    } else if (type == ListUiType.Grid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: sidePadding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
            crossAxisCount: crossAxisCount ?? 2,
            height: height ?? 1,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15),
        itemBuilder: builder,
        itemCount: total,
      );
    } else {
      return Container();
    }
  }
}
