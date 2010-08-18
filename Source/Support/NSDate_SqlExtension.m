//
//  NSDate_SqlExtension.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/8/08.
//  Copyright 2008 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSDate_SqlExtension.h"

@implementation NSDate (NSDate_SqlExtension)

static NSDateFormatter *gDateFormatter = NULL;

+ (NSDateFormatter *)sqlDateStringFormatter
{
@synchronized([self class])
	{
// 2008-09-09 02:12:36
	if (gDateFormatter == NULL)
		{
		NSDateFormatter *theFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[theFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[theFormatter setGeneratesCalendarDates:NO];
		[theFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		[theFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		
		gDateFormatter = [theFormatter retain];
		}
	}
return(gDateFormatter);
}

+ (NSDateFormatter *)sqlDateOnlyStringFormatter
{
	@synchronized([self class])
	{
		if (gDateFormatter == NULL)
		{
			NSDateFormatter *theFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[theFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			[theFormatter setGeneratesCalendarDates:NO];
			[theFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
			[theFormatter setDateFormat:@"yyyy-MM-dd"];
			
			gDateFormatter = [theFormatter retain];
		}
	}
	return(gDateFormatter);
}


+ (id)dateWithSqlDateString:(NSString *)inString
{
NSDate *theDate = [[self sqlDateStringFormatter] dateFromString:inString];
//NSLog(@"%@ -> %@", inString, theDate);
return(theDate);
}

- (NSString *)sqlDateString
{
NSString *theDateString = [[[self class] sqlDateStringFormatter] stringFromDate:self];
//NSLog(@"%@ -> %@", self, theDateString);
return(theDateString);
}

- (NSString *)sqlDateOnlyString {
	return [[[self class] sqlDateOnlyStringFormatter] stringFromDate:self];
}


@end
