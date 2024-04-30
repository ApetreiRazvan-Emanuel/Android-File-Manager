// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'backend/file_manager.dart';
import 'frontend/pages/home/file_manager.dart';
import 'frontend/pages/view_text_file/view_text_file.dart';
import 'frontend/pages/starting_page/path_selection_page.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

GoRouter router() {
  return GoRouter(initialLocation: '/starting_page', routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => FileManagerHome(),
    ),
    GoRoute(
      path: '/view_txt_file',
      builder: (context, state) => ViewTextFile(),
    ),
    GoRoute(
      path: '/starting_page',
      builder: (context, state) => PathSelectionPage(),
    ),
  ]);
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FileManager(),
      child: MaterialApp.router(
      title: 'File Manager',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          color: Colors.grey[850],
          elevation: 0,
        ),
      ),
      routerConfig: router(),
      ),
    ),
  );
}