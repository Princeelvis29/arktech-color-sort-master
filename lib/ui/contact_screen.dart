import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'brand_theme.dart';

/// ARKTECH SOLUTIONS' official contact details, shared across game releases.
class ArktechContact {
  static const phone1 = '+2348134839763';
  static const phone2 = '+2348050344913';
  static const email1 = 'info@arktechsolution.top';
  static const email2 = 'arktechsolutioncompany@gmail.com';
  static const appStore = 'https://app.arktechsolution.top';

  static Uri call(String number) => Uri(scheme: 'tel', path: number);
  static Uri whatsapp(String number) =>
      Uri.parse('https://wa.me/${number.replaceAll(RegExp(r'\D'), '')}');
  static Uri email(String address) => Uri(
    scheme: 'mailto',
    path: address,
    query:
        'subject=${Uri.encodeComponent('ARKTECH Color Sort Master enquiry')}',
  );
  static Uri get moreApps => Uri.parse(appStore);
}

/// Contact page adapted to Color Sort Master's visual identity.
/// It intentionally does not depend on login, game progress, or network APIs.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key, required this.theme, this.onOpenUri});

  final String theme;

  /// Allows tests to verify the intended URL without launching another app.
  final Future<bool> Function(Uri)? onOpenUri;

  Future<void> _open(BuildContext context, Uri target, String fallback) async {
    try {
      final opened =
          await (onOpenUri?.call(target) ??
              launchUrl(target, mode: LaunchMode.platformDefault));
      if (opened) return;
    } catch (_) {
      // Missing handlers are normal in desktop browsers and some emulators.
    }
    if (!context.mounted) return;
    await _copy(context, fallback, fallbackNotice: true);
  }

  Future<void> _copy(
    BuildContext context,
    String value, {
    bool fallbackNotice = false,
  }) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          fallbackNotice
              ? 'Could not open a compatible app. Copied: $value'
              : 'Copied: $value',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _home(BuildContext context) =>
      Navigator.of(context).popUntil((route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 370;
    return Scaffold(
      backgroundColor: Brand.navy,
      body: GradientBackground(
        theme: theme,
        child: SafeArea(
          child: SingleChildScrollView(
            key: const Key('contact-scroll'),
            padding: EdgeInsets.fromLTRB(
              narrow ? 14 : 20,
              12,
              narrow ? 14 : 20,
              28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      // CONTACT HEADER RESPONSIVE FIX V1
                      children: [
                        IconButton(
                          key: const Key('contact-top-back'),
                          tooltip: 'Back to game',
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Brand.white,
                          ),
                        ),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: const Text(
                              'ARKTECH SOLUTIONS',
                              maxLines: 1,
                              style: TextStyle(
                                color: Brand.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('contact-top-home'),
                          tooltip: 'Home',
                          onPressed: () => _home(context),
                          icon: const Icon(
                            Icons.home_rounded,
                            color: Brand.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF4A2B9A),
                            Brand.purple,
                            Color(0xFF174C88),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Brand.purple.withValues(alpha: .23),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/game_icon_1024.png',
                              width: 72,
                              height: 72,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'CONTACT US',
                            key: Key('contact-title'),
                            style: TextStyle(
                              color: Brand.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 29,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'We are here to help. Connect with the\nARKTECH SOLUTIONS team.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Brand.white,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ContactSection(
                      icon: Icons.phone_in_talk_rounded,
                      color: const Color(0xFF32DBA5),
                      title: 'PHONE / WHATSAPP',
                      children: [
                        _NumberRow(
                          number: ArktechContact.phone1,
                          suffix: '1',
                          onCall: () => _open(
                            context,
                            ArktechContact.call(ArktechContact.phone1),
                            ArktechContact.phone1,
                          ),
                          onWhatsapp: () => _open(
                            context,
                            ArktechContact.whatsapp(ArktechContact.phone1),
                            ArktechContact.phone1,
                          ),
                          onCopy: () => _copy(context, ArktechContact.phone1),
                        ),
                        const Divider(color: Colors.white12),
                        _NumberRow(
                          number: ArktechContact.phone2,
                          suffix: '2',
                          onCall: () => _open(
                            context,
                            ArktechContact.call(ArktechContact.phone2),
                            ArktechContact.phone2,
                          ),
                          onWhatsapp: () => _open(
                            context,
                            ArktechContact.whatsapp(ArktechContact.phone2),
                            ArktechContact.phone2,
                          ),
                          onCopy: () => _copy(context, ArktechContact.phone2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ContactSection(
                      icon: Icons.mark_email_read_rounded,
                      color: const Color(0xFFFFB85F),
                      title: 'EMAIL SUPPORT',
                      children: [
                        _LinkRow(
                          value: ArktechContact.email1,
                          icon: Icons.mail_outline_rounded,
                          keyName: 'contact-email-primary',
                          onOpen: () => _open(
                            context,
                            ArktechContact.email(ArktechContact.email1),
                            ArktechContact.email1,
                          ),
                          onCopy: () => _copy(context, ArktechContact.email1),
                        ),
                        const Divider(color: Colors.white12),
                        _LinkRow(
                          value: ArktechContact.email2,
                          icon: Icons.mail_outline_rounded,
                          keyName: 'contact-email-secondary',
                          onOpen: () => _open(
                            context,
                            ArktechContact.email(ArktechContact.email2),
                            ArktechContact.email2,
                          ),
                          onCopy: () => _copy(context, ArktechContact.email2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ContactSection(
                      icon: Icons.apps_rounded,
                      color: Brand.aqua,
                      title: 'MORE ARKTECH APPS',
                      children: [
                        _LinkRow(
                          value: ArktechContact.appStore,
                          icon: Icons.open_in_new_rounded,
                          keyName: 'contact-app-store',
                          onOpen: () => _open(
                            context,
                            ArktechContact.moreApps,
                            ArktechContact.appStore,
                          ),
                          onCopy: () => _copy(context, ArktechContact.appStore),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('contact-back'),
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('BACK'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Brand.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: const Color(0xFF553170),
                              side: const BorderSide(color: Colors.white30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            key: const Key('contact-home'),
                            onPressed: () => _home(context),
                            icon: const Icon(Icons.home_rounded),
                            label: const Text('HOME'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Brand.purple,
                              foregroundColor: Brand.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Powered by ARKTECH SOLUTIONS',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Brand.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
  });
  final IconData icon;
  final Color color;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: Brand.panel.withValues(alpha: .93),
      border: Border.all(color: color.withValues(alpha: .45)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .17),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Brand.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

class _NumberRow extends StatelessWidget {
  const _NumberRow({
    required this.number,
    required this.suffix,
    required this.onCall,
    required this.onWhatsapp,
    required this.onCopy,
  });
  final String number;
  final String suffix;
  final VoidCallback onCall;
  final VoidCallback onWhatsapp;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        number,
        style: const TextStyle(
          color: Brand.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 7,
        children: [
          _SmallAction(
            key: Key('contact-call-$suffix'),
            label: 'CALL',
            icon: Icons.call_rounded,
            color: Brand.aqua,
            onPressed: onCall,
          ),
          _SmallAction(
            key: Key('contact-whatsapp-$suffix'),
            label: 'WHATSAPP',
            icon: Icons.chat_bubble_rounded,
            color: const Color(0xFF32DBA5),
            onPressed: onWhatsapp,
          ),
          _SmallAction(
            key: Key('contact-copy-phone-$suffix'),
            label: 'COPY',
            icon: Icons.copy_rounded,
            color: Brand.muted,
            onPressed: onCopy,
          ),
        ],
      ),
    ],
  );
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.value,
    required this.icon,
    required this.keyName,
    required this.onOpen,
    required this.onCopy,
  });
  final String value;
  final IconData icon;
  final String keyName;
  final VoidCallback onOpen;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        softWrap: true,
        style: const TextStyle(
          color: Brand.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 7,
        children: [
          _SmallAction(
            key: Key(keyName),
            label: 'OPEN',
            icon: icon,
            color: Brand.aqua,
            onPressed: onOpen,
          ),
          _SmallAction(
            key: Key('$keyName-copy'),
            label: 'COPY',
            icon: Icons.copy_rounded,
            color: Brand.muted,
            onPressed: onCopy,
          ),
        ],
      ),
    ],
  );
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: color,
      backgroundColor: color.withValues(alpha: .10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      visualDensity: VisualDensity.compact,
      minimumSize: const Size(0, 32),
      side: BorderSide(color: color.withValues(alpha: .35)),
    ),
    icon: Icon(icon, size: 14),
    label: Text(
      label,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
    ),
  );
}
