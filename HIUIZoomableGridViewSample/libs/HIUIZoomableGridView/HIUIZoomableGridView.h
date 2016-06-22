//
//  HIUIZoomableGridView.h
//  HIUIZoomableGridView
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HIUIZoomableGridViewDataSource.h"
#import "HIUIZoomableGridViewDelegate.h"
#import "HIUIZoomableGridViewLayoutManager.h"
#import "HIUIZoomableGridViewDataSource.h"
#import "HIUIScrollView.h"

@interface HIUIZoomableGridView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    HIUIScrollView* _scrollView;
    UIView* _contentView;
    id<HIUIZoomableGridViewLayoutManager> _layoutManager;
    
    NSMutableArray* _itemData;
    NSMutableDictionary* _reuseQueue;
    NSInteger _reuseCap;
    
    NSUInteger _zoomLevel;
    
    BOOL _shouldConstructTiles;
    
    UILongPressGestureRecognizer* _tapRec;
}

@property (nonatomic, assign) id<HIUIZoomableGridViewDataSource> dataSource;
@property (nonatomic, assign) id<HIUIZoomableGridViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIScrollView* scrollView;
@property (nonatomic, strong, readonly) UIView* contentView;
@property (nonatomic, strong, readonly) id<HIUIZoomableGridViewLayoutManager> layoutManager;

@property (nonatomic, strong, readonly) NSArray* visibleTiles;

@property (nonatomic, assign, readonly) NSUInteger zoomLevel;
@property (nonatomic, assign) BOOL animating;

@property (nonatomic, assign) BOOL zoomOnItemSelected;

- (id)initWithFrame:(CGRect)frame layoutManager:(id<HIUIZoomableGridViewLayoutManager>)layoutManager;

- (void)reloadData;
- (void)reloadItemAtIndexPath:(NSIndexPath*)indexPath;

- (void)loadVisibleTiles;
- (void)releaseVisibleTiles;

- (void)zoomOutFromSelectedItemWithAnimated:(BOOL)animated;

- (void)zoomOut;
- (void)zoomIn;

- (void)startTileAnimation;
- (void)stopTileAnimation;

/*
 *  Editing
 */
- (UIView<HIUIGridTile>*)dequeueReusableTileWithIdentifier:(NSString*)identifier;
- (UIView<HIUIGridTile>*)tileAtIndexPath:(NSIndexPath*)indexPath;

- (void)removeItemAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;
- (void)insertItemAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

- (void)removeItemsAtIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated;
- (void)insertItemsAtIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated;

/*
 *  Independent steps
 */
- (void)removeItemAtIndexPath:(NSIndexPath*)indexPath;
- (void)insertItemAtIndexPath:(NSIndexPath*)indexPath;

- (void)removeItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths;

- (void)relayoutItemAnimated:(BOOL)animated;

@end
