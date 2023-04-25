import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
    return MaterialApp(title: 'Nrich Assignment', theme: ThemeData(),
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
Dio dio=new Dio();
  File? image;
  String res='No image picked';
  Future pickImage() async{
    try{
      final image=await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return ;
      final imageTemp=File(image.path);

      setState(()=>this.image=imageTemp);
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
      
    }

    Future pickImageC() async{
    try{
      final image=await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp=File(image.path);

      setState(()=>this.image=imageTemp);
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
        
    } 
      
     on PlatformException catch(e){
        print ('Failed to pick image: $e');
      }
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Picker App'), backgroundColor: Color.fromARGB(255, 185, 96, 201),),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [MaterialButton(
              onPressed: () {
                pickImage();
              },
              color:Color.fromARGB(255, 163, 78, 179),
              child:Text('Pick image from gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              ),
      
              MaterialButton(
              onPressed: (){pickImageC();},
              color:Color.fromARGB(255, 163, 78, 179),
              child:Text('Click image from camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              ),
      
             SizedBox(height: 20,),
             image!=null? Image.file(image!):Text('No image selected'),
              SizedBox(height: 20,),
      
              MaterialButton(
              onPressed: (){  var snackBar = SnackBar(
               content: Text("Image upload response : "+res, style: TextStyle(color: Colors.white),),
               
                  );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);},
              color:Colors.purple[300],
              child:Text('Upload image to server', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              ),
              
            
              ],
          )),
      ),
    );
  }
}
