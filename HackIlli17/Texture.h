//
//  Texture.h
//  HackIlli17
//
//  Created by Jonathan Chan on 2017-02-25.
//  Copyright © 2017 Jonathan Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Texture : NSObject

@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;
@property (nonatomic, readonly) NSInteger numberOfChannels;
@property (nonatomic) NSInteger textureId;
@property (nonatomic, readonly) unsigned char * _Nullable pngData;

- (instancetype _Nullable)initWithImageFileName:(NSString * _Nonnull)fileName;

@end
