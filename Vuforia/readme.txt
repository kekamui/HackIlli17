Project Banter--HackIllinois 2017

In this modern society, people are often busy and find it hard to keep track of small details in their lives. Banter utilizes augmented reality to engage users in a new and fun way to help them stay organized and facilitate daily tasks in their lives. This app allows for a quick check-up on reminders with a simple scan of their phones. This is done by tagging an object the app recognizes, so the user can associate a task with an object inside, say, their bedroom.

Ultimately, our goal is for this app to:
-allow users to add and remove tasks.
-integrate other phone features like alarms.
-integrate other apps such as Amazon (example: the app reminds them to buy a certain item. This would be facilitated by integrating a third party app that allows the user to buy a needed item.) or a weather app (that tells the user what the weather is like that day when they point at, say, a window).
-add a function for creating to-do lists.
-have a database to support multiple users and store their information.

USAGE
The user can point their phone around their room and tag different objects such as:
-desk: set a reminder to study for a math test on Thursday.
-bed: note that an alarm was set for 8:30 am the next day.
-window: note the temperature of that day and suggestions such as needing warm clothes for a cold day or an umbrella for a rainy day.

BUILD INSTRUCTIONS
-To have the full testing experience, you must ideally have an iOS phone or OS X stimulator to test the app in.
-git clone to access the application.

INTERFACE:
-Prototype link here: https://xd.adobe.com/view/442bea04-6930-4b4d-a68b-f9576eebc3d1/

CONTRIBUTER GUIDE:
-Contributer guide link here: https://github.com/kekamui/HackIlli17/blob/master/Contributing.md

ISSUES:
-There is an issue with the need for high enough contrast between the target image and surrounding background for image recognition to work properly. We hope to develop image sensitivity so the app is able to work properly in more realistic settings.
-Currently, text is inputted manually but we would like users to be able to input information themselves to encourage interaction and increase the app's usefulness.
-The interface needs to be ramped up with additions of buttons and textboxes.

Vuforia Augmented Reality SDK Release Package
=============================================


This package has the following structure:

vuforia-sdk-ios-xx-yy-zz/     
    build/                        Vuforia SDK
        include/                  Commented header files
        lib/                      Static link libraries
    licenses/                     License Agreements
    samples/                      Destination folder for sample applications
        readme.txt                Instructions for downloading and installing the sample applications
    assets/                       Additional assets required to use Vuforia SDK
    readme.txt                    This document
    

To get started, go to https://developer.vuforia.com, where you will find detailed 
documentation on developing AR apps using the Vuforia SDK, and a brief description 
of the online Target Management System.

To view the SDK license agreement, go to https://developer.vuforia.com/legal/vuforia-developer-agreement

To view the release notes, go to https://developer.vuforia.com/library/release-notes


/*============================================================================
            Copyright (c) 2010-2015 PTC Inc.
            All Rights Reserved.
         Confidential and Proprietary - PTC Inc.
  ============================================================================*/
