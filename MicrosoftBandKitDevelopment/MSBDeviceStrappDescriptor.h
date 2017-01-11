//
//  MSBDeviceStrappDescriptor.h
//  BandTileEvent
//
//  Created by Anton Sokolchenko on 10.01.17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#ifndef MSBDeviceStrappDescriptor_h
#define MSBDeviceStrappDescriptor_h

@interface MSBDeviceStrappDescriptor: NSObject

@property (nonatomic, assign) NSUInteger settingsMask;
@property (nonatomic, assign) NSUInteger tileImageIndex;
@property (nonatomic, assign) NSUInteger displayOrder;
@property (nonatomic, assign) NSUInteger themeColor;
@property (nonatomic, assign) NSUInteger badgeImageIndex;
@property (nonatomic, strong) NSUUID *appID;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSData *ownerIdentifier;
@property (nonatomic, strong) NSDictionary *layouts;

@end

#endif /* MSBDeviceStrappDescriptor_h */
