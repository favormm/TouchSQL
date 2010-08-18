//
//  CSqliteDatabase.h
//  TouchCode
//
//  Created by Jonathan Wight on Tue Apr 27 2004.
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

#import <Foundation/Foundation.h>

#import <sqlite3.h>

extern NSString *TouchSQLErrorDomain /* = @"TouchSQLErrorDomain" */;

@class CSqliteStatement;

@interface CSqliteDatabase : NSObject {
	NSString *path;
	sqlite3 *sql;
	NSMutableDictionary *userDictionary;
}

@property (readonly, retain) NSString *path;
@property (readonly, assign) sqlite3 *sql;
@property (readonly, retain) NSMutableDictionary *userDictionary;

- (id)initWithPath:(NSString *)inPath;
- (id)initInMemory;

- (BOOL)open:(NSError **)outError;
- (void)close;

- (BOOL)begin;
- (BOOL)commit;
- (BOOL)rollback;

- (BOOL)executeExpression:(NSString *)inExpression error:(NSError **)outError;
- (NSEnumerator *)enumeratorForExpression:(NSString *)inExpression error:(NSError **)outError;
- (NSArray *)rowsForExpression:(NSString *)inExpression error:(NSError **)outError;

- (NSInteger)lastInsertRowID;
- (NSError *)currentError;

@end
