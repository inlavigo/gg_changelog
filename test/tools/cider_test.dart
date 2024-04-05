// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:cider/cider.dart';
import 'package:gg_changelog/gg_changelog.dart';
import 'package:test/test.dart';

import '../pubspec_yaml.dart';

void main() {
  final messages = <String>[];
  final ggLog = messages.add;
  late Directory d;
  late CiderProject ciderProject;

  setUp(() async {
    messages.clear();
    d = await Directory.systemTemp.createTemp();
    final pubspecFile = File('${d.path}/pubspec.yaml');
    await pubspecFile.writeAsString(pubspecExample);
    ciderProject = CiderProject(ggLog: ggLog);
  });

  tearDown(() async {
    await d.delete(recursive: true);
  });

  group('Cider', () {
    group('get(directory, ggLog)', () {
      group('should succeed', () {
        test('and return a cider project', () async {
          expect(
            await ciderProject.get(directory: d, ggLog: ggLog),
            isA<Project>(),
          );
        });
      });
    });
  });
}
