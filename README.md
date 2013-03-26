3d_phone
========
############################################################
Steps to manually record the proper position of the video when rotating the phone.
1) Rollover on the phone and drag to rotate the phone.
2) Click on the text "click me to start rotate...."
3) Move mouse to get x, y rotation position as close as possible.  Values in sliders would get synced as well
4) Click again to set the position.
5) Manually adjust slider value to get optimized position.
6) Write down each values and current phone frame index #
7) repeat the process for all 72 frames

e.g. The value I had for frame# 4 by following the stip is below
rotationX = 360;
rotationY = 565;
rotationZ = 360;
scale = 1.05;
fv = 1;	(field of view)
############################################################


3d phone with video

Library:
#bulk loader
http://code.google.com/p/bulk-loader/

#tweenmax 
http://www.greensock.com/tweenmax/

#load image from amazon
http://onegiantmedia.com/cross-domain-policy-issues-with-flash-loading-remote-data-from-amazon-s3-cloud-storage

http://stackoverflow.com/questions/14283094/loading-facebook-profile-image-with-bulk-loader

#video player library
https://github.com/gokercebeci/f4player
http://codeknow.com/opensource/videoLoader/

Project schedule and timeline:

3/19
Outline schedule and timeline, setup github account.  
Dave, this is done, the github url is - https://github.com/bzrga/3d_phone

3/20-3/21
Setup project base
Create flash project in Flash IDE and sync the workspace with github. Create base swc library to store visual assets. Create xml file which contain S3 image file path and audio/video file path. commit the basic project structure into github.
Research and import third party source libraries for loader, tweener, video/audio class and etc

What's Done
Setup project base
Create flash project in Flash Builder and synced the workspace with github. Create xml file which contain image file path and audio/video file path.  Add third party source libraries for Bulk loader and tweenmax.  Setup basic image loading from local folder.  Add simple mouse interaction on images.

3/22-3/23
Dynamically load images from Amazon cloud server and place in flash

Asset Importing
Import any visual asset (background and etc) into flash/swc. Embed any text content

3/24
Visual interaction
add drag left/right event handler onto phone object and show different rotation state upon dragging.

3/25-26
Video/Audio embedding
Embed video streaming player
Embed audio streaming player 
audio/video synchronization

Skew video and sync audio volume depend on phone rotating.  pop out video player when the back of phone is exposed

3/27
General site animation implementation
Place background and other visual asset on stage, adjust the x and y coordinate according to the visual board

3/28-3/29
First round of QA and Fix, Get feedback from designer on visual interaction and make proper adjustment on interaction.

3/30-3/31
Miscellaneous 
Performance Enhancement
Asset and file size optimization, minimize file size and reduce initial load as much as possible. Code clean up.

4/1
Final QA and Fix

4/2
Deliver the final swf and source code
