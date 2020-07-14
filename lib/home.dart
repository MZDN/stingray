import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stingray/model/item.dart';
import 'package:stingray/repo.dart';

final FutureProvider topStories = FutureProvider((ref) async {
  return await Repo.getTopStories();
});

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new ScrollController();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if (_controller.position.extentAfter <= 500) {
        print("Fetching..");
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        (context, read) {
          return read(topStories).when(
            loading: () => Center(child: const CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
            data: (items) {
              return NotificationListener(
                onNotification: _handleScrollNotification,
                child: ListView.builder(
                  controller: _controller,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    Item item = items[index];
                    return ListTile(
                      key: Key(item.id.toString()),
                      onTap: () {},
                      title: Text(
                        item.title,
                      ),
                      subtitle: Text(
                        "${item.descendants.toString()} comments",
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
