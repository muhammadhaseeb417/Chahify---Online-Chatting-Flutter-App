import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:recipe_flutter_app/pages/home.dart';
import 'package:recipe_flutter_app/pages/register.dart';
import 'package:recipe_flutter_app/pages/signin.dart';

class NavigationService {
  late final GlobalKey<NavigatorState> _navigationKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => Signin(),
    "/register": (context) => RegisterPage(),
    "/home": (context) => Home(),
  };

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  GlobalKey<NavigatorState> get navigationKey {
    return _navigationKey;
  }

  NavigationService() {
    _navigationKey = GlobalKey<NavigatorState>();
  }

  void push(MaterialPageRoute route) {
    _navigationKey.currentState?.push(route);
  }

  void pushNamed(String routeName) {
    _navigationKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    _navigationKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigationKey.currentState?.pop();
  }
}
