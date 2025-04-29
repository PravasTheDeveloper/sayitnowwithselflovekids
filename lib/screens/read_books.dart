import 'package:flutter/material.dart';
import 'package:sayitnowwithselflovekids/screens/pdf_viewer_page.dart';

class ReadBooks extends StatefulWidget {
  const ReadBooks({Key? key}) : super(key: key);

  @override
  State<ReadBooks> createState() => _ReadBooksState();
}

class _ReadBooksState extends State<ReadBooks> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  void _showBookDetailsBottomSheet(
    BuildContext context,
    String imageUrl,
    String title,
    List<String> tags,
    String pdfName, // Accept pdfName here
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This allows the bottom sheet to have a flexible height
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8, // 80% of screen height
          minChildSize: 0.5, // Minimum height (50%)
          maxChildSize: 0.9, // Maximum height (90%)
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bottom sheet handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Book Image
                        Center(
                          child: Container(
                            height: 200,
                            width: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Book Title
                        Center(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tags
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                tags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Book Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'This is a detailed description of the book "${title}". '
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                          'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                          'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Book Details
                        const Text(
                          'Book Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Details List
                        _buildDetailRow('Author', 'John Doe'),
                        _buildDetailRow('Publisher', 'Book Publishing Co.'),
                        _buildDetailRow('Publication Date', 'January 2023'),
                        _buildDetailRow('Pages', '120'),
                        _buildDetailRow('Language', 'English'),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),

                  // Read Now Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PdfViewerPage(
                                  pdfPath:
                                      "assets/books/$pdfName.pdf", // Pass the correct path of your PDF here
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Read Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8E8D0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF9A826), // Amber/orange starting color
                    Color(0xFFFF8C00), // Darker orange ending color
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'Read Books',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: _toggleSearch,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Navigate to cart screen or show cart modal
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Visibility(
                      visible: _isSearchVisible,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for books...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFFFF6B6B).withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Recently Read Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recently Read',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFFF6B6B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recently Read Books
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 270,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        scrollDirection: Axis.horizontal,
                        children: const [
                          RecentBookCard(
                            imageUrl: 'assets/images/book1.png',
                            title: 'THE REDDUCK FAMILY TALES',
                            lastRead: 'Last read: Today',
                          ),
                          SizedBox(width: 16),
                          RecentBookCard(
                            imageUrl: 'assets/images/book2.jpg',
                            title:
                                'LIFE WITH AUTISM: HUNTER\'S STORY OF HOPE, NEW FRIENDS AND FUN',
                            lastRead: 'Last read: Yesterday',
                          ),
                          SizedBox(width: 16),
                          RecentBookCard(
                            imageUrl: 'assets/images/book3.jpg',
                            title:
                                'Kylie & Kyle: Siblings Living in Foster Care',
                            lastRead: 'Last read: 2 days ago',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // All Books Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 24,
                        bottom: 16,
                      ),
                      child: const Text(
                        'All Books',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ),

                  // All Books Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.52,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      delegate: SliverChildListDelegate([
                        BookCard(
                          imageUrl: 'assets/images/book1.png',
                          title: 'THE REDDUCK FAMILY TALES',
                          tags: const ['Ages 6-8', 'Educational'],
                          pdfName: 'book1', // Pass pdfName here
                          onReadNowPressed:
                              (context, imageUrl, title, tags, pdfName) =>
                                  _showBookDetailsBottomSheet(
                                    context,
                                    imageUrl,
                                    title,
                                    tags,
                                    pdfName,
                                  ),
                        ),

                        BookCard(
                          imageUrl: 'assets/images/book2.jpg',
                          title:
                              'LIFE WITH AUTISM: HUNTER\'S STORY OF HOPE, NEW FRIENDS AND FUN',
                          tags: const ['Ages 3-5', 'Fantasy'],
                          pdfName: 'book2', // Pass pdfName here
                          onReadNowPressed:
                              (context, imageUrl, title, tags, pdfName) =>
                                  _showBookDetailsBottomSheet(
                                    context,
                                    imageUrl,
                                    title,
                                    tags,
                                    pdfName,
                                  ),
                        ),

                        BookCard(
                          imageUrl: 'assets/images/book3.jpg',
                          title: 'Kylie & Kyle: Siblings Living in Foster Care',
                          tags: const ['Ages 6-8', 'Adventure'],
                          pdfName: 'book3', // Pass pdfName here
                          onReadNowPressed:
                              (context, imageUrl, title, tags, pdfName) =>
                                  _showBookDetailsBottomSheet(
                                    context,
                                    imageUrl,
                                    title,
                                    tags,
                                    pdfName,
                                  ),
                        ),
                      ]),
                    ),
                  ),

                  // Bottom spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentBookCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String lastRead;

  const RecentBookCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.lastRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // Apply border radius here
        child: Container(
          color: Colors.white, // Set the background color to red
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 176,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 176,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3748),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Text(
                  lastRead,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<String> tags;
  final String pdfName; // Add pdfName here
  final Function(BuildContext, String, String, List<String>, String) onReadNowPressed; // Update this line to include pdfName

  const BookCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.onReadNowPressed,
    required this.pdfName,  // Pass pdfName here
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover image
            AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            // Book details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Tags
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Spacer to push button to bottom
            const Spacer(),

            // Read Button at the bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onReadNowPressed(context, imageUrl, title, tags, pdfName); // Pass pdfName to onReadNowPressed
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Read Now',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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

