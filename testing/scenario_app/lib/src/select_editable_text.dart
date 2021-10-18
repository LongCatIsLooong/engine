// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'channel_util.dart';
import 'scenario.dart';

/// A scenario that sends back messages when touches are received.
class SelectEditableText extends Scenario {
  /// Creates a `SelectEditableText` [Scenario].
  SelectEditableText(PlatformDispatcher dispatcher) : super(dispatcher);

  @override
  void onBeginFrame(Duration duration) {
    // Paint the canvas white for visibility.
    final SceneBuilder builder = SceneBuilder();
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, window.physicalSize.width, window.physicalSize.height),
      Paint()..color = const Color.fromARGB(255, 255, 255, 255),
    );
    final Picture picture = recorder.endRecording();

    builder.addPicture(
      Offset.zero,
      picture,
    );
    final Scene scene = builder.build();
    window.render(scene);
    scene.dispose();
  }

  // We don't really care about the touch itself. It's just a way for the
  // XCUITest to communicate timing to the mock framework.
  @override
  void onPointerDataPacket(PointerDataPacket packet) {
    // This mimics the framework which shows the FlutterTextInputView before
    // updating the TextInputSemanticsObject.
    sendJsonMethodCall(
      dispatcher: dispatcher,
      channel: 'flutter/textinput',
      method: 'TextInput.setClient',
      arguments: <dynamic>[
        1,
        // The arguments are text field configurations. It doesn't really matter
        // since we're just testing text field accessibility here.
        <String, dynamic>{ 'obscureText': false },
      ]
    );

    sendJsonMethodCall(
      dispatcher: dispatcher,
      channel: 'flutter/textinput',
      method: 'TextInput.show',
    );

    sendJsonMethodCall(
      dispatcher: dispatcher,
      channel: 'flutter/textinput',
      method: 'TextInput.setEditingState',
      arguments: <String, dynamic>{
        'text': 'Long text is looooooooooooooooooong.',
        // "Long" is selected.
        'selectionBase': 0,
        'selectionExtent': 4,
        'selectionAffinity': 'TextAffinity.downstream',
        'selectionIsDirectional': false,
        'composingBase': -1,
        'composingExtent': -1,
      }
    );
  }
}
