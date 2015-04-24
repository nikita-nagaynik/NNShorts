//
//  NNShorts.h
//  SDxGuidelines
//
//  Created by Nikita Nagaynik on 07/04/15.
//  Copyright (c) 2015 SnapDx. All rights reserved.
//

#pragma mark - GCD

@interface Gcd : NSObject

+ (void)goAfterSeconds:(NSUInteger)seconds task:(void(^)())task;
+ (void)goAfterSeconds:(NSUInteger)seconds queue:(dispatch_queue_t)queue task:(void(^)())task;
+ (void)goAsyncMain:(void(^)())task;
+ (void)goAsyncBack:(void(^)())task;
+ (void)goAsyncInQueue:(dispatch_queue_t)queue task:(void(^)())task;

@end


#pragma mark - NSString

@interface NSString (NNAdditions)

- (NSString *)stringByAddingParams:(NSDictionary *)params;
- (BOOL)containsString:(NSString *)aString options:(NSStringCompareOptions)options;

- (NSArray *)splitOnChars;
- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)characterSet;

@end


#pragma mark - NSArray

@interface NSArray (NNAdditions)

- (BOOL)containValue:(NSNumber *)number;

- (NSArray *)filter:(BOOL(^)(id elem))filter;
- (NSArray *)map:(id(^)(id elem))map;

- (NSAttributedString *)attributedComponentsJoinedByString:(NSString *)join;

- (void)enumerateObjects:(void (^)(id object))block;
- (void)enumerateObjectsAndIndexes:(void (^)(id object, NSUInteger index))block;

@end


#pragma mark - UILabel

@interface UILabel (NNAdditions)

- (NSArray *)getSeparatedLines;

@end


#pragma mark - UIColor

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(NSString*)hex;
+ (UIColor *)colorWithHex:(NSString*)hex alpha:(CGFloat)alpha;

- (CGFloat)R;
- (CGFloat)G;
- (CGFloat)B;

@property (nonatomic, assign, readonly) CGFloat alpha;

- (UIColor *)clone;

@end


#pragma mark - UIView

@interface UIView (NNAdditions)

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign, readonly) CGFloat right;
@property (nonatomic, assign, readonly) CGFloat bottom;
@property (nonatomic, assign, readonly) CGPoint innerCenter;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;

@end