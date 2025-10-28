import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/routes.dart';

class MailDetailScreen extends StatefulWidget {
  final dynamic mail;

  const MailDetailScreen({super.key, required this.mail});

  @override
  State<MailDetailScreen> createState() => _MailDetailScreenState();
}

class _MailDetailScreenState extends State<MailDetailScreen> {
  // All chat-related state and methods (_chatController, _messages, _showChatBottomSheet, etc.)
  // have been removed and moved to MailChatScreen

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // New navigation method to dedicated chat screen
  void _navigateToChat() {
    Navigator.pushNamed(
      context,
      Routes.mailChat,
      arguments: widget.mail,
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.mail['summary'];
    Map<String, dynamic>? summaryData;

    // Parse summary if it's a JSON string
    if (summary != null && summary.toString().isNotEmpty) {
      try {
        if (summary is String) {
          summaryData = jsonDecode(summary);
        } else if (summary is Map) {
          summaryData = Map<String, dynamic>.from(summary);
        }
      } catch (e) {
        print('Error parsing summary: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Details'),
        backgroundColor: const Color(0xFF0f3460),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0f3460),
              Color(0xFF16213e),
              Color(0xFF1a1a2e),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject
              _buildSectionTitle('SUBJECT'),
              const SizedBox(height: 8),
              _buildInfoCard(
                widget.mail['subject'] ?? 'No Subject',
                Icons.subject,
              ),
              const SizedBox(height: 24),

              // From
              _buildSectionTitle('FROM'),
              const SizedBox(height: 8),
              _buildInfoCard(
                widget.mail['from_address'] ?? 'Unknown',
                Icons.person_outline,
              ),
              const SizedBox(height: 24),

              // Date
              _buildSectionTitle('RECEIVED'),
              const SizedBox(height: 8),
              _buildInfoCard(
                _formatDate(widget.mail['received_at']),
                Icons.calendar_today,
              ),
              const SizedBox(height: 24),

              // AI Summary (if exists)
              if (summaryData != null) ...[
                _buildSectionTitle('AI SUMMARY'),
                const SizedBox(height: 12),
                _buildAISummary(summaryData),
                const SizedBox(height: 24),
              ],

              // Email Body
              _buildSectionTitle('EMAIL CONTENT'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  widget.mail['body'] ?? 'No content',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToChat,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Ask AI'),
      ),
    );
  }

  Widget _buildAISummary(Map<String, dynamic> summaryData) {
    final importance = summaryData['importance'] ?? 'Normal';
    final summary = summaryData['summary'] ?? '';
    final keyPoints = summaryData['key_points'] as List? ?? [];
    final actionRequired = summaryData['action_required'] ?? '';

    Color importanceColor = Colors.blue;
    if (importance.toString().toLowerCase().contains('important')) {
      importanceColor = Colors.orange;
    }
    if (importance.toString().toLowerCase().contains('urgent') ||
        importance.toString().toLowerCase().contains('very')) {
      importanceColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.15),
            Colors.blue.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: importanceColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: importanceColor, width: 1.5),
                ),
                child: Text(
                  importance,
                  style: TextStyle(
                    color: importanceColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          // Summary
          Text(
            summary,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              height: 1.6,
            ),
          ),

          if (keyPoints.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Key Points:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...keyPoints.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],

          if (actionRequired.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notification_important,
                    color: Colors.orange.shade300,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      actionRequired,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade100,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.white.withOpacity(0.5),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInfoCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue.shade300,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    try {
      final date = DateTime.parse(dateStr.toString());
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown date';
    }
  }
}