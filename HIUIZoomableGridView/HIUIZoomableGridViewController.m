//
//  HIUIZoomableGridViewController.m
//  HIUIZoomableGridViewSample
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import "HIUIZoomableGridViewController.h"

@implementation HIUIZoomableGridViewController
@synthesize gridView=_gridView;

- (void)loadView {
    [super loadView];
    
    _itemData = [[NSMutableArray alloc] init];
    _gridView = [[HIUIZoomableGridView alloc] initWithFrame:self.view.bounds layoutManager:self.layoutManager];
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    self.gridView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:self.gridView];
}

#pragma mark - properties

- (id<HIUIZoomableGridViewLayoutManager>)layoutManager {
    NSAssert(NO, @"Should override this.");
    return nil;
}

#pragma mark - HIUIGroupDataView dataSource

- (UIView<HIUIGridTile> *)gridView:(HIUIZoomableGridView *)gridView tileAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"Should override this.");
    return nil;
}

- (NSUInteger)numberOfItemsInGridView:(HIUIZoomableGridView *)gridView {
    return _itemData.count;
}


@end
