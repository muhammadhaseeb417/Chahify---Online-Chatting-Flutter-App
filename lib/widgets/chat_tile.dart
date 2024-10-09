import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/user_profile.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  final Function onTap;

  const ChatTile({
    super.key,
    required this.userProfile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap();
      },
      dense: false,
      leading: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.15,
        width: MediaQuery.sizeOf(context).width * 0.15,
        child: CircleAvatar(
          backgroundImage: NetworkImage(userProfile.pfpURL!),
        ),
      ),
      title: Text(
        userProfile.name!,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
