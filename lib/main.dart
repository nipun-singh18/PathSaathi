import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/profile_input_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PathSaathi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const ProfileInputScreen();
        }
        return const SignInPage();
      },
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PathSaathi Login')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            try {
              await signInWithGoogle();
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
            }
          },
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final nameController = TextEditingController();
  final courseController = TextEditingController();
  final collegeController = TextEditingController();
  String message = '';

  User get currentUser => FirebaseAuth.instance.currentUser!;

  Future<void> saveProfile() async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(currentUser.uid)
        .set({
          'uid': currentUser.uid,
          'email': currentUser.email,
          'name': nameController.text.trim(),
          'course': courseController.text.trim(),
          'college': collegeController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
    setState(() => message = 'Profile saved successfully ✅');
  }

  Future<void> loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(currentUser.uid)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? '';
      courseController.text = data['course'] ?? '';
      collegeController.text = data['college'] ?? '';
      setState(() => message = 'Profile loaded ✅');
    } else {
      setState(() => message = 'No profile found');
    }
  }

  // ✅ FIXED: signOut without google_sign_in package
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    courseController.dispose();
    collegeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signed in as: ${currentUser.email ?? "No email"}'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: courseController,
              decoration: const InputDecoration(labelText: 'Course'),
            ),
            TextField(
              controller: collegeController,
              decoration: const InputDecoration(labelText: 'College'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveProfile,
              child: const Text('Save Profile'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: loadProfile,
              child: const Text('Read Profile'),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
