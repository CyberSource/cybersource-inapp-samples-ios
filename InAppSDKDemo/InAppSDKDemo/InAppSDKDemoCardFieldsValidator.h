//
//  InAppSDKDemoCardFieldsValidator.h
//  InAppSDKDemo
//
//  Created by Senthil Kumar Periyasamy on 11/2/15.
//  Copyright (c) 2015 CyberSource, a Visa Company. All rights reserved.
//

// minimum and maximum length of card number from http://en.wikipedia.org/wiki/Bank_card_number
static const int kInAppSDKDemoCardNumberCharacterCountMin = 12;
static const int kInAppSDKDemoCardNumberCharacterCountMax = 19;
static const int kInAppSDKDemoCardExpirationMonthMin = 1;
static const int kInAppSDKDemoCardExpirationMonthMax = 12;
static const int kInAppSDKDemoCardExpirationYearMax = 99;
static const int kInAppSDKDemoSecurityCodeCharacterCountMin = 3;
static const int kInAppSDKDemoSecurityCodeCharacterCountMax = 4;
static const int kInAppSDKDemoZipCodeCharacterCountMax = 5;

@interface InAppSDKDemoCardFieldsValidator : NSObject

+ (int) cardExpirationYearMin;

//! basic validation
+ (BOOL) validateCardNumberWithString:(NSString *)aCardNumber;
+ (BOOL) validateMonthWithString:(NSString*)aMonth;
+ (BOOL) validateYearWithString:(NSString*)aYear;
+ (BOOL) validateSecurityCodeWithString:(NSString *)aSecurityCode;
+ (BOOL) validateZipCodeWithString:(NSString *)aZipCode;

//! advance validation
+ (BOOL) validateExpirationDateWithMonthString:(NSString *)aMonth andYearString:(NSString *)aYear;
+ (BOOL) validateCardWithLuhnAlgorithm:(NSString*)cardNumber;

@end
