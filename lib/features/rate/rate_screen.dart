import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../localization/change_lang.dart';

void showRatingDialog(BuildContext context, String orderId) {
  double selectedRating = 0;
  final TextEditingController commentController = TextEditingController();
  final locale = Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode;
  final textDirection = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Directionality(
          textDirection: textDirection,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(20),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Translations.getText('rate_service', locale),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      Translations.getText('your_comment', locale),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: Translations.getText('leave_comment_hint', locale),
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xffFAFAFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xff409EDC),
                            side: const BorderSide(color: Color(0xff409EDC)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(Translations.getText('rate_later', locale)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedRating < 1 || selectedRating > 5) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    Translations.getText('stars_required', locale),
                                  ),
                                ),
                              );
                              return;
                            }

                            final response = await http.post(
                              Uri.parse('https://backend.enjazkw.com/api/order/$orderId/rate'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'stars': selectedRating.toInt(),
                                'comment': commentController.text,
                              }),
                            );

                            final data = jsonDecode(response.body);

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(data['message'] ?? Translations.getText('rating_success', locale)),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(data['message'] ?? Translations.getText('rating_failed', locale)),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff409EDC),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(Translations.getText('submit_rating', locale)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}