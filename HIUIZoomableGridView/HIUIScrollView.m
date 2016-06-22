//
//  HIUIScrollView.m
//  HIUIZoomableGridView
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import "HIUIScrollView.h"

@implementation HIUIScrollView

- (void)setZoomEnable:(BOOL)zoomEnable {
    _zoomEnable = zoomEnable;
    
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ( [obj isKindOfClass:[UIPinchGestureRecognizer class]] ) {
            UIPinchGestureRecognizer* rec = obj;
            rec.enabled = self.zoomEnable;
        }
    }];
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    // prevent auto scrolling
}

@end
