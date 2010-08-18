//
//  CSqliteStatement.h
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

#import <Foundation/Foundation.h>

#include <sqlite3.h>

@class CSqliteDatabase;

@interface CSqliteStatement : NSObject <NSFastEnumeration> {
	CSqliteDatabase *database;
	NSString *statementString;
	sqlite3_stmt *statement;
}

@property (readonly, nonatomic, assign) CSqliteDatabase *database;
@property (readonly, nonatomic, copy) NSString *statementString;
@property (readonly, nonatomic, assign) sqlite3_stmt *statement;

+ (CSqliteStatement *)statementWithDatabase:(CSqliteDatabase *)inDatabase format:(NSString *)inFormat, ...;

- (id)initWithDatabase:(CSqliteDatabase *)inDatabase string:(NSString *)inString;

- (BOOL)prepare:(NSError **)outError;

- (BOOL)reset:(NSError **)outError;

- (BOOL)clearBindings:(NSError **)outError;
- (BOOL)bindValue:(id)inValue toBinding:(NSString *)inBinding transientValue:(BOOL)inTransientValues error:(NSError **)outError;
- (BOOL)bindValues:(NSDictionary *)inValues transientValues:(BOOL)inTransientValues error:(NSError **)outError;

- (BOOL)execute:(NSError **)outError;

- (BOOL)step:(NSError **)outError;

- (NSInteger)columnCount:(NSError **)outError;
- (NSString *)columnNameAtIndex:(NSInteger)inIndex error:(NSError **)outError;
- (id)columnValueAtIndex:(NSInteger)inIndex error:(NSError **)outError;

- (NSArray *)columnNames:(NSError **)outError;

- (NSArray *)row:(NSError **)outError;
- (NSDictionary *)rowDictionary:(NSError **)outError;

- (NSArray *)rows:(NSError **)outError;
- (NSArray *)rowDictionaries:(NSError **)outError;

- (NSEnumerator *)enumerator;

@end
