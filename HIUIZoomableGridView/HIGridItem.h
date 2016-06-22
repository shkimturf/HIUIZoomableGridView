//
//  HIGridItem.h
//  HIUIZoomableGridView
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HIUIGridTile.h"

@interface HIGridItem : NSObject

@property (nonatomic, strong) UIView<HIUIGridTile>* tile;
@property (nonatomic, assign) CGRect frame;

@end
