//
//  NSArray_SqlExtensions.m
//  TouchCode
//
//  Created by Jonathan Wight on Fri Apr 16 2004.
//  Copyright 2004 toxicsoftware.com. All rights reserved.
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

#import "NSArray_SqlExtensions.h"

@implementation NSArray (NSArray_Extensions)

- (NSString *)componentsJoinedByQuotedSQLEscapedCommas
{
// ### Note I'm doing a certain amount of optimisation here which is why the code is a little bit fuggly (e.g. I'm avoiding NSEnumerators and trying not to create too many temporary objects).
NSMutableString *theString = [NSMutableString stringWithCapacity:512];
unsigned theCount = [self count];
//
for (unsigned N = 0; N != theCount; ++N)
	{
	id theObject = [self objectAtIndex:N];
	if (theObject == NULL || [theObject isEqual:[NSNull null]])
		{
		[theString appendString:@"null"];
		}
	else
		{
		NSString *theTrimmedString = [theObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if ([theTrimmedString length] == 0)
			{
			[theString appendString:@"null"];
			}
		else
			{
			[theString appendString:@"'"];
			unsigned theStringLength = [theString length];
			[theString appendString:theTrimmedString];
			[theString replaceOccurrencesOfString:@"\'" withString:@"\'\'" options:NSLiteralSearch range:NSMakeRange(theStringLength, [theTrimmedString length])];
			[theString appendString:@"'"];
			}
		}
	if (N != theCount - 1)
		[theString appendString:@", "];
	}
return(theString);
}

@end
