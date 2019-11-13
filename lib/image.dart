import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as Duncan;

class ImageAnalysis {
  static List<Brick> getDataFromImage(Duncan.Image image, LegoColor basePlateColor, int basePlateWidth) {
    const studSpacing = 0.8;   

    // Find plate size
    Duncan.Image basePlateImage = _getBasePlate(image);

    // Derive stud size from plate size
    int actualStudSize = (basePlateImage.width / basePlateWidth * studSpacing).round();

    // detect bricks based on stud size
    //List<Brick> bricks = List();
    //bricks.add(Brick(LegoColor.cyan));
    //return bricks;
    return _detectBricks(basePlateImage, actualStudSize, basePlateColor);
  }

  static Duncan.Image _getBasePlate(Duncan.Image img) {
    Duncan.Image image = _trimImage(img);

    int pX = -1;
    int qY = -1;
    int qX = -1;
    
    for (int x = 0; x < image.width; x++) {
      Color col = Color(image.getPixel(x, 5));
      col = Color.fromRGBO(col.blue, col.green, col.red, col.opacity);
      
      if(col.red != 255 && col.green != 255 && col.blue != 255) {
        pX = x;
        break;
      }
    }

    for (int y = 0; y < image.height; y++) {
      Color col = Color(image.getPixel(5, y));
      col = Color.fromRGBO(col.blue, col.green, col.red, col.opacity);

      if(col.red != 255 && col.green != 255 && col.blue != 255) {
        qY = y;
        qX = 5;
        break;
      }
    }

    for (int y = 0; y < image.height; y++) {
      Color col = Color(image.getPixel(image.width - 3, y));
      col = Color.fromRGBO(col.blue, col.green, col.red, col.opacity);

      if(col.red != 255 && col.green != 255 && col.blue != 255) {
        if(y < qY) {
          qY = y;
          qX = image.width - 5;
          break;
        }
      }
    }
    
    num a = atan((qY - 5) / (qX - pX)) * 180/pi;

    Duncan.Image rotatedImage = Duncan.copyRotate(image, -a);
    Duncan.Image newImage = Duncan.Image(image.height, image.width, channels: Duncan.Channels.rgba);
    newImage.fill(Duncan.Color.fromRgba(255, 255, 255, 255));

    return Duncan.trim(Duncan.drawImage(newImage, rotatedImage), mode: Duncan.TrimMode.topLeftColor);
  }

  static Duncan.Image _trimImage(Duncan.Image image) {
    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        Color col = Color(image.getPixel(x, y));
        col = Color.fromRGBO(col.blue, col.green, col.red, col.opacity);

        if (_isShadeOfGray(col))
          image.setPixelRgba(x, y, 255, 255, 255);
      }
    }
    return Duncan.trim(image, mode: Duncan.TrimMode.topLeftColor);
  }

  static List<Brick> _detectBricks(Duncan.Image image, int studSize, LegoColor basePlateColor) {
    List<Brick> _bricks = List();
    Map<Point, Stud> _basePlate = Map();

    // Initiate plate
    for(int x = studSize; x <= image.height - studSize; x += studSize) {
      for(int y = studSize; y <= image.width - studSize; y += studSize) {
        Color col = Color(image.getPixel(x, y));
        col = Color.fromRGBO(col.blue, col.green, col.red, col.opacity);

        _basePlate[Point(x, y)] = Stud(_colorToLegoColor(col, basePlateColor));
      }
    }

    // Check plate for bricks
    for (int x = 0; x < _basePlate.length; x++) {
      for (int y = 0; y < _basePlate.length; y++) {
        Point curPoint = Point(x, y);

        if(_basePlate[curPoint].visited)
          // Ignore the current stud since it's already been visited
          continue;

        _basePlate[curPoint].visited = true;

        if(_basePlate[curPoint].color == LegoColor.none)
          // Ignore the stud since no brick is present here
          continue;

        // Create a new brick
        Brick brick = Brick(_basePlate[curPoint].color);

        // Check the knob below to see if we should increase the height of the brick
        Point below = Point(x + 1, y);
        if (_basePlate[below].color == brick.color) {
          _basePlate[below].visited = true;
          brick.height++;
        }

        // Find the width of the brick
        bool building = true;
        while(building) {
          int i = 1;
          Point p = Point(x, y + i);
          if(_basePlate[p].color == brick.color) {
            if(brick.height == 2) {
              // If the brick has a height of 2, check both the neighboaring studs
              Point p2 = Point(x + 1, y + i);
              if(_basePlate[p2].color == brick.color) {
                brick.width++;
                _basePlate[p].visited = true;
                _basePlate[p2].visited = true;
              } else {
                building = false;
              }
            } else {
              brick.width++;
              _basePlate[p].visited = true;
            }
            i++;
          } else {
            building = false;
          }
        }

        _bricks.add(brick);
      }
    }

    return _bricks;
  }

  static bool _isShadeOfGray(Color col) {
    int max = col.blue;
    int min = col.blue;

    if(max < col.green)
      max = col.green;
    if(max < col.red)
      max = col.red;
    if(min > col.green)
      min = col.green;
    if(min > col.red)
      min = col.red;

    return (max - min < 60);
  }

  static LegoColor _colorToLegoColor(Color col, LegoColor basePlateColor) {
    int red = col.red;
    int green = col.green;
    int blue = col.blue;

    if (red > 126 && green < 126 && blue < 126)
      // red
      return basePlateColor != LegoColor.red ? LegoColor.red : LegoColor.none;
    if (red < 126 && green > 126 && blue < 126)
      // green
      return basePlateColor != LegoColor.green ? LegoColor.green : LegoColor.none;
    if (red < 126 && green < 126 && blue > 126)
      // blue
      return basePlateColor != LegoColor.blue ? LegoColor.blue : LegoColor.none;
    if (red > 126 && green > 126 && blue < 126)
      // yellow
      return basePlateColor != LegoColor.yellow ? LegoColor.yellow : LegoColor.none;

    return LegoColor.none;
  }
}

class Brick {
  Brick(LegoColor color) {
    this.color = color;
  }

  int height = 1;
  int width = 1;

  LegoColor color;
}

class Point {
  Point(int x, int y) {
    this.x = x;
    this.y = y;
  }

  int x;
  int y;
}

class Stud {
  Stud(LegoColor color) {
    this.color = color;
  }

  bool visited = false;
  LegoColor color;
}

enum LegoColor {
  none,
  red,
  green,
  blue,
  yellow,
  cyan,
  light_green
}