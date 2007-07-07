/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <AppKit/NSFont.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSGraphicsContextFunctions.h>
#import <AppKit/CoreGraphics.h>
#import <AppKit/NSDisplay.h>
#import <AppKit/NSNibKeyedUnarchiver.h>

FOUNDATION_EXPORT char *NSUnicodeToSymbol(const unichar *characters,unsigned length,
  BOOL lossy,unsigned *resultLength,NSZone *zone);


@implementation NSFont

-(void)fetchMetrics {
   NSFontMetrics metrics;

   [[NSDisplay currentDisplay] metricsForFontWithName:[_name cString] pointSize:_pointSize metrics:&metrics];

   _boundingRect=metrics.boundingRect;

   _underlineThickness=metrics.underlineThickness;
   _underlinePosition=metrics.underlinePosition;

   _ascender=metrics.ascender;
   _descender=metrics.descender;
   _isFixedPitch=metrics.isFixedPitch;

}

-(void)encodeWithCoder:(NSCoder *)coder {
   [coder encodeObject:_name forKey:@"NSFont name"];
   [coder encodeFloat:_pointSize forKey:@"NSFont pointSize"];
}

-(NSString *)_translateNibFontName:(NSString *)name {

   if([name isEqual:@"Helvetica"])
    return @"Arial";
   if([name isEqual:@"Helvetica-Bold"])
    return @"Arial Bold";
   if([name isEqual:@"Helvetica-Oblique"])
    return @"Arial Italic";
   if([name isEqual:@"Helvetica-BoldOblique"])
    return @"Arial Bold Italic";

   if([name isEqual:@"Times-Roman"])
    return @"Times New Roman";
   if([name isEqual:@"Ohlfs"])
    return @"Courier New";
   if([name isEqual:@"Courier"])
    return @"Courier New";

   if([name isEqual:@"Symbol"])
    return name;

   return name;
}

-initWithCoder:(NSCoder *)coder {
   if([coder isKindOfClass:[NSNibKeyedUnarchiver class]]){
    NSNibKeyedUnarchiver *keyed=(NSNibKeyedUnarchiver *)coder;
    NSString          *name=[self _translateNibFontName:[keyed decodeObjectForKey:@"NSName"]];
    float              size=[keyed decodeFloatForKey:@"NSSize"];
    int                flags=[keyed decodeIntForKey:@"NSfFlags"]; // ?
    
    [self dealloc];
    
    return [[NSFont fontWithName:name size:size] retain];
   }
   else {
    NSString *name=[coder decodeObjectForKey:@"NSFont name"];
    float     size=[coder decodeFloatForKey:@"NSFont pointSize"];

    [self dealloc];

    return [[NSFont fontWithName:name size:size] retain];
   }
   return nil;
}


-initWithName:(NSString *)name size:(float)size {
   _name=[name copy];
   _pointSize=size;
   _matrix[0]=_pointSize;
   _matrix[1]=0;
   _matrix[2]=0;
   _matrix[3]=_pointSize;
   _matrix[4]=0;
   _matrix[5]=0;

   if([_name isEqualToString:@"Symbol"])
    _encoding=NSSymbolStringEncoding;
   else
    _encoding=NSUnicodeStringEncoding;

   [self fetchMetrics];

   [[NSDisplay currentDisplay] addFontToCache:self];
   
   _kgFont=[[KGFont alloc] initWithName:_name size:_pointSize];

   return self;
}

-(void)dealloc {
//NSLog(@"dealloc'ing font %@ %f",_name,_pointSize);

   [[NSDisplay currentDisplay] removeFontFromCache:self];

   [_name release];
   [_kgFont release];
   [super dealloc];
}

-copyWithZone:(NSZone *)zone {
   return [self retain];
}

+(NSFont *)fontWithName:(NSString *)name size:(float)size {
   NSFont *result;

   if(name==nil)
    [NSException raise:NSInvalidArgumentException format:@"-[%@ %s] name==nil",self,SELNAME(_cmd)];

   result=[[NSDisplay currentDisplay] cachedFontWithName:name size:size];

   if(result==nil)
    result=[[[NSFont alloc] initWithName:name size:size] autorelease];

   return result;
}

+(NSFont *)fontWithName:(NSString *)name matrix:(const float *)matrix {
   return [self fontWithName:name size:matrix[0]];
}

+(NSFont *)systemFontOfSize:(float)size {
   return [self messageFontOfSize:size];
}

+(NSFont *)messageFontOfSize:(float)size {
   return [NSFont fontWithName:@"Arial" size:(size==0)?12.0:size];
}

+(NSFont *)userFontOfSize:(float)size {
   return [NSFont fontWithName:@"Arial" size:(size==0)?12.0:size];
}

+(NSFont *)userFixedPitchFontOfSize:(float)size {
   return [NSFont fontWithName:@"Courier New" size:(size==0)?12.0:size];
}

+(NSFont *)boldSystemFontOfSize:(float)size {
   return [NSFont fontWithName:@"Arial Bold" size:(size==0)?12.0:size];
}

+(NSFont *)menuFontOfSize:(float)size {
   float     pointSize=0;
   NSString *name=[[NSDisplay currentDisplay] menuFontNameAndSize:&pointSize];

   return [NSFont fontWithName:name size:(size==0)?pointSize:size];
}

// nb check
+(NSFont *)toolTipFontOfSize:(float)size {
   return [NSFont fontWithName:@"Arial" size:(size==0)?12.0:size];
}

-(NSString *)description {
   return [NSString stringWithFormat:@"<%@ %@ %f>",isa,_name,_pointSize];
}

-(float)pointSize {
   return _pointSize;
}

-(NSString *)fontName {
   return _name;
}

-(const float *)matrix {
   return _matrix;
}

-(NSRect)boundingRectForFont {
   return _boundingRect;
}

-(unsigned)numberOfGlyphs {
   return [_kgFont numberOfGlyphs];
}

-(BOOL)glyphIsEncoded:(NSGlyph)glyph {
   return [_kgFont glyphIsEncoded:glyph];
}

-(NSSize)advancementForGlyph:(NSGlyph)glyph {
   return [_kgFont advancementForGlyph:glyph];
}

-(NSSize)maximumAdvancement {
   return [_kgFont maximumAdvancement];
}

-(NSFont *)screenFont {
   return self;
}

-(float)underlinePosition {
   return _underlinePosition;
}

-(float)underlineThickness {
   return _underlineThickness;
}

-(float)ascender {
   return _ascender;
}

-(float)descender {
   return _descender;
}

-(float)defaultLineHeightForFont {
   return _ascender+-_descender;
}

-(BOOL)isFixedPitch {
   return _isFixedPitch;
}

-(void)set {
   CGContextSetFont(NSCurrentGraphicsPort(),_kgFont);
}

-(NSStringEncoding)mostCompatibleStringEncoding {
   return _encoding;
}

-(NSMultibyteGlyphPacking)glyphPacking {
   return NSCoreGraphicsGlyphPacking;
}

-(NSPoint)positionOfGlyph:(NSGlyph)current precededByGlyph:(NSGlyph)previous isNominal:(BOOL *)isNominalp {
   return [_kgFont positionOfGlyph:current precededByGlyph:previous isNominal:isNominalp];
}

-(unsigned)getGlyphs:(NSGlyph *)glyphs forCharacters:(unichar *)characters length:(unsigned)length {
   CGGlyph  cgGlyphs[length];
   int      i;
   
   [_kgFont getGlyphs:cgGlyphs forCharacters:characters length:length];
   
   for(i=0;i<length;i++){
    unichar check=characters[i];

    if(check<' ' || (check>=0x7F && check<=0x9F) || check==0x200B)
     glyphs[i]=NSControlGlyph;
    else
     glyphs[i]=cgGlyphs[i];
   }

   return length;
}

-(void)getAdvancements:(NSSize *)advancements forGlyphs:(const NSGlyph *)glyphs count:(unsigned)count {
   CGGlyph cgGlyphs[count];
   int     i;
   
   for(i=0;i<count;i++)
    cgGlyphs[i]=glyphs[i];
    
   [_kgFont getAdvancements:advancements forGlyphs:cgGlyphs count:count];
}

@end

int NSConvertGlyphsToPackedGlyphs(NSGlyph *glyphs,int length,NSMultibyteGlyphPacking packing,char *outputX) {
   int      i,result=0;
   CGGlyph *output=(CGGlyph *)outputX;

   for(i=0;i<length;i++){
    NSGlyph check=glyphs[i];

    if(check!=NSNullGlyph && check!=NSControlGlyph)
     output[result++]=check;
   }

   return result*2;
}

