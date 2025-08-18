import 'dart:ui';

import 'package:hero_container/components/hero_container_controller.dart';

/// A captured snapshot of a widget containing its image, size, and position.
///
/// Used by [HeroContainerController] to store widget snapshots for
/// smooth transition animations between different widget states.
class HeroContainerFragment {
  /// Creates a fragment with the captured widget data.
  const HeroContainerFragment({
    required this.size,
    required this.offset,
    required this.capturedImage,
  });

  /// The size of the captured widget.
  final Size size;

  /// The global position of the captured widget.
  final Offset offset;

  /// The captured image of the widget.
  final Image capturedImage;
}
