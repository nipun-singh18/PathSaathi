import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'services/knowledge_base.dart';
import 'services/language_service.dart';
import 'l10n/app_localizations.dart';

// --- APP SCREENS ---
import 'screens/welcome_screen.dart';
import 'screens/stream_selection_screen.dart';
import 'screens/profile_input_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/career_recommendations_screen.dart';
import 'screens/career_detail_screen.dart';
import 'screens/visual_roadmap_screen.dart';
import 'screens/government_schemes_screen.dart';
import 'screens/alternate_paths_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env safely — don't crash if file is missing.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: .env file not loaded: $e');
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load career/scheme/question data from assets/data/
  await KnowledgeBase.instance.load();

  runApp(const PathSaathiApp());
}

class PathSaathiApp extends StatelessWidget {
  const PathSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to LanguageService so locale changes rebuild the whole app
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'PathSaathi',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          // ─── Localization ───
          locale: LanguageService.instance.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // ─── Routing ───
          home: const AuthGate(),
          routes: {
            '/welcome': (context) => const WelcomeScreen(),
            '/stream_selection': (context) => const StreamSelectionScreen(),
            '/profile_input': (context) => const ProfileInputScreen(),
            '/processing': (context) => const ProcessingScreen(),
            '/career_recommendations': (context) =>
                const CareerRecommendationsScreen(),
            '/career_detail': (context) => const CareerDetailScreen(),
            '/visual_roadmap': (context) => const VisualRoadmapScreen(),
            '/government_schemes': (context) => const GovernmentSchemesScreen(),
            '/alternate_paths': (context) => const AlternatePathsScreen(),
          },
        );
      },
    );
  }
}

// --- AUTHENTICATION GATEWAY ---
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
          // After login, load the user's saved language preference
          // (fire-and-forget — doesn't block the welcome screen)
          LanguageService.instance.loadFromFirestore();
          return const WelcomeScreen();
        }
        return const SignInPage();
      },
    );
  }
}

// --- SIGN IN PAGE (works on both web and Android) ---
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isSigningIn = false;

  Future<void> signInWithGoogle() async {
    setState(() => _isSigningIn = true);
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          if (mounted) setState(() => _isSigningIn = false);
          return;
        }

        final googleAuth = await googleUser.authentication;

        // CRITICAL: mobile requires BOTH accessToken and idToken
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      // Create/update user document in Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .set({
              'uid': user.uid,
              'email': user.email,
              'displayName': user.displayName,
              'createdAt': FieldValue.serverTimestamp(),
              'lastActive': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSigningIn = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'PathSaathi',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your AI-powered career companion',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSigningIn ? null : signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isSigningIn
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.login),
                  label: Text(
                    _isSigningIn ? 'Signing in...' : 'Sign in with Google',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}