import 'package:flutter/material.dart';

class CustomTextFormFieldAppNew extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?) validator;

  const CustomTextFormFieldAppNew({
    required this.label,
    required this.controller,
    required this.validator,
    this.isPassword = false, 
    required bool obscureText,
  });

  @override
  _CustomTextFormFieldAppNewState createState() => _CustomTextFormFieldAppNewState();
}

class _CustomTextFormFieldAppNewState extends State<CustomTextFormFieldAppNew> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false, 
            validator: widget.validator,
            style: const TextStyle(color: Colors.grey),
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 0.5),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 0.5),
              ),
              isDense: true,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null, 
            ),
          ),
        ),
      ],
    );
  }
}

class CustomFieldPassAppNew extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool isPassword;

  const CustomFieldPassAppNew({
    required this.label,
    required this.controller,
    required this.validator,
    this.isPassword = false,
    Key? key,
  }) : super(key: key);

  @override
  _CustomFieldPassAppNewState createState() => _CustomFieldPassAppNewState();
}

class _CustomFieldPassAppNewState extends State<CustomFieldPassAppNew> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        Container(
         // padding: const EdgeInsets.only(bottom: 8),  
          child: Text(
            widget.label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8), 
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: widget.isPassword ? _obscureText : false,
                  validator: widget.validator,
                  style: const TextStyle(color: Colors.grey),
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.5),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom:4), 
                  ),
                ),
              ),
              if (widget.isPassword)
                IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText; 
                    });
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
