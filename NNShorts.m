//
//  NNShorts.m
//  SDxGuidelines
//
//  Created by Nikita Nagaynik on 07/04/15.
//  Copyright (c) 2015 SnapDx. All rights reserved.
//

#import "NNShorts.h"

#import <objc/runtime.h>

#pragma mark - GCD

@implementation Gcd

+ (void)goAfterSeconds:(NSUInteger)seconds task:(void(^)())task {
    [self goAfterSeconds:seconds queue:dispatch_get_main_queue() task:task];
}

+ (void)goAfterSeconds:(NSUInteger)seconds queue:(dispatch_queue_t)queue task:(void(^)())task {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(time, queue, task);
}

+ (void)goAsyncMain:(void(^)())task {
    [self goAsyncInQueue:dispatch_get_main_queue() task:task];
}

+ (void)goAsyncBack:(void(^)())task {
    [self goAsyncInQueue:dispatch_get_global_queue(0, 0) task:task];
}

+ (void)goAsyncInQueue:(dispatch_queue_t)queue task:(void(^)())task {
    dispatch_async(queue, task);
}

@end


#pragma mark - NSString

@implementation NSString (NNAdditions)

- (NSString *)stringByAddingParams:(NSDictionary *)params {
    if (params.count == 0) {
        return self;
    }
    NSUInteger count = 0;
    NSString *result = [self stringByAppendingString:@"?"];
    for (NSString *key in params) {
        NSString *value = params[key];
        result = [result stringByAppendingFormat:@"%@=%@", key, value];
        if (count + 1 != params.count) {
            result = [result stringByAppendingString:@"&"];
        }
        count++;
    }
    return result;
}

- (BOOL)containsString:(NSString *)string options:(NSStringCompareOptions)options {
    return [self rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound;
}

- (NSArray *)splitOnChars {
    NSMutableArray *chars = [NSMutableArray array];
    for (int i = 0; i < [self length]; i++) {
        [chars addObject:[NSString stringWithFormat:@"%C", [self characterAtIndex:i]]];
    }
    return chars;
}

- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)characterSet {
    return [[self componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
}

@end


#pragma mark - NSArray

@implementation NSArray (NNAdditions)

- (BOOL)containValue:(NSNumber *)number {
    return CFArrayContainsValue ((__bridge CFArrayRef)self,
                                 CFRangeMake(0, self.count),
                                 (CFNumberRef) number);
}

- (NSArray *)filter:(BOOL(^)(id elem))filter {
    NSMutableArray *new = [NSMutableArray arrayWithCapacity:self.count];
    for (id elem in self) {
        if (filter(elem)) {
            [new addObject:elem];
        }
    }
    return [NSArray arrayWithArray:new];
}

- (NSArray *)map:(id(^)(id elem))map {
    NSMutableArray *new = [NSMutableArray arrayWithCapacity:self.count];
    for (id elem in self) {
        [new addObject:map(elem)];
    }
    return [NSArray arrayWithArray:new];
}

- (NSAttributedString *)attributedComponentsJoinedByString:(NSString *)join {
    NSMutableAttributedString *result = [NSMutableAttributedString new];
    for (NSAttributedString *string in self) {
        [result appendAttributedString:string];
        if (self.lastObject != string) {
            [result appendAttributedString:[[NSAttributedString alloc] initWithString:join]];
        }
    }
    return [[NSAttributedString alloc] initWithAttributedString:result];
}

- (void)enumerateObjects:(void (^)(id object))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (void)enumerateObjectsAndIndexes:(void (^)(id object, NSUInteger index))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx);
    }];
}

@end


#pragma mark - UILabel

@implementation UILabel (NNAdditions)

- (NSArray *)getSeparatedLines {
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:10];
    NSCharacterSet *wordSeparators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *words = [self.text componentsSeparatedByCharactersInSet:wordSeparators];
    NSString *whitespaces = [self.text stringByRemovingCharactersInSet:[wordSeparators invertedSet]];
    NSArray *separators = [whitespaces splitOnChars];
    NSString *currentLine = @"";
    NSInteger currentWordIndex = 0;
    
    while (currentWordIndex < words.count) {
        NSString *separator = currentWordIndex > 0 ? separators[currentWordIndex - 1] : @"";
        NSString *currentWord = words[currentWordIndex];
        NSString *prevLine = currentLine;
        NSString *nextLine = [prevLine stringByAppendingFormat:@"%@%@", separator, currentWord];
        
        CGFloat lineWidth = [self getWidthOfString:nextLine];
        
        if (lineWidth > self.width) {
            [lines addObject:prevLine];
            
            if ([self getWidthOfString:currentWord] > self.width) {
                NSArray *wordLines = [self splitWordOnLines:currentWord];
                [lines addObjectsFromArray:wordLines];
                
                currentWord = [wordLines lastObject];
                [lines removeLastObject];
            }
            
            currentLine = currentWord;
        } else {
            currentLine = nextLine;
        }
        
        currentWordIndex++;
    }
    
    [lines addObject:currentLine];
    
    return lines;
}

- (CGFloat)getWidthOfString:(NSString *)string {
    return [string boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                           options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{ NSFontAttributeName:self.font }
                           context:nil].size.width;
}

- (NSArray *)splitWordOnLines:(NSString *)word {
    NSArray *chars = [word splitOnChars];
    
    NSInteger currentCharIndex = 0;
    NSString *currentLine = @"";
    
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:10];
    
    while (currentCharIndex < chars.count) {
        NSString *currentChar = chars[currentCharIndex];
        NSString *prevLine = currentLine;
        NSString *nextLine = [prevLine stringByAppendingFormat:@"%@", currentChar];
        
        CGRect lineRect = [nextLine boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{ NSFontAttributeName:self.font }
                                                 context:nil];

        if (lineRect.size.width > self.width) {
            [lines addObject:prevLine];
            
            currentLine = currentChar;
        } else {
            currentLine = nextLine;
        }
        
        currentCharIndex++;
    }
    
    [lines addObject:currentLine];
    
    return lines;
}

@end


#pragma mark - UIColor

@implementation UIColor (Hex)

+ (UIColor *)colorWithHex:(NSString*)hex
{
    return [self colorWithHex:hex alpha:1.0f];
}

+ (UIColor *)colorWithHex:(NSString*)hex alpha:(CGFloat)alpha
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}

- (CGFloat)R
{
    return CGColorGetComponents(self.CGColor)[0];
}

- (CGFloat)G
{
    return CGColorGetComponents(self.CGColor)[1];
}

- (CGFloat)B
{
    return CGColorGetComponents(self.CGColor)[2];
}

- (CGFloat)alpha
{
    return CGColorGetAlpha(self.CGColor);
}

- (UIColor *)clone
{
    return [UIColor colorWithRed:self.R green:self.G blue:self.B alpha:self.alpha];
}

@end


#pragma mark - UIView

@implementation UIView (NNAdditions)

- (void)setFrameWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setFrameHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setFrameOriginX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setFrameOriginY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setFrameOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}


// Properties

- (void)setSize:(CGSize)size {
    [self setFrameWidth:size.width];
    [self setFrameHeight:size.height];
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setWidth:(CGFloat)width {
    [self setFrameWidth:width];
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    [self setFrameHeight:height];
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setX:(CGFloat)x {
    [self setFrameOriginX:x];
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y {
    [self setFrameOriginY:y];
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (CGPoint)innerCenter {
    return CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
}

- (void)setOrigin:(CGPoint)origin {
    [self setFrameOrigin:origin];
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (CGFloat)right {
    return self.x + self.width;
}

- (CGFloat)bottom {
    return self.y + self.height;
}

@end



