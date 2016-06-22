//
//  HIUIZoomableGridViewDelegate.h
//  HIUIZoomableGridView
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HIUIZoomableGridView;
@protocol HIUIZoomableGridViewDelegate <NSObject>

@optional
- (NSInteger)defaultZoomLevelInGridView:(HIUIZoomableGridView*)gridView;
- (void)gridView:(HIUIZoomableGridView*)gridView willSelectItemAtIndexPath:(NSIndexPath*)indexPath;
- (void)gridView:(HIUIZoomableGridView*)gridView didSelectItemAtIndexPath:(NSIndexPath*)indexPath;

- (void)gridView:(HIUIZoomableGridView*)gridView didScroll:(UIScrollView*)scrollView;
- (void)gridView:(HIUIZoomableGridView*)gridView willBeginDragging:(UIScrollView*)scrollView;
- (void)gridView:(HIUIZoomableGridView*)gridView willEndDragging:(UIScrollView*)scrollView targetContentOffset:(CGPoint)targetContentOffset;

- (void)gridView:(HIUIZoomableGridView*)gridView didChangeZoomLevel:(NSInteger)zoomLevel;

@end
