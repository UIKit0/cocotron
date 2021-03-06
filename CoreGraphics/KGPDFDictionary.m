/* Copyright (c) 2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "KGPDFDictionary.h"

#import "KGPDFArray.h"
#import "KGPDFStream.h"
#import "KGPDFObject_Integer.h"
#import "KGPDFObject_Name.h"
#import "KGPDFObject_Real.h"
#import "KGPDFObject_Boolean.h"
#import "KGPDFContext.h"
#import <Foundation/NSString.h>
#import <stddef.h>
#import <string.h>

unsigned KGPDFHashCString(NSMapTable *table,const void *data){
   const char *s=data;

   if(s!=NULL){
    unsigned i,result=5381;

    for(i=0;s[i]!='\0';i++)
     result=((result<<5)+result)+(unsigned)(s[i]); // hash*33+c

    return result;
   }

   return 0;
}

BOOL KGPDFIsEqualCString(NSMapTable *table,const void *data1,const void *data2){
   if(data1 == data2)
    return YES;

   if(!data1)
    return !strlen((char *)data2);

   if (!data2)
    return !strlen((char *)data1);

   if(((char *)data1)[0]!=((char *)data2)[0])
    return NO;

   return (strcmp((char *)data1,(char *)data2))?NO:YES;
}

void KGPDFFreeCString(NSMapTable *table,void *data) {
   NSZoneFree(NULL,data);
}

NSMapTableKeyCallBacks KGPDFOwnedCStringKeyCallBacks={
  KGPDFHashCString,KGPDFIsEqualCString,NULL,KGPDFFreeCString,NULL,NULL
};

@implementation KGPDFDictionary

-init {
   _table=NSCreateMapTable(KGPDFOwnedCStringKeyCallBacks,NSObjectMapValueCallBacks,0);
   return self;
}

+(KGPDFDictionary *)pdfDictionary {
   return [[[self alloc] init] autorelease];
}

-(void)dealloc {
   NSFreeMapTable(_table);
   [super dealloc];
}

-(KGPDFObjectType)objectType { return kKGPDFObjectTypeDictionary; }

-(BOOL)checkForType:(KGPDFObjectType)type value:(void *)value {
   if(type!=kKGPDFObjectTypeDictionary)
    return NO;
   
   *((KGPDFDictionary **)value)=self;
   return YES;
}

-(void)setObjectForKey:(const char *)key value:(KGPDFObject *)object {
   char *keyCopy=NSZoneMalloc(NULL,strlen(key)+1);
   
   strcpy(keyCopy,key);
   
   NSMapInsert(_table,keyCopy,object);
}

-(void)setBooleanForKey:(const char *)key value:(KGPDFBoolean)value {
   [self setObjectForKey:key value:[KGPDFObject_Boolean pdfObjectWithBoolean:value]];
}

-(void)setIntegerForKey:(const char *)key value:(KGPDFInteger)value {
   [self setObjectForKey:key value:[KGPDFObject_Integer pdfObjectWithInteger:value]];
}

-(void)setNumberForKey:(const char *)key value:(KGPDFReal)value {
   [self setObjectForKey:key value:[KGPDFObject_Real pdfObjectWithReal:value]];
}

-(void)setNameForKey:(const char *)key value:(const char *)value {
   [self setObjectForKey:key value:[KGPDFObject_Name pdfObjectWithCString:value]];
}

-(KGPDFObject *)objectForCStringKey:(const char *)key {
   KGPDFObject *object=NSMapGet(_table,key);

   return [object realObject];
}

-(KGPDFObject *)inheritedForCStringKey:(const char *)cStringKey typecheck:(KGPDFObjectType)type {
   KGPDFDictionary *parent=self;
   KGPDFObject     *object;

   do{
    if((object=[parent objectForCStringKey:cStringKey])!=nil){
     if([object objectType]==type)
      return object;
    }
    
   }while([parent getDictionaryForKey:"Parent" value:&parent]);
   
   return nil;
}


-(BOOL)getObjectForKey:(const char *)key value:(KGPDFObject **)objectp {
   *objectp=[self objectForCStringKey:key];
   
   return YES;
}

-(BOOL)getNullForKey:(const char *)key {
   KGPDFObject *object=[self objectForCStringKey:key];
   
   return ([object objectType]==kKGPDFObjectTypeNull)?YES:NO;
}

-(BOOL)getBooleanForKey:(const char *)key value:(KGPDFBoolean *)valuep {
   KGPDFObject *object=[self objectForCStringKey:key];
   
   return [object checkForType:kKGPDFObjectTypeBoolean value:valuep];
}

-(BOOL)getIntegerForKey:(const char *)key value:(KGPDFInteger *)valuep {
   KGPDFObject *object=[self objectForCStringKey:key];
   
   return [object checkForType:kKGPDFObjectTypeInteger value:valuep];
}

-(BOOL)getNumberForKey:(const char *)key value:(KGPDFReal *)valuep {
   KGPDFObject *object=[self objectForCStringKey:key];
   
   return [object checkForType:kKGPDFObjectTypeReal value:valuep];
}

-(BOOL)getNameForKey:(const char *)key value:(const char **)namep {
   KGPDFObject *object=[self objectForCStringKey:key];
   
   return [object checkForType:kKGPDFObjectTypeName value:namep];
}

-(BOOL)getStringForKey:(const char *)key value:(KGPDFString **)stringp {
   KGPDFObject *object=[self objectForCStringKey:key];
   
   return [object checkForType:kKGPDFObjectTypeString value:stringp];
}

-(BOOL)getArrayForKey:(const char *)key value:(KGPDFArray **)arrayp {
   KGPDFObject *object=[self objectForCStringKey:key];
   
   return [object checkForType:kKGPDFObjectTypeArray value:arrayp];
}

-(BOOL)getDictionaryForKey:(const char *)key value:(KGPDFDictionary **)dictionaryp {
   KGPDFObject *object=[self objectForCStringKey:key];
   
   return [object checkForType:kKGPDFObjectTypeDictionary value:dictionaryp];
}

-(BOOL)getStreamForKey:(const char *)key value:(KGPDFStream **)streamp {
   KGPDFObject *object=[self objectForCStringKey:key];
   
   return [object checkForType:kKGPDFObjectTypeStream value:streamp];
}

-(NSString *)description {
   NSMutableString *result=[NSMutableString string];
   NSMapEnumerator  state=NSEnumerateMapTable(_table);
   const char *key;
   id          value;
   
   [result appendString:@"<<\n"];
   while(NSNextMapEnumeratorPair(&state,(void **)&key,(void **)&value)){
    [result appendFormat:@"%s %@\n",key,value];
   }
   [result appendString:@">>\n"];

   return result;
}

-(void)encodeWithPDFContext:(KGPDFContext *)encoder {
   NSMapEnumerator  state=NSEnumerateMapTable(_table);
   const char      *key;
   id               value;
   
   [encoder appendString:@"<<\n"];
   while(NSNextMapEnumeratorPair(&state,(void **)&key,(void **)&value)){
    [encoder appendFormat:@"/%s ",key];
    [encoder encodePDFObject:value];
   }
   [encoder appendString:@">>\n"];
}

@end

