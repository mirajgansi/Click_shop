import 'package:flutter/material.dart';

class AppCategory {
  final String id;
  final String title;
  final String image;
  final Color bg;
  final Color border;

  const AppCategory({
    required this.id,
    required this.title,
    required this.image,
    required this.bg,
    required this.border,
  });

  String get titleOneLine => title.replaceAll("\n", " ");
}

const appCategories = <AppCategory>[
  AppCategory(
    id: "meat",
    title: "Meat & Fish",
    image: "assets/images/meat.png",
    bg: Color(0xFFFBEAEA),
    border: Color(0xFFF0B4B4),
  ),
  AppCategory(
    id: "oil",
    title: "Cooking Oil\n& Ghee",
    image: "assets/images/oil.png",
    bg: Color(0xFFFFF1E6),
    border: Color(0xFFFFC7A3),
  ),
  AppCategory(
    id: "pulses",
    title: "Pulses",
    image: "assets/images/pulses.png",
    bg: Color(0xFFFFF7D6),
    border: Color(0xFFFFE08A),
  ),
  AppCategory(
    id: "bakery",
    title: "Bakery & Snacks",
    image: "assets/images/bakery.png",
    bg: Color(0xFFF1E9FF),
    border: Color(0xFFD2C0FF),
  ),
  AppCategory(
    id: "snacks",
    title: "Snacks",
    image: "assets/images/snacks.png",
    bg: Color(0xFFEAF1FF),
    border: Color(0xFFB9D0FF),
  ),
  AppCategory(
    id: "beverages",
    title: "Beverages",
    image: "assets/images/beverages.png",
    bg: Color(0xFFEAFBFF),
    border: Color(0xFFAFE7F5),
  ),
];
