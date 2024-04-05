// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:gg_args/gg_args.dart';
import 'package:gg_changelog/gg_changelog.dart';
import 'package:gg_changelog/src/tools/cider.dart';
import 'package:gg_console_colors/gg_console_colors.dart';
import 'package:gg_log/gg_log.dart';

// #############################################################################

/// The type of the commit message.
enum LogType {
  /// Added a new feature.
  added,

  /// Changed something.
  changed,

  /// Deprecated something.
  deprecated,

  /// Fixed a bug.
  fixed,

  /// Removed something.
  removed,

  /// Fixed a security issue.
  security,
}

final _logTypes = LogType.values.map((e) => e.name);

// #############################################################################
/// An example command
class Add extends DirCommand<dynamic> {
  /// Constructor
  Add({
    required super.ggLog,
    super.name = 'add',
    super.description = 'Adds a message to the change log.',
    CiderProject? ciderProject,
  }) : _ciderProject = ciderProject ?? CiderProject(ggLog: ggLog) {
    _addParam();
  }

  // ...........................................................................
  /// Returns true if a message was added to the change log.
  @override
  Future<bool> exec({
    required Directory directory,
    required GgLog ggLog,
    String? message,
    LogType? logType,
  }) async {
    // Does the directory exist?
    await check(directory: directory);

    // Check needed options
    message ??= _messageFromArgs();
    logType ??= _logTypeFromArgs();

    // Create CHANGELOG.md if it does not exist
    final changelogFile = File('${directory.path}/CHANGELOG.md');
    if (!await changelogFile.exists()) {
      await changelogFile.create();
      await changelogFile.writeAsString('# Changelog\n\n');
    }

    // Read CHANGELOG.md
    final changelog = await changelogFile.readAsString();

    if (_unreleasedSectionContainsMessage(changelog, message)) {
      ggLog.call(
        darkGray('The message »message« is already in CHANGELOG.md'),
      );
      return false;
    }

    final cider = await _ciderProject.get(directory: directory, ggLog: ggLog);
    await cider.addUnreleased(logType.name, message);

    return true;
  }

  // ######################
  // Private
  // ######################

  final CiderProject _ciderProject;

  // ...........................................................................
  void _addParam() {
    argParser.addOption(
      'message',
      abbr: 'm',
      help: 'The message for the commit.',
      mandatory: true,
    );

    argParser.addOption(
      'log-type',
      abbr: 'l',
      help: 'The type of the commit.',
      mandatory: true,
      allowed: _logTypes,
    );
  }

  // ...........................................................................
  String _messageFromArgs() {
    try {
      final message = argResults!['message'] as String;
      return message;
    } catch (e) {
      throw Exception(
        yellow('Run again with ') + blue('-m "yourMessage"'),
      );
    }
  }

  // ...........................................................................
  LogType _logTypeFromArgs() {
    try {
      final logTypeString = argResults!['log-type'] as String;
      return LogType.values.firstWhere(
        (element) => element.name == logTypeString,
      );
    } catch (e) {
      throw Exception(
        yellow('Run again with ') + blue('-l ${_logTypes.join(' | ')}'),
      );
    }
  }

  // ...........................................................................
  bool _unreleasedSectionContainsMessage(String changeLog, String message) {
    final parts = changeLog.split('## ');
    if (parts.length <= 1) {
      return false;
    }

    final indexOfUnreleased =
        parts.indexWhere((element) => element.contains('Unreleased'));

    if (indexOfUnreleased < 0) {
      return false;
    }

    if (parts.length > indexOfUnreleased) {
      return parts[indexOfUnreleased + 1].contains(message);
    }

    return false;
  }
}
