//
//  InAppSDKDemoSignatureGenerator.h
//  InAppSDKDemo
//
//  Created by Senthil Kumar Periyasamy on 11/2/15.
//  Copyright (c) 2015 CyberSource, a Visa Company. All rights reserved.
//

@interface InAppSDKDemoSignatureGenerator : NSObject

//-------WARNING!----------------
// This part of the code that generates the Signature is present here only to show as the sample.
// Signature generation should be done at the Merchant Server.

-(NSString*) generateDEMOSignatureWithMerchantId: (NSString *) merchantId
                        transactionSecretKey: (NSString *) transactionSecretKey
                       merchantReferenceCode: (NSString *) merchantReferenceCode;

@end
