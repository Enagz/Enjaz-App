import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/otp_viewmodel.dart';

class OtpFields extends StatefulWidget {
  const OtpFields({super.key});

  @override
  State<OtpFields> createState() => _OtpFieldsState();
}

class _OtpFieldsState extends State<OtpFields> {
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpProvider = context.read<OtpViewModel>();
    final langCode = Localizations.localeOf(context).languageCode;
    final textDirection = TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            width: 62,
            height: 66,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: const TextSelectionThemeData(
                  cursorColor: Color.fromRGBO(64, 157, 220, 1),
                  selectionColor: Color.fromRGBO(64, 157, 220, 1),
                  selectionHandleColor: Color.fromRGBO(64, 157, 220, 1),
                ),
              ),
              child: TextFormField(
                focusNode: focusNodes[index],
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.number,
                textInputAction:
                index < 3 ? TextInputAction.next : TextInputAction.done,
                maxLength: 1,
                style: const TextStyle(fontSize: 24),
                cursorColor: Color.fromRGBO(64, 157, 220, 1),
                onChanged: (value) {
                  otpProvider.otpValues[index] = value;
                  if (value.isNotEmpty && index < 3) {
                    FocusScope.of(context)
                        .requestFocus(focusNodes[index + 1]);
                  }
                },
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}