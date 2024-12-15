import 'package:flutter/material.dart';

class GiftDetailsPage extends StatefulWidget {
  final String giftName;
  final String category;
  final String price;
  final String status;

  GiftDetailsPage({
    required this.giftName,
    required this.category,
    required this.price,
    required this.status,
  });

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late bool isPledged;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.giftName);
    _categoryController = TextEditingController(text: widget.category);
    _priceController = TextEditingController(text: widget.price);
    isPledged = widget.status == 'Pledged';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Gift Details'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Colorful Watercolor Painting.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 5, blurRadius: 10),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Gift Name'),
                                enabled: !isPledged,
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _categoryController,
                                decoration: const InputDecoration(labelText: 'Category'),
                                enabled: !isPledged,
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _priceController,
                                decoration: const InputDecoration(labelText: 'Price'),
                                enabled: !isPledged,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: !isPledged
                                    ? () {
                                  // Upload Image logic
                                }
                                    : null,
                                child: const Text("Upload Image"),
                              ),
                              const SizedBox(height: 10),
                              SwitchListTile(
                                title: const Text('Pledged'),
                                value: isPledged,
                                onChanged: (bool value) {
                                  setState(() {
                                    isPledged = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}