import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_smart/core/constants/app_constants.dart';
import 'package:study_smart/core/widgets/app_button.dart';
import 'package:study_smart/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:study_smart/features/study_items/domain/entities/deck_entity.dart';
import 'package:study_smart/features/study_items/domain/entities/study_item_entity.dart';
import 'package:study_smart/features/study_items/presentation/viewmodels/study_viewmodel.dart';
import 'package:uuid/uuid.dart';

/// Modal bottom sheet for creating a new flashcard.
///
/// Usage:
/// ```dart
/// AddStudyItemSheet.show(context, deck: deck);
/// ```
class AddStudyItemSheet extends StatefulWidget {
  const AddStudyItemSheet({super.key, required this.deck});

  final DeckEntity deck;

  /// Convenience launcher — handles [isScrollControlled] + safe area.
  static Future<void> show(BuildContext context, {required DeckEntity deck}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddStudyItemSheet(deck: deck),
    );
  }

  @override
  State<AddStudyItemSheet> createState() => _AddStudyItemSheetState();
}

class _AddStudyItemSheetState extends State<AddStudyItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _frontCtrl = TextEditingController();
  final _backCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  final List<String> _tags = [];

  @override
  void dispose() {
    _frontCtrl.dispose();
    _backCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  // ── Tag helpers ────────────────────────────────────────────────────────────

  void _addTag(String raw) {
    final tag = raw.trim().toLowerCase();
    if (tag.isEmpty || _tags.contains(tag) || _tags.length >= 8) return;
    setState(() {
      _tags.add(tag);
      _tagCtrl.clear();
    });
  }

  void _removeTag(String tag) => setState(() => _tags.remove(tag));

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<StudyViewModel>();
    final auth = context.read<AuthViewModel>();
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      _showError('You must be signed in to add flashcards.');
      return;
    }

    final item = StudyItemEntity(
      id: const Uuid().v4(),
      deckId: widget.deck.id,
      userId: uid,
      front: _frontCtrl.text.trim(),
      back: _backCtrl.text.trim(),
      tags: List.unmodifiable(_tags),
      createdAt: DateTime.now(),
      nextReviewDate: DateTime.now(),
      easeFactor: 250,
      interval: 0,
      repetitions: 0,
    );

    final result = await vm.addStudyItem(item);

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pop();
      _showSuccess();
    } else {
      _showError(result.error ?? 'Something went wrong. Please try again.');
    }
  }

  // ── Snackbars ──────────────────────────────────────────────────────────────

  void _showSuccess() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppConstants.paddingM),
          backgroundColor: Colors.green.shade700,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM)),
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Flashcard added!',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppConstants.paddingM),
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM)),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(widget.deck.colorValue);
    final isAdding = context.watch<StudyViewModel>().isAddingItem;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingL,
        AppConstants.paddingM,
        AppConstants.paddingL,
        MediaQuery.of(context).viewInsets.bottom + AppConstants.paddingL,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle bar ─────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
              ),
            ),

            // ── Header ─────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 6,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                  ),
                ),
                const SizedBox(width: 10),
                Text('New Flashcard',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(widget.deck.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: color, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: AppConstants.paddingL),

            // ── Front field ────────────────────────────────────────────
            _SectionLabel(label: 'Front', icon: Icons.help_outline, color: color),
            const SizedBox(height: AppConstants.paddingS),
            TextFormField(
              controller: _frontCtrl,
              autofocus: true,
              maxLines: 3,
              enabled: !isAdding,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'e.g. What is the time complexity of Quick Sort?',
                hintStyle: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.35)),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(color: color, width: 2),
                ),
                contentPadding: const EdgeInsets.all(AppConstants.paddingM),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Front side cannot be empty.';
                }
                if (v.trim().length > 500) {
                  return 'Front side must be 500 characters or fewer.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.paddingM),

            // ── Back field ─────────────────────────────────────────────
            _SectionLabel(label: 'Back', icon: Icons.lightbulb_outline, color: color),
            const SizedBox(height: AppConstants.paddingS),
            TextFormField(
              controller: _backCtrl,
              maxLines: 3,
              enabled: !isAdding,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'e.g. O(n log n) average, O(n²) worst case',
                hintStyle: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.35)),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(color: color, width: 2),
                ),
                contentPadding: const EdgeInsets.all(AppConstants.paddingM),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Back side cannot be empty.';
                }
                if (v.trim().length > 1000) {
                  return 'Back side must be 1000 characters or fewer.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.paddingM),

            // ── Tags ───────────────────────────────────────────────────
            _SectionLabel(label: 'Tags (optional)', icon: Icons.label_outline, color: color),
            const SizedBox(height: AppConstants.paddingS),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagCtrl,
                    enabled: !isAdding,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'e.g. biology, chapter-3',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.35)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        borderSide: BorderSide(color: color, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingM,
                        vertical: AppConstants.paddingS,
                      ),
                    ),
                    onFieldSubmitted: _addTag,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingS),
                _AddTagButton(
                  color: color,
                  onTap: () => _addTag(_tagCtrl.text),
                  enabled: !isAdding,
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingS),
              Wrap(
                spacing: AppConstants.paddingS,
                runSpacing: AppConstants.paddingXS,
                children: _tags
                    .map((tag) => _TagChip(
                          label: tag,
                          color: color,
                          onDelete: isAdding ? null : () => _removeTag(tag),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: AppConstants.paddingL),

            // ── Submit button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: color.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                  elevation: 0,
                ),
                onPressed: isAdding ? null : _submit,
                child: isAdding
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Add to Deck',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private helper widgets ─────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(
      {required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _AddTagButton extends StatelessWidget {
  const _AddTagButton(
      {required this.color, required this.onTap, required this.enabled});
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(enabled ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: color.withOpacity(enabled ? 0.4 : 0.2)),
        ),
        child: Icon(Icons.add, color: enabled ? color : color.withOpacity(0.4),
            size: 20),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip(
      {required this.label, required this.color, required this.onDelete});
  final String label;
  final Color color;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Chip(
        label: Text(label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        backgroundColor: color.withOpacity(0.1),
        side: BorderSide(color: color.withOpacity(0.3)),
        deleteIcon: Icon(Icons.close, size: 14, color: color.withOpacity(0.7)),
        onDeleted: onDelete,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
