//
//  InAppSDKDemoViewController.h
//  InAppSDKDemo
//
//  Created by Senthil Kumar Periyasamy on 11/2/15.
//  Copyright (c) 2015 CyberSource, a Visa Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InAppSDKDemoViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *cardNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *expirationMonthTextField;
@property (weak, nonatomic) IBOutlet UITextField *expirationYearTextField;

@property (weak, nonatomic) IBOutlet UITextField *cardVerificationCodeTextField;

@property (weak, nonatomic) IBOutlet UIButton *encryptPaymentButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorInAppSDKDemo;
@property (weak, nonatomic) IBOutlet UITextView *textViewShowResults;
@end
