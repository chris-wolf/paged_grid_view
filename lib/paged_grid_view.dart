import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PagedGridView extends GridView {
  final void Function(int pageIndex)? onPageChanged;

  PagedGridView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics = const PageScrollPhysics(),
    super.shrinkWrap,
    super.padding,
    required super.gridDelegate,
    super.addAutomaticKeepAlives = true,
    super.addRepaintBoundaries = true,
    super.addSemanticIndexes = true,
    super.cacheExtent,
    super.children = const <Widget>[],
    super.semanticChildCount,
    super.dragStartBehavior,
    super.clipBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    this.onPageChanged,
  });

  PagedGridView.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics = const PageScrollPhysics(),
    super.shrinkWrap,
    super.padding,
    required super.gridDelegate,
    required NullableIndexedWidgetBuilder itemBuilder,
    super.findChildIndexCallback,
    super.itemCount,
    super.addAutomaticKeepAlives = true,
    super.addRepaintBoundaries = true,
    super.addSemanticIndexes = true,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    this.onPageChanged,
  }) : super.builder(itemBuilder: itemBuilder);

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset offset,
    AxisDirection axisDirection,
    List<Widget> slivers,
  ) {
    assert(() {
      switch (axisDirection) {
        case AxisDirection.up:
        case AxisDirection.down:
          return debugCheckHasDirectionality(
            context,
            why: 'to determine the cross-axis direction of the scroll view',
            hint:
                'Vertical scroll views create Viewport widgets that try to determine their cross axis direction '
                'from the ambient Directionality.',
          );
        case AxisDirection.left:
        case AxisDirection.right:
          return true;
      }
    }());
    if (shrinkWrap) {
      return ShrinkWrappingViewport(
        axisDirection: axisDirection,
        offset: offset,
        slivers: slivers,
        clipBehavior: clipBehavior,
      );
    }
    return PagedViewPort(
      axisDirection: axisDirection,
      offset: offset,
      slivers: slivers,
      cacheExtent: cacheExtent,
      center: center,
      anchor: anchor,
      clipBehavior: clipBehavior,
      onPageChanged: onPageChanged,
    );
  }
}

class PagedViewPort extends Viewport {
  final void Function(int pageIndex)? onPageChanged;

  PagedViewPort({
    super.key,
    super.axisDirection = AxisDirection.down,
    super.crossAxisDirection,
    super.anchor = 0.0,
    required super.offset,
    super.center,
    super.cacheExtent,
    super.cacheExtentStyle = CacheExtentStyle.pixel,
    super.clipBehavior = Clip.hardEdge,
    super.slivers,
    this.onPageChanged,
  });

  @override
  RenderViewport createRenderObject(BuildContext context) {
    return PagedRenderViewport(
      axisDirection: axisDirection,
      crossAxisDirection: crossAxisDirection ??
          Viewport.getDefaultCrossAxisDirection(context, axisDirection),
      anchor: anchor,
      offset: offset,
      cacheExtent: cacheExtent,
      cacheExtentStyle: cacheExtentStyle,
      clipBehavior: clipBehavior,
      onPageChanged: onPageChanged,
    );
  }
}

class PagedRenderViewport extends RenderViewport {
  static const buildItemsForPageCount = 3;
  int? lastPageIndex;
  double lastIdleScrollOffset = 0.0;
  final void Function(int pageIndex)? onPageChanged;

  PagedRenderViewport({
    super.axisDirection,
    required super.crossAxisDirection,
    required super.offset,
    super.anchor = 0.0,
    super.children,
    super.center,
    super.cacheExtent,
    super.cacheExtentStyle,
    super.clipBehavior,
    this.onPageChanged,
  });

  @override
  void performLayout() {
    super.performLayout();

    if (onPageChanged == null) {
      return;
    }

    // Calculate the current page index
    final double mainAxisExtent = axisDirection == AxisDirection.left ||
            axisDirection == AxisDirection.right
        ? size.width
        : size.height;
    final int currentPageIndex = (offset.pixels / mainAxisExtent).round();

    // If the page index has changed, trigger the callback
    if (lastPageIndex != currentPageIndex) {
      lastPageIndex = currentPageIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onPageChanged?.call(currentPageIndex);
      });
    }
  }

  @override
  double layoutChildSequence({
    required RenderSliver? child,
    required double scrollOffset,
    required double overlap,
    required double layoutOffset,
    required double remainingPaintExtent,
    required double mainAxisExtent,
    required double crossAxisExtent,
    required GrowthDirection growthDirection,
    required RenderSliver? Function(RenderSliver child) advance,
    required double remainingCacheExtent,
    required double cacheOrigin,
  }) {
    double dynamicPagedCacheOrigin = -mainAxisExtent;

    // when idle, set lastIdleScrollOffset to build items for adjacent pages
    if (offset.userScrollDirection == ScrollDirection.idle) {
      lastIdleScrollOffset = scrollOffset;
    }

    // move cacheExtentOrigin dependent on scrollOffset to prevent building new items during scrolling
    dynamicPagedCacheOrigin =
        min((lastIdleScrollOffset - scrollOffset) - mainAxisExtent, 0);

    // workaround for scrolling multiple pages without being idle in between, there should probably bee a better way...
    if (dynamicPagedCacheOrigin <
            -(buildItemsForPageCount - 1) * mainAxisExtent ||
        dynamicPagedCacheOrigin >
            (buildItemsForPageCount - 1) * mainAxisExtent) {
      dynamicPagedCacheOrigin = -mainAxisExtent;
    }

    return super.layoutChildSequence(
        child: child,
        scrollOffset: scrollOffset,
        overlap: overlap,
        layoutOffset: layoutOffset,
        remainingPaintExtent: remainingPaintExtent,
        mainAxisExtent: mainAxisExtent,
        crossAxisExtent: crossAxisExtent,
        growthDirection: growthDirection,
        advance: advance,
        remainingCacheExtent: buildItemsForPageCount * mainAxisExtent,
        cacheOrigin: dynamicPagedCacheOrigin);
  }
}
