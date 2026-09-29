import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final results = AppScope.of(context).search(_query);
    return Scaffold(
      appBar: AppBar(title: Text(l.navSearch)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _query.trim().isEmpty
                ? Center(
                    child: Text(l.searchPrompt,
                        style: const TextStyle(color: AppColors.textSecondary)),
                  )
                : results.isEmpty
                    ? Center(
                        child: Text(l.searchNoResult,
                            style: const TextStyle(color: AppColors.textSecondary)),
                      )
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, i) => ScpTile(scp: results[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
