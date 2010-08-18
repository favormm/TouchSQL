//
//  NSData_SqlExtensions.m
//  TouchCode
//
//  Created by Ian Baird on 3/30/08.
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

#import "NSData_SqlExtensions.h"

#import "CSqliteDatabase.h"

@implementation NSData (NSData_SqlExtensions)

- (BOOL)writeToDatabase:(CSqliteDatabase *)database table:(NSString *)table field:(NSString *)field whereClause:(NSString *)whereClause
{
    BOOL success = NO;
    sqlite3_stmt *pStmt;
    const char *zTail;
    NSString *sqlExpression = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ? WHERE %@", table, field, whereClause]; 
    int resultCode = sqlite3_prepare_v2([database sql], [sqlExpression UTF8String], -1, &pStmt, &zTail);
    if (resultCode == SQLITE_OK)
    {
        resultCode = sqlite3_bind_blob(pStmt, 1, [self bytes], [self length], SQLITE_STATIC);
        if(resultCode == SQLITE_OK)
        {
            success = (sqlite3_step(pStmt) == SQLITE_DONE);
        }
        sqlite3_finalize(pStmt);
    }
    return success;
}

@end
