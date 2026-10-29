import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colorsortmaster/ui/contact_screen.dart';

void main() {
  test('ARKTECH contact link destinations are correctly encoded', () {
    expect(
      ArktechContact.whatsapp(ArktechContact.phone1).toString(),
      'https://wa.me/2348134839763',
    );
    expect(
      ArktechContact.whatsapp(ArktechContact.phone2).toString(),
      'https://wa.me/2348050344913',
    );
    expect(ArktechContact.call(ArktechContact.phone1).scheme, 'tel');
    expect(ArktechContact.email(ArktechContact.email1).scheme, 'mailto');
    expect(
      ArktechContact.moreApps.toString(),
      'https://app.arktechsolution.top',
    );
  });

  testWidgets('Contact Us displays official details and working link action', (
    tester,
  ) async {
    final links = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: ContactScreen(
          theme: 'crystal',
          onOpenUri: (uri) async {
            links.add(uri);
            return true;
          },
        ),
      ),
    );
    expect(find.text('CONTACT US'), findsOneWidget);
    expect(find.text(ArktechContact.phone1), findsOneWidget);
    expect(find.text(ArktechContact.phone2), findsOneWidget);
    expect(find.text(ArktechContact.email1), findsOneWidget);
    expect(find.text(ArktechContact.email2), findsOneWidget);
    expect(find.text(ArktechContact.appStore), findsOneWidget);

    final whatsapp = find.byKey(const Key('contact-whatsapp-1'));
    await tester.ensureVisible(whatsapp);
    await tester.tap(whatsapp);
    await tester.pump();
    expect(links.single.toString(), 'https://wa.me/2348134839763');
  });

  testWidgets('Contact Us is scrollable on 320 by 640 screens', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      const MaterialApp(home: ContactScreen(theme: 'crystal')),
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('contact-scroll')), findsOneWidget);
    final homeButton = find.byKey(const Key('contact-home'));
    await tester.ensureVisible(homeButton);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(homeButton, findsOneWidget);
  });
}
