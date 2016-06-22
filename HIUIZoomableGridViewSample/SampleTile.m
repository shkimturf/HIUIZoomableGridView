//
//  SampleTile.m
//  HIUIZoomableGridViewSample
//
//  Created by Sunhong Kim on 2016. 6. 22..
//  Copyright © 2016년 Sunhong Kim. All rights reserved.
//

#import "SampleTile.h"

@implementation SampleTile
@synthesize label=_label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setUp];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _setUp];
}

#pragma mark - HIUIGridTile protocols

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)initiateTile {
    self.label.text = nil;
    self.transform = CGAffineTransformIdentity;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    self.backgroundColor = highlighted ? [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.f] : [UIColor whiteColor];
}

#pragma mark - private functions

- (void)_setUp {
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    self.label.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:20.f];
    [self addSubview:self.label];
    
    self.layer.cornerRadius = 4.f;
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 1.f;
    
    self.clipsToBounds = YES;
    
    self.backgroundColor = [UIColor whiteColor];
}

@end
