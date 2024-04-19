import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadDocument(String userId) async {
  // Pick the document
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    PlatformFile file = result.files.first;

    // Create a reference to Firebase Storage
    Reference storageRef =
    FirebaseStorage.instance.ref().child('documents').child(userId).child(file.name);

    // Start the upload task
    UploadTask uploadTask = storageRef.putData(
      file.bytes!,
      SettableMetadata(contentType: 'application/pdf'), // or any file type you're uploading
    );

    // Wait for the upload to complete
    await uploadTask.whenComplete(() => {});

    // Get the download URL
    String documentUrl = await storageRef.getDownloadURL();

    // Get the document name
    String documentName = file.name;

    // Define the new document object
    Map<String, dynamic> newDocument = {
      'document': documentUrl,
      'name': documentName,
    };

    // Reference to Firestore document where the array is stored
    DocumentReference documentRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Update the Firestore document
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentRef);

      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }

      List<dynamic> currentDocuments = snapshot.get('documents') ?? [];

      transaction.update(documentRef, {
        'personalDocuments': FieldValue.arrayUnion([newDocument]),
      });
    });
  }
}
