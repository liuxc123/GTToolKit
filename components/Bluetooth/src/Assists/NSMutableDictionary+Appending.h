//
//  NSMutableDictionary+Appending.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (Appending)

- (void)addObject:(nullable id)anObject forKey:(nonnull id <NSCopying>)aKey;
-(void)addUniqueObject:(nullable id)anObject forKey:(nonnull id <NSCopying>)aKey;

- (void)removeObject:(nonnull id)anObject forKey:(nonnull id <NSCopying>)aKey;
- (void)removeAllObjectsForKey:(nonnull id <NSCopying>)aKey;

- (nullable NSArray *)objectsForKey:(nonnull id <NSCopying>)aKey;

@end

NS_ASSUME_NONNULL_END
