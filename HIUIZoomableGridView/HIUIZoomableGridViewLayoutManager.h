//
//  HIUIZoomableGridViewLayoutManager.h
//  HIUIZoomableGridView
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HIUIZoomableGridViewLayoutManager <NSObject>

@property (nonatomic, assign, readonly) NSInteger minimumZoomLevel;
@property (nonatomic, assign, readonly) NSInteger maximumZoomLevel;
@property (nonatomic, assign, readonly) UIEdgeInsets contentInset;

- (CGSize)cellSizeWithZoomLevel:(NSInteger)zoomLevel;
- (CGSize)tileSizeWithZoomLevel:(NSInteger)zoomLevel;

@end
