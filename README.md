Postcodr
==============

What is this app about?
--------------

It is so often happens that you need to know exactly that pesky postcode: either you are ordering something from the web or just would like to know which part of London you are in, everything you need is that magic combination of letters and numbers. 
This app does the magic. You will get the exact postcode of your location!

Why did I make it?
--------------

The main idea was to create a small showcase app in which I can use the following technologies:

- RESTful webservices
- CoreData
- CoreLocation
- CoreAnimation
- UI Transition API
- AutoLayout

How does it work?
--------------

It has very simple UI, but it utilizes two ways of finding out your current postcode. This app uses CoreLocation to find out where you are.

Then based on your location it uses reverse geocoder to get the postcode of the area. If you are lucky enough to be in the lovely kingdom named UK the second stage logic kicks in. This means app is trying to contact http://uk-postcodes.com to get a JSON based response with your postcode.

Then it carefully logs the location and its postcode in a diary you can access by swiping the screen.

Project is commented well enough and has unit tests for it's logic layer.

*Sounds are downloaded from http://www.freesound.com*

Some screenshots
--------------

![alt tag](https://s3.mzstatic.com/us/r30/Purple6/v4/65/2a/10/652a10e8-3dc2-1127-705e-46a3a1984338/mzl.pbcxedeb.png)
![alt tag](https://s5.mzstatic.com/us/r30/Purple4/v4/a3/89/2d/a3892d73-d30f-bc64-9f53-0c6f66c5a4df/mzl.coremoeg.png)
![alt tag](https://s5.mzstatic.com/us/r30/Purple4/v4/5c/d5/76/5cd57624-509c-82d6-b95f-3b76d06f2e99/mzl.sofoxqct.png)
