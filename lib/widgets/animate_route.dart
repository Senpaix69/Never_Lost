import 'package:flutter/material.dart';

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  final dynamic arguments;

  SlideRightRoute({required this.page, this.arguments})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          settings: RouteSettings(arguments: arguments),
        );
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;

  FadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset.zero;
            const end = Offset(0.1, 0.0);
            const offsetCurve = Curves.fastOutSlowIn;
            const opacityCurve = Curves.easeIn;

            final offcetTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: offsetCurve),
            );
            final opacityOldTween = Tween(begin: 1.0, end: 0.0)
                .chain(CurveTween(curve: opacityCurve));

            final opacityNewTween = Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: opacityCurve));

            return SlideTransition(
              position: offcetTween.animate(secondaryAnimation),
              child: FadeTransition(
                opacity: opacityOldTween.animate(secondaryAnimation),
                child: FadeTransition(
                  opacity: opacityNewTween.animate(animation),
                  child: child,
                ),
              ),
            );
          },
        );
}
