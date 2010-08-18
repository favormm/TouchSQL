//
//  CSqliteDatabase.m
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

#import "CSqliteDatabase.h"

#include <sqlite3.h>

#import "CSqliteStatement.h"

#import "CSqliteEnumerator.h"
#import "CSqliteDatabase_Extensions.h"

NSString *TouchSQLErrorDomain = @"TouchSQLErrorDomain";

@interface CSqliteDatabase ()
@property (readwrite, retain) NSString *path;
@property (readwrite, assign) sqlite3 *sql;
@property (readwrite, retain) NSMutableDictionary *userDictionary;
@end

@implementation CSqliteDatabase

@synthesize path;

- (id)initWithPath:(NSString *)inPath
{
if (self = ([self init]))
	{
	self.path = inPath;
	}
return(self);
}

- (id)initInMemory;
{
return([self initWithPath:@":memory:"]);
}

- (void)dealloc
{
self.path = NULL;
self.sql = NULL;
self.userDictionary = NULL;
//
[super dealloc];
}

#pragma mark -

- (BOOL)open:(NSError **)outError
{
if (sql == NULL)
	{
	sqlite3 *theSql = NULL;
	int theResult = sqlite3_open([self.path UTF8String], &theSql);
	if (theResult != SQLITE_OK)
		{
		if (outError)
			*outError = [NSError errorWithDomain:TouchSQLErrorDomain code:theResult userInfo:NULL];
		return(NO);
		}
	self.sql = theSql;
	}
return(YES);
}

- (void)close
{
self.sql = NULL;
}

- (sqlite3 *)sql
{
return(sql);
}

- (void)setSql:(sqlite3 *)inSql
{
if (sql != inSql)
	{
	if (sql != NULL)
		{
		if (sqlite3_close(sql) == SQLITE_BUSY)
			NSLog(@"sqlite3_close() failed with SQLITE_BUSY!");
		sql = NULL;
		}
	sql = inSql;
	}
}



- (NSMutableDictionary *)userDictionary
{
if (userDictionary == NULL)
	userDictionary = [[NSMutableDictionary alloc] init];
return(userDictionary);
}

- (void)setUserDictionary:(NSMutableDictionary *)inUserDictionary
{
if (userDictionary != inUserDictionary)
	{
	[userDictionary autorelease];
	userDictionary = [inUserDictionary retain];
    }
}

#pragma mark -

- (BOOL)begin
{
CSqliteStatement *theStatement = [self.userDictionary objectForKey:@"BEGIN TRANSACTION"];
if (theStatement == NULL)
	{
	theStatement = [[[CSqliteStatement alloc] initWithDatabase:self string:@"BEGIN TRANSACTION"] autorelease];
	[self.userDictionary setObject:theStatement forKey:@"BEGIN TRANSACTION"];
	}
return([theStatement execute:NULL]);
}

- (BOOL)commit
{
CSqliteStatement *theStatement = [self.userDictionary objectForKey:@"COMMIT"];
if (theStatement == NULL)
	{
	theStatement = [[[CSqliteStatement alloc] initWithDatabase:self string:@"COMMIT"] autorelease];
	[self.userDictionary setObject:theStatement forKey:@"COMMIT"];
	}
return([theStatement execute:NULL]);
}

- (BOOL)rollback
{
CSqliteStatement *theStatement = [self.userDictionary objectForKey:@"ROLLBACK"];
if (theStatement == NULL)
	{
	theStatement = [[[CSqliteStatement alloc] initWithDatabase:self string:@"ROLLBACK"] autorelease];
	[self.userDictionary setObject:theStatement forKey:@"ROLLBACK"];
	}
return([theStatement execute:NULL]);
}

- (BOOL)executeExpression:(NSString *)inExpression error:(NSError **)outError
{
NSAssert(self.sql != NULL, @"Database not open.");

int theResult = sqlite3_exec(self.sql, [inExpression UTF8String], NULL, NULL, NULL);
if (theResult != SQLITE_OK)
	{
	if (outError)
        {
		*outError = [self currentError];
        }
	}

return(theResult == SQLITE_OK ? YES : NO);
}

- (NSEnumerator *)enumeratorForExpression:(NSString *)inExpression error:(NSError **)outError
{
#pragma unused (outError)
CSqliteStatement *theStatement = [[[CSqliteStatement alloc] initWithDatabase:self string:inExpression] autorelease];
return([theStatement enumerator]);
}

- (NSArray *)rowsForExpression:(NSString *)inExpression error:(NSError **)outError
{
NSAssert(self.sql != NULL, @"Database not open.");
int theColumnCount = 0;
int cColumnType = 0;
NSInteger cColumnIntegerVal;
NSMutableDictionary *cRowDict = nil;
double cColumnDoubleVal;
const unsigned char *cColumnCStrVal;
const void *cColumnBlobVal;
int cColumnBlobValLen;
id cBoxedColumnValue = nil;
const char* cColumnName;
sqlite3_stmt *pStmt = NULL;
const char *tail = NULL;

int theResult = sqlite3_prepare_v2(self.sql, [inExpression UTF8String], -1, &pStmt, &tail);

if (theResult != SQLITE_OK)
	{
	if (outError)
        {
		*outError = [self currentError];
        }
	return(NULL);
	}
//

NSMutableArray *theRowsArray = [NSMutableArray array];
theColumnCount = sqlite3_column_count(pStmt);
while ((theResult = sqlite3_step(pStmt)) == SQLITE_ROW)
    {
    // Read the next row
    cRowDict = [NSMutableDictionary dictionaryWithCapacity:theColumnCount];

    for (int theColumn = 0; theColumn < theColumnCount; ++theColumn)
        {
            cColumnType = sqlite3_column_type(pStmt, theColumn);
            cColumnName = sqlite3_column_name(pStmt, theColumn);

            switch(cColumnType)
                {
                case SQLITE_INTEGER:
                    cColumnIntegerVal = sqlite3_column_int(pStmt, theColumn);
                    cBoxedColumnValue = [NSNumber numberWithInteger:cColumnIntegerVal];
                    break;
                case SQLITE_FLOAT:
                    cColumnDoubleVal = sqlite3_column_double(pStmt, theColumn);
                    cBoxedColumnValue = [NSNumber numberWithDouble:cColumnDoubleVal];
                    break;
                case SQLITE_BLOB:
                    cColumnBlobVal = sqlite3_column_blob(pStmt, theColumn);
                    cColumnBlobValLen = sqlite3_column_bytes(pStmt, theColumn);
                    cBoxedColumnValue = [NSData dataWithBytes:cColumnBlobVal length:cColumnBlobValLen];
                    break;
                case SQLITE_NULL:
                    cBoxedColumnValue = [NSNull null];
                    break;
                case SQLITE_TEXT:
                    cColumnCStrVal = sqlite3_column_text(pStmt, theColumn);
                    cBoxedColumnValue = [NSString stringWithUTF8String:(const char *)cColumnCStrVal];
                    break;
                }

            [cRowDict setObject:cBoxedColumnValue forKey:[NSString stringWithUTF8String:cColumnName]];
        }

    [theRowsArray addObject:cRowDict];
    }

if ( (theResult != SQLITE_OK) && (theResult != SQLITE_DONE) )
    {
    if (outError)
        {
		*outError = [self currentError];
        }
    }

sqlite3_finalize(pStmt);
pStmt = NULL;

return(theRowsArray);
}

- (NSInteger)lastInsertRowID
{
// TODO 64 bit!??!?!?!
sqlite_int64 theLastRowID = sqlite3_last_insert_rowid(self.sql);
return(theLastRowID);
}

- (NSError *)currentError
{
NSString *theErrorString = [NSString stringWithUTF8String:sqlite3_errmsg(self.sql)];
NSError *theError = [NSError errorWithDomain:TouchSQLErrorDomain code:sqlite3_errcode(self.sql) userInfo:[NSDictionary dictionaryWithObject:theErrorString forKey:NSLocalizedDescriptionKey]];
return(theError);
}

@end
