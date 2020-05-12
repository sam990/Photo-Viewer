import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'models.dart';
import 'unsplash_image_provider.dart';
import 'image_tile.dart';
import 'loading_indicator.dart';

/// Screen for showing a collection of trending [UnsplashImage].
class MyPhotoView extends StatefulWidget {
  final String _collectionId;
  MyPhotoView(this._collectionId);

  @override
  MyPhotoViewState createState() => MyPhotoViewState(_collectionId);
}


/// Provide a state for [MainPage].
class MyPhotoViewState extends State<MyPhotoView> with AutomaticKeepAliveClientMixin<MyPhotoView>{
  ///maintains persistence when switching tabs
  bool get wantKeepAlive => true;
  /// Stores the current page index for the api requests.
  int page = 0, totalPages = -1;
  /// Stores the currently loaded loaded images.
  List<UnsplashImage> images = [];
  /// States whether there is currently a task running loading images.
  bool loadingImages = false;
  ///collection id of the collection
  String _collectionId;

  MyPhotoViewState(this._collectionId);


  @override
  initState() {
    super.initState();
    // initial image Request
    _loadImages();
  }

  /// Resets the state to the inital state.
  _resetImages() {
    // clear image list
    images = [];
    // reset page counter
    page = 0;
    totalPages = -1;
    // show regular images
    _loadImages();
  }

  /// Requests a list of [UnsplashImage] for a given [keyword].
  /// If the given [keyword] is null, trending images are loaded.
  _loadImages() async {
    // check if there is currently a loading task running
    if (loadingImages) {
      // there is currently a task running
      return;
    }
    // check if all pages are already loaded
    if (totalPages != -1 && page >= totalPages) {
      // all pages already loaded
      return;
    }
    // set loading state
    // delay setState, otherwise: Unhandled Exception: setState() or markNeedsBuild() called during build.
    await Future.delayed(Duration(microseconds: 1));
    setState(() {
      // set loading
      loadingImages = true;
      // check if new search
    });
    // load images
    List<UnsplashImage> images;
    List res = await UnsplashImageProvider.loadImagesOfCollection(_collectionId,
        page: ++page);
    // set totalPages
    totalPages = res[0];
    // set images
    images = res[1];
    //set the images
    this.images.addAll(images);
    // update the state
    setState(() {
      // done loading
      loadingImages = false;
    });
  }


  /// Asynchronously loads a [UnsplashImage] for a given [index].
  Future<UnsplashImage> _loadImage(int index) async {
    // check if new images need to be loaded
    if (index >= images.length - 2 ) {
      // Reached the end of the list. Try to load more images.
      await _loadImages();
    }
    return index < images.length ? images[index] : null;
  }

  @override
  Widget build(BuildContext context) =>

      Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Scaffold(
            backgroundColor: Colors.grey[50],
            body: OrientationBuilder(
                builder: (context, orientation) => CustomScrollView(
                  // put AppBar in NestedScrollView to have it sliver off on scrolling
                    slivers: <Widget>[
                      _buildImageGrid(orientation: orientation),
                      // loading indicator at the bottom of the list
                      loadingImages
                          ? SliverToBoxAdapter(
                        child: LoadingIndicator(Colors.grey[400]),
                      )
                          : null,
                      // filter null views
                    ].where((w) => w != null).toList()))),
      );


  /// Returns a StaggeredTile for a given [image].
  StaggeredTile _buildStaggeredTile(UnsplashImage image, int columnCount) {
    // calc image aspect ration
    double aspectRatio =
        image.getHeight().toDouble() / image.getWidth().toDouble();
    // calc columnWidth
    double columnWidth = MediaQuery.of(context).size.width / columnCount;
    // not using [StaggeredTile.fit(1)] because during loading StaggeredGrid is really jumpy.
    return StaggeredTile.extent(1, aspectRatio * columnWidth + 16.0);
  }

  /// Returns the grid that displays images.
  /// [orientation] can be used to adjust the grid column count.
  Widget _buildImageGrid({orientation = Orientation.portrait}) {
    // calc columnCount based on orientation
    int columnCount = orientation == Orientation.portrait ? 2 : 3;
    // return staggered grid
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverStaggeredGrid.countBuilder(
        // set column count
        crossAxisCount: columnCount,
        itemCount: images.length,
        // set itemBuilder
        itemBuilder: (BuildContext context, int index) =>
            _buildImageItemBuilder(index),
        staggeredTileBuilder: (int index) =>
            _buildStaggeredTile(images[index], columnCount),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
      ),
    );
  }

  /// Returns a FutureBuilder to load a [UnsplashImage] for a given [index].
  Widget _buildImageItemBuilder(int index) => FutureBuilder(
        // pass image loader
        future: _loadImage(index),
        builder: (context, snapshot) => snapshot.hasData ? ImageTile(snapshot.data) : Container()
            // image loaded return [_ImageTile]

      );
}
