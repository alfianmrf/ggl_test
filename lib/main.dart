import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ggl_test/Database.dart';
import 'package:ggl_test/Barang.dart';
import 'package:ggl_test/Stok.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Barang> dataBarang = [];
  List<Stok> dataStok = [];

  TextEditingController kodeBarangController = new TextEditingController();
  TextEditingController namaBarangController = new TextEditingController();

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchBarang();
  }

  Future<List<Stok>> fetchStok(int idBarang) async {
    dataStok = [];
    DatabaseHelper.instance.getStok(idBarang).then((value) {
      if(value.length>0){
        value.forEach((element) {
          setState(() {
            dataStok.add(element);
          });
        });
      }
    });
    return dataStok;
  }

  void fetchBarang(){
    dataBarang = [];
    DatabaseHelper.instance.getBarang().then((value) {
      if(value.length>0){
        value.forEach((element) {
          setState(() {
            dataBarang.add(element);
          });
        });
      }
    });
  }

  Future<void> _showBarangUpdateDialog(Barang barang) async {
    bool _isImageEdited = false;
    kodeBarangController.text = barang.kode_barang!;
    namaBarangController.text = barang.nama_barang!;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              margin: EdgeInsets.all(5),
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: TextFormField(
                      controller: kodeBarangController,
                      decoration: InputDecoration(
                        hintText: "Kode Barang",
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: namaBarangController,
                    decoration: InputDecoration(
                      hintText: "Nama Barang",
                    ),
                  ),
                  SizedBox(height: 10),
                  _isImageEdited == true && _imageFile == null ? InkWell(
                    onTap: () async {
                      var pickedFile = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1000,
                        maxHeight: 1000,
                      );
                      setModalState(() {
                        _imageFile = pickedFile;
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ) : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          child: _isImageEdited == true ? Image.file(
                            File(_imageFile!.path),
                            fit: BoxFit.cover,
                          ) : Image.memory(
                            base64Decode(barang.gambar_barang!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: GestureDetector(
                            onTap: (){
                              setModalState(() {
                                _imageFile = null;
                                _isImageEdited = true;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: MaterialButton(
                      onPressed: (){
                        Map<String, dynamic> data = {
                          "kode_barang": kodeBarangController.value.text,
                          "nama_barang": namaBarangController.value.text,
                        };
                        if(_isImageEdited == true){
                          data["gambar_barang"] = base64Encode(File(_imageFile!.path).readAsBytesSync());
                        }
                        else{
                          data["gambar_barang"] = barang.gambar_barang;
                        }
                        DatabaseHelper.instance.update("data_barang", barang.id!, data).then((value){
                          kodeBarangController.clear();
                          namaBarangController.clear();
                          _imageFile = null;
                          fetchBarang();
                          Navigator.pop(context);
                        });
                      },
                      color: Colors.green,
                      textColor: Colors.white,
                      child: Text('Simpan'),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _showBarangDialog(Barang barang) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              margin: EdgeInsets.all(5),
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Text(
                            'Barang',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Image.memory(base64Decode(barang.gambar_barang!)),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Text(barang.kode_barang!),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Text(barang.nama_barang!),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MaterialButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                  _showBarangUpdateDialog(barang);
                                },
                                color: Colors.blue,
                                textColor: Colors.white,
                                child: Text('Ubah'),
                              ),
                              MaterialButton(
                                onPressed: (){
                                  DatabaseHelper.instance.deleteStok(barang.id!).then((value){
                                    DatabaseHelper.instance.delete('data_barang', barang.id!).then((value){
                                      fetchBarang();
                                      Navigator.pop(context);
                                    });
                                  });
                                },
                                color: Colors.red,
                                textColor: Colors.white,
                                child: Text('Hapus'),
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder(
                          future: fetchStok(barang.id!),
                          builder: (context, snapshot){
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  if((snapshot.data! as List<Stok>).length > 0)
                                    Container(
                                      margin: EdgeInsets.all(5),
                                      child: Text(
                                        'Stok',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  Column(
                                    children: (snapshot.data! as List<Stok>).map((e){
                                      return Container(
                                        margin: EdgeInsets.all(5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(e.total_barang.toString()),
                                            e.jenis_stok == 'in'
                                              ? Text('Stok Masuk')
                                              : Text('Stok Keluar')
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              );
                            } else {
                              return Center (
                                child: CircularProgressIndicator(),
                              );
                            }
                          }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _showFormDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content:  StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              margin: EdgeInsets.all(5),
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: TextFormField(
                      controller: kodeBarangController,
                      decoration: InputDecoration(
                        hintText: "Kode Barang",
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: namaBarangController,
                    decoration: InputDecoration(
                      hintText: "Nama Barang",
                    ),
                  ),
                  SizedBox(height: 10),
                  _imageFile == null ? InkWell(
                    onTap: () async {
                      var pickedFile = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1000,
                        maxHeight: 1000,
                      );
                      setModalState(() {
                        _imageFile = pickedFile;
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ) : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          child: Image.file(
                            File(_imageFile!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: GestureDetector(
                            onTap: (){
                              setModalState(() {
                                _imageFile = null;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: MaterialButton(
                      onPressed: (){
                        DatabaseHelper.instance.insert("data_barang",{
                          "kode_barang": kodeBarangController.value.text,
                          "nama_barang": namaBarangController.value.text,
                          "gambar_barang": base64Encode(File(_imageFile!.path).readAsBytesSync()),
                        }).then((value){
                          kodeBarangController.clear();
                          namaBarangController.clear();
                          _imageFile = null;
                          fetchBarang();
                          Navigator.pop(context);
                        });
                      },
                      color: Colors.green,
                      textColor: Colors.white,
                      child: Text('Simpan'),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _addStokModal(String type){
    return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
          return Wrap(
            children: [
              for(Barang e in dataBarang)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(e.kode_barang!+" - "+e.nama_barang!),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: (){
                              if(e.qty>0){
                                setModalState(() {
                                  e.qty--;
                                });
                              }
                            },
                            padding: EdgeInsets.zero,
                            splashRadius: 20,
                            icon: Icon(Icons.remove),
                          ),
                          Text(e.qty.toString()),
                          IconButton(
                            onPressed: (){
                              setModalState(() {
                                e.qty++;
                              });
                            },
                            padding: EdgeInsets.zero,
                            splashRadius: 20,
                            icon: Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                child: MaterialButton(
                  onPressed: (){
                    dataBarang.forEach((element) {
                      if(element.qty != 0){
                        DatabaseHelper.instance.insert('data_stok', {
                          "id_barang": element.id,
                          "total_barang": element.qty,
                          "jenis_stok": type,
                        });
                      }
                    });
                    Navigator.pop(context);
                  },
                  color: type == 'in' ? Colors.green : Colors.red,
                  textColor: Colors.white,
                  child: Text(type == 'in' ? 'Beli' : 'Jual'),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            for(Barang e in dataBarang)
              InkWell(
                onTap: (){
                  _showBarangDialog(e);
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  width: double.infinity,
                  child: Text(e.kode_barang!+" - "+e.nama_barang!),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8),
        color: Colors.black,
        child: Row(
          children: [
            Expanded(
              child: MaterialButton(
                onPressed: (){
                  _addStokModal('in').then((value){
                    dataBarang.forEach((element) {
                      setState(() {
                        element.qty = 0;
                      });
                    });
                  });
                },
                elevation: 0,
                highlightElevation: 0,
                color: Colors.white,
                textColor: Colors.black,
                child: Text('Beli'),
              ),
            ),
            SizedBox(width: 10,),
            Expanded(
              child: MaterialButton(
                onPressed: (){
                  _addStokModal('out').then((value){
                    dataBarang.forEach((element) {
                      setState(() {
                        element.qty = 0;
                      });
                    });
                  });
                },
                elevation: 0,
                highlightElevation: 0,
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Jual'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: (){
          _showFormDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
