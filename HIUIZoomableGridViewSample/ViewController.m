//
//  ViewController.m
//  HIUIZoomableGridViewSample
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import "ViewController.h"

#import "SampleLayoutManager.h"
#import "SampleTile.h"

@implementation ViewController

- (void)loadView {
    [super loadView];
    
    for ( int i = 0 ; i < 1000 ; i++ ) {
        [_itemData addObject:[NSNumber numberWithInt:i]];
    }
}

#pragma mark - properties

- (id<HIUIZoomableGridViewLayoutManager>)layoutManager {
    if ( nil == _layoutManager ) {
        _layoutManager = [[SampleLayoutManager alloc] init];
    }
    
    return _layoutManager;
}

#pragma mark - HIUIGroupDataView dataSource

- (UIView<HIUIGridTile> *)gridView:(HIUIZoomableGridView *)gridView tileAtIndexPath:(NSIndexPath *)indexPath {
    SampleTile* tile = (SampleTile*)[gridView dequeueReusableTileWithIdentifier:[SampleTile reuseIdentifier]];
    if ( nil == tile ) {
        tile = [[SampleTile alloc] initWithFrame:CGRectZero];
    }
    
    
    tile.label.text = [NSString stringWithFormat:@"%d", [[_itemData objectAtIndex:indexPath.row] intValue]];
    
    return tile;
}

@end
