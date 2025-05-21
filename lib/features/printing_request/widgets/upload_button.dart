import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../localization/change_lang.dart';

class UploadButton extends StatelessWidget {
  final VoidCallback onPressed;

  const UploadButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 343,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(Translations.getText('please_add_files', context.read<LocalizationProvider>().locale.languageCode)
                , style: TextStyle(fontSize: 14, color: Color(0xffB3B3B3))),
            SizedBox(
              width:38
            ),
            IconButton(
              onPressed: onPressed,
              icon: Image.asset("assets/images/img18.png"),
            ),
          ],
        ),
      ),
    );
  }
}
