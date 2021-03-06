/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>, David Young <daver@geeks.org>
#import <AppKit/NSPopUpButton.h>
#import <AppKit/NSPopUpButtonCell.h>
#import <AppKit/NSObject+BindingSupport.h>

static NSString *NSPopUpButtonBindingObservationContext=@"NSPopUpButtonBindingObservationContext";

@implementation NSPopUpButton

+(Class)cellClass {
    return [NSPopUpButtonCell class];
}

-(id)initWithFrame:(NSRect)frame pullsDown:(BOOL)pullsDown
{
    [super initWithFrame:frame];
    [self setPullsDown:pullsDown];
    
    return self;
}

-(void)dealloc
{
	NS_DURING
	[self removeObserver:self forKeyPath:@"cell.selectedItem"];
	[self removeObserver:self forKeyPath:@"cell.menu.itemArray"];
	NS_HANDLER
	NS_ENDHANDLER
	
	[super dealloc];
}

-(BOOL)pullsDown
{
    return [_cell pullsDown];
}

-(NSMenu *)menu
{
    return [_cell menu];
}

-(NSArray *)itemArray {
   return [_cell itemArray];
}

-(int)numberOfItems {
   return [_cell numberOfItems];
}

-(NSMenuItem *)itemAtIndex:(int)index {
   return [_cell itemAtIndex:index];
}

-(NSMenuItem *)itemWithTitle:(NSString *)title {
   return [_cell itemWithTitle:title];
}

-(int)indexOfItemWithTitle:(NSString *)title {
   return [_cell indexOfItemWithTitle:title];
}

-(int)indexOfItemWithTag:(int)tag {
   return [_cell indexOfItemWithTag:tag];
}

-(NSMenuItem *)selectedItem {
   return [_cell selectedItem];
}

-(NSString *)titleOfSelectedItem {
   return [_cell titleOfSelectedItem];
}

-(int)selectedTag {
   return [_cell tag];
}

-(int)indexOfSelectedItem {
   return [_cell indexOfSelectedItem];
}

-(void)setPullsDown:(BOOL)flag
{
    [_cell setPullsDown:flag];
}

-(void)setMenu:(NSMenu *)menu
{
    [_cell setMenu:menu];
}

-(void)addItemWithTitle:(NSString *)title {
   [_cell addItemWithTitle:title];
}

-(void)addItemsWithTitles:(NSArray *)titles {
   [_cell addItemsWithTitles:titles];
}

-(void)removeAllItems {
   [_cell removeAllItems];
}

-(void)removeItemAtIndex:(int)index {
   [_cell removeItemAtIndex:index];
}

-(void)insertItemWithTitle:(NSString *)title atIndex:(int)index {
   [_cell insertItemWithTitle:title atIndex:index];
}

-(void)selectItemAtIndex:(int)index {
   [_cell selectItemAtIndex:index];
   [self setNeedsDisplay:YES];
}

- (NSMenuItem *)lastItem {
   return [_cell lastItem];
}

-(void)selectItemWithTitle:(NSString *)title {
   [_cell selectItemWithTitle:title];
   [self setNeedsDisplay:YES];
}

-(BOOL)selectItemWithTag:(int)tag {
   int index = [self indexOfItemWithTag:tag];
   if (index >= 0)
   {
      [self selectItemAtIndex:index];
      return YES;
   }
   else
      return NO;
}

-(void)mouseDown:(NSEvent *)event {
   if(![self isEnabled])
    return;

   if([_cell trackMouse:event inRect:[self bounds] ofView:self untilMouseUp:NO]){
    NSMenuItem *item=[self selectedItem];
    SEL         action=[item action];
    id          target=[item target];

    [_cell setState:![_cell state]];
    [self setNeedsDisplay:YES];

    if(action==NULL){
     action=[self action];
     target=[self target];
    }
    else if(target==nil){
     target=[self target];
    }

    [self sendAction:action to:target];
   }
}

- (void)keyDown:(NSEvent *)event {
    [self interpretKeyEvents:[NSArray arrayWithObject:event]];
}

// this gets us arrow keys to select items in the menu w/o popping it up.
- (void)moveUp:(id)sender {
    [_cell moveUp:sender];
    [self setNeedsDisplay:YES];
}

- (void)moveDown:(id)sender {
    [_cell moveDown:sender];
    [self setNeedsDisplay:YES];
}

- (void)insertNewline:(id)sender {
    [self mouseDown:nil];
}

@end


@implementation NSPopUpButton (BindingSupport)
-(void)_setItemValues:(NSArray*)values forKey:(NSString*)key;
{
	int i;

	if([values count]!=[self numberOfItems])
	{
		[self removeAllItems];
		for(i=0; i<[values count]; i++)
			[self addItemWithTitle:@""];
	}
	if(!key)
		return;
	
	for(i=0; i<[values count]; i++)
	{
		[[self itemAtIndex:i] setValue:[values objectAtIndex:i] forKey:key];
	}
}

-(id)_contentValues
{
	return [self valueForKeyPath:@"itemArray.title"];
}

-(void)_setContentValues:(NSArray*)values
{
	[self _setItemValues:values forKey:@"title"];
}

-(id)_content
{
	return [self valueForKeyPath:@"itemArray.representedObject"];
}

-(void)_setContent:(NSArray*)values
{
	[self _setItemValues:values forKey:@"representedObject"];
	if(![self _binderForBinding:@"contentValues"])
	{
		[self _setItemValues:[values valueForKey:@"description"] forKey:@"title"];
	}
}



-(NSUInteger)_selectedIndex
{
	return [self indexOfSelectedItem];
}

-(void)_setSelectedIndex:(NSUInteger)idx
{
	[self selectItemAtIndex:idx];
}

-(id)_selectedValue
{
	return [self titleOfSelectedItem];
}

-(void)_setSelectedValue:(id)value
{
	return [self selectItemWithTitle:value];
}

- (void) bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	[self addObserver:self 
		   forKeyPath:@"cell.menu.itemArray" 
			  options:NSKeyValueObservingOptionPrior
			  context:NSPopUpButtonBindingObservationContext];
	
	[self addObserver:self 
		   forKeyPath:@"cell.selectedItem" 
			  options:NSKeyValueObservingOptionPrior
			  context:NSPopUpButtonBindingObservationContext];
	
	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == NSPopUpButtonBindingObservationContext) {
		if([keyPath isEqualToString:@"cell.selectedItem"])
		{
			if([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue])
			{
				[self willChangeValueForKey:@"selectedIndex"];
            [self willChangeValueForKey:@"selectedValue"];
            [self willChangeValueForKey:@"selectedObject"];

			}
			else
			{
            [self didChangeValueForKey:@"selectedObject"];
            [self didChangeValueForKey:@"selectedValue"];
				[self didChangeValueForKey:@"selectedIndex"];
			}
		}
		else
		{
			if([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue])
			{
				[self willChangeValueForKey:@"contentValues"];
			}
			else
			{
				[self didChangeValueForKey:@"contentValues"];
			}
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}
@end
