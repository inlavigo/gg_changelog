// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:gg_args/gg_args.dart';
import 'package:gg_changelog/src/tools/repo_url.dart';

import 'package:gg_log/gg_log.dart';
import 'package:mocktail/mocktail.dart';

// #############################################################################
/// An example command
class GithubDiffTemplate extends DirCommand<dynamic> {
  /// Constructor
  GithubDiffTemplate({
    required super.ggLog,
    super.name = 'github-diff-template',
    super.description = 'Reads repository URL from pubspec.yaml and '
        'returns the cider diff template',
    RepoUrl? repoUrl,
  }) : _repoUrl = repoUrl ?? const RepoUrl();

  // ...........................................................................
  @override
  Future<String> exec({
    required Directory directory,
    required GgLog ggLog,
  }) async {
    // Does the directory exist?
    await check(directory: directory);
    final result = await get(directory: directory);
    ggLog(result);
    return result;
  }

  // ...........................................................................
  /// Reads repo URL from pubspec.yaml and returns the cider diff template'
  Future<String> get({
    required Directory directory,
  }) async {
    final repoUrl = await _repoUrl.get(directory: directory);
    final repoUrlWithoutGit = repoUrl.replaceAll(RegExp(r'\.git$'), '');

    return '$repoUrlWithoutGit/compare/%from%...%to%';
  }

  // ######################
  // Private
  // ######################

  final RepoUrl _repoUrl;
}

/// Mock for [GitHubDiffTemplate]
class MockGitHubDiffTemplate extends Mock implements GithubDiffTemplate {}
