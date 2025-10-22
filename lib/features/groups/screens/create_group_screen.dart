import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitfree/features/auth/services/auth_service.dart';
import 'package:splitfree/features/groups/services/firestore_service.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final List<String> _memberEmails = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add current user to the group by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUserEmail = ref.read(authServiceProvider).currentUser?.email;
      if (currentUserEmail != null && !_memberEmails.contains(currentUserEmail)) {
        setState(() {
          _memberEmails.add(currentUserEmail);
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _addMember() {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isNotEmpty && 
        email.contains('@') && 
        email.contains('.') &&
        !_memberEmails.contains(email)) {
      setState(() {
        _memberEmails.add(email);
        _emailController.clear();
      });
    } else if (_memberEmails.contains(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This email is already added')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
    }
  }

  void _removeMember(int index) {
    final currentUserEmail = ref.read(authServiceProvider).currentUser?.email;
    final emailToRemove = _memberEmails[index];
    
    // Don't allow removing the current user
    if (emailToRemove == currentUserEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot remove yourself from the group')),
      );
      return;
    }
    
    setState(() {
      _memberEmails.removeAt(index);
    });
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      if (_memberEmails.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A group must have at least 2 members')),
        );
        return;
      }

      setState(() => _isLoading = true);
      
      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.createGroup(
          _nameController.text.trim(),
          _memberEmails,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Group created successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating group: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Group'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'Enter group name',
                  prefixIcon: Icon(Icons.group),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a group name'
                    : null,
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Member Email',
                        hintText: 'friend@example.com',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted: (_) => _addMember(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle, size: 32),
                    color: Theme.of(context).primaryColor,
                    onPressed: _addMember,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Members (${_memberEmails.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  elevation: 2,
                  child: _memberEmails.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Add members by their email',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _memberEmails.length,
                          itemBuilder: (context, index) {
                            final email = _memberEmails[index];
                            final currentUserEmail = ref.watch(authServiceProvider).currentUser?.email;
                            final isCurrentUser = email == currentUserEmail;
                            
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isCurrentUser 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey[300],
                                child: Text(
                                  email[0].toUpperCase(),
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(email),
                              subtitle: isCurrentUser ? const Text('You') : null,
                              trailing: isCurrentUser 
                                ? const Icon(Icons.person, color: Colors.grey)
                                : IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _removeMember(index),
                                  ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createGroup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Create Group',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}