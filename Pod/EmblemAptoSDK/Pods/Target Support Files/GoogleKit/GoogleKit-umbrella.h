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

#import "GKGeocoderPlace.h"
#import "GKGeocoderQuery.h"
#import "GKObject.h"
#import "GKPlace.h"
#import "GKPlaceAutocomplete.h"
#import "GKPlaceAutocompleteQuery.h"
#import "GKPlaceDetails.h"
#import "GKPlaceDetailsQuery.h"
#import "GKPlacesNearbySearchQuery.h"
#import "GKPlacesRadarSearchQuery.h"
#import "GKPlacesTextSearchQuery.h"
#import "GKQuery.h"
#import "GoogleKit.h"

FOUNDATION_EXPORT double GoogleKitVersionNumber;
FOUNDATION_EXPORT const unsigned char GoogleKitVersionString[];

