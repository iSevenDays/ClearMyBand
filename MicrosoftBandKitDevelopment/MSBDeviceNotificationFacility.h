//
//  MSBDeviceNotificationFacility.h
//  Pods
//
//  Created by Anton Sokolchenko on 11.01.17.
//
//

#ifndef MSBDeviceNotificationFacility_h
#define MSBDeviceNotificationFacility_h

#import "MSBStrapp.h"

@interface MSBDeviceNotificationFacility : NSObject

- (void)clearStrapp:(MSBStrapp *)strapp errorRef:(NSError **)errorRef;

@end


#endif /* MSBDeviceNotificationFacility_h */
