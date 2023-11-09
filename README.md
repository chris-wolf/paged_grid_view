<?code-excerpt path-base="excerpts/packages/paged_grid_view"?>

# Paged GridView

[![pub package](https://img.shields.io/pub/v/paged_grid_view.svg)](https://pub.dev/packages/paged_grid_view)

GridView with following adjustments:
* PageScrollPhysics set as default
* Better scroll performance by changing cacheExtent depending on scrollOffset to prevent itemBuild during scrolling.

### An example comparing scroll preformance to GridView can be found here: [***dartpad.dev***](https://dartpad.dev/?id=6c9f64d9032cefa564b72c7bbd1c979a).

> :warning: **Doesn't improve scrollController.animateTo performance**

## Installation

First, add `paged_grid_view` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

##  Usage

```
import 'package:paged_grid_view/paged_grid_view.dart';

  @override
  Widget build(BuildContext context) {
    @override
    Widget build(BuildContext context) {
      return PagedGridView.builder(
          itemCount: 1000,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisExtent: MediaQuery.sizeOf(context).width / 10,
              crossAxisCount: 10),
          scrollDirection: Axis.horizontal,
          physics: const PageScrollPhysics(),
          itemBuilder: (context, index) {
            return ColoredBox(
              key: UniqueKey(),
              color: Color(Random().nextInt(0xffffff) + 0xff000000),
            );
          });
    }
  }
```

## Example

```
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:paged_grid_view/paged_grid_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paged GridView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double itemsPerColumn = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PagedGridView Demo'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text("Axis item count:"),
                Expanded(
                  child: Slider(
                    max: 100,
                    min: 1,
                    divisions: 99,
                    label: itemsPerColumn.round().toString(),
                    value: itemsPerColumn,
                    onChanged: (double value) {
                      setState(() {
                        itemsPerColumn = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text("GridView:")),
          ),
          Expanded(
              child: GridView.builder(
            itemCount: (itemsPerColumn * itemsPerColumn * 10).round(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent:
                    MediaQuery.sizeOf(context).width / itemsPerColumn.round(),
                crossAxisCount: itemsPerColumn.round()),
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(),
            itemBuilder: (context, index) {
              debugPrint("gridView build item $index");
              return ColoredBox(
                key: UniqueKey(),
                color: Color(Random().nextInt(0xffffff) + 0xff000000),
              );
            },
          )),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text("PagedGridView:")),
          ),
          Expanded(
              child: PagedGridView.builder(
            itemCount: (itemsPerColumn * itemsPerColumn * 10).round(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent:
                    MediaQuery.sizeOf(context).width / itemsPerColumn.round(),
                crossAxisCount: itemsPerColumn.round()),
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(),
            itemBuilder: (context, index) {
              debugPrint("pagedGridView build item $index");
              return ColoredBox(
                key: UniqueKey(),
                color: Color(Random().nextInt(0xffffff) + 0xff000000),
              );
            },
          )),
        ],
      ),
    );
  }
}
```