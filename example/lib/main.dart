import 'package:flutter/material.dart';
import 'package:stream_feed/stream_feed.dart';
import 'package:stream_feed_example/app_user.dart';
import 'package:stream_feed_example/client_provider.dart';
import 'package:stream_feed_example/extension.dart';
import 'package:stream_feed_example/home.dart';

//ignore_for_file: public_member_api_docs

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const _key = String.fromEnvironment('key');

  final client = StreamFeedClient(_key, appId: 'testing');

  runApp(
    MyApp(
      client: client,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.client,
    Key? key,
  }) : super(key: key);

  // ignore: diagnostic_describe_all_properties
  final StreamFeedClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stream Feed Demo',
      home: const LoginScreen(),
      builder: (context, child) => ClientProvider(
        client: client,
        child: child!,
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _client = context.client;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login with a User',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 42),
              for (final user in appUsers)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Loading User'),
                        ),
                      );
                      final streamUser = await _client.setUser(
                        User(
                          id: user.id,
                          data: user.data,
                        ),
                        Token(user.token),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User Loaded'),
                        ),
                      );
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(
                            currentUser: streamUser,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 36, horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
