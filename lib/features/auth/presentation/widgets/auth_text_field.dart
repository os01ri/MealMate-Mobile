
import 'package:flutter/material.dart';

import '../../../../core/ui/theme/colors.dart';
import '../../../../core/ui/theme/text_styles.dart';
import '../../../../core/ui/widgets/main_text_field.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({super.key, required this.hint, required this.label});

  final String hint;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            alignment: Alignment.topLeft,
            child: Text(
              label, style: AppTextStyles.styleWeight500(fontSize: 16)
            ),
          ),
          MainTextField(
            fillColor: AppColors.scaffoldBackgroundColor,
            controller: TextEditingController(),
            hint: hint,
          ),
        ],
      ),
    );
  }
}