import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:untitled/permissionHand.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MyPermissionPhoto().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that// how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //variable
  TextEditingController langueIdentifier = TextEditingController();
  LanguageIdentifier identifier = LanguageIdentifier(confidenceThreshold: 0.1);
  String langueUnique = "";
  OnDeviceTranslator translator = OnDeviceTranslator(sourceLanguage: TranslateLanguage.french, targetLanguage: TranslateLanguage.bengali);
  Uint8List? bytesImages;
  String? pathImage;
  String labels= "";
  ImageLabeler imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.2));

  //méthode
  identifierLangue() async {
    if(langueIdentifier != null && langueIdentifier != ""){
      String phrase = await identifier.identifyLanguage(langueIdentifier.text);
      setState(() {
        langueUnique = phrase;
      });

    }

  }

  identifierMultipleLangue() async {
    langueUnique = "";
    if(langueIdentifier != null && langueIdentifier.text != ""){
      List langs = await identifier.identifyPossibleLanguages(langueIdentifier.text);
       for(IdentifiedLanguage lang in langs){
         print(lang.languageTag);
         setState(() {
           langueUnique += "la langue est ${lang.languageTag} avec une confiance de ${(lang.confidence *100).toInt()} %\n";
         });

       }
    }

  }

  translate() async{
    if(langueIdentifier != null && langueIdentifier.text != ""){

      String phrase = await translator.translateText(langueIdentifier.text);
      setState(() {
        langueUnique = phrase;
      });
    }
  }

  ImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.image,
    );
    if(result != null){
      setState(() {
        pathImage =result.files.first.path;
        bytesImages = result.files.first.bytes;
        processing(pathImage!);
      });


    }
  }
  processing(String image) async {
    labels = "";
    InputImage img = InputImage.fromFilePath(image);
    List<ImageLabel> allElementImage = await imageLabeler.processImage(img);
    for (ImageLabel label in allElementImage){

        labels += "${label.label} avec une confiance de ${(label.confidence *100).toInt()} %\n";


    }
    setState(() {

    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
          child: Column(
            children:[
              TextField(
                controller: langueIdentifier,
              ),
              ElevatedButton(
              onPressed: identifierLangue,
                  child: Text("Determiner la langue")),

              ElevatedButton(
                  onPressed: identifierMultipleLangue,
                  child: Text("plusieurs langues")),

              ElevatedButton(
                  onPressed: translate,
                  child: Text("Traduction")),

              Text(langueUnique),

              ElevatedButton(
                  onPressed: ImagePick,
                  child: Text("Image")),

              (bytesImages == null)?Container():Image.memory(bytesImages!),

              Text(labels)

            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
