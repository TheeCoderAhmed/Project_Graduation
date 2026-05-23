import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../models/provider_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common/loading_indicator.dart';

/// Admin-only panel listing doctors' pending practice changes. Each can be
/// approved (pending values copied to live fields) or rejected (discarded).
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _service = FirestoreService();
  List<ProviderModel> _pending = [];
  bool _loading = true;
  String? _busyId; // provider currently being approved/rejected

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    List<ProviderModel> list = [];
    try {
      list = await _service.getPendingPracticeChanges();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _pending = list;
      _loading = false;
    });
  }

  Future<void> _approve(ProviderModel p) async {
    setState(() => _busyId = p.providerId);
    bool ok = true;
    try {
      await _service.approvePracticeChange(p);
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() {
      _busyId = null;
      if (ok) _pending.removeWhere((x) => x.providerId == p.providerId);
    });
    _snack(ok ? 'Change approved' : 'Could not approve', ok);
  }

  Future<void> _reject(ProviderModel p) async {
    setState(() => _busyId = p.providerId);
    bool ok = true;
    try {
      await _service.rejectPracticeChange(p.providerId);
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() {
      _busyId = null;
      if (ok) _pending.removeWhere((x) => x.providerId == p.providerId);
    });
    _snack(ok ? 'Change rejected' : 'Could not reject', ok);
  }

  void _snack(String msg, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? AppColors.primary : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Admin · Approvals',
            style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const LoadingIndicator(message: 'Loading approvals...')
          : _pending.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(AppTheme.containerMargin),
                    children: [
                      Text('Pending practice changes',
                          style: GoogleFonts.manrope(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('${_pending.length} awaiting review',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 20),
                      ..._pending.map(_buildCard),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCard(ProviderModel p) {
    final busy = _busyId == p.providerId;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.name,
              style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          if (p.specialty.isNotEmpty)
            Text(p.specialty,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          _diffRow('Hospital', p.hospital, p.pendingHospital),
          const SizedBox(height: 10),
          _diffRow('Department', p.department, p.pendingDepartment),
          const SizedBox(height: 10),
          _diffRow('Room', p.room, p.pendingRoom),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : () => _reject(p),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: busy ? null : () => _approve(p),
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded, size: 18),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _diffRow(String label, String? current, String? pending) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  (current == null || current.isEmpty) ? '—' : current,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.outline,
                      decoration: TextDecoration.lineThrough),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 14, color: AppColors.outline),
              ),
              Flexible(
                child: Text(
                  (pending == null || pending.isEmpty) ? '—' : pending,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_rounded,
                size: 64, color: AppColors.divider),
            const SizedBox(height: 16),
            Text('All caught up',
                style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('No pending practice changes to review.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
