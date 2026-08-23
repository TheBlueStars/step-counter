
import 'package:flutter/material.dart';
import 'package:project/app/widgets/scale_tap_widget.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/colors.gen.dart';
import '../../../generated/text_styles.gen.dart';
import '../../data/models/enums/period_type.dart';

class DatePeriodWidget extends StatelessWidget {
  static const double _buttonSize = 32;
  static const double _navSpacing = 24;

  final PeriodType selectedPeriod;
  final String dateLabel;
  final bool isAtCurrent;
  final ValueChanged<PeriodType> onPeriodChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReturn;

  const DatePeriodWidget({
    super.key,
    required this.selectedPeriod,
    required this.dateLabel,
    required this.isAtCurrent,
    required this.onPeriodChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: ColorName.neutralWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorName.borderBackground),
      ),
      child: Column(
        children: [_buildPeriodTabs(), SizedBox(height: 16), _buildDateNavigator()],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Row(
      children: PeriodType.values.map((period) {
        return Expanded(child: _buildTab(period));
      }).toList(),
    );
  }

  Widget _buildTab(PeriodType period) {
    final isSelected = period == selectedPeriod;

    return ScaleTapWidget(
      onTap: () => onPeriodChanged(period),
      child: Container(
        margin: EdgeInsetsDirectional.symmetric(horizontal: 4),
        padding: EdgeInsetsDirectional.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? ColorName.neutralWhite : ColorName.secondary20,
          borderRadius: BorderRadius.circular(64),
          border: Border.all(
            color: isSelected ? ColorName.primary100 : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: TnmText.body(period.label).semiBold.copyWith(
          color: isSelected ? ColorName.primary100 : ColorName.neutralGray,
        ),
      ),
    );
  }

  Widget _buildDateNavigator() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final navWidth =
            constraints.maxWidth - (_buttonSize + _navSpacing) * 2;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: _navSpacing,
          children: [
            Visibility(
              visible: false,
              maintainState: true,
              maintainSize: true,
              maintainAnimation: true,
              child: _buildReturnButton(enabled: false),
            ),
            SizedBox(
              width: navWidth,
              child: Row(
                spacing: 20,
                children: [
                  _buildChevron(onTap: onPrevious, isPrevious: true),
                  Expanded(
                    child: TnmText.title(dateLabel).semiBold.copyWith(
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      color: ColorName.neutralBlack
                    ),
                  ),
                  _buildChevron(onTap: onNext, isPrevious: false),
                ],
              ),
            ),
            AnimatedScale(
              scale: isAtCurrent ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: _buildReturnButton(enabled: !isAtCurrent),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReturnButton({required bool enabled}) {
    return ScaleTapWidget(
      onTap: enabled ? onReturn : null,
      child: Container(
        width: _buttonSize,
        height: _buttonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorName.neutralWhite,
          shape: .circle,
          border: .all(color: ColorName.secondary100),
        ),
        child: Assets.svg.icLineReturn.svg(
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(ColorName.secondary100, .srcIn),
        ),
      ),
    );
  }

  Widget _buildChevron({
    required VoidCallback onTap,
    required bool isPrevious,
  }) {
    final icon = Assets.svg.arrowRight.svg(
      width: 16,
      height: 16,
      colorFilter: ColorFilter.mode(ColorName.neutralBlack, .srcIn),
    );

    return ScaleTapWidget(
      onTap: onTap,
      child: Container( 
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorName.secondary20,
        ),
        child: isPrevious ? Transform.flip(flipX: true, child: icon) : icon,
      ),
    );
  }
}
