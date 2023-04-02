// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list_extended/scrollable_positioned_list_extended.dart';

const numberOfItems = 5001;
const minItemHeight = 20.0;
const maxItemHeight = 150.0;
const scrollDuration = Duration(seconds: 2);

const randomMax = 32;

void main() {
  runApp(ScrollablePositionedListExample());
}

// The root widget for the example app.
class ScrollablePositionedListExample extends StatelessWidget {
  const ScrollablePositionedListExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScrollablePositionedList Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ScrollablePositionedListPage(),
    );
  }
}

/// Example widget that uses [ScrollablePositionedList].
///
/// Shows a [ScrollablePositionedList] along with the following controls:
///   - Buttons to jump or scroll to certain items in the list.
///   - Slider to control the alignment of the items being scrolled or jumped
///   to.
///   - A checkbox to reverse the list.
///
/// If the device this example is being used on is in portrait mode, the list
/// will be vertically scrollable, and if the device is in landscape mode, the
/// list will be horizontally scrollable.
class ScrollablePositionedListPage extends StatefulWidget {
  const ScrollablePositionedListPage({Key? key}) : super(key: key);

  @override
  _ScrollablePositionedListPageState createState() =>
      _ScrollablePositionedListPageState();
}

class _ScrollablePositionedListPageState
    extends State<ScrollablePositionedListPage> {
  /// Controller to scroll or jump to a particular item.
  final ItemScrollController itemScrollController = ItemScrollController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  late List<double> itemHeights;
  late List<Color> itemColors;
  bool reversed = false;

  /// The alignment to be used next time the user scrolls or jumps to an item.
  double alignment = 0;
  AutoScrollController? _autoScrollController;

  @override
  void initState() {
    super.initState();
    final heightGenerator = Random(328902348);
    final colorGenerator = Random(42490823);
    itemHeights = List<double>.generate(
        numberOfItems,
        (int _) =>
            heightGenerator.nextDouble() * (maxItemHeight - minItemHeight) +
            minItemHeight);
    itemColors = List<Color>.generate(numberOfItems,
        (int _) => Color(colorGenerator.nextInt(randomMax)).withOpacity(1));
    _autoGetPosition();
  }

  void _autoGetPosition() {
    Future.delayed(const Duration(milliseconds: 500), () {
      itemScrollController.scrollListener(
        (notification) {
          _autoScrollController = itemScrollController.getAutoScrollController;
          debugPrint(notification.position.maxScrollExtent.toString());

          /// do with notification
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) => Column(
          children: <Widget>[
            Expanded(
              child: list(orientation),
            ),
            positionsView,
            Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    scrollControlButtons,
                    const SizedBox(height: 10),
                    jumpControlButtons,
                    alignmentControl,
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          itemScrollController.scrollToMax(
                              duration: const Duration(milliseconds: 800));
                        },
                        child: Text("Scroll To Max")),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          itemScrollController.scrollToMin(
                              duration: const Duration(milliseconds: 800));
                        },
                        child: Text("Scroll To Min")),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          itemScrollController.jumpToMax();
                        },
                        child: Text("Jump To Max")),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          itemScrollController.jumpToMin();
                        },
                        child: Text("Jump To Min")),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          /// Helper function of ``` (scroll_to_index)[https://pub.dev/packages/scroll_to_index] ``
                          _autoScrollController?.scrollToIndex(10);
                        },
                        child: Text("Scroll To Index Via Scroll_To_Index")),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget get alignmentControl => Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const Text('Alignment: '),
          SizedBox(
            width: 200,
            child: SliderTheme(
              data: SliderThemeData(
                showValueIndicator: ShowValueIndicator.always,
              ),
              child: Slider(
                value: alignment,
                label: alignment.toStringAsFixed(2),
                onChanged: (double value) => setState(() => alignment = value),
              ),
            ),
          ),
        ],
      );

  Widget list(Orientation orientation) => ScrollablePositionedList.builder(
      itemCount: numberOfItems,
      itemBuilder: (context, index) => item(index, orientation),
      itemScrollController: itemScrollController,
      addAutomaticKeepAlives: false,
      minCacheExtent: 0,
      itemPositionsListener: itemPositionsListener,
      reverse: reversed,
      scrollDirection: Axis.vertical);

  Widget get positionsView => ValueListenableBuilder<Iterable<ItemPosition>>(
        valueListenable: itemPositionsListener.itemPositions,
        builder: (context, positions, child) {
          int? min;
          int? max;
          if (positions.isNotEmpty) {
            // Determine the first visible item by finding the item with the
            // smallest trailing edge that is greater than 0.  i.e. the first
            // item whose trailing edge in visible in the viewport.
            min = positions
                .where((ItemPosition position) => position.itemTrailingEdge > 0)
                .reduce((ItemPosition min, ItemPosition position) =>
                    position.itemTrailingEdge < min.itemTrailingEdge
                        ? position
                        : min)
                .index;
            // Determine the last visible item by finding the item with the
            // greatest leading edge that is less than 1.  i.e. the last
            // item whose leading edge in visible in the viewport.
            max = positions
                .where((ItemPosition position) => position.itemLeadingEdge < 1)
                .reduce((ItemPosition max, ItemPosition position) =>
                    position.itemLeadingEdge > max.itemLeadingEdge
                        ? position
                        : max)
                .index;
          }
          return Row(
            children: <Widget>[
              Expanded(child: Text('First Item: ${min ?? ''}')),
              Expanded(child: Text('Last Item: ${max ?? ''}')),
              const Text('Reversed: '),
              Checkbox(
                  value: reversed,
                  onChanged: (bool? value) => setState(() {
                        reversed = value!;
                      }))
            ],
          );
        },
      );

  Widget get scrollControlButtons => Row(
        children: <Widget>[
          const Text('scroll to'),
          scrollButton(0),
          scrollButton(5),
          scrollButton(10),
          scrollButton(99),
          scrollButton(5000),
        ],
      );

  Widget get jumpControlButtons => Row(
        children: <Widget>[
          const Text('jump to'),
          jumpButton(0),
          jumpButton(5),
          jumpButton(10),
          jumpButton(99),
          jumpButton(5000),
        ],
      );

  final _scrollButtonStyle = ButtonStyle(
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
    ),
    minimumSize: MaterialStateProperty.all(Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  Widget scrollButton(int value) => TextButton(
        key: ValueKey<String>('Scroll$value'),
        onPressed: () {
          scrollTo(value);
        },
        child: Text('$value'),
        style: _scrollButtonStyle,
      );

  Widget jumpButton(int value) => TextButton(
        key: ValueKey<String>('Jump$value'),
        onPressed: () {
          jumpTo(value);
        },
        child: Text('$value'),
        style: _scrollButtonStyle,
      );

  void scrollTo(int index) async {
    if (index == 100) {
      await itemScrollController.scrollTo(
          index: 9, duration: const Duration(milliseconds: 10));
    }
    await itemScrollController
        .scrollTo(
            index: index,
            duration: scrollDuration,
            curve: Curves.easeInCubic,
            alignment: alignment)
        .then((value) {
      // _autoGetPosition();
    });
  }

  void anotherScrollTo(int index) async {
    itemScrollController.scrollToMax(
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  void jumpTo(int index) =>
      itemScrollController.jumpTo(index: index, alignment: alignment);

  // void _getController() {}

  /// Generate item number [i].
  Widget item(int i, Orientation orientation) {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[400],
              child: Center(
                child: Text('Item $i'),
              ),
            ),
          ),
          Container(
            height: 80,
            color: Colors.amber,
          )
        ],
      ),
    );
  }
}
