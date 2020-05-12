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

  //returns the tab bar button for i position
 Widget  _getTabBar(final int i){
    return Padding(
        key: _keys[i],
        padding: EdgeInsets.all(1.0),
        child: ButtonTheme(
            child: AnimatedBuilder(
              animation: _colorTweenBackgroundOn,
              builder: (context, child) => FlatButton(
                  color: _getBackgroundColor(i),
                  shape: ContinuousRectangleBorder(
                      borderRadius:
                      new BorderRadius.circular(
                          5.0)),
                  onPressed: () {
                    setState(() {
                      _buttonTap = true;
                      _controller.animateTo(i);
                      _setCurrentIndex(i);
                    });
                  },
                  child: Text(textlist[i],
                      style: TextStyle(
                          color:
                          _getForegroundColor(i)))),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                                children: _keys.asMap().keys.map((i) => _getTabBar(i)).toList(),
                              )))),
                  Flexible(
                      child: TabBarView(
                        controller: _controller,
                        children: <Widget>[
                          MyPhotoView('1580860'), //collection views
                          MyPhotoView('139386')
                        ],
                      )),
                  SizedBox(height: 20)]),
          ),
    );
  }

  //method for handling the tab change animation
  _handleTabAnimation() {
    _aniValue = _controller.animation.value;
    if (!_buttonTap && ((_aniValue - _prevAniValue).abs() < 1)) {
      _setCurrentIndex(_aniValue.round());
    }
    _prevAniValue = _aniValue;
  }

  //method for handling the tab change
  _handleTabChange() {
    if (_buttonTap) _setCurrentIndex(_controller.index);
    if ((_controller.index == _prevControllerIndex) ||
        (_controller.index == _aniValue.round())) _buttonTap = false;
    _prevControllerIndex = _controller.index;
  }


  //set the active tab bar
  _setCurrentIndex(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _triggerAnimation();
    }
  }

  _triggerAnimation() {
    _animationControllerOn.reset();
    _animationControllerOff.reset();
    _animationControllerOn.forward();
    _animationControllerOff.forward();
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