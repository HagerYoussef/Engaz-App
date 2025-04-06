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
        home: SettingsScreen(),
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
          leading: const Icon(Icons.arrow_back_ios),
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
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  final List<String> images = [
    'assets/images/img7.png',
    'assets/images/img7.png',
    'assets/images/img7.png',
  ];

  int _selectedIndex = 0;


  final List<Widget> _pages = [
    HomeContent(),
    OrdersScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffFDFDFD),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xffFDFDFD),
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
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        body: SafeArea(child: _pages[_selectedIndex]),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
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
        backgroundColor: const Color(0xffFDFDFD),

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
                      const Text(
                        'الرئيسية',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'IBM_Plex_Sans_Arabic'),
                      ),
                      Row(
                        children: [
                          Image.asset("assets/images/img8.png"),
                          const SizedBox(width: 10),
                          Image.asset("assets/images/img9.png"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
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
                                margin: const EdgeInsets.symmetric(horizontal: .5),
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
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: images.length,
                            effect: const ExpandingDotsEffect(
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
                  const SizedBox(height: 10),
                  const Text(
                    'التصنيفات',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff1D1D1D),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'IBM_Plex_Sans_Arabic',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const CategoryCard(
                    title: 'الترجمة',
                    description:
                        'نقدم أفضل خدمات الترجمة لأكثر من 10 لغات حول العالم',
                    image: 'assets/images/img5.png',
                  ),
                  const SizedBox(height: 10),
                  const CategoryCard(
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
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff409EDC),
                        fontFamily: 'IBM_Plex_Sans_Arabic'),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                        fontFamily: 'IBM_Plex_Sans_Arabic',
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
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
                          side: const BorderSide(color: Color(0xff409EDC), width: 1),
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
            const SizedBox(width: 15),
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
        backgroundColor: const Color(0xffF8F8F8),
        appBar: AppBar(
          leading: const Icon(Icons.arrow_back_ios),
          title: const Text('طلب ترجمة', style: TextStyle(color: Colors.black)),
          backgroundColor: const Color(0xffF8F8F8),
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
                const Center(
                  child: Text(
                    'طلب ترجمة جديد',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'الرجاء اختيار اللغة المراد ترجمتها',
                    style: TextStyle(fontSize: 14, color: Color(0xffB3B3B3)),
                  ),
                ),
                const SizedBox(height: 8),
                _buildDropdown('اللغة المراد ترجمتها'),
                _buildMultiSelectDropdown('اللغات المراد الترجمة إليها'),
                _buildRadioSelection(),
                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SavedAddress()),
                    );
                  },
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Image.asset("assets/images/img51.png")),
                ),
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
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 5,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.0,
                letterSpacing: 0,
                color: Color(0xFFB3B3B3),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
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
        icon: Image.asset("assets/images/img18.png"),
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
        onPressed: () {

        },
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
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "الرجاء إضافة المرفقات المراد ترجمتها",
            style: TextStyle(fontSize: 14, color: Color(0xffB3B3B3)),
          ),
          IconButton(
            onPressed: onPressed,
            icon: Image.asset("assets/images/img18.png"),
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

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
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
              activeColor: const Color(0xff409EDC),
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
              activeColor: const Color(0xff409EDC),
              onChanged: (value) {
                setState(() {
                  deliveryMethod = value;
                  selectedOption = null;
                  _currentPosition = null;
                  selectedAddress = null;
                });
                _getCurrentLocation();
              },
            ),
            const Text('توصيل'),
          ],
        ),
        const SizedBox(height: 8),
        if (deliveryMethod == "توصيل") ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: RadioListTile<String>(
              activeColor: const Color(0xff409EDC),
              contentPadding: EdgeInsets.zero,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المنزل',style:TextStyle(color:Color(0xff409EDC),fontSize: 14,fontWeight: FontWeight.bold)),
                  if (selectedOption == 'المنزل' && selectedAddress != null ||
                      (selectedAddress != null && selectedOption == null))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "الموقع :",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              selectedAddress ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              value: 'المنزل',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: RadioListTile<String>(
              activeColor: const Color(0xff409EDC),
              contentPadding: EdgeInsets.zero,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('العمل',style:TextStyle(color:Color(0xff409EDC),fontSize: 14,fontWeight: FontWeight.bold)),
                  if (selectedOption == 'العمل' && selectedAddress != null ||
                      (selectedAddress != null && selectedOption == null))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "الموقع :",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              selectedAddress ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              value: 'العمل',
              groupValue: selectedOption,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
            ),
          ),
        ],
        const SizedBox(height: 10),

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
                                  const SnackBar(
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
                        const Align(
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
                        const Align(
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
                        const Align(
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
                        const Align(
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
                            const Text(
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
                                child: const Icon(Icons.arrow_forward_ios)),
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff409EDC),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        const SizedBox(height: 16),
                        const OtpFields(),
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
                                    const TextSpan(
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
                                      style: const TextStyle(
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
                            const SizedBox(width: 10),
                            Text(
                              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                              style: const TextStyle(
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
                            const Text(
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
                                child: const Icon(Icons.arrow_forward_ios)),
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
                                      color: const Color(0xff409EDC), width: 1)
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
                                      color: const Color(0xff409EDC), width: 1)
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
                            const Text(
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
                              child: const Icon(Icons.arrow_forward_ios),
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

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool isTranslationSelected = true;

  final List<Map<String, String>> allOrders = [
    {'status': 'جديد', 'receive': 'توصيل'},
    {'status': 'حالي', 'receive': 'استلام من الفرع'},
    {'status': 'منتهي', 'receive': 'تم التوصيل'},
    {'status': 'ملغي', 'receive': 'لا يوجد استلام'},
    {'status': 'جديد', 'receive': 'توصيل'},
    {'status': 'حالي', 'receive': 'استلام من الفرع'},
    {'status': 'منتهي', 'receive': 'تم التوصيل'},
    {'status': 'ملغي', 'receive': 'لا يوجد استلام'},
    {'status': 'جديد', 'receive': 'توصيل'},
    {'status': 'حالي', 'receive': 'استلام من الفرع'},
  ];

  final Map<String, Map<String, dynamic>> statusDetails = {
    'جديد': {
      'text': 'قيد الانتظار',
      'color': Colors.orange,
      'image': 'assets/images/img16.png'
    },
    'حالي': {
      'text': 'المندوب في الطريق إليك',
      'color': Colors.blue,
      'image': 'assets/images/img16.png'
    },
    'منتهي': {
      'text': 'تم تنفيذ الخ\مه',
      'color': Colors.green,
      'image': 'assets/images/img16.png'
    },
    'ملغي': {
      'text': 'تم إلغاء الطلب',
      'color': Colors.red,
      'image': 'assets/images/img16.png'
    },
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: const Color(0xffFAFAFA),
          appBar: AppBar(
            leading: Icon(Icons.arrow_back_ios_new),
            backgroundColor: const Color(0xffFAFAFA),
            title: const Text('طلباتي', style: TextStyle(color: Colors.black)),

            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/images/img9.png"),
              )
            ],
          ),

          body: Column(
            children: [
              Container(
                width: 360,
                height: 56,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isTranslationSelected = true;
                        });
                      },
                      child: _buildTabButton(
                          'طلبات الترجمة', isTranslationSelected),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isTranslationSelected = false;
                        });
                      },
                      child: _buildTabButton(
                          'طلبات الطباعة', !isTranslationSelected),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xffF2F2F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TabBar(
                  labelColor: Color(0xff409EDC),
                  unselectedLabelColor: Color(0xffB3B3B3),
                  indicatorColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'جديد'),
                    Tab(text: 'حالي'),
                    Tab(text: 'منتهي'),
                    Tab(text: 'ملغي'),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: TabBarView(
                  children: ['جديد', 'حالي', 'منتهي', 'ملغي'].map((tabStatus) {
                    final filteredOrders = allOrders
                        .where((order) => order['status'] == tabStatus)
                        .toList();
                    return filteredOrders.isEmpty
                        ? const Center(child: Text('لا يوجد طلبات'))
                        : ListView.builder(
                            itemCount: (filteredOrders.length / 5).ceil(),
                            itemBuilder: (context, index) {
                              final startIndex = index * 5;
                              final endIndex =
                                  (startIndex + 5) > filteredOrders.length
                                      ? filteredOrders.length
                                      : startIndex + 5;
                              final ordersSubset =
                                  filteredOrders.sublist(startIndex, endIndex);

                              return Column(
                                children: ordersSubset.map((order) {
                                  final details =
                                      statusDetails[order['status']]!;
                                  return OrderItem(
                                    statusText: details['text'],
                                    receiveText: order['receive']!,
                                    statusColor: details['color'],
                                    statusImage: details['image'],
                                  );
                                }).toList(),
                              );
                            },
                          );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xff409EDC) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final String statusText;
  final String receiveText;
  final Color statusColor;
  final String statusImage;

  const OrderItem({
    Key? key,
    required this.statusText,
    required this.receiveText,
    required this.statusColor,
    required this.statusImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#125456',
                      style: TextStyle(
                          color: Color(0xff1D1D1D),
                          fontWeight: FontWeight.bold)),
                  Text('01:15 م - 22/01/2025',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text('اللغه:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1D1D1D))),
                      SizedBox(width: 5),
                      Text('الفرنسيه',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                  Text(receiveText, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 5),
              const Row(
                children: [
                  Text('عدد المرفقات:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1D1D1D))),
                  SizedBox(width: 5),
                  Text('5',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              const Divider(color: Color(0xffF2F2F2)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(statusImage, width: 20),
                      const SizedBox(width: 5),
                      Text(statusText, style: TextStyle(color: statusColor)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [

                        Image.asset("assets/images/img17.png"),
                        const SizedBox(width: 5),
                        const Text('عرض الطلب', style: TextStyle(color: Colors.blue)),

                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TranslationRequestPage2 extends StatefulWidget {
  TranslationRequestPage2({super.key});

  @override
  _TranslationRequestPage2State createState() =>
      _TranslationRequestPage2State();
}

class _TranslationRequestPage2State extends State<TranslationRequestPage2> {
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
        backgroundColor: Color(0xffF8F8F8),
        appBar: AppBar(
          leading: const Icon(Icons.arrow_back_ios),
          title: const Text('طلب ترجمة', style: TextStyle(color: Colors.black)),
          backgroundColor: Color(0xffF8F8F8),
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
                const Center(
                  child: Text(
                    'طلب ترجمة جديد',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'الرجاء اختيار اللغة المراد ترجمتها',
                    style: TextStyle(fontSize: 14, color: Color(0xffB3B3B3)),
                  ),
                ),
                const SizedBox(height: 8),
                _buildDropdown('اللغة'),
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
              hint:
                  Text(selectedLanguage ?? 'اختر اللغه المطلوب الترجمه اليها '),
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
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 5,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.0,
                letterSpacing: 0,
                color: Color(0xFFB3B3B3),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
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
        icon: Image.asset("assets/images/img18.png"),
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
          backgroundColor: const Color(0xff409EDC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage()
            ),
          );
        },
        child: const Text('إرسال الطلب',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF2F2F2),
        appBar: AppBar(
          backgroundColor: const Color(0xffF2F2F2),
          title: const Text('تفاصيل الطلب'),
          leading: const Icon(Icons.arrow_back_ios_new),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderInfo(),
              const SizedBox(height: 16.0),
              DeliveryInfo(),
              const SizedBox(height: 16.0),
              TranslationLanguages(),
              const SizedBox(height: 16.0),
              NotesSection(),
              const SizedBox(height: 16.0),
              AttachmentsSection(),
              const SizedBox(height: 16.0),
              CancelOrderButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailsPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF2F2F2),
        appBar: AppBar(
          backgroundColor: const Color(0xffF2F2F2),
          title: const Text('تفاصيل الطلب'),
          leading: const Icon(Icons.arrow_back_ios_new),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderInfo(),
              const SizedBox(height: 16.0),
              DeliveryInfo(),
              const SizedBox(height: 16.0),
              TranslationLanguages(),
              const SizedBox(height: 16.0),
              NotesSection(),
              const SizedBox(height: 16.0),
              AttachmentsSection(),
              const SizedBox(height: 16.0),
         Card(
          color: Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('قيمه الطلب',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("قيمه الخدمات", style: TextStyle()),
                  Text("70"),
                ]),
                const Divider(),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("الضريبه", style: TextStyle()),
                  Text("15"),
                ]),
                const Divider(),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("الاجمالي",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text("85"),
                ]),


              ],
            ),
          ),
        )
              ,

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Positioned(
                    top: 1194,
                    left: 16,
                    child: Container(
                      width: 343,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF409EDC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "تسديد قيمه الخدمات",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Positioned(
                    top: 1194,
                    left: 16,
                    child: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 343,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE50930),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "الغاء الطلب",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class OrderDetailsPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF2F2F2),
        appBar: AppBar(
          backgroundColor: const Color(0xffF2F2F2),
          title: const Text('تفاصيل الطلب'),
          leading: const Icon(Icons.arrow_back_ios_new),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderInfo(),
              const SizedBox(height: 16.0),
              DeliveryInfo(),
              const SizedBox(height: 16.0),
              TranslationLanguages(),
              const SizedBox(height: 16.0),
              NotesSection(),
              const SizedBox(height: 16.0),
              AttachmentsSection(),
              const SizedBox(height: 16.0),
              Card(
                color: Colors.white,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('قيمه الطلب',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Divider(),
                      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("قيمه الخدمات", style: TextStyle()),
                        Text("70"),
                      ]),
                      const Divider(),
                      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("الضريبه", style: TextStyle()),
                        Text("15"),
                      ]),
                      const Divider(),
                      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("الاجمالي",
                            style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("85"),
                      ]),


                    ],
                  ),
                ),
              )
              ,

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Positioned(
                    top: 1194,
                    left: 16,
                    child: Container(
                      width: 343,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF409EDC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "تأكيد الاستلام",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class OrderInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('رقم الطلب ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('# 1265',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('تاريخ الطلب ',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('22/01/2025',
                    style: TextStyle(
                      fontSize: 14,
                    )),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('وقت الطلب ',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('01:26 م',
                    style: TextStyle(
                      fontSize: 14,
                    )),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("assets/images/img16.png"),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('تم استلام الطلب',
                        style: TextStyle(color: Colors.orange)),
                    Text('الاربعاء 22/01/2025 1:26 م ',
                        style: TextStyle(color: Color(0xffB3B3B3))),
                  ],
                ),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AddAddressScreen()));

                  },
                  child: CircleAvatar(
                      backgroundColor: const Color(0xff409EDC),
                      child: Image.asset("assets/images/img19.png")),
                )
              ],
            ),
            Row(
              children: [
                Image.asset("assets/images/img20.png"),
                const Text("جاري تنفيذ الخدمه",
                    style: TextStyle(color: Color(0xffB3B3B3)))
              ],
            ),
            Row(
              children: [
                Image.asset("assets/images/img21.png"),
                const Text("في انتظارك للستلام ",
                    style: TextStyle(color: Color(0xffB3B3B3)))
              ],
            ),
            Row(
              children: [
                Image.asset("assets/images/img22.png"),
                const Text("تم تسليم الخدمه",
                    style: TextStyle(color: Color(0xffB3B3B3)))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DeliveryInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإستلام',
                    style:
                        TextStyle(fontSize: 13,color:Color(0xffB3B3B3))),
                Text('استلام من الشركه',
                    style:
                        TextStyle(fontSize: 12,color: Color(0xff409EDC))),
              ],
            ),
            Text('موقع الاستلام من الشركة:'),
            Text('الرياض منطقة الشباب قطعة 15 ميني 36 الدور 2',
                style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}

class TranslationLanguages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: const Card(
        color: Colors.white,
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اللغة المراد ترجمتها',
              style:
              TextStyle(fontSize: 13,color:Color(0xffB3B3B3))),
              Text('العربية',style: TextStyle(color:Color(0xff409EDC)),),
              Text('اللغات المراد الترجمة إليها:', style:
                  TextStyle(fontSize: 13,color:Color(0xffB3B3B3))),
              Text('الفرنسية (5 دينار / 100 كلمة)',
                  style: TextStyle(color:Color(0xff409EDC))),
              Text('الإنجليزية (5 دينار / 100 كلمة)',
                  style: TextStyle(color:Color(0xff409EDC))),
            ],
          ),
        ),
      ),
    );
  }
}

class NotesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الملاحظات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            Text('هذا النص هو نص بديل يمكن أن يستبدل بنص آخر في نفس المساحة'),
          ],
        ),
      ),
    );
  }
}

class AttachmentsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('المرفقات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
             Image.asset("assets/images/img10.png"),
             Image.asset("assets/images/img11.png"),
             Image.asset("assets/images/img12.png"),
          ],
        )
          ],
        ),
      ),
    );

  }
}

class AttachmentIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  AttachmentIcon(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        Text(label),
      ],
    );
  }
}

class CancelOrderButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child:   OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CancelOrder()
            ),
          );
        },
        style: OutlinedButton.styleFrom(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          minimumSize: const Size(164, 5),
          backgroundColor: Color(0xffE50930),
        ),
        child: const Text(
          'الغاء الطلب',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class CancelOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("الغاء الطلب ",style:TextStyle(
            fontWeight: FontWeight.bold,fontSize: 17
          )),
          centerTitle: true,
          leading: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Image.asset("assets/images/img23.png"))),
      body: Column(
        children: [
          Center(child: Image.asset("assets/images/img24.png")),
          const SizedBox(
            height: 30,
          ),
          const Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text("سبب الالغاء",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              )),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'توضيح سبب الالغاء',
                  hintStyle: const TextStyle(color: Color(0xffB3B3B3)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffF2F2F2),width: 1),
                    borderRadius: BorderRadius.circular(8),

                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                maxLines: 5,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                onPressed: () {

                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE50930), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  minimumSize: const Size(164, 5),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'الغاء',
                  style: TextStyle(
                    color: Color(0xFFE50930),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff409EDC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  minimumSize: const Size(164, 5),
                ),
                child: const Text(
                  'تراجع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8F8F8),
        appBar: AppBar(
          leading: const Icon(Icons.arrow_back_ios_new),
          title: const Text('المحادثة', style: TextStyle(color: Colors.black)),
          backgroundColor: const Color(0xffF8F8F8),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,

                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Text(
                          'إنجاز',
                          style: TextStyle(
                            color: Color(0xFF3498DB),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      Expanded(
                        child: _buildMessage(
                          'تم ارسال طلبك رقم #1235 وجاري مراجعته من قبل الإدارة',
                          false,
                          forceLeft: true,
                        ),
                      ),
                    ],
                  ),
                  _buildMessage(
                      'هذا النص هو نص بديل يمكن أن تستبدل بنص آخر في نفس المساحة',
                      true),
                  _buildMessage(
                      'هذا النص هو نص بديل يمكن أن تستبدل بنص آخر في نفس المساحة',
                      false),
                  _buildMessage(
                      'هذا النص هو نص بديل يمكن أن تستبدل بنص آخر في نفس المساحة',
                      true),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Image.asset("assets/images/img25.png"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String text, bool isMe, {bool forceLeft = false}) {
    final bool alignLeft = (isMe && !forceLeft) || forceLeft;

    return Align(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          top: 5,
          bottom: 5,
          left: alignLeft ? 10 : 60,
          right: alignLeft ? 60 : 10,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 250,
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      "المزيد",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const Spacer(),
                    Image.asset("assets/images/img9.png", height: 40),
                  ],
                ),
                const SizedBox(height: 24),


                buildSection([
                  buildSettingItem(context, "الملف الشخصي", Icons.person,
                      "assets/images/img26.png",EditProfileScreen()),
                  buildSettingItem(context, "معلوماتي", Icons.info,
                      "assets/images/img27.png",EditProfileScreen()),
                ]),

                const SizedBox(height: 12),


                buildSection([
                  buildSettingItem(context, "إعدادات عامة", Icons.settings,
                      "assets/images/img28.png",GeneralSettingsScreen()),
                  buildSettingItem(context, "تواصل معنا", Icons.phone,
                      "assets/images/img29.png",ContactUsScreen()),
                ]),

                const SizedBox(height: 12),


                buildSection([
                  buildSettingItem(context, "سياسة الاستخدام", Icons.security,
                      "assets/images/img30.png",UsagePolicyScreen()),
                  buildSettingItem(context, "الشروط والأحكام", Icons.rule,
                      "assets/images/img31.png",TermsAndConditionsScreen()),
                  buildSettingItem(context, "سياسة الخصوصية", Icons.privacy_tip,
                      "assets/images/img32.png",PrivacyPolicyScreen()),
                ]),

                const SizedBox(height: 16),


                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/img33.png"),
                      const SizedBox(width: 8),
                      const Text("تسجيل الخروج", style: TextStyle(color: Color(0xffE50930))),
                    ],
                  ),
                ),

                const SizedBox(height: 24),


                 const Center(
                   child: Text("تابعنا عبر",
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                 ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset("assets/images/img34.png"),
                    Image.asset("assets/images/img35.png"),
                    Image.asset("assets/images/img36.png"),
                    Image.asset("assets/images/img37.png"),
                    Image.asset("assets/images/img38.png"),
                    Image.asset("assets/images/img39.png"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget buildSettingItem(
      BuildContext context,
      String title,
      IconData icon,
      String imagePath,
      Widget targetScreen, // ✅ دي الإضافة
      ) {
    return ListTile(
      tileColor: Colors.white,
      leading: Image.asset(imagePath, width: 24, height: 24),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
    );
  }



  Widget buildSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          return Column(
            children: [
              items[index],
            ],
          );
        }),
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: const Icon(Icons.arrow_back_ios_new),
          title: const Text("الملف الشخصي", textAlign: TextAlign.right),

        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Column(
              children: [
                Image.asset("assets/images/img1.png", height: 69, width: 187,),

                const SizedBox(height: 24),
                const Align(
                    alignment: Alignment.topRight,
                    child: Text("الاسم الاول",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),)),
                buildTextField("محمد", firstNameController),
                const SizedBox(height: 16),
                const Align(
                    alignment: Alignment.topRight,
                    child: Text("اسم العائله",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15))),
                buildTextField("اشرف", lastNameController),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(343, 10),
                    backgroundColor: const Color(0xF0409EDC),

                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "حفظ التعديلات",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Container(
      width: 343,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}


class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  bool _isImage44 = true;

  void _toggleImage() {
    setState(() {
      _isImage44 = !_isImage44;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "الإعدادات العامة",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),


                Center(
                  child: Image.asset(
                    "assets/images/img1.png",
                    width: 120,
                  ),
                ),

                const SizedBox(height: 32),


                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsItem("تغيير رقم الجوال", "assets/images/img40.png"),

                      _buildSettingsItem("تغيير البريد الإلكتروني", "assets/images/img41.png"),

                      _buildSettingsItem("تغيير لغة التطبيق", "assets/images/img42.png"),

                      _buildSwitchItem("تفعيل الإشعارات"),
                    ],
                  ),
                ),



                TextButton(
                  onPressed: () {
Navigator.push(context,MaterialPageRoute(builder: (context)=>OtpScreen(contactInfo: '', contactType: '',)));
                  },
                  child: const Text(
                    "حذف الحساب",
                    style: TextStyle(
                      color: Colors.red,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, String icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Image.asset(icon, width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildSwitchItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Image.asset("assets/images/img43.png", width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
          GestureDetector(
            onTap: _toggleImage,
            child: Image.asset(
              _isImage44
                  ? "assets/images/img44.png"
                  : "assets/images/img45.png",
              width: 40,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.close, color: Colors.red),
        title: const Text('لغة التطبيق'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildLanguageOption(
                    context,
                    'English',
                    'assets/images/img46.png',
                    false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildLanguageOption(
                    context,
                    'اللغة العربية',
                    'assets/images/img47.png',
                    true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff28C1ED),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff28C1ED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: const Text(
                  'تأكيد',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, String label, String asset, bool selected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? const Color(0xff28C1ED).withOpacity(.2): const Color(0xffF2F2F2),

        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? const Color(0xff409EDC): const Color(0xffF2F2F2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Image.asset(asset, height: 40),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white,
          title: const Text('تواصل معنا'),
          leading: const Icon(Icons.arrow_back_ios),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset('assets/images/img1.png', height: 80)),
              const SizedBox(height: 16),
              const Center(child: Text('تواصل معنا',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16))),
              const SizedBox(height: 8),
              const Center(child: Text('من خلال :',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Color(0xff676767)))),
              const SizedBox(height: 8),
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/img55.png"),
                  const SizedBox(width: 8),
                  Image.asset("assets/images/img50.png"),
                  const SizedBox(width: 8),
                  Image.asset("assets/images/img49.png"),
                ],
              ),
              const SizedBox(height: 8),
              const Center(child: Text('أو أرسل لنا رسالة :')),
              const SizedBox(height: 16),
              const Text("الاسم",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
              Container(
                width: 343.24,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TextField(
                  decoration: InputDecoration(

                    border: InputBorder.none,
                    hintText: 'ادخل الاسم فضلا',
                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
              const Text("عنوان الرساله",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

              Container(
                width: 343.24,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TextField(
                  decoration: InputDecoration(

                    border: InputBorder.none,
                    hintText: 'الرجاء توضيح عنوان رسالتك',
                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              const Text("نص الرساله",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
              Container(
                width: 343.24,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'ادخل نص الرساله',
                    border: InputBorder.none,

                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 343.24,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff409EDC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إرسال',
                    style: TextStyle(fontSize: 16,color: Colors.white),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
         actions: [Padding(
           padding: const EdgeInsets.all(8.0),
           child: Image.asset("assets/images/img23.png"),
         )],
          title: const Text('حذف الحساب'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset("assets/images/img24.png"),
              const SizedBox(height: 12),
              const Text(
                'هل حقاً تريد حذف حسابك؟',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'سبب حذف الحساب *',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Container(
                  width: 343,
                  height: 106,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFF2F2F2),
                      width: 1,
                    ),
                  ),
                  child: const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'الرجاء توضيح سبب الحذف',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff409EDC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      child: const Text(
                        'تراجع',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 164,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE50930), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      child: const Text(
                        'حذف',
                        style: TextStyle(
                          color: Color(0xFFE50930),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),


                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('سياسة الخصوصية'),
          leading: const Icon(Icons.arrow_back_ios),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(child: Image.asset('assets/images/img1.png', height: 80)),
              const SizedBox(height: 16),
              Container(
                width: 346,

                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const SingleChildScrollView(
                  child: Text(
                    'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF1D1D1D),fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('الشروط والأحكام'),
          leading: const Icon(Icons.arrow_back_ios),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(child: Image.asset('assets/images/img1.png', height: 80)),
              const SizedBox(height: 16),
              Container(
                width: 346,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const SingleChildScrollView(
                  child: Text(
                    'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF1D1D1D), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UsagePolicyScreen extends StatelessWidget {
  const UsagePolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('سياسه الاستخدام'),
          leading: const Icon(Icons.arrow_back_ios),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(child: Image.asset('assets/images/img1.png', height: 80)),
              const SizedBox(height: 16),
              Container(
                width: 346,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const SingleChildScrollView(
                  child: Text(
                    'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة '
                        'هذا النص هو نص بديل يمكن ان يستبدل بنص اخر في نفس المساحة ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF1D1D1D), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogOut extends StatelessWidget {
  const LogOut({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/images/img23.png"),
          )],
          title: const Text('تسجيل الخروج'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset("assets/images/img24.png"),
              const SizedBox(height: 12),
              const Text(
                'هل حقاً تريد تسجيل الخروج؟',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff409EDC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      child: const Text(
                        'تراجع',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 164,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE50930), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      child: const Text(
                        'حذف',
                        style: TextStyle(
                          color: Color(0xFFE50930),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),


                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}



class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'الإشعارات',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          leading: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 8,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Container(
              width: 345,
              height: 75.5,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'هذا النص هو نص بديل يمكن أن يستبدل',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D1D1D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '1 ساعة',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFB3B3B3),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.lock_clock,
                              size: 9,
                              color: Color(0xFFB3B3B3),
                            ),
                            SizedBox(width: 4),

                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.delete_outline, color: Color(0xFFE50930)),


                ],
              ),
            );
          },
        ),
      ),
    );
  }
}




class SavedAddress extends StatefulWidget {
  const SavedAddress({Key? key}) : super(key: key);

  @override
  _SavedAddressState createState() => _SavedAddressState();
}

class _SavedAddressState extends State<SavedAddress> {
  String? currentLocation = 'جاري تحديد الموقع...';
  String? selectedAddress;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;


    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        currentLocation = 'خدمة الموقع غير مفعلة';
      });
      return;
    }


    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          currentLocation = 'تم رفض صلاحية الوصول للموقع';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        currentLocation = 'تم رفض صلاحية الوصول نهائياً';
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation =
      '${position.latitude}, ${position.longitude}';
    });
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8F8F8),
        appBar: AppBar(
          leading: const Icon(Icons.arrow_back_ios),
          title: const Text('العناوين المحفوظه',
              style: TextStyle(color: Colors.black)),
          backgroundColor: const Color(0xffF8F8F8),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Image.asset('assets/images/img52.png', height: 100)),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "اختر احد العناوين المحفوظه الخاصه بك",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAddressCard("المنزل"),
                    _buildAddressCard("العمل"),
                    const SizedBox(height: 10),
                      ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (selectedAddress != null) _buildDeliveryButton(),

                  Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: _buildAddAddressButton(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(String title) {
    bool isSelected = selectedAddress == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAddress = title;
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
                Text(title,
                    style: const TextStyle(
                        color: Color(0xff409EDC),
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Image.asset("assets/images/img54.png"),
                    const SizedBox(width: 10),
                    Image.asset("assets/images/img53.png"),
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "الموقع :",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      currentLocation ?? '',
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

  Widget _buildDeliveryButton() {
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
            SnackBar(content: Text('تم اختيار التوصيل إلى $selectedAddress')),
          );
        },
        child: const Text(
          'التوصيل إلى هذا العنوان',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildAddAddressButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff409EDC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const AddAddressScreen()));
        },
        child: const Text('اضافه عنوان جديد',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}


class SaveOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
            title: const Text("تأكيد الطلب",style:TextStyle(
                fontWeight: FontWeight.bold,fontSize: 17
            )),
            centerTitle: true,
          ),
        body: Column(
          children: [

            const SizedBox(
              height: 30,
            ),
            const Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text("كود الخصم",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                )),
            Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(hintText:"ادخل كود الخصم"),
            ),
            Card(
              color: Colors.white,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('قيمه الطلب',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("قيمه الخدمات", style: TextStyle()),
                      Text("70"),
                    ]),
                    const Divider(),
                    const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("الضريبه", style: TextStyle()),
                      Text("15"),
                    ]),
                    const Divider(),
                    const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("الاجمالي",
                          style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("85"),
                    ]),


                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SuccessOrder()));

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff409EDC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    minimumSize: const Size(164, 5),
                  ),
                  child: const Text(
                    'الدفع',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {

                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF409EDC), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    minimumSize: const Size(164, 5),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'تراجع',
                    style: TextStyle(
                      color: Color(0xFF409EDC),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}


class SuccessOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        body: Center(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text("تم تسديد قيمة الطلب بنجاج",style:TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15
              )),
              SizedBox(height: 60,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetailsPage3()));

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff409EDC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      minimumSize: const Size(164, 5),
                    ),
                    child: const Text(
                      'متابعه الطلب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {

                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF409EDC), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      minimumSize: const Size(164, 5),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'طلب خدمه جديده',
                      style: TextStyle(
                        color: Color(0xFF409EDC),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
