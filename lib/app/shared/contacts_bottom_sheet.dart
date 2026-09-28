import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactSheet extends StatefulWidget {
  final List<Contact> contacts;
  final List<Contact> initiallySelected;

  const ContactSheet({
    super.key,
    required this.contacts,
    this.initiallySelected = const [],
  });

  @override
  State<ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends State<ContactSheet> {
  static const int _maxSelection = 3;
  static const int _minSelection = 2;
  Timer? _timer;
  final interBaseStyle = GoogleFonts.inter();
  final syneBaseStyle = GoogleFonts.syne(height: 1.15);

  final Set<Contact> _selected = {};
  final TextEditingController _searchController = TextEditingController();
  late final List<Contact> _all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _all = [...widget.contacts]
      ..sort(
        (a, b) => _nameOf(a).toLowerCase().compareTo(_nameOf(b).toLowerCase()),
      );
    _selected.addAll(widget.initiallySelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();

    super.dispose();
  }

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------

  String _nameOf(Contact c) {
    final n = c.displayName?.trim();
    return (n == null || n.isEmpty) ? 'Unknown contact' : n;
  }

  String? _phoneOf(Contact c) {
    if (c.phones.isEmpty) return null;
    final number = c.phones.first.number.trim();
    return number.isEmpty ? null : number;
  }

  String _initialsOf(String name) {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  List<Contact> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    final digits = q.replaceAll(RegExp(r'[^0-9+]'), '');
    final numeric = RegExp(r'^[0-9+\-\s()]+$').hasMatch(q);
    return _all.where((c) {
      if (_nameOf(c).toLowerCase().contains(q)) return true;
      if (!numeric || digits.isEmpty) return false;
      return c.phones.any(
        (p) => p.number.replaceAll(RegExp(r'[^0-9+]'), '').contains(digits),
      );
    }).toList();
  }

  void _toggle(Contact contact) {
    if (_phoneOf(contact) == null) return;

    if (_selected.contains(contact)) {
      setState(() => _selected.remove(contact));
    } else if (_selected.length < _maxSelection) {
      setState(() => _selected.add(contact));
    } else {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.selectionClick();
  }

  // ------------------------------------------------------------------
  // Build
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final media = MediaQuery.of(context);

    final keyboard = media.viewInsets.bottom;
    final bottomPad = keyboard > 0 ? keyboard + 16 : media.padding.bottom + 16;

    final filtered = _filtered;
    final count = _selected.length;
    final atMax = count >= _maxSelection;
    final ready = count >= _minSelection;
    final remaining = _minSelection - count;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Emergency contacts',
                      style: syneBaseStyle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '$count/$_maxSelection',
                    style: interBaseStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ready
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Choose $_minSelection to $_maxSelection people to alert in an emergency.',
                style: interBaseStyle.copyWith(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),

              // Search
              TextField(
                controller: _searchController,
                // TextField
                onChanged: (value) {
                  _timer?.cancel();
                  _timer = Timer(const Duration(milliseconds: 300), () {
                    if (!mounted) return;
                    setState(() => _query = value);
                  });
                },
                // onChanged: (v){setState(() => _query = v ,
                style: interBaseStyle.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: interBaseStyle.copyWith(
                    fontSize: 15,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // List
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No contacts found',
                            style: interBaseStyle.copyWith(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final contact = filtered[index];
                          final name = _nameOf(contact);
                          final phone = _phoneOf(contact);
                          final selected = _selected.contains(contact);

                          // Fade out everything else once the limit is hit.
                          final dimmed = phone == null || (atMax && !selected);

                          return _ContactRow(
                            name: name,
                            phone: phone,
                            initials: _initialsOf(name),
                            selected: selected,
                            dimmed: dimmed,
                            colorScheme: colorScheme,
                            interBaseStyle: interBaseStyle,
                            onTap: () => _toggle(contact),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),

              // Confirm
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: ready
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: ready
                        ? () => Navigator.pop(context, _selected.toList())
                        : null,
                    child: Center(
                      child: Text(
                        ready ? 'Confirm' : 'Select $remaining more',
                        style: interBaseStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ready
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// CONTACT ROW
// ==================================================================

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.name,
    required this.phone,
    required this.initials,
    required this.selected,
    required this.dimmed,
    required this.colorScheme,
    required this.interBaseStyle,
    required this.onTap,
  });

  final String name;
  final String? phone;
  final String initials;
  final bool selected;
  final bool dimmed;
  final ColorScheme colorScheme;
  final TextStyle interBaseStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: dimmed ? 0.4 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: phone == null ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              // Avatar turns into a check when selected
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: colorScheme.onPrimary,
                      )
                    : Text(
                        initials,
                        style: interBaseStyle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: interBaseStyle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone ?? 'No phone number',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: interBaseStyle.copyWith(
                        fontSize: 12.5,
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
