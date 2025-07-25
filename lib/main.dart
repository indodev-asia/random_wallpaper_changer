//random wallpaper changer, code by Antonius (indodev.asia)
import 'package:flutter/material.dart';
import 'dart:io'; 
import 'dart:async'; 
import 'dart:math'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WallpaperChangerApp());
}

class WallpaperChangerApp extends StatelessWidget {
  const WallpaperChangerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Wallpaper Changer',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.blueGrey, 
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white), 
          bodyMedium: TextStyle(color: Colors.white70),
          labelLarge: TextStyle(color: Colors.white), 
        ),
        
        cardTheme: CardThemeData( // Changed from CardTheme to CardThemeData
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
       
        appBarTheme: AppBarTheme( // Changed from AppBarTheme to AppBarThemeData implicitly, as AppBarTheme is the correct class
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      home: const WallpaperChangerHomePage(),
    );
  }
}

class WallpaperChangerHomePage extends StatefulWidget {
  const WallpaperChangerHomePage({super.key});

  @override
  State<WallpaperChangerHomePage> createState() => _WallpaperChangerHomePageState();
}

class _WallpaperChangerHomePageState extends State<WallpaperChangerHomePage> {
  
  final String wallpaperDirectory = '/home/robohax/Desktop/Wallpaper/Car';

  
  final List<String> imageExtensions = const [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp'
  ];

  String _statusMessage = 'Initializing wallpaper changer...';
  Timer? _timer; // Declare the timer variable

  @override
  void initState() {
    super.initState();
    // Start the wallpaper changing process immediately when the app starts
    _startWallpaperChanger();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to prevent memory leaks
    _timer?.cancel();
    super.dispose();
  }

  
  void _startWallpaperChanger() {
    _changeWallpaper(); // Change wallpaper immediately
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      _changeWallpaper(); // Change wallpaper every minute
    });
  }

  
  Future<void> _changeWallpaper() async {
    setState(() {
      _statusMessage = 'Attempting to change wallpaper at ${DateTime.now().toLocal().toString().split('.')[0]}...';
    });

    final Directory dir = Directory(wallpaperDirectory);

   
    if (!await dir.exists()) {
      setState(() {
        _statusMessage = 'Error: Wallpaper directory "$wallpaperDirectory" does not exist. Please create it.';
      });
      print('Error: Wallpaper directory "$wallpaperDirectory" does not exist.');
      return;
    }

    try {
      
      final List<FileSystemEntity> entities = await dir.list().toList();
      final List<File> imageFiles = [];

     
      for (final entity in entities) {
        if (entity is File) {
          final String lowerCasePath = entity.path.toLowerCase();
          if (imageExtensions.any((ext) => lowerCasePath.endsWith(ext))) {
            imageFiles.add(entity);
          }
        }
      }

     
      if (imageFiles.isEmpty) {
        setState(() {
          _statusMessage = 'No image files found in "$wallpaperDirectory".';
        });
        print('No image files (${imageExtensions.join(', ')}) found in "$wallpaperDirectory".');
        return;
      }

      
      final Random random = Random();
      final File randomImage = imageFiles[random.nextInt(imageFiles.length)];
      final String imagePath = randomImage.path;

      print('Selected wallpaper: $imagePath');

     
      final String uri = 'file://$imagePath';

      final ProcessResult resultLight = await Process.run(
        'gsettings',
        ['set', 'org.gnome.desktop.background', 'picture-uri', uri],
      );

     
      final ProcessResult resultDark = await Process.run(
        'gsettings',
        ['set', 'org.gnome.desktop.background', 'picture-uri-dark', uri],
      );

     
      if (resultLight.exitCode == 0 && resultDark.exitCode == 0) {
        setState(() {
          _statusMessage = 'Wallpaper changed to: ${imagePath.split('/').last}';
        });
        print('Wallpaper changed successfully.');
      } else {
        setState(() {
          _statusMessage = 'Error changing wallpaper. Light: ${resultLight.stderr}, Dark: ${resultDark.stderr}';
        });
        print('Error changing wallpaper (light theme): ${resultLight.stderr}');
        print('Error changing wallpaper (dark theme): ${resultDark.stderr}');
      }
    } catch (e) {
    
      setState(() {
        _statusMessage = 'An unexpected error occurred: $e';
      });
      print('An unexpected error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background for the app
      appBar: AppBar(
        title: const Text(
          'Random Wallpaper Changer',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[800], // Darker app bar
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main status message display
              Card(
                color: Colors.blueGrey[700], // Card background color
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.image_outlined, // A relevant icon
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Next change in: ${_timer != null ? (_timer!.tick % 60 == 0 ? 60 : 60 - (_timer!.tick % 60)) : 60} seconds',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(), // Pushes the text to the bottom
              // The required string at the bottom
              const Text(
                'random wallpaper changer - developed by Antonius (indodev.asia)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
