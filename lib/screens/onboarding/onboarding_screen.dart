// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../chat/chat_screen.dart';

// ── Onboarding Data ──────────────────────────────────────────────────────
class _OBPage {
  final String emoji, title, subtitle, description;
  final Color accent, accentBg;
  final List<_Feature> features;
  const _OBPage({
    required this.emoji, required this.title, required this.subtitle,
    required this.description, required this.accent, required this.accentBg,
    required this.features,
  });
}

class _Feature {
  final String icon, text;
  const _Feature(this.icon, this.text);
}

const _pages = [
  _OBPage(
    emoji: '✉️', title: 'Smart Emails',
    subtitle: 'Never miss what matters',
    description: 'ARIA reads your Gmail and shows your 5 most important emails — ranked by AI priority every morning.',
    accent: AriaColors.secondary,
    accentBg: AriaColors.secondarySurface,
    features: [
      _Feature('📌', 'Top 5 important emails'),
      _Feature('✍️', 'AI-drafted professional replies'),
      _Feature('📤', 'Send with one tap'),
    ],
  ),
  _OBPage(
    emoji: '🔔', title: 'Natural Reminders',
    subtitle: 'Just say it — I\'ll remember',
    description: 'Say "Remind me Friday at 3pm about the client call" — no tapping, no forms, just natural conversation.',
    accent: AriaColors.primary,
    accentBg: AriaColors.primarySurface,
    features: [
      _Feature('🗣️', 'Natural language input'),
      _Feature('⏰', 'Smart date & time parsing'),
      _Feature('🌅', 'Morning brief at 8AM daily'),
    ],
  ),
  _OBPage(
    emoji: '📅', title: 'Day at a Glance',
    subtitle: 'Your entire day, instantly',
    description: 'Ask "What\'s my day?" and ARIA gives you a crisp 3-sentence summary of meetings, urgent emails, and tasks.',
    accent: Color(0xFF6B7FD7),
    accentBg: Color(0xFFEEF0FB),
    features: [
      _Feature('📊', 'Full day overview'),
      _Feature('🤝', 'Meeting summaries'),
      _Feature('⚡', 'Priority highlights'),
    ],
  ),
  _OBPage(
    emoji: '🤖', title: 'Powered by Groq AI',
    subtitle: 'Lightning-fast AI responses',
    description: 'ARIA uses Groq\'s blazing-fast AI (llama3-70b) to understand your requests and give intelligent responses in milliseconds.',
    accent: Color(0xFF9B59B6),
    accentBg: Color(0xFFF5EEF8),
    features: [
      _Feature('⚡', 'Sub-second AI responses'),
      _Feature('🧠', 'Understands natural language'),
      _Feature('🔒', 'Your data stays private'),
    ],
  ),
];

class OnboardingScreen extends StatefulWidget {
  final Future<void> Function()? onFinished;
  const OnboardingScreen({super.key, this.onFinished});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(duration: 400.ms, curve: Curves.easeInOut);
    } else {
      _toChat();
    }
  }

  Future<void> _toChat() async {
    if (widget.onFinished != null) {
      await widget.onFinished!.call();
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: 600.ms,
        pageBuilder: (_, a, __) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut),
          child: const ChatScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    final page   = _pages[_page];

    return Scaffold(
      backgroundColor: AriaColors.background,
      body: SafeArea(
        child: Column(children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Row(children: [
                  AriaLogo(size: 34),
                  const SizedBox(width: 8),
                  const Text('ARIA', style: TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 17,
                    color: AriaColors.textPrimary, letterSpacing: 3,
                  )),
                ]),
                // Skip
                if (!isLast)
                  TextButton(
                    onPressed: () => _toChat(),
                    style: TextButton.styleFrom(
                      foregroundColor: AriaColors.textHint,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text('Skip', style: AriaText.labelMedium.copyWith(
                      color: AriaColors.textHint)),
                  ),
              ],
            ),
          ),

          // Page content
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: _pages.length,
              itemBuilder: (_, i) => _PageContent(data: _pages[i]),
            ),
          ),

          // Bottom controls
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Column(children: [
              // Page dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) =>
                  GestureDetector(
                    onTap: () => _ctrl.animateToPage(i,
                      duration: 400.ms, curve: Curves.easeInOut),
                    child: AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 28 : 8, height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? page.accent : AriaColors.divider,
                        borderRadius: BorderRadius.circular(Rad.full),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // CTA Button
              AnimatedContainer(
                duration: 300.ms,
                height: 60, width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: page.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Rad.lg)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [page.accent, Color.lerp(page.accent, Colors.black, 0.15)!],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(Rad.lg),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(isLast ? 'Get Started' : 'Continue',
                        style: AriaText.button.copyWith(color: Colors.white)),
                      const SizedBox(width: 10),
                      Icon(
                        isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                        color: Colors.white, size: 22,
                      ),
                    ]),
                  ),
                )
                .animate(key: ValueKey(_page))
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.94, 0.94), duration: 300.ms,
                       curve: Curves.easeOut),
              ),

              if (isLast) ...[
                const SizedBox(height: 14),
                Text('Free forever · No credit card · Zero cost',
                  style: AriaText.bodySmall.copyWith(color: AriaColors.textHint),
                  textAlign: TextAlign.center),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Single page content ──────────────────────────────────────────────────
class _PageContent extends StatelessWidget {
  final _OBPage data;
  const _PageContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(children: [
        SizedBox(height: h * 0.05),

        // Illustration card
        Container(
          width: 200, height: 200,
          decoration: BoxDecoration(
            color: data.accentBg,
            borderRadius: BorderRadius.circular(52),
            border: Border.all(color: data.accent.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: data.accent.withOpacity(0.15),
                blurRadius: 32, offset: const Offset(0, 12), spreadRadius: -4,
              ),
            ],
          ),
          child: Center(child: Text(data.emoji, style: const TextStyle(fontSize: 84))),
        ).animate().fadeIn(duration: 400.ms).scale(
          begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.easeOut),

        SizedBox(height: h * 0.04),

        // Title
        Text(data.title, textAlign: TextAlign.center,
          style: AriaText.displayMedium.copyWith(fontWeight: FontWeight.w800))
        .animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, delay: 100.ms),

        const SizedBox(height: 10),

        // Subtitle
        Text(data.subtitle, textAlign: TextAlign.center,
          style: AriaText.headlineSmall.copyWith(
            color: data.accent, fontWeight: FontWeight.w600))
        .animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 20),

        // Description
        Text(data.description, textAlign: TextAlign.center,
          style: AriaText.bodyLarge.copyWith(
            color: AriaColors.textSecondary, height: 1.7))
        .animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 28),

        // Features list
        ...data.features.asMap().entries.map((e) =>
          _FeatureRow(e.value, data.accent)
          .animate(delay: Duration(milliseconds: 250 + e.key * 80))
          .fadeIn(duration: 350.ms)
          .slideX(begin: -0.15, duration: 350.ms, curve: Curves.easeOut),
        ),

        const SizedBox(height: 20),
      ]),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final _Feature f;
  final Color color;
  const _FeatureRow(this.f, this.color);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(Rad.lg),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(children: [
      Text(f.icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 12),
      Text(f.text, style: AriaText.titleMedium.copyWith(color: AriaColors.textPrimary)),
      const Spacer(),
      Icon(Icons.check_circle_rounded, size: 16, color: color),
    ]),
  );
}
