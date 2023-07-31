import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Bardanswer', theme: ThemeData(),
    home:const MyHomePage(title: ' Home Page'),
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
  bool textScanning=false;
  String scannedText="";
  
  TextEditingController _apikey=TextEditingController();
Dio dio=new Dio();
  File? image;
  String res='No image picked';

  Future pickImage() async{
    try{
      final image=await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return ;
      textScanning=true;
      File? imageTemp=File(image.path);
      
      setState( 
        ()=>this.image=imageTemp);

        _scanImage(imageTemp);


       String filename=image.path.split('/').last;
       FormData formData=new FormData.fromMap({
        "file":
        await MultipartFile.fromFile(image.path, filename: filename, contentType: new MediaType('image','png')),
        "type": "image/png"
       });
       Response response =
       await dio.post('https://codelime.in/api/remind-app-token?=', 
       data: formData, 
       options: Options(
        headers: {
          "accept":"*/*",
          "Authorization":"Bearer accesstoken",
          "Content-Type": "multipart/form-data"
        }
        ));
        
        res="$response";
        
      
    } on PlatformException catch(e){
        print ('Failed to pick image: $e');
      }
      catch(e){
       textScanning=false;
       image=null;
       setState(() {});
       scannedText="Error occured while scanning";
      }
      
    }

    

    

    Future<void> _scanImage(File? image) async{
      final inputImage=InputImage.fromFilePath(image!.path);
      final textRecognizer=TextRecognizer();
    RecognizedText recognizedText=await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    scannedText="";
    for (TextBlock block in recognizedText.blocks){
      for (TextLine line in block.lines){
        scannedText=scannedText+line.text+"\n";
      }
    }
    textScanning=false;
    setState(() {});
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BardAnswer'), backgroundColor: Color.fromARGB(255, 185, 96, 201),),
      body: SingleChildScrollView(
        
        child: Center(
          child: Column(
            children: [
      
              
      
             SizedBox(height: 20,),
             if (textScanning)
             CircularProgressIndicator(),
             if (image==null && !textScanning)Column(
               children: [
                Image.asset("assets/image.png", height: 95, width:105),
                 Text('No image selected'),
               ],
             ),
             if (image!=null) Image.file(image!),
              SizedBox(height: 20,),
      
             MaterialButton(
              
              onPressed: () {
                pickImage();
              },
              
              color:Color.fromARGB(255, 163, 78, 179),
              child:Text('Click image from camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller:_apikey,
                  cursorColor: Colors.purple,
                  decoration: InputDecoration(
                    enabled: true,
                    
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(width: 1, color:Color.fromARGB(255, 163, 78, 179),),),
              enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(width: 1, color:Color.fromARGB(255, 163, 78, 179),),),
              hintText: 'Enter Your Google Bard API key',
              
              ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(child: scannedText==""?Text("No text scanned" ,style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold)):Column(
                  crossAxisAlignment:CrossAxisAlignment.center ,children: [
                    Text("Text scanned from the image : ",style:TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                    SizedBox(height:20),Text(scannedText,style:TextStyle(fontStyle: FontStyle.italic,fontSize: 15)),
                  ],
                ),),
              )
              
            
              ],
          )),
      ),
    );
  }
}
