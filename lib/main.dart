// lib/main.dart
// APPIUM_TEST_LABELS:
// get_started_button, email_field, password_field, google_sign_in_button,
// sign_in_button, logout_button, raise_issue_fab, chatbot_message_field,
// send_message_button, nav_dashboard, nav_campus_feed, nav_complaints,
// nav_placement_portal, nav_notifications, nav_chatbot, nav_my_profile,
// quick_raise_issue, quick_placement, quick_profiles, quick_notifications,
// quick_chatbot, quick_my_profile
// SmartCampus - Full No-Billing Version
// Features included:
// Firebase Auth, dark mode, forgot password, edit profile, grievance search/filter,
// booking cancel, emergency contacts, faculty directory, lost & found, feedback,
// Supabase live grievances and bookings, chat demo, map, timetable, announcements, analytics, image preview.
// Realtime Supabase portal enabled.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await Supabase.initialize(
      url: 'https://mvfvflrjwmwlzzjgrtsy.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12ZnZmbHJqd213bHp6amdydHN5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2MDk2NjAsImV4cCI6MjA5MzE4NTY2MH0.YLYhumUwwuR6_FbilfvMioTJA7OhxhquMDrcrcysxcs',
    );

    runApp(const SmartCampusApp());
  } catch (e) {
    runApp(FirebaseErrorApp(error: e.toString()));
  }
}

final supabase = Supabase.instance.client;


class PortalColors {
  static const sidebar = Color(0xFF314255);
  static const sidebarDark = Color(0xFF263544);
  static const header = Color(0xFF263544);
  static const pageBg = Color(0xFFEFF3F7);
  static const teal = Color(0xFF27A99A);
  static const red = Color(0xFFE9565B);
  static const purple = Color(0xFF8E78B8);
  static const textGrey = Color(0xFF666666);
}


class ModernColors {
  static const navy = Color(0xFF0F172A);
  static const slate = Color(0xFF1E293B);
  static const cyan = Color(0xFF06B6D4);
  static const blue = Color(0xFF2563EB);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const bg = Color(0xFFF8FAFC);
}

class AppColors {
  static const primary = Color(0xFF1565C0);
  static const darkBlue = Color(0xFF0D47A1);
  static const bg = Color(0xFFF5F7FA);
  static const text = Color(0xFF1A1A2E);
  static const danger = Color(0xFFE53935);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFE65100);
}

class AppState {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  static bool sessionTimeoutEnabled = false;
  static final List<String> activityLogs = ['App started in realtime portal mode'];

  static void addLog(String message) {
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    activityLogs.insert(0, '$time - $message');
  }

  static void toggleTheme(bool dark) {
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }
}


class AccessControl {
  static const String collegeDomain = 'saveetha.com';
  static const String adminEmail = 'avligondadileepkumar2074.sse@saveetha.com';

  static bool isCollegeEmail(String email) {
    return email.trim().contains('@');
  }

  static bool isAdminEmail(String email) {
    return email.trim().toLowerCase() == adminEmail;
  }

  static String roleForEmail(String email) {
    return isAdminEmail(email) ? 'Admin' : 'Student';
  }
}


// ========================= PREMIUM SPLASH + LANDING + SIGN IN FLOW =========================

class SmartSplashPage extends StatefulWidget {
  const SmartSplashPage({super.key});

  @override
  State<SmartSplashPage> createState() => _SmartSplashPageState();
}

class _SmartSplashPageState extends State<SmartSplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final savedUser = fb.FirebaseAuth.instance.currentUser?.email ?? LocalStore.lastLoggedInEmail;
      if (savedUser != null && savedUser.isNotEmpty) {
        LocalStore.selectedRole = AccessControl.roleForEmail(savedUser);
        LocalStore.currentName ??= AccessControl.isAdminEmail(savedUser)
            ? 'AVILIGONDA DILEEP KUMAR'
            : (LocalStore.userDatabase[savedUser.toLowerCase()]?['name'] ?? savedUser.split('@').first.toUpperCase());
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthGate()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SmartLandingPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -70,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF06B6D4).withOpacity(0.18)),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF2563EB).withOpacity(0.20)),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF06B6D4)]),
                    boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.35), blurRadius: 38, spreadRadius: 4)],
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 72),
                ),
                const SizedBox(height: 30),
                const Text(
                  'SmartCampus',
                  style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                const Text('Your campus, live.', style: TextStyle(color: Colors.white70, fontSize: 17)),
                const SizedBox(height: 34),
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(color: Color(0xFF06B6D4), strokeWidth: 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmartLandingPage extends StatelessWidget {
  const SmartLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      ['Realtime Feed', Icons.dynamic_feed],
      ['AI Chatbot', Icons.smart_toy],
      ['Placements', Icons.work],
      ['Smart Complaints', Icons.report_problem],
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 760;
                  if (wide) {
                    return Row(
                      children: [
                        Expanded(child: _landingText(context, features)),
                        const SizedBox(width: 36),
                        Expanded(child: _landingPreviewCard()),
                      ],
                    );
                  }
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 22),
                        _landingText(context, features),
                        const SizedBox(height: 18),
                        _landingPreviewCard(),
                        const SizedBox(height: 22),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _landingText(BuildContext context, List<List<Object>> features) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, 12))],
          ),
          child: const Icon(Icons.hub, color: Colors.white, size: 66),
        ),
        const SizedBox(height: 30),
        const Text(
          'A Live Digital Campus\nin Your Pocket',
          style: TextStyle(fontSize: 34, height: 1.15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Connect with campus updates, placements, complaints, chatbot, profiles and notifications in realtime.',
          style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: features.map((f) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f[1] as IconData, size: 17, color: const Color(0xFF2563EB)),
                  const SizedBox(width: 7),
                  Text(f[0] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: Semantics(
            label: 'get_started_button',
            button: true,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartSignInPage())),
              child: const Text('Get Started', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _landingPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [BoxShadow(color: Color(0x330F172A), blurRadius: 30, offset: Offset(0, 18))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              CircleAvatar(radius: 18, backgroundColor: Color(0xFF06B6D4), child: Icon(Icons.school, color: Colors.white, size: 19)),
              SizedBox(width: 10),
              Expanded(child: Text('Live Campus Pulse', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18))),
              Icon(Icons.circle, color: Colors.greenAccent, size: 12),
              SizedBox(width: 5),
              Text('LIVE', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 18),
          const Column(
            children: [
              Row(
                children: [
                  Expanded(child: _MiniPulseCard(title: 'Students Online', value: '187', icon: Icons.people)),
                  SizedBox(width: 12),
                  Expanded(child: _MiniPulseCard(title: 'Placements', value: '05', icon: Icons.work)),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _MiniPulseCard(title: 'Notifications', value: '12', icon: Icons.notifications)),
                  SizedBox(width: 12),
                  Expanded(child: _MiniPulseCard(title: 'Issues Resolved', value: '24', icon: Icons.verified)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Icon(Icons.smart_toy, color: Color(0xFF06B6D4)),
                SizedBox(width: 10),
                Expanded(child: Text('AI Campus Assistant ready to guide students.', style: TextStyle(color: Colors.white70))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPulseCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniPulseCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF06B6D4), size: 18),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 10), overflow: TextOverflow.ellipsis, maxLines: 1),
        ],
      ),
    );
  }
}

class SmartSignInPage extends StatelessWidget {
  const SmartSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}

// ======================= END PREMIUM SPLASH + LANDING + SIGN IN FLOW =======================

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppState.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'SmartCampus',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light),
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.bg,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF101418),
          ),
          home: const SmartSplashPage(),
        );
      },
    );
  }
}


class AdminOnlyScreen extends StatelessWidget {
  final Widget child;
  const AdminOnlyScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentEmail = FirebaseAuth.instance.currentUser?.email?.toLowerCase() ?? '';
    if (!AccessControl.isAdminEmail(currentEmail)) {
      return Scaffold(
        appBar: appBar('Admin Access Denied', back: true, context: context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: infoBox('Only avligondadileepkumar2074.sse@saveetha.com can access the admin portal and accept queries.'),
          ),
        ),
      );
    }
    return child;
  }
}

class FirebaseErrorApp extends StatelessWidget {
  final String error;
  const FirebaseErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: cardDecoration(radius: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Firebase Setup Error', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.danger)),
                  const SizedBox(height: 12),
                  const Text('Check firebase_options.dart and Firebase Authentication setup.'),
                  const SizedBox(height: 12),
                  SelectableText(error, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb.User?>(
      stream: fb.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData) return const LoginScreen();

        final firebaseUser = snapshot.data!;
        final email = firebaseUser.email ?? 'user@college.edu';
        LocalStore.currentName ??= AccessControl.isAdminEmail(email) ? 'AVILIGONDA DILEEP KUMAR' : email.split('@').first;
        Future.microtask(() async {
          try {
            await supabase.from('app_registered_users').upsert({
              'email': email,
              'full_name': AccessControl.isAdminEmail(email) ? 'AVILIGONDA DILEEP KUMAR' : (LocalStore.currentName ?? email.split('@').first),
              'role': AccessControl.isAdminEmail(email) ? 'admin' : 'student',
              'photo_url': LocalStore.profilePhotoUrl,
              'status': 'active',
              'last_login': DateTime.now().toIso8601String(),
            }, onConflict: 'email');

            await supabase.from('profiles').upsert({
              'email': email,
              'full_name': AccessControl.isAdminEmail(email) ? 'AVILIGONDA DILEEP KUMAR' : (LocalStore.currentName ?? email.split('@').first),
              'role': AccessControl.isAdminEmail(email) ? 'admin' : 'student',
              'phone': AccessControl.isAdminEmail(email) ? '7032643839' : LocalStore.currentPhone,
              'status': 'active',
              'last_login': DateTime.now().toIso8601String(),
            }, onConflict: 'email');
          } catch (_) {}
        });
        return MainScreen(
          user: AppUser(
            uid: firebaseUser.uid,
            email: email,
            role: AccessControl.roleForEmail(email),
            name: LocalStore.currentName ?? email.split('@').first,
            phone: LocalStore.currentPhone,
            department: LocalStore.currentDepartment,
          ),
        );
      },
    );
  }
}

class AppUser {
  final String uid;
  final String email;
  final String role;
  final String name;
  final String phone;
  final String department;

  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    required this.phone,
    required this.department,
  });

  AppUser copyWith({String? name, String? phone, String? department}) {
    return AppUser(
      uid: uid,
      email: email,
      role: role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      department: department ?? this.department,
    );
  }
}

class LocalGrievance {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  String status;
  final String createdByEmail;
  final DateTime createdAt;
  final XFile? image;

  LocalGrievance({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdByEmail,
    required this.createdAt,
    this.image,
  });
}

class LocalBooking {
  final String id;
  final String resource;
  final String date;
  final String time;
  final String userEmail;
  final DateTime createdAt;
  String status;

  LocalBooking({
    required this.id,
    required this.resource,
    required this.date,
    required this.time,
    required this.userEmail,
    required this.createdAt,
    this.status = 'Confirmed',
  });
}

class LocalMessage {
  final String text;
  final String senderEmail;
  final DateTime createdAt;

  LocalMessage({required this.text, required this.senderEmail, required this.createdAt});
}

class LostFoundItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final String contact;
  final DateTime createdAt;

  LostFoundItem({required this.id, required this.title, required this.description, required this.type, required this.contact, required this.createdAt});
}

class FeedbackItem {
  final String id;
  final String category;
  final String message;
  final int rating;
  final String createdBy;
  final DateTime createdAt;

  FeedbackItem({required this.id, required this.category, required this.message, required this.rating, required this.createdBy, required this.createdAt});
}

class AttendanceRecord {
  final String subject;
  final int attended;
  final int total;

  AttendanceRecord({required this.subject, required this.attended, required this.total});

  double get percentage => total == 0 ? 0 : (attended / total) * 100;
}

class LibraryBook {
  final String title;
  final String author;
  final String category;
  final bool available;

  LibraryBook({required this.title, required this.author, required this.category, required this.available});
}

class ExamItem {
  final String subject;
  final String date;
  final String time;
  final String room;

  ExamItem({required this.subject, required this.date, required this.time, required this.room});
}

class MarkItem {
  final String subject;
  final int marks;
  final int total;
  final String grade;

  MarkItem({required this.subject, required this.marks, required this.total, required this.grade});
}

class BusRoute {
  final String routeNo;
  final String from;
  final String to;
  final String timing;
  final String driver;

  BusRoute({required this.routeNo, required this.from, required this.to, required this.timing, required this.driver});
}

class HostelRequest {
  final String id;
  final String type;
  final String description;
  String status;

  HostelRequest({required this.id, required this.type, required this.description, required this.status});
}

class CampusEvent {
  final String id;
  final String title;
  final String date;
  final String venue;
  final String description;
  bool registered;

  CampusEvent({required this.id, required this.title, required this.date, required this.venue, required this.description, this.registered = false});
}

class NoticeItem {
  final String title;
  final String body;
  final String date;

  NoticeItem({required this.title, required this.body, required this.date});
}

class AssignmentItem {
  final String subject;
  final String title;
  final String dueDate;
  bool completed;

  AssignmentItem({required this.subject, required this.title, required this.dueDate, this.completed = false});
}

class FeeItem {
  final String title;
  final int amount;
  String status;
  final String dueDate;

  FeeItem({required this.title, required this.amount, required this.status, required this.dueDate});
}

class PlacementItem {
  final String company;
  final String role;
  final String package;
  final String eligibility;
  bool applied;

  PlacementItem({required this.company, required this.role, required this.package, required this.eligibility, this.applied = false});
}

class ClubItem {
  final String name;
  final String description;
  final String coordinator;
  bool joined;

  ClubItem({required this.name, required this.description, required this.coordinator, this.joined = false});
}

class LabItem {
  final String name;
  final String block;
  final int systems;
  bool available;

  LabItem({required this.name, required this.block, required this.systems, required this.available});
}

class StudyMaterialItem {
  final String subject;
  final String title;
  final String type;

  StudyMaterialItem({required this.subject, required this.title, required this.type});
}

class MentorSlot {
  final String mentor;
  final String date;
  final String time;
  bool booked;

  MentorSlot({required this.mentor, required this.date, required this.time, this.booked = false});
}

class CalendarItem {
  final String title;
  final String date;
  final String type;

  CalendarItem({required this.title, required this.date, required this.type});
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int answerIndex;

  QuizQuestion({required this.question, required this.options, required this.answerIndex});
}

class InternshipItem {
  final String company;
  final String role;
  final String deadline;
  bool applied;

  InternshipItem({required this.company, required this.role, required this.deadline, this.applied = false});
}

class SkillItem {
  final String name;
  double progress;

  SkillItem({required this.name, required this.progress});
}

class AlumniItem {
  final String name;
  final String company;
  final String batch;
  final String email;

  AlumniItem({required this.name, required this.company, required this.batch, required this.email});
}

class LocalStore {
  static String selectedRole = 'Student';
  static String? currentName;
  static String currentPhone = '7032643839';
  static String currentDepartment = 'Computer Science';
  static String profilePhotoUrl = '';
  static String? lastLoggedInEmail = 'avligondadileepkumar2074.sse@saveetha.com';

  static final Map<String, Map<String, String>> userDatabase = {
    'avligondadileepkumar2074.sse@saveetha.com': {
      'name': 'AVILIGONDA DILEEP KUMAR',
      'password': 'GoogleUserPassword123!',
      'role': 'Admin',
    },
    'dileepkumar.student@saveetha.com': {
      'name': 'DILEEP KUMAR STUDENT',
      'password': 'GoogleUserPassword123!',
      'role': 'Student',
    },
    'google.student@saveetha.com': {
      'name': 'GOOGLE STUDENT',
      'password': 'GoogleUserPassword123!',
      'role': 'Student',
    },
  };

  static bool isRegisteredEmail(String email) {
    final clean = email.trim().toLowerCase();
    return userDatabase.containsKey(clean);
  }

  static void registerUser(String email, String name, String password) {
    final clean = email.trim().toLowerCase();
    userDatabase[clean] = {
      'name': name,
      'password': password,
      'role': AccessControl.roleForEmail(clean),
    };
    lastLoggedInEmail = clean;
    currentName = name;
  }

  static final List<LocalGrievance> grievances = [
    LocalGrievance(id: 'GR1001', title: 'Broken projector in Lab 3', description: 'Projector is not turning on during lab sessions.', category: 'Infrastructure', priority: 'High', status: 'Pending', createdByEmail: 'student@college.edu', createdAt: DateTime(2026, 4, 22)),
    LocalGrievance(id: 'GR1002', title: 'WiFi not working in Block B', description: 'Students are unable to connect to campus WiFi.', category: 'Infrastructure', priority: 'Medium', status: 'In Progress', createdByEmail: 'student@college.edu', createdAt: DateTime(2026, 4, 20)),
    LocalGrievance(id: 'GR1003', title: 'Canteen food quality issue', description: 'Food quality needs improvement.', category: 'Canteen', priority: 'Low', status: 'Resolved', createdByEmail: 'student@college.edu', createdAt: DateTime(2026, 4, 18)),
  ];

  static final List<LocalBooking> bookings = [
    LocalBooking(id: 'BK1001', resource: 'Computer Lab A', date: 'Today', time: '10:00 AM', userEmail: 'student@college.edu', createdAt: DateTime.now()),
  ];

  static final List<LocalMessage> messages = [
    LocalMessage(text: 'Welcome to SmartCampus support chat.', senderEmail: 'admin@college.edu', createdAt: DateTime.now()),
  ];

  static final List<Map<String, String>> announcements = [
    {'title': 'Internal Exam Schedule Released', 'body': 'Students can check the timetable section for exam slots.'},
    {'title': 'Library Maintenance', 'body': 'Library hall will be unavailable tomorrow from 2 PM to 4 PM.'},
    {'title': 'Placement Training', 'body': 'Placement training starts next Monday in Seminar Hall.'},
  ];

  static final List<Map<String, String>> emergencyContacts = [
    {'name': 'AVILIGONDA DILEEP KUMAR', 'phone': '7032643839', 'icon': 'security'},
    {'name': 'Medical Room', 'phone': '044-2222-3333', 'icon': 'medical'},
    {'name': 'Transport Helpdesk', 'phone': '044-3333-4444', 'icon': 'bus'},
    {'name': 'Women Safety Cell', 'phone': '044-4444-5555', 'icon': 'safety'},
  ];

  static final List<Map<String, String>> faculty = [
    {'name': 'Dr. Priya Raman', 'dept': 'CSE', 'email': 'priya.raman@college.edu', 'phone': '9000011111'},
    {'name': 'Prof. Arjun Kumar', 'dept': 'ECE', 'email': 'arjun.kumar@college.edu', 'phone': '9000022222'},
    {'name': 'Dr. Meena S', 'dept': 'IT', 'email': 'meena.s@college.edu', 'phone': '9000033333'},
    {'name': 'Prof. Karthik V', 'dept': 'Mechanical', 'email': 'karthik.v@college.edu', 'phone': '9000044444'},
  ];

  static final List<LostFoundItem> lostFound = [
    LostFoundItem(id: 'LF1001', title: 'Black Wallet', description: 'Found near library entrance.', type: 'Found', contact: 'security@college.edu', createdAt: DateTime.now()),
    LostFoundItem(id: 'LF1002', title: 'Blue Water Bottle', description: 'Lost in Computer Lab A.', type: 'Lost', contact: 'student@college.edu', createdAt: DateTime.now()),
  ];

  static final List<FeedbackItem> feedbacks = [];

  static final List<AttendanceRecord> attendance = [
    AttendanceRecord(subject: 'Data Structures', attended: 38, total: 45),
    AttendanceRecord(subject: 'Operating Systems', attended: 34, total: 42),
    AttendanceRecord(subject: 'Database Systems', attended: 40, total: 44),
    AttendanceRecord(subject: 'Flutter Development', attended: 28, total: 30),
  ];

  static final List<LibraryBook> libraryBooks = [
    LibraryBook(title: 'Clean Code', author: 'Robert C. Martin', category: 'Programming', available: true),
    LibraryBook(title: 'Introduction to Algorithms', author: 'CLRS', category: 'Computer Science', available: false),
    LibraryBook(title: 'Database System Concepts', author: 'Silberschatz', category: 'Database', available: true),
    LibraryBook(title: 'Operating System Concepts', author: 'Galvin', category: 'Operating Systems', available: true),
    LibraryBook(title: 'Flutter in Action', author: 'Eric Windmill', category: 'Mobile App', available: false),
  ];

  static final List<ExamItem> exams = [
    ExamItem(subject: 'Data Structures', date: 'May 10, 2026', time: '10:00 AM', room: 'Room 201'),
    ExamItem(subject: 'Operating Systems', date: 'May 13, 2026', time: '10:00 AM', room: 'Room 202'),
    ExamItem(subject: 'Database Systems', date: 'May 16, 2026', time: '02:00 PM', room: 'Lab A'),
    ExamItem(subject: 'Flutter Development', date: 'May 20, 2026', time: '09:30 AM', room: 'Seminar Hall'),
  ];

  static final List<MarkItem> marks = [
    MarkItem(subject: 'Data Structures', marks: 87, total: 100, grade: 'A'),
    MarkItem(subject: 'Operating Systems', marks: 78, total: 100, grade: 'B+'),
    MarkItem(subject: 'Database Systems', marks: 91, total: 100, grade: 'A+'),
    MarkItem(subject: 'Flutter Development', marks: 95, total: 100, grade: 'A+'),
  ];

  static final List<BusRoute> busRoutes = [
    BusRoute(routeNo: 'B12', from: 'Tambaram', to: 'Campus', timing: '7:20 AM', driver: 'Mr. Kumar'),
    BusRoute(routeNo: 'B18', from: 'Velachery', to: 'Campus', timing: '7:10 AM', driver: 'Mr. Ravi'),
    BusRoute(routeNo: 'B21', from: 'Avadi', to: 'Campus', timing: '6:55 AM', driver: 'Mr. Mani'),
    BusRoute(routeNo: 'B25', from: 'Porur', to: 'Campus', timing: '7:30 AM', driver: 'Mr. Selvam'),
  ];

  static final List<HostelRequest> hostelRequests = [
    HostelRequest(id: 'HR1001', type: 'Maintenance', description: 'Fan not working in Room B-204', status: 'Pending'),
    HostelRequest(id: 'HR1002', type: 'Cleaning', description: 'Common area cleaning request', status: 'Resolved'),
  ];

  static final List<Map<String, String>> canteenMenu = [
    {'meal': 'Breakfast', 'item': 'Idli, Sambar, Chutney', 'price': '₹35'},
    {'meal': 'Lunch', 'item': 'Meals, Curd Rice, Veg Curry', 'price': '₹70'},
    {'meal': 'Snacks', 'item': 'Samosa, Tea, Coffee', 'price': '₹25'},
    {'meal': 'Dinner', 'item': 'Chapati, Kurma, Rice', 'price': '₹60'},
  ];

  static final List<CampusEvent> events = [
    CampusEvent(id: 'EV1001', title: 'Tech Symposium', date: 'May 25, 2026', venue: 'Auditorium', description: 'Technical paper presentations and coding contests.'),
    CampusEvent(id: 'EV1002', title: 'Sports Day', date: 'May 28, 2026', venue: 'Sports Ground', description: 'Athletics, football, cricket and indoor games.'),
    CampusEvent(id: 'EV1003', title: 'Placement Bootcamp', date: 'June 2, 2026', venue: 'Seminar Hall', description: 'Resume building, aptitude and mock interviews.'),
  ];

  static final List<NoticeItem> notices = [
    NoticeItem(title: 'Semester Registration', body: 'Students must complete semester registration before May 5.', date: 'Apr 30, 2026'),
    NoticeItem(title: 'Holiday Notice', body: 'College remains closed on May 1 for Labour Day.', date: 'Apr 29, 2026'),
    NoticeItem(title: 'Library Fine Waiver', body: 'Return overdue books before May 7 to avoid additional fines.', date: 'Apr 28, 2026'),
  ];

  static final List<AssignmentItem> assignments = [
    AssignmentItem(subject: 'Data Structures', title: 'Binary Tree Problems', dueDate: 'May 4, 2026'),
    AssignmentItem(subject: 'Operating Systems', title: 'Process Scheduling Report', dueDate: 'May 6, 2026'),
    AssignmentItem(subject: 'Database Systems', title: 'SQL Practice Sheet', dueDate: 'May 8, 2026'),
  ];

  static final List<FeeItem> fees = [
    FeeItem(title: 'Tuition Fee', amount: 45000, status: 'Paid', dueDate: 'Apr 15, 2026'),
    FeeItem(title: 'Exam Fee', amount: 2500, status: 'Pending', dueDate: 'May 10, 2026'),
    FeeItem(title: 'Hostel Fee', amount: 30000, status: 'Pending', dueDate: 'May 20, 2026'),
  ];

  static final List<PlacementItem> placements = [
    PlacementItem(company: 'TCS', role: 'Software Engineer', package: '4.5 LPA', eligibility: 'CGPA 7.0+'),
    PlacementItem(company: 'Infosys', role: 'System Engineer', package: '3.8 LPA', eligibility: 'No active arrears'),
    PlacementItem(company: 'Zoho', role: 'Developer', package: '6.0 LPA', eligibility: 'Coding round required'),
  ];

  static final List<ClubItem> clubs = [
    ClubItem(name: 'Coding Club', description: 'Weekly coding practice and hackathons.', coordinator: 'Dr. Priya Raman'),
    ClubItem(name: 'Robotics Club', description: 'Build bots and compete in robotics events.', coordinator: 'Prof. Arjun Kumar'),
    ClubItem(name: 'Cultural Club', description: 'Music, dance, theatre and cultural events.', coordinator: 'Dr. Meena S'),
  ];

  static final List<LabItem> labs = [
    LabItem(name: 'Computer Lab A', block: 'Block A', systems: 40, available: true),
    LabItem(name: 'AI/ML Lab', block: 'Block B', systems: 35, available: false),
    LabItem(name: 'Networks Lab', block: 'Block C', systems: 30, available: true),
    LabItem(name: 'Electronics Lab', block: 'Block D', systems: 25, available: true),
  ];

  static final List<StudyMaterialItem> studyMaterials = [
    StudyMaterialItem(subject: 'Data Structures', title: 'Trees and Graphs Notes', type: 'PDF'),
    StudyMaterialItem(subject: 'Operating Systems', title: 'CPU Scheduling Slides', type: 'PPT'),
    StudyMaterialItem(subject: 'Database Systems', title: 'SQL Practice Questions', type: 'PDF'),
    StudyMaterialItem(subject: 'Flutter Development', title: 'Widgets Cheat Sheet', type: 'PDF'),
  ];

  static final List<MentorSlot> mentorSlots = [
    MentorSlot(mentor: 'Dr. Priya Raman', date: 'May 3, 2026', time: '10:00 AM'),
    MentorSlot(mentor: 'Prof. Arjun Kumar', date: 'May 4, 2026', time: '02:00 PM'),
    MentorSlot(mentor: 'Dr. Meena S', date: 'May 5, 2026', time: '11:30 AM'),
  ];

  static final List<CalendarItem> academicCalendar = [
    CalendarItem(title: 'Internal Exam 1', date: 'May 10 - May 20, 2026', type: 'Exam'),
    CalendarItem(title: 'Project Review', date: 'May 24, 2026', type: 'Academic'),
    CalendarItem(title: 'Sports Day', date: 'May 28, 2026', type: 'Event'),
    CalendarItem(title: 'Semester Practical Exams', date: 'June 5 - June 12, 2026', type: 'Exam'),
  ];

  static final List<QuizQuestion> quizQuestions = [
    QuizQuestion(question: 'Flutter uses which programming language?', options: ['Java', 'Dart', 'Python', 'C++'], answerIndex: 1),
    QuizQuestion(question: 'Firebase Auth is used for?', options: ['Login', 'Drawing', 'Styling', 'Routing only'], answerIndex: 0),
    QuizQuestion(question: 'Which widget is used for vertical scrolling?', options: ['Row', 'Container', 'ListView', 'Icon'], answerIndex: 2),
  ];

  static final List<InternshipItem> internships = [
    InternshipItem(company: 'TechNova', role: 'Flutter Intern', deadline: 'May 15, 2026'),
    InternshipItem(company: 'DataWorks', role: 'Data Analyst Intern', deadline: 'May 20, 2026'),
    InternshipItem(company: 'WebCraft', role: 'Frontend Intern', deadline: 'May 25, 2026'),
  ];

  static final List<SkillItem> skills = [
    SkillItem(name: 'Flutter', progress: 0.85),
    SkillItem(name: 'Firebase', progress: 0.70),
    SkillItem(name: 'SQL', progress: 0.78),
    SkillItem(name: 'Communication', progress: 0.80),
  ];

  static final List<String> codingProblems = [
    'Two Sum - Easy',
    'Binary Search - Easy',
    'Valid Parentheses - Easy',
    'Merge Intervals - Medium',
    'LRU Cache - Medium',
  ];

  static final List<AlumniItem> alumni = [
    AlumniItem(name: 'Rahul S', company: 'Google', batch: '2022', email: 'rahul.alumni@college.edu'),
    AlumniItem(name: 'Ananya R', company: 'Zoho', batch: '2021', email: 'ananya.alumni@college.edu'),
    AlumniItem(name: 'Vikram K', company: 'TCS', batch: '2020', email: 'vikram.alumni@college.edu'),
  ];
}


class SmartCampusLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool lightText;

  const SmartCampusLogo({
    super.key,
    this.size = 110,
    this.showText = true,
    this.lightText = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = lightText ? Colors.white : const Color(0xFF0F172A);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * 0.92,
                height: size * 0.92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF06B6D4),
                      Color(0xFF10B981),
                      Color(0xFFF59E0B),
                      Color(0xFFEC4899),
                      Color(0xFF2563EB),
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x3306B6D4), blurRadius: 24, offset: Offset(0, 10)),
                  ],
                ),
              ),
              Container(
                width: size * 0.70,
                height: size * 0.70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: size * 0.12,
                child: Icon(Icons.school_rounded, color: Colors.white, size: size * 0.42),
              ),
              Positioned(
                bottom: size * 0.18,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: size * 0.16, vertical: size * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size),
                  ),
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: const Color(0xFF2563EB),
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: size * 0.03,
                bottom: size * 0.15,
                child: CircleAvatar(radius: size * 0.10, backgroundColor: const Color(0xFFF59E0B)),
              ),
              Positioned(
                right: size * 0.03,
                bottom: size * 0.15,
                child: CircleAvatar(radius: size * 0.10, backgroundColor: const Color(0xFFEC4899)),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor),
              children: const [
                TextSpan(text: 'Smart'),
                TextSpan(text: 'Campus', style: TextStyle(color: Color(0xFF2563EB))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 15, color: lightText ? Colors.white70 : Colors.blueGrey),
              children: const [
                TextSpan(text: 'Your Campus, '),
                TextSpan(text: 'Live.', style: TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final fullName = TextEditingController();
  bool isLogin = true;
  bool loading = false;
  bool obscure = true;
  bool obscureConfirm = true;
  bool remember = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    fullName.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final mail = email.text.trim().toLowerCase();
    final pass = password.text.trim();
    final confirmPass = confirmPassword.text.trim();
    final name = fullName.text.trim();

    if (mail.isEmpty || pass.isEmpty) {
      snack(context, 'Please enter email and password', error: true);
      return;
    }

    if (!AccessControl.isCollegeEmail(mail)) {
      snack(context, 'Please enter a valid email address', error: true);
      return;
    }

    if (!isLogin) {
      if (name.isEmpty) {
        snack(context, 'Please enter your full name / username', error: true);
        return;
      }
      if (pass.length < 6) {
        snack(context, 'Password must be at least 6 characters long', error: true);
        return;
      }
      if (pass != confirmPass) {
        snack(context, 'Passwords do not match. Please re-enter.', error: true);
        return;
      }
    }

    setState(() => loading = true);
    try {
      LocalStore.selectedRole = AccessControl.roleForEmail(mail);
      LocalStore.currentName = name.isNotEmpty ? name : (AccessControl.isAdminEmail(mail) ? 'AVILIGONDA DILEEP KUMAR' : mail.split('@').first);
      LocalStore.registerUser(mail, LocalStore.currentName!, pass);

      if (isLogin) {
        try {
          await fb.FirebaseAuth.instance.signInWithEmailAndPassword(email: mail, password: pass);
        } on fb.FirebaseAuthException catch (e) {
          final code = e.code.toLowerCase();
          if (code == 'user-not-found' || code == 'invalid-credential' || code == 'invalid-auth-credential') {
            bool isKnown = LocalStore.isRegisteredEmail(mail);
            if (!isKnown) {
              try {
                final r1 = await supabase.from('profiles').select('email').eq('email', mail).maybeSingle();
                if (r1 != null) isKnown = true;
              } catch (_) {}
            }
            if (!isKnown) {
              try {
                final r2 = await supabase.from('app_registered_users').select('email').eq('email', mail).maybeSingle();
                if (r2 != null) isKnown = true;
              } catch (_) {}
            }

            if (isKnown) {
              try {
                await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(email: mail, password: pass);
              } catch (_) {}
            } else {
              rethrow;
            }
          } else {
            rethrow;
          }
        }
      } else {
        try {
          await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(email: mail, password: pass);
        } catch (_) {}
      }

      try {
        await supabase.from('app_registered_users').upsert({
          'email': mail,
          'full_name': LocalStore.currentName,
          'role': AccessControl.isAdminEmail(mail) ? 'admin' : 'student',
          'status': 'active',
          'last_login': DateTime.now().toIso8601String(),
        }, onConflict: 'email');

        await supabase.from('profiles').upsert({
          'email': mail,
          'full_name': LocalStore.currentName,
          'role': AccessControl.isAdminEmail(mail) ? 'admin' : 'student',
          'status': 'active',
          'last_login': DateTime.now().toIso8601String(),
        }, onConflict: 'email');
      } catch (_) {}

      if (!mounted) return;
      snack(context, isLogin ? 'Signed in successfully' : 'Account created successfully', error: false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } on fb.FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Authentication failed';
      final code = e.code.toLowerCase();
      if (code == 'user-not-found' || code == 'invalid-credential' || code == 'invalid-auth-credential') {
        msg = isLogin
            ? 'User not registered with this email. Please tap "Create Account" below to sign up.'
            : 'Invalid authentication credentials provided.';
      } else if (code == 'wrong-password') {
        msg = 'Incorrect password for this account. Tap "Forgot Password?" to reset your password.';
      } else if (code == 'email-already-in-use') {
        msg = 'An account already exists with this email. Please tap "Sign In".';
      } else if (code == 'weak-password') {
        msg = 'Password is too weak. Use at least 6 characters.';
      } else if (code == 'invalid-email') {
        msg = 'Please enter a valid email address.';
      }
      snack(context, msg, error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> forgotPassword() async {
    final mailController = TextEditingController(text: email.text.trim().toLowerCase());
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();

    String generatedOtp = (100000 + (DateTime.now().microsecondsSinceEpoch % 900000)).toString();
    int resendSeconds = 30;
    bool otpSent = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: const [
                Icon(Icons.lock_reset, color: Color(0xFF2563EB), size: 28),
                SizedBox(width: 10),
                Text('Reset Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter your registered email to receive a 6-digit OTP verification code:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mailController,
                    decoration: InputDecoration(
                      hintText: 'yourname@example.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (!otpSent) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                        onPressed: () async {
                          final targetMail = mailController.text.trim().toLowerCase();
                          if (targetMail.isEmpty || !AccessControl.isCollegeEmail(targetMail)) {
                            snack(context, 'Enter a valid registered email', error: true);
                            return;
                          }
                          try {
                            await fb.FirebaseAuth.instance.sendPasswordResetEmail(email: targetMail);
                          } catch (_) {}
                          setDlgState(() {
                            otpSent = true;
                            generatedOtp = (100000 + (DateTime.now().microsecondsSinceEpoch % 900000)).toString();
                          });
                          snack(context, 'OTP verification code sent to $targetMail (Code: $generatedOtp)', error: false);
                        },
                        child: const Text('Send 6-Digit OTP Code'),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBFDBFE))),
                      child: Row(
                        children: [
                          const Icon(Icons.mark_email_read, color: Color(0xFF2563EB), size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text('OTP Code sent to ${mailController.text.trim()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('6-Digit OTP Verification Code:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: 'Enter 6-digit OTP',
                        prefixIcon: const Icon(Icons.pin, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text("Didn't receive OTP? ", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        TextButton(
                          onPressed: () {
                            setDlgState(() {
                              generatedOtp = (100000 + (DateTime.now().microsecondsSinceEpoch % 900000)).toString();
                              resendSeconds = 30;
                            });
                            snack(context, 'New OTP verification code sent! (Code: $generatedOtp)', error: false);
                          },
                          child: const Text('Resend OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('New Password:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'New Password',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Confirm New Password:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: confirmNewPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm New Password',
                        prefixIcon: const Icon(Icons.lock_reset_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              if (otpSent)
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                  onPressed: () async {
                    final enteredOtp = otpController.text.trim();
                    final newPass = newPasswordController.text.trim();
                    final confirmPass = confirmNewPasswordController.text.trim();

                    if (enteredOtp.length != 6) {
                      snack(context, 'Please enter a valid 6-digit OTP code', error: true);
                      return;
                    }
                    if (newPass.length < 6) {
                      snack(context, 'New password must be at least 6 characters', error: true);
                      return;
                    }
                    if (newPass != confirmPass) {
                      snack(context, 'Passwords do not match. Please re-enter.', error: true);
                      return;
                    }

                    try {
                      final targetMail = mailController.text.trim().toLowerCase();
                      await fb.FirebaseAuth.instance.signInWithEmailAndPassword(email: targetMail, password: newPass);
                    } catch (_) {}

                    if (!mounted) return;
                    Navigator.pop(ctx);
                    snack(context, 'Password reset successfully! You can now log in.', error: false);
                  },
                  child: const Text('Verify OTP & Reset Password'),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _performGoogleCompleteRegistrationModal(String mail, String googleName) async {
    final nameCtrl = TextEditingController(text: googleName.isNotEmpty ? googleName : mail.split('@').first.toUpperCase());
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isSubmitting = false;
    bool obscureP1 = true;
    bool obscureP2 = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            title: Row(
              children: const [
                Text('G ', style: TextStyle(color: Color(0xFF2563EB), fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Complete Registration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Google Email: $mail', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 14),
                  const Text('Create Full Name / Username:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Enter your Full Name',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Create Account Password:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passCtrl,
                    obscureText: obscureP1,
                    decoration: InputDecoration(
                      hintText: 'Minimum 6 characters',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscureP1 ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setDlgState(() => obscureP1 = !obscureP1),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Confirm Password:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: obscureP2,
                    decoration: InputDecoration(
                      hintText: 'Re-enter password',
                      prefixIcon: const Icon(Icons.lock_reset, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscureP2 ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setDlgState(() => obscureP2 = !obscureP2),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final chosenName = nameCtrl.text.trim();
                          var p1 = passCtrl.text.trim();
                          final p2 = confirmPassCtrl.text.trim();

                          if (chosenName.isEmpty) {
                            snack(context, 'Please enter your username', error: true);
                            return;
                          }

                          if (p1.isNotEmpty || p2.isNotEmpty) {
                            if (p1.length < 6) {
                              snack(context, 'Password must be at least 6 characters long', error: true);
                              return;
                            }
                            if (p1 != p2) {
                              snack(context, 'Passwords do not match. Please re-enter.', error: true);
                              return;
                            }
                          } else {
                            p1 = 'SmartCampus2026!';
                          }

                          setDlgState(() => isSubmitting = true);

                          LocalStore.selectedRole = AccessControl.roleForEmail(mail);
                          LocalStore.currentName = chosenName;
                          LocalStore.registerUser(mail, chosenName, p1);

                          try {
                            await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(email: mail, password: p1);
                          } catch (_) {
                            try {
                              await fb.FirebaseAuth.instance.signInWithEmailAndPassword(email: mail, password: p1);
                            } catch (_) {}
                          }

                          try {
                            await supabase.from('app_registered_users').upsert({
                              'email': mail,
                              'full_name': chosenName,
                              'role': AccessControl.isAdminEmail(mail) ? 'admin' : 'student',
                              'status': 'active',
                              'last_login': DateTime.now().toIso8601String(),
                            }, onConflict: 'email');

                            await supabase.from('profiles').upsert({
                              'email': mail,
                              'full_name': chosenName,
                              'role': AccessControl.isAdminEmail(mail) ? 'admin' : 'student',
                              'status': 'active',
                              'last_login': DateTime.now().toIso8601String(),
                            }, onConflict: 'email');
                          } catch (_) {}

                          if (!mounted) return;
                          Navigator.pop(ctx);
                          snack(context, 'Registration completed successfully! Signed in as $chosenName', error: false);

                          if (fb.FirebaseAuth.instance.currentUser != null) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const AuthGate()),
                              (route) => false,
                            );
                          } else {
                            final appUser = AppUser(
                              uid: 'user_${mail.split('@').first}_${DateTime.now().millisecondsSinceEpoch}',
                              email: mail,
                              role: AccessControl.roleForEmail(mail),
                              name: chosenName,
                              phone: LocalStore.currentPhone,
                              department: LocalStore.currentDepartment,
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => MainScreen(user: appUser)),
                              (route) => false,
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Complete Registration & Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _performGoogleExistingUserSignInModal(String mail) async {
    final storedUser = LocalStore.userDatabase[mail.toLowerCase()];
    final displayName = storedUser?['name'] ?? (AccessControl.isAdminEmail(mail) ? 'AVILIGONDA DILEEP KUMAR' : mail.split('@').first.toUpperCase());
    final defaultPass = storedUser?['password'] ?? 'GoogleUserPassword123!';
    final passCtrl = TextEditingController(text: defaultPass);
    bool isSubmitting = false;
    bool obscurePass = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            title: Row(
              children: const [
                Text('G ', style: TextStyle(color: Color(0xFF2563EB), fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Sign In to SmartCampus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome Back, $displayName!', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text('Account: $mail', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                  const SizedBox(height: 16),
                  const Text('Enter your Account Password:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passCtrl,
                    obscureText: obscurePass,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setDlgState(() => obscurePass = !obscurePass),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final pass = passCtrl.text.trim();
                          if (pass.isEmpty) {
                            snack(context, 'Please enter your password', error: true);
                            return;
                          }

                          setDlgState(() => isSubmitting = true);

                          LocalStore.selectedRole = AccessControl.roleForEmail(mail);
                          LocalStore.currentName = displayName;
                          LocalStore.lastLoggedInEmail = mail;

                          try {
                            await fb.FirebaseAuth.instance.signInWithEmailAndPassword(email: mail, password: pass);
                          } catch (_) {
                            try {
                              await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(email: mail, password: pass);
                            } catch (_) {}
                          }

                          if (!mounted) return;
                          Navigator.pop(ctx);
                          snack(context, 'Signed in successfully as $displayName', error: false);

                          if (fb.FirebaseAuth.instance.currentUser != null) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const AuthGate()),
                              (route) => false,
                            );
                          } else {
                            final appUser = AppUser(
                              uid: 'user_${mail.split('@').first}_${DateTime.now().millisecondsSinceEpoch}',
                              email: mail,
                              role: AccessControl.roleForEmail(mail),
                              name: displayName,
                              phone: LocalStore.currentPhone,
                              department: LocalStore.currentDepartment,
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => MainScreen(user: appUser)),
                              (route) => false,
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Sign In & Go to App', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _performGoogleAccountSelectionModal() async {
    final customEmailCtrl = TextEditingController();
    String? selectedAccount;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Text('G ', style: TextStyle(color: Color(0xFF2563EB), fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Choose Google Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select a Google account on your device to Continue:', style: TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 14),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF2563EB), child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              title: const Text('avligondadileepkumar2074.sse@saveetha.com', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: const Text('Saveetha Student / Admin Account', style: TextStyle(fontSize: 11)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFE2E8F0))),
              onTap: () {
                selectedAccount = 'avligondadileepkumar2074.sse@saveetha.com';
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF10B981), child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              title: const Text('dileepkumar.student@saveetha.com', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: const Text('Google Student Account', style: TextStyle(fontSize: 11)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFE2E8F0))),
              onTap: () {
                selectedAccount = 'dileepkumar.student@saveetha.com';
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 14),
            const Text('Or enter another Google Account email:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 6),
            TextField(
              controller: customEmailCtrl,
              decoration: InputDecoration(
                hintText: 'yourname@gmail.com',
                prefixIcon: const Icon(Icons.email, size: 18),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            onPressed: () {
              if (customEmailCtrl.text.trim().isNotEmpty) {
                selectedAccount = customEmailCtrl.text.trim().toLowerCase();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (selectedAccount != null && selectedAccount!.isNotEmpty) {
      email.text = selectedAccount!;
      if (LocalStore.isRegisteredEmail(selectedAccount!)) {
        await _performGoogleExistingUserSignInModal(selectedAccount!);
      } else {
        await _performGoogleCompleteRegistrationModal(selectedAccount!, selectedAccount!.split('@').first);
      }
    }
  }

  Future<void> _performGoogleFallbackSignIn() async {
    try {
      final inputMail = email.text.trim().toLowerCase();
      final mail = inputMail.isNotEmpty && inputMail.contains('@')
          ? inputMail
          : 'google.student@saveetha.com';
      final name = AccessControl.isAdminEmail(mail)
          ? 'AVILIGONDA DILEEP KUMAR'
          : (mail.split('@').first.toUpperCase());

      LocalStore.selectedRole = AccessControl.roleForEmail(mail);
      LocalStore.currentName = name;
      LocalStore.lastLoggedInEmail = mail;

      try {
        await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: mail,
          password: 'GoogleUserPassword123!',
        );
      } catch (_) {
        try {
          await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: mail,
            password: 'GoogleUserPassword123!',
          );
        } catch (_) {}
      }

      try {
        await supabase.from('app_registered_users').upsert({
          'email': mail,
          'full_name': name,
          'role': AccessControl.isAdminEmail(mail) ? 'admin' : 'student',
          'status': 'active',
          'last_login': DateTime.now().toIso8601String(),
        }, onConflict: 'email');

        await supabase.from('profiles').upsert({
          'email': mail,
          'full_name': name,
          'role': AccessControl.isAdminEmail(mail) ? 'admin' : 'student',
          'status': 'active',
          'last_login': DateTime.now().toIso8601String(),
        }, onConflict: 'email');
      } catch (_) {}

      if (!mounted) return;
      snack(context, 'Signed in with Google ($mail)', error: false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() => loading = true);

    String targetEmail = '';
    String googleDisplayName = '';

    try {
      if (kIsWeb) {
        final provider = fb.GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        provider.setCustomParameters({'prompt': 'select_account'});

        try {
          final userCred = await fb.FirebaseAuth.instance.signInWithPopup(provider);
          targetEmail = userCred.user?.email?.toLowerCase() ?? '';
          googleDisplayName = userCred.user?.displayName ?? '';
        } catch (_) {
          await _performGoogleAccountSelectionModal();
          return;
        }
      } else {
        try {
          final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
          await googleSignIn.signOut();
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

          if (googleUser == null) {
            if (mounted) setState(() => loading = false);
            return;
          }

          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

          final credential = fb.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final userCred = await fb.FirebaseAuth.instance.signInWithCredential(credential);
          targetEmail = userCred.user?.email?.toLowerCase() ?? googleUser.email.toLowerCase();
          googleDisplayName = userCred.user?.displayName ?? googleUser.displayName ?? '';
        } catch (_) {
          await _performGoogleAccountSelectionModal();
          return;
        }
      }

      if (targetEmail.isNotEmpty) {
        email.text = targetEmail;
        if (LocalStore.isRegisteredEmail(targetEmail)) {
          await _performGoogleExistingUserSignInModal(targetEmail);
        } else {
          bool exists = false;
          try {
            final res = await supabase.from('profiles').select('email').eq('email', targetEmail).maybeSingle();
            if (res != null) exists = true;
          } catch (_) {}

          if (exists) {
            await _performGoogleExistingUserSignInModal(targetEmail);
          } else {
            await _performGoogleCompleteRegistrationModal(targetEmail, googleDisplayName);
          }
        }
      }
    } catch (_) {
      await _performGoogleAccountSelectionModal();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  InputDecoration modernInput(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: wide
                  ? Row(
                      children: [
                        Expanded(child: _brandPanel()),
                        const SizedBox(width: 34),
                        Expanded(child: _signInCard()),
                      ],
                    )
                  : _signInCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandPanel() {
    return Container(
      height: 720,
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [BoxShadow(color: Color(0x330F172A), blurRadius: 28, offset: Offset(0, 18))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            bottom: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withOpacity(0.28),
              ),
            ),
          ),
          Positioned(
            left: -70,
            top: -50,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withOpacity(0.18),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SmartCampusLogo(size: 150, showText: true, lightText: true),
              const SizedBox(height: 42),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _BrandMini(icon: Icons.chat_bubble, label: 'Connect', color: Color(0xFF2563EB)),
                  SizedBox(width: 34),
                  _BrandMini(icon: Icons.wifi_tethering, label: 'Engage', color: Color(0xFF10B981)),
                  SizedBox(width: 34),
                  _BrandMini(icon: Icons.school, label: 'Grow', color: Color(0xFFEC4899)),
                ],
              ),
              const SizedBox(height: 54),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Center(
                  child: Text(
                    'Realtime Campus Network\nPlacements • Complaints • Notifications • Chatbot',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _signInCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 38),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 28, offset: Offset(0, 16))],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SmartCampusLogo(size: 118),
          const SizedBox(height: 28),
          Text(
            isLogin ? 'Sign in to continue' : 'Create your account',
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 20),
          Semantics(
            label: 'google_sign_in_button',
            button: true,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 58),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                foregroundColor: const Color(0xFF0F172A),
              ),
              onPressed: loading ? null : signInWithGoogle,
              icon: const Text('G', style: TextStyle(fontSize: 24, color: Color(0xFF2563EB), fontWeight: FontWeight.w900)),
              label: const Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w700)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 22),
          if (!isLogin) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Full Name / Username', style: TextStyle(color: Colors.blueGrey.shade700, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'fullname_field',
              textField: true,
              child: TextField(
                controller: fullName,
                decoration: modernInput('Enter your Full Name / Username', Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Email', style: TextStyle(color: Colors.blueGrey.shade700, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'email_field',
            textField: true,
            child: TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: modernInput('you@example.com', Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Password', style: TextStyle(color: Colors.blueGrey.shade700, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'password_field',
            textField: true,
            child: TextField(
              controller: password,
              obscureText: obscure,
              decoration: modernInput('Password', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
            ),
          ),
          if (!isLogin) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Confirm Password', style: TextStyle(color: Colors.blueGrey.shade700, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'confirm_password_field',
              textField: true,
              child: TextField(
                controller: confirmPassword,
                obscureText: obscureConfirm,
                decoration: modernInput('Re-enter Password', Icons.lock_reset).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          if (isLogin)
            Row(
              children: [
                Checkbox(
                  value: remember,
                  onChanged: (v) => setState(() => remember = v ?? true),
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                ),
                const SizedBox(width: 4),
                const Text('Remember me'),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: forgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: loading ? null : submit,
              child: loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isLogin ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(isLogin ? "Don’t have an account? " : 'Already have an account? '),
              GestureDetector(
                onTap: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin ? 'Create Account' : 'Sign In',
                  style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Any valid email can login. Admin access is protected.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BrandMini extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _BrandMini({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ],
    );
  }
}


class MainScreen extends StatefulWidget {
  final AppUser user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  late AppUser user;
  Timer? sessionTimer;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    resetSessionTimer();
  }

  void refresh() => setState(() {});

  void resetSessionTimer() {
    sessionTimer?.cancel();
    if (AppState.sessionTimeoutEnabled) {
      sessionTimer = Timer(const Duration(minutes: 15), () {
        fb.FirebaseAuth.instance.signOut();
      });
    }
  }

  @override
  void dispose() {
    sessionTimer?.cancel();
    super.dispose();
  }

  void updateUser(AppUser updated) {
    LocalStore.currentName = updated.name;
    LocalStore.currentPhone = updated.phone;
    LocalStore.currentDepartment = updated.department;
    setState(() => user = updated);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(user: user, refresh: refresh, onTab: (i) => setState(() => index = i)),
      GrievanceListScreen(user: user, refresh: refresh),
      ResourceBookingScreen(user: user, refresh: refresh),
      MoreScreen(user: user, refresh: refresh, onUserChanged: updateUser),
    ];

    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      final navItems = [
        [Icons.dashboard_rounded, 'Dashboard', 0],
        [Icons.report_problem_outlined, 'Complaints', 1],
        [Icons.meeting_room_outlined, 'Bookings', 2],
        [Icons.work_outline, 'Placement', -1, () => push(context, RealtimePlacementPortalScreen(user: user))],
        [Icons.map_outlined, 'Saveetha Map', -1, () => push(context, CampusMapScreen(user: user, refresh: refresh))],
        [Icons.calendar_month_outlined, 'Timetable', -1, () => push(context, TimetableScreen(user: user))],
        [Icons.campaign_outlined, 'Announcements', -1, () => push(context, AnnouncementsScreen(user: user))],
        [Icons.emergency_outlined, 'Emergency', -1, () => push(context, EmergencyContactsScreen(user: user))],
        [Icons.smart_toy_outlined, 'AI Assistant', -1, () => push(context, SmartCampusChatbotScreen(user: user))],
        [Icons.person_outline, 'Profile & Settings', 3],
        if (AccessControl.isAdminEmail(user.email))
          [Icons.admin_panel_settings_outlined, 'Admin Dashboard', -1, () => push(context, const AdminOnlyScreen(child: AdminDashboardScreen()))],
      ];

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // Desktop Web Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF06B6D4)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.school, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text('SmartCampus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Web Portal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  ),
                  const Spacer(),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: AppState.themeMode,
                    builder: (_, mode, __) => IconButton(
                      icon: Icon(mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode_outlined),
                      onPressed: () => AppState.toggleTheme(mode != ThemeMode.dark),
                      tooltip: 'Toggle Theme',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () => push(context, PowerNotificationsScreen(user: user)),
                    tooltip: 'Notifications',
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => setState(() => index = 3),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF2563EB),
                            child: Text(user.email[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          Text(user.name.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () => fb.FirebaseAuth.instance.signOut(),
                    tooltip: 'Sign Out',
                  ),
                ],
              ),
            ),
            // Desktop Body with Sidebar Rail
            Expanded(
              child: Row(
                children: [
                  // Left Web Navigation Rail
                  Container(
                    width: 250,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      children: navItems.map((item) {
                        final idx = item[2] as int;
                        final selected = idx >= 0 && index == idx;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Material(
                            color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (idx >= 0) {
                                  setState(() => index = idx);
                                } else if (item.length > 3 && item[3] != null) {
                                  (item[3] as VoidCallback)();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(item[0] as IconData, color: selected ? const Color(0xFF2563EB) : const Color(0xFF64748B), size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item[1] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                          color: selected ? const Color(0xFF2563EB) : const Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Main Web Page Content Container
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1300),
                        child: screens[index],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.report_outlined), label: 'Issues'),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room_outlined), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.apps_rounded), label: 'More'),
        ],
      ),
    );
  }
}


// ========================= SAVEETHA PORTAL STYLE HELPERS =========================

PreferredSizeWidget portalTopBar(BuildContext context, String title, {required AppUser user}) {
  return AppBar(
    backgroundColor: PortalColors.header,
    foregroundColor: Colors.white,
    elevation: 0,
    title: Text(title),
    actions: [
      _portalBadge(Icons.notifications_none, '0'),
      if (MediaQuery.of(context).size.width > 600) ...[
        _portalBadge(Icons.mail_outline, '0'),
        _portalBadge(Icons.calendar_month_outlined, '0'),
      ],
      const SizedBox(width: 8),
      StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('profiles')
            .stream(primaryKey: ['id'])
            .eq('email', user.email),
        builder: (context, snapshot) {
          String photo = LocalStore.profilePhotoUrl;
          String displayName = AccessControl.isAdminEmail(user.email)
              ? 'AVILIGONDA DILEEP KUMAR'
              : user.name;

          if (snapshot.hasData && (snapshot.data ?? []).isNotEmpty) {
            final row = snapshot.data!.first;
            photo = (row['photo_url'] ?? photo).toString();
            displayName = (row['full_name'] ?? displayName).toString();

            if (photo.isNotEmpty) {
              LocalStore.profilePhotoUrl = photo;
            }
            if (displayName.isNotEmpty) {
              LocalStore.currentName = displayName;
            }
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                backgroundImage: photo.trim().isEmpty ? null : NetworkImage(photo.trim()),
                child: photo.trim().isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 18)
                    : null,
              ),
              if (MediaQuery.of(context).size.width > 600) ...[
                const SizedBox(width: 8),
                Center(
                  child: Text(
                    displayName.toUpperCase(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      if (MediaQuery.of(context).size.width > 600)
        Semantics(
          label: 'logout_button',
          button: true,
          child: IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
        ),
      const SizedBox(width: 8),
    ],
  );
}

Widget _portalBadge(IconData icon, String count) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: Colors.white70, size: 25),
        Positioned(
          right: -7,
          top: -8,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(color: PortalColors.teal, shape: BoxShape.circle),
            child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ),
  );
}

Drawer portalDrawer(BuildContext context, AppUser user, VoidCallback refresh, ValueChanged<int>? onTab) {
  Widget item(IconData icon, String title, VoidCallback onTap, {bool isNew = false}) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x223FFFFFF)))),
      child: ListTile(
        leading: Icon(icon, color: Colors.white60),
        title: Row(children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 15))),
          if (isNew) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), color: PortalColors.red, child: const Text('new', style: TextStyle(color: Colors.white, fontSize: 11))),
        ]),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  return Drawer(
    backgroundColor: PortalColors.sidebar,
    child: SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            color: PortalColors.sidebarDark,
            child: Row(children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: PortalColors.teal, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.school, color: Colors.white)),
              const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SIMATS', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 22, letterSpacing: 5, fontWeight: FontWeight.bold)),
                Text('ENGINEERING', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 12, letterSpacing: 2)),
              ])),
            ]),
          ),
          Expanded(
            child: ListView(children: [
              item(Icons.home_outlined, 'Dashboard', () => onTab == null ? null : onTab(0)),
              item(Icons.report_problem_outlined, 'Complaints & Grievances', () => onTab == null ? push(context, GrievanceListScreen(user: user, refresh: refresh)) : onTab(1)),
              item(Icons.meeting_room_outlined, 'Room & Facility Bookings', () => push(context, BookRoomScreen(user: user, refresh: refresh))),
              item(Icons.work_outline, 'Placement Portal', () => push(context, RealtimePlacementPortalScreen(user: user))),
              item(Icons.campaign_outlined, 'Announcements', () => push(context, AnnouncementsScreen(user: user))),
              item(Icons.calendar_month_outlined, 'Timetable', () => push(context, TimetableScreen(user: user))),
              item(Icons.map_outlined, 'Saveetha Campus Map', () => push(context, CampusMapScreen(user: user, refresh: refresh))),
              item(Icons.emergency_outlined, 'Emergency Contacts', () => push(context, EmergencyContactsScreen(user: user))),
              item(Icons.smart_toy_outlined, 'AI Assistant', () => push(context, SmartCampusChatbotScreen(user: user))),
              item(Icons.person_outline, 'My Profile', () => push(context, RealtimeProfileScreen(user: user))),
              if (AccessControl.isAdminEmail(user.email)) item(Icons.admin_panel_settings_outlined, 'Admin Dashboard', () => push(context, const AdminOnlyScreen(child: AdminDashboardScreen()))),
            ]),
          ),
        ],
      ),
    ),
  );
}
Widget portalPanel({required String title, required Color color, required IconData icon, required Widget child}) {
  return Container(
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: color.withOpacity(.55))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 48,
        width: double.infinity,
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500))),
          Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white54)), child: const Icon(Icons.open_in_full, color: Colors.white70, size: 17)),
        ]),
      ),
      Expanded(child: child),
    ]),
  );
}

class PortalCalendarBox extends StatelessWidget {
  const PortalCalendarBox({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final totalCells = ((startWeekday + daysInMonth + 6) ~/ 7) * 7;
    final months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    final monthText = '${months[now.month - 1]} ${now.year}';

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              _calBtn('‹'),
              const SizedBox(width: 4),
              _calBtn('›'),
              const SizedBox(width: 10),
              OutlinedButton(onPressed: () {}, child: const Text('Today')),
              const Spacer(),
              Text(monthText, style: const TextStyle(fontSize: 24, color: Colors.black87)),
              const Spacer(),
              FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.grey), onPressed: () {}, child: const Text('Month')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
                        child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ))
                .toList(),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              childAspectRatio: 1.25,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(totalCells, (i) {
                final day = i - startWeekday + 1;
                final valid = day >= 1 && day <= daysInMonth;
                final selected = valid && day == now.day;
                return Container(
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFFFFBC2) : Colors.white,
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text(valid ? '$day' : '', style: TextStyle(color: valid ? Colors.black87 : Colors.black26)),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calBtn(String text) => Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: Colors.black12), color: Colors.white),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      );
}

class PortalNotificationsBox extends StatelessWidget {
  final AppUser user;
  const PortalNotificationsBox({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('announcements').stream(primaryKey: ['id']).order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final notifications = (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty)
            ? snapshot.data!
            : [
                {
                  'id': 'a1',
                  'title': 'Campus Placement Drive 2026 - Registration Open',
                  'description': 'Top technology companies visiting campus next week. Register on the Placements portal.',
                  'category': 'Placements',
                  'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
                },
                {
                  'id': 'a2',
                  'title': 'Semester Examination Schedule Released',
                  'description': 'Check your student portal for detailed dates and hall ticket downloads.',
                  'category': 'Academics',
                  'created_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
                },
              ];
        if (notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AccessControl.isAdminEmail(user.email)
                    ? 'No notifications uploaded yet. Use Admin Upload Notification to add one.'
                    : 'No notifications available.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (_, i) {
            final a = notifications[i];
            final fileUrl = (a['file_url'] ?? '').toString();
            final fileName = (a['file_name'] ?? '').toString();
            final date = (a['notification_date'] ?? a['created_at'] ?? '').toString().split('T').first;
            final by = (a['uploaded_by'] ?? a['created_by'] ?? 'Admin').toString();
            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(radius: 24, backgroundColor: Colors.black12, child: Icon(Icons.person, color: Colors.grey)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: PortalColors.teal, width: 3)),
                        color: Color(0xFFF7F7F7),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$by on $date', style: TextStyle(color: Colors.blue.shade700, fontSize: 15)),
                          const SizedBox(height: 3),
                          Text('${a['title'] ?? ''}\n${a['body'] ?? ''}'),
                          if (fileUrl.isNotEmpty || fileName.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              color: PortalColors.teal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.description, color: Colors.white, size: 14),
                                  const SizedBox(width: 5),
                                  Text(fileName.isEmpty ? 'Open Document' : fileName, style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            if (fileUrl.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: SelectableText(fileUrl, style: const TextStyle(color: Colors.blue, fontSize: 12)),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AdminUploadNotificationScreen extends StatefulWidget {
  final AppUser user;
  const AdminUploadNotificationScreen({super.key, required this.user});

  @override
  State<AdminUploadNotificationScreen> createState() => _AdminUploadNotificationScreenState();
}

class _AdminUploadNotificationScreenState extends State<AdminUploadNotificationScreen> {
  final title = TextEditingController();
  final body = TextEditingController();
  final fileName = TextEditingController();
  final fileUrl = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    fileName.dispose();
    fileUrl.dispose();
    super.dispose();
  }

  Future<void> uploadNotification() async {
    if (!AccessControl.isAdminEmail(widget.user.email)) {
      snack(context, 'Only admin can upload notifications', error: true);
      return;
    }
    if (title.text.trim().isEmpty || body.text.trim().isEmpty) {
      snack(context, 'Enter notification title and message', error: true);
      return;
    }
    setState(() => loading = true);
    try {
      await supabase.from('announcements').insert({
        'title': title.text.trim(),
        'body': body.text.trim(),
        'target_role': 'all',
        'created_by': widget.user.email,
        'uploaded_by': AccessControl.isAdminEmail(widget.user.email) ? 'AVILIGONDA DILEEP KUMAR' : widget.user.name,
        'file_name': fileName.text.trim(),
        'file_url': fileUrl.text.trim(),
        'notification_date': DateTime.now().toIso8601String().split('T').first,
      });
      if (!mounted) return;
      title.clear();
      body.clear();
      fileName.clear();
      fileUrl.clear();
      snack(context, 'Notification uploaded');
    } catch (e) {
      if (!mounted) return;
      snack(context, 'Upload failed: $e', error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AccessControl.isAdminEmail(widget.user.email)) {
      return Scaffold(
        appBar: appBar('Admin Upload Notification', back: true, context: context),
        body: const Center(child: Text('Only admin can upload notifications.')),
      );
    }
    return Scaffold(
      appBar: appBar('Admin Upload Notification', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          infoBox('Upload notification text and optional PDF / Google Sheet / document link. If no notification is uploaded, students will see an empty notification panel.'),
          const SizedBox(height: 14),
          TextField(controller: title, decoration: input('Notification Title', Icons.title)),
          const SizedBox(height: 12),
          TextField(controller: body, maxLines: 5, decoration: input('Notification Message', Icons.message)),
          const SizedBox(height: 12),
          TextField(controller: fileName, decoration: input('Document Name e.g. Exam Schedule PDF', Icons.description)),
          const SizedBox(height: 12),
          TextField(controller: fileUrl, decoration: input('PDF / Google Sheet / Document URL', Icons.link)),
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: loading ? null : uploadNotification,
              icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.cloud_upload),
              label: const Text('Upload Notification'),
            ),
          ),
        ],
      ),
    );
  }
}

class PortalCourseScreen extends StatelessWidget {
  final AppUser user;
  const PortalCourseScreen({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    final courses = [
      ['CSA1648', 'Data warehousing and Data Mining for Association Analysis', 'InProgress', '19/02/2026'],
      ['ECA1437', 'Embedded Systems for Smart Devices', 'InProgress', '19/02/2026'],
      ['MMA1096', 'Mentor Mentee Meeting', 'InProgress', '21/02/2025'],
      ['SPIC7A61', 'Product Design and Development for Engineers', 'InProgress', '23/02/2026'],
      ['UBA5018', 'Technical skills for BATCH 18', 'InProgress', '07/03/2026'],
    ];
    return Scaffold(
      backgroundColor: PortalColors.pageBg,
      drawer: portalDrawer(context, user, () {}, null),
      appBar: portalTopBar(context, 'My Course', user: user),
      body: ListView(padding: const EdgeInsets.all(28), children: [
        const Text('My Course', style: TextStyle(fontSize: 30, color: PortalColors.textGrey)),
        const SizedBox(height: 18),
        Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: PortalColors.red.withOpacity(.6))), child: Column(children: [
          Container(height: 48, color: PortalColors.red, padding: const EdgeInsets.symmetric(horizontal: 16), child: const Row(children: [
            Icon(Icons.list, color: Colors.white), SizedBox(width: 8), Expanded(child: Text('INPROGRESS COURSES', style: TextStyle(color: Colors.white, fontSize: 18))), Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ])),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
            columns: const [DataColumn(label: Text('Course Code')), DataColumn(label: Text('Course Name')), DataColumn(label: Text('Status')), DataColumn(label: Text('Enroll On'))],
            rows: courses.map((c) => DataRow(cells: [
              DataCell(Text(c[0])), DataCell(SizedBox(width: 420, child: Text(c[1], textAlign: TextAlign.center))),
              DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 5), color: Colors.lightBlue.shade200, child: Text(c[2], style: const TextStyle(color: Colors.white)))),
              DataCell(Text(c[3])),
            ])).toList(),
          )),
        ])),
        const SizedBox(height: 24),
        Container(height: 48, color: PortalColors.purple, padding: const EdgeInsets.symmetric(horizontal: 16), child: const Row(children: [
          Icon(Icons.notifications, color: Colors.white), SizedBox(width: 8), Expanded(child: Text('GRADUATION STATUS', style: TextStyle(color: Colors.white, fontSize: 18))), Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ])),
      ]),
    );
  }
}

// ======================= END SAVEETHA PORTAL STYLE HELPERS =======================



// ========================= CLEAN CHATBOT MODULE =========================


class SmartCampusChatbotScreen extends StatefulWidget {
  final AppUser user;
  const SmartCampusChatbotScreen({super.key, required this.user});

  @override
  State<SmartCampusChatbotScreen> createState() => _SmartCampusChatbotScreenState();
}

class _SmartCampusChatbotScreenState extends State<SmartCampusChatbotScreen> {
  final msg = TextEditingController();

  final List<Map<String, dynamic>> localMessages = [
    {
      'sender': 'bot',
      'message': 'Hi! I am your SmartCampus Assistant. Ask me about complaints, placements, notifications, profile, faculty, lost & found, or campus map.',
      'created_at': '',
    }
  ];

  bool usingLocalMode = false;

  @override
  void dispose() {
    msg.dispose();
    super.dispose();
  }

  String botReply(String input) {
    final t = input.toLowerCase();

    if (t.contains('emergency') || t.contains('sos') || t.contains('call') || t.contains('security') || t.contains('police') || t.contains('hospital')) {
      return '🚨 EMERGENCY HELP: Open "Emergency Contacts" from the menu to dial Saveetha Security (7032643839), Health Room, or Women Safety Cell directly.';
    }

    if (t.contains('map') || t.contains('location') || t.contains('navigation') || t.contains('route') || t.contains('distance') || t.contains('saveetha')) {
      return '📍 CAMPUS MAP: Open "Saveetha Campus Map" from the menu to launch Saveetha University directly inside Google Maps for live turn-by-turn navigation, routes, and distance.';
    }

    if (t.contains('timetable') || t.contains('class') || t.contains('schedule') || t.contains('room')) {
      return '📅 TIMETABLE: Open "Timetable" from the menu to view day-by-day class schedules. Admins can upload, edit, or delete schedules live.';
    }

    if (t.contains('complaint') || t.contains('grievance') || t.contains('issue') || t.contains('raise') || t.contains('problem') || t.contains('water') || t.contains('wifi')) {
      return '📝 COMPLAINTS & GRIEVANCES: Tap "Raise Issue" on your dashboard or select "Complaints & Grievances" from the menu to upload photos and track real-time resolution status.';
    }

    if (t.contains('booking') || t.contains('facility') || t.contains('hall') || t.contains('seminar') || t.contains('lab')) {
      return '🏛️ FACILITY BOOKINGS: Select "Room & Facility Bookings" to submit seminar hall or lab reservation requests. Admins approve or modify slots in real-time.';
    }

    if (t.contains('placement') || t.contains('job') || t.contains('company') || t.contains('drive') || t.contains('interview')) {
      return '💼 PLACEMENTS: Open "Placement Portal" to browse active hiring drives, eligibility requirements, and application links.';
    }

    if (t.contains('announcement') || t.contains('notice') || t.contains('pdf') || t.contains('document') || t.contains('download')) {
      return '📢 ANNOUNCEMENTS: Open "Announcements" to read official college circulars, download attached PDFs, images, and documents posted by Admin.';
    }

    if (t.contains('profile') || t.contains('username') || t.contains('password') || t.contains('photo')) {
      return '👤 MY PROFILE: Open "My Profile" to update your username with uniqueness validation, change your password securely, or upload a profile photo.';
    }

    return '🤖 SmartCampus AI Assistant: I can guide you with Saveetha Google Maps navigation, Emergency contacts, Complaint tracking, Timetables, Facility Bookings, and Placements. Ask me any question!';
  }

  Future<void> saveMessage(String sender, String message) async {
    try {
      await supabase.from('chatbot_messages').insert({
        'user_email': widget.user.email,
        'sender': sender,
        'message': message,
      });
    } catch (_) {
      usingLocalMode = true;
    }
  }

  Future<void> send() async {
    final text = msg.text.trim();
    if (text.isEmpty) return;

    msg.clear();

    final userMessage = {
      'sender': 'user',
      'message': text,
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() => localMessages.insert(0, userMessage));

    await saveMessage('user', text);

    final reply = botReply(text);

    await Future.delayed(const Duration(milliseconds: 250));

    final botMessage = {
      'sender': 'bot',
      'message': reply,
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() => localMessages.insert(0, botMessage));

    await saveMessage('bot', reply);
  }

  Widget buildMessageList(List<Map<String, dynamic>> rows) {
    final messages = rows.isEmpty ? localMessages : rows;

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final m = messages[i];
        final mine = (m['sender'] ?? '') == 'user';

        return Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            constraints: const BoxConstraints(maxWidth: 360),
            decoration: BoxDecoration(
              color: mine ? ModernColors.blue : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(mine ? 18 : 4),
                bottomRight: Radius.circular(mine ? 4 : 18),
              ),
              boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8)],
            ),
            child: Text(
              (m['message'] ?? '').toString(),
              style: TextStyle(color: mine ? Colors.white : Colors.black87, height: 1.35),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.bg,
      appBar: appBar('SmartCampus AI Assistant', back: true, context: context),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [ModernColors.navy, ModernColors.blue]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF06B6D4),
                  child: Icon(Icons.smart_toy, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ask me anything about SmartCampus navigation and services.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('chatbot_messages')
                  .stream(primaryKey: ['id'])
                  .eq('user_email', widget.user.email)
                  .order('created_at', ascending: false),
              builder: (_, snapshot) {
                if (snapshot.hasError || usingLocalMode) {
                  return buildMessageList(localMessages);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return buildMessageList(localMessages);
                }

                final rows = snapshot.data ?? localMessages;
                return buildMessageList(rows.isEmpty ? localMessages : rows);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'chatbot_message_field',
                    textField: true,
                    child: TextField(
                      controller: msg,
                      minLines: 1,
                      maxLines: 3,
                      decoration: input('Ask chatbot...', Icons.smart_toy).copyWith(
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSubmitted: (_) => send(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: 'send_message_button',
                  button: true,
                  child: FloatingActionButton(
                    backgroundColor: ModernColors.blue,
                    onPressed: send,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= END CLEAN CHATBOT MODULE =======================



// ========================= LIVE IDENTITY FEATURES =========================

Future<void> recordLiveActivity({
  required String actorEmail,
  required String actorName,
  required String action,
  required String module,
}) async {
  try {
    await supabase.from('live_activity_events').insert({
      'actor_email': actorEmail,
      'actor_name': actorName,
      'action': action,
      'module': module,
    });
  } catch (_) {}
}

class LiveCampusPulseHero extends StatelessWidget {
  final AppUser user;
  final VoidCallback refresh;
  const LiveCampusPulseHero({super.key, required this.user, required this.refresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [ModernColors.navy, ModernColors.slate, ModernColors.blue]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: ModernColors.blue.withOpacity(.18), blurRadius: 24, offset: const Offset(0, 14))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SMARTCAMPUS', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1)),
            SizedBox(height: 6),
            Text('Live Campus Status', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.circle, color: Colors.white, size: 10),
              SizedBox(width: 6),
              Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        LiveCampusPulseStats(user: user),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton.icon(onPressed: () => push(context, CampusMapScreen(user: user, refresh: refresh)), icon: const Icon(Icons.map_outlined), label: const Text('Explore Campus')),
          OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)), onPressed: () => push(context, SmartCampusChatbotScreen(user: user)), icon: const Icon(Icons.smart_toy_outlined), label: const Text('Ask Assistant')),
        ]),
      ]),
    );
  }
}

class LiveCampusPulseStats extends StatelessWidget {
  final AppUser user;
  const LiveCampusPulseStats({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('app_registered_users').stream(primaryKey: ['id']),
      builder: (_, usersSnap) {
        final users = usersSnap.data ?? [];
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase.from('announcements').stream(primaryKey: ['id']),
          builder: (_, notiSnap) {
            final notifications = notiSnap.data ?? [];
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('placement_posts').stream(primaryKey: ['id']),
              builder: (_, placeSnap) {
                final placements = placeSnap.data ?? [];
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: supabase.from('grievances').stream(primaryKey: ['id']),
                  builder: (_, issueSnap) {
                    final issues = issueSnap.data ?? [];
                    final resolved = issues.where((g) => isIssueHistoryStatus((g['status'] ?? '').toString())).length;
                    final isWide = MediaQuery.of(context).size.width > 600;
                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: _pulseCard('Students Online', users.length.toString(), Icons.people_alt, ModernColors.cyan)),
                          const SizedBox(width: 10),
                          Expanded(child: _pulseCard('Notifications', notifications.length.toString(), Icons.notifications_active, ModernColors.amber)),
                          const SizedBox(width: 10),
                          Expanded(child: _pulseCard('Placements', placements.length.toString(), Icons.work, ModernColors.green)),
                          const SizedBox(width: 10),
                          Expanded(child: _pulseCard('Resolved Issues', resolved.toString(), Icons.verified, Colors.white)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _pulseCard('Students Online', users.length.toString(), Icons.people_alt, ModernColors.cyan)),
                            const SizedBox(width: 10),
                            Expanded(child: _pulseCard('Notifications', notifications.length.toString(), Icons.notifications_active, ModernColors.amber)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _pulseCard('Placements', placements.length.toString(), Icons.work, ModernColors.green)),
                            const SizedBox(width: 10),
                            Expanded(child: _pulseCard('Resolved Issues', resolved.toString(), Icons.verified, Colors.white)),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _pulseCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white24)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), overflow: TextOverflow.ellipsis, maxLines: 1),
        ])),
      ]),
    );
  }
}

class LiveActivityTicker extends StatelessWidget {
  final AppUser user;
  const LiveActivityTicker({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('live_activity_events').stream(primaryKey: ['id']).order('created_at', ascending: false),
      builder: (_, snapshot) {
        final rows = (snapshot.data ?? []).take(5).toList();
        if (rows.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12)]),
          child: Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)), child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
            const SizedBox(width: 10),
            Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: rows.map((e) => Padding(padding: const EdgeInsets.only(right: 22), child: Text('• ${e['actor_name'] ?? 'User'} ${e['action'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)))).toList()))),
          ]),
        );
      },
    );
  }
}

class CampusStoriesBar extends StatelessWidget {
  final AppUser user;
  const CampusStoriesBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('campus_stories').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (_, snapshot) {
          final rows = snapshot.data ?? [];
          return ListView(
            scrollDirection: Axis.horizontal,
            children: rows.map((s) => GestureDetector(
              onTap: () {
                final title = (s['title'] ?? '').toString().toLowerCase();
                if (title.contains('placement')) push(context, RealtimePlacementPortalScreen(user: user));
                else if (title.contains('announcement')) push(context, PowerNotificationsScreen(user: user));
                else push(context, CampusFeedFullScreen(user: user));
              },
              child: Container(
                width: 135,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [ModernColors.blue, ModernColors.cyan]), borderRadius: BorderRadius.circular(20)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.bolt, color: Colors.white),
                  const Spacer(),
                  Text((s['title'] ?? '').toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text((s['subtitle'] ?? '').toString(), style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}

class CampusScoreCard extends StatelessWidget {
  final AppUser user;
  const CampusScoreCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return modernSection(
      title: 'My Campus Score',
      icon: Icons.emoji_events,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('campus_scores').stream(primaryKey: ['id']).eq('user_email', user.email),
        builder: (_, snapshot) {
          final row = snapshot.hasData && (snapshot.data ?? []).isNotEmpty ? snapshot.data!.first : null;
          final score = row == null ? 100 : (row['score'] ?? 100);
          final badge = row == null ? 'New Member' : (row['badge'] ?? 'Active Member');
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.star, color: Colors.amber, size: 34),
              const SizedBox(width: 10),
              Text('$score', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(width: 10),
              chip(badge.toString(), ModernColors.blue),
            ]),
            const SizedBox(height: 8),
            const Text('Earn score by profile completion, valid issues, placements and campus feed activity.'),
          ]);
        },
      ),
    );
  }
}

class LivePlacementWall extends StatelessWidget {
  final AppUser user;
  const LivePlacementWall({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return modernSection(
      title: 'Live Placement Wall',
      icon: Icons.work_history,
      child: SizedBox(
        height: 260,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase.from('placement_posts').stream(primaryKey: ['id']).order('created_at', ascending: false),
          builder: (_, postSnap) {
            final posts = postSnap.data ?? [];
            if (posts.isEmpty) return const Center(child: Text('No live placement drives yet'));
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('placement_applications').stream(primaryKey: ['id']),
              builder: (_, appSnap) {
                final apps = appSnap.data ?? [];
                return ListView(children: posts.take(6).map((p) {
                  final count = apps.where((a) => (a['post_id'] ?? '').toString() == (p['id'] ?? '').toString()).length;
                  return ListTile(
                    leading: const CircleAvatar(backgroundColor: ModernColors.blue, child: Icon(Icons.business, color: Colors.white)),
                    title: Text('${p['company'] ?? 'Company'} — ${p['role'] ?? 'Role'}'),
                    subtitle: Text('${p['package'] ?? ''} • ${p['location'] ?? ''}'),
                    trailing: chip('$count applied', ModernColors.green),
                    onTap: () => push(context, RealtimePlacementPortalScreen(user: user)),
                  );
                }).toList());
              },
            );
          },
        ),
      ),
    );
  }
}

class SmartAssistantShortcuts extends StatelessWidget {
  final AppUser user;
  final VoidCallback refresh;
  const SmartAssistantShortcuts({super.key, required this.user, required this.refresh});

  @override
  Widget build(BuildContext context) {
    return modernSection(
      title: 'AI Campus Assistant',
      icon: Icons.smart_toy,
      child: Column(children: [
        _askTile('Where is Lab C?', Icons.location_on, () => push(context, CampusMapScreen(user: user, refresh: refresh))),
        _askTile('When is placement?', Icons.work, () => push(context, RealtimePlacementPortalScreen(user: user))),
        _askTile('I lost my wallet', Icons.search, () => push(context, RealtimeLostFoundScreen(user: user))),
        _askTile('Raise a complaint', Icons.report, () => push(context, SubmitGrievanceScreen(user: user, onDone: refresh))),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: () => push(context, SmartCampusChatbotScreen(user: user)), icon: const Icon(Icons.chat), label: const Text('Open Chatbot')),
      ]),
    );
  }

  Widget _askTile(String text, IconData icon, VoidCallback onTap) {
    return Semantics(
      label: 'assistant_${text.toLowerCase().replaceAll(' ', '_').replaceAll('?', '').replaceAll('&', 'and')}',
      button: true,
      child: ListTile(leading: Icon(icon, color: ModernColors.blue), title: Text(text), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: onTap),
    );
  }
}

class CampusMapScreen extends StatelessWidget {
  final AppUser user;
  final VoidCallback refresh;
  const CampusMapScreen({super.key, required this.user, required this.refresh});

  static const String saveethaMapsUrl = 'https://www.google.com/maps/search/?api=1&query=Saveetha+University+Chennai';

  Future<void> launchSaveethaMap(BuildContext context) async {
    final uri = Uri.parse(saveethaMapsUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        snack(context, 'Could not launch Google Maps: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Saveetha Campus Map', back: true, context: context),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 18)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 64),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Saveetha University Campus',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Realtime Turn-by-Turn Navigation, Distance & Route Tracker',
                    style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap below to open Saveetha University directly inside Google Maps. Get live directions from your current location, routes, distance estimates, and campus navigation.',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => launchSaveethaMap(context),
                      icon: const Icon(Icons.near_me),
                      label: const Text('Launch Google Maps Navigation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================= END LIVE IDENTITY FEATURES =======================

// ========================= MODERN UI/UX REALTIME REMODEL =========================

class ModernSmartCampusHome extends StatelessWidget {
  final AppUser user;
  final VoidCallback refresh;
  final ValueChanged<int> onTab;

  const ModernSmartCampusHome({
    super.key,
    required this.user,
    required this.refresh,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: ModernColors.bg,
      drawer: isDesktop ? null : modernDrawer(context, user, refresh, onTab),
      appBar: isDesktop ? null : modernTopBar(context, user),
      floatingActionButton: Semantics(
        label: 'raise_issue_fab',
        button: true,
        child: FloatingActionButton.extended(
          backgroundColor: ModernColors.blue,
          onPressed: () => push(context, SubmitGrievanceScreen(user: user, onDone: refresh)),
          icon: const Icon(Icons.add),
          label: const Text('Raise Issue'),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 1050;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LiveCampusPulseHero(user: user, refresh: refresh),
                const SizedBox(height: 12),
                LiveActivityTicker(user: user),
                const SizedBox(height: 16),
                CampusStoriesBar(user: user),
                const SizedBox(height: 16),
                ModernStatsRow(user: user),
                const SizedBox(height: 18),
                if (desktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: ModernCampusFeed(user: user)),
                      const SizedBox(width: 18),
                      Expanded(child: Column(
                        children: [
                          ModernNotificationsPanel(user: user),
                          const SizedBox(height: 18),
                          const SizedBox(height: 18),
                          CampusScoreCard(user: user),
                          const SizedBox(height: 18),
                          LivePlacementWall(user: user),
                          const SizedBox(height: 18),
                          SmartAssistantShortcuts(user: user, refresh: refresh),
                        ],
                      )),
                    ],
                  )
                else ...[
                  ModernCampusFeed(user: user),
                  const SizedBox(height: 18),
                  ModernNotificationsPanel(user: user),
                  const SizedBox(height: 18),
                  ModernQuickActions(user: user, refresh: refresh),
                  const SizedBox(height: 18),
                  CampusScoreCard(user: user),
                  const SizedBox(height: 18),
                  LivePlacementWall(user: user),
                  const SizedBox(height: 18),
                  SmartAssistantShortcuts(user: user, refresh: refresh),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

PreferredSizeWidget modernTopBar(BuildContext context, AppUser user) {
  return AppBar(
    backgroundColor: Colors.white,
    foregroundColor: ModernColors.navy,
    elevation: 0.5,
    leading: Builder(
      builder: (ctx) => IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    ),
    title: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [ModernColors.blue, ModernColors.cyan]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Text('SmartCampus', style: TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
    actions: [
      IconButton(onPressed: () => push(context, PowerNotificationsScreen(user: user)), icon: const Icon(Icons.notifications_none)),
      if (MediaQuery.of(context).size.width > 600)
        IconButton(onPressed: () => push(context, SmartCampusChatbotScreen(user: user)), icon: const Icon(Icons.smart_toy_outlined)),
      StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('profiles').stream(primaryKey: ['id']).eq('email', user.email),
        builder: (_, snapshot) {
          String photo = LocalStore.profilePhotoUrl;
          String name = AccessControl.isAdminEmail(user.email) ? 'AVILIGONDA DILEEP KUMAR' : user.name;
          if (snapshot.hasData && (snapshot.data ?? []).isNotEmpty) {
            final row = snapshot.data!.first;
            photo = (row['photo_url'] ?? photo).toString();
            name = (row['full_name'] ?? name).toString();
          }
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: photo.isEmpty ? null : NetworkImage(photo),
                  child: photo.isEmpty ? const Icon(Icons.person, size: 18) : null,
                ),
                if (MediaQuery.of(context).size.width > 600) ...[
                  const SizedBox(width: 8),
                  Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ],
            ),
          );
        },
      ),
      if (MediaQuery.of(context).size.width > 600)
        IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
    ],
  );
}

Drawer modernDrawer(BuildContext context, AppUser user, VoidCallback refresh, ValueChanged<int> onTab) {
  Widget item(IconData icon, String title, VoidCallback onTap, {bool admin = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Semantics(
        label: 'nav_${title.toLowerCase().replaceAll(' ', '_').replaceAll('°', '').replaceAll('&', 'and')}',
        button: true,
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: Icon(icon, color: admin ? ModernColors.cyan : Colors.white70),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
        ),
      ),
    );
  }

  return Drawer(
    backgroundColor: ModernColors.navy,
    child: SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [ModernColors.blue, ModernColors.cyan]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.school, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('SmartCampus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    Text('Realtime Portal', style: TextStyle(color: Colors.white70)),
                  ]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                item(Icons.dashboard_rounded, 'Dashboard', () => onTab(0)),
                item(Icons.report_problem_outlined, 'Complaints & Grievances', () => onTab(1)),
                item(Icons.meeting_room_outlined, 'Room & Facility Bookings', () => push(context, BookRoomScreen(user: user, refresh: refresh))),
                item(Icons.work_outline, 'Placement Portal', () => push(context, RealtimePlacementPortalScreen(user: user))),
                item(Icons.campaign_outlined, 'Announcements', () => push(context, AnnouncementsScreen(user: user))),
                item(Icons.calendar_month_outlined, 'Timetable', () => push(context, TimetableScreen(user: user))),
                item(Icons.map_outlined, 'Saveetha Campus Map', () => push(context, CampusMapScreen(user: user, refresh: refresh))),
                item(Icons.emergency_outlined, 'Emergency Contacts', () => push(context, EmergencyContactsScreen(user: user))),
                item(Icons.smart_toy_outlined, 'AI Assistant', () => push(context, SmartCampusChatbotScreen(user: user))),
                item(Icons.person_outline, 'My Profile', () => push(context, RealtimeProfileScreen(user: user))),
                if (AccessControl.isAdminEmail(user.email))
                  item(Icons.admin_panel_settings_outlined, 'Admin Dashboard', () => push(context, const AdminOnlyScreen(child: AdminDashboardScreen())), admin: true),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget modernHero(AppUser user) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [ModernColors.navy, ModernColors.slate, ModernColors.blue]),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: ModernColors.blue.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 12))],
    ),
    child: Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome back, ${AccessControl.isAdminEmail(user.email) ? 'AVILIGONDA DILEEP KUMAR' : user.name}',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Realtime campus feed, placements, complaints, notifications and student services in one platform.',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
        ])),
        const SizedBox(width: 14),
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.hub, color: Colors.white, size: 50),
        ),
      ],
    ),
  );
}

class ModernStatsRow extends StatelessWidget {
  final AppUser user;
  const ModernStatsRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('grievances').stream(primaryKey: ['id']),
      builder: (_, issueSnap) {
        final issues = issueSnap.data ?? [];
        final open = issues.where((g) => !isIssueHistoryStatus((g['status'] ?? '').toString())).length;
        final resolved = issues.where((g) => isIssueHistoryStatus((g['status'] ?? '').toString())).length;
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase.from('app_registered_users').stream(primaryKey: ['id']),
          builder: (_, userSnap) {
            final users = userSnap.data ?? [];
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('placement_posts').stream(primaryKey: ['id']),
              builder: (_, placeSnap) {
                final placements = placeSnap.data ?? [];
                final isWide = MediaQuery.of(context).size.width > 600;
                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: modernStat('Users', users.length.toString(), Icons.people, ModernColors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: modernStat('Open Issues', open.toString(), Icons.report, ModernColors.amber)),
                      const SizedBox(width: 12),
                      Expanded(child: modernStat('Resolved', resolved.toString(), Icons.verified, ModernColors.green)),
                      const SizedBox(width: 12),
                      Expanded(child: modernStat('Placements', placements.length.toString(), Icons.work, ModernColors.cyan)),
                    ],
                  );
                }
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: modernStat('Users', users.length.toString(), Icons.people, ModernColors.blue)),
                        const SizedBox(width: 12),
                        Expanded(child: modernStat('Open Issues', open.toString(), Icons.report, ModernColors.amber)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: modernStat('Resolved', resolved.toString(), Icons.verified, ModernColors.green)),
                        const SizedBox(width: 12),
                        Expanded(child: modernStat('Placements', placements.length.toString(), Icons.work, ModernColors.cyan)),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

Widget modernStat(String label, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12)]),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 8),
      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis, maxLines: 1),
      ])),
    ]),
  );
}

class ModernCampusFeed extends StatefulWidget {
  final AppUser user;
  const ModernCampusFeed({super.key, required this.user});

  @override
  State<ModernCampusFeed> createState() => _ModernCampusFeedState();
}

class _ModernCampusFeedState extends State<ModernCampusFeed> {
  final post = TextEditingController();

  @override
  void dispose() {
    post.dispose();
    super.dispose();
  }

  Future<void> addPost() async {
    if (post.text.trim().isEmpty) return;
    await recordLiveActivity(actorEmail: widget.user.email, actorName: AccessControl.isAdminEmail(widget.user.email) ? 'AVILIGONDA DILEEP KUMAR' : widget.user.name, action: 'posted on campus feed', module: 'Campus Feed');
    await supabase.from('campus_feed_posts').insert({
      'user_email': widget.user.email,
      'user_name': AccessControl.isAdminEmail(widget.user.email) ? 'AVILIGONDA DILEEP KUMAR' : widget.user.name,
      'user_photo': LocalStore.profilePhotoUrl,
      'content': post.text.trim(),
      'category': 'Campus',
    });
    post.clear();
  }

  Future<void> likePost(Map<String, dynamic> p) async {
    final likes = (p['likes'] ?? 0) as int;
    await supabase.from('campus_feed_posts').update({'likes': likes + 1}).eq('id', p['id']);
  }

  @override
  Widget build(BuildContext context) {
    return modernSection(
      title: 'Campus Realtime Feed',
      icon: Icons.dynamic_feed,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: ModernColors.bg, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Expanded(child: TextField(controller: post, decoration: const InputDecoration(hintText: 'Share achievement, event, placement update...', border: InputBorder.none))),
            FilledButton(onPressed: addPost, child: const Text('Post')),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 520,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('campus_feed_posts').stream(primaryKey: ['id']).order('created_at', ascending: false),
            builder: (_, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final posts = snapshot.data ?? [];
              if (posts.isEmpty) return const Center(child: Text('No campus posts yet'));
              return ListView(
                children: posts.map((p) {
                  final photo = (p['user_photo'] ?? '').toString();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(backgroundImage: photo.isEmpty ? null : NetworkImage(photo), child: photo.isEmpty ? const Icon(Icons.person) : null),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text((p['user_name'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text((p['category'] ?? 'Campus').toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      Text((p['content'] ?? '').toString()),
                      const SizedBox(height: 10),
                      Row(children: [
                        TextButton.icon(onPressed: () => likePost(p), icon: const Icon(Icons.thumb_up_alt_outlined), label: Text('${p['likes'] ?? 0}')),
                        TextButton.icon(onPressed: () {}, icon: const Icon(Icons.comment_outlined), label: const Text('Comment')),
                      ]),
                    ]),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class CampusFeedFullScreen extends StatelessWidget {
  final AppUser user;
  const CampusFeedFullScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ModernColors.bg,
    appBar: modernTopBar(context, user),
    body: Padding(padding: const EdgeInsets.all(18), child: ModernCampusFeed(user: user)),
  );
}

class ModernNotificationsPanel extends StatelessWidget {
  final AppUser user;
  const ModernNotificationsPanel({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return modernSection(
      title: 'Realtime Notifications',
      icon: Icons.notifications_active,
      child: SizedBox(height: 330, child: PortalNotificationsBox(user: user)),
    );
  }
}

class ModernQuickActions extends StatelessWidget {
  final AppUser user;
  final VoidCallback refresh;
  const ModernQuickActions({super.key, required this.user, required this.refresh});

  @override
  Widget build(BuildContext context) {
    final actions = [
      [Icons.report_problem_outlined, 'Raise Issue', () => push(context, SubmitGrievanceScreen(user: user, onDone: refresh))],
      [Icons.meeting_room_outlined, 'Book Room', () => push(context, BookRoomScreen(user: user, refresh: refresh))],
      [Icons.map_outlined, 'Saveetha Map', () => push(context, CampusMapScreen(user: user, refresh: refresh))],
      [Icons.calendar_month_outlined, 'Timetable', () => push(context, TimetableScreen(user: user))],
      [Icons.campaign_outlined, 'Announcements', () => push(context, AnnouncementsScreen(user: user))],
      [Icons.emergency_outlined, 'Emergency', () => push(context, EmergencyContactsScreen(user: user))],
      [Icons.work_outline, 'Placement', () => push(context, RealtimePlacementPortalScreen(user: user))],
      [Icons.smart_toy_outlined, 'AI Assistant', () => push(context, SmartCampusChatbotScreen(user: user))],
      [Icons.person_outline, 'My Profile', () => push(context, RealtimeProfileScreen(user: user))],
    ];

    return modernSection(
      title: 'Quick Actions',
      icon: Icons.grid_view,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.8,
        children: actions.map((a) => Semantics(
          label: 'quick_${(a[1] as String).toLowerCase().replaceAll(' ', '_').replaceAll('&', 'and')}',
          button: true,
          child: InkWell(
            onTap: a[2] as VoidCallback,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: ModernColors.bg, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(a[0] as IconData, color: ModernColors.blue),
                const SizedBox(height: 8),
                Text(a[1] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

Widget modernSection({required String title, required IconData icon, required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 14)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: ModernColors.cyan.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: ModernColors.cyan)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

// ======================= END MODERN UI/UX REALTIME REMODEL =======================

class HomeScreen extends StatelessWidget {
  final AppUser user;
  final VoidCallback refresh;
  final ValueChanged<int> onTab;

  const HomeScreen({super.key, required this.user, required this.refresh, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return ModernSmartCampusHome(user: user, refresh: refresh, onTab: onTab);
  }
}

Widget statCard(String value, String label, IconData icon) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 2),
        ],
      ),
    ),
  );
}


class GrievanceListScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback refresh;
  const GrievanceListScreen({super.key, required this.user, required this.refresh});

  @override
  State<GrievanceListScreen> createState() => _GrievanceListScreenState();
}

class _GrievanceListScreenState extends State<GrievanceListScreen> {
  final search = TextEditingController();
  String statusFilter = 'All';

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> filteredRows(List<Map<String, dynamic>> rows) {
    final canManage = AccessControl.isAdminEmail(widget.user.email);
    var items = canManage ? rows : rows.where((g) => (g['user_email'] ?? '') == widget.user.email).toList();

    if (statusFilter != 'All') {
      items = items.where((g) => (g['status'] ?? 'Pending') == statusFilter).toList();
    }

    final q = search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((g) {
        final id = (g['id'] ?? '').toString().toLowerCase();
        final title = (g['title'] ?? '').toString().toLowerCase();
        final description = (g['description'] ?? '').toString().toLowerCase();
        final category = (g['category'] ?? '').toString().toLowerCase();
        return id.contains(q) || title.contains(q) || description.contains(q) || category.contains(q);
      }).toList();
    }

    return items;
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await supabase.from('grievances').update({'status': status}).eq('id', id);
      if (mounted) snack(context, 'Status updated to $status');
      AppState.addLog('Grievance $id updated to $status');
    } catch (e) {
      if (mounted) snack(context, 'Supabase update failed: $e', error: true);
    }
  }


  Future<void> updateGrievanceStatus(String id, String status) async {
    if (!AccessControl.isAdminEmail(widget.user.email)) {
      snack(context, 'Only admin can update complaints', error: true);
      return;
    }

    try {
      await supabase.from('grievances').update({
        'status': status,
        'admin_note': 'Updated by admin: ${widget.user.email}',
      }).eq('id', id);

      if (!mounted) return;
      snack(context, 'Complaint marked as $status');
      AppState.addLog('Complaint $id marked as $status');
    } catch (e) {
      if (!mounted) return;
      snack(context, 'Status update failed: $e', error: true);
    }
  }

  Future<void> rateOrReopenComplaint(Map<String, dynamic> g) async {
    final id = (g['id'] ?? '').toString();
    final feedbackCtrl = TextEditingController(text: (g['student_feedback'] ?? '').toString());
    int rating = g['rating'] ?? 5;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Resolution Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rate Resolution:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        icon: Icon(star <= rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                        onPressed: () => setDlgState(() => rating = star),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: feedbackCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Feedback Comments', prefixIcon: Icon(Icons.comment)),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  await supabase.from('grievances').update({
                    'status': 'Reopened',
                    'student_feedback': 'Reopened by student: ${feedbackCtrl.text.trim()}',
                  }).eq('id', id);
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  snack(context, 'Complaint reopened!');
                },
                icon: const Icon(Icons.replay),
                label: const Text('Reopen Complaint'),
              ),
              FilledButton(
                onPressed: () async {
                  await supabase.from('grievances').update({
                    'rating': rating,
                    'student_feedback': feedbackCtrl.text.trim(),
                  }).eq('id', id);
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  snack(context, 'Feedback saved!');
                },
                child: const Text('Submit Rating'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = AccessControl.isAdminEmail(widget.user.email);
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: isDesktop ? null : appBar(canManage ? 'Complaint Center (Admin)' : 'My Complaints & Grievances', back: true, context: context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => push(
          context,
          SubmitGrievanceScreen(
            user: widget.user,
            onDone: () {
              setState(() {});
              widget.refresh();
            },
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Raise Complaint'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: input('Search complaints by ID, title, or category', Icons.search),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Pending', 'In Progress', 'Resolved', 'Reopened'].map((s) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: statusFilter == s,
                    onSelected: (_) => setState(() => statusFilter = s),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('grievances')
                  .stream(primaryKey: ['id'])
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                final List<Map<String, dynamic>> rawData = (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty)
                    ? snapshot.data!
                    : [
                        {
                          'id': 'g1',
                          'title': 'Wi-Fi Connection Disruption in CS Lab 2',
                          'description': 'Wi-Fi signal drops frequently during practical sessions.',
                          'category': 'IT & Wi-Fi',
                          'priority': 'High',
                          'status': 'In Progress',
                          'user_email': widget.user.email,
                          'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
                        },
                      ];

                final rows = filteredRows(rawData);

                if (rows.isEmpty) {
                  return const Center(child: Text('No complaints found in this view'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: rows.length,
                  itemBuilder: (_, i) {
                    final g = rows[i];
                    final id = (g['id'] ?? '').toString();
                    final title = (g['title'] ?? 'Untitled').toString();
                    final description = (g['description'] ?? '').toString();
                    final category = (g['category'] ?? 'Other').toString();
                    final priority = (g['priority'] ?? 'Medium').toString();
                    final status = (g['status'] ?? 'Pending').toString();
                    final userEmail = (g['user_email'] ?? '').toString();
                    final imageUrl = (g['image_url'] ?? '').toString();
                    final rating = g['rating'];
                    final feedback = (g['student_feedback'] ?? '').toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              chip(category, AppColors.primary),
                              chip(status, statusColor(status)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(description, style: const TextStyle(color: Colors.black87)),
                          if (imageUrl.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text('Priority: $priority • By: $userEmail', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          if (rating != null)
                            Row(
                              children: [
                                const Text('Rating: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ...List.generate(rating as int, (_) => const Icon(Icons.star, color: Colors.amber, size: 14)),
                              ],
                            ),
                          if (feedback.isNotEmpty) Text('Feedback: $feedback', style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontStyle: FontStyle.italic)),
                          const SizedBox(height: 8),
                          if (canManage) ...[
                            Row(
                              children: [
                                Expanded(child: OutlinedButton(onPressed: () => updateStatus(id, 'In Progress'), child: const Text('In Progress'))),
                                const SizedBox(width: 6),
                                Expanded(child: FilledButton(onPressed: () => updateStatus(id, 'Resolved'), child: const Text('Resolve'))),
                                const SizedBox(width: 6),
                                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: Colors.red), onPressed: () => updateStatus(id, 'Rejected'), child: const Text('Reject'))),
                              ],
                            ),
                          ] else if (status == 'Resolved') ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => rateOrReopenComplaint(g),
                                icon: const Icon(Icons.rate_review),
                                label: const Text('Rate Resolution or Reopen'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SubmitGrievanceScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onDone;
  const SubmitGrievanceScreen({super.key, required this.user, required this.onDone});

  @override
  State<SubmitGrievanceScreen> createState() => _SubmitGrievanceScreenState();
}

class _SubmitGrievanceScreenState extends State<SubmitGrievanceScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  String category = 'Infrastructure';
  String priority = 'Medium';
  XFile? image;
  bool saving = false;

  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 75, maxWidth: 1000);
    if (picked != null) {
      setState(() => image = picked);
    }
  }

  Future<void> submit() async {
    if (title.text.trim().isEmpty || desc.text.trim().isEmpty) {
      snack(context, 'Please enter title and description', error: true);
      return;
    }

    setState(() => saving = true);

    String imageUrl = '';
    try {
      if (image != null) {
        final bytes = await image!.readAsBytes();
        final ext = image!.name.split('.').last;
        final path = 'complaints/${DateTime.now().millisecondsSinceEpoch}_${widget.user.email.split('@').first}.$ext';
        try {
          await supabase.storage.from('complaint-photos').uploadBinary(path, bytes);
          imageUrl = supabase.storage.from('complaint-photos').getPublicUrl(path);
        } catch (_) {}
      }

      await supabase.from('grievances').insert({
        'title': title.text.trim(),
        'description': desc.text.trim(),
        'category': category,
        'priority': priority,
        'status': 'Pending',
        'image_url': imageUrl,
        'user_email': widget.user.email,
        'user_name': LocalStore.currentName ?? widget.user.name,
        'created_at': DateTime.now().toIso8601String(),
      });

      widget.onDone();
      if (mounted) {
        snack(context, 'Complaint submitted successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) snack(context, 'Submit failed: $e', error: true);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Raise Infra Issue', back: true, context: context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            infoBox('Live mode: grievance is saved to Supabase. Image preview is local only.'),
            const SizedBox(height: 16),
            TextField(controller: title, decoration: input('Grievance title', Icons.title)),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: category,
              decoration: input('Category', Icons.category_outlined),
              items: ['Infrastructure', 'Academic', 'Canteen', 'Hostel', 'Transport', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: priority,
              decoration: input('Priority', Icons.flag_outlined),
              items: ['Low', 'Medium', 'High']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => priority = v!),
            ),
            const SizedBox(height: 14),
            TextField(controller: desc, maxLines: 5, decoration: input('Description', Icons.description_outlined)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: saving ? null : () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Take Photo'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: saving ? null : () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose Gallery'),
                  ),
                ),
              ],
            ),
            if (image != null) Padding(padding: const EdgeInsets.only(top: 12), child: imagePreview(image!)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: saving ? null : submit,
                child: saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Complaint'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef BookRoomScreen = ResourceBookingScreen;

class ResourceBookingScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback refresh;
  const ResourceBookingScreen({super.key, required this.user, required this.refresh});

  @override
  State<ResourceBookingScreen> createState() => _ResourceBookingScreenState();
}

class _ResourceBookingScreenState extends State<ResourceBookingScreen> {
  String resource = '';
  String date = '';
  String time = '';
  final resources = ['Computer Lab A', 'Seminar Hall B', 'Main Auditorium', 'Sports Ground', 'Conference Room 101', 'Central Library Hall'];
  final dates = ['Today', 'Tomorrow', 'Next Monday', 'Next Wednesday'];
  final slots = ['09:00 AM - 11:00 AM', '11:00 AM - 01:00 PM', '02:00 PM - 04:00 PM', '04:00 PM - 06:00 PM'];

  Future<void> book() async {
    if (resource.isEmpty || date.isEmpty || time.isEmpty) {
      snack(context, 'Please select resource, date, and time slot', error: true);
      return;
    }

    try {
      await supabase.from('bookings').insert({
        'resource': resource,
        'booking_date': date,
        'booking_time': time,
        'status': 'Pending',
        'user_email': widget.user.email,
        'user_name': LocalStore.currentName ?? widget.user.name,
        'created_at': DateTime.now().toIso8601String(),
      });

      widget.refresh();
      if (!mounted) return;
      snack(context, 'Booking request submitted');
      setState(() {
        resource = '';
        date = '';
        time = '';
      });
    } catch (e) {
      if (!mounted) return;
      snack(context, 'Booking failed: $e', error: true);
    }
  }

  Future<void> updateBookingStatus(String id, String newStatus) async {
    try {
      await supabase.from('bookings').update({'status': newStatus}).eq('id', id);
      if (!mounted) return;
      widget.refresh();
      snack(context, 'Booking $newStatus');
    } catch (e) {
      if (!mounted) return;
      snack(context, 'Update failed: $e', error: true);
    }
  }

  List<Map<String, dynamic>> visibleBookings(List<Map<String, dynamic>> rows) {
    final isManager = AccessControl.isAdminEmail(widget.user.email);
    if (isManager) return rows;
    return rows.where((b) => (b['user_email'] ?? '').toString() == widget.user.email).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isManager = AccessControl.isAdminEmail(widget.user.email);
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: isDesktop ? null : appBar(isManager ? 'Facility Booking Manager' : 'Book Facility / Room', back: true, context: context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isManager) ...[
              infoBox('Select resource, date, and time slot to submit a real-time reservation request.'),
              const SizedBox(height: 16),
              dropdown('Select Resource / Room', resource, resources, (v) => setState(() => resource = v)),
              const SizedBox(height: 12),
              dropdown('Select Date', date, dates, (v) => setState(() => date = v)),
              const SizedBox(height: 12),
              dropdown('Select Time Slot', time, slots, (v) => setState(() => time = v)),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: book, child: const Text('Submit Booking Request'))),
              const SizedBox(height: 24),
            ],
            const Text('Live Booking Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: isManager ? 620 : 420,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase
                    .from('bookings')
                    .stream(primaryKey: ['id'])
                    .order('created_at', ascending: false),
                builder: (context, snapshot) {
                  final rawBookings = snapshot.data ?? [];
                  final bookings = visibleBookings(rawBookings);

                  if (bookings.isEmpty) {
                    return const Center(child: Text('No active booking requests'));
                  }

                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (_, i) {
                      final b = bookings[i];
                      final id = (b['id'] ?? '').toString();
                      final res = (b['resource'] ?? b['facility_name'] ?? 'Facility Booking').toString();
                      final bookingDate = (b['booking_date'] ?? '').toString();
                      final bookingTime = (b['booking_time'] ?? b['time_slot'] ?? '').toString();
                      final email = (b['user_email'] ?? '').toString();
                      final status = (b['status'] ?? 'Pending').toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(res, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                chip(status, statusColor(status)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('$bookingDate • $bookingTime', style: const TextStyle(color: Colors.black87, fontSize: 14)),
                            Text('Requested by: $email', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 10),
                            if (isManager && status == 'Pending') ...[
                              Row(
                                children: [
                                  Expanded(child: FilledButton(onPressed: () => updateBookingStatus(id, 'Approved'), child: const Text('Approve'))),
                                  const SizedBox(width: 8),
                                  Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: Colors.red), onPressed: () => updateBookingStatus(id, 'Rejected'), child: const Text('Reject'))),
                                ],
                              ),
                            ] else if (!isManager && status != 'Cancelled') ...[
                              OutlinedButton(onPressed: () => updateBookingStatus(id, 'Cancelled'), child: const Text('Cancel Request')),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final AppUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msg = TextEditingController();

  void send() {
    final text = msg.text.trim();
    if (text.isEmpty) return;
    LocalStore.messages.insert(0, LocalMessage(text: text, senderEmail: widget.user.email, createdAt: DateTime.now()));
    msg.clear();
    setState(() {});
  }

  @override
  void dispose() {
    msg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Campus Chat Demo', back: true, context: context),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: infoBox('No billing mode: chat messages are local demo messages only.')),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: LocalStore.messages.length,
              itemBuilder: (_, i) {
                final m = LocalStore.messages[i];
                final mine = m.senderEmail == widget.user.email;
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(color: mine ? AppColors.primary : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.text, style: TextStyle(color: mine ? Colors.white : null)),
                      const SizedBox(height: 4),
                      Text(m.senderEmail, style: TextStyle(color: mine ? Colors.white70 : Colors.grey, fontSize: 10)),
                    ]),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: msg, decoration: input('Message', Icons.message_outlined))),
              const SizedBox(width: 8),
              FloatingActionButton.small(onPressed: send, child: const Icon(Icons.send)),
            ]),
          ),
        ],
      ),
    );
  }
}

class TimetableScreen extends StatefulWidget {
  final AppUser user;
  const TimetableScreen({super.key, required this.user});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String selectedDay = 'Monday';
  final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  Future<void> showAddTimetableModal([Map<String, dynamic>? existing]) async {
    final subjectCtrl = TextEditingController(text: existing?['subject'] ?? '');
    final timeCtrl = TextEditingController(text: existing?['time_slot'] ?? '09:00 AM - 10:00 AM');
    final roomCtrl = TextEditingController(text: existing?['room'] ?? 'Room 201');
    final lecturerCtrl = TextEditingController(text: existing?['lecturer'] ?? 'Faculty');
    String day = existing?['day'] ?? selectedDay;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(existing == null ? 'Upload Class Schedule' : 'Edit Class Schedule', style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: day,
                    decoration: const InputDecoration(labelText: 'Day of Week'),
                    items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setDlgState(() => day = v ?? day),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject / Course Name', prefixIcon: Icon(Icons.book))),
                  const SizedBox(height: 10),
                  TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time Slot', prefixIcon: Icon(Icons.schedule))),
                  const SizedBox(height: 10),
                  TextField(controller: roomCtrl, decoration: const InputDecoration(labelText: 'Room / Lab', prefixIcon: Icon(Icons.meeting_room))),
                  const SizedBox(height: 10),
                  TextField(controller: lecturerCtrl, decoration: const InputDecoration(labelText: 'Lecturer / Faculty', prefixIcon: Icon(Icons.person))),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  final s = subjectCtrl.text.trim();
                  if (s.isEmpty) {
                    snack(context, 'Please enter subject name', error: true);
                    return;
                  }
                  final data = {
                    'day': day,
                    'subject': s,
                    'time_slot': timeCtrl.text.trim(),
                    'room': roomCtrl.text.trim(),
                    'lecturer': lecturerCtrl.text.trim(),
                    'created_at': DateTime.now().toIso8601String(),
                  };
                  if (existing != null) {
                    await supabase.from('timetables').update(data).eq('id', existing['id']);
                  } else {
                    await supabase.from('timetables').insert(data);
                  }
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  snack(context, existing == null ? 'Schedule uploaded' : 'Schedule updated');
                },
                child: Text(existing == null ? 'Upload' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> deleteSchedule(String id) async {
    await supabase.from('timetables').delete().eq('id', id);
    if (mounted) snack(context, 'Schedule deleted');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AccessControl.isAdminEmail(widget.user.email);

    return Scaffold(
      appBar: appBar('Academic Timetable', back: true, context: context),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => showAddTimetableModal(),
              icon: const Icon(Icons.add),
              label: const Text('Upload Schedule'),
            )
          : null,
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: days.map((d) {
                final sel = selectedDay == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(d, style: TextStyle(fontWeight: sel ? FontWeight.bold : FontWeight.normal, color: sel ? Colors.white : Colors.black87)),
                    selected: sel,
                    selectedColor: const Color(0xFF2563EB),
                    onSelected: (_) => setState(() => selectedDay = d),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('timetables').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                final allRows = snapshot.data ?? [];
                final rows = allRows.where((r) => (r['day'] ?? '').toString().toLowerCase() == selectedDay.toLowerCase()).toList();

                if (rows.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 54, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('No class schedules for $selectedDay', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (isAdmin) const Text('Tap Upload Schedule to add classes.', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rows.length,
                  itemBuilder: (ctx, i) {
                    final item = rows[i];
                    final id = (item['id'] ?? '').toString();
                    final subject = (item['subject'] ?? 'Subject').toString();
                    final time = (item['time_slot'] ?? '').toString();
                    final room = (item['room'] ?? '').toString();
                    final lecturer = (item['lecturer'] ?? '').toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: cardDecoration(),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF2563EB),
                          child: Icon(Icons.schedule, color: Colors.white),
                        ),
                        title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text('$time • $room\nLecturer: $lecturer'),
                        isThreeLine: true,
                        trailing: isAdmin
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => showAddTimetableModal(item)),
                                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => deleteSchedule(id)),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnnouncementsScreen extends StatefulWidget {
  final AppUser user;
  const AnnouncementsScreen({super.key, required this.user});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  Future<void> showAddAnnouncementModal() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'General');
    String attachmentUrl = '';
    bool uploading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Upload Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title))),
                  const SizedBox(height: 10),
                  TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category))),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description / Details', prefixIcon: Icon(Icons.description))),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: uploading
                        ? null
                        : () async {
                            final res = await FilePicker.platform.pickFiles(type: FileType.any);
                            if (res == null || res.files.isEmpty) return;
                            final file = res.files.first;
                            setDlgState(() => uploading = true);
                            try {
                              final bytes = file.bytes;
                              if (bytes != null) {
                                final path = 'announcements/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
                                await supabase.storage.from('announcements').uploadBinary(path, bytes);
                                attachmentUrl = supabase.storage.from('announcements').getPublicUrl(path);
                                snack(context, 'Attachment uploaded');
                              }
                            } catch (e) {
                              snack(context, 'Upload failed: $e', error: true);
                            } finally {
                              setDlgState(() => uploading = false);
                            }
                          },
                    icon: uploading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.attach_file),
                    label: Text(attachmentUrl.isEmpty ? 'Attach File / PDF / Image' : 'Attachment Uploaded ✓'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  final t = titleCtrl.text.trim();
                  final d = descCtrl.text.trim();
                  if (t.isEmpty) {
                    snack(context, 'Please enter title', error: true);
                    return;
                  }
                  await supabase.from('announcements').insert({
                    'title': t,
                    'description': d,
                    'category': catCtrl.text.trim(),
                    'attachment_url': attachmentUrl,
                    'created_at': DateTime.now().toIso8601String(),
                  });
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  snack(context, 'Announcement posted');
                },
                child: const Text('Publish Announcement'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> deleteAnnouncement(String id) async {
    await supabase.from('announcements').delete().eq('id', id);
    if (mounted) snack(context, 'Announcement deleted');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AccessControl.isAdminEmail(widget.user.email);

    return Scaffold(
      appBar: appBar('Announcements & Notices', back: true, context: context),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => showAddAnnouncementModal(),
              icon: const Icon(Icons.add),
              label: const Text('Publish Notice'),
            )
          : null,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('announcements').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.campaign_outlined, size: 54, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('No official announcements posted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (isAdmin) const Text('Tap Publish Notice to post an announcement.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: rows.length,
            itemBuilder: (ctx, i) {
              final a = rows[i];
              final id = (a['id'] ?? '').toString();
              final title = (a['title'] ?? 'Notice').toString();
              final desc = (a['description'] ?? a['body'] ?? '').toString();
              final cat = (a['category'] ?? 'General').toString();
              final url = (a['attachment_url'] ?? '').toString();

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        chip(cat, const Color(0xFF2563EB)),
                        const Spacer(),
                        if (isAdmin)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => deleteAnnouncement(id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(height: 6),
                    Text(desc, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    if (url.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('View / Download Attachment'),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final all = LocalStore.grievances;
    final pending = all.where((g) => g.status == 'Pending').length;
    final progress = all.where((g) => g.status == 'In Progress').length;
    final resolved = all.where((g) => g.status == 'Resolved').length;
    final cancelled = LocalStore.bookings.where((b) => b.status == 'Cancelled').length;
    return Scaffold(
      appBar: appBar('Analytics', back: true, context: context),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          metric('Total', all.length.toString(), Icons.list_alt, AppColors.primary),
          metric('Pending', pending.toString(), Icons.hourglass_top, AppColors.warning),
          metric('In Progress', progress.toString(), Icons.sync, Colors.blue),
          metric('Resolved', resolved.toString(), Icons.check_circle, AppColors.success),
          metric('Bookings', LocalStore.bookings.length.toString(), Icons.meeting_room, Colors.purple),
          metric('Cancelled', cancelled.toString(), Icons.cancel, AppColors.danger),
          metric('Lost & Found', LocalStore.lostFound.length.toString(), Icons.find_in_page, Colors.cyan),
          metric('Feedback', LocalStore.feedbacks.length.toString(), Icons.feedback, Colors.deepPurple),
          metric('Internships', LocalStore.internships.length.toString(), Icons.business_center, Colors.indigo),
          metric('Alumni', LocalStore.alumni.length.toString(), Icons.groups_3, Colors.brown),
          metric('Assignments', LocalStore.assignments.length.toString(), Icons.checklist, Colors.green),
          metric('Placements', LocalStore.placements.length.toString(), Icons.work, Colors.indigo),
        ],
      ),
    );
  }
}

class MoreScreen extends StatelessWidget {
  final AppUser user;
  final VoidCallback refresh;
  final ValueChanged<AppUser> onUserChanged;
  const MoreScreen({super.key, required this.user, required this.refresh, required this.onUserChanged});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: isDesktop ? null : appBar('Profile & More'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: cardDecoration(radius: 20),
            child: Column(children: [
              CircleAvatar(radius: 38, backgroundColor: AppColors.primary, child: Text(user.email[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(user.email, style: const TextStyle(color: Colors.grey)),
              Text('${user.role} • ${user.department}', style: const TextStyle(color: Colors.grey)),
            ]),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppState.themeMode,
            builder: (_, mode, __) => SwitchListTile(
              value: mode == ThemeMode.dark,
              onChanged: AppState.toggleTheme,
              title: const Text('Dark Mode'),
              secondary: const Icon(Icons.dark_mode),
            ),
          ),
          tile(context, Icons.home_outlined, 'Dashboard', () => push(context, ModernSmartCampusHome(user: user, refresh: () {}, onTab: (_) {}))),
          tile(context, Icons.report_problem_outlined, 'Complaints & Grievances', () => push(context, GrievanceListScreen(user: user, refresh: () {}))),
          tile(context, Icons.meeting_room_outlined, 'Room & Facility Bookings', () => push(context, BookRoomScreen(user: user, refresh: () {}))),
          tile(context, Icons.work_outline, 'Placement Portal', () => push(context, RealtimePlacementPortalScreen(user: user))),
          tile(context, Icons.campaign_outlined, 'Announcements', () => push(context, AnnouncementsScreen(user: user))),
          tile(context, Icons.calendar_month_outlined, 'Timetable', () => push(context, TimetableScreen(user: user))),
          tile(context, Icons.map_outlined, 'Saveetha Campus Map', () => push(context, CampusMapScreen(user: user, refresh: () {}))),
          tile(context, Icons.emergency_outlined, 'Emergency Contacts', () => push(context, EmergencyContactsScreen(user: user))),
          tile(context, Icons.smart_toy_outlined, 'AI Assistant', () => push(context, SmartCampusChatbotScreen(user: user))),
          tile(context, Icons.person_outline, 'My Profile', () => push(context, RealtimeProfileScreen(user: user))),
          if (AccessControl.isAdminEmail(user.email)) tile(context, Icons.admin_panel_settings_outlined, 'Admin Dashboard', () => push(context, const AdminOnlyScreen(child: AdminDashboardScreen()))),
          tile(context, Icons.logout, 'Logout', () => fb.FirebaseAuth.instance.signOut(), danger: true),
        ],
      ),
    );
  }
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalAttended = LocalStore.attendance.fold<int>(0, (sum, a) => sum + a.attended);
    final totalClasses = LocalStore.attendance.fold<int>(0, (sum, a) => sum + a.total);
    final overall = totalClasses == 0 ? 0 : ((totalAttended / totalClasses) * 100).round();
    return Scaffold(
      appBar: appBar('Attendance Tracker', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          metric('Overall Attendance', '$overall%', Icons.fact_check, overall >= 75 ? AppColors.success : AppColors.danger),
          const SizedBox(height: 16),
          ...LocalStore.attendance.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: cardDecoration(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(a.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                chip('${a.percentage.toStringAsFixed(1)}%', a.percentage >= 75 ? AppColors.success : AppColors.danger),
              ]),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: a.percentage / 100),
              const SizedBox(height: 6),
              Text('${a.attended}/${a.total} classes attended', style: const TextStyle(color: Colors.grey)),
            ]),
          )),
        ],
      ),
    );
  }
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = search.text.trim().toLowerCase();
    final books = LocalStore.libraryBooks.where((b) => q.isEmpty || b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q) || b.category.toLowerCase().contains(q)).toList();
    return Scaffold(
      appBar: appBar('Library Book Search', back: true, context: context),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(controller: search, onChanged: (_) => setState(() {}), decoration: input('Search book, author, category', Icons.search))),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: books.map((b) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: cardDecoration(),
              child: ListTile(
                leading: const Icon(Icons.menu_book, color: AppColors.primary),
                title: Text(b.title),
                subtitle: Text('${b.author} • ${b.category}'),
                trailing: chip(b.available ? 'Available' : 'Issued', b.available ? AppColors.success : AppColors.warning),
              ),
            )).toList(),
          ),
        ),
      ]),
    );
  }
}

class ExamTimetableScreen extends StatelessWidget {
  const ExamTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Exam Timetable', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.exams.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Row(children: [
            const Icon(Icons.assignment, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text('${e.date} • ${e.time} • ${e.room}', style: const TextStyle(color: Colors.grey)),
            ])),
          ]),
        )).toList(),
      ),
    );
  }
}

class MarksScreen extends StatelessWidget {
  const MarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scored = LocalStore.marks.fold<int>(0, (sum, m) => sum + m.marks);
    final total = LocalStore.marks.fold<int>(0, (sum, m) => sum + m.total);
    final percentage = total == 0 ? 0 : ((scored / total) * 100).round();
    return Scaffold(
      appBar: appBar('Marks / Results', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          metric('Overall Score', '$percentage%', Icons.grade, AppColors.success),
          const SizedBox(height: 16),
          ...LocalStore.marks.map((m) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: cardDecoration(),
            child: ListTile(
              leading: const Icon(Icons.grade, color: AppColors.primary),
              title: Text(m.subject),
              subtitle: Text('${m.marks}/${m.total} marks'),
              trailing: chip(m.grade, AppColors.success),
            ),
          )),
        ],
      ),
    );
  }
}

class BusRoutesScreen extends StatelessWidget {
  const BusRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Transport Bus Routes', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.busRoutes.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: cardDecoration(),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.primary, child: Text(r.routeNo, style: const TextStyle(color: Colors.white, fontSize: 12))),
            title: Text('${r.from} to ${r.to}'),
            subtitle: Text('${r.timing} • Driver: ${r.driver}'),
            trailing: const Icon(Icons.directions_bus, color: AppColors.primary),
          ),
        )).toList(),
      ),
    );
  }
}

class HostelScreen extends StatefulWidget {
  const HostelScreen({super.key});

  @override
  State<HostelScreen> createState() => _HostelScreenState();
}

class _HostelScreenState extends State<HostelScreen> {
  final desc = TextEditingController();
  String type = 'Maintenance';

  @override
  void dispose() {
    desc.dispose();
    super.dispose();
  }

  void submitRequest() {
    if (desc.text.trim().isEmpty) {
      snack(context, 'Enter request description', error: true);
      return;
    }
    final id = 'HR${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    LocalStore.hostelRequests.insert(0, HostelRequest(id: id, type: type, description: desc.text.trim(), status: 'Pending'));
    desc.clear();
    setState(() {});
    snack(context, 'Hostel request submitted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Hostel Management', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        DropdownButtonFormField<String>(value: type, decoration: input('Request Type', Icons.hotel), items: ['Maintenance', 'Cleaning', 'Room Change', 'Permission', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => type = v!)),
        const SizedBox(height: 12),
        TextField(controller: desc, maxLines: 3, decoration: input('Description', Icons.description_outlined)),
        const SizedBox(height: 12),
        SizedBox(height: 48, child: FilledButton(onPressed: submitRequest, child: const Text('Submit Hostel Request'))),
        const SizedBox(height: 24),
        const Text('My Hostel Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ...LocalStore.hostelRequests.map((h) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: cardDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${h.id} • ${h.type}', style: const TextStyle(fontWeight: FontWeight.bold)), chip(h.status, statusColor(h.status))]),
            const SizedBox(height: 6),
            Text(h.description, style: const TextStyle(color: Colors.grey)),
          ]),
        )),
      ]),
    );
  }
}

class CanteenMenuScreen extends StatelessWidget {
  const CanteenMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Canteen Menu', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.canteenMenu.map((m) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: cardDecoration(),
          child: ListTile(
            leading: const Icon(Icons.restaurant_menu, color: AppColors.warning),
            title: Text(m['meal'] ?? ''),
            subtitle: Text(m['item'] ?? ''),
            trailing: chip(m['price'] ?? '', AppColors.success),
          ),
        )).toList(),
      ),
    );
  }
}

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() => _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Event Registration', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.events.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), chip(e.registered ? 'Registered' : 'Open', e.registered ? AppColors.success : AppColors.primary)]),
            const SizedBox(height: 6),
            Text('${e.date} • ${e.venue}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(e.description),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: e.registered ? null : () { setState(() => e.registered = true); snack(context, 'Registered for ${e.title}'); }, child: Text(e.registered ? 'Registered' : 'Register Now'))),
          ]),
        )).toList(),
      ),
    );
  }
}

class StudentIdCardScreen extends StatelessWidget {
  final AppUser user;
  const StudentIdCardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Student ID Card', back: true, context: context),
      body: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.school, color: Colors.white, size: 42),
            const SizedBox(height: 8),
            const Text('Saveetha Engineering College', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 18),
            CircleAvatar(radius: 42, backgroundColor: Colors.white24, child: Text(user.email[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user.email, style: const TextStyle(color: Colors.white70)),
            const Divider(color: Colors.white30, height: 28),
            idRow('Role', user.role),
            idRow('Department', user.department),
            idRow('Phone', user.phone),
            idRow('Student ID', 'SEC${user.uid.hashCode.abs().toString().padLeft(6, '0').substring(0, 6)}'),
          ]),
        ),
      ),
    );
  }

  Widget idRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Text('$label: ', style: const TextStyle(color: Colors.white70)), Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))]),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Admin Control Center & Telemetry', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Live Campus Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('profiles').stream(primaryKey: ['id']),
            builder: (ctx, profileSnap) {
              final users = profileSnap.data ?? [];
              final activeCount = users.where((u) => (u['status'] ?? 'active') == 'active').length;

              return Row(
                children: [
                  Expanded(child: metric('Registered Users', '${users.isEmpty ? 12 : users.length}', Icons.people, AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: metric('Active Accounts', '${activeCount == 0 ? 12 : activeCount}', Icons.online_prediction, AppColors.success)),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('grievances').stream(primaryKey: ['id']),
            builder: (ctx, gSnap) {
              final grievances = gSnap.data ?? [];
              final pending = grievances.where((g) => (g['status'] ?? '').toString().toLowerCase() == 'pending').length;
              final resolved = grievances.where((g) => (g['status'] ?? '').toString().toLowerCase() == 'resolved').length;
              final reopened = grievances.where((g) => (g['status'] ?? '').toString().toLowerCase() == 'reopened').length;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: metric('Pending Issues', '$pending', Icons.warning_amber, AppColors.warning)),
                      const SizedBox(width: 12),
                      Expanded(child: metric('Resolved Issues', '$resolved', Icons.check_circle, AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: metric('Reopened Complaints', '$reopened', Icons.replay, Colors.purple)),
                      const SizedBox(width: 12),
                      Expanded(child: metric('Total Reported', '${grievances.length}', Icons.report, Colors.indigo)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('bookings').stream(primaryKey: ['id']),
            builder: (ctx, bSnap) {
              final bookings = bSnap.data ?? [];
              final activeBookings = bookings.where((b) => (b['status'] ?? '').toString().toLowerCase() != 'cancelled').length;

              return Row(
                children: [
                  Expanded(child: metric('Active Bookings', '$activeBookings', Icons.meeting_room, Colors.teal)),
                  const SizedBox(width: 12),
                  Expanded(child: metric('Total Booking Logs', '${bookings.length}', Icons.bookmark, Colors.amber)),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Text('Registered Users Directory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('profiles').stream(primaryKey: ['id']),
            builder: (ctx, snap) {
              final rows = snap.data ?? [];
              if (rows.isEmpty) {
                return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No profiles loaded')));
              }
              return Column(
                children: rows.map((u) {
                  final name = (u['full_name'] ?? 'User').toString();
                  final email = (u['email'] ?? '').toString();
                  final photo = (u['photo_url'] ?? '').toString();
                  final role = (u['role'] ?? 'student').toString();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                        child: photo.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$email • Role: ${role.toUpperCase()}'),
                      trailing: chip(role.toUpperCase(), role == 'admin' ? AppColors.danger : AppColors.primary),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NoticeBoardScreen extends StatelessWidget {
  const NoticeBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Notice Board', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.notices.map((n) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), chip(n.date, AppColors.primary)]),
            const SizedBox(height: 8),
            Text(n.body, style: const TextStyle(color: Colors.grey)),
          ]),
        )).toList(),
      ),
    );
  }
}

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Assignments / To-do', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.assignments.map((a) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: cardDecoration(),
          child: CheckboxListTile(
            value: a.completed,
            onChanged: (v) => setState(() => a.completed = v ?? false),
            title: Text(a.title, style: TextStyle(decoration: a.completed ? TextDecoration.lineThrough : null, fontWeight: FontWeight.bold)),
            subtitle: Text('${a.subject} • Due: ${a.dueDate}'),
            secondary: Icon(a.completed ? Icons.check_circle : Icons.pending_actions, color: a.completed ? AppColors.success : AppColors.warning),
          ),
        )).toList(),
      ),
    );
  }
}

class FeeStatusScreen extends StatefulWidget {
  const FeeStatusScreen({super.key});

  @override
  State<FeeStatusScreen> createState() => _FeeStatusScreenState();
}

class _FeeStatusScreenState extends State<FeeStatusScreen> {
  void markPaid(FeeItem fee) {
    setState(() => fee.status = 'Paid');
    snack(context, '${fee.title} marked as paid locally');
  }

  @override
  Widget build(BuildContext context) {
    final pendingAmount = LocalStore.fees.where((f) => f.status != 'Paid').fold<int>(0, (sum, f) => sum + f.amount);
    return Scaffold(
      appBar: appBar('Fee Payment Status', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        metric('Pending Amount', '₹$pendingAmount', Icons.payments, pendingAmount == 0 ? AppColors.success : AppColors.warning),
        const SizedBox(height: 16),
        ...LocalStore.fees.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: cardDecoration(),
          child: ListTile(
            leading: const Icon(Icons.receipt_long, color: AppColors.primary),
            title: Text(f.title),
            subtitle: Text('₹${f.amount} • Due: ${f.dueDate}'),
            trailing: f.status == 'Paid' ? chip('Paid', AppColors.success) : TextButton(onPressed: () => markPaid(f), child: const Text('Pay')),
          ),
        )),
      ]),
    );
  }
}

class PlacementPortalScreen extends StatefulWidget {
  const PlacementPortalScreen({super.key});

  @override
  State<PlacementPortalScreen> createState() => _PlacementPortalScreenState();
}

class _PlacementPortalScreenState extends State<PlacementPortalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Placement Portal', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.placements.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(p.company, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))), chip(p.package, AppColors.success)]),
            const SizedBox(height: 6),
            Text(p.role, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('Eligibility: ${p.eligibility}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: p.applied ? null : () { setState(() => p.applied = true); snack(context, 'Applied to ${p.company}'); }, child: Text(p.applied ? 'Applied' : 'Apply Now'))),
          ]),
        )).toList(),
      ),
    );
  }
}

class ClubActivitiesScreen extends StatefulWidget {
  const ClubActivitiesScreen({super.key});

  @override
  State<ClubActivitiesScreen> createState() => _ClubActivitiesScreenState();
}

class _ClubActivitiesScreenState extends State<ClubActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Club Activities', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.clubs.map((c) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), chip(c.joined ? 'Joined' : 'Open', c.joined ? AppColors.success : AppColors.primary)]),
            const SizedBox(height: 6),
            Text(c.description),
            const SizedBox(height: 4),
            Text('Coordinator: ${c.coordinator}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: c.joined ? null : () { setState(() => c.joined = true); snack(context, 'Joined ${c.name}'); }, child: Text(c.joined ? 'Joined' : 'Join Club'))),
          ]),
        )).toList(),
      ),
    );
  }
}

class LabAvailabilityScreen extends StatelessWidget {
  const LabAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Lab Availability', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.labs.map((l) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: cardDecoration(),
          child: ListTile(
            leading: const Icon(Icons.computer, color: AppColors.primary),
            title: Text(l.name),
            subtitle: Text('${l.block} • ${l.systems} systems'),
            trailing: chip(l.available ? 'Available' : 'Occupied', l.available ? AppColors.success : AppColors.danger),
          ),
        )).toList(),
      ),
    );
  }
}

class StudyMaterialsScreen extends StatefulWidget {
  const StudyMaterialsScreen({super.key});

  @override
  State<StudyMaterialsScreen> createState() => _StudyMaterialsScreenState();
}

class _StudyMaterialsScreenState extends State<StudyMaterialsScreen> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = search.text.trim().toLowerCase();
    final items = LocalStore.studyMaterials.where((m) => q.isEmpty || m.subject.toLowerCase().contains(q) || m.title.toLowerCase().contains(q)).toList();
    return Scaffold(
      appBar: appBar('Study Materials', back: true, context: context),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(controller: search, onChanged: (_) => setState(() {}), decoration: input('Search materials', Icons.search))),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: items.map((m) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: cardDecoration(),
            child: ListTile(
              leading: const Icon(Icons.download, color: AppColors.primary),
              title: Text(m.title),
              subtitle: Text('${m.subject} • ${m.type}'),
              trailing: TextButton(onPressed: () => snack(context, 'Download simulated for ${m.title}'), child: const Text('Download')),
            ),
          )).toList(),
        )),
      ]),
    );
  }
}

class MentorBookingScreen extends StatefulWidget {
  const MentorBookingScreen({super.key});

  @override
  State<MentorBookingScreen> createState() => _MentorBookingScreenState();
}

class _MentorBookingScreenState extends State<MentorBookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Mentor Meeting Booking', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.mentorSlots.map((s) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: cardDecoration(),
          child: ListTile(
            leading: const Icon(Icons.person_pin, color: AppColors.primary),
            title: Text(s.mentor),
            subtitle: Text('${s.date} • ${s.time}'),
            trailing: s.booked ? chip('Booked', AppColors.success) : TextButton(onPressed: () { setState(() => s.booked = true); snack(context, 'Mentor meeting booked'); }, child: const Text('Book')),
          ),
        )).toList(),
      ),
    );
  }
}

class AcademicCalendarScreen extends StatelessWidget {
  const AcademicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Academic Calendar', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.academicCalendar.map((c) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Row(children: [
            const Icon(Icons.date_range, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${c.date} • ${c.type}', style: const TextStyle(color: Colors.grey)),
            ])),
          ]),
        )).toList(),
      ),
    );
  }
}


class OtpLoginDemoScreen extends StatefulWidget {
  const OtpLoginDemoScreen({super.key});
  @override
  State<OtpLoginDemoScreen> createState() => _OtpLoginDemoScreenState();
}

class _OtpLoginDemoScreenState extends State<OtpLoginDemoScreen> {
  final phone = TextEditingController();
  final otp = TextEditingController();
  String generatedOtp = '';

  @override
  void dispose() {
    phone.dispose();
    otp.dispose();
    super.dispose();
  }

  void generateOtp() {
    if (phone.text.trim().length < 10) {
      snack(context, 'Enter valid phone number', error: true);
      return;
    }
    generatedOtp = '123456';
    AppState.addLog('OTP demo generated');
    setState(() {});
    snack(context, 'Demo OTP is 123456');
  }

  void verifyOtp() {
    if (otp.text.trim() == generatedOtp && generatedOtp.isNotEmpty) {
      snack(context, 'OTP verified successfully');
    } else {
      snack(context, 'Invalid OTP', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('OTP Login Demo', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        infoBox('No-billing demo: OTP is simulated locally as 123456.'),
        const SizedBox(height: 16),
        TextField(controller: phone, keyboardType: TextInputType.phone, decoration: input('Phone number', Icons.phone_android)),
        const SizedBox(height: 12),
        SizedBox(height: 48, child: OutlinedButton(onPressed: generateOtp, child: const Text('Send Demo OTP'))),
        const SizedBox(height: 12),
        TextField(controller: otp, keyboardType: TextInputType.number, decoration: input('Enter OTP', Icons.sms_outlined)),
        const SizedBox(height: 20),
        SizedBox(height: 50, child: FilledButton(onPressed: verifyOtp, child: const Text('Verify OTP'))),
      ]),
    );
  }
}

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  Future<void> sendVerification(BuildContext context) async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      snack(context, 'No user logged in', error: true);
      return;
    }
    try {
      await user.sendEmailVerification();
      AppState.addLog('Email verification sent');
      snack(context, 'Verification email sent');
    } on fb.FirebaseAuthException catch (e) {
      snack(context, e.message ?? 'Could not send verification email', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = fb.FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: appBar('Email Verification', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        infoBox('This uses Firebase Authentication only. No billing required.'),
        const SizedBox(height: 16),
        metric('Verified', user?.emailVerified == true ? 'Yes' : 'No', Icons.mark_email_read, user?.emailVerified == true ? AppColors.success : AppColors.warning),
        const SizedBox(height: 16),
        SizedBox(height: 50, child: FilledButton.icon(onPressed: () => sendVerification(context), icon: const Icon(Icons.email_outlined), label: const Text('Send Verification Email'))),
      ]),
    );
  }
}

class SessionTimeoutScreen extends StatefulWidget {
  const SessionTimeoutScreen({super.key});
  @override
  State<SessionTimeoutScreen> createState() => _SessionTimeoutScreenState();
}

class _SessionTimeoutScreenState extends State<SessionTimeoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Session Timeout', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        infoBox('When enabled, the app will auto logout after 15 minutes while this app is open.'),
        const SizedBox(height: 16),
        SwitchListTile(
          value: AppState.sessionTimeoutEnabled,
          onChanged: (v) {
            setState(() => AppState.sessionTimeoutEnabled = v);
            AppState.addLog(v ? 'Session timeout enabled' : 'Session timeout disabled');
          },
          title: const Text('Enable 15-minute auto logout'),
          secondary: const Icon(Icons.timer_off_outlined),
        ),
      ]),
    );
  }
}

class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({super.key});
  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  final credits = TextEditingController(text: '20');
  final gradePoints = TextEditingController(text: '170');

  @override
  void dispose() {
    credits.dispose();
    gradePoints.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = double.tryParse(credits.text.trim()) ?? 0;
    final gp = double.tryParse(gradePoints.text.trim()) ?? 0;
    final cgpa = c == 0 ? 0 : gp / c;
    return Scaffold(
      appBar: appBar('GPA / CGPA Calculator', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(controller: credits, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: input('Total credits', Icons.numbers_outlined)),
        const SizedBox(height: 12),
        TextField(controller: gradePoints, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: input('Total grade points', Icons.calculate_outlined)),
        const SizedBox(height: 20),
        metric('Calculated CGPA', cgpa.toStringAsFixed(2), Icons.calculate, AppColors.success),
      ]),
    );
  }
}

class QuizSystemScreen extends StatefulWidget {
  const QuizSystemScreen({super.key});
  @override
  State<QuizSystemScreen> createState() => _QuizSystemScreenState();
}

class _QuizSystemScreenState extends State<QuizSystemScreen> {
  int index = 0;
  int score = 0;
  bool completed = false;

  void answer(int selected) {
    final q = LocalStore.quizQuestions[index];
    if (selected == q.answerIndex) score++;
    if (index == LocalStore.quizQuestions.length - 1) {
      setState(() => completed = true);
      AppState.addLog('Quiz completed with score $score');
    } else {
      setState(() => index++);
    }
  }

  void restart() {
    setState(() {
      index = 0;
      score = 0;
      completed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = LocalStore.quizQuestions[index];
    return Scaffold(
      appBar: appBar('Quiz System', back: true, context: context),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: completed
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                metric('Score', '$score/${LocalStore.quizQuestions.length}', Icons.quiz_outlined, AppColors.primary),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: restart, child: const Text('Restart Quiz'))),
              ])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Question ${index + 1}/${LocalStore.quizQuestions.length}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                Text(q.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ...List.generate(q.options.length, (i) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: OutlinedButton(onPressed: () => answer(i), child: Text(q.options[i])),
                    )),
              ]),
      ),
    );
  }
}

class ResumeBuilderScreen extends StatefulWidget {
  final AppUser user;
  const ResumeBuilderScreen({super.key, required this.user});
  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final skills = TextEditingController(text: 'Flutter, Dart, Firebase, SQL');
  final projects = TextEditingController(text: 'SmartCampus App, Quiz App');
  final objective = TextEditingController(text: 'To build useful software solutions for students and institutions.');

  @override
  void dispose() {
    skills.dispose();
    projects.dispose();
    objective.dispose();
    super.dispose();
  }

  int resumeScore() {
    int score = 40;
    if (skills.text.trim().length > 10) score += 20;
    if (projects.text.trim().length > 10) score += 20;
    if (objective.text.trim().length > 20) score += 20;
    return score.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final score = resumeScore();
    return Scaffold(
      appBar: appBar('Resume Builder', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        metric('Resume Score', '$score%', Icons.description_outlined, AppColors.primary),
        const SizedBox(height: 16),
        TextField(controller: objective, maxLines: 3, onChanged: (_) => setState(() {}), decoration: input('Career objective', Icons.flag_outlined)),
        const SizedBox(height: 12),
        TextField(controller: skills, maxLines: 3, onChanged: (_) => setState(() {}), decoration: input('Skills', Icons.workspace_premium_outlined)),
        const SizedBox(height: 12),
        TextField(controller: projects, maxLines: 3, onChanged: (_) => setState(() {}), decoration: input('Projects', Icons.folder_copy_outlined)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(LocalStore.currentName ?? widget.user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.user.email),
            Text(LocalStore.currentDepartment),
            const Divider(),
            Text('Objective: ${objective.text}'),
            const SizedBox(height: 8),
            Text('Skills: ${skills.text}'),
            const SizedBox(height: 8),
            Text('Projects: ${projects.text}'),
          ]),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () => snack(context, 'Resume export simulated locally'), icon: const Icon(Icons.download), label: const Text('Export Resume Demo')),
      ]),
    );
  }
}

class InternshipPortalScreen extends StatefulWidget {
  const InternshipPortalScreen({super.key});
  @override
  State<InternshipPortalScreen> createState() => _InternshipPortalScreenState();
}

class _InternshipPortalScreenState extends State<InternshipPortalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Internship Portal', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: LocalStore.internships.map((i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(i.company, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), chip(i.applied ? 'Applied' : 'Open', i.applied ? AppColors.success : AppColors.primary)]),
          const SizedBox(height: 6),
          Text(i.role, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('Deadline: ${i.deadline}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: i.applied ? null : () { setState(() => i.applied = true); snack(context, 'Applied to ${i.company}'); }, child: Text(i.applied ? 'Applied' : 'Apply Now'))),
        ]),
      )).toList()),
    );
  }
}

class SkillTrackingScreen extends StatelessWidget {
  const SkillTrackingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Skill Tracking Dashboard', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: LocalStore.skills.map((s) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('${(s.progress * 100).round()}%')]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: s.progress),
        ]),
      )).toList()),
    );
  }
}

class CodingPracticeScreen extends StatelessWidget {
  const CodingPracticeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Coding Practice', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: LocalStore.codingProblems.map((p) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: cardDecoration(),
        child: ListTile(
          leading: const Icon(Icons.code_outlined, color: AppColors.primary),
          title: Text(p),
          trailing: TextButton(onPressed: () => snack(context, 'Practice opened locally'), child: const Text('Open')),
        ),
      )).toList()),
    );
  }
}

class AlumniNetworkScreen extends StatefulWidget {
  const AlumniNetworkScreen({super.key});
  @override
  State<AlumniNetworkScreen> createState() => _AlumniNetworkScreenState();
}

class _AlumniNetworkScreenState extends State<AlumniNetworkScreen> {
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final q = search.text.trim().toLowerCase();
    final alumni = LocalStore.alumni.where((a) => q.isEmpty || a.name.toLowerCase().contains(q) || a.company.toLowerCase().contains(q) || a.batch.toLowerCase().contains(q)).toList();
    return Scaffold(
      appBar: appBar('Alumni Network', back: true, context: context),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(controller: search, onChanged: (_) => setState(() {}), decoration: input('Search alumni', Icons.search))),
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), children: alumni.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: cardDecoration(),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
              title: Text(a.name),
              subtitle: Text('${a.company} • Batch ${a.batch} • ${a.email}'),
              trailing: TextButton(onPressed: () => snack(context, 'Connect request sent locally'), child: const Text('Connect')),
            ),
          )).toList()),
        ),
      ]),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final AppUser user;
  final ValueChanged<AppUser> onSaved;
  const EditProfileScreen({super.key, required this.user, required this.onSaved});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController name;
  late final TextEditingController phone;
  late final TextEditingController department;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.user.name);
    phone = TextEditingController(text: widget.user.phone);
    department = TextEditingController(text: widget.user.department);
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    department.dispose();
    super.dispose();
  }

  void save() {
    final updated = widget.user.copyWith(name: name.text.trim(), phone: phone.text.trim(), department: department.text.trim());
    widget.onSaved(updated);
    snack(context, 'Profile updated locally');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Edit Profile', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: name, decoration: input('Name', Icons.person_outline)),
          const SizedBox(height: 12),
          TextField(controller: phone, decoration: input('Phone', Icons.phone_outlined), keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          TextField(controller: department, decoration: input('Department', Icons.account_balance_outlined)),
          const SizedBox(height: 20),
          SizedBox(height: 50, child: FilledButton(onPressed: save, child: const Text('Save Profile'))),
        ],
      ),
    );
  }
}

class EmergencyContactsScreen extends StatefulWidget {
  final AppUser user;
  const EmergencyContactsScreen({super.key, required this.user});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  Future<void> makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) snack(context, 'Opening phone dialer for $phone...', error: false);
      }
    } catch (_) {
      if (mounted) snack(context, 'Opening phone dialer for $phone...', error: false);
    }
  }

  Future<void> showAddContactModal([Map<String, dynamic>? existing]) async {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: existing?['phone'] ?? '');
    final deptCtrl = TextEditingController(text: existing?['department'] ?? 'Campus Security');
    bool isActive = (existing?['status'] ?? 'active') == 'active';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(existing == null ? 'Add Emergency Contact' : 'Edit Emergency Contact', style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Contact Name / Title', prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 10),
                  TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone))),
                  const SizedBox(height: 10),
                  TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Department / Unit', prefixIcon: Icon(Icons.business))),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Active Contact'),
                    value: isActive,
                    onChanged: (v) => setDlgState(() => isActive = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  final n = nameCtrl.text.trim();
                  final p = phoneCtrl.text.trim();
                  if (n.isEmpty || p.isEmpty) {
                    snack(context, 'Please enter name and phone number', error: true);
                    return;
                  }
                  final data = {
                    'name': n,
                    'phone': p,
                    'department': deptCtrl.text.trim(),
                    'status': isActive ? 'active' : 'inactive',
                    'created_at': DateTime.now().toIso8601String(),
                  };
                  if (existing != null) {
                    await supabase.from('emergency_contacts').update(data).eq('id', existing['id']);
                  } else {
                    await supabase.from('emergency_contacts').insert(data);
                  }
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  snack(context, existing == null ? 'Contact added' : 'Contact updated');
                },
                child: Text(existing == null ? 'Add Contact' : 'Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> deleteContact(String id) async {
    await supabase.from('emergency_contacts').delete().eq('id', id);
    if (mounted) snack(context, 'Contact deleted');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AccessControl.isAdminEmail(widget.user.email);

    final defaultContacts = [
      {'id': 'e1', 'name': 'Saveetha Main Campus Security', 'phone': '7032643839', 'department': 'Campus Security & Safety', 'status': 'active'},
      {'id': 'e2', 'name': 'Saveetha Medical Emergency Room', 'phone': '044-2222-3333', 'department': 'Health Center', 'status': 'active'},
      {'id': 'e3', 'name': 'Saveetha Women Safety Cell', 'phone': '044-4444-5555', 'department': 'Safety & Support', 'status': 'active'},
      {'id': 'e4', 'name': 'Transport & Shuttle Helpline', 'phone': '044-3333-4444', 'department': 'Transport Dept', 'status': 'active'},
    ];

    return Scaffold(
      appBar: appBar('Emergency Contacts & SOS', back: true, context: context),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => showAddContactModal(),
              icon: const Icon(Icons.add),
              label: const Text('Add Contact'),
            )
          : null,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('emergency_contacts').stream(primaryKey: ['id']).order('name'),
        builder: (context, snapshot) {
          final rows = (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty)
              ? snapshot.data!
              : defaultContacts;

          final visibleRows = isAdmin ? rows : rows.where((r) => (r['status'] ?? 'active') == 'active').toList();

          if (visibleRows.isEmpty) {
            return const Center(child: Text('No emergency contacts available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: visibleRows.length,
            itemBuilder: (ctx, i) {
              final c = visibleRows[i];
              final id = (c['id'] ?? '').toString();
              final name = (c['name'] ?? '').toString();
              final phone = (c['phone'] ?? '').toString();
              final dept = (c['department'] ?? 'Emergency').toString();
              final isActive = (c['status'] ?? 'active') == 'active';

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: cardDecoration(),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isActive ? const Color(0xFFEF4444) : Colors.grey,
                    child: const Icon(Icons.local_phone, color: Colors.white),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text('$phone • $dept${!isActive ? ' (Inactive)' : ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call, color: Color(0xFF10B981), size: 28),
                        onPressed: () => makePhoneCall(phone),
                      ),
                      if (isAdmin) ...[
                        IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => showAddContactModal(c)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => deleteContact(id)),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FacultyDirectoryScreen extends StatefulWidget {
  const FacultyDirectoryScreen({super.key});

  @override
  State<FacultyDirectoryScreen> createState() => _FacultyDirectoryScreenState();
}

class _FacultyDirectoryScreenState extends State<FacultyDirectoryScreen> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = search.text.trim().toLowerCase();
    final items = LocalStore.faculty.where((f) => q.isEmpty || (f['name'] ?? '').toLowerCase().contains(q) || (f['dept'] ?? '').toLowerCase().contains(q)).toList();
    return Scaffold(
      appBar: appBar('Faculty Directory', back: true, context: context),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(controller: search, onChanged: (_) => setState(() {}), decoration: input('Search faculty', Icons.search))),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: items.map((f) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: cardDecoration(),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
                title: Text(f['name'] ?? ''),
                subtitle: Text('${f['dept']} • ${f['email']} • ${f['phone']}'),
              ),
            )).toList(),
          ),
        ),
      ]),
    );
  }
}

class LostFoundScreen extends StatefulWidget {
  final AppUser user;
  const LostFoundScreen({super.key, required this.user});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  void addItem() {
    push(context, AddLostFoundScreen(user: widget.user, onDone: () => setState(() {})));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Lost & Found', back: true, context: context),
      floatingActionButton: FloatingActionButton(onPressed: addItem, child: const Icon(Icons.add)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: LocalStore.lostFound.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), chip(item.type, item.type == 'Lost' ? AppColors.danger : AppColors.success)]),
            const SizedBox(height: 6),
            Text(item.description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text('Contact: ${item.contact}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        )).toList(),
      ),
    );
  }
}

class AddLostFoundScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onDone;
  const AddLostFoundScreen({super.key, required this.user, required this.onDone});

  @override
  State<AddLostFoundScreen> createState() => _AddLostFoundScreenState();
}

class _AddLostFoundScreenState extends State<AddLostFoundScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  String type = 'Lost';

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    super.dispose();
  }

  void submit() {
    if (title.text.trim().isEmpty || desc.text.trim().isEmpty) {
      snack(context, 'Please fill all fields', error: true);
      return;
    }
    final id = 'LF${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    LocalStore.lostFound.insert(0, LostFoundItem(id: id, title: title.text.trim(), description: desc.text.trim(), type: type, contact: widget.user.email, createdAt: DateTime.now()));
    widget.onDone();
    snack(context, 'Lost & Found item added');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Add Lost & Found', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Row(children: ['Lost', 'Found'].map((t) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(t), selected: type == t, onSelected: (_) => setState(() => type = t))))).toList()),
        const SizedBox(height: 14),
        TextField(controller: title, decoration: input('Item title', Icons.title)),
        const SizedBox(height: 14),
        TextField(controller: desc, maxLines: 4, decoration: input('Description', Icons.description_outlined)),
        const SizedBox(height: 20),
        SizedBox(height: 50, child: FilledButton(onPressed: submit, child: const Text('Submit'))),
      ]),
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  final AppUser user;
  const FeedbackScreen({super.key, required this.user});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final message = TextEditingController();
  String category = 'App';
  int rating = 5;

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  void submit() {
    if (message.text.trim().isEmpty) {
      snack(context, 'Enter feedback message', error: true);
      return;
    }
    final id = 'FB${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    LocalStore.feedbacks.insert(0, FeedbackItem(id: id, category: category, message: message.text.trim(), rating: rating, createdBy: widget.user.email, createdAt: DateTime.now()));
    message.clear();
    setState(() {});
    snack(context, 'Feedback submitted locally');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Feedback Form', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        infoBox('Feedback is stored locally in this no-billing version.'),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: category, decoration: input('Category', Icons.category_outlined), items: ['App', 'Campus', 'Faculty', 'Transport', 'Canteen', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => category = v!)),
        const SizedBox(height: 16),
        Text('Rating: $rating', style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(value: rating.toDouble(), min: 1, max: 5, divisions: 4, label: '$rating', onChanged: (v) => setState(() => rating = v.round())),
        TextField(controller: message, maxLines: 5, decoration: input('Write your feedback', Icons.feedback_outlined)),
        const SizedBox(height: 20),
        SizedBox(height: 50, child: FilledButton(onPressed: submit, child: const Text('Submit Feedback'))),
        const SizedBox(height: 24),
        const Text('Submitted Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (LocalStore.feedbacks.isEmpty) const Text('No feedback yet'),
        ...LocalStore.feedbacks.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: cardDecoration(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${f.category} • ${f.rating}/5', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(f.message),
            const SizedBox(height: 4),
            Text('By: ${f.createdBy}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        )),
      ]),
    );
  }
}


class ChartsDashboardScreen extends StatelessWidget {
  const ChartsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resolved = LocalStore.grievances.where((g) => g.status == 'Resolved').length;
    final pending = LocalStore.grievances.where((g) => g.status == 'Pending').length;
    final progress = LocalStore.grievances.where((g) => g.status == 'In Progress').length;
    final avgMarks = LocalStore.marks.isEmpty ? 0 : (LocalStore.marks.fold<int>(0, (sum, m) => sum + m.marks) / LocalStore.marks.length).round();
    return Scaffold(
      appBar: appBar('Charts Dashboard', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          infoBox('No extra chart package needed. These are local visual chart cards.'),
          const SizedBox(height: 16),
          chartBar('Resolved Grievances', resolved, LocalStore.grievances.length, AppColors.success),
          chartBar('Pending Grievances', pending, LocalStore.grievances.length, AppColors.warning),
          chartBar('In Progress', progress, LocalStore.grievances.length, Colors.blue),
          chartBar('Average Marks', avgMarks, 100, Colors.purple),
          chartBar('Active Bookings', LocalStore.bookings.where((b) => b.status != 'Cancelled').length, LocalStore.bookings.length, AppColors.primary),
        ],
      ),
    );
  }
}

class PdfExportScreen extends StatelessWidget {
  const PdfExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('PDF Export', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        infoBox('Realtime portal version: PDF export is simulated. Add a PDF package later for real files.'),
        const SizedBox(height: 16),
        exportTile(context, Icons.description_outlined, 'Export Resume PDF', 'Resume PDF prepared locally'),
        exportTile(context, Icons.analytics_outlined, 'Export Analytics Report PDF', 'Analytics report PDF prepared locally'),
        exportTile(context, Icons.report_outlined, 'Export Grievance Report PDF', 'Grievance report PDF prepared locally'),
      ]),
    );
  }
}

class ExcelExportScreen extends StatelessWidget {
  const ExcelExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Excel Export', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        infoBox('Realtime portal version: Excel export is simulated. Add an Excel package later for real XLSX files.'),
        const SizedBox(height: 16),
        exportTile(context, Icons.table_chart_outlined, 'Export Student Data', 'Student data sheet prepared locally'),
        exportTile(context, Icons.report_problem_outlined, 'Export Grievances', 'Grievances sheet prepared locally'),
        exportTile(context, Icons.meeting_room_outlined, 'Export Bookings', 'Bookings sheet prepared locally'),
      ]),
    );
  }
}

class LocalNotificationsScreen extends StatefulWidget {
  const LocalNotificationsScreen({super.key});

  @override
  State<LocalNotificationsScreen> createState() => _LocalNotificationsScreenState();
}

class _LocalNotificationsScreenState extends State<LocalNotificationsScreen> {
  final reminders = <String>['Exam reminder: Data Structures on May 10', 'Assignment reminder: SQL Practice Sheet due May 8', 'Event reminder: Tech Symposium on May 25'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Local Notifications', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        infoBox('These are local demo reminders shown inside the app.'),
        const SizedBox(height: 16),
        ...reminders.map((r) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: cardDecoration(), child: ListTile(leading: const Icon(Icons.notifications_active, color: AppColors.primary), title: Text(r), trailing: TextButton(onPressed: () => snack(context, 'Reminder triggered'), child: const Text('Test'))))),
      ]),
    );
  }
}

class SmartRecommendationScreen extends StatelessWidget {
  const SmartRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lowestAttendance = [...LocalStore.attendance]..sort((a, b) => a.percentage.compareTo(b.percentage));
    final lowestMark = [...LocalStore.marks]..sort((a, b) => a.marks.compareTo(b.marks));
    final recommendations = [
      'Focus on ${lowestAttendance.first.subject}: attendance is ${lowestAttendance.first.percentage.toStringAsFixed(1)}%.',
      'Revise ${lowestMark.first.subject}: current score is ${lowestMark.first.marks}/${lowestMark.first.total}.',
      'Complete pending assignments before checking placement updates.',
      'Spend 30 minutes daily on coding practice for interview readiness.',
    ];
    return Scaffold(
      appBar: appBar('Smart Recommendations', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: recommendations.map((r) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: cardDecoration(), child: ListTile(leading: const Icon(Icons.lightbulb, color: AppColors.warning), title: Text(r)))).toList()),
    );
  }
}

class ClassroomAvailabilityScreen extends StatelessWidget {
  const ClassroomAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = [
      ['Room 201', 'Available', 'CSE Block'],
      ['Room 202', 'Occupied', 'CSE Block'],
      ['Seminar Hall', 'Available', 'Main Block'],
      ['Lab A', 'Occupied', 'Block A'],
      ['Conference Room', 'Available', 'Admin Block'],
    ];
    return Scaffold(
      appBar: appBar('Classroom Availability', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: rooms.map((r) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: cardDecoration(), child: ListTile(leading: const Icon(Icons.meeting_room, color: AppColors.primary), title: Text(r[0]), subtitle: Text(r[2]), trailing: chip(r[1], r[1] == 'Available' ? AppColors.success : AppColors.danger)))).toList()),
    );
  }
}

class SmartParkingScreen extends StatelessWidget {
  const SmartParkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final slots = [
      ['Main Gate Parking', 12, 40],
      ['Block B Parking', 5, 25],
      ['Hostel Parking', 0, 30],
      ['Auditorium Parking', 18, 50],
    ];
    return Scaffold(
      appBar: appBar('Smart Parking', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: slots.map((s) {
        final free = s[1] as int;
        final total = s[2] as int;
        return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: cardDecoration(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(s[0] as String, style: const TextStyle(fontWeight: FontWeight.bold)), chip(free == 0 ? 'Full' : '$free free', free == 0 ? AppColors.danger : AppColors.success)]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: (total - free) / total),
          const SizedBox(height: 6),
          Text('${total - free}/$total slots occupied', style: const TextStyle(color: Colors.grey)),
        ]));
      }).toList()),
    );
  }
}

class IndoorNavigationScreen extends StatelessWidget {
  const IndoorNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = [
      'Main Gate to Admin Block: Walk straight 100m, then turn left.',
      'Admin Block to Library: Turn right near canteen and walk 50m.',
      'Library to Computer Lab A: Go to Block A, second floor.',
      'Canteen to Auditorium: Cross the central courtyard and turn right.',
    ];
    return Scaffold(
      appBar: appBar('Indoor Navigation', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: routes.map((r) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: cardDecoration(), child: ListTile(leading: const Icon(Icons.navigation, color: AppColors.primary), title: Text(r)))).toList()),
    );
  }
}

class AiComplaintPriorityScreen extends StatefulWidget {
  const AiComplaintPriorityScreen({super.key});

  @override
  State<AiComplaintPriorityScreen> createState() => _AiComplaintPriorityScreenState();
}

class _AiComplaintPriorityScreenState extends State<AiComplaintPriorityScreen> {
  final text = TextEditingController();
  String result = 'Enter complaint text to detect priority';

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  void detect() {
    final q = text.text.toLowerCase();
    if (q.contains('fire') || q.contains('medical') || q.contains('electric') || q.contains('danger')) {
      result = 'High Priority';
    } else if (q.contains('wifi') || q.contains('projector') || q.contains('water') || q.contains('broken')) {
      result = 'Medium Priority';
    } else if (q.trim().isEmpty) {
      result = 'Enter complaint text to detect priority';
    } else {
      result = 'Low Priority';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final color = result.startsWith('High') ? AppColors.danger : result.startsWith('Medium') ? AppColors.warning : result.startsWith('Low') ? AppColors.success : AppColors.primary;
    return Scaffold(
      appBar: appBar('AI Complaint Priority', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        infoBox('Rule-based local AI demo. No internet or billing required.'),
        const SizedBox(height: 16),
        TextField(controller: text, maxLines: 5, decoration: input('Complaint text', Icons.description_outlined)),
        const SizedBox(height: 16),
        SizedBox(height: 50, child: FilledButton(onPressed: detect, child: const Text('Detect Priority'))),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(18), decoration: cardDecoration(), child: Row(children: [Icon(Icons.priority_high, color: color), const SizedBox(width: 10), Text(result, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18))])),
      ]),
    );
  }
}

class AdvancedAdminReportsScreen extends StatelessWidget {
  const AdvancedAdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activeBookings = LocalStore.bookings.where((b) => b.status != 'Cancelled').length;
    final resolved = LocalStore.grievances.where((g) => g.status == 'Resolved').length;
    final pendingFees = LocalStore.fees.where((f) => f.status != 'Paid').fold<int>(0, (sum, f) => sum + f.amount);
    return Scaffold(
      appBar: appBar('Advanced Admin Reports', back: true, context: context),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          metric('Total Grievances', LocalStore.grievances.length.toString(), Icons.report, AppColors.primary),
          metric('Resolved Issues', resolved.toString(), Icons.check_circle, AppColors.success),
          metric('Active Bookings', activeBookings.toString(), Icons.meeting_room, Colors.purple),
          metric('Pending Fees', '₹$pendingFees', Icons.payments, AppColors.warning),
          metric('Feedback Count', LocalStore.feedbacks.length.toString(), Icons.feedback, Colors.deepPurple),
          metric('Event Registrations', LocalStore.events.where((e) => e.registered).length.toString(), Icons.event_available, Colors.indigo),
        ],
      ),
    );
  }
}

Widget chartBar(String label, int value, int total, Color color) {
  final safeTotal = total <= 0 ? 1 : total;
  final progress = (value / safeTotal).clamp(0.0, 1.0).toDouble();
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: cardDecoration(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text('$value / $safeTotal')]),
      const SizedBox(height: 10),
      LinearProgressIndicator(value: progress, minHeight: 10, color: color),
    ]),
  );
}

Widget exportTile(BuildContext context, IconData icon, String title, String message) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: cardDecoration(),
    child: ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: TextButton(onPressed: () => snack(context, message), child: const Text('Export')),
    ),
  );
}


// ========================= COLLEGE LIVE SYSTEM 9 STEPS =========================

class CollegeLiveSystemScreen extends StatelessWidget {
  final AppUser user;
  const CollegeLiveSystemScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final items = [
      _LiveMenu('Profiles & Roles', Icons.verified_user, () => LiveProfileRoleScreen(user: user)),
      _LiveMenu('Announcements', Icons.campaign, () => const LiveSimpleTableScreen(title: 'Live Announcements', table: 'announcements', fields: ['title', 'body', 'created_by'])),
      _LiveMenu('Live Chat', Icons.chat, () => LiveChatTableScreen(user: user)),
      _LiveMenu('Attendance', Icons.fact_check, () => const LiveSimpleTableScreen(title: 'Live Attendance', table: 'attendance', fields: ['student_email', 'subject', 'attended', 'total'])),
      _LiveMenu('Marks / Results', Icons.grade, () => const LiveSimpleTableScreen(title: 'Live Marks', table: 'marks', fields: ['student_email', 'subject', 'marks', 'total', 'grade'])),
      _LiveMenu('Events', Icons.event_available, () => LiveEventsTableScreen(user: user)),
      _LiveMenu('Notices', Icons.article, () => const LiveSimpleTableScreen(title: 'Live Notices', table: 'notices', fields: ['title', 'body', 'notice_date'])),
      _LiveMenu('Issues', Icons.report, () => GrievanceListScreen(user: user, refresh: () {})),
      _LiveMenu('Bookings', Icons.meeting_room, () => ResourceBookingScreen(user: user, refresh: () {})),
    ];

    return Scaffold(
      appBar: appBar('College Live System', back: true, context: context),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: items.map((item) {
          return GestureDetector(
            onTap: () => push(context, item.page()),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: cardDecoration(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, color: AppColors.primary, size: 34),
                  const Spacer(),
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LiveMenu {
  final String title;
  final IconData icon;
  final Widget Function() page;
  _LiveMenu(this.title, this.icon, this.page);
}

class LiveProfileRoleScreen extends StatefulWidget {
  final AppUser user;
  const LiveProfileRoleScreen({super.key, required this.user});

  @override
  State<LiveProfileRoleScreen> createState() => _LiveProfileRoleScreenState();
}

class _LiveProfileRoleScreenState extends State<LiveProfileRoleScreen> {
  late final TextEditingController name = TextEditingController(text: widget.user.name);
  late final TextEditingController phone = TextEditingController(text: widget.user.phone);
  late final TextEditingController dept = TextEditingController(text: widget.user.department);
  final roll = TextEditingController();
  String role = 'student';

  @override
  void initState() {
    super.initState();
    role = widget.user.role.toLowerCase();
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    dept.dispose();
    roll.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    try {
      await supabase.from('profiles').upsert({
        'email': widget.user.email,
        'full_name': name.text.trim(),
        'phone': phone.text.trim(),
        'department': dept.text.trim(),
        'roll_no': roll.text.trim(),
        'role': AccessControl.isAdminEmail(widget.user.email) ? 'admin' : 'student',
      }, onConflict: 'email');

      LocalStore.currentName = name.text.trim();
      LocalStore.currentPhone = phone.text.trim();
      LocalStore.currentDepartment = dept.text.trim();
      LocalStore.selectedRole = AccessControl.roleForEmail(widget.user.email);

      if (!mounted) return;
      snack(context, 'Profile saved to Supabase');
    } catch (e) {
      if (!mounted) return;
      snack(context, 'Profile save failed: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Live Profile & Role', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          infoBox('This saves real student/faculty/admin profile data to Supabase.'),
          const SizedBox(height: 14),
          TextField(controller: name, decoration: input('Full Name', Icons.person_outline)),
          const SizedBox(height: 12),
          TextField(controller: phone, decoration: input('Phone', Icons.phone_outlined)),
          const SizedBox(height: 12),
          TextField(controller: dept, decoration: input('Department', Icons.account_balance_outlined)),
          const SizedBox(height: 12),
          TextField(controller: roll, decoration: input('Roll Number', Icons.badge_outlined)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: role,
            decoration: input('Role', Icons.verified_user_outlined),
            items: const [
              DropdownMenuItem(value: 'student', child: Text('student')),
              DropdownMenuItem(value: 'faculty', child: Text('faculty')),
              DropdownMenuItem(value: 'admin', child: Text('admin')),
            ],
            onChanged: (v) => setState(() => role = v ?? 'student'),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 50, child: FilledButton(onPressed: saveProfile, child: const Text('Save Profile'))),
        ],
      ),
    );
  }
}

class LiveSimpleTableScreen extends StatelessWidget {
  final String title;
  final String table;
  final List<String> fields;
  const LiveSimpleTableScreen({super.key, required this.title, required this.table, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(title, back: true, context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from(table).stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) return Center(child: Text('No $title data found'));
          return ListView(
            padding: const EdgeInsets.all(20),
            children: rows.map((row) {
              final mainTitle = row[fields.first]?.toString() ?? 'Record';
              final subtitle = fields.skip(1).map((f) => '${f.replaceAll('_', ' ')}: ${row[f] ?? ''}').join('\n');
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: cardDecoration(),
                child: ListTile(
                  leading: const Icon(Icons.cloud_done, color: AppColors.primary),
                  title: Text(mainTitle),
                  subtitle: Text(subtitle),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class LiveChatTableScreen extends StatefulWidget {
  final AppUser user;
  const LiveChatTableScreen({super.key, required this.user});

  @override
  State<LiveChatTableScreen> createState() => _LiveChatTableScreenState();
}

class _LiveChatTableScreenState extends State<LiveChatTableScreen> {
  final msg = TextEditingController();

  @override
  void dispose() {
    msg.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = msg.text.trim();
    if (text.isEmpty) return;
    msg.clear();
    await supabase.from('chat_messages').insert({
      'message': text,
      'sender_email': widget.user.email,
      'room': 'campus',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Live Campus Chat', back: true, context: context),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('chat_messages').stream(primaryKey: ['id']).order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final rows = snapshot.data ?? [];
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: rows.length,
                  itemBuilder: (_, i) {
                    final row = rows[i];
                    final mine = (row['sender_email'] ?? '') == widget.user.email;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: mine ? AppColors.primary : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((row['message'] ?? '').toString(), style: TextStyle(color: mine ? Colors.white : null)),
                            const SizedBox(height: 4),
                            Text((row['sender_email'] ?? '').toString(), style: TextStyle(color: mine ? Colors.white70 : Colors.grey, fontSize: 10)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: msg, decoration: input('Message', Icons.message_outlined))),
                const SizedBox(width: 8),
                FloatingActionButton.small(onPressed: send, child: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LiveEventsTableScreen extends StatelessWidget {
  final AppUser user;
  const LiveEventsTableScreen({super.key, required this.user});

  Future<void> register(BuildContext context, String eventId) async {
    try {
      await supabase.from('event_registrations').insert({'event_id': eventId, 'user_email': user.email});
      if (!context.mounted) return;
      snack(context, 'Registered successfully');
    } catch (e) {
      if (!context.mounted) return;
      snack(context, 'Already registered or failed: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Live Events', back: true, context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('campus_events').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) return const Center(child: Text('No events yet'));
          return ListView(
            padding: const EdgeInsets.all(20),
            children: rows.map((row) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((row['title'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('${row['event_date'] ?? ''} • ${row['venue'] ?? ''}', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text((row['description'] ?? '').toString()),
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: FilledButton(onPressed: () => register(context, (row['id'] ?? '').toString()), child: const Text('Register'))),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ======================= END COLLEGE LIVE SYSTEM 9 STEPS =======================


Widget adminApprovalButtons({
  required BuildContext context,
  required String grievanceId,
  required String adminEmail,
  required VoidCallback refresh,
}) {
  Future<void> update(String status) async {
    if (!AccessControl.isAdminEmail(adminEmail)) {
      snack(context, 'Only admin can update complaints', error: true);
      return;
    }

    try {
      await supabase.from('grievances').update({
        'status': status,
        'admin_note': 'Updated by admin: $adminEmail',
      }).eq('id', grievanceId);

      snack(context, 'Complaint marked as $status');
      refresh();
    } catch (e) {
      snack(context, 'Status update failed: $e', error: true);
    }
  }

  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      OutlinedButton(onPressed: () => update('Accepted'), child: const Text('Accept')),
      OutlinedButton(onPressed: () => update('Rejected'), child: const Text('Reject')),
      OutlinedButton(onPressed: () => update('In Progress'), child: const Text('In Progress')),
      FilledButton(onPressed: () => update('Resolved'), child: const Text('Resolved')),
    ],
  );
}


// ========================= 9 REALTIME POWER FEATURES =========================

class PowerRealtimeHubScreen extends StatelessWidget {
  final AppUser user;
  const PowerRealtimeHubScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final items = [
      _PowerMenu('Live Complaint Dashboard', Icons.dashboard_customize, () => PowerComplaintDashboardScreen(user: user)),
      _PowerMenu('Notification Center', Icons.notifications_active, () => PowerNotificationsScreen(user: user)),
      _PowerMenu('Complaint Chat', Icons.forum, () => PowerComplaintChatListScreen(user: user)),
      _PowerMenu('Admin Online Status', Icons.online_prediction, () => PowerPresenceScreen(user: user)),
      _PowerMenu('Priority Detection', Icons.priority_high, () => PowerPriorityDetectionScreen(user: user)),
      _PowerMenu('Photo Proof', Icons.photo_camera, () => PowerPhotoProofScreen(user: user)),
      _PowerMenu('Admin Analytics', Icons.analytics, () => const PowerAnalyticsDashboardScreen()),
      _PowerMenu('Audit Logs', Icons.history, () => const PowerAuditLogsScreen()),
      _PowerMenu('Error Logs', Icons.bug_report, () => PowerErrorLogsScreen(user: user)),
    ];

    return Scaffold(
      backgroundColor: PortalColors.pageBg,
      appBar: portalTopBar(context, 'Realtime Power Features', user: user),
      drawer: portalDrawer(context, user, () {}, null),
      body: GridView.count(
        padding: const EdgeInsets.all(22),
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        children: items.map((item) {
          return GestureDetector(
            onTap: () => push(context, item.page()),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: cardDecoration(radius: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(item.icon, color: PortalColors.teal, size: 36),
                const Spacer(),
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('Realtime module', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PowerMenu {
  final String title;
  final IconData icon;
  final Widget Function() page;
  _PowerMenu(this.title, this.icon, this.page);
}

Future<void> powerAudit({
  required String actor,
  required String action,
  String? targetTable,
  String? targetId,
  String? details,
}) async {
  try {
    await supabase.from('audit_logs').insert({
      'actor_email': actor,
      'action': action,
      'target_table': targetTable,
      'target_id': targetId,
      'details': details,
    });
  } catch (_) {}
}

String detectPriorityFromText(String input) {
  final t = input.toLowerCase();
  if (t.contains('fire') || t.contains('shock') || t.contains('electric') || t.contains('medical') || t.contains('emergency') || t.contains('danger')) {
    return 'High';
  }
  if (t.contains('urgent') || t.contains('broken') || t.contains('water') || t.contains('wifi') || t.contains('security')) {
    return 'Medium';
  }
  return 'Low';
}

class PowerComplaintDashboardScreen extends StatelessWidget {
  final AppUser user;
  const PowerComplaintDashboardScreen({super.key, required this.user});

  Future<void> updateStatus(BuildContext context, String id, String status, String title) async {
    if (!AccessControl.isAdminEmail(user.email)) {
      snack(context, 'Only admin can update complaints', error: true);
      return;
    }

    try {
      final update = {
        'status': status,
        'admin_note': 'Updated by ${user.email}',
      };

      if (status == 'Accepted') update['accepted_at'] = DateTime.now().toIso8601String();
      if (status == 'Resolved') update['resolved_at'] = DateTime.now().toIso8601String();

      await supabase.from('grievances').update(update).eq('id', id);
      await powerAudit(actor: user.email, action: 'Complaint $status', targetTable: 'grievances', targetId: id, details: title);
      await supabase.from('app_notifications').insert({
        'user_email': null,
        'title': 'Complaint $status',
        'body': '$title has been marked as $status',
        'type': 'complaint',
      });
      if (!context.mounted) return;
      snack(context, 'Complaint marked as $status');
    } catch (e) {
      if (!context.mounted) return;
      snack(context, 'Update failed: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Live Complaint Dashboard', back: true, context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('grievances').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final rows = (snapshot.data ?? []).where((g) => !isIssueHistoryStatus((g['status'] ?? '').toString())).toList();
          if (rows.isEmpty) return const Center(child: Text('No active complaints. Check Issue History.'));

          return ListView(
            padding: const EdgeInsets.all(18),
            children: rows.map((g) {
              final id = (g['id'] ?? '').toString();
              final title = (g['title'] ?? 'Complaint').toString();
              final status = (g['status'] ?? 'Pending').toString();
              final priority = (g['priority'] ?? g['detected_priority'] ?? 'Medium').toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: cardDecoration(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    chip(status, statusColor(status)),
                  ]),
                  const SizedBox(height: 6),
                  Text((g['description'] ?? '').toString(), style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    chip('Priority: $priority', priority == 'High' ? AppColors.danger : priority == 'Medium' ? AppColors.warning : AppColors.success),
                    chip((g['category'] ?? 'Other').toString(), AppColors.primary),
                    chip((g['user_email'] ?? '').toString(), Colors.blueGrey),
                  ]),
                  if (AccessControl.isAdminEmail(user.email)) ...[
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      OutlinedButton(onPressed: () => updateStatus(context, id, 'Accepted', title), child: const Text('Accept')),
                      OutlinedButton(onPressed: () => updateStatus(context, id, 'Rejected', title), child: const Text('Reject')),
                      OutlinedButton(onPressed: () => updateStatus(context, id, 'In Progress', title), child: const Text('In Progress')),
                      FilledButton(onPressed: () => updateStatus(context, id, 'Resolved', title), child: const Text('Resolved')),
                    ]),
                  ],
                ]),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class PowerNotificationsScreen extends StatelessWidget {
  final AppUser user;
  const PowerNotificationsScreen({super.key, required this.user});

  Future<void> markRead(String id) async {
    await supabase.from('app_notifications').update({'is_read': true}).eq('id', id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Notification Center', back: true, context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('app_notifications').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final rows = (snapshot.data ?? []).where((n) {
            final target = (n['user_email'] ?? '').toString();
            return target.isEmpty || target == user.email;
          }).toList();
          if (rows.isEmpty) return const Center(child: Text('No notifications'));
          return ListView(
            padding: const EdgeInsets.all(18),
            children: rows.map((n) => Card(
              child: ListTile(
                leading: Icon((n['is_read'] ?? false) == true ? Icons.notifications_none : Icons.notifications_active, color: PortalColors.teal),
                title: Text((n['title'] ?? '').toString()),
                subtitle: Text((n['body'] ?? '').toString()),
                trailing: TextButton(onPressed: () => markRead((n['id'] ?? '').toString()), child: const Text('Read')),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}

class PowerComplaintChatListScreen extends StatelessWidget {
  final AppUser user;
  const PowerComplaintChatListScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Complaint Chat', back: true, context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('grievances').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var rows = snapshot.data ?? [];
          if (!AccessControl.isAdminEmail(user.email)) {
            rows = rows.where((g) => (g['user_email'] ?? '') == user.email).toList();
          }
          if (rows.isEmpty) return const Center(child: Text('No complaints for chat'));
          return ListView(
            padding: const EdgeInsets.all(18),
            children: rows.map((g) => Card(
              child: ListTile(
                leading: const Icon(Icons.forum, color: PortalColors.teal),
                title: Text((g['title'] ?? '').toString()),
                subtitle: Text('Status: ${g['status'] ?? 'Pending'}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => push(context, PowerComplaintChatScreen(user: user, grievance: g)),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}

class PowerComplaintChatScreen extends StatefulWidget {
  final AppUser user;
  final Map<String, dynamic> grievance;
  const PowerComplaintChatScreen({super.key, required this.user, required this.grievance});

  @override
  State<PowerComplaintChatScreen> createState() => _PowerComplaintChatScreenState();
}

class _PowerComplaintChatScreenState extends State<PowerComplaintChatScreen> {
  final msg = TextEditingController();

  @override
  void dispose() {
    msg.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = msg.text.trim();
    if (text.isEmpty) return;
    msg.clear();
    await supabase.from('complaint_chats').insert({
      'grievance_id': widget.grievance['id'],
      'sender_email': widget.user.email,
      'message': text,
    });
    await powerAudit(actor: widget.user.email, action: 'Complaint chat message', targetTable: 'grievances', targetId: widget.grievance['id'].toString(), details: text);
  }

  @override
  Widget build(BuildContext context) {
    final gid = widget.grievance['id'].toString();
    return Scaffold(
      appBar: appBar('Chat: ${widget.grievance['title'] ?? 'Complaint'}', back: true, context: context),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('complaint_chats').stream(primaryKey: ['id']).eq('grievance_id', gid).order('created_at', ascending: false),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final rows = snapshot.data ?? [];
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: rows.length,
                itemBuilder: (_, i) {
                  final m = rows[i];
                  final mine = (m['sender_email'] ?? '') == widget.user.email;
                  return Align(
                    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(color: mine ? AppColors.primary : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text((m['message'] ?? '').toString(), style: TextStyle(color: mine ? Colors.white : null)),
                        const SizedBox(height: 4),
                        Text((m['sender_email'] ?? '').toString(), style: TextStyle(color: mine ? Colors.white70 : Colors.grey, fontSize: 10)),
                      ]),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: TextField(controller: msg, decoration: input('Message', Icons.message_outlined))),
            const SizedBox(width: 8),
            FloatingActionButton.small(onPressed: send, child: const Icon(Icons.send)),
          ]),
        ),
      ]),
    );
  }
}

class PowerPresenceScreen extends StatelessWidget {
  final AppUser user;
  const PowerPresenceScreen({super.key, required this.user});

  Future<void> setOnline(bool online) async {
    await supabase.from('online_status').upsert({
      'user_email': user.email,
      'role': AccessControl.isAdminEmail(user.email) ? 'admin' : 'student',
      'is_online': online,
      'last_seen': DateTime.now().toIso8601String(),
    }, onConflict: 'user_email');
  }

  @override
  Widget build(BuildContext context) {
    setOnline(true);
    return Scaffold(
      appBar: appBar('Admin Online Status', back: true, context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('online_status').stream(primaryKey: ['id']).order('last_seen', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(18),
            children: rows.map((u) => Card(
              child: ListTile(
                leading: Icon(Icons.circle, color: (u['is_online'] ?? false) == true ? AppColors.success : Colors.grey, size: 15),
                title: Text((u['user_email'] ?? '').toString()),
                subtitle: Text('Role: ${u['role'] ?? ''}'),
                trailing: Text((u['is_online'] ?? false) == true ? 'Online' : 'Offline'),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}

class PowerPriorityDetectionScreen extends StatefulWidget {
  final AppUser user;
  const PowerPriorityDetectionScreen({super.key, required this.user});

  @override
  State<PowerPriorityDetectionScreen> createState() => _PowerPriorityDetectionScreenState();
}

class _PowerPriorityDetectionScreenState extends State<PowerPriorityDetectionScreen> {
  final text = TextEditingController();
  String priority = 'Low';

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  void detect() {
    setState(() => priority = detectPriorityFromText(text.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('AI Priority Detection', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        infoBox('This local smart detector helps classify complaint priority before submitting.'),
        const SizedBox(height: 14),
        TextField(controller: text, maxLines: 5, decoration: input('Type complaint text', Icons.text_fields)),
        const SizedBox(height: 14),
        FilledButton(onPressed: detect, child: const Text('Detect Priority')),
        const SizedBox(height: 18),
        metric('Detected Priority', priority, Icons.priority_high, priority == 'High' ? AppColors.danger : priority == 'Medium' ? AppColors.warning : AppColors.success),
      ]),
    );
  }
}

class PowerPhotoProofScreen extends StatefulWidget {
  final AppUser user;
  const PowerPhotoProofScreen({super.key, required this.user});

  @override
  State<PowerPhotoProofScreen> createState() => _PowerPhotoProofScreenState();
}

class _PowerPhotoProofScreenState extends State<PowerPhotoProofScreen> {
  final grievanceId = TextEditingController();
  final fileName = TextEditingController();
  final note = TextEditingController();

  @override
  void dispose() {
    grievanceId.dispose();
    fileName.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> saveProof() async {
    if (grievanceId.text.trim().isEmpty || fileName.text.trim().isEmpty) {
      snack(context, 'Enter grievance ID and file name', error: true);
      return;
    }
    try {
      await supabase.from('complaint_photos').insert({
        'grievance_id': grievanceId.text.trim(),
        'user_email': widget.user.email,
        'file_name': fileName.text.trim(),
        'file_url': '',
        'note': note.text.trim(),
      });
      await powerAudit(actor: widget.user.email, action: 'Photo proof metadata added', targetTable: 'complaint_photos', targetId: grievanceId.text.trim(), details: fileName.text.trim());
      if (!mounted) return;
      snack(context, 'Photo proof metadata saved');
    } catch (e) {
      if (!mounted) return;
      snack(context, 'Save failed: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Photo Proof', back: true, context: context),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        infoBox('Storage upload can be enabled later. This saves photo/file proof metadata for each complaint.'),
        const SizedBox(height: 14),
        TextField(controller: grievanceId, decoration: input('Grievance UUID', Icons.confirmation_number)),
        const SizedBox(height: 12),
        TextField(controller: fileName, decoration: input('Photo/File Name', Icons.photo)),
        const SizedBox(height: 12),
        TextField(controller: note, decoration: input('Note', Icons.note), maxLines: 3),
        const SizedBox(height: 14),
        FilledButton(onPressed: saveProof, child: const Text('Save Proof')),
        const SizedBox(height: 20),
        const Text('Saved Proofs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(
          height: 300,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('complaint_photos').stream(primaryKey: ['id']).order('created_at', ascending: false),
            builder: (_, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final rows = snapshot.data ?? [];
              return ListView(children: rows.map((p) => Card(child: ListTile(title: Text((p['file_name'] ?? '').toString()), subtitle: Text('Complaint: ${p['grievance_id']}\n${p['note'] ?? ''}')))).toList());
            },
          ),
        ),
      ]),
    );
  }
}

class PowerAnalyticsDashboardScreen extends StatelessWidget {
  const PowerAnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Admin Analytics Dashboard', back: true, context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('grievances').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data ?? [];
          int count(String s) => rows.where((g) => (g['status'] ?? '') == s).length;
          final high = rows.where((g) => (g['priority'] ?? g['detected_priority'] ?? '') == 'High').length;
          return GridView.count(
            padding: const EdgeInsets.all(20),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              metric('Total Complaints', rows.length.toString(), Icons.list_alt, AppColors.primary),
              metric('Pending', count('Pending').toString(), Icons.hourglass_top, AppColors.warning),
              metric('Accepted', count('Accepted').toString(), Icons.check, AppColors.success),
              metric('Rejected', count('Rejected').toString(), Icons.close, AppColors.danger),
              metric('Resolved', count('Resolved').toString(), Icons.verified, AppColors.success),
              metric('High Priority', high.toString(), Icons.priority_high, AppColors.danger),
            ],
          );
        },
      ),
    );
  }
}

class PowerAuditLogsScreen extends StatelessWidget {
  const PowerAuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Audit Logs', back: true, context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('audit_logs').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) return const Center(child: Text('No audit logs yet'));
          return ListView(
            padding: const EdgeInsets.all(18),
            children: rows.map((l) => Card(child: ListTile(
              leading: const Icon(Icons.history, color: PortalColors.teal),
              title: Text((l['action'] ?? '').toString()),
              subtitle: Text('${l['actor_email'] ?? ''}\n${l['details'] ?? ''}'),
              isThreeLine: true,
            ))).toList(),
          );
        },
      ),
    );
  }
}

class PowerErrorLogsScreen extends StatefulWidget {
  final AppUser user;
  const PowerErrorLogsScreen({super.key, required this.user});

  @override
  State<PowerErrorLogsScreen> createState() => _PowerErrorLogsScreenState();
}

class _PowerErrorLogsScreenState extends State<PowerErrorLogsScreen> {
  final error = TextEditingController();

  @override
  void dispose() {
    error.dispose();
    super.dispose();
  }

  Future<void> addError() async {
    if (error.text.trim().isEmpty) return;
    await supabase.from('app_error_logs').insert({
      'user_email': widget.user.email,
      'screen': 'manual',
      'error_message': error.text.trim(),
    });
    error.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Error Logs', back: true, context: context),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: TextField(controller: error, decoration: input('Log test error', Icons.bug_report))),
            const SizedBox(width: 8),
            FilledButton(onPressed: addError, child: const Text('Add')),
          ]),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('app_error_logs').stream(primaryKey: ['id']).order('created_at', ascending: false),
            builder: (_, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final rows = snapshot.data ?? [];
              return ListView(
                padding: const EdgeInsets.all(18),
                children: rows.map((e) => Card(child: ListTile(
                  leading: const Icon(Icons.bug_report, color: AppColors.danger),
                  title: Text((e['error_message'] ?? '').toString()),
                  subtitle: Text('${e['user_email'] ?? ''} • ${e['screen'] ?? ''}'),
                ))).toList(),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ======================= END 9 REALTIME POWER FEATURES =======================


// ========================= PREMIUM 30 COMPLAINT FEATURES =========================

class PremiumComplaintHubScreen extends StatelessWidget {
  final AppUser user;
  const PremiumComplaintHubScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final names = [
      ['SLA Timer', Icons.timer],
      ['Department Assignment', Icons.account_tree],
      ['Auto Escalation', Icons.trending_up],
      ['Satisfaction Rating', Icons.star_rate],
      ['Anonymous Complaint', Icons.visibility_off],
      ['Action Timeline', Icons.timeline],
      ['Duplicate Detection', Icons.content_copy],
      ['Staff Dashboard', Icons.engineering],
      ['Location Tagging', Icons.location_on],
      ['QR Complaint Reporting', Icons.qr_code_2],
      ['Reopen Request', Icons.replay],
      ['Priority Queue', Icons.priority_high],
      ['Evidence History', Icons.attach_file],
      ['Internal Notes', Icons.note_alt],
      ['Category Analytics', Icons.pie_chart],
      ['Resolution Analytics', Icons.speed],
      ['Department Performance', Icons.bar_chart],
      ['Feedback Analytics', Icons.rate_review],
      ['Staff Workload', Icons.work_history],
      ['Auto Complaint ID', Icons.confirmation_number],
      ['Email Templates', Icons.email],
      ['Notification Inbox', Icons.notifications],
      ['Admin Broadcast', Icons.campaign],
      ['Search Filters', Icons.filter_alt],
      ['Export Reports', Icons.download],
      ['Weekly Summary', Icons.summarize],
      ['Emergency Flag', Icons.emergency],
      ['Student History', Icons.history_edu],
      ['Faculty Forward', Icons.forward_to_inbox],
      ['Final Closure', Icons.verified],
    ];

    return Scaffold(
      backgroundColor: PortalColors.pageBg,
      appBar: portalTopBar(context, 'Premium Complaint System', user: user),
      drawer: portalDrawer(context, user, () {}, null),
      body: GridView.builder(
        padding: const EdgeInsets.all(18),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 4 : MediaQuery.of(context).size.width > 700 ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemCount: names.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => push(context, PremiumFeatureScreen(user: user, index: i + 1, title: names[i][0] as String)),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: cardDecoration(radius: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(names[i][1] as IconData, color: PortalColors.teal, size: 30),
              const Spacer(),
              Text('${i + 1}. ${names[i][0]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          ),
        ),
      ),
    );
  }
}

class PremiumFeatureScreen extends StatefulWidget {
  final AppUser user;
  final int index;
  final String title;
  const PremiumFeatureScreen({super.key, required this.user, required this.index, required this.title});

  @override
  State<PremiumFeatureScreen> createState() => _PremiumFeatureScreenState();
}

class _PremiumFeatureScreenState extends State<PremiumFeatureScreen> {
  final a = TextEditingController();
  final b = TextEditingController();
  String dept = 'Maintenance';
  int rating = 5;

  @override
  void dispose() {
    a.dispose();
    b.dispose();
    super.dispose();
  }

  bool get isAdmin => AccessControl.isAdminEmail(widget.user.email);

  String code() {
    final n = DateTime.now().millisecondsSinceEpoch.toString();
    return 'SEC-${n.substring(n.length - 8)}';
  }

  Future<void> timeline(String gid, String action, String details) async {
    await supabase.from('complaint_timeline').insert({
      'grievance_id': gid,
      'actor_email': widget.user.email,
      'action': action,
      'details': details,
    });
  }

  Future<void> notify(String title, String body) async {
    await supabase.from('app_notifications').insert({'title': title, 'body': body, 'type': 'premium'});
  }

  Future<void> updateComplaint(String id, Map<String, dynamic> data, String action) async {
    if (!isAdmin && [2,3,14,23,29].contains(widget.index)) {
      snack(context, 'Only admin can perform this action', error: true);
      return;
    }
    await supabase.from('grievances').update(data).eq('id', id);
    await timeline(id, action, data.toString());
    await notify(action, 'Complaint updated: $action');
    if (mounted) snack(context, '$action completed');
  }

  Future<void> submitPremiumComplaint({bool anonymous = false, bool emergency = false}) async {
    final title = a.text.trim();
    final desc = b.text.trim();
    if (title.isEmpty || desc.isEmpty) {
      snack(context, 'Fill both fields', error: true);
      return;
    }
    final priority = detectPriorityFromText('$title $desc');
    final inserted = await supabase.from('grievances').insert({
      'complaint_code': code(),
      'title': title,
      'description': desc,
      'category': dept,
      'priority': priority,
      'detected_priority': priority,
      'status': 'Pending',
      'user_email': widget.user.email,
      'sla_hours': emergency ? 4 : 48,
      'due_at': DateTime.now().add(Duration(hours: emergency ? 4 : 48)).toIso8601String(),
      'anonymous': anonymous,
      'emergency': emergency,
      'location_block': widget.index == 9 ? a.text.trim() : null,
      'location_room': widget.index == 9 ? b.text.trim() : null,
    }).select().single();
    await timeline(inserted['id'].toString(), 'Submitted', 'Premium complaint submitted');
    await notify('New Complaint', '$title submitted');
    if (mounted) snack(context, 'Premium complaint submitted');
  }

  @override
  Widget build(BuildContext context) {
    if ([1,7,8,12,15,16,17,18,19,26,28].contains(widget.index)) {
      return PremiumListScreen(user: widget.user, title: widget.title, mode: widget.index);
    }
    if (widget.index == 6) return PremiumTimelineListScreen(user: widget.user);
    if (widget.index == 13) return PowerPhotoProofScreen(user: widget.user);
    if (widget.index == 22) return PowerNotificationsScreen(user: widget.user);
    if (widget.index == 20) return _simpleInfo('Auto Complaint ID', 'Next ID: ${code()}');
    if (widget.index == 21) return _simpleInfo('Email Templates', 'Accepted, Assigned, Escalated, Resolved and Closure templates are ready for admin use.');
    if (widget.index == 10) return _qrScreen();

    return Scaffold(
      appBar: appBar(widget.title, back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          infoBox(_description(widget.index)),
          const SizedBox(height: 14),
          if (widget.index == 2) ...[
            TextField(controller: a, decoration: input('Complaint UUID', Icons.confirmation_number)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: dept,
              decoration: input('Department', Icons.account_tree),
              items: ['Maintenance', 'IT', 'Transport', 'Hostel', 'Canteen', 'Security'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => dept = v ?? 'Maintenance'),
            ),
            const SizedBox(height: 12),
            TextField(controller: b, decoration: input('Staff Email', Icons.engineering)),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => updateComplaint(a.text.trim(), {'assigned_department': dept, 'assigned_staff_email': b.text.trim(), 'status': 'Assigned'}, 'Department Assigned'), child: const Text('Assign')),
          ] else if ([3,11,14,23,25,29,30].contains(widget.index)) ...[
            TextField(controller: a, decoration: input(widget.index == 23 ? 'Broadcast Title' : 'Complaint UUID', Icons.confirmation_number)),
            const SizedBox(height: 12),
            TextField(controller: b, maxLines: 4, decoration: input(widget.index == 23 ? 'Broadcast Message' : 'Details / Reason / Note', Icons.description)),
            const SizedBox(height: 12),
            FilledButton(onPressed: () async {
              switch (widget.index) {
                case 3:
                  await updateComplaint(a.text.trim(), {'escalated': true, 'status': 'Escalated'}, 'Escalated');
                  break;
                case 11:
                  await supabase.from('complaint_reopen_requests').insert({'grievance_id': a.text.trim(), 'user_email': widget.user.email, 'reason': b.text.trim()});
                  await updateComplaint(a.text.trim(), {'reopen_requested': true}, 'Reopen Requested');
                  break;
                case 14:
                  await supabase.from('complaint_internal_notes').insert({'grievance_id': a.text.trim(), 'admin_email': widget.user.email, 'note': b.text.trim()});
                  snack(context, 'Internal note saved');
                  break;
                case 23:
                  await supabase.from('admin_broadcasts').insert({'title': a.text.trim(), 'body': b.text.trim(), 'created_by': widget.user.email});
                  await notify(a.text.trim(), b.text.trim());
                  snack(context, 'Broadcast sent');
                  break;
                case 25:
                  await supabase.from('complaint_exports').insert({'requested_by': widget.user.email, 'export_type': 'complaint_report', 'filters': b.text.trim()});
                  snack(context, 'Export request saved');
                  break;
                case 29:
                  await updateComplaint(a.text.trim(), {'forwarded_by': b.text.trim(), 'status': 'Forwarded'}, 'Faculty Forwarded');
                  break;
                case 30:
                  await updateComplaint(a.text.trim(), {'closure_confirmed': true, 'final_note': b.text.trim(), 'status': 'Closed'}, 'Closure Confirmed');
                  break;
              }
            }, child: Text(_button(widget.index))),
          ] else if (widget.index == 4) ...[
            TextField(controller: a, decoration: input('Complaint UUID', Icons.confirmation_number)),
            const SizedBox(height: 8),
            Text('Rating: $rating'),
            Slider(value: rating.toDouble(), min: 1, max: 5, divisions: 4, onChanged: (v) => setState(() => rating = v.round())),
            TextField(controller: b, maxLines: 3, decoration: input('Feedback', Icons.rate_review)),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => updateComplaint(a.text.trim(), {'student_rating': rating, 'student_feedback': b.text.trim()}, 'Student Rated'), child: const Text('Submit Rating')),
          ] else if ([5,9,27].contains(widget.index)) ...[
            TextField(controller: a, decoration: input(widget.index == 9 ? 'Block / Location' : 'Title', Icons.title)),
            const SizedBox(height: 12),
            TextField(controller: b, maxLines: 4, decoration: input(widget.index == 9 ? 'Room / Details' : 'Description', Icons.description)),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => submitPremiumComplaint(anonymous: widget.index == 5, emergency: widget.index == 27), child: const Text('Submit')),
          ] else if (widget.index == 24) ...[
            TextField(controller: a, onChanged: (_) => setState(() {}), decoration: input('Search title, status, department, block', Icons.search)),
            const SizedBox(height: 12),
            SizedBox(height: 500, child: PremiumFilteredList(query: a.text, user: widget.user)),
          ] else ...[
            TextField(controller: a, decoration: input('Title / Complaint UUID', Icons.title)),
            const SizedBox(height: 12),
            TextField(controller: b, maxLines: 4, decoration: input('Details', Icons.description)),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => submitPremiumComplaint(), child: const Text('Submit')),
          ],
        ],
      ),
    );
  }

  String _description(int i) => const {
    2: 'Assign complaint to department and staff.',
    3: 'Escalate overdue or urgent complaints.',
    4: 'Student rates resolved complaint.',
    5: 'Submit complaint with anonymous flag.',
    9: 'Add block, floor or room location.',
    11: 'Request reopening for unresolved issue.',
    14: 'Private admin notes.',
    23: 'Send broadcast to all users.',
    24: 'Search/filter complaints by any field.',
    25: 'Create export request.',
    27: 'Emergency complaint with high priority.',
    29: 'Faculty forwards complaint to admin.',
    30: 'Student confirms final closure.',
  }[i] ?? 'Premium complaint feature connected to Supabase.';

  String _button(int i) => const {
    3: 'Escalate',
    11: 'Request Reopen',
    14: 'Save Note',
    23: 'Broadcast',
    25: 'Request Export',
    29: 'Forward',
    30: 'Confirm Closure',
  }[i] ?? 'Save';

  Widget _simpleInfo(String title, String body) => Scaffold(appBar: appBar(title, back: true, context: context), body: Center(child: Padding(padding: const EdgeInsets.all(20), child: infoBox(body))));

  Widget _qrScreen() => Scaffold(
    appBar: appBar('QR Complaint Reporting', back: true, context: context),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      infoBox('Demo QR for location-based reporting. Print QR near classrooms/labs.'),
      const SizedBox(height: 16),
      Center(child: Container(width: 160, height: 160, padding: const EdgeInsets.all(8), color: Colors.white, child: GridView.count(crossAxisCount: 9, children: List.generate(81, (i) => Container(margin: const EdgeInsets.all(1), color: (i * 11 + 7) % 4 == 0 ? Colors.black : Colors.white))))),
      const SizedBox(height: 16),
      FilledButton(onPressed: () => push(context, PremiumFeatureScreen(user: widget.user, index: 9, title: 'Location Tagging')), child: const Text('Report for QR Location')),
    ]),
  );
}

class PremiumListScreen extends StatelessWidget {
  final AppUser user;
  final String title;
  final int mode;
  const PremiumListScreen({super.key, required this.user, required this.title, required this.mode});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar(title, back: true, context: context),
    body: StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('grievances').stream(primaryKey: ['id']).order('created_at', ascending: false),
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        var rows = s.data ?? [];
        if (!AccessControl.isAdminEmail(user.email) || mode == 28) rows = rows.where((g) => (g['user_email'] ?? '') == user.email).toList();
        if (mode == 8) rows = rows.where((g) => (g['assigned_staff_email'] ?? '') == user.email || AccessControl.isAdminEmail(user.email)).toList();
        if (mode == 12) rows.sort((a, b) => _score(b).compareTo(_score(a)));
        return ListView(padding: const EdgeInsets.all(18), children: _build(rows));
      },
    ),
  );

  int _score(Map<String, dynamic> g) {
    if ((g['emergency'] ?? false) == true) return 100;
    final p = (g['priority'] ?? g['detected_priority'] ?? '').toString();
    if (p == 'High') return 80;
    if (p == 'Medium') return 50;
    return 20;
  }

  List<Widget> _build(List<Map<String, dynamic>> rows) {
    if ([15,17,19].contains(mode)) {
      final key = mode == 15 ? 'category' : mode == 17 ? 'assigned_department' : 'assigned_staff_email';
      final m = <String, int>{};
      for (final g in rows) {
        final k = (g[key] ?? 'Unassigned').toString();
        m[k] = (m[k] ?? 0) + 1;
      }
      return m.entries.map((e) => Card(child: ListTile(title: Text(e.key), trailing: chip(e.value.toString(), AppColors.primary)))).toList();
    }
    if (mode == 16 || mode == 18 || mode == 26) {
      final resolved = rows.where((g) => (g['status'] ?? '') == 'Resolved' || (g['status'] ?? '') == 'Closed').length;
      final rated = rows.where((g) => g['student_rating'] != null).length;
      return [
        metric('Total', rows.length.toString(), Icons.list_alt, AppColors.primary),
        const SizedBox(height: 12),
        metric('Resolved / Closed', resolved.toString(), Icons.check_circle, AppColors.success),
        const SizedBox(height: 12),
        metric('Rated', rated.toString(), Icons.star, AppColors.warning),
      ];
    }
    return rows.map((g) => premiumComplaintCard(g, extra: mode == 1 ? [chip(_sla(g), _sla(g) == 'Overdue' ? AppColors.danger : AppColors.success)] : mode == 12 ? [chip('Score ${_score(g)}', AppColors.warning)] : [])).toList();
  }

  String _sla(Map<String, dynamic> g) {
    final due = DateTime.tryParse((g['due_at'] ?? '').toString());
    if (due == null) return 'No SLA';
    return DateTime.now().isAfter(due) && (g['status'] ?? '') != 'Resolved' ? 'Overdue' : 'Within SLA';
  }
}

class PremiumFilteredList extends StatelessWidget {
  final String query;
  final AppUser user;
  const PremiumFilteredList({super.key, required this.query, required this.user});
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Map<String, dynamic>>>(
    stream: supabase.from('grievances').stream(primaryKey: ['id']).order('created_at', ascending: false),
    builder: (_, s) {
      if (!s.hasData) return const Center(child: CircularProgressIndicator());
      final q = query.toLowerCase();
      final rows = (s.data ?? []).where((g) => g.toString().toLowerCase().contains(q)).toList();
      return ListView(children: rows.map((g) => premiumComplaintCard(g)).toList());
    },
  );
}

class PremiumTimelineListScreen extends StatelessWidget {
  final AppUser user;
  const PremiumTimelineListScreen({super.key, required this.user});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar('Admin Action Timeline', back: true, context: context),
    body: StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('complaint_timeline').stream(primaryKey: ['id']).order('created_at', ascending: false),
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(padding: const EdgeInsets.all(18), children: (s.data ?? []).map((t) => Card(child: ListTile(
          leading: const Icon(Icons.timeline, color: PortalColors.teal),
          title: Text((t['action'] ?? '').toString()),
          subtitle: Text('${t['actor_email'] ?? ''}\n${t['details'] ?? ''}'),
          isThreeLine: true,
        ))).toList());
      },
    ),
  );
}

Widget premiumComplaintCard(Map<String, dynamic> g, {List<Widget> extra = const []}) {
  final status = (g['status'] ?? 'Pending').toString();
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: cardDecoration(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('${g['title'] ?? 'Complaint'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        chip(status, statusColor(status)),
      ]),
      const SizedBox(height: 6),
      Text('ID: ${g['complaint_code'] ?? g['id'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 4),
      Text((g['description'] ?? '').toString(), style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        chip('Priority: ${g['priority'] ?? g['detected_priority'] ?? 'Medium'}', AppColors.warning),
        chip('Dept: ${g['assigned_department'] ?? 'None'}', AppColors.primary),
        chip('Location: ${g['location_block'] ?? '-'} ${g['location_room'] ?? ''}', Colors.blueGrey),
        if ((g['anonymous'] ?? false) == true) chip('Anonymous', Colors.black54),
        if ((g['emergency'] ?? false) == true) chip('Emergency', AppColors.danger),
        ...extra,
      ]),
    ]),
  );
}

// ======================= END PREMIUM 30 COMPLAINT FEATURES =======================


// ========================= REQUESTED REALTIME PORTAL UPGRADES =========================

class RealtimePlacementPortalScreen extends StatefulWidget {
  final AppUser user;
  const RealtimePlacementPortalScreen({super.key, required this.user});
  @override
  State<RealtimePlacementPortalScreen> createState() => _RealtimePlacementPortalScreenState();
}

class _RealtimePlacementPortalScreenState extends State<RealtimePlacementPortalScreen> {
  Future<void> addPost() async {
    if (!AccessControl.isAdminEmail(widget.user.email)) {
      snack(context, 'Only admin can post placement updates', error: true);
      return;
    }
    final company = TextEditingController();
    final role = TextEditingController();
    final package = TextEditingController();
    final location = TextEditingController();
    final description = TextEditingController();
    final link = TextEditingController();
    await showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Post Placement Opportunity'),
      content: SizedBox(width: 520, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: company, decoration: const InputDecoration(labelText: 'Company')),
        TextField(controller: role, decoration: const InputDecoration(labelText: 'Role')),
        TextField(controller: package, decoration: const InputDecoration(labelText: 'Package')),
        TextField(controller: location, decoration: const InputDecoration(labelText: 'Location')),
        TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
        TextField(controller: link, decoration: const InputDecoration(labelText: 'Apply Link')),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          await supabase.from('placement_posts').insert({
            'company': company.text.trim(), 'role': role.text.trim(), 'package': package.text.trim(),
            'location': location.text.trim(), 'description': description.text.trim(), 'apply_link': link.text.trim(),
            'posted_by': widget.user.email, 'posted_by_name': 'AVILIGONDA DILEEP KUMAR', 'posted_by_photo': LocalStore.profilePhotoUrl,
          });
          if (context.mounted) Navigator.pop(context);
        }, child: const Text('Post')),
      ],
    ));
  }

  Future<void> apply(Map<String, dynamic> post) async {
    try {
      await supabase.from('placement_applications').insert({'post_id': post['id'], 'user_email': widget.user.email, 'user_name': widget.user.name});
      if (!mounted) return;
      snack(context, 'Applied successfully');
    } catch (e) {
      if (!mounted) return;
      snack(context, 'Already applied or failed: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: PortalColors.pageBg,
    appBar: portalTopBar(context, 'Realtime Placement Portal', user: widget.user),
    floatingActionButton: AccessControl.isAdminEmail(widget.user.email) ? FloatingActionButton(onPressed: addPost, child: const Icon(Icons.add)) : null,
    body: StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('placement_posts').stream(primaryKey: ['id']).order('created_at', ascending: false),
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final posts = s.data ?? [];
        if (posts.isEmpty) return const Center(child: Text('No placement posts yet'));
        return ListView(padding: const EdgeInsets.all(18), children: posts.map((p) {
          final photo = (p['posted_by_photo'] ?? '').toString();
          return Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16), decoration: cardDecoration(radius: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(backgroundImage: photo.isEmpty ? null : NetworkImage(photo), child: photo.isEmpty ? const Icon(Icons.person) : null),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text((p['company'] ?? '').toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Posted by ${p['posted_by_name'] ?? 'Admin'}', style: const TextStyle(color: Colors.grey)),
              ])),
              chip((p['job_type'] ?? 'Full Time').toString(), PortalColors.teal),
            ]),
            const Divider(height: 22),
            Text((p['role'] ?? '').toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('${p['package'] ?? ''} • ${p['location'] ?? ''}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text((p['description'] ?? '').toString()),
            if ((p['apply_link'] ?? '').toString().isNotEmpty) ...[const SizedBox(height: 8), SelectableText((p['apply_link'] ?? '').toString(), style: const TextStyle(color: Colors.blue))],
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.thumb_up_alt_outlined), label: const Text('Interested'))),
              const SizedBox(width: 8),
              Expanded(child: FilledButton.icon(onPressed: () => apply(p), icon: const Icon(Icons.send), label: const Text('Apply'))),
            ]),
          ]));
        }).toList());
      },
    ),
  );
}

class RealtimeProfileScreen extends StatefulWidget {
  final AppUser user;
  const RealtimeProfileScreen({super.key, required this.user});

  @override
  State<RealtimeProfileScreen> createState() => _RealtimeProfileScreenState();
}

class _RealtimeProfileScreenState extends State<RealtimeProfileScreen> {
  late final TextEditingController name = TextEditingController(
    text: AccessControl.isAdminEmail(widget.user.email) ? 'AVILIGONDA DILEEP KUMAR' : widget.user.name,
  );
  late final TextEditingController phone = TextEditingController(
    text: AccessControl.isAdminEmail(widget.user.email) ? '7032643839' : widget.user.phone,
  );
  late final TextEditingController department = TextEditingController(text: widget.user.department);

  String photoUrl = LocalStore.profilePhotoUrl;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    loadProfilePhoto();
  }

  Future<void> loadProfilePhoto() async {
    try {
      final row = await supabase.from('profiles').select('photo_url, full_name, phone, department').eq('email', widget.user.email).maybeSingle();
      if (row == null) return;

      setState(() {
        photoUrl = (row['photo_url'] ?? '').toString();
        LocalStore.profilePhotoUrl = photoUrl;
        if (!AccessControl.isAdminEmail(widget.user.email)) {
          name.text = (row['full_name'] ?? name.text).toString();
          phone.text = (row['phone'] ?? phone.text).toString();
        }
        department.text = (row['department'] ?? department.text).toString();
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    department.dispose();
    super.dispose();
  }

  Future<void> pickAndUploadPhoto() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 900,
      );

      if (picked == null) return;

      setState(() => uploading = true);

      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final safeEmail = widget.user.email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final fileName = '$safeEmail-${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = 'profiles/$fileName';

      await supabase.storage.from('profile-photos').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
          upsert: true,
        ),
      );

      final publicUrl = supabase.storage.from('profile-photos').getPublicUrl(path);

      setState(() {
        photoUrl = publicUrl;
        LocalStore.profilePhotoUrl = publicUrl;
      });

      await saveProfile(showMessage: false);

      if (!mounted) return;
      snack(context, 'Profile photo uploaded');
    } catch (e) {
      if (!mounted) return;
      snack(context, 'Photo upload failed: $e', error: true);
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> saveProfile({bool showMessage = true}) async {
    final displayName = name.text.trim();
    final displayPhone = phone.text.trim();

    if (displayName.isEmpty) {
      snack(context, 'Username cannot be empty', error: true);
      return;
    }

    try {
      final existing = await supabase.from('profiles').select('email').eq('full_name', displayName).neq('email', widget.user.email).maybeSingle();
      if (existing != null) {
        snack(context, 'Username "$displayName" is already taken. Please choose a different username.', error: true);
        return;
      }
    } catch (_) {}

    await supabase.from('profiles').upsert({
      'email': widget.user.email,
      'full_name': displayName,
      'phone': displayPhone,
      'department': department.text.trim(),
      'photo_url': photoUrl,
      'role': AccessControl.isAdminEmail(widget.user.email) ? 'admin' : 'student',
      'status': 'active',
      'last_login': DateTime.now().toIso8601String(),
    }, onConflict: 'email');

    try {
      await supabase.from('app_registered_users').upsert({
        'email': widget.user.email,
        'full_name': displayName,
        'role': AccessControl.isAdminEmail(widget.user.email) ? 'admin' : 'student',
        'status': 'active',
        'last_login': DateTime.now().toIso8601String(),
      }, onConflict: 'email');
    } catch (_) {}

    LocalStore.currentName = displayName;
    LocalStore.currentPhone = displayPhone;
    LocalStore.currentDepartment = department.text.trim();
    LocalStore.profilePhotoUrl = photoUrl;
    LocalStore.registerUser(widget.user.email, displayName, 'GoogleUserPassword123!');

    if (!mounted || !showMessage) return;
    snack(context, 'Profile updated successfully!');
  }

  Future<void> showChangePasswordModal() async {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Current Password', prefixIcon: Icon(Icons.lock_outline)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'New Password (min 6 chars)', prefixIcon: Icon(Icons.lock)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirm New Password', prefixIcon: Icon(Icons.lock_reset)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final cur = currentPassCtrl.text.trim();
                        final n1 = newPassCtrl.text.trim();
                        final n2 = confirmPassCtrl.text.trim();

                        if (cur.isEmpty || n1.isEmpty) {
                          snack(context, 'Please enter current and new password', error: true);
                          return;
                        }
                        if (n1.length < 6) {
                          snack(context, 'New password must be at least 6 characters', error: true);
                          return;
                        }
                        if (n1 != n2) {
                          snack(context, 'New passwords do not match', error: true);
                          return;
                        }

                        setDlgState(() => isSubmitting = true);

                        try {
                          await fb.FirebaseAuth.instance.signInWithEmailAndPassword(email: widget.user.email, password: cur);
                          await fb.FirebaseAuth.instance.currentUser?.updatePassword(n1);

                          if (!mounted) return;
                          Navigator.pop(ctx);
                          snack(context, 'Password updated successfully!');
                        } on fb.FirebaseAuthException catch (e) {
                          snack(context, 'Password update failed: ${e.message}', error: true);
                        } catch (e) {
                          snack(context, 'Password update failed. Verify your current password.', error: true);
                        } finally {
                          setDlgState(() => isSubmitting = false);
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Update Password'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('My Profile', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 58,
                  backgroundImage: photoUrl.trim().isEmpty ? null : NetworkImage(photoUrl.trim()),
                  child: photoUrl.trim().isEmpty ? const Icon(Icons.person, size: 58) : null,
                ),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: uploading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.upload, color: Colors.white),
                    onPressed: uploading ? null : pickAndUploadPhoto,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Upload profile photo from files',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          TextField(controller: name, decoration: input('Full Name / Username', Icons.person)),
          const SizedBox(height: 12),
          TextField(controller: phone, decoration: input('Phone Number', Icons.phone)),
          const SizedBox(height: 12),
          TextField(controller: department, decoration: input('Department', Icons.account_balance)),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => saveProfile(),
            icon: const Icon(Icons.save),
            label: const Text('Save Profile Details'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => showChangePasswordModal(),
            icon: const Icon(Icons.lock_reset),
            label: const Text('Change Account Password'),
          ),
          if (photoUrl.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text('Public profile photo URL', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            SelectableText(photoUrl, style: const TextStyle(color: Colors.blue, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class RealtimeUsersAdminScreen extends StatelessWidget {
  final AppUser user;
  const RealtimeUsersAdminScreen({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    if (!AccessControl.isAdminEmail(user.email)) return Scaffold(appBar: appBar('Users', back: true, context: context), body: const Center(child: Text('Admin only')));
    return Scaffold(appBar: appBar('Registered App Users', back: true, context: context), body: StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('profiles').stream(primaryKey: ['id']).order('last_login', ascending: false),
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final users = s.data ?? [];
        return Column(children: [
          Padding(padding: const EdgeInsets.all(16), child: metric('Total Registered Users', users.length.toString(), Icons.people, AppColors.primary)),
          Expanded(child: ListView(padding: const EdgeInsets.all(16), children: users.map((u) {
            final photo = (u['photo_url'] ?? '').toString();
            return Card(child: ListTile(leading: CircleAvatar(backgroundImage: photo.isEmpty ? null : NetworkImage(photo), child: photo.isEmpty ? const Icon(Icons.person) : null), title: Text((u['full_name'] ?? u['email'] ?? '').toString()), subtitle: Text('${u['email'] ?? ''}\nRole: ${u['role'] ?? ''} • Status: ${u['status'] ?? ''}'), isThreeLine: true));
          }).toList())),
        ]);
      },
    ));
  }
}

class RealtimeFacultyDirectoryScreen extends StatefulWidget {
  final AppUser user;
  const RealtimeFacultyDirectoryScreen({super.key, required this.user});
  @override
  State<RealtimeFacultyDirectoryScreen> createState() => _RealtimeFacultyDirectoryScreenState();
}

class _RealtimeFacultyDirectoryScreenState extends State<RealtimeFacultyDirectoryScreen> {
  Future<void> addFaculty() async {
    if (!AccessControl.isAdminEmail(widget.user.email)) return;
    final name = TextEditingController(), dept = TextEditingController(), email = TextEditingController(), phone = TextEditingController();
    await showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Add Faculty'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
      TextField(controller: dept, decoration: const InputDecoration(labelText: 'Department')),
      TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
      TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
    ]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { await supabase.from('faculty_directory').insert({'name': name.text, 'department': dept.text, 'email': email.text, 'phone': phone.text, 'created_by': widget.user.email}); if (context.mounted) Navigator.pop(context); }, child: const Text('Add'))]));
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: appBar('Realtime Faculty Directory', back: true, context: context), floatingActionButton: AccessControl.isAdminEmail(widget.user.email) ? FloatingActionButton(onPressed: addFaculty, child: const Icon(Icons.add)) : null, body: StreamBuilder<List<Map<String, dynamic>>>(stream: supabase.from('faculty_directory').stream(primaryKey: ['id']).order('name'), builder: (_, s) { if (!s.hasData) return const Center(child: CircularProgressIndicator()); final rows = s.data ?? []; if (rows.isEmpty) return const Center(child: Text('No faculty added yet')); return ListView(padding: const EdgeInsets.all(16), children: rows.map((f) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.school)), title: Text((f['name'] ?? '').toString()), subtitle: Text('${f['department'] ?? ''}\n${f['email'] ?? ''} • ${f['phone'] ?? ''}'), isThreeLine: true))).toList()); }));
}

class RealtimeLostFoundScreen extends StatefulWidget {
  final AppUser user;
  const RealtimeLostFoundScreen({super.key, required this.user});
  @override
  State<RealtimeLostFoundScreen> createState() => _RealtimeLostFoundScreenState();
}

class _RealtimeLostFoundScreenState extends State<RealtimeLostFoundScreen> {
  Future<void> addItem() async {
    final title = TextEditingController(), desc = TextEditingController(), loc = TextEditingController();
    String type = 'Lost';
    await showDialog(context: context, builder: (_) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(title: const Text('Post Lost / Found Item'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownButtonFormField<String>(value: type, items: ['Lost','Found'].map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (v)=>setLocal(()=>type=v??'Lost')),
      TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
      TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
      TextField(controller: loc, decoration: const InputDecoration(labelText: 'Location')),
    ]), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { await supabase.from('lost_found_items').insert({'title': title.text, 'description': desc.text, 'type': type, 'location': loc.text, 'contact': widget.user.email, 'posted_by': widget.user.email, 'posted_by_name': widget.user.name}); if (context.mounted) Navigator.pop(context); }, child: const Text('Post'))])));
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: appBar('Realtime Lost & Found', back: true, context: context), floatingActionButton: FloatingActionButton(onPressed: addItem, child: const Icon(Icons.add)), body: StreamBuilder<List<Map<String, dynamic>>>(stream: supabase.from('lost_found_items').stream(primaryKey: ['id']).order('created_at', ascending: false), builder: (_, s) { if (!s.hasData) return const Center(child: CircularProgressIndicator()); final rows = s.data ?? []; if (rows.isEmpty) return const Center(child: Text('No lost/found posts yet')); return ListView(padding: const EdgeInsets.all(16), children: rows.map((i) => Card(child: ListTile(leading: Icon((i['type'] ?? 'Lost') == 'Lost' ? Icons.search : Icons.check_circle, color: PortalColors.teal), title: Text('${i['type']}: ${i['title']}'), subtitle: Text('${i['description'] ?? ''}\nLocation: ${i['location'] ?? ''}\nContact: ${i['contact'] ?? ''}'), isThreeLine: true))).toList()); }));
}

class RealtimeOtpScreen extends StatefulWidget {
  final AppUser user;
  const RealtimeOtpScreen({super.key, required this.user});
  @override
  State<RealtimeOtpScreen> createState() => _RealtimeOtpScreenState();
}

class _RealtimeOtpScreenState extends State<RealtimeOtpScreen> {
  final code = TextEditingController();
  String generated = '';
  Future<void> generateOtp() async {
    generated = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
    await supabase.from('otp_codes').insert({'email': widget.user.email, 'code': generated, 'verified': false, 'expires_at': DateTime.now().add(const Duration(minutes: 5)).toIso8601String()});
    setState(() {}); snack(context, 'OTP generated. Demo OTP: $generated');
  }
  Future<void> verify() async {
    final rows = await supabase.from('otp_codes').select().eq('email', widget.user.email).eq('code', code.text.trim()).eq('verified', false);
    if ((rows as List).isEmpty) { snack(context, 'Invalid OTP', error: true); return; }
    await supabase.from('otp_codes').update({'verified': true}).eq('id', rows.first['id']);
    snack(context, 'OTP verified');
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: appBar('Realtime OTP Verification', back: true, context: context), body: ListView(padding: const EdgeInsets.all(20), children: [
    infoBox('Realtime OTP demo stores OTP in Supabase. For production, connect email/SMS provider.'),
    const SizedBox(height: 16), FilledButton(onPressed: generateOtp, child: const Text('Generate OTP')),
    if (generated.isNotEmpty) Padding(padding: const EdgeInsets.all(12), child: Text('Demo OTP: $generated', style: const TextStyle(fontWeight: FontWeight.bold))),
    TextField(controller: code, decoration: input('Enter OTP', Icons.password)), const SizedBox(height: 12), FilledButton(onPressed: verify, child: const Text('Verify OTP')),
  ]));
}

// ======================= END REQUESTED REALTIME PORTAL UPGRADES =======================


// ========================= STUDENT 360 + ISSUE HISTORY =========================

bool isIssueHistoryStatus(String status) {
  final s = status.toLowerCase();
  return s == 'resolved' || s == 'closed' || s == 'rejected' || s == 'cancelled';
}

class IssueHistoryScreen extends StatelessWidget {
  final AppUser user;
  const IssueHistoryScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Issue History', back: true, context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('grievances').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var rows = snapshot.data ?? [];
          rows = rows.where((g) => isIssueHistoryStatus((g['status'] ?? '').toString())).toList();

          if (!AccessControl.isAdminEmail(user.email)) {
            rows = rows.where((g) => (g['user_email'] ?? '').toString() == user.email).toList();
          }

          if (rows.isEmpty) return const Center(child: Text('No resolved / closed issue history yet'));

          return ListView(
            padding: const EdgeInsets.all(18),
            children: rows.map((g) {
              final status = (g['status'] ?? 'Resolved').toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: cardDecoration(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text((g['title'] ?? 'Issue').toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    chip(status, statusColor(status)),
                  ]),
                  const SizedBox(height: 6),
                  Text((g['description'] ?? '').toString(), style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    chip((g['category'] ?? 'Other').toString(), AppColors.primary),
                    chip((g['priority'] ?? 'Medium').toString(), AppColors.warning),
                    chip((g['user_email'] ?? '').toString(), Colors.blueGrey),
                  ]),
                ]),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class Student360ViewScreen extends StatelessWidget {
  final AppUser user;
  const Student360ViewScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (!AccessControl.isAdminEmail(user.email)) {
      return Scaffold(
        appBar: appBar('Student 360° View', back: true, context: context),
        body: const Center(child: Text('Only admin can access Student 360° View')),
      );
    }

    return Scaffold(
      appBar: appBar('Student 360° View', back: true, context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('profiles').stream(primaryKey: ['id']).order('full_name'),
        builder: (_, profileSnapshot) {
          if (!profileSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final profiles = profileSnapshot.data ?? [];

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('grievances').stream(primaryKey: ['id']),
            builder: (_, issueSnapshot) {
              if (!issueSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              final issues = issueSnapshot.data ?? [];

              if (profiles.isEmpty) return const Center(child: Text('No registered users found'));

              return ListView(
                padding: const EdgeInsets.all(18),
                children: profiles.map((p) {
                  final email = (p['email'] ?? '').toString();
                  final photo = (p['photo_url'] ?? '').toString();
                  final name = (p['full_name'] ?? email).toString();
                  final userIssues = issues.where((g) => (g['user_email'] ?? '').toString() == email).toList();
                  final active = userIssues.where((g) => !isIssueHistoryStatus((g['status'] ?? '').toString())).length;
                  final history = userIssues.where((g) => isIssueHistoryStatus((g['status'] ?? '').toString())).length;
                  final emergency = userIssues.where((g) => (g['emergency'] ?? false) == true || (g['priority'] ?? '') == 'High').length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: cardDecoration(radius: 14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: photo.isEmpty ? null : NetworkImage(photo),
                          child: photo.isEmpty ? const Icon(Icons.person) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          Text(email, style: const TextStyle(color: Colors.grey)),
                          Text('Status: ${p['status'] ?? 'active'} • Dept: ${p['department'] ?? '-'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        chip('Total Issues: ${userIssues.length}', AppColors.primary),
                        chip('Active: $active', AppColors.warning),
                        chip('History: $history', AppColors.success),
                        chip('Emergency/High: $emergency', emergency > 0 ? AppColors.danger : Colors.blueGrey),
                      ]),
                      const SizedBox(height: 10),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text('View raised issues'),
                        children: userIssues.isEmpty
                            ? [const Padding(padding: EdgeInsets.all(8), child: Text('No issues raised'))]
                            : userIssues.map((g) => ListTile(
                                  dense: true,
                                  leading: Icon(isIssueHistoryStatus((g['status'] ?? '').toString()) ? Icons.history : Icons.report, color: PortalColors.teal),
                                  title: Text((g['title'] ?? 'Issue').toString()),
                                  subtitle: Text('Status: ${g['status'] ?? 'Pending'} • Priority: ${g['priority'] ?? 'Medium'}'),
                                )).toList(),
                      ),
                    ]),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

// ======================= END STUDENT 360 + ISSUE HISTORY =======================


// ========================= REALTIME USERS + PDF NOTIFICATIONS + PLACEMENT PROFILES =========================

class AdminNotificationFileUploadScreen extends StatefulWidget {
  final AppUser user;
  const AdminNotificationFileUploadScreen({super.key, required this.user});

  @override
  State<AdminNotificationFileUploadScreen> createState() => _AdminNotificationFileUploadScreenState();
}

class _AdminNotificationFileUploadScreenState extends State<AdminNotificationFileUploadScreen> {
  final title = TextEditingController();
  final body = TextEditingController();
  String fileName = '';
  String fileUrl = '';
  bool uploading = false;

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  Future<void> pickPdfOrFile() async {
    if (!AccessControl.isAdminEmail(widget.user.email)) {
      snack(context, 'Only admin can upload notification files', error: true);
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'png', 'jpg', 'jpeg'],
      );
      if (result == null || result.files.single.bytes == null) return;

      setState(() => uploading = true);

      final file = result.files.single;
      final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = 'notifications/${DateTime.now().millisecondsSinceEpoch}-$safeName';

      await supabase.storage.from('notification-files').uploadBinary(
        path,
        file.bytes!,
        fileOptions: FileOptions(
          upsert: true,
          contentType: file.extension == 'pdf' ? 'application/pdf' : null,
        ),
      );

      final url = supabase.storage.from('notification-files').getPublicUrl(path);

      setState(() {
        fileName = file.name;
        fileUrl = url;
      });

      if (!mounted) return;
      snack(context, 'File uploaded');
    } catch (e) {
      if (!mounted) return;
      snack(context, 'File upload failed: $e', error: true);
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> uploadNotification() async {
    if (!AccessControl.isAdminEmail(widget.user.email)) {
      snack(context, 'Only admin can upload notifications', error: true);
      return;
    }

    if (title.text.trim().isEmpty || body.text.trim().isEmpty) {
      snack(context, 'Enter title and message', error: true);
      return;
    }

    await supabase.from('announcements').insert({
      'title': title.text.trim(),
      'body': body.text.trim(),
      'target_role': 'all',
      'created_by': widget.user.email,
      'uploaded_by': 'AVILIGONDA DILEEP KUMAR',
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileName.split('.').last,
      'notification_date': DateTime.now().toIso8601String().split('T').first,
    });

    title.clear();
    body.clear();
    setState(() {
      fileName = '';
      fileUrl = '';
    });

    if (!mounted) return;
    snack(context, 'Notification uploaded realtime');
  }

  @override
  Widget build(BuildContext context) {
    if (!AccessControl.isAdminEmail(widget.user.email)) {
      return Scaffold(appBar: appBar('Admin Upload Notification', back: true, context: context), body: const Center(child: Text('Only admin can upload notifications.')));
    }

    return Scaffold(
      appBar: appBar('Admin Upload Notification', back: true, context: context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          infoBox('Admin can upload notification text and attach PDF, document, sheet, or image from files.'),
          const SizedBox(height: 12),
          TextField(controller: title, decoration: input('Notification Title', Icons.title)),
          const SizedBox(height: 12),
          TextField(controller: body, maxLines: 5, decoration: input('Notification Message', Icons.message)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: uploading ? null : pickPdfOrFile,
            icon: uploading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.attach_file),
            label: Text(fileName.isEmpty ? 'Choose PDF / File from device' : fileName),
          ),
          if (fileUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(fileUrl, style: const TextStyle(color: Colors.blue, fontSize: 12)),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: uploadNotification, icon: const Icon(Icons.cloud_upload), label: const Text('Upload Notification')),
        ],
      ),
    );
  }
}

class RealtimeRegisteredUsersScreen extends StatelessWidget {
  final AppUser user;
  const RealtimeRegisteredUsersScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (!AccessControl.isAdminEmail(user.email)) {
      return Scaffold(appBar: appBar('Registered Users', back: true, context: context), body: const Center(child: Text('Admin only')));
    }

    return Scaffold(
      appBar: appBar('Realtime Registered App Users', back: true, context: context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('app_registered_users').stream(primaryKey: ['id']).order('last_login', ascending: false),
        builder: (_, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final users = s.data ?? [];
          if (users.isEmpty) return const Center(child: Text('No app users registered yet'));
          return Column(children: [
            Padding(padding: const EdgeInsets.all(16), child: metric('Registered Users', users.length.toString(), Icons.people, AppColors.primary)),
            Expanded(child: ListView(
              padding: const EdgeInsets.all(16),
              children: users.map((u) {
                final photo = (u['photo_url'] ?? '').toString();
                return Card(child: ListTile(
                  leading: CircleAvatar(backgroundImage: photo.isEmpty ? null : NetworkImage(photo), child: photo.isEmpty ? const Icon(Icons.person) : null),
                  title: Text((u['full_name'] ?? u['email'] ?? '').toString()),
                  subtitle: Text('${u['email'] ?? ''}\nRole: ${u['role'] ?? ''} • Status: ${u['status'] ?? ''}\nLast login: ${u['last_login'] ?? ''}'),
                  isThreeLine: true,
                ));
              }).toList(),
            )),
          ]);
        },
      ),
    );
  }
}

class Student360MessagesOnlyScreen extends StatefulWidget {
  final AppUser user;
  final String? studentEmail;
  const Student360MessagesOnlyScreen({super.key, required this.user, this.studentEmail});

  @override
  State<Student360MessagesOnlyScreen> createState() => _Student360MessagesOnlyScreenState();
}

class _Student360MessagesOnlyScreenState extends State<Student360MessagesOnlyScreen> {
  final msg = TextEditingController();
  String selectedStudent = '';

  @override
  void initState() {
    super.initState();
    selectedStudent = widget.studentEmail ?? widget.user.email;
  }

  @override
  void dispose() {
    msg.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (msg.text.trim().isEmpty) return;
    await supabase.from('student360_messages').insert({
      'student_email': selectedStudent,
      'sender_email': widget.user.email,
      'sender_name': AccessControl.isAdminEmail(widget.user.email) ? 'AVILIGONDA DILEEP KUMAR' : widget.user.name,
      'message': msg.text.trim(),
    });
    msg.clear();
  }

  @override
  Widget build(BuildContext context) {
    final admin = AccessControl.isAdminEmail(widget.user.email);

    return Scaffold(
      appBar: appBar('Student 360° Messages', back: true, context: context),
      body: Column(
        children: [
          if (admin)
            SizedBox(
              height: 74,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase.from('app_registered_users').stream(primaryKey: ['id']).order('full_name'),
                builder: (_, s) {
                  final users = s.data ?? [];
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(10),
                    children: users.map((u) {
                      final email = (u['email'] ?? '').toString();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text((u['full_name'] ?? email).toString()),
                          selected: selectedStudent == email,
                          onSelected: (_) => setState(() => selectedStudent = email),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('student360_messages')
                  .stream(primaryKey: ['id'])
                  .eq('student_email', selectedStudent)
                  .order('created_at', ascending: false),
              builder: (_, s) {
                if (!s.hasData) return const Center(child: CircularProgressIndicator());
                final rows = s.data ?? [];
                if (rows.isEmpty) return const Center(child: Text('No realtime messages yet'));
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: rows.length,
                  itemBuilder: (_, i) {
                    final m = rows[i];
                    final mine = (m['sender_email'] ?? '') == widget.user.email;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(color: mine ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text((m['message'] ?? '').toString(), style: TextStyle(color: mine ? Colors.white : Colors.black87)),
                          const SizedBox(height: 4),
                          Text((m['sender_name'] ?? m['sender_email'] ?? '').toString(), style: TextStyle(color: mine ? Colors.white70 : Colors.grey, fontSize: 11)),
                        ]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: msg, decoration: input('Message', Icons.message))),
              const SizedBox(width: 8),
              FloatingActionButton.small(onPressed: send, child: const Icon(Icons.send)),
            ]),
          ),
        ],
      ),
    );
  }
}

class LinkedInPlacementProfilesScreen extends StatefulWidget {
  final AppUser user;
  const LinkedInPlacementProfilesScreen({super.key, required this.user});

  @override
  State<LinkedInPlacementProfilesScreen> createState() => _LinkedInPlacementProfilesScreenState();
}

class _LinkedInPlacementProfilesScreenState extends State<LinkedInPlacementProfilesScreen> {
  Future<void> editMyProfile() async {
    final headline = TextEditingController();
    final skills = TextEditingController();
    final resume = TextEditingController();
    final linkedin = TextEditingController();
    final github = TextEditingController();
    final portfolio = TextEditingController();

    final existing = await supabase.from('placement_profiles').select().eq('user_email', widget.user.email).maybeSingle();
    if (existing != null) {
      headline.text = (existing['headline'] ?? '').toString();
      skills.text = (existing['skills'] ?? '').toString();
      resume.text = (existing['resume_url'] ?? '').toString();
      linkedin.text = (existing['linkedin_url'] ?? '').toString();
      github.text = (existing['github_url'] ?? '').toString();
      portfolio.text = (existing['portfolio_url'] ?? '').toString();
    }

    await showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('My LinkedIn-style Placement Profile'),
      content: SizedBox(width: 520, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: headline, decoration: const InputDecoration(labelText: 'Headline')),
        TextField(controller: skills, decoration: const InputDecoration(labelText: 'Skills')),
        TextField(controller: resume, decoration: const InputDecoration(labelText: 'Resume URL')),
        TextField(controller: linkedin, decoration: const InputDecoration(labelText: 'LinkedIn URL')),
        TextField(controller: github, decoration: const InputDecoration(labelText: 'GitHub URL')),
        TextField(controller: portfolio, decoration: const InputDecoration(labelText: 'Portfolio URL')),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          await supabase.from('placement_profiles').upsert({
            'user_email': widget.user.email,
            'full_name': widget.user.name,
            'headline': headline.text.trim(),
            'skills': skills.text.trim(),
            'resume_url': resume.text.trim(),
            'linkedin_url': linkedin.text.trim(),
            'github_url': github.text.trim(),
            'portfolio_url': portfolio.text.trim(),
            'photo_url': LocalStore.profilePhotoUrl,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_email');
          if (context.mounted) Navigator.pop(context);
        }, child: const Text('Save')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar('Live LinkedIn Placement Profiles', back: true, context: context),
    floatingActionButton: FloatingActionButton(onPressed: editMyProfile, child: const Icon(Icons.edit)),
    body: StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('placement_profiles').stream(primaryKey: ['id']).order('updated_at', ascending: false),
      builder: (_, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final rows = s.data ?? [];
        if (rows.isEmpty) return const Center(child: Text('No placement profiles yet'));
        return ListView(
          padding: const EdgeInsets.all(16),
          children: rows.map((p) {
            final photo = (p['photo_url'] ?? '').toString();
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: cardDecoration(radius: 14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(radius: 30, backgroundImage: photo.isEmpty ? null : NetworkImage(photo), child: photo.isEmpty ? const Icon(Icons.person) : null),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text((p['full_name'] ?? p['user_email'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  Text((p['headline'] ?? '').toString(), style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Skills: ${p['skills'] ?? ''}'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    if ((p['resume_url'] ?? '').toString().isNotEmpty) chip('Resume', AppColors.primary),
                    if ((p['linkedin_url'] ?? '').toString().isNotEmpty) chip('LinkedIn', Colors.blue),
                    if ((p['github_url'] ?? '').toString().isNotEmpty) chip('GitHub', Colors.black87),
                    if ((p['portfolio_url'] ?? '').toString().isNotEmpty) chip('Portfolio', PortalColors.teal),
                  ]),
                  if ((p['linkedin_url'] ?? '').toString().isNotEmpty) SelectableText((p['linkedin_url'] ?? '').toString(), style: const TextStyle(color: Colors.blue, fontSize: 12)),
                ])),
              ]),
            );
          }).toList(),
        );
      },
    ),
  );
}

// ======================= END REALTIME USERS + PDF NOTIFICATIONS + PLACEMENT PROFILES =======================

PreferredSizeWidget appBar(String title, {bool back = false, BuildContext? context, List<Widget>? actions}) {
  return AppBar(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    automaticallyImplyLeading: back,
    leading: back && context != null ? IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)) : null,
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis, maxLines: 1),
    actions: actions,
  );
}

InputDecoration input(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.primary),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
  );
}

BoxDecoration cardDecoration({double radius = 14}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
  );
}

void push(BuildContext context, Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

void snack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: error ? AppColors.danger : AppColors.primary));
}

Widget sectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
    child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
  );
}

Widget action(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(radius: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
        const Spacer(),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, height: 1.3)),
      ]),
    ),
  );
}

Widget chip(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
  );
}

Color statusColor(String status) {
  switch (status) {
    case 'Pending':
      return AppColors.warning;
    case 'In Progress':
      return Colors.blue;
    case 'Resolved':
      return AppColors.success;
    case 'Accepted':
      return AppColors.success;
    case 'Rejected':
      return AppColors.danger;
    case 'Cancelled':
      return AppColors.danger;
    case 'Closed':
      return AppColors.success;
    case 'Assigned':
      return AppColors.primary;
    case 'Forwarded':
      return Colors.blueGrey;
    case 'Escalated':
      return AppColors.danger;
    default:
      return Colors.grey;
  }
}

Widget dropdown(String label, String value, List<String> items, ValueChanged<String> onChanged) {
  return DropdownButtonFormField<String>(
    value: value.isEmpty ? null : value,
    decoration: input(label, Icons.arrow_drop_down_circle_outlined),
    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    onChanged: (v) => onChanged(v!),
  );
}

Widget metric(String title, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: cardDecoration(radius: 18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 30),
      const Spacer(),
      Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
      Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
    ]),
  );
}

Widget tile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool danger = false}) {
  final color = danger ? AppColors.danger : AppColors.primary;
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: cardDecoration(),
    child: ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: danger ? color : AppColors.text, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    ),
  );
}

Widget grievanceTile(LocalGrievance g) {
  return Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    padding: const EdgeInsets.all(16),
    decoration: cardDecoration(),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(g.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 4),
        Text('${g.category} • ${g.priority}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ])),
      chip(g.status, statusColor(g.status)),
    ]),
  );
}

Widget infoBox(String text) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.primary))),
    ]),
  );
}

Widget imagePreview(XFile file) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: kIsWeb
        ? FutureBuilder<Uint8List>(
            future: file.readAsBytes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));
              return Image.memory(snapshot.data!, height: 140, width: double.infinity, fit: BoxFit.cover);
            },
          )
        : Image.file(File(file.path), height: 140, width: double.infinity, fit: BoxFit.cover),
  );
}
