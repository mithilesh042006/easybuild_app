import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/component.dart';

class BuildState {
  final Map<ComponentType, Component?> selectedComponents;

  const BuildState({this.selectedComponents = const {}});

  double get totalPrice {
    return selectedComponents.values
        .where((c) => c != null)
        .map((c) => c!.price)
        .fold(0.0, (sum, price) => sum + price);
  }

  BuildState copyWith({Map<ComponentType, Component?>? selectedComponents}) {
    return BuildState(
      selectedComponents: selectedComponents ?? this.selectedComponents,
    );
  }
}

class BuildNotifier extends Notifier<BuildState> {
  @override
  BuildState build() {
    return const BuildState();
  }

  void selectComponent(Component component) {
    state = state.copyWith(
      selectedComponents: {
        ...state.selectedComponents,
        component.type: component,
      },
    );
  }

  void removeComponent(ComponentType type) {
    final newComponents = Map<ComponentType, Component?>.from(
      state.selectedComponents,
    );
    newComponents.remove(type);

    state = state.copyWith(selectedComponents: newComponents);
  }

  void clearBuild() {
    state = const BuildState();
  }
}

final buildProvider = NotifierProvider<BuildNotifier, BuildState>(
  BuildNotifier.new,
);
