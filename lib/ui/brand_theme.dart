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

  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF161140), Color(0xFF35216F), Color(0xFF17113D)],
  );
}

class GradientBackground extends StatelessWidget {
  const GradientBackground({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: Brand.background),
      child: Stack(children: [
        Positioned(top: -70, right: -50, child: _Glow(color: Brand.purple.withValues(alpha: .23), size: 230)),
        Positioned(bottom: 70, left: -85, child: _Glow(color: Brand.aqua.withValues(alpha: .10), size: 210)),
        child,
      ]),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class GradientAction extends StatelessWidget {
  const GradientAction({super.key, required this.label, required this.icon, required this.onTap, this.secondary = false});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    return Semantics(button: true, label: label, child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity, height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: secondary ? null : const LinearGradient(colors: [Brand.aqua, Brand.purple]),
          color: secondary ? Brand.panel : null,
          border: secondary ? Border.all(color: Colors.white24) : null,
          boxShadow: secondary ? null : [BoxShadow(color: Brand.purple.withValues(alpha: .26), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: .4)),
        ]),
      ),
    ));
  }
}
