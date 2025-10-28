import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/token_service.dart';
import '../services/api_service.dart';
import '../utils/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<dynamic> _mails = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('DEBUG: Firebase User ID: ${user?.uid ?? 'NULL'}');
    _loadMails();
  }

  Future<void> _handleUnauthorized() async {
    await _logout(); // _logout already clears tokens and navigates
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadMails() async {
    setState(() => _isLoading = true);
    try {
      print('DEBUG: Attempting to load existing mails...');
      final response = await ApiService.getAllMails(limit: 50);
      print('DEBUG: Load Mails SUCCESS response body: ${response.toString()}');
      setState(() {
        _mails = response['mails'] ?? [];
      });
    } catch (e) {
      print('DEBUG: Load Mails FAILED error: $e');
      if (mounted) {
        if (e is UnauthorizedException) {
          await _handleUnauthorized();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load mails: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // This function is now used for both pull-to-refresh and the FAB
  Future<void> _fetchGmailEmails() async {
    setState(() => _isLoading = true);
    try {
      print('DEBUG: Attempting to fetch Gmail emails from backend...');
      final response = await ApiService.fetchGmailEmails(maxResults: 50);
      print('DEBUG: Fetch Gmail SUCCESS response body: ${response.toString()}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fetched ${response['fetched']} emails, Saved ${response['saved']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
      // Reload the local list after fetching new ones
      await _loadMails();
    } catch (e) {
      print('DEBUG: Fetch Gmail FAILED error: $e');
      if (mounted) {
        if (e is UnauthorizedException) {
          await _handleUnauthorized();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to fetch emails: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await TokenService.clearAll();
    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = TokenService.getUserData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MailMind Inbox'),
        backgroundColor: const Color(0xFF0f3460),
        elevation: 0,
        actions: [
          // Removed the refresh button as per user request
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
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
        child: Column(
          children: [
            // User Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    backgroundImage: userData['profilePic'] != null
                        ? NetworkImage(userData['profilePic']!)
                        : null,
                    child: userData['profilePic'] == null
                        ? Text(
                      userData['name']?[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${userData['name'] ?? 'User'}!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userData['email'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Mail Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_mails.length} Emails',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mail List
            Expanded(
              child: _mails.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.mail_outline,
                      size: 80,
                      color: Colors.white30,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No emails yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _fetchGmailEmails,
                      icon: const Icon(Icons.download),
                      label: const Text('Fetch Gmail Emails'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: _fetchGmailEmails, // Pull to refresh now fetches new Gmail emails
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _mails.length,
                  itemBuilder: (context, index) {
                    final mail = _mails[index];
                    return _buildMailCard(mail);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMailCard(dynamic mail) {
    final subject = mail['subject'] ?? 'No Subject';
    final fromAddress = mail['from_address'] ?? 'Unknown';
    final receivedAt = mail['received_at'] ?? '';
    final hasSummary = mail['summary'] != null && mail['summary'].toString().isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.mailDetail,
            arguments: mail,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.mail,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'From: $fromAddress',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (hasSummary)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.green, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Summarized',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(receivedAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                  Row(
                    children: [
                      if (!hasSummary)
                        TextButton.icon(
                          onPressed: () => _summarizeEmail(mail['_id']),
                          icon: const Icon(Icons.auto_awesome, size: 14),
                          label: const Text('Summarize'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                        ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white30),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _summarizeEmail(String mailId) async {
    try {
      await ApiService.summarizeEmail(mailId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email summarized'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadMails();
    } catch (e) {
      if (mounted) {
        if (e is UnauthorizedException) {
          await _handleUnauthorized();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to summarize: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}