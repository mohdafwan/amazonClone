import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/deal_model.dart';

class UploadDealScreen extends StatefulWidget {
  const UploadDealScreen({super.key});

  @override
  State<UploadDealScreen> createState() => _UploadDealScreenState();
}

class _UploadDealScreenState extends State<UploadDealScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _collectionName = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addtocartController = TextEditingController();
  final TextEditingController _totalpriceController = TextEditingController();

  final TextEditingController _bannerUrlController = TextEditingController();
  final TextEditingController _bannerCollectionIdController =
      TextEditingController();

  // final List<String> reviews = [
  //   "niceProduct i never see 1",
  //   "niceProduct i never see 2",
  // ];

  Future<void> _uploadDeal() async {
    if (_formKey.currentState!.validate()) {
      try {
        final deal = DealModel(
          addtocart: false,
          dealAmount: _amountController.text,
          dealImage: _imageController.text,
          dealPercentage: _percentageController.text,
          dealRating: 5,
          // dealReviews: reviews,
          dealTitle: _titleController.text,
          name: _nameController.text,
          totalprice: _totalpriceController.text,
        );

        await FirebaseFirestore.instance
            .collection(_collectionName.text)
            .add(deal.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal uploaded successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading deal: $e')));
      }
    }
  }

  Future<void> _uploadBanner() async {
    if (_bannerUrlController.text.isNotEmpty &&
        _bannerCollectionIdController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('banners').add({
          'bannerUrl': _bannerUrlController.text,
          'collectionId': _bannerCollectionIdController.text,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner uploaded successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading banner: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all banner fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload New Deal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _collectionName,
                decoration: const InputDecoration(labelText: 'Collection Name'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter collection name'
                            : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _totalpriceController,
                decoration: const InputDecoration(labelText: 'Total Price'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter total price'
                            : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Deal Amount'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Please enter amount' : null,
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter image URL'
                            : null,
              ),
              TextFormField(
                controller: _percentageController,
                decoration: const InputDecoration(labelText: 'Deal Percentage'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter percentage'
                            : null,
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Deal Title'),
                maxLines: 3,
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Please enter title' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadDeal,
                child: const Text('Upload Deal'),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                'Banner Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _bannerUrlController,
                decoration: const InputDecoration(
                  labelText: 'Banner Image URL',
                ),
              ),
              TextFormField(
                controller: _bannerCollectionIdController,
                decoration: const InputDecoration(
                  labelText: 'Banner Collection ID',
                  helperText: 'ID for products associated with this banner',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _uploadBanner();
                  _amountController.clear();
                  _imageController.clear();
                  _percentageController.clear();
                  _titleController.clear();
                  _bannerUrlController.clear();
                  _bannerCollectionIdController.clear();
                  _addtocartController.clear();
                  _totalpriceController.clear();
                  _nameController.clear();
                },
                child: const Text('Upload Banner'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _imageController.dispose();
    _percentageController.dispose();
    _titleController.dispose();
    _bannerUrlController.dispose();
    _bannerCollectionIdController.dispose();
    _nameController.dispose();
    _addtocartController.dispose();
    _totalpriceController.dispose();

    super.dispose();
  }
}
