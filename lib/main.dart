import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theproject/pages/profilepage.dart';
import 'package:theproject/pages/splash_page.dart';
import 'package:theproject/providers/imagedownloadprovider.dart';
import 'package:theproject/providers/imageuploadprovider.dart';
import 'package:theproject/stores/login_store.dart';
import 'package:theproject/stores/profileStore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
runApp(App());
} 

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LoginStore>(
          create: (_) => LoginStore(),
        ),
        Provider<ProfileStore>(
          create: (_) => ProfileStore(),
        ),
        ChangeNotifierProvider<ImageUploadProvider>(
          create: (_) =>ImageUploadProvider(),
        ),
         ChangeNotifierProvider<ImageDownloadProvider>(
          create: (_) =>ImageDownloadProvider(),
        )
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashPage(),
      ),
    );
  }
}