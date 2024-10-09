import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recipe_flutter_app/consts.dart';
import 'package:recipe_flutter_app/models/user_profile.dart';
import 'package:recipe_flutter_app/servics/auth_service.dart';
import 'package:recipe_flutter_app/servics/database_service.dart';
import 'package:recipe_flutter_app/servics/media_service.dart';
import 'package:recipe_flutter_app/servics/navigation_service.dart';
import 'package:recipe_flutter_app/servics/show_toast_service.dart';
import 'package:recipe_flutter_app/servics/storage_servive.dart';
import 'package:recipe_flutter_app/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? name, email, password;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  File? selectedImage;
  final GetIt _getIt = GetIt.instance;
  bool isLoading = false;

  late final MediaService _mediaService;
  late AuthService _authService;
  late NavigationService _navigationService;
  late ShowToastService _showToastService;
  late StorageServive _storageServive;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _showToastService = _getIt.get<ShowToastService>();
    _storageServive = _getIt.get<StorageServive>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 15,
        ),
        child: Column(
          children: [
            _headerText(),
            if (!isLoading) _loginForm(),
            if (!isLoading) _buttonText(),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.1,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Let\'s, get going!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Register the form using the form below',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.63,
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _pfpSelectedField(),
            CustomTextField(
              hintText: 'Name',
              validatorRegExp: NAME_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            CustomTextField(
              hintText: 'Email',
              validatorRegExp: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            CustomTextField(
              hintText: 'Password',
              obscureText: true,
              validatorRegExp: PASSWORD_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            _loginButton(),
          ],
        ),
      ),
    );
  }

  Widget _pfpSelectedField() {
    return GestureDetector(
      onTap: () async {
        final File? file = await _mediaService.getMediaImageFromUserGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.sizeOf(context).width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if (_registerFormKey.currentState?.validate() ?? false) {
              _registerFormKey.currentState?.save();
              bool result = await _authService.Register(email!, password!);
              if (result) {
                String? pfpURL = await _storageServive.uploadUserpfp(
                    file: selectedImage!, uid: _authService.user!.uid);

                if (pfpURL != null) {
                  _databaseService.createUserInFirebase(
                      userProfile: UserProfile(
                          uid: _authService.user!.uid,
                          name: name,
                          pfpURL: pfpURL));
                }

                _navigationService.goBack();
                _navigationService.pushReplacementNamed("/home");
                setState(() {
                  isLoading = false;
                });

                _showToastService.showToast(
                    text: "Registerd Successfully!", icon: Icons.check);
              } else {
                setState(() {
                  isLoading = false;
                });
              }
            }
          } catch (e) {
            print(e);
            _showToastService.showToast(
                text: "Failed to Register, Please try again",
                icon: Icons.error);
          }
        },
        child: const Text('Register'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buttonText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.16,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("Already have a account? "),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              "Login",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
