import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:genome/src/theme/app_background.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import '../utils/language_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  late GenerativeModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env["GEMINI_API_KEY"];
    _model = GenerativeModel(model: "gemini-2.0-flash", apiKey: apiKey!);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isUser": true});
      _controller.clear();
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // Health-only restriction prompt
      final prompt = """
You are a health assistant. Only answer health-related questions.
If the question is not related to health, politely reply:
⚠️ I can only answer health-related questions.

User: $text
""";

      final response = await _model.generateContent([Content.text(prompt)]);
      final reply = response.text ?? "⚠️ No response received.";

      setState(() {
        _messages.add({"text": reply, "isUser": false});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "text": "❌ Error connecting to Gemini:\n$e",
          "isUser": false,
        });
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, lang, child) {
        return Scaffold(
          body: AppBackground(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                          child: Image.asset(
                            "assets/images/chat_bg.png",
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg["isUser"];
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? const Color(0xFFDDEBFF)
                                    : const Color(0xFFDAD0E8),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isUser ? 16 : 0),
                                  bottomRight: Radius.circular(isUser ? 0 : 16),
                                ),
                              ),
                              child: Text(
                                msg["text"],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16, top: 4),
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Positioned(
                        left: 0,
                        bottom: 70,
                        child: Image.asset(
                          "assets/images/chat_ico.png",
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: lang.locale.languageCode == 'ar' ? "إرسال" : "Send",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFB4B5F1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.send, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
