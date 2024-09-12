import 'package:app17000ft_new/constants/color_const.dart';
import 'package:flutter/material.dart';

class CustomDropdownFormField extends StatefulWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?>? onChanged;
  final String labelText;
  final FocusNode? focusNode;

  const CustomDropdownFormField({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
    required this.labelText,
    this.focusNode,
  });

  @override
  _CustomDropdownFormFieldState createState() =>
      _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState extends State<CustomDropdownFormField> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      focusNode: widget.focusNode,
      value: widget.selectedOption,
      onChanged: widget.onChanged,
      items: widget.options.isNotEmpty
          ? widget.options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: SizedBox(
            width: 260, // Set a fixed width to prevent overflow
            child: Text(
              value,
              maxLines: 1, // Allow only one line of text
              overflow: TextOverflow.ellipsis, // Use ellipsis for overflow
            ),
          ),
        );
      }).toList()
          : [ // If no options, provide a placeholder item
        DropdownMenuItem<String>(
          value: null,
          child: Text('No options available'),
        ),
      ],
      decoration: InputDecoration(
        iconColor: AppColors.primary,
        labelText: widget.labelText, // Use labelText from widget
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            width: 1,
            color: AppColors.onBackground,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            width: 2,
            color: AppColors.primary,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            width: 1,
            color: AppColors.outline,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            width: 2,
            color: AppColors.error,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          // Safeguard against null focusNode
          if (widget.focusNode != null && widget.focusNode!.context != null) {
            Scrollable.ensureVisible(
              widget.focusNode!.context!,
              alignment: 0.5, // Adjust alignment as needed
              duration: const Duration(milliseconds: 500), // Scroll animation duration
            );
          }
          return 'Select an option';
        }
        return null;
      },
    );
  }
}
