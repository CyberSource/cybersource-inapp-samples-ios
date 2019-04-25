//
//  InAppSDKDemoStringValidator.h
//  InAppSDKDemo
//
//  Created by Senthil Kumar Periyasamy on 11/2/15.
//  Copyright (c) 2015 CyberSource, a Visa Company. All rights reserved.
//

@interface NSString (InAppSDKDemoConstants)

+ (NSString *) space;
+ (NSString *) comma;
+ (NSString *) dot;
+ (NSString *) percent;
+ (NSString *) newLine;
+ (NSString *) carriageReturn;
+ (NSString *) qrCodeItemSeparator;
+ (NSString *) addressPartsSeparator;
+ (NSString *) stateAndZipCodeSeparator;
+ (NSString *) underline;
+ (NSString *) passwordDot;

@end

@interface InAppSDKDemoStringValidator : NSObject

//! Method isEmpty:
/*! isEmpty checks if string in \c paramString is correct NSString object and is not empty.
 \param paramString The string to be examined
 \return YES if condition is true
 */
+ (BOOL) isEmpty:(NSString*)paramString;

//! Method isNumber:
/*! isNumber checks if string in \c paramString contains only number characters.
 \param paramString The string to be examined
 \return YES if condition is true
 */
+ (BOOL) isNumber:(NSString *)paramString;

//! Method isAlphanumeric:
/*! isAlphanumeric checks if string in \c paramString contains only alpha characters.
 \param paramString The string to be examined
 \return YES if condition is true
 */
+ (BOOL) isAlphanumeric:(NSString *)paramString;

@end
