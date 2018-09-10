//
//  UIViewController+oritation.m
//  Kyoto
//
//  Created by HardCastle on 23/02/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "UIViewController+oritation.h"

@implementation UIViewController (oritation)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


@end
