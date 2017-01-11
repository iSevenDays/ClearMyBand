//
//  MSBTileUtility.h
//  Pods
//
//  Created by Anton Sokolchenko on 11.01.17.
//
//

#ifndef MSBTileUtility_h
#define MSBTileUtility_h

#import "MSBDeviceNotificationFacility.h"
#import "MSBStrapp.h"

@interface MSBTileUtility : NSObject

@property (nonatomic, weak) MSBDeviceNotificationFacility *notificationFacility;

- (void)clearStrapp:(NSUUID *)strappUUID completion:(void(^)(NSError *error))completion;

@end

#endif /* MSBTileUtility_h */
