import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homii_ai_event_comp_app/providers/auth_provider.dart';
import 'package:homii_ai_event_comp_app/providers/profile_provider.dart';
import 'package:homii_ai_event_comp_app/views/theme/app_theme_data.dart';
import 'package:homii_ai_event_comp_app/views/widgets/animated/animated_text.dart';
import 'landing_screen.dart';
import 'main_screen.dart';

/// Root screen that handles initial routing based on authentication and profile completion
class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  late Future<ProfileCompletionStatus> _initFuture;
  bool _splashDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Start 2.5s splash timer
    Future.delayed(const Duration(milliseconds: 2500)).then((_) {
      if (mounted) {
        setState(() {
          _splashDone = true;
        });
      }
    });
    // In parallel, attempt auth and load profile status
    _initFuture = _ensureAuthAndLoadProfile();
  }

  Future<ProfileCompletionStatus> _ensureAuthAndLoadProfile() async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      final authService = ref.read(authServiceProvider);
      await authService.signInAnonymously();
    }
    // Await current profile completion status
    return await ref.read(profileCompletionStatusProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileCompletionStatus>(
      future: _initFuture,
      builder: (context, snapshot) {
        // 1) Always show splash for the first 2.5 seconds
        if (!_splashDone) {
          return Scaffold(
            backgroundColor: AppColor.primary.color,
            body: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              color: AppColor.primary.color,
              child: AnimatedText(
                text: 'Event Buddy',
                isLast: false,
                fontSize: 56,
                textColor: AppColor.white.color,
                isEntranceOutEnabled: true,
              ),
            ),
          );
        }

        // 2) After splash: if auth/profile still loading, show loader
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 3) After splash and future done: route by profile status
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'エラーが発生しました: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Retry the flow; keep splash already done
                        ref.invalidate(profileCompletionStatusProvider);
                        _initFuture = _ensureAuthAndLoadProfile();
                      });
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            ),
          );
        }

        final status = snapshot.data;
        if (!_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final route = MaterialPageRoute(
              builder: (_) => status == ProfileCompletionStatus.complete
                  ? const MainScreen()
                  : const LandingScreen(),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          });
        }
        // Show a minimal loader while navigation happens
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

