import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:flutter_map/flutter_map.dart';

import '../../localization/change_lang.dart';
import '../view_model/add_address_view_model.dart';

class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AddAddressViewModel(),
        child: Consumer<LocalizationProvider>(
            builder: (context, localizationProvider, child) {
          final locale = localizationProvider.locale.languageCode;
          final textDirection =
              locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
          return Directionality(
            textDirection: textDirection,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios)),
                title: Text(
                  Translations.getText(
                    'addadd',
                    context.read<LocalizationProvider>().locale.languageCode,
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: Consumer<AddAddressViewModel>(
                builder: (context, model, child) {
                  return SafeArea(
                    child : Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: model.selectedPosition,
                            initialZoom: 14,
                            onTap: (tapPosition, point) {
                              model.selectedPosition = point;
                              model.getAddressFromLatLng(point);
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: model.selectedPosition,
                                  width: 50,
                                  height: 50,
                                  child: Image.asset("assets/images/img57.png"),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 10),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Translations.getText(
                                    'locname',
                                    context
                                        .read<LocalizationProvider>()
                                        .locale
                                        .languageCode,
                                  ),
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: model.locationController,
                                  readOnly: false,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Image.asset(
                                        "assets/images/img58.png",
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Translations.getText(
                                              'locname',
                                              context
                                                  .read<LocalizationProvider>()
                                                  .locale
                                                  .languageCode,
                                            ),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              model.locationController.text,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                              softWrap: true,
                                              maxLines: null,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff409EDC),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                    onPressed: model.isLoading ||
                                        model.locationController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : () {
                                      model.addAddress(context);
                                    },
                                    child: model.isLoading
                                        ? const CircularProgressIndicator(
                                        color: Colors.white)
                                        : Text(
                                      Translations.getText(
                                        'addadd',
                                        context
                                            .read<LocalizationProvider>()
                                            .locale
                                            .languageCode,
                                      ),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  );
                },
              ),
            ),
          );
        }));
  }
}
