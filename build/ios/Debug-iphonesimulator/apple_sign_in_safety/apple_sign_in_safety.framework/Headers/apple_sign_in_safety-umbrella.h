#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AppleIDButton.h"
#import "AppleIDButtonFactory.h"
#import "AppleSignInPlugin.h"
#import "AuthorizationControllerDelegate.h"
#import "CredentialConverter.h"
#import "NSErrorConverter.h"
#import "Utils.h"

FOUNDATION_EXPORT double apple_sign_in_safetyVersionNumber;
FOUNDATION_EXPORT const unsigned char apple_sign_in_safetyVersionString[];

