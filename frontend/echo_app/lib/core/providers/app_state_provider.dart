import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to track if user is authenticated and has completed assessment
final appInitializedProvider = StateProvider<bool>((ref) => false);
