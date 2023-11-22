import 'dart:io';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dart_openai/dart_openai.dart';

class ToText extends StatefulWidget {
  const ToText({super.key});

  @override
  State<ToText> createState() {
    return _ToText();
  }
}

class _ToText extends State<ToText> {
  final Logger _logger = Logger();

  bool _scanning = false;
  String _extractText = '';
  XFile? _pickedImage;
  String? response;
  final List<Map<String, String>> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 58, 84),
        title: const Text('GET ANSWERS FROM IMAGES'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          if (_scanning == true)
            const Center(child: CircularProgressIndicator()),
          // : const Icon(
          //     Icons.done,
          //     size: 40,
          //     color: Colors.green,
          //   ),
          // SHOW TEXT SHOW TEXT SHOW TEXT
          const SizedBox(height: 20),
          if (_extractText.isNotEmpty)
          SizedBox(
            child: SingleChildScrollView(
              child: Card( 
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 22),
                color: const Color.fromARGB(153, 255, 255, 255),
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    _extractText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // SHOW IMAGE HERE
          // _pickedImage == null
          //     ? Container(
          //         height: 300,
          //         color: Colors.grey[300],
          //         child: const Icon(
          //           Icons.image,
          //           size: 100,
          //         ),
          //       )
          //     : Container(
          //         height: 300,
          //         decoration: BoxDecoration(
          //           color: Colors.grey[300],
          //           image: DecorationImage(
          //             image: FileImage(File(_pickedImage!.path)), // Convert XFile to File
          //             fit: BoxFit.fill,
          //           ),
          //         ),
          //       ),
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ElevatedButton(
              child: const Text(
                'Pick image',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF165BAA),
                elevation: 0,
              ),
              onPressed: () async {
                _logger.d("Starting image picking...");
                setState(() {
                  _scanning = true;
                });
                getImage();
              }
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: response != null
              ? Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 22),
                color: const Color.fromARGB(153, 255, 255, 255),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Generated response: $response",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              )
              : Container(),
              // : const Card(
              //   margin: EdgeInsets.only(left: 22, right: 22, bottom: 450),
              //   color: Color.fromARGB(255, 204, 204, 204),
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(
              //     horizontal: 20,
              //     vertical: 16,
              //   ),
              //   child: Text(
              //       "Response is null",
              //     ),
              //   ),
              // ),
          )
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
      response = await chatGPTAPI(_extractText);
      _scanning = false;
    } catch(e) {
      _extractText = 'Error occurred while recognizing text';
    } finally{
      _scanning = false;
      setState(() {});
    }
  }
  Future<String> chatGPTAPI(String prompt) async {
    OpenAI.apiKey = "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";
    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: "For the following text, I dont want the response to be over 300 characters. Be consise and straight to the point:, ${prompt}",
          role: OpenAIChatMessageRole.user,
          ),
      ],
    );
    return chatCompletion.choices[0].message.content;
  }
}