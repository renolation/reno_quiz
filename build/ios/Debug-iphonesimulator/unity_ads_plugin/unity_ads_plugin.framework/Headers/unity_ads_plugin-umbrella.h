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

#import "UnityAdsPlugin.h"

FOUNDATION_EXPORT double unity_ads_pluginVersionNumber;
FOUNDATION_EXPORT const unsigned char unity_ads_pluginVersionString[];

