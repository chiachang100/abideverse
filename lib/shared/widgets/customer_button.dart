import 'package:flutter/material.dart';

import 'package:abideverse/shared/services/url_service.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String url;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.url,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => UrlService.launch(url),
          child: Text(text),
        ),
      ),
    );
  }
}
