/* Copyright (c) 2008 Johannes Fortmann
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/CGWindow.h>
#import <X11/Xlib.h>

@class CairoContext, X11Display;

@interface X11Window : CGWindow {
   id _delegate;
   Window _window;
   Display *_dpy;
   CairoContext *_backingContext;
   CairoContext *_cgContext;
   NSMutableDictionary *_deviceDictionary;
   NSRect _frame;
   BOOL _mapped;
}
+(void)removeDecorationForWindow:(Window)w onDisplay:(Display*)dpy;
-initWithFrame:(NSRect)frame styleMask:(unsigned)styleMask isPanel:(BOOL)isPanel backingType:(NSUInteger)backingType;
-(NSRect)frame;
-(Visual*)visual;
-(Drawable)drawable;
-(NSPoint)transformPoint:(NSPoint)pos;
-(NSRect)transformFrame:(NSRect)frame;
-(void)sizeChanged;
-(void)frameChanged;
-(void)handleEvent:(XEvent*)ev fromDisplay:(X11Display*)display;
@end
