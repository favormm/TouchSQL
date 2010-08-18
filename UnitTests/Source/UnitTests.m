//
//  UnitTests.m
//  TouchCode
//
//  Created by Jonathan Wight on 06/07/2005.
//  Copyright 2005 toxicsoftware.com. All rights reserved.
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

#import "UnitTests.h"

#import <TouchSQL/TouchSQL.h>

@implementation UnitTests

#pragma warning TODO implement fixtures/setup/teardown

- (void)testDatabaseCreate;
{
	CSqliteDatabase *db = [[[CSqliteDatabase alloc] initInMemory] autorelease];
	
	BOOL result;
	
	result = [db open:NULL];
	STAssertTrue(result, @"Databases should be openable");
	
	result = [db executeExpression:@"create table foo (name varchar(100))" error:NULL];
	STAssertTrue(result, @"Databases should be createable");
	
//	[db close];
}

- (void)testInsert;
{
	CSqliteDatabase *db = [[[CSqliteDatabase alloc] initInMemory] autorelease];
	[db open:NULL];
	
	BOOL result;
	result = [db executeExpression:@"create table foo (name varchar(100))" error:NULL];
	
	result = [db executeExpression:@"INSERT INTO foo VALUES ('testname')" error:NULL];
	STAssertTrue(result, @"Inserts should work");
	
	NSError *err = NULL;
	NSArray *rows = [db rowsForExpression:@"SELECT * FROM foo WHERE 1" error:&err];
	STAssertNil(err, @"Should be able to select from database");
	
	NSDictionary *row = [rows objectAtIndex:0];
	STAssertNotNil(row, @"Should be able to get a row from the database");
	STAssertEqualObjects([row objectForKey:@"name"], @"testname", @"Should be able to select inserted data");
	
//	[db close];
}

- (void)testEnumerate;
{
	CSqliteDatabase *db = [[[CSqliteDatabase alloc] initInMemory] autorelease];
	[db open:NULL];
	
	[db executeExpression:@"create table foo (name varchar(100))" error:NULL];

	NSMutableSet *names = [NSMutableSet set];
	NSString *name;
	NSString *expression;
	int i;
	for (i = 0; i < 10; i++) {
		name = [NSString stringWithFormat:@"name%d", i];
		[names addObject:name];
		expression = [NSString stringWithFormat:@"INSERT INTO foo VALUES('%@')", name];
		[db executeExpression:expression error:NULL];
	}
	
	NSMutableSet *selectedNames = [NSMutableSet set];
	NSEnumerator *rowEnumerator = [db enumeratorForExpression:@"SELECT * FROM foo WHERE 1" error:NULL];
	for (NSDictionary *row in rowEnumerator) {
		[selectedNames addObject:[row objectForKey:@"name"]];
	}
	STAssertEqualObjects(selectedNames, names, @"Enumeration should get all rows");
	
//	[db close];
}

@end
