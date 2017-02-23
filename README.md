SwiftRPlot  
======
A Swift('er) framework for Real-time time series data visualization

![ios/osx](https://cocoapod-badges.herokuapp.com/p/SwiftRPlot/badge.png)
![ios/osx](https://cocoapod-badges.herokuapp.com/v/SwiftRPlot/badge.png)
![Apache](https://cocoapod-badges.herokuapp.com/l/RestKit/badge.png)
![](https://travis-ci.org/kalanyuz/SwiftR.svg?branch=master)


Plotting time series data such as analog signals in real-time can be difficult. 
Charting solutions currently available are not fine-tuned for real-time plots and can be CPU/RAM intensive so I've decided to address this.
The project will be as lightweight as possible and purely Swift & Cocoa(Touch) based to minimalize problems & update time when new OS arrives.

<img src="http://i.giphy.com/l44QuVwTqYs1FFcYw.gif" width="900">

Features
=======
* Two types of plot : Merged and Split
* Support multiple instances running at the same time
* Thread-safe, you can safely add data obtained from another thread to SwiftR.
* Up to 60fps rendering on macOS
* Use RAM sparingly, CPU needs further optimization
* Support scaling and resizing through view constraints 
* Customizable y-tick labels
* Up to 7 predefined pastel color templates through PrismColor()

Getting Started
------
To use SwiftRPlot:

1. Drag the SwiftR.xcodeproj to your project
2. Go to your target's settings, hit the "+" under the "Embedded Binaries" section, and select the SwiftR.framework
3. In your sourcefile:
```
import SwiftR
```
Currently there is no documentation but both platform shares the same API.
Please try [SwiftRDemo_macOS project](https://github.com/kalanyuz/SwiftR/tree/master/SwiftRDemo_macOS) or [SwiftRDemo_iOS](https://github.com/kalanyuz/SwiftR/tree/master/SwiftRDemo_iOS) to see the example of how you can use the API.

Installing via CocoaPods
------
Add pod 'SwiftRPlot' to your Podfile.

Known Issues
------
* Lower fps when running multiple instances of the plot on iOS
  * This is due to text drawing which is resource intensive and is on my top fix priority

Question, Issues & Feature requests
------
If you are having questions or problems, :
* Make sure you are using the latest version of the library. Check the release-section.
* Search known issues for your problem (open and closed)
* Create new issues (please do not create duplicate issues)

License
------
Copyright 2017 Kalanyu Zintus-art 

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
