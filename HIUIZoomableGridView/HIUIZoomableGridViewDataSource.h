//
//  HIUIZoomableGridViewDataSource.h
//  HIUIZoomableGridView
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import "HIUIGridTile.h"

@class HIUIZoomableGridView;
@protocol HIUIZoomableGridViewDataSource <NSObject>

- (NSUInteger)numberOfItemsInGridView:(HIUIZoomableGridView*)gridView;
- (UIView<HIUIGridTile>*)gridView:(HIUIZoomableGridView*)gridView tileAtIndexPath:(NSIndexPath*)indexPath;

@optional
- (void)gridView:(HIUIZoomableGridView*)gridView willShowTile:(UIView<HIUIGridTile>*)tile atIndexPath:(NSIndexPath*)indexPath;

@end
