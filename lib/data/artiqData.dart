import 'dart:async';
import 'package:flutter/material.dart';

class ArtiqData {
  static String categoryMusic = "music";
  static String categoryArt = "art";
  static String category = categoryMusic;
  static int categoryIdx = 0;
  static var musicNextStateIcon = [Icons.repeat_one, Icons.repeat, Icons.shuffle];
  static var musicNextStateArr = ["repeat", "auto", "shuffle"];
  static int musicNextStateIdx = 0;
  static String musicNextState = musicNextStateArr[0];
  static bool isOnload = false;
  static bool isPostScrolling = false;
  static bool isFavoriteMusic = true;
  static String version = "1.1.3";

  static String likeGenre = "";

  static Timer refreshTimer;
  static Timer playLikeTimer;
  static int refreshPerSec = 20;
  static int refreshSec = 0;
  static Color refreshColor;

  static Color backgroundColor = Color(0xff2B2B2B);
  static Color darkGreyColor = Color(0xff978A8B);
  static Color fluorescenceColor = Color(0xffE3FF24);
  static Color greyPinkColor = Color(0xffDFC2C8);
}
