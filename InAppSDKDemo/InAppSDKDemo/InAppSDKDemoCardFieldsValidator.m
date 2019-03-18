//
//  InAppSDKDemoCardFieldsValidator.m
//  InAppSDKDemo
//
//  Created by Senthil Kumar Periyasamy on 11/2/15.
//  Copyright (c) 2015 CyberSource, a Visa Company. All rights reserved.
//

#import "InAppSDKDemoCardFieldsValidator.h"
#import "InAppSDKDemoStringValidator.h"


@implementation InAppSDKDemoCardFieldsValidator

+ (int) cardExpirationYearMin
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitYear fromDate:[NSDate date]];
    return [components year]%100;
}

//!--------------------------------------------- basic validation -----------------------------------
+ (BOOL) validateCardNumberWithString:(NSString *)aCardNumber
{
    BOOL result = NO;
    
    aCardNumber = [aCardNumber stringByReplacingOccurrencesOfString:[NSString space] withString:[NSString string]];
    if ([InAppSDKDemoStringValidator isNumber:aCardNumber])
    {
        if ((aCardNumber.length >= kInAppSDKDemoCardNumberCharacterCountMin) &&
            (aCardNumber.length <= kInAppSDKDemoCardNumberCharacterCountMax))
        {
            result = YES;
        }
    }
    
    return result;
}

+ (BOOL) validateMonthWithString:(NSString*)aMonth
{
    BOOL result = NO;
    
    if ([InAppSDKDemoStringValidator isNumber:aMonth])
    {
        NSInteger monthNumber = [aMonth integerValue];
        
        if ((monthNumber >= kInAppSDKDemoCardExpirationMonthMin) &&
            (monthNumber <= kInAppSDKDemoCardExpirationMonthMax))
        {
            result = YES;
        }
    }
    
    return result;
}

+ (BOOL) validateYearWithString:(NSString*)aYear
{
    BOOL result = NO;
    
    if ([InAppSDKDemoStringValidator isNumber:aYear])
    {
        NSInteger yearNumber = [aYear integerValue];
        
        if ((yearNumber >= [self cardExpirationYearMin])  &&
            (yearNumber <= kInAppSDKDemoCardExpirationYearMax))
        {
            result = YES;
        }
    }
    
    return result;
}


+ (BOOL) validateSecurityCodeWithString:(NSString *)aSecurityCode
{
    BOOL result = NO;
    
    if ([InAppSDKDemoStringValidator isNumber:aSecurityCode])
    {
        if ((aSecurityCode.length == kInAppSDKDemoSecurityCodeCharacterCountMin)  ||
            (aSecurityCode.length == kInAppSDKDemoSecurityCodeCharacterCountMax))
        {
            result = YES;
        }
    }
    
    return result;
}

+ (BOOL) validateZipCodeWithString:(NSString *)aZipCode
{
    BOOL result = NO;
    
    if ([InAppSDKDemoStringValidator isNumber:aZipCode])
    {
        
        if (aZipCode.length == kInAppSDKDemoZipCodeCharacterCountMax)
        {
            result = YES;
        }
    }
    
    return result;
}

//!--------------------------------------------- advance validation -----------------------------------

+ (BOOL) validateCardWithLuhnAlgorithm:(NSString*)cardNumber
{
    BOOL result = NO;
    
    cardNumber = [cardNumber stringByReplacingOccurrencesOfString:[NSString space] withString:[NSString string]];
    
    if ([cardNumber length])
    {
        NSInteger elementsCount = [cardNumber length];
        
        NSInteger arrayOfIntegers[elementsCount];
        
        for (NSInteger index = 0; index < elementsCount; index++)
        {
            NSString * singleCharacter = [NSString stringWithFormat:@"%C",[cardNumber characterAtIndex:index]];
            arrayOfIntegers[[cardNumber length] - 1 - index] = [singleCharacter intValue];
        }
        
        for (NSInteger index = 0; index < elementsCount; index++)
        {
            if (index % 2 != 0)
            {
                arrayOfIntegers[index] *= 2;
            }
        }
        
        int theSum = 0;
        for (NSInteger index = 0; index < elementsCount; index++)
        {
            if (arrayOfIntegers[index] > 9)
            {
                theSum += arrayOfIntegers[index] / 10;
                theSum += arrayOfIntegers[index] % 10;
            }
            else
            {
                theSum += arrayOfIntegers[index];
            }
        }
        
        if ((theSum != 0) && ((theSum % 10) == 0))
        {
            result = YES;
        }
    }
    
    return result;
}

+ (BOOL) validateExpirationDateWithMonthString:(NSString *)aMonth andYearString:(NSString *)aYear {
    BOOL result = NO;
    
    if ([self validateMonthWithString:aMonth] && [self validateYearWithString:aYear]) {
        //---  now date
        NSDate* nowDate = [NSDate date];
        
        //--- date expiration
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:1];
        [comps setMonth:[aMonth integerValue]];
        [comps setYear:2000+[aYear integerValue]];
        NSDate *expirationDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        //--- next month after expiration
        NSDateComponents* monthComponents = [[NSDateComponents alloc] init];
        [monthComponents setMonth:1];
        NSDate* nextDayAfterExpirationDate = [[NSCalendar currentCalendar] dateByAddingComponents:monthComponents toDate:expirationDate options:0];
        
        NSTimeInterval timeIntervalSinceDate = [nextDayAfterExpirationDate timeIntervalSinceDate:nowDate];
        result = (timeIntervalSinceDate > 0);
    }
    
    return result;
}


@end
