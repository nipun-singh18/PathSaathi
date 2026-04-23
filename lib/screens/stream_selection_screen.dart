import 'package:flutter/material.dart';

class StreamSelectionScreen extends StatelessWidget {
  const StreamSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder image links matching your requested themes
    final List<Map<String, String>> streams = [
      {
        'title': 'Medical',
        'image':
            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
      },
      {
        'title': 'Non-Medical',
        'image':
            'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
      },
      {
        'title': 'Commerce',
        'image':
            'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800',
      },
      {
        'title': 'Arts',
        'image':
            'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Select Your Path',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Choose Your Stream',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: streams.length,
                itemBuilder: (context, index) {
                  return StreamCard(
                    title: streams[index]['title']!,
                    imageUrl: streams[index]['image']!,
                    onTap: () {
                      // Navigate to quiz and pass the stream name as an argument
                      Navigator.pushNamed(
                        context,
                        '/profile_input',
                        arguments: streams[index]['title'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Widget for Hover Animation
class StreamCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const StreamCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<StreamCard> createState() => _StreamCardState();
}

class _StreamCardState extends State<StreamCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              if (isHovered)
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
            ],
            image: DecorationImage(
              image: NetworkImage(widget.imageUrl),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
            ),
          ),
          child: Center(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
