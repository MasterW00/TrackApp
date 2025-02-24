# Overview

This application is for people to get orginized in a simple and nocomittal space that is easy to configure and understand. It keeps tasks you do regularly up to date and written down so you can keep up with things because life moves so fast. Ever gotten pulled over and found out the registration was out on your car? Put it down in the app! Add your oil changes and tire rotaitons and instpections. Forget the last time you cleaned your bedsheets? Add in your whole room cleaning while your at it! You remember to dust that old clay pot your little kid made you at shcool too!

In the app you start by adding new tracks. These tracks are things in your life you need to mantain regularly with different parts like cars and houses and taxes. In each of those tracks you can enter in a list of tasks, when to do them, and how frequently. Just simply press the plus button to start and navigate intuitivly by pressing on the tracks and the single navigation button.

This will help everyone keep track of all those little things you forget to do with all the big stuff that happens. It will also keep you on task and you can move at your own pace!
{Provide a link to your YouTube demonstration.  It should be a 4-5 minute demo of the app running and a walkthrough of the code.}

# Cloud DataBase
This project uses MongoDB Atlas hosted on AWS. The Database is non relational using Two Collections inside of its database for user information and another for user data. The Database will query the user data collection once a user has been authenticated and the program will only permit them change their own entry. There was no security built in mind when designing this besides a few simple things. The database is designed that only a user authenticated with its passowrd and then by its username will change the enrty associated with that username.

[Software Demo Video](https://youtu.be/mGshejs1pGs)

# Development Environment
Enviornment: \
Dart \
Mongo_DB \
Android Studio \
Flutter \
Mongo_Dart \

Build tools: \
Visual Studio Code \
Flutter SDK standard enviornment \
Android Studio standard enviornment to fulfill Flutter required dependancies \
MongoDB Atlas and Compass \
Compatible with all platforms \
Built on Pixel 6a
# Useful Websites

{Make a list of websites that you found helpful in this project}
* [Flutter Dev](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://docs.flutter.dev/get-started/install&ved=2ahUKEwiB6ef_zrOLAxUsK0QIHTQ4CBgQFnoECAwQAQ&usg=AOvVaw0_DysGRxe6bHMb0c8Whvun)
* [MongoDB] (https://www.mongodb.com)
* [Mongo_Dart] (https://pub.dev/packages/mongo_dart)

# Future Work

* add authentication server that the Database piggy backs for more security
* new authentication tokens and session tokens 
* Change user data structure for security and orginization
* Improve the scheduling features
* Saves to local storage (which makes the app pointless till thats added)
* Add Styles and Infographics
* Overhaul Forms

