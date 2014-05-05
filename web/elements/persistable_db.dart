import 'package:polymer/polymer.dart';  // XXX DO NOT USE SHOW HERE
import 'package:wordherd/persistable_html.dart' as db;
import 'package:logging/logging.dart' show Logger;
import 'dart:html' show CustomEvent;

final Logger log = new Logger('PersistableDb');

@CustomTag('persistable-db')
class PersistableDb extends PolymerElement {
  @observable bool initialized = false;
  @published String dbname;
  @published String storename;

  PersistableDb.created() : super.created();

  @override
  void enteredView() {
    super.enteredView();

    _init();
  }

  @override
  void attributeChanged(String name, String oldValue, String newValue) {
    super.attributeChanged(name, oldValue, newValue);
    if (initialized) {
      log.info('Storage already initialized. No support for changing info at runtime.');
      return;
    }
    _init();
  }

  void _init() {
    if (dbname == null || storename == null) {
      log.warning('dbname or storename is null. Store is not initialized.');
      return;
    }

    db.init(dbname, storename)
    .then((_) {
      log.fine('Persistable store initialized');
      initialized = true;
      this.dispatchEvent(new CustomEvent('persistablestoreinitialized'));
    })
    .catchError((e, stackTrace) {
      log.severe('Could not initialize storage: $e', e, stackTrace);
    });
  }
}