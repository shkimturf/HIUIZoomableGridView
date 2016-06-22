//
//  HIUIZoomableGridView.m
//  HIUIZoomableGridView
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import "HIUIZoomableGridView.h"

#import "HIGridItem.h"
#import "HIUIZoomableGridViewCommon.h"

@interface HIUIZoomableGridView ()
@property (atomic, assign) BOOL shouldLayoutByScroll;
@property (atomic, assign) BOOL shouldBackToNormalZoomLevel;
@property (atomic, assign) BOOL shouldSendSelectDelegate;
@property (nonatomic, assign, readonly) NSInteger reuseCap;
@property (nonatomic, strong) NSIndexPath* highlightedIndexPath;
@end

@implementation HIUIZoomableGridView
@synthesize scrollView=_scrollView, contentView=_contentView, layoutManager=_layoutManager;
@synthesize reuseCap=_reuseCap, zoomLevel=_zoomLevel;

- (id)initWithFrame:(CGRect)frame layoutManager:(id<HIUIZoomableGridViewLayoutManager>)layoutManager {
    self = [super initWithFrame:frame];
    if (self) {
        _itemData = [[NSMutableArray alloc] init];
        
        _reuseQueue = [[NSMutableDictionary alloc] init];
        _reuseCap = DEFAULT_REUSE_QUEUE_CAP;
        
        _scrollView = [[HIUIScrollView alloc] initWithFrame:CGRectMake(layoutManager.contentInset.left, layoutManager.contentInset.top, CGRectGetWidth(self.bounds) - (layoutManager.contentInset.left + layoutManager.contentInset.right), CGRectGetHeight(self.bounds) - (layoutManager.contentInset.top + layoutManager.contentInset.bottom))];
        self.scrollView.delegate = self;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.alwaysBounceVertical = YES;
        _scrollView.zoomEnable = YES;
        self.scrollView.bouncesZoom = YES;
        self.scrollView.minimumZoomScale = 1.f;
        self.scrollView.maximumZoomScale = DEFAULT_MAXIMUM_ZOOM_SCALE;
        
        self.shouldBackToNormalZoomLevel = YES;
        
        [self addSubview:self.scrollView];
        
        _contentView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
        [self.scrollView addSubview:_contentView];
        
        _layoutManager = layoutManager;
        
        _zoomLevel = NSNotFound;
        _shouldConstructTiles = YES;
        self.shouldLayoutByScroll = YES;
        
        [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        
        _tapRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onTapInView:)];
        _tapRec.minimumPressDuration = DEFAULT_PRESS_DURATION;
        _tapRec.delegate = self;
        [self addGestureRecognizer:_tapRec];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    NSAssert(NO, @"Not supports. Use initWithFrame:layoutManager");
    return nil;
}

- (void)awakeFromNib {
    NSAssert(NO, @"Not supports. Use initWithFrame:layoutManager");
}

- (void)dealloc {
    self.animating = NO;
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - properties

- (NSArray *)visibleTiles {
    NSMutableArray* tiles = [[NSMutableArray alloc] init];
    [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ( [obj conformsToProtocol:@protocol(HIUIGridTile)] ) {
            [tiles addObject:obj];
        }
    }];
    
    return [NSArray arrayWithArray:tiles];
}

#pragma mark - view interfaces

- (void)reloadData {
    self.scrollView.contentOffset = CGPointZero;
    _shouldConstructTiles = YES;
    
    [self setNeedsLayout];
}

- (void)reloadItemAtIndexPath:(NSIndexPath *)indexPath {
    HIGridItem* item = [_itemData objectAtIndex:indexPath.row];
    [self _enqueueReusableTile:item.tile];
    item.tile = nil;
    
    [self _loadItemAtIndexPath:indexPath startAnimation:self.animating];
}

- (void)loadVisibleTiles {
    [self _layoutVisibleTilesWithReloading:NO];
}

- (void)releaseVisibleTiles {
    [_itemData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HIGridItem* item = obj;
        [self _enqueueReusableTile:item.tile];
        item.tile = nil;
    }];
}

- (void)zoomOutFromSelectedItemWithAnimated:(BOOL)animated {
    NSAssert(nil != self.highlightedIndexPath, @"Invalid status.");
    
    self.scrollView.maximumZoomScale = DEFAULT_MAXIMUM_ZOOM_SCALE;
    [self.scrollView setZoomScale:1.f animated:animated];
    
    self.highlightedIndexPath = nil;
    self.shouldBackToNormalZoomLevel = YES;
    
    if ( NO == animated ) {
        self.shouldLayoutByScroll = YES;
        _tapRec.enabled = YES;
        _scrollView.zoomEnable = YES;
        self.scrollView.clipsToBounds = YES;
    } else {
        self.animating = YES;
    }
}

- (void)setAnimating:(BOOL)animating {
    if ( animating == self.animating ) {
        return;
    }
    
    _animating = animating;
    
    if ( self.animating ) {
        [self startTileAnimation];
    } else {
        [self stopTileAnimation];
    }
}

- (void)startTileAnimation {
    [self.visibleTiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView<HIUIGridTile>* tile = obj;
        if ( [tile respondsToSelector:@selector(startAnimation)] ) {
            [tile startAnimation];
        }
    }];
}

- (void)stopTileAnimation {
    [self.visibleTiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView<HIUIGridTile>* tile = obj;
        if ( [tile respondsToSelector:@selector(stopAnimation)] ) {
            [tile stopAnimation];
            //            tile.transform = CGAffineTransformIdentity;
        }
    }];
}

- (UIView<HIUIGridTile>*)tileAtIndexPath:(NSIndexPath*)indexPath {
    HIGridItem* item = [_itemData objectAtIndex:indexPath.row];
    return item.tile;
}

- (void)zoomOut {
    if ( self.zoomLevel == self.layoutManager.minimumZoomLevel ) {
        return;
    }
    
    _zoomLevel--;
    
    [self _relayoutByZomming];
}

- (void)zoomIn {
    if ( self.zoomLevel == self.layoutManager.maximumZoomLevel ) {
        return;
    }
    
    _zoomLevel++;
    
    [self _relayoutByZomming];
}

#pragma mark - observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // edit contentview frame when contentsize changed
    self.contentView.frame = CGRectMake(0.f, 0.f, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
}

#pragma mark - reuse

- (UIView<HIUIGridTile>*)dequeueReusableTileWithIdentifier:(NSString*)identifier {
    NSMutableArray* stack = [_reuseQueue objectForKey:identifier];
    UIView<HIUIGridTile>* tile = [stack lastObject];
    if ( nil != tile ) {
        [stack removeLastObject];
    }
    
    return tile;
}

- (void)_enqueueReusableTile:(UIView<HIUIGridTile>*)tile {
    if ( nil == tile ) {
        return;
    }
    
    [tile removeFromSuperview];
    
    // reset itemView to re-use
    tile.tag = DEFAULT_UNKNOWN_ITEM_TAG;
    if ( [tile respondsToSelector:@selector(stopAnimation)] ) {
        [tile stopAnimation];
    }
    if ( [tile respondsToSelector:@selector(initiateTile)] ) {
        [tile initiateTile];
    }
    
    NSString* identifier = [[tile class] reuseIdentifier];
    NSMutableArray* stack = [_reuseQueue objectForKey:identifier];
    if ( nil == stack ) {
        stack = [[NSMutableArray alloc] initWithCapacity:self.reuseCap];
        [_reuseQueue setObject:stack forKey:identifier];
    }
    
    if ( stack.count < _reuseCap ) {
        [stack addObject:tile];
    }
}

#pragma mark - editing

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self removeItemAtIndexPath:indexPath];
    [self relayoutItemAnimated:animated];
}

- (void)insertItemAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated {
    [self insertItemAtIndexPath:indexPath];
    [self relayoutItemAnimated:animated];
}

- (void)removeItemsAtIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated {
    [self removeItemsAtIndexPaths:indexPaths];
    [self relayoutItemAnimated:animated];
}

- (void)insertItemsAtIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated {
    [self insertItemsAtIndexPaths:indexPaths];
    [self relayoutItemAnimated:animated];
}

#pragma mark - independent steps

- (void)removeItemAtIndexPath:(NSIndexPath*)indexPath {
    HIGridItem* item = [_itemData objectAtIndex:indexPath.row];
    
    [self _enqueueReusableTile:item.tile];
    item.tile = nil;
    
    [_itemData removeObjectAtIndex:indexPath.row];
}

- (void)insertItemAtIndexPath:(NSIndexPath*)indexPath {
    HIGridItem* item = [[HIGridItem alloc] init];
    item.frame = [self _cellFrameAtIndexPath:indexPath];
    [_itemData insertObject:item atIndex:indexPath.row];
}

- (void)removeItemsAtIndexPaths:(NSArray *)indexPaths {
    NSMutableIndexSet* indexSet = [[NSMutableIndexSet alloc] init];
    [indexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath* indexPath = obj;
        HIGridItem* item = [_itemData objectAtIndex:indexPath.row];
        
        [self _enqueueReusableTile:item.tile];
        item.tile = nil;
        
        [indexSet addIndex:indexPath.row];
    }];
    
    [_itemData removeObjectsAtIndexes:indexSet];
}

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths {
    [indexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath* indexPath = obj;
        HIGridItem* item = [[HIGridItem alloc] init];
        item.frame = [self _cellFrameAtIndexPath:indexPath];
        [_itemData insertObject:item atIndex:indexPath.row];
    }];
}

- (void)relayoutItemAnimated:(BOOL)animated {
    [self _relayoutItems];
    if ( animated ) {
        self.animating = NO;
        [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION delay:0.f options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowAnimatedContent) animations:^{
            [self loadVisibleTiles];
        } completion:^(BOOL finished) {
            self.animating = YES;
        }];
    } else {
        self.animating = NO;
        [self loadVisibleTiles];
        self.animating = YES;
    }
}


#pragma mark - UIGestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ( [touch.view isKindOfClass:[UIButton class]] ) {
        return NO;
    } else if ( [touch.view.gestureRecognizers.lastObject isKindOfClass:[UITapGestureRecognizer class]] ) {
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _tapRec.enabled = NO;
    
    if ( [self.delegate respondsToSelector:@selector(gridView:willBeginDragging:)] ) {
        [self.delegate gridView:self willBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    _tapRec.enabled = YES;
    
    if ( [self.delegate respondsToSelector:@selector(gridView:willEndDragging:targetContentOffset:)] ) {
        [self.delegate gridView:self willEndDragging:scrollView targetContentOffset:*targetContentOffset];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ( self.shouldLayoutByScroll ) {
        [self _loadVisibleTilesWithReloading:NO];
        
        if ( [self.delegate respondsToSelector:@selector(gridView:didScroll:)] ) {
            [self.delegate gridView:self didScroll:scrollView];
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ( NO == self.shouldBackToNormalZoomLevel ) {
        return;
    }
    
    if ( scrollView.zoomScale > DEFAULT_ZOOM_IN_SCALE ) {
        _scrollView.zoomEnable = NO;
        [self zoomIn];
    } else if ( scrollView.zoomScale < DEFAULT_ZOOM_OUT_SCALE ) {
        _scrollView.zoomEnable = NO;
        [self zoomOut];
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.shouldLayoutByScroll = NO;
    _tapRec.enabled = NO;
    self.scrollView.clipsToBounds = NO;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ( self.shouldSendSelectDelegate ) {
        if ( [self.delegate respondsToSelector:@selector(gridView:didSelectItemAtIndexPath:)] ) {
            [self.delegate gridView:self didSelectItemAtIndexPath:self.highlightedIndexPath];
        }
        self.shouldSendSelectDelegate = NO;
    }
    
    if ( NO == self.shouldBackToNormalZoomLevel ) {
        return;
    }
    
    if ( 1.f != scale ) {
        [scrollView setZoomScale:1.f animated:YES];
    } else {
        self.shouldLayoutByScroll = YES;
        _tapRec.enabled = YES;
        _scrollView.zoomEnable = YES;
        self.scrollView.clipsToBounds = YES;
    }
}

#pragma mark - related layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if ( NO == _shouldConstructTiles ) {
        return;
    }
    
    // reset item datas
    [_itemData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HIGridItem* item = obj;
        [self _enqueueReusableTile:item.tile];
    }];
    [_itemData removeAllObjects];
    
    NSUInteger numberOfItems = [self.dataSource numberOfItemsInGridView:self];
    for ( int i = 0 ; i < numberOfItems ; i++ ) {
        HIGridItem* item = [[HIGridItem alloc] init];
        [_itemData addObject:item];
    }
    
    if ( NSNotFound == _zoomLevel ) {
        if ( [self.delegate respondsToSelector:@selector(defaultZoomLevelInGridView:)] ) {
            _zoomLevel = [self.delegate defaultZoomLevelInGridView:self];
        } else {
            _zoomLevel = self.layoutManager.minimumZoomLevel;
        }
    }
    
    // layouts
    [self _relayoutItems];
    [self _loadVisibleTilesWithReloading:YES];
}

- (void)_relayoutItems {
    [_itemData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HIGridItem* item = obj;
        item.frame = [self _cellFrameAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:DEFAULT_SECTION_INDEXPATH]];
    }];
    
    CGSize cellSize = [self.layoutManager cellSizeWithZoomLevel:self.zoomLevel];
    NSInteger numberOfColumnsInEachRows = floorf(CGRectGetWidth(self.scrollView.bounds) / cellSize.width);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), ceilf((float)_itemData.count / (float)numberOfColumnsInEachRows) * cellSize.height);
}

- (void)_loadVisibleTilesWithReloading:(BOOL)reload {
    // for scrolling
    CGRect visibleBounds = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    [_itemData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HIGridItem* item = obj;
        
        if ( CGRectContainsRect(visibleBounds, item.frame) || CGRectIntersectsRect(visibleBounds, item.frame) ) {
            if ( reload ) {
                [self _enqueueReusableTile:item.tile];
                item.tile = nil;
            }
            
            if ( nil == item.tile ) {
                [self _loadItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:DEFAULT_SECTION_INDEXPATH] startAnimation:self.animating];
            }
        } else {
            [self _enqueueReusableTile:item.tile];
            item.tile = nil;
        }
    }];
}

- (void)_loadItemAtIndexPath:(NSIndexPath*)indexPath startAnimation:(BOOL)startAnimation {
    HIGridItem* item = [_itemData objectAtIndex:indexPath.row];
    
    if ( nil == item.tile ) {
        item.tile = [self.dataSource gridView:self tileAtIndexPath:indexPath];
        item.tile.tag = indexPath.row;
        
        [self _layoutTileAtIndexPath:indexPath];
        [self.contentView addSubview:item.tile];
        
        if ( startAnimation && [item.tile respondsToSelector:@selector(startAnimation)] ) {
            [item.tile startAnimation];
        }
    }
}

- (void)_layoutVisibleTilesWithReloading:(BOOL)reload {
    // for scrolling
    CGRect visibleBounds = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    [_itemData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HIGridItem* item = obj;
        
        if ( CGRectContainsRect(visibleBounds, item.frame) || CGRectIntersectsRect(visibleBounds, item.frame) ) {
            if ( reload ) {
                [self _enqueueReusableTile:item.tile];
                item.tile = nil;
            }
            
            if ( nil == item.tile ) {
                [self _loadItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:DEFAULT_SECTION_INDEXPATH] startAnimation:self.animating];
            } else {
                [self _layoutTileAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:DEFAULT_SECTION_INDEXPATH]];
            }
        } else {
            [self _enqueueReusableTile:item.tile];
            item.tile = nil;
        }
    }];
}

- (void)_layoutTileAtIndexPath:(NSIndexPath*)indexPath {
    HIGridItem* item = [_itemData objectAtIndex:indexPath.row];
    
    CGSize tileSize = [self.layoutManager tileSizeWithZoomLevel:self.zoomLevel];
    item.tile.transform = CGAffineTransformIdentity;
    
    item.tile.frame = CGRectMake(0.f, self.scrollView.contentSize.height, tileSize.width, tileSize.height);
    item.tile.center = CGPointMake(CGRectGetMinX(item.frame) + CGRectGetWidth(item.frame) / 2.f, CGRectGetMinY(item.frame) + CGRectGetHeight(item.frame) / 2.f);
    
    if ( [self.delegate respondsToSelector:@selector(gridView:willShowTile:atIndexPath:)] ) {
        [self.delegate gridView:self willShowTile:item.tile atIndexPath:indexPath];
    }
}

#pragma mark - helper functions

- (CGRect)_cellFrameAtIndexPath:(NSIndexPath*)indexPath {
    CGSize cellSize = [self.layoutManager cellSizeWithZoomLevel:self.zoomLevel];
    NSInteger numberOfColumnsInEachRows = floorf(CGRectGetWidth(self.scrollView.bounds) / cellSize.width);
    
    return CGRectMake(cellSize.width * (int)(indexPath.row % numberOfColumnsInEachRows), cellSize.height * (int)(indexPath.row / numberOfColumnsInEachRows), cellSize.width, cellSize.height);
}

- (NSIndexPath*)_indexPathAtPoint:(CGPoint)point {
    __block NSIndexPath* indexPath = nil;
    [_itemData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HIGridItem* item = obj;
        if ( CGRectContainsPoint(item.frame, point) ) {
            indexPath = [NSIndexPath indexPathForRow:idx inSection:DEFAULT_SECTION_INDEXPATH];
            *stop = YES;
        }
    }];
    
    return indexPath;
}

- (void)_relayoutByZomming {
    [self _relayoutItems];
    CGRect visibleBounds = CGRectMake(0.f, self.scrollView.contentOffset.y, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    __block NSInteger animationItemCount = 0;
    [_itemData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HIGridItem* item = obj;
        if ( [item.tile respondsToSelector:@selector(stopAnimation)] ) {
            [item.tile stopAnimation];
        }
        if ( CGRectContainsRect(visibleBounds, item.frame) , CGRectIntersectsRect(visibleBounds, item.frame) ) {
            if ( nil == item.tile ) {
                [self _loadItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:DEFAULT_SECTION_INDEXPATH] startAnimation:self.animating];
                item.tile.center = CGPointMake(item.tile.center.x, item.tile.center.y + CGRectGetHeight(self.bounds));
                [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION delay:animationItemCount++ * DEFAULT_ANIMATION_DELAY options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    item.tile.center = CGPointMake(item.tile.center.x, item.tile.center.y - CGRectGetHeight(self.bounds));
                } completion:^(BOOL finished) {
                    if ( [item.tile respondsToSelector:@selector(startAnimation)] ) {
                        [item.tile startAnimation];
                    }
                }];
            } else {
                [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION delay:animationItemCount++ * DEFAULT_ANIMATION_DELAY options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    [self _layoutTileAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:DEFAULT_SECTION_INDEXPATH]];
                } completion:^(BOOL finished) {
                    if ( [item.tile respondsToSelector:@selector(startAnimation)] ) {
                        [item.tile startAnimation];
                    }
                }];
            }
        } else {
            if ( nil != item.tile ) {
                [UIView animateWithDuration:DEFAULT_ANIMATION_DURATION animations:^{
                    item.tile.center = CGPointMake(item.tile.center.x, item.tile.center.y + CGRectGetHeight(self.bounds));
                } completion:^(BOOL finished) {
                    [self _enqueueReusableTile:item.tile];
                    item.tile = nil;
                }];
            }
        }
    }];
    
    if ( [self.delegate respondsToSelector:@selector(gridView:didChangeZoomLevel:)] ) {
        [self.delegate gridView:self didChangeZoomLevel:_zoomLevel];
    }
}

#pragma mark - user interactions

- (void)onTapInView:(UIGestureRecognizer*)rec {
    NSIndexPath* indexPath = [self _indexPathAtPoint:[rec locationInView:self.contentView]];
    switch ( rec.state ) {
        case UIGestureRecognizerStateBegan:
        {
            if ( nil == indexPath ) {
                return;
            }
            
            NSAssert(nil == self.highlightedIndexPath, @"Item selected already!");
            self.highlightedIndexPath = indexPath;
            
            HIGridItem* item = [_itemData objectAtIndex:indexPath.row];
            UIView<HIUIGridTile>* tile = item.tile;
            if ( [tile respondsToSelector:@selector(setHighlighted:animated:)] ) {
                [tile setHighlighted:YES animated:NO];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if ( nil == self.highlightedIndexPath ) {
                return;
            }
            
            HIGridItem* item = [_itemData objectAtIndex:self.highlightedIndexPath.row];
            UIView<HIUIGridTile>* tile = item.tile;
            
            if ( [tile respondsToSelector:@selector(setHighlighted:animated:)] ) {
                [tile setHighlighted:NO animated:NO];
            }
            
            if ( self.highlightedIndexPath.row != indexPath.row ) {
                return;
            }
            
            if ( self.zoomOnItemSelected ) {
                if ( [self.delegate respondsToSelector:@selector(gridView:willSelectItemAtIndexPath:)] ) {
                    [self.delegate gridView:self willSelectItemAtIndexPath:indexPath];
                }
                
                self.shouldBackToNormalZoomLevel = NO;
                
                self.animating = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.scrollView.maximumZoomScale = 999.f;
                    CGSize size = [self.layoutManager tileSizeWithZoomLevel:self.zoomLevel];
                    CGRect rect = CGRectMake(CGRectGetMinX(item.frame) + roundf((CGRectGetWidth(item.frame) - size.width) / 2.f), CGRectGetMinY(item.frame) + roundf((CGRectGetHeight(item.frame) - size.height) / 2.f), size.width, size.height);
                    
                    item.tile.center = CGPointMake(CGRectGetMinX(item.frame) + CGRectGetWidth(item.frame) / 2.f, CGRectGetMinY(item.frame) + CGRectGetHeight(item.frame) / 2.f);
                    
                    self.shouldSendSelectDelegate = YES;
                    [self.scrollView zoomToRect:rect animated:YES];
                });
            } else {
                self.animating = NO;
                if ( [self.delegate respondsToSelector:@selector(gridView:didSelectItemAtIndexPath:)] ) {
                    [self.delegate gridView:self didSelectItemAtIndexPath:indexPath];
                }
                
                self.highlightedIndexPath = nil;
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateChanged:
        {
            if ( nil == self.highlightedIndexPath ) {
                return;
            }
            
            HIGridItem* item = [_itemData objectAtIndex:self.highlightedIndexPath.row];
            UIView<HIUIGridTile>* tile = item.tile;
            
            if ( [tile respondsToSelector:@selector(setHighlighted:animated:)] ) {
                [tile setHighlighted:NO animated:NO];
            }
            
            self.highlightedIndexPath = nil;
        }
            break;
        default:
            break;
    }
}

@end
