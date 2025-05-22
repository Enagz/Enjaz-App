// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:provider/provider.dart';
//
// import '../../address/view/address.dart';
// import '../../address/view/edit_address.dart';
// import '../../address/view_model/add_address_view_model.dart';
//
// class SavedAddress extends StatefulWidget {
//   const SavedAddress({Key? key}) : super(key: key);
//
//   @override
//   _SavedAddressState createState() => _SavedAddressState();
// }
//
// class _SavedAddressState extends State<SavedAddress> {
//   String? currentLocation = 'جاري تحديد الموقع...';
//   String? selectedAddress;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       setState(() {
//         currentLocation = 'خدمة الموقع غير مفعلة';
//       });
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         setState(() {
//           currentLocation = 'تم رفض صلاحية الوصول للموقع';
//         });
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       setState(() {
//         currentLocation = 'تم رفض صلاحية الوصول نهائياً';
//       });
//       return;
//     }
//
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//
//
//     getAddressFromLatLng(position.latitude, position.longitude);
//   }
//
//   Future<void> getAddressFromLatLng(double lat, double lng) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
//
//       if (placemarks.isNotEmpty) {
//         final place = placemarks.first;
//         setState(() {
//           currentLocation =
//           "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
//         });
//       }
//     } catch (e) {
//       print("Error getting location: $e");
//       setState(() {
//         currentLocation = "تعذر تحديد الموقع";
//       });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: const Color(0xffF8F8F8),
//         appBar: AppBar(
//           leading: const Icon(Icons.arrow_back_ios),
//           title: const Text('العناوين المحفوظه',
//               style: TextStyle(color: Colors.black)),
//           backgroundColor: const Color(0xffF8F8F8),
//           elevation: 0,
//           iconTheme: const IconThemeData(color: Colors.black),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                         child: Image.asset('assets/images/img52.png',
//                             height: 100)),
//                     const SizedBox(height: 20),
//                     const Center(
//                       child: Text(
//                         "اختر احد العناوين المحفوظه الخاصه بك",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _buildAddressCard("المنزل"),
//                     _buildAddressCard("العمل"),
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   if (selectedAddress != null) _buildDeliveryButton(),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: _buildAddAddressButton(),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddressCard(String title) {
//     bool isSelected = selectedAddress == title;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedAddress = title;
//         });
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(
//             color: isSelected ? const Color(0xff409EDC) : Colors.transparent,
//             width: 1,
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(title,
//                     style: const TextStyle(
//                         color: Color(0xff409EDC),
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold)),
//                 Row(
//                   children: [
//                     InkWell(
//
//                         onTap: (){
//                           Navigator.push(context, MaterialPageRoute(builder: (context)=>EditAddressScreen()));
//                         },
//                         child: Image.asset("assets/images/img54.png")),
//                     const SizedBox(width: 10),
//                     InkWell(
//                       onTap: () {
//                         Provider.of<AddAddressViewModel>(context, listen: false).deleteAddress(context);
//                       },
//                       child: Image.asset("assets/images/img53.png"),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 4),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "الموقع :",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 12,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       currentLocation ?? '',
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDeliveryButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.white,
//           foregroundColor: const Color(0xff409EDC),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: const BorderSide(color: Color(0xff409EDC), width: 1),
//           ),
//         ),
//         onPressed: () {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('تم اختيار التوصيل إلى $selectedAddress')),
//           );
//         },
//         child: const Text(
//           'التوصيل إلى هذا العنوان',
//           style: TextStyle(fontSize: 16),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddAddressButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xff409EDC),
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         onPressed: () {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) =>  AddAddressScreen()));
//         },
//         child: const Text('اضافه عنوان جديد',
//             style: TextStyle(color: Colors.white, fontSize: 16)),
//       ),
//     );
//   }
// }
//



import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../address/view/address.dart';
import '../../address/view/edit_address.dart';
import '../../address/view_model/add_address_view_model.dart';
import '../../localization/change_lang.dart';

class SavedAddress extends StatefulWidget {
  const SavedAddress({Key? key}) : super(key: key);

  @override
  _SavedAddressState createState() => _SavedAddressState();
}

class _SavedAddressState extends State<SavedAddress> {
  String? selectedAddress;
  List<dynamic> addresses = [];
  String? selectedAddressId;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? addressId;

    try {
      final response = await http.get(
        Uri.parse('https://backend.enjazkw.com/api/address'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          addresses = (data['addresses'] as List)
              .map((item) => AddressModel.fromJson(item))
              .toList();
          if (addresses.isNotEmpty) {
            addressId = addresses.first.id;
          }
        });
        await prefs.setString('addressId', addressId!);
      } else {
        print('Failed to load addresses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final locale = localizationProvider.locale.languageCode;
        final textDirection =
        locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
        return Directionality(
          textDirection: textDirection,
          child: Scaffold(
            backgroundColor: const Color(0xffF8F8F8),
            appBar: AppBar(
              leading: IconButton(onPressed: (){
                  Navigator.pop(context);
              }, icon: const Icon(Icons.arrow_back_ios)),
              title: Text(
                Translations.getText('saved_address', locale),
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: const Color(0xffF8F8F8),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                              child: Image.asset('assets/images/img52.png',
                                  height: 100)),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              Translations.getText('choose', locale),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...addresses.map((address) => _buildAddressCard(address, locale)).toList(),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (selectedAddress != null) _buildDeliveryButton(locale),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildAddAddressButton(locale),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressCard(AddressModel address, String locale) {
    //bool isSelected = selectedAddress == title;
    bool isSelected = selectedAddressId == address.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          //selectedAddress = title;
          selectedAddress = address.name;
          selectedAddressId = address.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xff409EDC) : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(address.name,
                    style: const TextStyle(
                        color: Color(0xff409EDC),
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditAddressScreen()));
                        },
                        child: Image.asset("assets/images/img54.png")),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Provider.of<AddAddressViewModel>(context, listen: false)
                            .deleteAddress(context);
                      },
                      child: Image.asset("assets/images/img53.png"),
                    ),
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Translations.getText('location', locale)} :',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address.address,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryButton(String locale) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xff409EDC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xff409EDC), width: 1),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${Translations.getText('delivery_to', locale)} $selectedAddress',
              ),
            ),
          );
        },
        child: Text(
          Translations.getText('dilvery', locale),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildAddAddressButton(String locale) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff409EDC),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddAddressScreen()));
        },
        child: Text(
          Translations.getText('add_to_address', locale),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

class AddressModel {
  final String id;
  final String name;
  final String address;
  final String location;

  AddressModel({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      location: json['location'] ?? '',
    );
  }
}
