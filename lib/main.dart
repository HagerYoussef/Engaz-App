import 'dart:async';
import 'package:enjaz/features/splash/presentation/view/splash_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Geolocator.requestPermission();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AddAddressScreen(),
      ),
    ),
  );
}

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final LatLng _initialPosition = const LatLng(24.7136, 46.6753);
  LatLng _selectedPosition = const LatLng(24.7136, 46.6753);
  TextEditingController _locationController =
      TextEditingController(text: "الرياض");

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String address = place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            place.street ??
            "موقع غير معروف";

        setState(() {
          _locationController.text = address;
        });

        debugPrint("الموقع: $address");
      } else {
        debugPrint("لم يتم العثور على عنوان");
      }
    } catch (e) {
      debugPrint("Error fetching address: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.arrow_back_ios),
          title: const Text(
            "إضافة عنوان",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _initialPosition,
                initialZoom: 14,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedPosition = point;
                  });
                  _getAddressFromLatLng(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPosition,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
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
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "اسم الموقع",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _locationController,
                        readOnly: true,
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
                      Text(
                        "الموقع: ${_selectedPosition.latitude}, ${_selectedPosition.longitude}",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "إضافة",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final PageController _pageController = PageController();

  final List<String> images = [
    'assets/images/img7.png',
    'assets/images/img7.png',
    'assets/images/img7.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xffFDFDFD),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xffFDFDFD),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/img13.png'),
                label: 'الرئيسية'),
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/img14.png'), label: 'طلباتي'),
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/img15.png'), label: 'المزيد'),
          ],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          currentIndex: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الرئيسية',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'IBM_Plex_Sans_Arabic'),
                      ),
                      Row(
                        children: [
                          Image.asset("assets/images/img8.png"),
                          SizedBox(width: 10),
                          Image.asset("assets/images/img9.png"),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'مرحباً محمد!',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'IBM_Plex_Sans_Arabic',
                        color: Color(0xff409EDC)),
                  ),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: .5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: AssetImage(images[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: images.length,
                            effect: ExpandingDotsEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: Color(0xff409EDC),
                              dotColor: Colors.grey,
                              expansionFactor: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'التصنيفات',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff1D1D1D),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'IBM_Plex_Sans_Arabic',
                    ),
                  ),
                  SizedBox(height: 10),
                  CategoryCard(
                    title: 'الترجمة',
                    description:
                        'نقدم أفضل خدمات الترجمة لأكثر من 10 لغات حول العالم',
                    image: 'assets/images/img5.png',
                  ),
                  SizedBox(height: 10),
                  CategoryCard(
                    title: 'الطباعة',
                    description: 'نقدم أفضل جودة للطباعة بأسعار تنافسية',
                    image: 'assets/images/img6.png',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const CategoryCard({
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff409EDC),
                        fontFamily: 'IBM_Plex_Sans_Arabic'),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                        fontFamily: 'IBM_Plex_Sans_Arabic',
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 152,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TranslationRequestPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Color(0xff409EDC), width: 1),
                        ),
                      ),
                      child: const Text(
                        'طلب الخدمة',
                        style: TextStyle(
                            color: Color(0xff0409EDC),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 15),
            Image.asset(image, width: 123, height: 123),
          ],
        ),
      ),
    );
  }
}

class TranslationRequestPage extends StatefulWidget {
  TranslationRequestPage({super.key});

  @override
  _TranslationRequestPageState createState() => _TranslationRequestPageState();
}

class _TranslationRequestPageState extends State<TranslationRequestPage> {
  final List<String> fileTypes = [
    'assets/word.png',
    'assets/excel.png',
    'assets/pdf.png'
  ];
  List<PlatformFile> selectedFiles = [];
  final List<String> availableLanguages = [
    'إنجليزي(5 دينار /100 كلمة)',
    'فرنسي(5 دينار /100 كلمة) ',
    'اسباني(5 دينار /100 كلمة)',
    'الماني(5 دينار /100 كلمة)',
    'ايطالي(5 دينار /100 كلمة)',
    'صيني(5 دينار /100 كلمة)'
  ];
  List<String> selectedLanguages = [];

  void _addLanguage(String language) {
    if (!selectedLanguages.contains(language)) {
      setState(() {
        selectedLanguages.add(language);
      });
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        setState(() {
          selectedFiles.add(file);
        });

        print("تم اختيار الملف: ${file.name}");
      } else {
        print("لم يتم اختيار أي ملف.");
      }
    } catch (e) {
      print("حدث خطأ أثناء اختيار الملف: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Icon(Icons.arrow_back_ios),
          title: const Text('طلب ترجمة', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset('assets/images/img5.png', height: 100),
                ),
                const SizedBox(height: 16),
                Center(
                  child: const Text(
                    'طلب ترجمة جديد',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: const Text(
                    'الرجاء اختيار اللغة المراد ترجمتها',
                    style: TextStyle(fontSize: 14, color: Color(0xffB3B3B3)),
                  ),
                ),
                const SizedBox(height: 8),
                _buildDropdown('اللغة المراد ترجمتها'),
                _buildMultiSelectDropdown('اللغات المراد الترجمة إليها'),
                _buildRadioSelection(),
                const Text(
                  'الملاحظات',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _buildTextField('ادخل الملاحظات الخاصة بك ان وجدت'),
                const SizedBox(height: 16),
                const Text(
                  'المرفقات المراد ترجمتها',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                UploadButton(
                  onPressed: () {
                    pickFile();
                  },
                ),
                const SizedBox(height: 8),
                _buildSelectedFilesList(),
                const SizedBox(height: 16),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? selectedLanguage;

  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 343,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text(selectedLanguage ?? 'اختر'),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: availableLanguages
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    selectedLanguage = value;
                    selectedLanguages.remove(value);
                    selectedLanguages.insert(0, value);
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 343,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text(selectedLanguages.isEmpty ? 'اختر' : ''),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: availableLanguages
                  .where((lang) => !selectedLanguages.contains(lang))
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedLanguages.add(value);
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: selectedLanguages.map((language) {
            return Container(
              width: 155,
              height: 36,
              padding: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language, style: const TextStyle(fontSize: 9)),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLanguages.remove(language);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 1.5),
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRadioSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [DeliveryOptions()],
    );
  }

  Widget _buildTextField(String label) {
    return Container(
      width: 343,
      height: 109,
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 5,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.0,
                letterSpacing: 0,
                color: Color(0xFFB3B3B3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadButton() {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: pickFile,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text(
          'إضافة مرفقات',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'assets/images/img10.png';
      case 'doc':
      case 'docx':
        return 'assets/images/img12.png';
      case 'xls':
      case 'xlsx':
        return 'assets/images/img11.png';
      default:
        return 'assets/file.png';
    }
  }

  Widget _buildSelectedFilesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: selectedFiles.map((file) {
          String extension = file.extension ?? "";
          String iconPath = getFileIcon(extension);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  OpenFile.open(file.path);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(iconPath, width: 60, height: 60),
                ),
              ),
              Positioned(
                top: -5,
                left: -5,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFiles.remove(file);
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 1.5),
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.red),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void openSelectedFile(String filePath) {
    OpenFile.open(filePath);
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {},
        child: const Text('إرسال الطلب',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}

class UploadButton extends StatelessWidget {
  final VoidCallback onPressed;

  const UploadButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 343,
      height: 48,
      decoration: BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "الرجاء إضافة المرفقات المراد ترجمتها",
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          IconButton(
            onPressed: onPressed,
            icon: Icon(Icons.upload_file, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class DeliveryOptions extends StatefulWidget {
  @override
  _DeliveryOptionsState createState() => _DeliveryOptionsState();
}

class _DeliveryOptionsState extends State<DeliveryOptions> {
  String? deliveryMethod;
  String? selectedOption;
  Position? _currentPosition;
  String? selectedAddress;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خدمة الموقع غير مفعلة، يرجى تشغيلها!")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم رفض إذن الوصول للموقع!")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("إذن الموقع مرفوض نهائيًا، قم بتفعيله من الإعدادات!")),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      String address =
          "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}";

      setState(() {
        _currentPosition = position;
        selectedAddress = address;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تعذر تحديد الموقع، حاول مرة أخرى.")),
      );
    }
  }

  void _submitOrder() {
    if (deliveryMethod == "توصيل" && selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار عنوان التوصيل!")),
      );
      return;
    }

    String address = selectedAddress ?? "لم يتم تحديد الموقع بعد";
    print("تم اختيار: $deliveryMethod، الموقع: $address");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio(
              value: 'استلام من الفرع',
              groupValue: deliveryMethod,
              activeColor: Colors.blue,
              onChanged: (value) {
                setState(() {
                  deliveryMethod = value;
                  selectedOption = null;
                  _currentPosition = null;
                  selectedAddress = null;
                });
              },
            ),
            const Text('استلام من الشركة'),
            Radio(
              value: 'توصيل',
              groupValue: deliveryMethod,
              activeColor: Colors.blue,
              onChanged: (value) {
                setState(() {
                  deliveryMethod = value;
                  selectedOption = null;
                  _currentPosition = null;
                  selectedAddress = null;
                });
              },
            ),
            const Text('توصيل'),
          ],
        ),
        if (deliveryMethod == "توصيل") ...[
          RadioListTile<String>(
              activeColor: Colors.blue,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المنزل'),
                  if (selectedOption == 'المنزل' && selectedAddress != null)
                    Text(
                      '📍 $selectedAddress',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              value: 'المنزل',
              groupValue: selectedOption,
              onChanged: (value) async {
                setState(() {
                  selectedOption = value;
                });

                await _getCurrentLocation();

                setState(() {});
              }),
          RadioListTile<String>(
            activeColor: Colors.blue,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('العمل'),
                if (selectedOption == 'العمل' && selectedAddress != null)
                  Text(
                    '📍 $selectedAddress',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            value: 'العمل',
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() {
                selectedOption = value;
                _currentPosition = null;
                selectedAddress = null;
              });
              _getCurrentLocation();
            },
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

class LoginViewModel extends ChangeNotifier {
  bool isPhoneSelected = true;
  String userInput = '';
  String firstName = '';
  String lastName = '';
  String phone = '';
  String email = '';

  void toggleLoginMethod() {
    isPhoneSelected = !isPhoneSelected;
    userInput = '';
    notifyListeners();
  }

  void setUserInput(String value) {
    userInput = value;
    notifyListeners();
  }

  void setFirstName(String value) {
    firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    lastName = value;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double padding = screenWidth > 600 ? 48 : 24;
            double imageWidth = screenWidth > 600 ? 250 : 204;
            double buttonHeight = screenWidth > 600 ? 60 : 50;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: screenWidth > 600 ? 150 : 130),
                        Image.asset('assets/images/img1.png',
                            width: imageWidth, height: imageWidth * 0.37),
                        const SizedBox(height: 16),
                        const Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        const Text(
                          "الرجاء اختيار وسيلة تسجيل الدخول المناسبة لك",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xffB3B3B3),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Consumer<LoginViewModel>(
                              builder: (context, viewModel, child) {
                                return _buildToggleButton(
                                  context,
                                  title: "البريد الإلكتروني",
                                  isSelected: !viewModel.isPhoneSelected,
                                  onTap: () => viewModel.toggleLoginMethod(),
                                );
                              },
                            ),
                            Consumer<LoginViewModel>(
                              builder: (context, viewModel, child) {
                                return _buildToggleButton(
                                  context,
                                  title: "رقم الجوال",
                                  isSelected: viewModel.isPhoneSelected,
                                  onTap: () => viewModel.toggleLoginMethod(),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const LoginTextField(),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              final viewModel = Provider.of<LoginViewModel>(
                                  context,
                                  listen: false);
                              if (viewModel.userInput.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "يرجى إدخال البيانات المطلوبة",
                                      style: TextStyle(
                                          fontFamily: 'IBM_Plex_Sans_Arabic'),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtpScreen(
                                    contactInfo: viewModel.userInput,
                                    contactType: '',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "تسجيل الدخول",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                  color: Color(0xff409EDC), width: 1),
                            ),
                            child: const Text(
                              "الاستمرار كزائر",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                                color: Color(0xff409EDC),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text.rich(TextSpan(
                          text: "لا املك حساب؟ ",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'IBM_Plex_Sans_Arabic',
                          ),
                          children: [
                            TextSpan(
                              text: "تسجيل جديد",
                              style: const TextStyle(
                                color: Color(0xff409EDC),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterScreen()),
                                  );
                                },
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: padding,
                  child: Image.asset('assets/images/img2.png',
                      width: screenWidth > 600 ? 120 : 98,
                      height: screenWidth > 600 ? 40 : 33),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context,
      {required String title,
      required bool isSelected,
      required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xff409EDC) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'IBM_Plex_Sans_Arabic',
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double padding = screenWidth > 600 ? 48 : 24;
            double imageWidth = screenWidth > 600 ? 250 : 204;
            double buttonHeight = screenWidth > 600 ? 60 : 50;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: screenWidth > 600 ? 150 : 130),
                        Image.asset('assets/images/img1.png',
                            width: imageWidth, height: imageWidth * 0.37),
                        const SizedBox(height: 16),
                        const Text(
                          "انشاء حساب جديد",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        const Text(
                          "الرجاء ملئ البيانات التالية لانشاء حسابك",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xffB3B3B3),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            "الاسم الاول",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic'),
                          ),
                        ),
                        CustomTextField(
                            hintText: 'ادخل الاسم الاول',
                            onChanged: (value) => Provider.of<LoginViewModel>(
                                    context,
                                    listen: false)
                                .setFirstName(value)),
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            "اسم العائله",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'ادخل اسم العائلة',
                          onChanged: (value) => Provider.of<LoginViewModel>(
                                  context,
                                  listen: false)
                              .setLastName(value),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            "رقم الجوال",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'ادخل رقم الجوال',
                          onChanged: (value) => Provider.of<LoginViewModel>(
                                  context,
                                  listen: false)
                              .setPhone(value),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            "البريد الالكتروني",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: 'ادخل البريد الإلكتروني',
                          onChanged: (value) => Provider.of<LoginViewModel>(
                                  context,
                                  listen: false)
                              .setEmail(value),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              final viewModel = Provider.of<LoginViewModel>(
                                  context,
                                  listen: false);
                              if (viewModel.firstName.isEmpty ||
                                  viewModel.lastName.isEmpty ||
                                  viewModel.phone.isEmpty ||
                                  viewModel.email.isEmpty) {
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtpScreen2(
                                    phone: viewModel.phone,
                                    email: viewModel.email,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "تسجيل",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text.rich(TextSpan(
                          text: "لديك حساب بالفعل؟",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'IBM_Plex_Sans_Arabic',
                          ),
                          children: [
                            TextSpan(
                              text: "تسجيل الدخول",
                              style: const TextStyle(
                                color: Color(0xff409EDC),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()));
                                },
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: padding,
                  child: SizedBox(
                    width: screenWidth * .9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/img2.png',
                          width: screenWidth > 600 ? 120 : 98,
                          height: screenWidth > 600 ? 40 : 33,
                        ),
                        Row(
                          children: [
                            Text(
                              "حساب جديد",
                              style: TextStyle(
                                color: Color(0xff1D1D1D),
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(Icons.arrow_forward_ios)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context,
      {required String title,
      required bool isSelected,
      required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xff409EDC) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'IBM_Plex_Sans_Arabic',
            ),
          ),
        ),
      ),
    );
  }
}

class LoginTextField extends StatefulWidget {
  const LoginTextField({super.key});

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    _controller.addListener(() => viewModel.setUserInput(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
          Future.delayed(Duration.zero, () => _focusNode.requestFocus());
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: viewModel.isPhoneSelected
                  ? "ادخل رقم الجوال"
                  : "ادخل البريد الإلكتروني",
              hintStyle: const TextStyle(
                color: Color(0xffB3B3B3),
                fontWeight: FontWeight.w500,
                fontSize: 13,
                fontFamily: 'IBM_Plex_Sans_Arabic',
              ),
              filled: true,
              fillColor: const Color(0xffFAFAFA),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            keyboardType: viewModel.isPhoneSelected
                ? TextInputType.phone
                : TextInputType.emailAddress,
          ),
        );
      },
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String contactInfo;
  final String contactType;

  const OtpScreen({required this.contactInfo, required this.contactType});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  int minutes = 0;
  int seconds = 0;
  Timer? _timer;
  final int maxMinutes = 2;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (minutes == maxMinutes && seconds == 59) {
            _timer?.cancel();
          } else if (seconds == 59) {
            minutes++;
            seconds = 0;
          } else {
            seconds++;
          }
        });
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      minutes = 0;
      seconds = 0;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double padding = screenWidth > 600 ? 48 : 24;
            double imageWidth = screenWidth > 600 ? 250 : 204;
            double buttonHeight = screenWidth > 600 ? 60 : 50;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: screenWidth > 600 ? 150 : 130),
                        Image.asset('assets/images/img1.png',
                            width: imageWidth, height: imageWidth * 0.37),
                        const SizedBox(height: 16),
                        const Text(
                          "رمز التفعيل",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        const Text(
                          ":الرجاء ادخال رمز التفعيل المرسل عبر رقم الجوال التالي",
                          style: TextStyle(
                              fontSize: 11,
                              color: Color(0xffB3B3B3),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.contactInfo,
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff409EDC),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        const SizedBox(height: 16),
                        OtpFields(),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "تأكيد",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection: TextDirection.rtl,
                          children: [
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "لم يصلك رمز التفعيل؟ ",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xff000000),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'IBM_Plex_Sans_Arabic',
                                      ),
                                    ),
                                    TextSpan(
                                      text: "أعد الإرسال",
                                      style: TextStyle(
                                        color: Color(0xff409EDC),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        fontFamily: 'IBM_Plex_Sans_Arabic',
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _resetTimer();
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff409EDC),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: padding,
                  child: SizedBox(
                    width: screenWidth * .9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/img2.png',
                          width: screenWidth > 600 ? 120 : 98,
                          height: screenWidth > 600 ? 40 : 33,
                        ),
                        Row(
                          children: [
                            Text(
                              "رمز التفعيل ",
                              style: TextStyle(
                                color: Color(0xff1D1D1D),
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(Icons.arrow_forward_ios)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class OtpFields extends StatelessWidget {
  const OtpFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: TextFormField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(fontSize: 24),
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
            ),
          ),
        );
      }),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String hintText;
  final Function(String)? onChanged;

  const CustomTextField({Key? key, required this.hintText, this.onChanged})
      : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return TextField(
            controller: _controller,
            onChanged: (value) {
              viewModel.setUserInput(value);
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: Color(0xffB3B3B3),
                fontWeight: FontWeight.w500,
                fontFamily: 'IBM_Plex_Sans_Arabic',
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xffFAFAFA),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          );
        },
      ),
    );
  }
}

class OtpScreen2 extends StatefulWidget {
  final String phone;
  final String email;

  const OtpScreen2({required this.phone, required this.email});

  @override
  State<OtpScreen2> createState() => _OtpScreen2State();
}

class _OtpScreen2State extends State<OtpScreen2> {
  int minutes = 0;
  int seconds = 0;
  Timer? _timer;
  final int maxMinutes = 2;
  int? selectedImageIndex;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (minutes == maxMinutes && seconds == 59) {
            _timer?.cancel();
          } else if (seconds == 59) {
            minutes++;
            seconds = 0;
          } else {
            seconds++;
          }
        });
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      minutes = 0;
      seconds = 0;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double padding = screenWidth > 600 ? 48 : 24;
            double imageWidth = screenWidth > 600 ? 250 : 204;
            double buttonHeight = screenWidth > 600 ? 60 : 50;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: screenWidth > 600 ? 150 : 130),
                        Image.asset('assets/images/img1.png',
                            width: imageWidth, height: imageWidth * 0.37),
                        const SizedBox(height: 16),
                        const Text(
                          "رمز التفعيل",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        const Text(
                          "اختر وسيلة استلام رمز التفعيل الخاص بك لتفعيل حسابك",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xffB3B3B3),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImageIndex = 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 60, left: 60),
                            decoration: BoxDecoration(
                              border: selectedImageIndex == 1
                                  ? Border.all(
                                      color: Color(0xff409EDC), width: 1)
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/images/img3.png',
                              width: imageWidth,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImageIndex = 2;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 60, left: 60),
                            decoration: BoxDecoration(
                              border: selectedImageIndex == 2
                                  ? Border.all(
                                      color: Color(0xff409EDC), width: 1)
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/images/img4.png',
                              width: imageWidth,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedImageIndex == null) {
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtpScreen(
                                    contactInfo: selectedImageIndex == 1
                                        ? widget.phone
                                        : widget.email,
                                    contactType: selectedImageIndex == 1
                                        ? 'phone'
                                        : 'email',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "تأكيد",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: padding,
                  child: SizedBox(
                    width: screenWidth * .9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/img2.png',
                          width: screenWidth > 600 ? 120 : 98,
                          height: screenWidth > 600 ? 40 : 33,
                        ),
                        Row(
                          children: [
                            Text(
                              "رمز التفعيل ",
                              style: TextStyle(
                                color: Color(0xff1D1D1D),
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.arrow_forward_ios),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
