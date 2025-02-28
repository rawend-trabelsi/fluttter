import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/service.dart';
import '../services/ServiceService.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';

class UpdateServicePage extends StatefulWidget {
  final Service service;

  UpdateServicePage({required this.service});

  @override
  _UpdateServicePageState createState() => _UpdateServicePageState();
}

class _UpdateServicePageState extends State<UpdateServicePage> {
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  final _dureeController = TextEditingController();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _titreController.text = widget.service.titre;
    _descriptionController.text = widget.service.description;
    _prixController.text = widget.service.prix.toString();
    _dureeController.text = widget.service.duree;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _submitService() async {
    if (_titreController.text.isNotEmpty &&
        _prixController.text.isNotEmpty &&
        double.tryParse(_prixController.text) != null) {
      try {
        double prix = double.parse(_prixController.text);

        XFile? imageFile = _imageFile ?? null;

        ServiceService serviceService = ServiceService();
        await serviceService.updateService(
          id: widget.service.id,
          titre: _titreController.text,
          description: _descriptionController.text,
          prix: prix,
          duree: _dureeController.text,
          imageFile: imageFile,
        );

        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF00BCD0),
                      size: 80,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Succès',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BCD0),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Le service a été mis à jour avec succès !',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00BCD0),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: ${e.toString()}'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Veuillez remplir tous les champs correctement.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black), // Bouton hamburger
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Modifier service'),
      ),
      drawer: Sidebar(authService: AuthService(), onSelectPage: (index) {}),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _imageFile != null
                    ? FileImage(File(_imageFile!.path))
                    : (widget.service.imageUrl != null &&
                            widget.service.imageUrl!.isNotEmpty
                        ? (widget.service.imageUrl!.startsWith('http')
                            ? NetworkImage(widget.service.imageUrl!)
                            : MemoryImage(
                                base64Decode(widget.service.imageUrl!)))
                        : null) as ImageProvider<Object>?,
                child: _imageFile == null &&
                        (widget.service.imageUrl == null ||
                            widget.service.imageUrl!.isEmpty)
                    ? Icon(Icons.add_photo_alternate,
                        size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            SizedBox(height: 30),
            CustomTextField(
                controller: _titreController, hintText: "Titre du service"),
            CustomTextField(
                controller: _descriptionController, hintText: "Description"),
            CustomTextField(controller: _prixController, hintText: "Prix"),
            CustomTextField(controller: _dureeController, hintText: "Durée"),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitService,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00BCD0),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text("Modifier",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  CustomTextField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          border: UnderlineInputBorder(),
        ),
      ),
    );
  }
}
