import 'package:windows_input_filter/windows_input_filter.dart';

Future<void> main() async {
  final client = await Interceptor.open();
  try {
    print(client.info());
  } finally {
    client.close();
  }
}
