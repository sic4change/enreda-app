import 'package:enreda_app/app/home/models/favourite_cv.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Dialog for creating or editing a [FavouriteCV].
import 'package:enreda_app/services/auth.dart';

/// Dialog for creating or editing a [FavouriteCV].
///
/// Pass [existing] to pre-fill the form (edit mode).
/// Pass [draftCV] to provide pre-selected experience/education IDs when creating.
/// [userId] is required for the create-mode Firestore write.
/// [onSaved] is called with the resulting [FavouriteCV] (with its Firestore ID).
class FavouriteCVDialog extends StatefulWidget {
  const FavouriteCVDialog({
    super.key,
    required this.userId,
    required this.interests,
    this.existing,
    this.draftCV,
    this.onSaved,
  });

  final String userId;
  final List<Interest> interests;
  final FavouriteCV? existing;
  final FavouriteCV? draftCV;
  final void Function(FavouriteCV saved)? onSaved;

  @override
  State<FavouriteCVDialog> createState() => _FavouriteCVDialogState();
}

class _FavouriteCVDialogState extends State<FavouriteCVDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  Interest? _selectedInterest;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existing?.name ?? '');

    // Pre-select the sector that matches the existing FavouriteCV's sectorId.
    if (_isEdit && widget.existing!.sectorId.isNotEmpty) {
      _selectedInterest = widget.interests.firstWhere(
        (i) => i.interestId == widget.existing!.sectorId,
        orElse: () => widget.interests.isNotEmpty
            ? widget.interests.first
            : Interest(name: ''),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    final resolvedUserId = (widget.userId.isNotEmpty)
        ? widget.userId
        : (auth.currentUser?.uid ?? '');

    final sectorId = _selectedInterest?.interestId ?? '';
    final sectorName = _selectedInterest?.name ?? '';

    try {
      if (_isEdit) {
        // --- Edit mode: update the existing document ---
        final updated = widget.existing!.copyWith(
          name: _nameController.text.trim(),
          sectorId: sectorId,
          sectorName: sectorName,
          updatedAt: DateTime.now(),
        );
        await database.updateFavouriteCV(updated);
        widget.onSaved?.call(updated);
      } else {
        // --- Create mode: add a new document and capture its ID ---
        final base = widget.draftCV ?? FavouriteCV(userId: resolvedUserId, name: '', sectorId: '', sectorName: '');
        final draft = base.copyWith(
          userId: resolvedUserId,
          name: _nameController.text.trim(),
          sectorId: sectorId,
          sectorName: sectorName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final newId = await database.addFavouriteCV(draft);
        final saved = draft.copyWith(favouriteCVId: newId);
        widget.onSaved?.call(saved);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('FavouriteCVDialog save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el currículum favorito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 36, 40, 36),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header (Centered, 2 lines) ──────────────────────────────
                Text(
                  _isEdit ? 'Editar currículum en:' : 'Guardar currículum en:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF054D5E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Currículums Favoritos',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF054D5E),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Nombre del currículum ───────────────────────────────────
                Text(
                  'Nombre del currículum',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF054D5E),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  maxLength: 60,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ej. Currículum Bombero',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF054D5E), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El nombre no puede estar vacío.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Sector del currículum ───────────────────────────────────
                Text(
                  'Sector del currículum',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF054D5E),
                  ),
                ),
                const SizedBox(height: 8),
                widget.interests.isEmpty
                    ? const Text('No hay sectores disponibles.')
                    : DropdownButtonFormField<Interest>(
                        value: _selectedInterest,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF00C9C9),
                          size: 28,
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF054D5E), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        hint: Text(
                          'Selecciona un sector',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: Colors.black45,
                          ),
                        ),
                        items: widget.interests
                            .map(
                              (i) => DropdownMenuItem<Interest>(
                                value: i,
                                child: Text(
                                  i.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedInterest = v),
                        validator: (v) =>
                            v == null ? 'Selecciona un sector.' : null,
                      ),
                const SizedBox(height: 36),

                // ── Centered Action Buttons (Cancelar / Guardar) ───────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed:
                          _loading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF054D5E), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 14),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF054D5E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C9C9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Guardar',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
