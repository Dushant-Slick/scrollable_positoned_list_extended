# scrollable_positioned_list_extended

A flutter list that allows scrolling to a specific item in the list.

Also allows determining what items are currently visible.


# Note

**This is an extension of [scrollable_positioned_list](https://pub.dev/packages/scrollable_positioned_list), which exposes helper methods like `scrollToMax` extent, `jumpToMax` extent and also `scrollListener` to listen notifications which has not implemented in that yet.**


# Added Features

1. `scrollToMax` For scrolling to maximum extent.
2. `jumpToMax` For jumping to maximum extent.
3. `scrollToMin` For scrolling to minimum extent.
4. `jumpToMin` For jumping to minimum extent.
5. `scrollListener` For listening `ScrollNotifications` like current offset `ScrollPostition`  see [here]().




## Usage

A `ScrollablePositionedList` works much like the builder version of `ListView`
except that the list can be scrolled or jumped to a specific item.

### Example

A `ScrollablePositionedList` can be created with:

```dart
final ItemScrollController itemScrollController = ItemScrollController();
final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

ScrollablePositionedList.builder(
  itemCount: 500,
  itemBuilder: (context, index) => Text('Item $index'),
  itemScrollController: itemScrollController,
  itemPositionsListener: itemPositionsListener,
);
```

One then can scroll to a particular item with:

```dart
itemScrollController.scrollTo(
  index: 150,
  duration: Duration(seconds: 2),
  curve: Curves.easeInOutCubic);
```

or jump to a particular item with:

```dart
itemScrollController.jumpTo(index: 150);
```

One can monitor what items are visible on screen with:

```dart
itemPositionsListener.itemPositions.addListener(() => ...);
```


 One can listen to scrollNotifications of primary `ScrollController` 

```dart
   itemScrollController.scrollListener(
        (notification) {
          debugPrint(notification.position.maxScrollExtent.toString());
          /// do with notification
        },
      );
```

One can scroll to max 

```dart
itemScrollController.scrollToMax(
  duration: Duration(seconds: 2),
  curve: Curves.easeInOutCubic);
```

or jump to maxExtent:

```dart
itemScrollController.jumpToMax();
```

One can scroll to min 

```dart
itemScrollController.scrollToMin(
  duration: Duration(seconds: 2),
  curve: Curves.easeInOutCubic);
```


or jump to minExtent:

```dart
itemScrollController.jumpToMin();
```


A full example can be found in the example folder.

--------------------------------------------------------------------------------

This is not an officially supported Google product.
