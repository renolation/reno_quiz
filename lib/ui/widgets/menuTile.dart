import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class MenuTile extends StatelessWidget {
  final String title;
  final bool isSvgIcon;
  final String? leadingIcon;
  final IconData? leadingIconData;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.isSvgIcon,
    required this.onTap,
    required this.title,
    this.leadingIcon,
    this.leadingIconData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.0,
      child: ListTile(
        onTap: onTap,
        title: Text(
          AppLocalization.of(context)!.getTranslatedValues(title)!,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        leading: Container(
          width: 60,
          transform: Matrix4.identity()..scale(isSvgIcon ? 0.45 : 1.0),
          transformAlignment: Alignment.center,
          child: isSvgIcon
              ? SvgPicture.asset(
                  UiUtils.getImagePath(leadingIcon!),
                  color: Theme.of(context).primaryColor,
                )
              : Icon(
                  leadingIconData,
                  color: Theme.of(context).primaryColor,
                ),
        ),
      ),
    );
  }
}
