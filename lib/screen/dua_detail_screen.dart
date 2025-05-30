import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class DuaDetailScreen extends StatefulWidget {
  final int duaIndex;
  final List<dynamic> duaData;

  const DuaDetailScreen({
    super.key,
    required this.duaIndex,
    required this.duaData,
  });

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen> {
  bool isBookmarked = false;
  double fontSize = 20.0;

  void _copyToClipboard() {
    final text = widget.duaData[widget.duaIndex]['dua'] ?? '';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('দোয়া কপি করা হয়েছে')),
    );
  }

  void _shareDua() {
    final text = widget.duaData[widget.duaIndex]['dua'] ?? '';
    Share.share(text);
  }

  void _loadNextDua() {
    if (widget.duaIndex < widget.duaData.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DuaDetailScreen(
            duaData: widget.duaData,
            duaIndex: widget.duaIndex + 1,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এটি শেষ দোয়া')),
      );
    }
  }

  void _loadPreviousDua() {
    if (widget.duaIndex > 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DuaDetailScreen(
            duaData: widget.duaData,
            duaIndex: widget.duaIndex - 1,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এটি প্রথম দোয়া')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDua = widget.duaData[widget.duaIndex];

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green[700],
        title: Text(
          currentDua['title'] ?? '',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase, color: Colors.white),
            tooltip: 'ফন্ট বড় করুন',
            onPressed: () {
              setState(() {
                fontSize += 2;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease, color: Colors.white),
            tooltip: 'ফন্ট ছোট করুন',
            onPressed: () {
              setState(() {
                if (fontSize > 12) fontSize -= 2;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
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
            const SizedBox(height: 16),

            if (currentDua['rules'] != null)
              Text(
                currentDua['rules'],
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
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
                  Text(
                    currentDua['dua_arabic'] ?? '',
                    style: TextStyle(
                      fontSize: fontSize + 2,
                      fontFamily: 'Scheherazade',
                      height: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentDua['dua_bangla'] ?? '',
                    style: TextStyle(fontSize: fontSize),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  if (currentDua['reference'] != null)
                    Text(
                      "- ${currentDua['reference']}",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const Divider(),
                  const SizedBox(height: 14),
                  const Text(
                    "তাফসীর",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentDua['dua'] ?? '',
                    style: TextStyle(fontSize: fontSize),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentDua['tafseer'] ?? '',
                    style: TextStyle(fontSize: fontSize - 1),
                    textAlign: TextAlign.justify,
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
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.green),
                tooltip: 'আগের দোয়া',
                onPressed: _loadPreviousDua,
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.green),
                tooltip: 'কপি করুন',
                onPressed: _copyToClipboard,
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.green),
                tooltip: 'শেয়ার করুন',
                onPressed: _shareDua,
              ),
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.green,
                ),
                tooltip: isBookmarked ? 'Bookmark তুলে ফেলুন' : 'Bookmark করুন',
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
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.green),
                tooltip: 'পরবর্তী দোয়া',
                onPressed: _loadNextDua,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
