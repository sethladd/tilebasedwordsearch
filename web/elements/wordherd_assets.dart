library wordherd.elements.assets;

import 'package:polymer/polymer.dart';  // XXX DO NOT USE SHOW HERE
import 'package:asset_pack/asset_pack.dart';
import 'package:logging/logging.dart';
import 'package:wordherd/shared_html.dart';
import 'dart:html';

final Logger log = new Logger('WordherdAssets');

@CustomTag('wordherd-assets')
class WordherdAssets extends PolymerElement {
  final AssetManager assetManager = new AssetManager();
  @observable Boards boards;
  @observable String status;
  @observable bool loaded = false;

  // TODO move this into enteredView?
  WordherdAssets.created() : super.created() {
    status = 'Loading...';
    assetManager.loadPack('game', 'assets/_.pack')
      .then((_) => _parseAssets());
  }

  void _parseAssets() {
    status = 'Loaded';
    loaded = true;
    dispatchEvent(new CustomEvent('assetsloaded'));

    if (assetManager['game.boards'] == null) {
      // TODO should custom elements complain this loud when they are
      // misconfigured?
      throw new StateError("Can't play without the boards");
    }

    boards = new Boards(assetManager['game.boards']);
  }
}