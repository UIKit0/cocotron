/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>

@interface NSRichTextReader : NSString {
   NSString            *_imageDirectory;
   NSData              *_data;
   const unsigned char *_bytes;
   unsigned             _length;
   NSRange              _range;

   int  _state;
   int  _groupType;
   unichar _univalue;

   NSRange _letterRange;
   int     _argValue;
   int     _argSign;

   NSMutableDictionary       *_fontTable;
   NSMutableDictionary       *_currentFontInfo;
   BOOL                       _activeColorTable;

   NSMutableDictionary       *_currentAttributes;   
   NSMutableAttributedString *_attributedString;
}

-initWithData:(NSData *)data;
-initWithContentsOfFile:(NSString *)path;

+(NSAttributedString *)attributedStringWithData:(NSData *)data;
+(NSAttributedString *)attributedStringWithContentsOfFile:(NSString *)path;

-(NSAttributedString *)parseAttributedString;

@end
