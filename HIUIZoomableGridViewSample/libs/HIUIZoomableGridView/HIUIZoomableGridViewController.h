//
//  HIUIZoomableGridViewController.h
//  HIUIZoomableGridViewSample
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HIUIZoomableGridView.h"

@interface HIUIZoomableGridViewController : UIViewController <HIUIZoomableGridViewDataSource, HIUIZoomableGridViewDelegate>
{
    HIUIZoomableGridView* _gridView;
    
    NSMutableArray* _itemData;
}

@property (nonatomic, strong, readonly) HIUIZoomableGridView* gridView;
@property (nonatomic, strong, readonly) id<HIUIZoomableGridViewLayoutManager> layoutManager;

@end
