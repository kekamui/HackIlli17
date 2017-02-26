# Project Banter--HackIllinois 2017
A proof-of-concept augmented reality iOS productivity app for the HackIllinois 2017 hackathon at University of Illinois.

In this modern society, people are often busy and find it hard to keep track of small details in their lives. Banter utilizes augmented reality to engage users in a new and fun way to help them stay organized and facilitate daily tasks in their lives. This app allows for a quick check-up on reminders with a simple scan of their phones. This is done by tagging an object the app recognizes, so the user can associate a task with an object inside, say, their bedroom.

Ultimately, our goal is for this app to:
* allow users to add and remove tasks.
* integrate other phone features like alarms.
* integrate other apps such as Amazon (example: the app reminds them to buy a certain item. This would be facilitated by integrating a third party app that allows the user to buy a needed item.) or a weather app (that tells the user what the weather is like that day when they point at, say, a window).
* add a function for creating to-do lists.
* have a database to support multiple users and store their information.

## Usage
Concept: the user can point their phone around their room and tag different objects such as:
* desk: set a reminder to study for a math test on Thursday.
* bed: note that an alarm was set for 8:30 am the next day.
* window: note the temperature of that day and suggestions such as needing warm clothes for a cold day or an umbrella for a rainy day.

For this app, launch and point your camera at [`stones.jpg`](Vuforia/samples/VuforiaSamples-6-2-11/media/ImageTargets/stones.jpg) or [`chips.jpg`](Vuforia/samples/VuforiaSamples-6-2-11/media/ImageTargets/chips.jpg) and see what pops up on screen.

## Build Instructions
* Open the `.xcworkspace` file in Xcode and change the Bundle Identifier and Team.
* Build for actual iOS device (Vuforia does not support iOS simulators).

## Front-end Interface Concept
* Prototype link here: https://xd.adobe.com/view/442bea04-6930-4b4d-a68b-f9576eebc3d1/

## Contributor Guide
* Contributer guide link at [`Contributing.md`](Contributing.md)

## Issues
* There is an issue with the need for high enough contrast between the target image and surrounding background for image recognition to work properly. We hope to develop image sensitivity so the app is able to work properly in more realistic settings.
* Currently, text is inputted manually but we would like users to be able to input information themselves to encourage interaction and increase the app's usefulness.
* The interface needs to be ramped up with additions of buttons and textboxes.

## Third-Party Software
Vuforia framework version 6.2 downloaded from https://developer.vuforia.com/downloads/sdk

Adapted from samples taken from https://developer.vuforia.com/downloads/samples by Vuforia at PTC Inc.
