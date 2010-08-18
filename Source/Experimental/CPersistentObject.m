//
//  CPersistentObject.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/12/08.
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

#import "CPersistentObject.h"

#import "CObjectTranscoder.h"
#import "CPersistentObjectManager.h"
#import "CSqliteDatabase.h"
#import "NSString_SqlExtensions.h"

@interface CPersistentObject ()
@property (readwrite, nonatomic, assign) CPersistentObjectManager *persistentObjectManager;

- (BOOL)columnNames:(NSArray **)outColumnNames values:(NSArray **)outValues includeRowID:(BOOL)inIncludeRowID error:(NSError **)outError;
@end

#pragma mark -

@implementation CPersistentObject

@synthesize persistentObjectManager;
@synthesize rowID;
@synthesize created;
@synthesize modified;

+ (CObjectTranscoder *)objectTranscoder
{
NSAssert(NO, @"Implement objectTranscoder in subclass");
return(NULL);
}

+ (NSString *)tableName
{
NSAssert(NO, @"Implement tableName in subclass");
return(NULL);
}

+ (NSArray *)persistentPropertyNames
{
return([NSArray arrayWithObjects:@"rowID", @"created", @"modified", NULL]);
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
	rowID = -1;
	}
return(self);
}

- (id)initWithPersistenObjectManager:(CPersistentObjectManager *)inManager rowID:(NSInteger)inRowID
{
if ((self = [self init]) != NULL)
	{
	self.persistentObjectManager = inManager;
	self.rowID = inRowID;
	}
return(self);
}

- (void)dealloc
{
self.persistentObjectManager = NULL;
self.created = NULL;
self.modified = NULL;
//
[super dealloc];
}

- (void)release
{
if ([self retainCount] == 2) // 2 == one in cache, one about to be released.
	{
	[self.persistentObjectManager uncachePersistentObject:self];
	}
//
[super release];
}

- (NSString *)description
{
return([NSString stringWithFormat:@"%@ (rowID: %d)", [super description], self.rowID]);
}

#pragma mark -

- (NSString *)persistentIdentifier
{
if (self.rowID == -1)
	return(NULL);
else
	return([NSString stringWithFormat:@"%@/%d", [[self class] tableName], self.rowID]);
}

- (NSInteger)rowID
{
return(rowID);
}

- (void)setRowID:(NSInteger)inRowID
{
if (rowID != inRowID)
	{
	NSAssert(rowID == -1 || inRowID == -1, @"Should not change the rowID of an object that already has a valid rowID (I think)");
	rowID = inRowID;
	if (rowID != -1)
		[self.persistentObjectManager cachePersistentObject:self];
	}
}

#pragma mark -

- (BOOL)write:(NSError **)outError
{
BOOL theResult = NO;
if (self.rowID == -1)
	{
	NSArray *theColumnNames = NULL;
	NSArray *theValues = NULL;
	theResult = [self columnNames:&theColumnNames values:&theValues includeRowID:NO error:outError];
	if (theResult == YES)
		{
		NSString *theExpression = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", [[self class] tableName], [theColumnNames componentsJoinedByString:@","], [theValues componentsJoinedByString:@","]];
		CSqliteDatabase *theDatabase = self.persistentObjectManager.database;
		theResult = [theDatabase executeExpression:theExpression error:outError];
		if (theResult == YES)
			self.rowID = [theDatabase lastInsertRowID];
		}
	}
else
	{
	NSArray *theColumnNames = NULL;
	NSArray *theValues = NULL;
	theResult = [self columnNames:&theColumnNames values:&theValues includeRowID:YES error:outError];
	if (theResult == YES)
		{
		NSMutableArray *theSetClauses = [NSMutableArray arrayWithCapacity:theColumnNames.count];
		NSEnumerator *theValueEnumerator = [theValues objectEnumerator];
		for (NSString *theColumnName in theColumnNames)
			{
			[theSetClauses addObject:[NSString stringWithFormat:@"%@ = %@", theColumnName, [theValueEnumerator nextObject]]];
			}

		NSString *theExpression = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE id = %d", [[self class] tableName], [theSetClauses componentsJoinedByString:@","], self.rowID];
		CSqliteDatabase *theDatabase = self.persistentObjectManager.database;
		theResult = [theDatabase executeExpression:theExpression error:outError];
		}
	}
return(theResult);
}

- (BOOL)delete:(NSError **)outError
{
if (self.rowID == -1)
	return(YES);

[self.persistentObjectManager uncachePersistentObject:self];

NSString *theExpression = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id == %d", [[self class] tableName], self.rowID];
BOOL theResult = [self.persistentObjectManager.database executeExpression:theExpression error:outError];
if (theResult)
	{
	self.rowID = -1;
	}

return(theResult);
}

#pragma mark -

- (BOOL)columnNames:(NSArray **)outColumnNames values:(NSArray **)outValues includeRowID:(BOOL)inIncludeRowID error:(NSError **)outError
{
CObjectTranscoder *theTranscoder = [[self class] objectTranscoder];

NSArray *thePropertyNames = [[self class] persistentPropertyNames];
NSMutableArray *theColumnNames = [NSMutableArray arrayWithCapacity:thePropertyNames.count];
NSMutableArray *theValueStrings = [NSMutableArray arrayWithCapacity:thePropertyNames.count];

for (NSString *thePropertyName in thePropertyNames)
	{
	if (inIncludeRowID == NO && [thePropertyName isEqualToString:@"rowID"])
		continue;

	id theValue = [self valueForKey:thePropertyName];
	if (theValue == NULL)
		theValue = [NSNull null];

	NSString *theValueString = NULL;

	if ([theValue respondsToSelector:@selector(encodedForSql)])
		{
		theValueString = [theValue encodedForSql];
		theValueString = [NSString stringWithFormat:@"'%@'", theValueString];
		}
	else if ([theValue isKindOfClass:[NSNumber class]])
		{
		theValueString = [theValue stringValue];
		}
	else if ([theValue isKindOfClass:[CPersistentObject class]])
		{
		theValueString = [NSString stringWithFormat:@"%d", [theValue rowID]];
		}
	else
		{
		theValueString = [theTranscoder transformObject:theValue toObjectOfClass:[NSString class] error:outError];
		if (theValueString == NULL)
			continue;
		theValueString = [theValueString encodedForSql];
		theValueString = [NSString stringWithFormat:@"'%@'", theValueString];
		}


	NSString *theColumnName = [theTranscoder.invertedPropertyNameMappings objectForKey:thePropertyName];
	if (theColumnName == NULL)
		theColumnName = thePropertyName;
	[theColumnNames addObject:theColumnName]; // TODO property name != column name
	[theValueStrings addObject:theValueString];
	}

if (outColumnNames)
	*outColumnNames = theColumnNames;
if (outValues)
	*outValues = theValueStrings;

return(YES);
}


@end
