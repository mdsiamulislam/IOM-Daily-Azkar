import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class DuaDetailScreen extends StatefulWidget {
  final Map<String, dynamic> duaData;
  final int duaIndex;

  const DuaDetailScreen({
    super.key,
    required this.duaData,
    required this.duaIndex,
  });

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen> {
  bool isBookmarked = false;
  double fontSize = 20.0;

  void _copyToClipboard() {
    final text = widget.duaData['dua'] ?? '';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('দোয়া কপি করা হয়েছে')),
    );
  }

  void _shareDua() {
    final text = widget.duaData['dua'] ?? '';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final duaData = widget.duaData;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green[700],
        title: Text(
          duaData['title'] ?? '',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Tooltip(
            message: 'ফন্ট বড় করুন',
            child: IconButton(
              icon: const Icon(Icons.text_increase, color: Colors.white),
              onPressed: () {
                setState(() {
                  fontSize += 2;
                });
              },
            ),
          ),
          Tooltip(
            message: 'ফন্ট ছোট করুন',
            child: IconButton(
              icon: const Icon(Icons.text_decrease, color: Colors.white),
              onPressed: () {
                setState(() {
                  if (fontSize > 12) fontSize -= 2;
                });
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              label: 'দোয়ার সিরিয়াল নম্বর ${widget.duaIndex + 1}',
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {},
                child: Text(
                  (widget.duaIndex + 1).toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (duaData['rules'] != null)
              Semantics(
                label: 'নিয়ম',
                child: Text(
                  duaData['rules'],
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "দোয়া",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    label: 'আরবি দোয়া',
                    child: Text(
                      duaData['dua_arabic'] ?? '',
                      style: TextStyle(
                        fontSize: (fontSize + 2),
                        fontFamily: 'Scheherazade',
                        height: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'বাংলা অনুবাদ',
                    child: Text(
                      duaData['dua_bangla'] ?? '',
                      style: TextStyle(fontSize: fontSize),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (duaData['reference'] != null)
                    Semantics(
                      label: 'সূত্র',
                      child: Text(
                        "- ${duaData['reference']}",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const Divider(),
                  const SizedBox(height: 14),
                  const Text(
                    "তাফসীর",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'দোয়ার ব্যাখ্যা',
                    child: Text(
                      duaData['dua'] ?? '',
                      style: TextStyle(fontSize: fontSize),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    label: 'তাফসীর',
                    child: Text(
                      duaData['tafseer'] ?? '',
                      style: TextStyle(fontSize: fontSize - 1),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Tooltip(
                message: 'কপি করুন',
                child: IconButton(
                  icon: const Icon(Icons.copy, color: Colors.green),
                  onPressed: _copyToClipboard,
                ),
              ),
              Tooltip(
                message: 'শেয়ার করুন',
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.green),
                  onPressed: _shareDua,
                ),
              ),
              Tooltip(
                message: isBookmarked ? 'Bookmark তুলে ফেলুন' : 'Bookmark করুন',
                child: IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      isBookmarked = !isBookmarked;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isBookmarked ? 'Bookmark করা হয়েছে' : 'Bookmark তুলে ফেলা হয়েছে',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
