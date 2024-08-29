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
  double itemsPerColumn = 30;

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
            onPageChanged: (index) {
              debugPrint('changed to page $index');
            },
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
