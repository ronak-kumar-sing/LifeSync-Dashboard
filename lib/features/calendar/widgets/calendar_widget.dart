import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/calendar_provider.dart';

class CalendarWidget extends StatelessWidget {
  final Function(DateTime)? onDateSelected;
  const CalendarWidget({super.key, this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, _) {
        final days = provider.daysInMonth;
        final weekdayHeaders = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF1A1A2E),
            boxShadow: [
              BoxShadow(
                color: AppColors.purpleAccent.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.primaryText),
                    onPressed: () => provider.previousMonth(),
                  ),
                  Text(
                    provider.monthYearLabel,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.primaryText),
                    onPressed: () => provider.nextMonth(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 3,
                width: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.purpleAccent, Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weekdayHeaders.map((day) => SizedBox(
                  width: 36,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final dayInfo = days[index];
                  final isSelected = provider.isSelected(dayInfo.date);
                  final isCurrentMonth = dayInfo.isCurrentMonth;
                  final isToday = provider.isToday(dayInfo.date);

                  return GestureDetector(
                    onTap: () {
                      provider.selectDate(dayInfo.date);
                      onDateSelected?.call(dayInfo.date);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.purpleAccent
                            : isToday
                                ? AppColors.purpleAccent.withOpacity(0.2)
                                : Colors.transparent,
                        border: isToday && !isSelected
                            ? Border.all(color: AppColors.purpleAccent, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${dayInfo.date.day}',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isCurrentMonth
                                    ? AppColors.primaryText
                                    : AppColors.mutedText,
                            fontSize: 14,
                            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
