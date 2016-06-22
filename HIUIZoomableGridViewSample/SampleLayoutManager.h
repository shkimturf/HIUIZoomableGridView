//
//  SampleLayoutManager.h
//  HIUIZoomableGridViewSample
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HIUIZoomableGridViewLayoutManager.h"

@interface SampleLayoutManager : NSObject <HIUIZoomableGridViewLayoutManager>
{
    NSInteger _maximumZoomLevel;
    NSInteger _minimumZoomLevel;
    UIEdgeInsets _contentInset;
}

@end
