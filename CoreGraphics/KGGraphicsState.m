/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "KGGraphicsState.h"

#import <CoreGraphics/CoreGraphics.h>
#import "O2Color.h"
#import "O2ColorSpace.h"
#import "O2MutablePath.h"
#import "KGFont.h"
#import "KGClipPhase.h"
#import <Foundation/NSArray.h>
#import "KGExceptions.h"
#import "KGSurface.h"

@implementation KGGraphicsState

-initWithDeviceTransform:(CGAffineTransform)deviceTransform {
   _deviceSpaceTransform=deviceTransform;
   _userSpaceTransform=CGAffineTransformIdentity;
   _textTransform=CGAffineTransformIdentity;
   _clipPhases=[NSMutableArray new];
   _strokeColor=[[O2Color alloc] init];
   _fillColor=[[O2Color alloc] init];
   _font=nil;
   _pointSize=12.0;
   _textEncoding=kCGEncodingFontSpecific;
   _fontState=nil;
   _patternPhase=CGSizeMake(0,0);
   _lineWidth=1.0;
   _miterLimit=10;
   _blendMode=kCGBlendModeNormal;
   _interpolationQuality=kCGInterpolationDefault;
   _shouldAntialias=YES;
   _antialiasingQuality=64;
   return self;
}

-init {
   return [self initWithDeviceTransform:CGAffineTransformIdentity];
}

-(void)dealloc {
   [_clipPhases release];
   [_strokeColor release];
   [_fillColor release];
   [_font release];
   [_fontState release];
   if(_dashLengths!=NULL)
    NSZoneFree(NULL,_dashLengths);
   [_shadowColor release];
   KGGaussianKernelRelease(_shadowKernel);
   [super dealloc];
}

-copyWithZone:(NSZone *)zone {
   KGGraphicsState *copy=NSCopyObject(self,0,zone);

   copy->_clipPhases=[[NSMutableArray alloc] initWithArray:_clipPhases];
   copy->_strokeColor=O2ColorCreateCopy(_strokeColor);
   copy->_fillColor=O2ColorCreateCopy(_fillColor);
   copy->_font=[_font retain];
   copy->_fontState=[_fontState retain];
   if(_dashLengths!=NULL){
    int i;
    
    copy->_dashLengths=NSZoneMalloc(zone,sizeof(float)*_dashLengthsCount);
    for(i=0;i<_dashLengthsCount;i++)
     copy->_dashLengths[i]=_dashLengths[i];
   }
    
   copy->_shadowColor=O2ColorCreateCopy(_shadowColor);
   
   copy->_shadowKernel=KGGaussianKernelRetain(_shadowKernel);
   
   return copy;
}

-(CGAffineTransform)userSpaceToDeviceSpaceTransform {
   return _deviceSpaceTransform;
}

-(CGAffineTransform)userSpaceTransform {
   return _userSpaceTransform;
}

-(CGRect)clipBoundingBox {
   KGUnimplementedMethod();
   return CGRectZero;
}

-(CGAffineTransform)textMatrix {
   return _textTransform;
}

-(CGInterpolationQuality)interpolationQuality {
   return _interpolationQuality;
}

-(CGPoint)textPosition {
// FIX, is this right?
  return CGPointMake(_textTransform.tx,_textTransform.ty);
}

-(CGPoint)convertPointToDeviceSpace:(CGPoint)point {
   return CGPointApplyAffineTransform(point,_deviceSpaceTransform);
}

-(CGPoint)convertPointToUserSpace:(CGPoint)point {
   return CGPointApplyAffineTransform(point,CGAffineTransformInvert(_deviceSpaceTransform));
}

-(CGSize)convertSizeToDeviceSpace:(CGSize)size {
   return CGSizeApplyAffineTransform(size,_deviceSpaceTransform);
}

-(CGSize)convertSizeToUserSpace:(CGSize)size {
   return CGSizeApplyAffineTransform(size,CGAffineTransformInvert(_deviceSpaceTransform));
}

-(CGRect)convertRectToDeviceSpace:(CGRect)rect {
   KGUnimplementedMethod();
   return CGRectZero;
}

-(CGRect)convertRectToUserSpace:(CGRect)rect {
   KGUnimplementedMethod();
   return CGRectZero;
}

-(void)setDeviceSpaceCTM:(CGAffineTransform)transform {
   _deviceSpaceTransform=transform;
}

-(void)setUserSpaceCTM:(CGAffineTransform)transform {
   _userSpaceTransform=transform;
}

-(void)concatCTM:(CGAffineTransform)transform {
   _deviceSpaceTransform=CGAffineTransformConcat(transform,_deviceSpaceTransform);
   _userSpaceTransform=CGAffineTransformConcat(transform,_userSpaceTransform);
}

-(NSArray *)clipPhases {
   return _clipPhases;
}

-(void)removeAllClipPhases {
   [_clipPhases removeAllObjects];
}

-(void)addClipToPath:(O2Path *)path {
   KGClipPhase *phase=[[KGClipPhase alloc] initWithNonZeroPath:path];
   
   [_clipPhases addObject:phase];
   [phase release];
}

-(void)addEvenOddClipToPath:(O2Path *)path {
   KGClipPhase *phase=[[KGClipPhase alloc] initWithEOPath:path];
   
   [_clipPhases addObject:phase];
   [phase release];
}

-(void)addClipToMask:(KGImage *)image inRect:(CGRect)rect {
   KGClipPhase *phase=[[KGClipPhase alloc] initWithMask:image rect:rect transform:_deviceSpaceTransform];
   
   [_clipPhases addObject:phase];
   [phase release];
}

-(O2Color *)strokeColor {
   return _strokeColor;
}

-(O2Color *)fillColor {
   return _fillColor;
}

-(void)setStrokeColor:(O2Color *)color {
   [color retain];
   [_strokeColor release];
   _strokeColor=color;
}

-(void)setFillColor:(O2Color *)color {
   [color retain];
   [_fillColor release];
   _fillColor=color;
}

-(void)setPatternPhase:(CGSize)phase {
   _patternPhase=phase;
}

-(void)setStrokePattern:(KGPattern *)pattern components:(const float *)components {
}

-(void)setFillPattern:(KGPattern *)pattern components:(const float *)components {
}

-(void)setTextMatrix:(CGAffineTransform)transform {
   _textTransform=transform;
}

-(void)setTextPosition:(float)x:(float)y {
   _textTransform.tx=x;
   _textTransform.ty=y;
}

-(void)setCharacterSpacing:(float)spacing {
   _characterSpacing=spacing;
}

-(void)setTextDrawingMode:(int)textMode {
   _textDrawingMode=textMode;
}

-(KGFont *)font {
   return _font;
}

-(CGFloat)pointSize {
   return _pointSize;
}

-(CGTextEncoding)textEncoding {
   return _textEncoding;
}

-(CGGlyph *)glyphTableForTextEncoding {
   return [_font glyphTableForEncoding:_textEncoding];
}

-(id)fontState {
   return _fontState;
}

-(void)setFontState:(id)fontState {
   fontState=[fontState retain];
   [_fontState release];
   _fontState=fontState;
}

-(void)setFont:(KGFont *)font {
   font=[font retain];
   [_font release];
   _font=font;
}

-(void)setFontSize:(float)size {
   _pointSize=size;
}

-(void)selectFontWithName:(const char *)name size:(float)size encoding:(CGTextEncoding)encoding {
   KGFont *font=O2FontCreateWithFontName([NSString stringWithCString:name]);
   
   if(font!=nil){
    [_font release];
    _font=font;
   }
   
   _pointSize=size;
   _textEncoding=encoding;
}

-(void)setShouldSmoothFonts:(BOOL)yesOrNo {
   _shouldSmoothFonts=yesOrNo;
}

-(void)setLineWidth:(float)width {
   _lineWidth=width;
}

-(void)setLineCap:(int)lineCap {
   _lineCap=lineCap;
}

-(void)setLineJoin:(int)lineJoin {
   _lineJoin=lineJoin;
}

-(void)setMiterLimit:(float)limit {
   _miterLimit=limit;
}

-(void)setLineDashPhase:(float)phase lengths:(const float *)lengths count:(unsigned)count {
   _dashPhase=phase;
   _dashLengthsCount=count;
   
   if(_dashLengths!=NULL)
    NSZoneFree(NULL,_dashLengths);
    
   if(lengths==NULL || count==0)
    _dashLengths=NULL;
   else {
    int i;
    
    _dashLengths=NSZoneMalloc(NULL,sizeof(float)*count);
    for(i=0;i<count;i++)
     _dashLengths[i]=lengths[i];
   }
}

-(void)setRenderingIntent:(CGColorRenderingIntent)intent {
   _renderingIntent=intent;
}

-(void)setBlendMode:(CGBlendMode)mode {
   _blendMode=mode;
}

-(void)setFlatness:(float)flatness {
   _flatness=flatness;
}

-(void)setInterpolationQuality:(CGInterpolationQuality)quality {
   _interpolationQuality=quality;
}

-(void)setShadowOffset:(CGSize)offset blur:(float)blur color:(O2Color *)color {
   _shadowOffset=offset;
   _shadowBlur=blur;
   [color retain];
   [_shadowColor release];
   _shadowColor=color;
   KGGaussianKernelRelease(_shadowKernel);
   _shadowKernel=(_shadowColor==nil)?NULL:KGCreateGaussianKernelWithDeviation(blur);
}

-(void)setShadowOffset:(CGSize)offset blur:(float)blur {
   O2ColorSpaceRef colorSpace=[[O2ColorSpace alloc] initWithDeviceRGB];
   float         components[4]={0,0,0,1.0/3.0};
   O2Color      *color=O2ColorCreate(colorSpace,components);

   [self setShadowOffset:offset blur:blur color:color];
   [color release];
   [colorSpace release];
}

-(void)setShouldAntialias:(BOOL)flag {
   _shouldAntialias=flag;
}

// temporary

-(void)setAntialiasingQuality:(int)value {
   _antialiasingQuality=value;
}

-(void)setWordSpacing:(float)spacing {
   _wordSpacing=spacing;
}

-(void)setTextLeading:(float)leading {
   _textLeading=leading;
}

@end
