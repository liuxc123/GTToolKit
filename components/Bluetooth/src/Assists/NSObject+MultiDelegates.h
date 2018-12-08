//
//  NSObject+MultiDelegates.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MultiDelegates)

//the delegate object will be added to a weak NSHashTable
-(void)addDelegate:(id)delegate;
-(void)removeDelegate:(id)delegate;
-(NSArray *)delegates;
-(void)emunateDelegatesWithBlock:(void (^)(id delegate, BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
