import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'my_photo_view.dart';

class CustomTabView extends StatefulWidget {
  @override
  CustomTabViewState createState() => CustomTabViewState();
}

class CustomTabViewState extends State<CustomTabView>
    with TickerProviderStateMixin {
  TabController _controller;
  AnimationController _animationControllerOn;
  AnimationController _animationControllerOff;

  Animation _colorTweenBackgroundOn;
  Animation _colorTweenBackgroundOff;
  Animation _colorTweenForegroundOn;
  Animation _colorTweenForegroundOff;

  int _currentIndex = 0;
  int _prevControllerIndex = 0;
  double _aniValue = 0.0;
  double _prevAniValue = 0.0;

  List textlist = [
    "One Item White BG",
    "Cats",
  ];

  Color _foregroundOn = Colors.black;
  Color _foregroundOff = Colors.white;
  Color _backgroundOn = Colors.white;
  Color _backgroundOff = Colors.transparent;

  List _keys = [];
  bool _buttonTap = false;

  @override
  void initState() {
    super.initState();

    for (int index = 0; index < textlist.length; index++) {
      _keys.add(new GlobalKey());
    }

    _controller = TabController(vsync: this, length: textlist.length);
    _controller.animation.addListener(_handleTabAnimation);
    _controller.addListener(_handleTabChange);
    _animationControllerOff =
        AnimationController(vsync: this, duration: Duration(milliseconds: 75));
    _animationControllerOff.value = 1.0;
    _colorTweenBackgroundOff =
        ColorTween(begin: _backgroundOn, end: _backgroundOff)
            .animate(_animationControllerOff);
    _colorTweenForegroundOff =
        ColorTween(begin: _foregroundOn, end: _foregroundOff)
            .animate(_animationControllerOff);
    _animationControllerOn =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    _animationControllerOn.value = 1.0;
    _colorTweenBackgroundOn =
        ColorTween(begin: _backgroundOff, end: _backgroundOn)
            .animate(_animationControllerOn);
    _colorTweenForegroundOn =
        ColorTween(begin: _foregroundOff, end: _foregroundOn)
            .animate(_animationControllerOn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
//          appBar: AppBar(
//            elevation: 0.0,
//            automaticallyImplyLeading: false,
//            backgroundColor: Colors.transparent,
//            title: Container(
//              width: 150,
//              height: 60,
//              child: Text('YES' ,),
//            ),
//          ),
          backgroundColor: Colors.white,
          body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20),
                  Center(
                      child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.grey[350],
                              borderRadius: BorderRadius.circular(5.0))
                          ,


                          child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      key: _keys[0],
                                      padding: EdgeInsets.all(1.0),
                                      child: ButtonTheme(
                                          child: AnimatedBuilder(
                                            animation: _colorTweenBackgroundOn,
                                            builder: (context, child) => FlatButton(
                                                color: _getBackgroundColor(0),
                                                shape: ContinuousRectangleBorder(
                                                    borderRadius:
                                                    new BorderRadius.circular(
                                                        5.0)),
                                                onPressed: () {
                                                  setState(() {
                                                    _buttonTap = true;
                                                    _controller.animateTo(0);
                                                    _setCurrentIndex(0);
                                                    _scrollTo(0);
                                                  });
                                                },
                                                child: Text(textlist[0],
                                                    style: TextStyle(
                                                        color:
                                                        _getForegroundColor(0)))),
                                          ))),
                                  Padding(
                                      key: _keys[1],
                                      padding: EdgeInsets.all(1.0),
                                      child: ButtonTheme(
                                          child: AnimatedBuilder(
                                            animation: _colorTweenBackgroundOn,
                                            builder: (context, child) => FlatButton(
                                                color: _getBackgroundColor(1),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _buttonTap = true;
                                                    _controller.animateTo(1);
                                                    _setCurrentIndex(1);
                                                    _scrollTo(1);
                                                  });
                                                },
                                                child: Text(
                                                  textlist[1],
                                                  style: TextStyle(
                                                      color: _getForegroundColor(1)),
                                                )),
                                          ))),
                                ],
                              )))),
                  Flexible(
                      child: TabBarView(
                        controller: _controller,
                        children: <Widget>[
                          MyPhotoView('1580860'),
                        MyPhotoView('139386')
                        ],
                      )),
                  SizedBox(height: 20)]),
          ),
    );
  }

  _handleTabAnimation() {
    _aniValue = _controller.animation.value;
    if (!_buttonTap && ((_aniValue - _prevAniValue).abs() < 1)) {
      _setCurrentIndex(_aniValue.round());
    }
    _prevAniValue = _aniValue;
  }

  _handleTabChange() {
    if (_buttonTap) _setCurrentIndex(_controller.index);
    if ((_controller.index == _prevControllerIndex) ||
        (_controller.index == _aniValue.round())) _buttonTap = false;
    _prevControllerIndex = _controller.index;
  }

  _setCurrentIndex(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _triggerAnimation();
      _scrollTo(index);
    }
  }

  _triggerAnimation() {
    _animationControllerOn.reset();
    _animationControllerOff.reset();
    _animationControllerOn.forward();
    _animationControllerOff.forward();
  }

  _scrollTo(int index) {
    double screenWidth = MediaQuery.of(context).size.width;
    RenderBox renderBox = _keys[index].currentContext.findRenderObject();
    double size = renderBox.size.width;
    double position = renderBox.localToGlobal(Offset.zero).dx;
    double offset = (position + size / 2) - screenWidth / 2;
    if (offset < 0) {
      renderBox = _keys[0].currentContext.findRenderObject();
      position = renderBox.localToGlobal(Offset.zero).dx;
      if (position > offset) offset = position;
    } else {
      renderBox = _keys[textlist.length - 1].currentContext.findRenderObject();
      position = renderBox.localToGlobal(Offset.zero).dx;
      size = renderBox.size.width;
      if (position + size < screenWidth) screenWidth = position + size;
      if (position + size - offset < screenWidth) {
        offset = position + size - screenWidth;
      }
    }
//    _scrollController.animateTo(offset + _scrollController.offset,
//        duration: new Duration(milliseconds: 150), curve: Curves.easeInOut);
  }

  _getBackgroundColor(int index) {
    if (index == _currentIndex) {
      return _colorTweenBackgroundOn.value;
    } else if (index == _prevControllerIndex) {
      return _colorTweenBackgroundOff.value;
    } else {
      return _backgroundOff;
    }
  }

  _getForegroundColor(int index) {
    if (index == _currentIndex) {
      return _colorTweenForegroundOn.value;
    } else if (index == _prevControllerIndex) {
      return _colorTweenForegroundOff.value;
    } else {
      return _foregroundOff;
    }
  }
}