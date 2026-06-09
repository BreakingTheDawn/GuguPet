import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/features/auth/data/models/auth_state.dart';
import 'package:jobpet/features/auth/providers/auth_provider.dart';

void main() {
  test(
    'initializeAsGuest sets an unauthenticated state without repository IO',
    () {
      final provider = AuthProvider();

      provider.initializeAsGuest();

      expect(provider.state, AuthState.unauthenticated);
      expect(provider.currentUser, isNull);
      expect(provider.errorMessage, isNull);
    },
  );
}
