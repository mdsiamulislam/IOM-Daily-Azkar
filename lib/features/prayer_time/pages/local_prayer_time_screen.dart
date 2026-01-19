// File: lib/features/prayer_time/pages/local_prayer_time_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../core/local_storage/local_prayer_data.dart';
import '../models/local_prayer_time_model.dart' hide PrayerTime;

class LocalPrayerTimeScreen extends StatefulWidget {
  const LocalPrayerTimeScreen({super.key});

  @override
  State<LocalPrayerTimeScreen> createState() => _LocalPrayerTimeScreenState();
}

class _LocalPrayerTimeScreenState extends State<LocalPrayerTimeScreen> {
  final _data = LocalPrayerData();

  List<MosqueSchedule> mosqueSchedules = [];
  bool isLoading = true;
  int? selectedMosqueIndex;

  final prayerNames = ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'এশা'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final result = await _data.getAllMosqueSchedules();
    mosqueSchedules = result;

    if (mosqueSchedules.isNotEmpty) {
      // make sure selectedMosqueIndex is within bounds
      if (selectedMosqueIndex == null || selectedMosqueIndex! >= mosqueSchedules.length) {
        selectedMosqueIndex = 0;
      }
    } else {
      selectedMosqueIndex = null;
    }

    setState(() => isLoading = false);
  }


  IconData _getPrayerIcon(int index) {
    switch (index) {
      case 0:
        return Icons.wb_twilight_rounded;
      case 1:
        return Icons.wb_sunny_rounded;
      case 2:
        return Icons.wb_sunny_outlined;
      case 3:
        return Icons.brightness_3_rounded;
      case 4:
        return Icons.nights_stay_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  void _openAddEditBottomSheet({MosqueSchedule? existingSchedule, int? index}) {
    final nameCtrl = TextEditingController(text: existingSchedule?.mosqueName ?? '');
    Map<String, TimeOfDay?> temp = {};

    if (existingSchedule != null) {
      for (var prayer in existingSchedule.prayerTimes) {
        final timeParts = prayer.time.split(':');
        if (timeParts.length == 2) {
          try {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1].split(' ')[0]);
            temp[prayer.name] = TimeOfDay(hour: hour, minute: minute);
          } catch (e) {
            // ignore
          }
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (builderContext) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        existingSchedule == null ? 'নতুন সময়সূচি যোগ করুন' : 'সময়সূচি সম্পাদনা',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'মসজিদের নাম',
                          hintText: 'উদাহরণ: বায়তুল মোকাররম মসজিদ',
                          prefixIcon: Icon(Icons.mosque_outlined, color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primaryGreen,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...prayerNames.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final p = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getPrayerIcon(idx),
                                  color: Colors.grey.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  p,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: temp[p] ?? TimeOfDay.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: AppColors.primaryGreen,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (t != null) {
                                    setModal(() => temp[p] = t);
                                  }
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: temp[p] != null
                                        ? AppColors.primaryGreen.withOpacity(0.1)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: temp[p] != null
                                          ? AppColors.primaryGreen.withOpacity(0.3)
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: temp[p] != null
                                            ? AppColors.primaryGreen
                                            : Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        temp[p]?.format(context) ?? 'সময় নির্বাচন',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: temp[p] != null
                                              ? AppColors.primaryGreen
                                              : Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (existingSchedule != null)
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade600,
                                  side: BorderSide(color: Colors.red.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('নিশ্চিত করুন'),
                                      content: const Text('আপনি কি এই সময়সূচি মুছে ফেলতে চান?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('না'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text('হ্যাঁ', style: TextStyle(color: Colors.red.shade600)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && index != null) {
                                    await _data.deleteMosqueSchedule(index);
                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('সময়সূচি মুছে ফেলা হয়েছে'),
                                          backgroundColor: Colors.red.shade600,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                      _load();
                                    }
                                  }
                                },
                                child: const Text('মুছে ফেলুন'),
                              ),
                            ),
                          if (existingSchedule != null) const SizedBox(width: 12),
                          Expanded(
                            flex: existingSchedule == null ? 1 : 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                if (nameCtrl.text.trim().isEmpty || temp.length != 5) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('সকল তথ্য পূরণ করুন'),
                                      backgroundColor: Colors.red.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final list = prayerNames
                                    .map((p) => PrayerTime(
                                  name: p,
                                  time: temp[p]!.format(context),
                                ))
                                    .toList();

                                final schedule = MosqueSchedule(
                                  mosqueName: nameCtrl.text.trim(),
                                  prayerTimes: list,
                                );

                                if (existingSchedule == null) {
                                  await _data.addMosqueSchedule(schedule);
                                } else if (index != null) {
                                  await _data.updateMosqueSchedule(index, schedule);
                                }

                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('সফলভাবে সংরক্ষিত হয়েছে'),
                                      backgroundColor: AppColors.primaryGreen,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                  _load();
                                }
                              },
                              child: const Text(
                                'সংরক্ষণ করুন',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMosqueSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'মসজিদ নির্বাচন করুন',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: mosqueSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = mosqueSchedules[index];
                    final isSelected = selectedMosqueIndex == index;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen.withOpacity(0.15)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.mosque_outlined,
                          color: isSelected ? AppColors.primaryGreen : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        schedule.mosqueName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20)
                          : null,
                      onTap: () {
                        setState(() => selectedMosqueIndex = index);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSchedule = selectedMosqueIndex != null && mosqueSchedules.isNotEmpty
        ? mosqueSchedules[selectedMosqueIndex!]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('স্থানীয় নামাজের সময়'),
        actions: [
          if (selectedSchedule != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _openAddEditBottomSheet(
                existingSchedule: selectedSchedule,
                index: selectedMosqueIndex,
              ),
              tooltip: 'সম্পাদনা',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mosqueSchedules.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mosque_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'কোন সময়সূচি নেই',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'আপনার মসজিদের নামাজের সময় যোগ করুন',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  'সময়সূচি যোগ করুন',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => _openAddEditBottomSheet(),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mosqueSchedules.length > 1)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: _showMosqueSelectionSheet,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: AppColors.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'মসজিদ পরিবর্তন করুন (${mosqueSchedules.length}টি)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.primaryGreen,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (selectedSchedule != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mosque_outlined,
                        size: 28,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selectedSchedule.mosqueName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'নামাজের সময়সূচি',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ...selectedSchedule.prayerTimes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final p = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getPrayerIcon(index),
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            p.time,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () => _openAddEditBottomSheet(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'নতুন যোগ করুন',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}