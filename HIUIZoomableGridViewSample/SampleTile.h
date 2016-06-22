//
//  SampleTile.h
//  HIUIZoomableGridViewSample
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HIUIGridTile.h"

@interface SampleTile : UIView <HIUIGridTile>
{
    UILabel* _label;
}

@property (nonatomic, strong, readonly) UILabel* label;

@end
