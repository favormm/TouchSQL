//
//  CSqliteDatabase_Deprecated.m
//  TouchCode
//
//  Created by Jonathan Wight on 12/9/08.
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

#import "CSqliteDatabase_Deprecated.h"

#import "CSqliteDatabase_Extensions.h"

@implementation CSqliteDatabase (CSqliteDatabase_Deprecated)

+ (NSDateFormatter *)dbDateFormatter
{
NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
[dateFormatter setGeneratesCalendarDates:NO];

return dateFormatter;
}

- (BOOL)objectExistsOfType:(NSString *)inType name:(NSString *)inTableName temporary:(BOOL)inTemporary
{
NSString *theSQL = [NSString stringWithFormat:@"select count(*) from %@ where TYPE = '%@' and NAME = '%@'", inTemporary == YES ? @"SQLITE_TEMP_MASTER" : @"SQLITE_MASTER", inType, inTableName];
NSString *theValue = [self valueForExpression:theSQL error:NULL];
return([theValue intValue] == 1);
}

- (BOOL)tableExists:(NSString *)inTableName
{
return([self objectExistsOfType:@"table" name:inTableName temporary:NO]);
}

- (BOOL)temporaryTableExists:(NSString *)inTableName
{
return([self objectExistsOfType:@"table" name:inTableName temporary:YES]);
}

@end
