import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isEditMode = false;
  
  // Controllers for edit mode
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          
          if (user == null) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          if (_isEditMode)
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  // TODO: Implement image picker
                                },
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        user.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.studentId,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                
                // Profile Content
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Quick Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Department',
                              user.department,
                              Icons.school,
                              Colors.blue,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              'Year',
                              user.year,
                              Icons.calendar_today,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Profile Details
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _isEditMode ? Icons.save : Icons.edit,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    onPressed: _toggleEditMode,
                                  ),
                                ],
                              ),
                              Divider(),
                              _buildProfileField(
                                'Full Name',
                                _nameController,
                                Icons.person_outline,
                                enabled: _isEditMode,
                              ),
                              _buildProfileField(
                                'Email',
                                _emailController,
                                Icons.email_outlined,
                                enabled: false, // Email can't be changed
                              ),
                              _buildProfileField(
                                'Phone',
                                _phoneController,
                                Icons.phone_outlined,
                                enabled: _isEditMode,
                              ),
                              _buildProfileInfo(
                                'Student ID',
                                user.studentId,
                                Icons.badge_outlined,
                              ),
                              _buildProfileInfo(
                                'Department',
                                user.department,
                                Icons.school_outlined,
                              ),
                              _buildProfileInfo(
                                'Year',
                                user.year,
                                Icons.calendar_today_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Settings Section
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.lock_outline),
                              title: Text('Change Password'),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: _showChangePasswordDialog,
                            ),
                            Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.notifications_outlined),
                              title: Text('Notifications'),
                              trailing: Switch(
                                value: true,
                                onChanged: (value) {
                                  // TODO: Implement notification toggle
                                },
                              ),
                            ),
                            Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.devices),
                              title: Text('Registered Devices'),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: _showRegisteredDevices,
                            ),
                            Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.help_outline),
                              title: Text('Help & Support'),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // TODO: Navigate to help screen
                              },
                            ),
                            Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.info_outline),
                              title: Text('About'),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: _showAboutDialog,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Logout Button
                      CustomButton(
                        text: 'LOGOUT',
                        onPressed: _handleLogout,
                        color: Colors.red,
                        icon: Icons.logout,
                      ),
                      
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
  }) {
    if (!enabled || !_isEditMode) {
      return _buildProfileInfo(label, controller.text, icon);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEditMode() async {
    if (_isEditMode) {
      // Save changes
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      bool success = await authProvider.updateProfile({
        'name': _nameController.text,
        'phone': _phoneController.text,
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: currentPasswordController,
              label: 'Current Password',
              obscureText: true,
              prefixIcon: Icons.lock_outline,
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: newPasswordController,
              label: 'New Password',
              obscureText: true,
              prefixIcon: Icons.lock,
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: confirmPasswordController,
              label: 'Confirm New Password',
              obscureText: true,
              prefixIcon: Icons.lock,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final result = await _authService.updatePassword(
                currentPasswordController.text,
                newPasswordController.text,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: result['success'] ? Colors.green : Colors.red,
                ),
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showRegisteredDevices() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registered Devices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.phone_android, color: Colors.green),
              title: Text('Current Device'),
              subtitle: Text('Xiaomi Redmi Note 10'),
              trailing: Chip(
                label: Text('Active'),
                backgroundColor: Colors.green.withOpacity(0.2),
              ),
            ),
            // Add more devices here
            SizedBox(height: 20),
            Text(
              'You can register up to 2 devices',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Smart Attendance',
        applicationVersion: '1.0.0',
        applicationIcon: Icon(
          Icons.school,
          size: 50,
          color: Theme.of(context).primaryColor,
        ),
        children: [
          Text(
            'Geo-fence and WiFi based attendance tracking system for educational institutions.',
          ),
          SizedBox(height: 10),
          Text(
            'Developed with ❤️ for Students',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}