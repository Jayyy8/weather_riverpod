import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'auth_repository.dart';
import 'database_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(databaseBoxProvider));
});

final loginHidePasswordProvider =
StateProvider.autoDispose<bool>((ref) => true);

final loginMessageProvider =
StateProvider.autoDispose<String>((ref) => '');

final signupHidePasswordProvider =
StateProvider.autoDispose<bool>((ref) => true);

final signupMessageProvider =
StateProvider.autoDispose<String>((ref) => '');