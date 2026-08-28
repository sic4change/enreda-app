import 'package:enreda_app/app/home/curriculum/favourite_cv_dialog.dart';
import 'package:enreda_app/app/home/curriculum/my_curriculum_page.dart';
import 'package:enreda_app/app/home/models/favourite_cv.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:enreda_app/services/auth.dart';

/// Tab that lists the user's saved [FavouriteCV]s.
///
/// Each card shows the CV name, its sector, and Edit / Delete action buttons.
/// Tapping the card body opens the CV in "favourite mode" via [onOpenFavourite].
class FavouriteCVsTab extends StatefulWidget {
  const FavouriteCVsTab({
    super.key,
    required this.user,
    required this.onOpenFavourite,
  });

  final UserEnreda user;

  /// Called when the user taps a card to open the CV in "favourite mode".
  final void Function(FavouriteCV cv) onOpenFavourite;

  @override
  State<FavouriteCVsTab> createState() => _FavouriteCVsTabState();
}

class _FavouriteCVsTabState extends State<FavouriteCVsTab> {
  Stream<List<FavouriteCV>>? _stream;
  Stream<List<Interest>>? _interestsStream;

  @override
  void initState() {
    super.initState();
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    final uid = (widget.user.userId != null && widget.user.userId!.isNotEmpty)
        ? widget.user.userId!
        : (auth.currentUser?.uid ?? '');
    _stream = database.favouriteCVsStream(uid);
    _interestsStream = database.interestStream();
  }

  void _showEditDialog(List<Interest> interests, {FavouriteCV? existing}) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final uid = (widget.user.userId != null && widget.user.userId!.isNotEmpty)
        ? widget.user.userId!
        : (auth.currentUser?.uid ?? '');
    showDialog(
      context: context,
      builder: (_) => FavouriteCVDialog(
        userId: uid,
        interests: interests,
        existing: existing,
      ),
    );
  }

  Future<void> _confirmDelete(FavouriteCV cv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Eliminar currículum?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.primary900,
            fontSize: 18,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${cv.name}"? Esta acción no se puede deshacer.',
          style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteFavouriteCV(cv);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Interest>>(
      stream: _interestsStream,
      builder: (context, interestSnap) {
        final interests = interestSnap.data ?? [];

        return StreamBuilder<List<FavouriteCV>>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final cvs = snap.data ?? [];

            if (cvs.isEmpty) {
              return _buildEmptyState();
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = Responsive.isMobile(context);
                return SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: cvs
                        .map((cv) => _FavouriteCVCard(
                              cv: cv,
                              isMobile: isMobile,
                              maxWidth: constraints.maxWidth,
                              onOpen: () => widget.onOpenFavourite(cv),
                              onEdit: () =>
                                  _showEditDialog(interests, existing: cv),
                              onDelete: () => _confirmDelete(cv),
                            ))
                        .toList(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 960),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡Todavía no tienes ningún currículum guardado!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF054D5E),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Previsualiza tu currículum en la sección "Mi currículum" para guardarlo aquí.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF054D5E),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 28),
              Image.asset(
                ImagePath.FAVOURITE_CV_EMPTY,
                height: 220,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single card representing one [FavouriteCV].
class _FavouriteCVCard extends StatelessWidget {
  const _FavouriteCVCard({
    required this.cv,
    required this.isMobile,
    required this.maxWidth,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final FavouriteCV cv;
  final bool isMobile;
  final double maxWidth;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  double get _cardWidth {
    if (isMobile) return maxWidth;
    if (maxWidth > 1100) {
      final w = (maxWidth - 48 - 48) / 3;
      return w.clamp(320, 390);
    } else if (maxWidth > 700) {
      final w = (maxWidth - 48 - 24) / 2;
      return w.clamp(320, 420);
    }
    return maxWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Title + Edit pencil | Delete bin ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        cv.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF054D5E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF054D5E),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFFE0E0E0), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFF054D5E),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Mini CV Preview box ───────────────────────────────────────────
          InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 480,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              clipBehavior: Clip.hardEdge,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Transform.scale(
                    scale: 0.35,
                    alignment: Alignment.topLeft,
                    child: MyCurriculumPage(
                      mini: true,
                      favouriteCV: cv,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
