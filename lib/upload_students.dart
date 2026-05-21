import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'dart:math';

// Development-only Firestore seeding utility.
// Keep this out of normal production navigation; it writes sample documents to
// the existing Evaluations collection and is intended for local/manual setup.
class UploadSwimmersPage extends StatefulWidget {
  const UploadSwimmersPage({super.key});

  @override
  State<UploadSwimmersPage> createState() => _UploadSwimmersPageState();
}

class _UploadSwimmersPageState extends State<UploadSwimmersPage> {
  bool isUploading = false;
  String message = "";

  final List<String> names = [
    "Ahmed Hassan",
    "Mohamed Ali",
    "Youssef Ibrahim",
    "Omar Khaled",
    "Karim Adel",
    "Hassan Mahmoud",
    "Mostafa Tarek",
    "Ali Fathy",
    "Amr Mohamed",
    "Ibrahim Samir",
    "Mahmoud Yasser",
    "Tamer Ehab",
    "Khaled Nabil",
    "Islam Hany",
    "Sherif Magdy",
    "Ehab Mostafa",
    "Fady Rami",
    "Adel Saad",
    "Othman Farid",
    "Walid Ashraf",
    "Ahmed Tamer",
    "Ramy Gamal",
    "Yasser Lotfy",
    "Ziad Emad",
    "Ayman Hossam",
    "Mina Nader",
    "Nour Ahmed",
    "Farah Hassan",
    "Sara Youssef",
    "Hana Mostafa",
    "Laila Khaled",
    "Malak Tarek",
    "Mariam Hany",
    "Rania Adel",
    "Nada Ibrahim",
    "Dina Sherif",
    "Hagar Fathy",
    "Esraa Mahmoud",
    "Reem Omar",
    "Salma Nabil",
    "Aya Karim",
    "Nourhan Ahmed",
    "Yasmin Ehab",
    "Mona Ali",
    "Basma Walid",
    "Rana Magdy",
    "Lobna Hassan",
    "Nadine Omar",
    "Menna Tamer",
    "Habiba Ziad"
  ];

  final List<String> levels = ["Beginner", "Intermediate", "Advanced"];
  final List<List<String>> trainingOptions = [
    ["Sunday", "Tuesday", "Thursday"],
    ["Monday", "Wednesday", "Friday"],
    ["Saturday", "Monday", "Wednesday"],
    ["Sunday", "Wednesday", "Friday"],
    ["Tuesday", "Thursday", "Saturday"],
  ];

  final List<String> subsStatus = [AppStatuses.active, AppStatuses.expired];
  final List<String> passedStatus = [AppStatuses.yes, AppStatuses.no];
  final Random random = Random();

  Future<void> uploadSwimmers() async {
    setState(() {
      isUploading = true;
      message = "Uploading swimmers to Firestore...";
    });

    final CollectionReference swimmersCollection =
        FirebaseFirestore.instance.collection(AppCollections.evaluations);

    for (String name in names) {
      await swimmersCollection.add({
        AppFields.name: name,
        AppFields.level: levels[random.nextInt(levels.length)],
        AppFields.score: 6 + random.nextInt(5),
        AppFields.date: DateTime.now().toIso8601String(),
        AppFields.notes: "Good performance and breathing control",
        AppFields.trainingDays:
            trainingOptions[random.nextInt(trainingOptions.length)].join(", "),
        AppFields.subscriptionStatus:
            subsStatus[random.nextInt(subsStatus.length)],
        AppFields.passed: passedStatus[random.nextInt(passedStatus.length)],
      });
    }

    setState(() {
      isUploading = false;
      message = "✅ Successfully uploaded 50 swimmers to Firestore!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Swimmers"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message.isEmpty
                    ? "Press the button to upload swimmers data"
                    : message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: isUploading ? null : uploadSwimmers,
                icon: const Icon(Icons.cloud_upload_rounded),
                label: Text(
                  isUploading ? "Uploading..." : "Upload 50 Swimmers",
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
