import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  Future<void> searchProducts(String searchText) async {
    if (searchText.isEmpty) return;
    
    setState(() => isLoading = true);
    searchResults.clear();

    final collections = [
      'todaydeals',
      'products',
      'watchs',
      'bags',
      'glasses',
      'clothing'
    ];

    String searchLower = searchText.toLowerCase();

    for (var collection in collections) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .get();  // Get all documents and filter locally for case-insensitive search

      final matchingDocs = querySnapshot.docs.where((doc) {
        final name = (doc.data()['name'] ?? '').toString().toLowerCase();
        return name.contains(searchLower);
      });

      searchResults.addAll(
        matchingDocs.map((doc) => {
          ...doc.data(),
          'id': doc.id,
          'collection': collection,
        }),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        iconTheme: IconThemeData(color: Colors.black),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            iconColor: Colors.black,
            hintText: 'Search Amazon',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => searchProducts(value),
        ),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Searching products...'),
                ],
              ),
            )
          : searchResults.isEmpty
              ? const Center(
                  child: Text('No products found'),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(8.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.w,
                  ),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final product = searchResults[index];
                    return Card(
                      color: Colors.white,
                      elevation: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Image.network(
                                product['dealImage'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '\₹${product['dealAmount']?.toString() ?? '0.00'}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16.sp,
                                        color: Colors.amber,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        product['dealRating']?.toString() ?? '0.0',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
