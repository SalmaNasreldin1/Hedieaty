import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Controllers/gift_controller.dart';
import '../Controllers/signin_controller.dart';

class GiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic> gift;

  const GiftDetailsPage({Key? key, required this.gift}) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final GiftController _giftController = GiftController();
  final SignInController signInController = SignInController();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  bool isPledged = false;
  bool isPublished = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.gift['name']);
    descriptionController = TextEditingController(text: widget.gift['description']);
    categoryController = TextEditingController(text: widget.gift['category']);
    priceController = TextEditingController(text: widget.gift['price']?.toString());
    isPledged = widget.gift['status'] == 'pledged';
    isPublished = widget.gift['published'] == 1;

    // Load existing image if available
    if (widget.gift['imageLink'] != null) {
      selectedImage = File(widget.gift['imageLink']);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveGift() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Price are required')),
      );
      return;
    }

    final updatedGift = {
      'id': widget.gift['id'],
      'name': nameController.text,
      'description': descriptionController.text,
      'category': categoryController.text,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'status': isPledged ? 'pledged' : 'available',
      'published': isPublished ? 1 : 0,
      'imageLink': selectedImage?.path ?? widget.gift['imageLink'], // Keep existing path if no new image
      'firebase_id': widget.gift['firebase_id'], // Ensure firebase_id is retained
      'pledged_by': isPledged ? await signInController.getUserUID() : '',
      'event_id': widget.gift['event_id'],
    };

    try {
      // Update in SQLite
      await _giftController.updateGift(widget.gift['id'], updatedGift);

      // If published, update in Firebase
      if (isPublished) {
        await _giftController.publishGift(updatedGift);
      } else if (widget.gift['published'] == 1 && !isPublished) {
        // If previously published but now unpublished, unpublish from Firebase
        await _giftController.unpublishGift(updatedGift);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift updated successfully')),
      );

      Navigator.pop(context, updatedGift); // Return updated data to parent page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Gift: ${widget.gift['name']}')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: isPledged
                  ? null // Disable image change for pledged gifts
                  : _pickImage,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  image: selectedImage != null
                      ? DecorationImage(
                    image: FileImage(selectedImage!),
                    fit: BoxFit.cover,
                  )
                      : widget.gift['imageLink'] != null
                      ? DecorationImage(
                    image: FileImage(File(widget.gift['imageLink'])),
                    fit: BoxFit.cover,
                  )
                      : const DecorationImage(
                    image: AssetImage('assets/gift_placeholder.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: selectedImage == null && widget.gift['imageLink'] == null
                    ? const Icon(Icons.add_a_photo, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Gift Name'),
                    enabled: !isPledged, // Disable when pledged
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    enabled: !isPledged,
                  ),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                    enabled: !isPledged,
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price'),
                    enabled: !isPledged,
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Publish Gift'),
                    value: isPublished,
                    onChanged: (value) async {
                      // Execute the asynchronous work first
                      if (value == 1) {
                        // Unpublish the gift
                        await _giftController.unpublishGift(widget.gift);
                        widget.gift['published'] = 0;
                      } else {
                        // Publish the gift
                        await _giftController.publishGift(widget.gift);
                        widget.gift['published'] = 1;
                      }

                      // Update the state synchronously inside setState
                      setState(() {
                        isPublished = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Pledge Gift'),
                    value: isPledged,
                    onChanged: (value) async {
                      String? user_firebase_id = await signInController.getUserUID();
                      if (value) {
                        await _giftController.pledgeGift(widget.gift['id'], user_firebase_id!); // Replace with user ID
                      } else {
                        await _giftController.unpledgeGift(widget.gift['id']);
                      }
                      setState(() {
                        isPledged = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:_saveGift,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}