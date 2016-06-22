//
//  SampleLayoutManager.m
//  HIUIZoomableGridViewSample
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import "SampleLayoutManager.h"

@implementation SampleLayoutManager

@synthesize maximumZoomLevel=_maximumZoomLevel, minimumZoomLevel=_minimumZoomLevel;
@synthesize contentInset=_contentInset;

#define TILE_WIDTH_HEIGHT_RATIO             1.328f
#define TILE_RATIO_IN_CELL                  0.98f
#define TILE_PADDING_INCELL                 2.f

- (instancetype)init {
    self = [super init];
    if (self) {
        _minimumZoomLevel = 1;
        _maximumZoomLevel = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 5 : 3);
        
        _contentInset = UIEdgeInsetsMake(TILE_PADDING_INCELL, TILE_PADDING_INCELL, TILE_PADDING_INCELL, TILE_PADDING_INCELL);
        
    }
    
    return self;
}

#pragma mark - HIUIZoomableGridTileLayoutManager protocols

- (CGSize)cellSizeWithZoomLevel:(NSInteger)zoomLevel {
    UIWindow* window = [[[UIApplication sharedApplication] windows] lastObject];
    CGFloat width = floorf((CGRectGetWidth(window.bounds) - (self.contentInset.left + self.contentInset.right)) / (self.maximumZoomLevel - zoomLevel + 2));
    
    return CGSizeMake(width, floorf(width * TILE_WIDTH_HEIGHT_RATIO));
}

- (CGSize)tileSizeWithZoomLevel:(NSInteger)zoomLevel {
    CGSize _cellSize = [self cellSizeWithZoomLevel:zoomLevel];
    
    CGFloat width = floorf(_cellSize.width - (2 * TILE_PADDING_INCELL));
    
    return CGSizeMake(width, floorf(width * TILE_WIDTH_HEIGHT_RATIO));
}


@end
