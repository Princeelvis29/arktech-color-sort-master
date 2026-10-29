import 'package:flutter/material.dart';

class Brand {
  static const navy = Color(0xFF131038);
  static const purple = Color(0xFF7047FF);
  static const aqua = Color(0xFF20C6ED);
  static const pink = Color(0xFFFF4D91);
  static const gold = Color(0xFFFFC94C);
  static const white = Color(0xFFF9F8FF);
  static const muted = Color(0xFFC7C1E7);
  static const panel = Color(0xFF2B225E);

  static const liquids = <Color>[
    Color(0xFFFF587B),
    Color(0xFF20D4F0),
    Color(0xFFFFCC4D),
    Color(0xFF8A60FF),
  ];

  static const themeNames = <String, String>{
    'crystal': 'Crystal Classic',
    'neon': 'Neon Nights',
    'ocean': 'Ocean Depths',
    'sunset': 'Sunset Glow',
    'emerald': 'Emerald Garden',
  };

  static List<Color> liquidsFor(String theme) => switch (theme) {
    'neon' => const [
      Color(0xFFFF4AA8),
      Color(0xFF3FFFD6),
      Color(0xFFFFD45E),
      Color(0xFFB16BFF),
      Color(0xFF28A8FF),
      Color(0xFFFF723B),
    ],
    'ocean' => const [
      Color(0xFF5FB2FF),
      Color(0xFF18E7B4),
      Color(0xFFFFC85A),
      Color(0xFF8669FA),
      Color(0xFFEF637F),
      Color(0xFF3DDDEB),
    ],
    'sunset' => const [
      Color(0xFFFF6782),
      Color(0xFFFFBC54),
      Color(0xFFAE6EFF),
      Color(0xFF3BCBDB),
      Color(0xFFFF8652),
      Color(0xFF5C82F6),
    ],
    'emerald' => const [
      Color(0xFFFA7698),
      Color(0xFF34E3A3),
      Color(0xFFF9D96B),
      Color(0xFF8B7CF9),
      Color(0xFF39C3E9),
      Color(0xFFF78E61),
    ],
    _ => const [
      Color(0xFFFF587B),
      Color(0xFF20D4F0),
      Color(0xFFFFCC4D),
      Color(0xFF8A60FF),
      Color(0xFF32E4AA),
      Color(0xFFFF8A42),
    ],
  };

  static LinearGradient backgroundFor(String theme) => switch (theme) {
    'neon' => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF080B2D), Color(0xFF352052), Color(0xFF070C26)],
    ),
    'ocean' => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF08213F), Color(0xFF18486E), Color(0xFF081E40)],
    ),
    'sunset' => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF31143D), Color(0xFF7D3765), Color(0xFF301735)],
    ),
    'emerald' => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0C2731), Color(0xFF17534F), Color(0xFF0A252C)],
    ),
    _ => background,
  };

  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF161140), Color(0xFF35216F), Color(0xFF17113D)],
  );
}

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    required this.child,
    this.theme = 'crystal',
    super.key,
  });
  final String theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: Brand.backgroundFor(theme)),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -50,
            child: _Glow(color: Brand.purple.withValues(alpha: .23), size: 230),
          ),
          Positioned(
            bottom: 70,
            left: -85,
            child: _Glow(color: Brand.aqua.withValues(alpha: .10), size: 210),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class GradientAction extends StatelessWidget {
  const GradientAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.secondary = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: secondary
                ? null
                : const LinearGradient(colors: [Brand.aqua, Brand.purple]),
            color: secondary ? Brand.panel : null,
            border: secondary ? Border.all(color: Colors.white24) : null,
            boxShadow: secondary
                ? null
                : [
                    BoxShadow(
                      color: Brand.purple.withValues(alpha: .26),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
