import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../generated/colors.gen.dart';
import '../../../generated/text_styles.gen.dart';
import '../scale_tap_widget.dart';

class BottomSheetDefault extends StatelessWidget {
  final String title;
  final Widget body;
  final String? primaryText;
  final VoidCallback? onPrimary;
  final String? secondaryText;
  final VoidCallback? onSecondary;
  final bool showClose;
  final ValueListenable<bool>? primaryEnabled;

  const BottomSheetDefault({
    super.key,
    required this.title,
    required this.body,
    this.primaryText,
    this.onPrimary,
    this.secondaryText,
    this.onSecondary,
    this.showClose = true,
    this.primaryEnabled,
  });

  static Future<T?> show<T>({
    required String title,
    required Widget body,
    String? primaryText,
    VoidCallback? onPrimary,
    String? secondaryText,
    VoidCallback? onSecondary,
    bool showClose = true,
    bool isDismissible = true,
    ValueListenable<bool>? primaryEnabled,
  }) {
    return Get.bottomSheet<T>(
      BottomSheetDefault(
        title: title,
        body: body,
        primaryText: primaryText,
        onPrimary: onPrimary,
        secondaryText: secondaryText,
        onSecondary: onSecondary,
        showClose: showClose,
        primaryEnabled: primaryEnabled,
      ),
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
    );
  }

  static void disposeLater(VoidCallback dispose) =>
      Future.delayed(const Duration(milliseconds: 400), dispose);

  static Future<int?> showNumberInput({
    required String title,
    required String fieldTitle,
    required int initialValue,
    String? suffixText,
    String saveText = "Save",
    int minValue = 0,
    int maxValue = 999999,
  }) async {
    final input = TextEditingController(text: initialValue.toString());
    final canSave = ValueNotifier<bool>(true);

    int? parse() {
      final value = int.tryParse(input.text.trim());
      if (value == null || value < minValue || value > maxValue) {
        return null;
      }

      return value;
    }

    void onChanged() => canSave.value = parse() != null;
    input.addListener(onChanged);

    final result = await show<int>(
      title: title,
      body: _NumberInputBody(
        fieldTitle: fieldTitle,
        controller: input,
        suffixText: suffixText,
      ),
      primaryText: saveText,
      primaryEnabled: canSave,
      onPrimary: () => Get.back(result: parse()),
    );

    input.removeListener(onChanged);
    disposeLater(() {
      input.dispose();
      canSave.dispose();
    });
    return result;
  }

  static Future<bool?> showConfirm({
    required String title,
    required String message,
    String primaryText = "OK",
    String secondaryText = "Cancel",
  }) {
    return show<bool>(
      title: title,
      body: TnmText.body(message).copyWith(color: ColorName.neutralGray),
      primaryText: primaryText,
      onPrimary: () => Get.back(result: true),
      secondaryText: secondaryText,
      onSecondary: () => Get.back(result: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: _buildSheet(),
    );
  }

  Widget _buildSheet() {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
        top: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: ColorName.neutralWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          SizedBox(height: 16),
          Flexible(child: SingleChildScrollView(child: body)),
          if (primaryText != null) ...[
            SizedBox(height: 16),
            _buildPrimaryButton(),
          ],
          if (secondaryText != null) ...[
            SizedBox(height: 8),
            _buildButton(
              text: secondaryText!,
              onTap: onSecondary ?? Get.back,
              backgroundColor: ColorName.neutralWhite,
              textColor: ColorName.neutralBlack,
              borderColor: ColorName.inputBorder,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        TnmText.title(title).semiBold.copyWith(color: ColorName.neutralBlack),
        if (showClose)
          PositionedDirectional(
            end: 0,
            child: ScaleTapWidget(
              onTap: Get.back,
              child: Icon(Icons.close, size: 24, color: ColorName.neutralBlack),
            ),
          ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    if (primaryEnabled == null) {
      return _primaryButton(enabled: true);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: primaryEnabled!,
      builder: (_, enabled, _) => _primaryButton(enabled: enabled),
    );
  }

  Widget _primaryButton({required bool enabled}) {
    return _buildButton(
      text: primaryText!,
      onTap: enabled ? (onPrimary ?? Get.back) : null,
      backgroundColor: enabled
          ? ColorName.buttonBackground
          : ColorName.buttonBackground.withValues(alpha: .5),
      textColor: ColorName.onColorText,
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onTap,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return ScaleTapWidget(
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: borderColor == null ? null : Border.all(color: borderColor),
        ),
        child: TnmText.body(text).semiBold.copyWith(color: textColor),
      ),
    );
  }
}

class _NumberInputBody extends StatelessWidget {
  final String fieldTitle;
  final TextEditingController controller;
  final String? suffixText;

  const _NumberInputBody({
    required this.fieldTitle,
    required this.controller,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TnmText.description(fieldTitle).copyWith(color: ColorName.neutralGray),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            suffixText: suffixText,
            contentPadding: EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: ColorName.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: ColorName.primary100),
            ),
          ),
        ),
      ],
    );
  }
}
