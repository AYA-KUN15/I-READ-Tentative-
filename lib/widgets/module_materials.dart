import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constant.dart';
import '../models/materials.dart';

Widget buildModuleMaterials(List<ModuleMaterial> materials) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Materials',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 8),
      Divider(color: Colors.white, thickness: 2),
      const SizedBox(height: 20),
      if (materials.isEmpty)
        Center(
          child: Text(
            'No materials available',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      Column(
        children: materials.map((m) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                onTap: () {
                  // Handle the download action
                  _downloadFile("${Constants.baseUrl}${m.fileUrl}");
                },
                leading: Icon(Icons.insert_drive_file, color: Colors.white),
                trailing: Icon(Icons.download, color: Colors.white),
                title: GestureDetector(
                  onTap: () {
                    // Handle the download action
                    _downloadFile("${Constants.baseUrl}${m.fileUrl}");
                  },
                  child: Text(
                    m.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    ],
  );
}

void _downloadFile(String url) async {
  try {
    final uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
    )) {}
  } catch (e) {
    log('An error occurred while trying to open the URL: $e');
  }
}
