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

#import "JFMinimalNotification.h"
#import "JFMinimalNotificationArt.h"
#import "NSInvocation+Constructors.h"
#import "UIColor+JFMinimalNotificationColors.h"
#import "UIView+Round.h"

FOUNDATION_EXPORT double JFMinimalNotificationsVersionNumber;
FOUNDATION_EXPORT const unsigned char JFMinimalNotificationsVersionString[];

