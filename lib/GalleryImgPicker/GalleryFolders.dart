import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../GalleryImgPicker/GalleryGridView.dart';

class AssetFolderName {
  AssetPathEntity assetPathEntiy;
  String name;
  String count;
  File file;
  Uint8List thumbBytes;
  AssetFolderName(
      {this.assetPathEntiy, this.name, this.count, this.file, this.thumbBytes});
}

class GalleryFolders extends StatefulWidget {
  int limit;

  GalleryFolders({Key key, this.title, this.limit}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _GalleryFoldersState createState() => _GalleryFoldersState();
}

class _GalleryFoldersState extends State<GalleryFolders> {
  int _counter = 0;

  /// List<AssetPathEntity> listData = [];
  List<AssetFolderName> listData = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listGallery();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  FilterOptionGroup makeOption() {
    String minWidth = "0";
    String maxWidth = "10000";
    String minHeight = "0";
    String maxHeight = "10000";
    bool _ignoreSize = true;
    Duration _minDuration = Duration.zero;
    Duration _maxDuration = Duration(hours: 1);
    bool _needTitle = false;
    final option = FilterOption(
      sizeConstraint: SizeConstraint(
        minWidth: int.tryParse(minWidth) ?? 0,
        maxWidth: int.tryParse(maxWidth) ?? 100000,
        minHeight: int.tryParse(minHeight) ?? 0,
        maxHeight: int.tryParse(maxHeight) ?? 100000,
        ignoreSize: true,
      ),
      durationConstraint: DurationConstraint(
        min: _minDuration,
        max: _maxDuration,
      ),
      needTitle: _needTitle,
    );
  }

  listGallery() async {
    var galleryList = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
      onlyAll: false,
      filterOption: makeOption(),
    );

    print("galleryList.length");
    print(galleryList.length);

    for (int i = 0; i < galleryList.length; i++) {
      AssetPathEntity element = galleryList[i];
      listData.add(AssetFolderName(
          assetPathEntiy: element,
          count: element.assetCount.toString(),
          file: null,
          name: element.name,
          thumbBytes: null));

      print(listData.length);
      getImgThumbNail(element, i);
    }
    setState(() {});
    // galleryList.forEach((element) async {
    //   print("step1");
    //   listData.add(AssetFolderName(
    //       assetPathEntiy: element,
    //       count: element.assetCount.toString(),
    //       file: null,
    //       name: element.name,
    //       thumbBytes: null));

    //   print(listData.length);

    //   if (galleryList.length == listData.length) {
    //     setState(() {});

    //     print("listData.length${listData.length}");
    //   }
    // });
  }

  Future<Uint8List> getImgThumbNail(AssetPathEntity element, int index) async {
    List<AssetEntity> data = await element.getAssetListRange(start: 0, end: 1);
    // File file;
    // print("step2");
    // data.length > 0 ? await data.first.file : File("");
    // // print("data.length");
    // // print(data.length);
    // print("step3");
    Uint8List thumbBytes = data.length > 0 ? await data[0].thumbData : null;

    listData[index].thumbBytes = thumbBytes;
    setState(() {});
    //return thumbBytes;
    // print("step4");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: bodyList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  bodyList() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: listData.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => GalleryGridView(
                      data: listData[index],
                      limit: widget.limit,
                    )));
          },
          child: Container(
            height: 100,
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: listData[index].thumbBytes == null
                      ? Container(
                          color: Colors.grey,
                        )
                      : Image.memory(
                          listData[index].thumbBytes,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(width: 20),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      listData[index].name == ""
                          ? "No name"
                          : listData[index].name,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Text(
                      listData[index].count + " Photos",
                      maxLines: 1,
                    ),
                  ],
                ))
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
