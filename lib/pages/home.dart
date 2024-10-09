import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recipe_flutter_app/models/user_profile.dart';
import 'package:recipe_flutter_app/pages/chat_page.dart';
import 'package:recipe_flutter_app/servics/auth_service.dart';
import 'package:recipe_flutter_app/servics/database_service.dart';
import 'package:recipe_flutter_app/servics/navigation_service.dart';
import 'package:recipe_flutter_app/servics/show_toast_service.dart';
import 'package:recipe_flutter_app/widgets/chat_tile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GetIt _getIt = GetIt.instance;

  late NavigationService _navigationService;
  late AuthService _authService;
  late ShowToastService _showToastService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _showToastService = _getIt.get<ShowToastService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            onPressed: () async {
              bool Result = await _authService.logout();
              if (Result) {
                _navigationService.pushReplacementNamed("/login");
                _showToastService.showToast(
                    text: "Successfully! Logged out", icon: Icons.check);
              } else {
                print("Error Occured");
              }
            },
            icon: Icon(Icons.exit_to_app),
            iconSize: 30,
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        child: _chatList(),
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder(
        stream: _databaseService.getUserProfiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: const Text('Unable to get data'),
            );
          }
          if (snapshot.hasData && snapshot != null) {
            final users = snapshot.data!.docs;
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  UserProfile user = users[index].data();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ChatTile(
                      userProfile: user,
                      onTap: () async {
                        bool Result =
                            await _databaseService.chatExistBetweenUser(
                          uid1: _authService.user!.uid,
                          uid2: user.uid!,
                        );
                        if (Result == false) {
                          await _databaseService.createChatInFirebase(
                              uid1: _authService.user!.uid, uid2: user.uid!);
                        }
                        _navigationService.push(
                          MaterialPageRoute(
                            builder: (context) {
                              return ChatPage(chatUser: user);
                            },
                          ),
                        );
                      },
                    ),
                  );
                });
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
