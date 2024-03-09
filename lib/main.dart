import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main()async {
  // Load Environment File
  await dotenv.load(fileName: 'lib/.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprite Image Generation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController prompt = TextEditingController();
  String apiKey = dotenv.env["API_KEY"].toString();
  String url = 'https://api.openai.com/v1/images/generations';
  String image = '';

  void generateImage()async {
    if (prompt.text.isNotEmpty){
      var data = {
        "prompt": prompt.text.toString(),
        "n": 1,
        "size": "256x256",
      };

      var res = await http.post(Uri.parse(url), 
        headers: {
          "Authorization":"Bearer $apiKey", 
          "Content-Type": "application/json"},
        body: jsonEncode(data));
      
      if(res.statusCode == 200){
        final resData = jsonDecode(res.body);
        setState(() {
          image = resData['data'][0]['url'];
        });
      }
      else{
        print("Image Generation Error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child:
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 0, 10),
                child:
                  Column(
                    children:[
                      TextField(
                        controller: prompt,
                        maxLines: 7,
                        minLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Input Image Prompt Here",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ElevatedButton(
                          onPressed: generateImage, 
                          child: const Text("Generate Image")),
                      )
                    ]
                  )
              )
          ),
          Expanded(
            flex: 6,
            child: 
              Column(
                children: [
                  if(image.isNotEmpty)
                    Center(child: Image.network(image))
                  else
                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black))
                        ),
                    ),
                      const Center(
                        child: Text(
                          "Image will be generated here"
                        ),
                      )
                  ]
              )
            )
        ],
      )
    );
  }
}
