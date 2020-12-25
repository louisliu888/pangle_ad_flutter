import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pangle_ad_flutter/pangle_ad_flutter.dart';
import 'package:pangle_ad_flutter/pangle_plugin.dart';

class ExpressFeedPage extends StatefulWidget {
  @override
  _ExpressFeedPageState createState() => _ExpressFeedPageState();
}

class Item {
  bool isAd;
  String id;
  String feedId;
  Item({this.isAd = false, this.feedId, this.id});
}

class _ItemKey extends GlobalObjectKey<ExpressFeedViewState> {
  _ItemKey(Object value) : super(value);
}

class _ExpressFeedPageState extends State<ExpressFeedPage> {
  final items = <Item>[];
  final feedIds = <String>[];

  final _controller = ScrollController();

  final _titleKey = GlobalKey();
  final _naviKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadFeedAd();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: _titleKey,
        title: Text('Feed Express AD'),
      ),
      bottomNavigationBar: BottomNavigationBar(
          key: _naviKey,
          onTap: (value) {
            // Navigator.of(context).push(CupertinoPageRoute(
            //   builder: (context) => EmptyPage(),
            // ));
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Like',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Dislike',
            ),
          ]),
      body: Container(
          child: ListView.builder(
        itemCount: items.length,
        controller: _controller,
        itemBuilder: (context, index) {
          return _buildItem(index);
        },
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _loadFeedAd();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildItem(int index) {
    var item = items[index];
    if (item.isAd) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: ExpressFeedView(
          key: _ItemKey(item.feedId),
          id: item.feedId,
          isUserInteractionEnabled: false,
          onRemove: () {
            this.feedIds.remove(item.feedId);
            setState(() {
              this.items.removeAt(index);
            });
          },
        ),
      );
    }

    return Loading();
  }

  /// 加载广告
  _loadFeedAd() async {
    PangleAdReturn feedAd = await pangle.loadExpressFeedAd(
      config: ExpressFeedConfig(
        iOSSlotId: "945702157",
        androidSlotId: "945702157",
        expressSize: PangleExpressSize.widthPercent(1.0, aspectRatio: 1.32),
      ),
    );

    final data = <Item>[];
    int totalCount = 20;

    for (var i = 0; i < totalCount; i++) {
      var item = Item(id: i.toString());
      data.add(item);
    }

    final itemPositions = [5, 10, 15];
    for (var i = 0; i < feedAd.count; i++) {
      int index = itemPositions.removeAt(0);
      final item = Item(isAd: true, feedId: feedAd.data[i]);
      data.insert(index, item);
      feedIds.add(item.feedId);
    }
    setState(() {
      this.items
        ..clear()
        ..addAll(data);
    });
  }

  _onScroll() {
    if (!Platform.isIOS) {
      return;
    }

    RenderBox titleBox = _titleKey.currentContext.findRenderObject();
    var titleSize = titleBox.size;
    var titleOffset = titleBox.localToGlobal(Offset.zero);

    final minAvailableHeigt = titleOffset.dy + titleSize.height;

    RenderBox naviBox = _naviKey.currentContext.findRenderObject();
    var naviOffset = naviBox.localToGlobal(Offset.zero);

    final maxAvailableHeight = naviOffset.dy;

    /// 检测各个item的宽高、偏移量是否满足点击需求
    for (var value in feedIds) {
      _switchUserInteraction(maxAvailableHeight, minAvailableHeigt, value);
    }
  }

  void _switchUserInteraction(
    double maxAvailableHeight,
    double minAvailableHeigt,
    String id,
  ) {
    var itemKey = _ItemKey(id);
    RenderBox renderBox = itemKey.currentContext?.findRenderObject();
    if (renderBox != null) {
      var size = renderBox.size;
      var offset = renderBox.localToGlobal(Offset.zero);

      /// 最底部坐标不低于NavigationBar, 最顶部不高于AppBar
      var available = offset.dy + size.height < maxAvailableHeight &&
          offset.dy > minAvailableHeigt;
      itemKey.currentState.setUserInteractionEnabled(available);
    }
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              color: Colors.grey[300],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 8.0,
                    color: Colors.grey[300],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                  ),
                  Container(
                    width: double.infinity,
                    height: 8.0,
                    color: Colors.grey[300],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                  ),
                  Container(
                    width: 40.0,
                    height: 8.0,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
