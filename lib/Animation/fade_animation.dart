import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  const FadeAnimation(this.delay, this.child, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tween = _createTween();

    return _PlayAnimation(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) =>
          Opacity(
            opacity: animation["opacity"], // Accessing animation directly
            child: Transform.translate(
              offset: Offset(0, animation["translateY"]),
              child: child,
            ),
          ),
    );
  }

  MultiTrackTween _createTween() {
    return MultiTrackTween([
      Track("opacity").add(
          Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track("translateY").add(
          Duration(milliseconds: 500), Tween(begin: -30.0, end: 0.0),
          curve: Curves.easeOut)
    ]);
  }
}

class Track {
  final String name;

  Track(this.name);

  TrackEntry add(Duration duration, Tween<double> tween, {Curve curve = Curves.linear}) {
    return TrackEntry(duration, tween, curve,name);
  }
}

class TrackEntry {
  final Duration duration;
  final Tween<double> tween;
  final Curve curve;
  final String name;

  TrackEntry(this.duration, this.tween, this.curve, this.name);

  String get getName => name;
}

class MultiTrackTween {
  final List<TrackEntry> tracks;

  MultiTrackTween(this.tracks);

  Duration get duration => tracks.isNotEmpty ? tracks.first.duration : Duration.zero;

  /// Implementing transform method to interpolate values based on animation value
  Map<String, dynamic> transform(double animationValue) {
    final result = <String, dynamic>{};
    for (final track in tracks) {
      result[track.name] = track.tween.transform(animationValue);
    }
    return result;
  }
}

class _PlayAnimation extends StatelessWidget {
  final Duration delay;
  final Duration duration;
  final MultiTrackTween tween;
  final Widget child;
  final Widget Function(BuildContext, Widget?, dynamic) builderWithChild;

  const _PlayAnimation({
    required this.delay,
    required this.duration,
    required this.tween,
    required this.child,
    required this.builderWithChild,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0), // You need to provide a tween here
      duration: duration,
      builder: (context, value, child) {
        final animation = tween.transform(value); // Transform the value using your tween
        return builderWithChild(context, child, animation);
      },
      child: child,
    );
  }
}
