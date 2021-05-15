import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import './GalleryFolders.dart';
import './ToastDisplay.dart';

class ModelFileAssest {
  Widget mediaList;
  AssetEntity assetsEntity;

  ModelFileAssest({this.mediaList, this.assetsEntity, this.selected = false});

  bool selected;
}

class GalleryGridView extends StatefulWidget {
  AssetFolderName data;
  int limit;
  GalleryGridView({this.data, this.limit = 10});
  @override
  _GalleryGridViewState createState() => _GalleryGridViewState();
}

class _GalleryGridViewState extends State<GalleryGridView> {
  List<ModelFileAssest> modelList = [];
  Set<int> indexesSelect = Set<int>();
  int currentPage = 0;
  int lastPage;
  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
//load the album list
      // List<AssetPathEntity> albums =
      //     await PhotoManager.getAssetPathList(onlyAll: true);
      // print(albums);
      List<AssetEntity> media =
          await widget.data.assetPathEntiy.getAssetListPaged(currentPage, 60);
      //albums[0].getAssetListPaged(currentPage, 60);
      List<Widget> temp = [];
      for (var asset in media) {
        if (asset.type == AssetType.image) {
          // path.add(asset.relativePath + asset.title);

          temp.add(
            FutureBuilder(
              future: asset.thumbDataWithSize(200, 200),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done)
                  return Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Image.memory(
                          snapshot.data,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  );
                return Container();
              },
            ),
          );

          modelList.add(ModelFileAssest(
              mediaList: temp.last, assetsEntity: asset, selected: false));
        }
      }
      setState(() {
        // model.mediaList.addAll(temp);
        //_mediaList.addAll(temp);
        currentPage++;
      });
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.data.name.toString() +
              " (${indexesSelect.length}/${widget.limit})"),
        ),
        floatingActionButton: new FloatingActionButton(
            elevation: 0.0,
            child: new Icon(Icons.check),
            backgroundColor: new Color(0xFFE57373),
            onPressed: () {}),
        body: bodyView());
  }

  Widget bodyView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scroll) {
        _handleScrollEvent(scroll);
        return;
      },
      child: GridView.builder(
          itemCount: modelList.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (BuildContext context, int index) {
            return imageview(modelList[index].mediaList, index);
          }),
    );
  }

  imageview(media, index) {
    return GestureDetector(
      onTap: () {
        print("widget.limit${widget.limit}");
        print("indexesSelect.length${indexesSelect.length}");
        if (indexesSelect.length == widget.limit &&
            !modelList[index].selected) {
          ToastDisplay.show(
              "Selection full,Deselect an image to choose another", context);
          return;
        }
        setState(() {
          modelList[index].selected = !modelList[index].selected;
        });

        if (modelList[index].selected) {
          indexesSelect.add(index);
        } else {
          indexesSelect.removeWhere((element) => element == index);
        }
        setState(() {});
        print("Click $index");
        print("SET $indexesSelect");
      },
      child: modelList[index].selected
          ? Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellowAccent, width: 2)),
              child: Stack(
                children: [
                  media,
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 5, bottom: 5),
                      child: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ))
          : Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2)),
              child: media,
            ),
    );
  }
}
