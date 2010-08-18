//
//  CPersistentObject.h
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

@class CPersistentObjectManager;
@class CObjectTranscoder;

@interface CPersistentObject : NSObject {
	CPersistentObjectManager *persistentObjectManager;
	NSInteger rowID;
	NSDate *created;
	NSDate *modified;
}

@property (readonly, nonatomic, assign) CPersistentObjectManager *persistentObjectManager;
@property (readonly, nonatomic, retain) NSString *persistentIdentifier;
@property (readwrite, nonatomic, assign) NSInteger rowID;
@property (readwrite, nonatomic, retain) NSDate *created;
@property (readwrite, nonatomic, retain) NSDate *modified;

+ (CObjectTranscoder *)objectTranscoder;
+ (NSString *)tableName; // This could be moved to objectTranscoder?
+ (NSArray *)persistentPropertyNames; // This could be moved to object transcoder?

- (id)initWithPersistenObjectManager:(CPersistentObjectManager *)inManager rowID:(NSInteger)inRowID;

- (BOOL)write:(NSError **)outError;

- (BOOL)delete:(NSError **)outError;

@end
