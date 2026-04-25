import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class StreamSelectionScreen extends StatefulWidget {
  const StreamSelectionScreen({super.key});

  @override
  State<StreamSelectionScreen> createState() => _StreamSelectionScreenState();
}

class _StreamSelectionScreenState extends State<StreamSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? selectedStream;
  late AnimationController _controller;

  /// Static stream metadata — colors, images, careers (these stay constant
  /// across languages). The `code` is the internal stream identifier passed
  /// to the next screen + saved in Firestore (always English so KB/Gemini
  /// keep working). Display labels are looked up via `_displayName(code, t)`.
  final List<Map<String, dynamic>> streams = [
    {
      'code': 'Medical',
      'emoji': '🩺',
      'image':
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&q=80',
      'careers': ['MBBS', 'B.Sc Nursing', 'Pharmacy'],
      'students': '42,000+',
      'color': const Color(0xFF0EA5E9),
    },
    {
      'code': 'Non-Medical',
      'emoji': '⚙️',
      'image':
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80',
      'careers': ['Engineering', 'B.Sc', 'Data Science'],
      'students': '58,000+',
      'color': const Color(0xFF8B5CF6),
    },
    {
      'code': 'Commerce',
      'emoji': '📊',
      'image':
          'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&q=80',
      'careers': ['CA / CMA', 'MBA', 'Banking'],
      'students': '35,000+',
      'color': const Color(0xFF10B981),
    },
    {
      'code': 'Arts',
      'emoji': '🎨',
      'image':
          'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800&q=80',
      'careers': ['Law / CLAT', 'Design', 'Psychology'],
      'students': '29,000+',
      'color': const Color(0xFFF59E0B),
    },
  ];

  /// Resolves the localized display name for a stream code.
  String _displayName(String code, AppLocalizations t) {
    switch (code) {
      case 'Medical':
        return t.streamMedical;
      case 'Non-Medical':
        return t.streamNonMedical;
      case 'Commerce':
        return t.streamCommerce;
      case 'Arts':
        return t.streamArts;
      default:
        return code;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Header ──────────────────────────────────
            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOut,
                    ),
                  ),
              child: FadeTransition(
                opacity: _controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.chooseYourStream,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.streamSelectionSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.45),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Cards Grid ───────────────────────────────
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 340,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                ),
                itemCount: streams.length,
                itemBuilder: (context, index) {
                  // Staggered entrance: each card delays a bit more
                  final delay = index * 0.12;
                  final cardAnim = CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      delay,
                      (delay + 0.6).clamp(0.0, 1.0),
                      curve: Curves.easeOutCubic,
                    ),
                  );
                  final stream = streams[index];
                  final code = stream['code'] as String;
                  final displayName = _displayName(code, t);

                  return FadeTransition(
                    opacity: cardAnim,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.25),
                            end: Offset.zero,
                          ).animate(cardAnim),
                      child: _StreamCard(
                        data: stream,
                        displayName: displayName,
                        selectLabel: t.streamCardSelect,
                        exploreLabel: t.streamCardExplore,
                        isSelected: selectedStream == code,
                        onTap: () {
                          setState(() => selectedStream = code);
                          Future.delayed(const Duration(milliseconds: 220), () {
                            if (!mounted) return;
                            // Pass the ENGLISH code — KB/Gemini depend on this
                            Navigator.pushNamed(
                              context,
                              '/profile_input',
                              arguments: code,
                            );
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// STREAM CARD WIDGET
// ──────────────────────────────────────────────────────────
class _StreamCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String displayName;
  final String selectLabel;
  final String exploreLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _StreamCard({
    required this.data,
    required this.displayName,
    required this.selectLabel,
    required this.exploreLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_StreamCard> createState() => _StreamCardState();
}

class _StreamCardState extends State<_StreamCard>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _selectController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _selectController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _selectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = widget.data['color'] as Color;
    final bool active = isHovered || widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _selectController.forward(),
        onTapUp: (_) {
          _selectController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _selectController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()..translate(0.0, active ? -6.0 : 0.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isSelected
                    ? accentColor
                    : isHovered
                    ? accentColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.08),
                width: widget.isSelected ? 2.0 : 1.0,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.35),
                        blurRadius: 28,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
              image: DecorationImage(
                image: NetworkImage(widget.data['image'] as String),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(active ? 0.35 : 0.55),
                  BlendMode.darken,
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // ── Accent color tint overlay on hover ──
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 280),
                    opacity: active ? 0.12 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [accentColor, Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  // ── Bottom gradient ──────────────────────
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.3, 1.0],
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Selected checkmark ───────────────────
                  if (widget.isSelected)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),

                  // ── Card Content ─────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Emoji + Title row (localized title)
                          Row(
                            children: [
                              Text(
                                widget.data['emoji'] as String,
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Career chips (career names always English)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (widget.data['careers'] as List<String>)
                                .map(
                                  (career) => _CareerChip(
                                    label: career,
                                    color: accentColor,
                                  ),
                                )
                                .toList(),
                          ),

                          const SizedBox(height: 12),

                          // Divider
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.12),
                          ),

                          const SizedBox(height: 10),

                          // Explore / Select button (localized)
                          Row(
                            children: [
                              const Spacer(),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? accentColor
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  active
                                      ? widget.selectLabel
                                      : widget.exploreLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: active
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

// ──────────────────────────────────────────────────────────
// CAREER CHIP WIDGET
// ──────────────────────────────────────────────────────────
class _CareerChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CareerChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color.withOpacity(0.95),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}