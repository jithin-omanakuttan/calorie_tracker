// import 'package:calorie_chat_app/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import '../objectbox.g.dart';

/// The generated code will create a function named `getObjectBoxModel()`.
/// We will call this function to obtain the model.
Future<Store> createStore() async {
  final docsDir = await getApplicationDocumentsDirectory();
  final store = await openStore(
    directory: '${docsDir.path}/objectbox',
  );
  return store;
}
