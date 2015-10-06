//
//  SecurityHelper.m
//  TRN
//
//  Created by Oleg Kasimov on 11/24/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "SecurityHelper.h"
#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>

static NSString *const kCertificateName = @"trn";
static NSString *const kCertificateType = @"der";

@implementation SecurityHelper

#warning - TODO: Test method, DELETE if it is not needed anymore.
+ (NSString *)cerInfo
{
    static SecCertificateRef certificateRef = NULL;
    if (!certificateRef) {
        NSString *path = [[NSBundle mainBundle] pathForResource:kCertificateName ofType:kCertificateType];
        NSData *certData =
        [[NSData alloc] initWithContentsOfFile:path];
        
        CFDataRef certDataRef = (__bridge CFDataRef)certData;
        certificateRef = SecCertificateCreateWithData(kCFAllocatorDefault, certDataRef);
    }
    
    CFStringRef certSummary = SecCertificateCopySubjectSummary(certificateRef);
    NSString *summary = [NSString stringWithString:(__bridge NSString *)certSummary];
    
    CFRelease(certSummary);
    
    return summary;
}


#pragma mark -- Private methods

+ (SecKeyRef)getKey
{
    static SecCertificateRef certificateRef = NULL;
    if (!certificateRef) {
        NSString *path = [[NSBundle mainBundle] pathForResource:kCertificateName ofType:kCertificateType];
        NSData *certData =
        [[NSData alloc] initWithContentsOfFile:path];
        
        CFDataRef certDataRef = (__bridge CFDataRef)certData;
        certificateRef = SecCertificateCreateWithData(NULL, certDataRef);
        OSStatus err = SecItemAdd((__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                             (__bridge id)kSecClassCertificate,  kSecClass,
                                                             certificateRef, kSecValueRef,
                                                             nil
                                                             ],
                                  NULL
                                  );
        if (err != noErr) {
            NSLog(@"SecurityHelper: Could not add certificate");
        }
    }
    
    SecPolicyRef policy = SecPolicyCreateSSL(YES, NULL);
    
    SecTrustRef trust;
    OSStatus status = SecTrustCreateWithCertificates(certificateRef, policy, &trust);
    
    SecTrustResultType trustResult;
    if (status == noErr) {
        status = SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)@[(__bridge id)certificateRef]);
        if (status == noErr) {
             SecTrustEvaluate(trust, &trustResult);
        } else {
            NSLog(@"SecurityHelper: could not add anchor certificates");
        }
    } else {
        NSLog(@"SecurityHelper: Could not load public key");
        return nil;
    }
    
    if (trustResult == kSecTrustResultRecoverableTrustFailure) {
        NSLog(@"SecurityHelper: Could not load public key");
        NSLog(@"Recoverable Failure");
        CFAbsoluteTime trustTime,currentTime,timeIncrement,newTime;
        CFDateRef newDate = NULL;
        
        trustTime = SecTrustGetVerifyTime(trust);
        timeIncrement = 31536000;
        currentTime = CFAbsoluteTimeGetCurrent();
        newTime = currentTime - timeIncrement;
        if (trustTime - newTime){
            newDate = CFDateCreate(NULL, newTime);
            SecTrustSetVerifyDate(trust, newDate);
            SecTrustEvaluate(trust, &trustResult);
            CFRelease(newDate);
        }
        NSLog(@"Trust again:%d", trustResult);
        return nil;
    }
    
    if (policy) {
        CFRelease(policy);
    }
    
    SecKeyRef publicKey = SecTrustCopyPublicKey(trust);
    
    return publicKey;
}


#pragma mark -- Public methods

+ (NSString *)encryptString:(NSString *)aString
{
    SecKeyRef publicKey = [self getKey];
    
    if (!publicKey) {
        return nil;
    }
    
    NSData *dataToEncrypt = [aString dataUsingEncoding:NSUTF8StringEncoding];
    const uint8_t *bytesToEncrypt = dataToEncrypt.bytes;
    
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    NSCAssert(cipherBufferSize > 11, @"block size is too small: %zd", cipherBufferSize);
    
    const size_t inputBlockSize = cipherBufferSize - 11; // since we'll use PKCS1 padding
    uint8_t *cipherBuffer = (uint8_t *) malloc(sizeof(uint8_t) * cipherBufferSize);
    
    NSMutableData *accumulator = [[NSMutableData alloc] init];
    
    for (size_t block = 0; block * inputBlockSize < dataToEncrypt.length; block++) {
        size_t blockOffset = block * inputBlockSize;
        const uint8_t *chunkToEncrypt = (bytesToEncrypt + block * inputBlockSize);
        const size_t remainingSize = dataToEncrypt.length - blockOffset;
        const size_t subsize = remainingSize < inputBlockSize ? remainingSize : inputBlockSize;
        
        size_t actualOutputSize = cipherBufferSize;
        OSStatus status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, chunkToEncrypt, subsize, cipherBuffer, &actualOutputSize);
        
        if (status != noErr) {
            NSLog(@"Cannot encrypt data, last SecKeyEncrypt status: %ld", (long)status);
            free(cipherBuffer);
            return nil;
        }
        
        [accumulator appendBytes:cipherBuffer length:actualOutputSize];
    }
    
    NSString *encodedBase64String = [accumulator base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    free(cipherBuffer);
    free(publicKey);
    
    return encodedBase64String;
}

+ (NSString *)decryptData:(NSData *)data
{
    static SecKeyRef privateKey = NULL;
    if (!privateKey) {
        
    }
//    OSStatus status = noErr;
    
    size_t cipherBufferSize = [data length];
    uint8_t *cipherBuffer = (uint8_t *)[data bytes];
    
    size_t plainBufferSize;
    uint8_t *plainBuffer;
    
    plainBufferSize = SecKeyGetBlockSize(privateKey);
    plainBuffer = malloc(plainBufferSize);
    
    if (plainBufferSize < cipherBufferSize) {
        free(plainBuffer);
        printf("Could not decrypt.  Packet too large.\n");
        return nil;
    }

    SecKeyDecrypt(privateKey,
                  kSecPaddingPKCS1,
                  cipherBuffer,
                  cipherBufferSize,
                  plainBuffer,
                  &plainBufferSize);
    
    if (privateKey) {
       CFRelease(privateKey);
    }
    
    NSString * s = [NSString stringWithUTF8String:(char *)plainBuffer];
    free(plainBuffer);
    return s;
}

@end
