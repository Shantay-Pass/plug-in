import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as Duncan;

class ImageAnalysis {
  static Duncan.Image debugImage;

  static List<Brick> getDataFromImage(Duncan.Image image, LegoColor basePlateColor, int basePlateWidth) {
    const studSpacing = 0.8;   

    // Find plate size
    Duncan.Image basePlateImage = _getBasePlate(image);
    debugImage = basePlateImage;

    // Derive stud spacing from plate size
    int actualStudSpacing = (basePlateImage.width / (basePlateWidth / studSpacing)).round();

    if (!_trimCheck(basePlateImage, actualStudSpacing)) {
      print("[WARNING] Trim check failed!");
      return new List();
    }

    // detect bricks
    return _detectBricks(basePlateImage, actualStudSpacing, basePlateColor);
  }

  static Duncan.Image _getBasePlate(Duncan.Image img) {
    Duncan.Image image = _trimImage(img);

    int pX = -1;
    int qY = -1;
    int qX = -1;
    
    for (int x = 0; x < image.width; x++) {
      Color col = Color(image.getPixel(x, 10));
      col = Color.fromRGBO(col.blue, col.green, col.red, col.opacity);
      
      if(col.red != 255 && col.green != 255 && col.blue != 255) {
        pX = x;
        break;
      }
    }

    for (int y = 0; y < image.height; y++) {
      Color col = Color(image.getPixel(10, y));
      col = Color.fromRGBO(col.blue, col.green, col.red, col.opacity);

      if(col.red != 255 && col.green != 255 && col.blue != 255) {
        qY = y;
        qX = 10;
        break;
      }
    }

    for (int y = 0; y < image.height; y++) {
      Color col = Color(image.getPixel(image.width - 10, y));
      col = Color.fromRGBO(col.blue, col.green, col.red, col.opacity);

      if(col.red != 255 && col.green != 255 && col.blue != 255) {
        if(y < qY) {
          qY = y;
          qX = image.width - 10;
          break;
        }
      }
    }

    if (qX == -1 || qY == -1 || pX == -1)
      print("[WARNING] Error finding rotation!");

    Duncan.Image rotatedImage = Duncan.copyRotate(image, -(atan((qY - 10) / (qX - pX)) * 180/pi));
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

  static bool _trimCheck(Duncan.Image image, int studSpacing) {
    Color topLeft = Color(image.getPixel(studSpacing, studSpacing));
    Color topRight = Color(image.getPixel(image.width - studSpacing, studSpacing));
    Color bottomLeft = Color(image.getPixel(studSpacing, image.height - studSpacing));
    Color bottomRight = Color(image.getPixel(image.width - studSpacing, image.height - studSpacing));
    topLeft = Color.fromRGBO(topLeft.blue, topLeft.green, topLeft.red, topLeft.opacity);
    topRight = Color.fromRGBO(topRight.blue, topRight.green, topRight.red, topRight.opacity);
    bottomLeft = Color.fromRGBO(bottomLeft.blue, bottomLeft.green, bottomLeft.red, bottomLeft.opacity);
    bottomRight = Color.fromRGBO(bottomRight.blue, bottomRight.green, bottomRight.red, bottomRight.opacity);

    return
      !_isNonColor(topLeft) &&
      !_isNonColor(topRight) &&
      !_isNonColor(bottomLeft) &&
      !_isNonColor(bottomRight);
  }

  static bool _isNonColor(Color col) {
    return col.red == 255 && col.green == 255 && col.blue == 255;
  }

  static List<Brick> _detectBricks(Duncan.Image image, int studSize, LegoColor basePlateColor) {
    List<Brick> _bricks = List();
    Map<Point, Stud> _basePlate = Map();

    // Initiate plate
    int halfStudSize = (studSize / 2).round();
    int pointX = 0;
    int pointXMax = 0;
    int pointY = 0;
    int pointYMax = 0;
    for(int x = halfStudSize; x < image.height; x += studSize) {
      pointY = 0;
      for(int y = halfStudSize; y < image.width; y += studSize) {
        Color col = Color(image.getPixel(x, y));
        col = Color.fromRGBO(col.blue, col.green, col.red, col.opacity);

        pointYMax = pointY > pointYMax ? pointY : pointYMax;
        LegoColor color = _colorToLegoColor(col, basePlateColor);
        _basePlate[Point(pointX, pointY++)] = Stud(color);
      }

      pointXMax = pointX > pointXMax ? pointX : pointXMax;
      pointX++;
    }

    // Check plate for bricks
    for (int y = 0; y <= pointYMax; y++) {
      for (int x = 0; x <= pointXMax; x++) {
        Point curPoint = Point(x, y);
        Stud curStud = _basePlate[_basePlate.keys.firstWhere((point) {
          return point.equals(curPoint);
        })];

        if(curStud.visited)
          // Ignore the current stud since it's already been visited
          continue;

        curStud.visited = true;

        if(curStud.color == LegoColor.none)
          // Ignore the stud since no brick is present here
          continue;

        // Create a new brick
        Brick brick = Brick(curStud.color);

        // Check the knob below to see if we should increase the height of the brick
        Point pointBelow = Point(x, y + 1);
        Stud studBelow = _basePlate[_basePlate.keys.firstWhere((point) {
          return point.equals(pointBelow);
        })];

        if (studBelow.color == brick.color) {
          studBelow.visited = true;
          brick.height++;
        }

        // Find the width of the brick
        bool building = true;
        int i = 1;
       
        while(building) {
          Point pointRight = Point(x + i, y);
          Stud studRight = _basePlate[_basePlate.keys.firstWhere((point) {
            return point.equals(pointRight);
          })];
          if(studRight.color == brick.color) {
            if(brick.height == 2) {
              // If the brick has a height of 2, check both the neighboaring studs
              Point pointDownRight = Point(x + i, y + 1);
              Stud studDownRight = _basePlate[_basePlate.keys.firstWhere((point) {
                return point.equals(pointDownRight);
              })];
              if(studDownRight.color == brick.color) {
                brick.width++;
                studRight.visited = true;
                studDownRight.visited = true;
              } else {
                building = false;
              }
            } else {
              brick.width++;
              studRight.visited = true;
            }
            i++;
          } else {
            building = false;
          }
        }
        print("Made brick: " + brick.toString());
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

    return (max - min) < 35;
  }

  // Needs adjusting
  static LegoColor _colorToLegoColor(Color col, LegoColor basePlateColor) {
    int red = col.red;
    int green = col.green;
    int blue = col.blue;

    if ((red >= green || green >= red) && (red > 126 && green > 126) && (red > blue && green > blue))
      // yellow
      return basePlateColor != LegoColor.yellow ? LegoColor.yellow : LegoColor.none;
    if ((green > red && green > blue) && (green > 126) && red + blue >= 100)
      // light green
      return basePlateColor != LegoColor.light_green ? LegoColor.light_green : LegoColor.none;
    if (red > green && red > blue)
      // red
      return basePlateColor != LegoColor.red ? LegoColor.red : LegoColor.none;
    if (green > red && green > blue)
      // green
      return basePlateColor != LegoColor.green ? LegoColor.green : LegoColor.none;
    if (blue > red && blue > green)
      // blue
      return basePlateColor != LegoColor.blue ? LegoColor.blue : LegoColor.none;

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

  @override
  String toString() {
    return color.toString() + " colored brick of dimensions: (H: " + height.toString() + ", W: " + width.toString() + ")";
  }
}

class Point {
  Point(int x, int y) {
    this.x = x;
    this.y = y;
  }

  int x;
  int y;

  @override
  String toString() {
    return ("(" + x.toString() + ", " + y.toString() + ")");
  }

  bool equals(Point other) {
    return other.x == x && other.y == y;
  }
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
  light_green
}