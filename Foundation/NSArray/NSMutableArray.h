/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSArray.h>

@interface NSMutableArray : NSArray

-initWithCapacity:(unsigned)capacity;
+arrayWithCapacity:(unsigned)capacity;

-(void)addObject:object;
-(void)addObjectsFromArray:(NSArray *)array;

-(void)removeObjectAtIndex:(unsigned)index;
-(void)removeAllObjects;
-(void)removeLastObject;
-(void)removeObject:object;
-(void)removeObject:object inRange:(NSRange)range;
-(void)removeObjectIdenticalTo:object;
-(void)removeObjectIdenticalTo:object inRange:(NSRange)range;
-(void)removeObjectsInRange:(NSRange)range;
-(void)removeObjectsFromIndices:(unsigned *)indices numIndices:(unsigned)count;
-(void)removeObjectsInArray:(NSArray *)array;

-(void)insertObject:object atIndex:(unsigned)index;

-(void)setArray:(NSArray *)array;
-(void)replaceObjectAtIndex:(unsigned)index withObject:object;
-(void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)array;
-(void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)array range:(NSRange)otherRange;
-(void)exchangeObjectAtIndex:(unsigned)index withObjectAtIndex:(unsigned)other;

-(void)sortUsingSelector:(SEL)selector;
-(void)sortUsingFunction:(int (*)(id, id, void *))compare context:(void *)context;

-(void)sortUsingDescriptors:(NSArray *)descriptors;
-(void)filterUsingPredicate:(NSPredicate *)predicate;

@end
