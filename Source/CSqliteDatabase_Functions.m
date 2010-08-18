//
//  CSqliteDatabase_Functions.m
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

#import "CSqliteDatabase_Functions.h"

static void group_concat_step(sqlite3_context *ctx, int ncols, sqlite3_value **values);
static void group_concat_finalize(sqlite3_context *ctx);
static void word_search_func(sqlite3_context* ctx, int argc, sqlite3_value** argv);

@implementation CSqliteDatabase (CSqliteDatabase_Functions)

- (BOOL)loadFunctions:(NSError **)outError
{
int theResult = sqlite3_create_function(self.sql, "group_concat", 1, SQLITE_UTF8, self.sql, NULL, group_concat_step, group_concat_finalize);    
if (theResult != SQLITE_OK)
	{
	if (outError)
		*outError = [self currentError];
	return(NO);
	}


theResult = sqlite3_create_function(self.sql, "word_search", 2, SQLITE_UTF8, NULL, word_search_func, NULL, NULL);
if (theResult != SQLITE_OK)
	{
	if (outError)
		*outError = [self currentError];
	return(NO);
	}
return(YES);
}

// sqlite group_concat functionality

typedef struct {
    NSMutableArray *values;
} group_concat_ctxt;

static void group_concat_step(sqlite3_context *ctx, int ncols, sqlite3_value **values)
{
    group_concat_ctxt *g;
    const unsigned char *bytes;
    
    g = (group_concat_ctxt *)sqlite3_aggregate_context(ctx, sizeof(group_concat_ctxt));
    
    if (sqlite3_aggregate_count(ctx) == 1)
    {
        g->values = [[NSMutableArray alloc] init];
    }
    
    bytes = sqlite3_value_text(values[0]); 
    [g->values addObject:[NSString stringWithCString:(const char *)bytes encoding:NSUTF8StringEncoding]];
}

static void group_concat_finalize(sqlite3_context *ctx)
{
    group_concat_ctxt *g;
    
    g = (group_concat_ctxt *)sqlite3_aggregate_context(ctx, sizeof(group_concat_ctxt));
    const char *finalString = [[g->values componentsJoinedByString:@", "] UTF8String];
    sqlite3_result_text(ctx, finalString, strlen(finalString), NULL);
    [g->values release];
    g->values = nil;
}

// sqlite word search function

static void word_search_func(sqlite3_context* ctx, int argc, sqlite3_value** argv)
{    
    int wasFound = 0;
    static NSCharacterSet *charSet = nil;
    
    if (!charSet)
    {
        charSet = [[NSCharacterSet characterSetWithCharactersInString:@" "] retain];
    }
    
    const unsigned char *s2 = sqlite3_value_text(argv[1]);
    NSString *string2 = [[NSString alloc] initWithUTF8String:(const char *)s2];
    
    // Borrow the buffer here
    const unsigned char *s1 = sqlite3_value_text(argv[0]);
    NSString *string1 = [[NSString alloc] initWithBytesNoCopy:(void *)s1 length:sqlite3_value_bytes(argv[0]) encoding:NSUTF8StringEncoding freeWhenDone:NO];
    
    // Prepare to be searched!
    int curLoc = 0;
    int maxLoc = [string1 length];
    
    int string2Len = [string2 length];
    while (curLoc < maxLoc)
    {
        NSRange searchRange = NSMakeRange(curLoc, maxLoc - curLoc);
        if (searchRange.length < string2Len)
        {
            break;
        }
        
        NSComparisonResult res = [string1 compare:string2 options:NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch range:NSMakeRange(curLoc, string2Len)];
        
        if (res == 0)
        {
            wasFound = 1;
            break;
        }
        
        // find the next whitespace to start from
        NSRange wsRange = [string1 rangeOfCharacterFromSet:charSet options:NSLiteralSearch range:searchRange];
        if (wsRange.location == NSNotFound)
        {
            break;
        }
        curLoc = wsRange.location + 1;
    }
    
    [string1 release];
    [string2 release];
        
    sqlite3_result_int(ctx, wasFound);
}



@end
