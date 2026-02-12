import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final databaseBoxProvider = Provider<Box>((ref) {
  return Hive.box("database");
});