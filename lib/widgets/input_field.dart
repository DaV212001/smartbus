import 'package:flutter/material.dart';

class InputFieldWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final FocusNode? focusNode;
  final String? Function(String? val) validator;
  final String? Function(String? val)? onChanged;
  bool obscureText;
  final Widget? prefixIcon;
  final String? label;
  final bool passwordinput;
  final String? hint;
  final int? maxlength;

  InputFieldWidget(
      {super.key,
      required this.textEditingController,
      required this.focusNode,
      required this.obscureText,
      required this.validator,
      required this.passwordinput,
      this.label,
      this.prefixIcon,
      this.onChanged,
      this.hint,
      this.maxlength});

  @override
  State<InputFieldWidget> createState() => _InputFieldWidgetState();
}

class _InputFieldWidgetState extends State<InputFieldWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.passwordinput) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
        child: SizedBox(
          width: double.infinity,
          child: TextFormField(
              controller: widget.textEditingController,
              style: const TextStyle(color: Colors.black),
              focusNode: widget.focusNode,
              autofocus: false,
              maxLength: widget.maxlength,
              onChanged: widget.onChanged,
              autofillHints: const [AutofillHints.password],
              obscureText: !widget.obscureText,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                hintStyle: const TextStyle(color: Colors.black),
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF4B39EF),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF1F4F8),
                suffixIcon: InkWell(
                  onTap: () => setState(
                    () => widget.obscureText = !widget.obscureText,
                  ),
                  focusNode: FocusNode(skipTraversal: true),
                  child: Icon(
                    widget.obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
                errorMaxLines: 2,
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: widget.validator),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
        child: SizedBox(
          width: double.infinity,
          child: TextFormField(
            controller: widget.textEditingController,
            focusNode: widget.focusNode,
            style: const TextStyle(color: Colors.black),
            autofocus: false,
            maxLength: widget.maxlength,
            onChanged: widget.onChanged,
            autofillHints: const [AutofillHints.password],
            obscureText: widget.obscureText,
            decoration: InputDecoration(
              icon: widget.prefixIcon,
              labelText: widget.label,
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Colors.black),
              labelStyle: const TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF4B39EF),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF1F4F8),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validator,
          ),
        ),
      );
    }
  }
}
