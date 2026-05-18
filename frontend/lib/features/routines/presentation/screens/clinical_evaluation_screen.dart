import 'package:flutter/material.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../../../core/theme/app_colors.dart';

class ClinicalEvaluationScreen extends StatefulWidget {
  final String exerciseName;

  const ClinicalEvaluationScreen({super.key, required this.exerciseName});

  @override
  State<ClinicalEvaluationScreen> createState() =>
      _ClinicalEvaluationScreenState();
}

class _ClinicalEvaluationScreenState extends State<ClinicalEvaluationScreen> {
  int? _painLevel;
  int? _painTypeIndex;
  int? _timingIndex;
  int? _sleepLevel;
  double _preciseIntensity = 0.0;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }


  bool get _canSubmit =>
      _painLevel != null &&
      _painTypeIndex != null &&
      _timingIndex != null &&
      _sleepLevel != null;

  void _submit() {
    // TODO: enviar evaluación al backend
    // Ejemplo: await clinicalService.submitEvaluation(ClinicalEvaluation(...));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleManager.strings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(s),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(s),
                    const SizedBox(height: 28),
                    _buildSection(
                      label: s.clinicalHowDoYouFeel,
                      sublabel: s.clinicalPainScaleHint,
                      child: _buildPainScale(),
                    ),
                    const SizedBox(height: 24),
                    _buildPreciseIntensitySection(s),
                    const SizedBox(height: 24),
                    _buildSection(
                      label: s.clinicalHowIsThePain,
                      child: _buildPainTypeGrid(s.clinicalPainTypes),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      label: s.clinicalWhenDidItStart,
                      child: _buildFrequencyOptions(s.clinicalFrequencyOptions),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      label: s.clinicalHowAffectsSleep,
                      sublabel: s.clinicalSleepHint,
                      child: _buildNumberScale(_sleepLevel, (v) => setState(() => _sleepLevel = v)),
                    ),
                    const SizedBox(height: 24),
                    _buildNotesField(s),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildActions(s),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppStrings s) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(false),
      ),
      centerTitle: true,
      title: Text(
        s.clinicalEvalTitle,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppStrings s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medical_services_rounded,
                color: Colors.redAccent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.clinicalPainReported,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.exerciseName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  s.clinicalPhysioWillReceive,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section wrapper ───────────────────────────────────────────────────────

  Widget _buildSection({
    required String label,
    String? sublabel,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        if (sublabel != null) ...[
          const SizedBox(height: 3),
          Text(
            sublabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  // ── Pain scale ────────────────────────────────────────────────────────────

  static const List<int> _painLevels = [0, 2, 5, 8, 10];

  static const Map<int, IconData> _painIcons = {
    0:  Icons.sentiment_very_satisfied_rounded,
    2:  Icons.sentiment_satisfied_rounded,
    5:  Icons.sentiment_neutral_rounded,
    8:  Icons.sentiment_dissatisfied_rounded,
    10: Icons.sentiment_very_dissatisfied_rounded,
  };

  static const Map<int, Color> _painColors = {
    0:  Color(0xFF00BFA5),
    2:  Color(0xFF42A5F5),
    5:  Color(0xFF7E57C2),
    8:  Color(0xFFFF7043),
    10: Color(0xFFF44336),
  };

  Widget _buildPainScale() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _painLevels.map((i) {
        final selected = _painLevel == i;
        final color = _painColors[i]!;
        return GestureDetector(
          onTap: () => setState(() => _painLevel = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? color : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected
                  ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 1)]
                  : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _painIcons[i],
                  color: selected ? color : AppColors.textSecondary,
                  size: selected ? 34 : 28,
                ),
                const SizedBox(height: 5),
                Text(
                  '$i',
                  style: TextStyle(
                    color: selected ? color : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }


  // ── Pain type grid ────────────────────────────────────────────────────────

  static const List<IconData> _painTypeIcons = [
    Icons.push_pin_rounded,
    Icons.waves_rounded,
    Icons.compress_rounded,
    Icons.bolt_rounded,
  ];

  Widget _buildPainTypeGrid(List<String> labels) {
    return Column(
      children: [
        Row(children: [
          _PainTypeCard(icon: _painTypeIcons[0], label: labels[0], selected: _painTypeIndex == 0, onTap: () => setState(() => _painTypeIndex = 0)),
          const SizedBox(width: 10),
          _PainTypeCard(icon: _painTypeIcons[1], label: labels[1], selected: _painTypeIndex == 1, onTap: () => setState(() => _painTypeIndex = 1)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _PainTypeCard(icon: _painTypeIcons[2], label: labels[2], selected: _painTypeIndex == 2, onTap: () => setState(() => _painTypeIndex = 2)),
          const SizedBox(width: 10),
          _PainTypeCard(icon: _painTypeIcons[3], label: labels[3], selected: _painTypeIndex == 3, onTap: () => setState(() => _painTypeIndex = 3)),
        ]),
      ],
    );
  }

  // ── Frequency options ─────────────────────────────────────────────────────

  static const List<IconData> _frequencyIcons = [
    Icons.brightness_low_rounded,
    Icons.sync_rounded,
    Icons.all_inclusive_rounded,
  ];

  Widget _buildFrequencyOptions(List<String> labels) {
    final items = <Widget>[];
    for (int i = 0; i < labels.length; i++) {
      if (i > 0) items.add(const SizedBox(width: 10));
      items.add(_PainTypeCard(
        icon: _frequencyIcons[i],
        label: labels[i],
        selected: _timingIndex == i,
        onTap: () => setState(() => _timingIndex = i),
      ));
    }
    return Row(children: items);
  }

  // ── Number scale (shared) ─────────────────────────────────────────────────

  static const List<int> _scaleLevels = [0, 2, 5, 8, 10];

  Widget _buildNumberScale(int? selected, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _scaleLevels.map((i) {
        final isSelected = selected == i;
        final color = _painColors[i]!;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 1)]
                  : [],
            ),
            child: Center(
              child: Text(
                '$i',
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontSize: isSelected ? 22 : 18,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Precise intensity ─────────────────────────────────────────────────────

  Widget _buildPreciseIntensitySection(AppStrings s) {
    final formatted = _preciseIntensity.toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              s.clinicalPreciseIntensity.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                formatted,
                key: ValueKey(formatted),
                style: TextStyle(
                  color: _intensityColor(_preciseIntensity),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _intensityColor(_preciseIntensity),
            inactiveTrackColor: AppColors.border,
            thumbColor: _intensityColor(_preciseIntensity),
            overlayColor: _intensityColor(_preciseIntensity).withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: _preciseIntensity,
            min: 0,
            max: 10,
            divisions: 100,
            onChanged: (v) => setState(() => _preciseIntensity = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              Text('10', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Color _intensityColor(double value) {
    if (value <= 3) return const Color(0xFF00BFA5);
    if (value <= 6) return const Color(0xFFFF7043);
    return const Color(0xFFF44336);
  }

  // ── Notes field ──────────────────────────────────────────────────────────

  Widget _buildNotesField(AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.clinicalAdditionalNotes.toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          minLines: 2,
          maxLines: 5,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: s.clinicalNotesHint,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Widget _buildActions(AppStrings s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      color: AppColors.background,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _canSubmit ? _submit : null,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(
                s.clinicalSendToPhysio,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(false),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: Text(
                s.clinicalCancel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pain type card ────────────────────────────────────────────────────────────

class _PainTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PainTypeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                size: 32,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
