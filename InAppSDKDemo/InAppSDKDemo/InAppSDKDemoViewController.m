//
//  InAppSDKDemoViewController.m
//  InAppSDKDemo
//
//  Created by Senthil Kumar Periyasamy on 11/2/15.
//  Copyright (c) 2015 CyberSource, a Visa Company. All rights reserved.
//

#import "InAppSDKDemoViewController.h"

#import <InAppSDK/InAppSDK.h>
#import <InAppSDK/InAppSDKCardData.h>
#import <InAppSDK/InAppSDKGatewayProtocol.h>
#import "InAppSDKDemoCardFieldsValidator.h"
#import "InAppSDKDemoStringValidator.h"
#import "InAppSDKDemoSignatureGenerator.h"

//-------WARNING!----------------
// The test merchant credentials are stored here for Demo Purpose.
// The Merchant Credentials sould not be stored here. Just to Demo we have it here.
// Sample Test Merchant Credentials

static NSString* kInAppSDKDemoTestMerchantID = @"test_paymentech_001";
static NSString* kInAppSDKDemoTestUserName = @"test_paymentech_001";

static NSString* kInAppSDKDemoTestTransactionSecretKey = @"r1bngjB1sJIz6HrmFdBubAh46xMVHWwsjw66AzlHksJW3TrAnXNiuoWOjA21zv/7ipfk9L7dPXbQat09UiYcD6l8534vVMKzlL0+os2kFHA1nwgOIct8f6PLJqGw+FnXvYPDllNrFgvtXELoP8JzTDP4HwmWA7XRp4tC0Bsq3pKP1w1iXj2CTXV3T+FtL4nXC3XxkDEVQN8jTTBGniQOGfMlFoVkzkhjOPwMy94fUVS0/PwSZit12gqPJ7/xE07oC5+EV+XGEjXZuEaKtSNJECN51qkcKHpikdaXKJT42oXOFLGLgh/SbcJtgjVWRarbf/P9E27lzuIS8pNX9HKJdQ==";

static NSString* kInAppSDKDemoTestMerchantReferenceNumber = @"InAppSDKDemo_12345";


#define kInAppSDKDemoCreditCardLength 16
#define kInAppSDKDemoCreditCardLengthPlusSpaces (kInAppSDKDemoCreditCardLength + 3)
#define kInAppSDKDemoExpirationLength 4
#define kInAppSDKDemoExpirationMonthLength 2
#define kInAppSDKDemoExpirationYearLength 2
#define kInAppSDKDemoExpirationLengthPlusSlash  kInAppSDKDemoExpirationLength + 1
#define kInAppSDKDemoCVV2Length 4


#define kInAppSDKDemoCreditCardObscureLength (kInAppSDKDemoCreditCardLength - 4)

#define kInAppSDKDemoSpace @" "
#define kInAppSDKDemoSlash @"/"



@interface InAppSDKDemoViewController () <UITextViewDelegate, InAppSDKGatewayDelegate>

@property (nonatomic, strong) NSString* cardNumber;
@property (nonatomic, strong) NSString* cardExpirationMonth;
@property (nonatomic, strong) NSString* cardExpirationYear;
@property (nonatomic, strong) NSString* cardVerificationCode;

@property (nonatomic, strong) NSString *cardNumberBuffer;

@end

@implementation InAppSDKDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUIControlsTagValues];
    [self initializeUIControls];
    [self initializeMembers];
    
    
    self.encryptPaymentButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setUIControlsTagValues
{
    self.cardNumberTextField.tag = 1;
    self.expirationMonthTextField.tag = 2;
    self.expirationYearTextField.tag = 3;
    self.cardVerificationCodeTextField.tag = 4;
    
}

-(UIColor *) darkBlueColor
{
    UIColor *color = [UIColor colorWithRed:51.0f/255.0f green:102.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    
    return color;
}
-(void) initializeUIControls
{
    self.cardNumberTextField.text = @"";
    self.expirationMonthTextField.text = @"";
    self.expirationYearTextField.text = @"";
    self.cardVerificationCodeTextField.text = @"";

}


-(void) initializeMembers
{
    self.cardNumber = nil;
    self.cardExpirationMonth = nil;
    self.cardExpirationYear = nil;
    self.cardVerificationCode = nil;
    self.cardNumberBuffer = @"";
    
}
- (IBAction)encrypt:(id)sender
{
    [self.activityIndicatorInAppSDKDemo startAnimating];
    
    [self performPaymentDataEncryption];
}

-(void) performPaymentDataEncryption
{
    
    //Collect the payment data.
    InAppSDKCardData * cardData = [[InAppSDKCardData alloc] init];
    cardData.accountNumber = self.cardNumber;
    cardData.expirationMonth = self.cardExpirationMonth;
    cardData.expirationYear = self.cardExpirationYear;
    cardData.cvNumber = self.cardVerificationCode;
    
    //Creat Transaction Object.
    InAppSDKTransactionObject * transactionObject = [[InAppSDKTransactionObject alloc]init];
    
    //Assign the card data obtained.
    transactionObject.cardData = cardData;
    
    //Get the Merchant data and credentials and assign.
    transactionObject.merchant = [self getMerchantData];
    
    //Set the End point / Environment. Test or Live
    [InAppSDKSettings sharedInstance].inAppSDKEnvironment = INAPPSDK_ENV_TEST;
    
    //Obtain the gateway sharted instance.
    InAppSDKGateway * gatway = [InAppSDKGateway sharedInstance];
    
    [gatway performPaymentDataEncryption:transactionObject withDelegate:self];
    
}

-(InAppSDKMerchant*) getMerchantData
{
    InAppSDKMerchant *merchantData = [[InAppSDKMerchant alloc] init];
    
    merchantData.userName = kInAppSDKDemoTestUserName;
    merchantData.merchantID = kInAppSDKDemoTestMerchantID;
    merchantData.merchantReferenceCode = kInAppSDKDemoTestMerchantReferenceNumber;
    
    //-------WARNING!----------------
    // This part of the code that generates the Signature is present here only to show as the sample.
    // Signature generation should be done at the Merchant Server.
    
    InAppSDKDemoSignatureGenerator * signatureGenerator = [[InAppSDKDemoSignatureGenerator alloc] init];
    
    NSString * signature = [signatureGenerator generateDEMOSignatureWithMerchantId:kInAppSDKDemoTestMerchantID
                                                          transactionSecretKey:kInAppSDKDemoTestTransactionSecretKey
                                                         merchantReferenceCode:kInAppSDKDemoTestMerchantReferenceNumber ];
    
    NSLog(@"Signature:%@", signature);
    
    merchantData.passwordDigest = signature;
    
    return merchantData;
}

#pragma InAppSDKGateway delegate

-(void) encryptPaymentDataServiceFinishedWithGatewayResponse:(InAppSDKGatewayResponse *)paramResponseData withError:(InAppSDKError *)paramError
{
    NSMutableString* statusMsg = [NSMutableString new];
    
    if(paramError != nil || paramResponseData != nil)
    {
    
        if (paramResponseData)
        {
            [statusMsg appendFormat: @"\nAccepted: %@", paramResponseData.isAccepted ? @"Yes" : @"No"];
        }
        if (paramError)
        {
            [statusMsg appendFormat:@"\nError: %@", paramError.localizedDescription];
        }
        
        if(paramResponseData.isAccepted)
        {
            [statusMsg appendFormat: @"\nEncryptedBlob: %@", paramResponseData.encryptedPayment.data];
        }
        
        NSLog(@"%@", statusMsg);
    }
    
    [self.activityIndicatorInAppSDKDemo stopAnimating];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Encrypt Service Response"
                                                    message:statusMsg
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil];
    [alert show];
    
    //If Needed We can clear the UI Controls and memebers.
    [self initializeUIControls];
    [self initializeMembers];

}



- (IBAction)hideKeyBoard:(id)sender
{
    [self.view endEditing:YES];
}

- (void) formatCardNumber:(UITextField *)textField
{
    NSMutableString *value = [NSMutableString string];
    
    if (textField == self.cardNumberTextField )
    {
        NSInteger length = [self.cardNumberBuffer length];
        
        for (int i = 0; i < length; i++)
        {
            
            // Reveal only the last character.
            if (length <= kInAppSDKDemoCreditCardObscureLength)
            {
                
                if (i == (length - 1))
                {
                    [value appendString:[self.cardNumberBuffer substringWithRange:NSMakeRange(i,1)]];
                }
                else
                {
                    [value appendString:@"●"];
                }
            }
            // Reveal the last 4 characters
            else
            {
                
                if (i < kInAppSDKDemoCreditCardObscureLength)
                {
                    [value appendString:@"●"];
                }
                else
                {
                    [value appendString:[self.cardNumberBuffer substringWithRange:NSMakeRange(i,1)]];
                }
            }
            
            //After 4 characters add a space
            if ((i +1) % 4 == 0 &&  ([value length] < kInAppSDKDemoCreditCardLengthPlusSpaces))
            {
                [value appendString:kInAppSDKDemoSpace];
            }
        }
        
        textField.text =  value;
    }
}

- (BOOL) isMaxLength:(UITextField *)textField
{
    
    if (textField == self.cardNumberTextField && [textField.text length] > kInAppSDKDemoCreditCardLengthPlusSpaces)
    {
        return YES;
    }
    
    if (textField == self.expirationMonthTextField && [textField.text length] > kInAppSDKDemoExpirationMonthLength)
    {
        return YES;
    }
    
    if (textField == self.expirationYearTextField && [textField.text length] > kInAppSDKDemoExpirationYearLength)
    {
        return YES;
    }
    if (textField == self.cardVerificationCodeTextField && [textField.text length] > kInAppSDKDemoCVV2Length)
    {
        return YES;
    }
    return NO;
}

#pragma UITextViewDelegate delegate

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
   return YES;
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    switch (textField.tag)
    {
        case 1:
        {
            if ([string length] > 0)
            {
                if ([self isMaxLength:textField])
                    return NO;
                
                self.cardNumberBuffer  = [NSString stringWithFormat:@"%@%@", self.cardNumberBuffer, string];
            }
            else
            {
                if ([self.cardNumberBuffer length] > 1)
                {
                    self.cardNumberBuffer = [self.cardNumberBuffer substringWithRange:NSMakeRange(0, [self.cardNumberBuffer length] - 1)];
                }
                else
                {
                    self.cardNumberBuffer = @"";
                }
            }
            [self formatCardNumber:textField];
            
            
            return NO;
            
        }
            break;
        case 2:
        {
            if ([string length] > 0)
            {
                if ([self isMaxLength:textField])
                    return NO;
            }
        }
            break;
        case 3:
        {
            if ([string length] > 0)
            {
                if ([self isMaxLength:textField])
                    return NO;
            }
        }
            break;
        case 4:
        {
            if ([string length] > 0)
            {
                if ([self isMaxLength:textField])
                    return NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

-(BOOL) validInputs
{
    BOOL inputsAreOKToProceed = NO;
    
    if (([InAppSDKDemoCardFieldsValidator validateSecurityCodeWithString:self.cardVerificationCodeTextField.text] &&
         [InAppSDKDemoCardFieldsValidator validateExpirationDateWithMonthString:self.expirationMonthTextField.text andYearString:self.expirationYearTextField.text] &&
         [InAppSDKDemoCardFieldsValidator validateCardWithLuhnAlgorithm:self.cardNumberBuffer]))
    {
        inputsAreOKToProceed = YES;
    }
    
    return inputsAreOKToProceed;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
            
        case 1:
        {
            self.cardNumber = self.cardNumberBuffer;
            
            BOOL luhnResult = [InAppSDKDemoCardFieldsValidator validateCardWithLuhnAlgorithm:self.cardNumberBuffer];
            
            if ((luhnResult == NO) || (textField.text.length < kInAppSDKDemoCardNumberCharacterCountMin))
            {
                self.cardNumberTextField.textColor = [UIColor redColor];
            }
            else
            {
                self.cardNumberTextField.textColor = [self darkBlueColor]; //[UIColor greenColor];
            }
            
            
            if ([self validInputs])
            {
                self.encryptPaymentButton.enabled = YES;
            }
            else
            {
                self.encryptPaymentButton.enabled = NO;
            }
        }
        break;
        case 2:
        {
            self.cardExpirationMonth = textField.text;
            
            if ([self.expirationMonthTextField.text length] == 1)
            {
                if ([textField.text isEqualToString:@"0"] == NO)
                {
                    self.expirationMonthTextField.text = [@"0" stringByAppendingString:self.expirationMonthTextField.text];
                }
            }
            
            NSInteger newMonth = [textField.text integerValue];
            
            if ((newMonth >= kInAppSDKDemoCardExpirationMonthMin)  && (newMonth <= kInAppSDKDemoCardExpirationMonthMax))
            {
                self.expirationMonthTextField.textColor = [self darkBlueColor]; //[UIColor greenColor];
                
            }
            else
            {
                self.expirationMonthTextField.textColor = [UIColor redColor];
                
            }
            
            if ([self validInputs])
            {
                self.encryptPaymentButton.enabled = YES;
            }
            else
            {
                self.encryptPaymentButton.enabled = NO;
            }
        }
        break;
        case 3:
        {
            self.cardExpirationYear = textField.text;
            
            NSInteger newYear = [textField.text integerValue];
            if ((newYear >= [InAppSDKDemoCardFieldsValidator cardExpirationYearMin])  && (newYear <= kInAppSDKDemoCardExpirationYearMax))
            {
                self.expirationYearTextField.textColor = [self darkBlueColor]; //[UIColor greenColor];
            }
            else
            {
                self.expirationYearTextField.textColor = [UIColor redColor];
            }
            
            if ([self.expirationYearTextField.text length] == 0)
            {
                return;
            }
            if ([self.expirationMonthTextField.text length] == 0)
            {
                return;
            }
            if ([InAppSDKDemoCardFieldsValidator validateExpirationDateWithMonthString:self.expirationMonthTextField.text andYearString:self.expirationYearTextField.text])
            {
                self.expirationMonthTextField.textColor = [self darkBlueColor];
                self.expirationYearTextField.textColor = [self darkBlueColor];
            }
            else
            {
                self.expirationMonthTextField.textColor = [UIColor redColor];
                self.expirationYearTextField.textColor = [UIColor redColor];
            }
            
            if ([self validInputs])
            {
                self.encryptPaymentButton.enabled = YES;
            }
            else
            {
                self.encryptPaymentButton.enabled = NO;
            }
        }
        break;
        case 4:
        {
            self.cardVerificationCode = textField.text;
            
            if ([InAppSDKDemoCardFieldsValidator validateSecurityCodeWithString:self.cardVerificationCodeTextField.text])
            {
                self.cardVerificationCodeTextField.textColor = [self darkBlueColor];
            }
            else
            {
                self.cardVerificationCodeTextField.textColor = [UIColor redColor];
            }
            
            if ([self validInputs])
            {
                self.encryptPaymentButton.enabled = YES;
            }
            else
            {
                self.encryptPaymentButton.enabled = NO;
            }
            
        }
        break;

        default:
            break;
    }
    
}

-(BOOL) textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.cardNumberTextField)
    {
        self.cardNumberBuffer = [NSString string];
    }
    
    return YES;
}

@end
