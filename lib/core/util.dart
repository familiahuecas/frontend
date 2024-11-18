import 'package:flutter/material.dart';


void navigate(context, screen, {bool isRemovingStack = false}) {
  if (isRemovingStack) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => screen), (route) => route.isFirst);
  }
  else {
    Navigator.push(context, MaterialPageRoute(builder: (c) => screen));
  }
}

ThemeData getTheme(context) => Theme.of(context);
goBack(BuildContext context) => Navigator.of(context).pop();
var closeDialog = goBack;

clearNavigation(BuildContext context) => Navigator.of(context).popUntil((r) => r.isFirst);

void replaceHome(context, screen) {
  clearNavigation(context);
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => screen));
}

extension StringExt on String {
  static final RegExp _r1 = RegExp(r'^([^,.]*[.,])|\D+');
  static final RegExp _r2 = RegExp(r'[^0-9,.]+');
  String get capitalized => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  String get pascalCased => split(' ').map((e) => e.capitalized).join();
  String get withoutNumbers => replaceAllMapped(_r1, (Match m) => m[1] != null ? m[1]!.replaceAll(_r2, '') : '');
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test, { E? Function()? orElse }) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return orElse?.call();
  }
}


extension ListExt<T> on List<T> {
  List<List<T>> partition(int chunk) => length <= chunk ? [ this ] : [ sublist(0, chunk), ...sublist(chunk).partition(chunk) ];
}