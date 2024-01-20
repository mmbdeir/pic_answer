import 'dart:convert';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ToText extends StatefulWidget {
  const ToText({super.key});

  @override
  State<ToText> createState() {
    return _ToText();
  }
}

class _ToText extends State<ToText> {
  late TextEditingController _textEditingController;

  bool _scanning = false;
  String? _extractText;
  // USED WHEN DISPLAYING IMAGE
  XFile? _pickedImage;
  String? response;
  final List<Map<String, String>> messages = [];
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: _extractText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 58, 84),
        title: const Text(
          'GET ANSWERS FROM IMAGES', 
          style: TextStyle(
            color: Colors.white,
          )
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          if (_scanning == true)
            const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 20),
          if (_extractText != null)
          SizedBox(
            height: 200,
            child: Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 22),
              color: const Color.fromARGB(153, 255, 255, 255),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _textEditingController..text = _extractText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: null,
                    onChanged: (newValue) async {
                      _extractText = newValue;
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 10),
                          padding: const EdgeInsets.all(16),
                          content: const Text('Submit new!'),
                          action: SnackBarAction(
                            label: 'Submit that',
                            onPressed: () async {
                              response = await callChatGPT(_extractText!);
                              setState(() {
                              });
                              _scanning = false;
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF165BAA),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                )
              ),
              onPressed: () async {
                setState(() {
                  _scanning = true;
                });
                getImage();
              },
              child: const Text(
                'Pick image',
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            ),
          ),
          const SizedBox(height: 10),
        if (response != null)
          Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 22),
            color: const Color.fromARGB(153, 255, 255, 255),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 250,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "$response",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void getImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        _scanning = true;
        _pickedImage = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
        _scanning = false;
      }
    } catch (e) {
      _scanning = false;
      _pickedImage = null;
	    _extractText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    try{
      final inputImage = InputImage.fromFilePath(image.path);
      final textDetector = GoogleMlKit.vision.textRecognizer();
      RecognizedText recognisedText =
            await textDetector.processImage(inputImage);
      await textDetector.close();
      _extractText = "";
      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          _extractText = "$_extractText${line.text}\n";
        }
      }
      print(_extractText);
      response = await callChatGPT(_extractText!);
      _scanning = false;
    } catch(e) {
      _extractText = e.toString();
    } finally{
      _scanning = false;
      setState(() {});
    }
  }

  Future<String?> callChatGPT(String prompt) async {
  const apiKey = "Your api key";
  const apiUrl = "https://api.openai.com/v1/chat/completions";

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    };

    final messages = [
      {"role": "user", "content": "Don't make the response to the following question more than 300 characters long: $prompt"},
    ];

    final body = jsonEncode(
      {
        "model": "gpt-3.5-turbo",
        'messages': messages,
        'max_tokens': 200, // Adjust as needed
      },
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final result = jsonResponse['choices'][0]['message']['content'];
        print(result);
        return result;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
