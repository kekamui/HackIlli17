//
//  Texture.mm
//  HackIlli17
//
//  Created by Jonathan Chan on 2017-02-25.
//  Copyright © 2017 Jonathan Chan. All rights reserved.
//

#import "Texture.h"
#import <UIKit/UIKit.h>

@interface Texture ()

- (BOOL)loadImageWithFileName:(NSString *)fileName;
- (BOOL)copyImageDataForOpenGL:(CFDataRef)imageData;

@end

@implementation Texture

- (instancetype)initWithImageFileName:(NSString *)fileName {
    self = [super init];
    
    if (self) {
        if (![self loadImageWithFileName:fileName]) {
            NSLog(@"Failed to load texture image from file %@", fileName);
            self = nil;
        }
    }
    
    return self;
}

- (void)dealloc {
    if (self.pngData) {
        delete [] self.pngData;
    }
}

- (BOOL)loadImageWithFileName:(NSString *)fileName {
    BOOL isSuccessful = NO;
    
     NSString * _Nonnull fullFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    
    UIImage * _Nullable uiImage = [UIImage imageWithContentsOfFile:fullFilePath];
    
    if (uiImage) {
        CGImageRef cgImage = uiImage.CGImage;
        _width = CGImageGetWidth(cgImage);
        _height = CGImageGetHeight(cgImage);
        
        _numberOfChannels = CGImageGetBitsPerPixel(cgImage) / CGImageGetBitsPerComponent(cgImage);
        
        CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
        
        isSuccessful = [self copyImageDataForOpenGL:imageData];
        
        CFRelease(imageData);
    }
    
    return isSuccessful;
}

- (BOOL)copyImageDataForOpenGL:(CFDataRef)imageData {
    if (self.pngData) {
        delete [] self.pngData;
    }
    
    _pngData = new unsigned char[self.width * self.height * self.numberOfChannels];
    const NSInteger rowSize = self.width * self.numberOfChannels;
    const unsigned char * _Nullable pixels = (unsigned char *)CFDataGetBytePtr(imageData);
    
    // Copy the row data from bottom to top
    for (size_t i = 0; i < self.height; ++i) {
        memcpy(_pngData + rowSize * i, pixels + rowSize * (_height - 1 - i), _width * _numberOfChannels);
    }
    
    return YES;
}

@end
