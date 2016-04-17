StreamScreener (ISSLive)
=======

Is a MacOS Screensaver capable of streaming multiple Quicktime compatible content (AVKit) in split screens on single or dual monitors. By default streams live content from the International Space Station HD Earth Viewing experiment and/or NASA TV.

Installation
=======

Download and unzip ISSLive.zip, open ISSLive.saver and install in to System Preferences or build a custom ISSLive.saver with XCode from source.

Config
=======

Can be reconfigured to stream any QuickTime compatible stream via screensaver options. By default uses the stream URL (http://iphone-streaming.ustream.tv/uhls/17074538/streams/live/iphone/playlist.m3u8) but this URL can be modified to another ustream channel by modifying the channel number in the URL or can be replaced entirely with a different stream. Streams can be optionally played in un-muted mode.

A single monitor will divide the screen as evenly as possible for as many streams configured. Dual monitors will stream the first video full screen on the primary monitor and will split screen the remaining in the second monitor. Additional monitors will mirror the secondary monitor content (for now).