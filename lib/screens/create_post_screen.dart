import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import 'location_handler.dart'; // Import the location handler

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _descriptionController = TextEditingController();
  final _injuredPersonsController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _dateTime;
  String? _currentAddress; // Variable to store the location

  LocationHandler _locationHandler =
      LocationHandler(); // Instance of LocationHandler

  @override
  void initState() {
    super.initState();
    _setDateTime();
    _getLocation(); // Fetch the location
  }

  Future<void> _getLocation() async {
    await _locationHandler.getLocation(); // Get location using LocationHandler
    setState(() {
      _currentAddress = _locationHandler.currentAddress; // Set the address
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _setDateTime() async {
    final now = DateTime.now();
    setState(() {
      _dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    });
  }

  Future<void> _uploadPost() async {
    if (_image == null ||
        _descriptionController.text.isEmpty ||
        _injuredPersonsController.text.isEmpty ||
        _currentAddress == null) return; // Ensure the location is captured

    // Upload image to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child('${DateTime.now().toIso8601String()}.jpg');
    final uploadTask = storageRef.putFile(_image!);
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Save post details to Firestore
    final postRef = FirebaseFirestore.instance.collection('posts').doc();
    await postRef.set({
      'imageUrl': downloadUrl,
      'description': _descriptionController.text,
      'createdAt': FieldValue.serverTimestamp(),
      'location': _currentAddress, // Use captured location
      'dateTime': _dateTime,
      'injuredPersons': int.tryParse(_injuredPersonsController.text) ?? 0,
    });

    // Clear input fields and image
    setState(() {
      _image = null;
      _descriptionController.clear();
      _injuredPersonsController.clear();
    });

    // Navigate to PostDetailsScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailsScreen(postId: postRef.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _image == null
                ? const Text('No image selected.')
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _injuredPersonsController,
              decoration:
                  const InputDecoration(labelText: 'Number of Injured Persons'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _currentAddress == null
                ? const Text('Fetching location...')
                : Text('Location: $_currentAddress'), // Display the location
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadPost,
              child: const Text('Upload Post'),
            ),
          ],
        ),
      ),
    );
  }
}

class PostDetailsScreen extends StatelessWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('posts').doc(postId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No post found.'));
          }

          final post = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (post['imageUrl'] != null) Image.network(post['imageUrl']),
                Text(
                  'Description: ${post['description']}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Location: ${post['location']}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Date & Time: ${post['dateTime']}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Injured Persons: ${post['injuredPersons']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
