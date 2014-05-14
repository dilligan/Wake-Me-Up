//
//  NSString+NSString_AddressFormat.m
//  WakeMeUp
//
//  Created by Milo Gosnell on 4/26/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "NSString+NSString_AddressFormat.h"

@implementation NSString (NSString_AddressFormat)

-(NSString *)formatAddress {
    NSString *address = self;
    address = [address capitalizedString];
    NSArray *directions = @[@"Ne", @"Se", @"Sw", @"Nw"];
    for (NSString *direc in directions) {
        if ([address rangeOfString:direc options:NSCaseInsensitiveSearch].location != NSNotFound) {
            address = [address stringByReplacingOccurrencesOfString:direc withString:[direc uppercaseString]];
        }
    }
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    NSString *pattern = @"[0-9]\\w+";
    NSString *patterntwo = @"\\s(St|Ave|Pl)(\\s|$)";
    
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:nil];
    NSRegularExpression *regextwo = [NSRegularExpression regularExpressionWithPattern:patterntwo options:regexOptions error:nil];
    
    
    NSArray *matches = [regex matchesInString:address options:0 range:NSMakeRange(0, address.length)];
    for (NSTextCheckingResult *re in matches) {
        NSString *numSt = [address substringWithRange:re.range];
        address = [address stringByReplacingCharactersInRange:re.range withString:[numSt lowercaseString]];
    }
    
    NSArray *matchestwo = [regextwo matchesInString:address options:0 range:NSMakeRange(0, address.length)];
    NSMutableString *adMut = [address mutableCopy];
    int count = 0;
    for (NSTextCheckingResult *re in matchestwo) {
        int index = (int)re.range.location + (int)re.range.length;
        [adMut insertString:@"." atIndex:index + (count == 1 ? 1:-1)];
        count++;
    }
    address = [adMut copy];
    return address;
}

@end
