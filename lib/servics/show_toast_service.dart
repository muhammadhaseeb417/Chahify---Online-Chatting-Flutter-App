import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:recipe_flutter_app/servics/navigation_service.dart';

class ShowToastService {
  final GetIt _getIt = GetIt.instance;

  late NavigationService _navigationService;

  ShowToastService() {
    _navigationService = _getIt.get<NavigationService>();
  }

  void showToast({required String text, IconData icon = Icons.info}) {
    try {
      DelightToastBar(
        autoDismiss: true,
        position: DelightSnackbarPosition.top,
        builder: (context) {
          return ToastCard(
            title: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            leading: Icon(
              icon,
              size: 28,
            ),
          );
        },
      ).show(
        _navigationService.navigationKey!.currentContext!,
      );
    } catch (e) {
      print(e);
    }
  }
}
