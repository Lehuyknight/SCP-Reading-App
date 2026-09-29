import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';

const privacyPolicyUrl = 'https://lehuyknight.github.io/SCP-Reading-App/privacy-policy.html';
const _licenseUrl = 'https://creativecommons.org/licenses/by-sa/3.0/';
const _sourceUrl = 'https://scp-wiki.wikidot.com/';

Future<void> openPrivacyPolicy() =>
    launchUrl(Uri.parse(privacyPolicyUrl), mode: LaunchMode.externalApplication);

class LicensePageView extends StatelessWidget {
  const LicensePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const body = TextStyle(fontSize: 15, height: 1.55);

    Widget paragraph(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: body)),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.licenseTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          paragraph(Icons.menu_book_outlined, l.licenseIntro),
          paragraph(Icons.person_outline, l.licenseAttribution),
          paragraph(Icons.translate, l.licenseShareAlike),
          paragraph(Icons.image_outlined, l.licenseImages),
          paragraph(Icons.info_outline, l.licenseUnofficial),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                launchUrl(Uri.parse(_licenseUrl), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.gavel_outlined),
            label: Text(l.openLicense),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                launchUrl(Uri.parse(_sourceUrl), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.public),
            label: const Text('scp-wiki.wikidot.com'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: openPrivacyPolicy,
            icon: const Icon(Icons.privacy_tip_outlined),
            label: Text(l.privacyPolicy),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: l.appTitle,
              applicationLegalese: 'Content © SCP Wiki contributors, CC BY-SA 3.0',
            ),
            icon: const Icon(Icons.code),
            label: Text(l.openSourceLicenses),
          ),
        ],
      ),
    );
  }
}
