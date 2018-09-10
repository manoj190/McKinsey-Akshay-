//
//  loadingPage.m
//  Navi Mumbai Police
//
//  Created by HardCastle on 07/12/15.
//  Copyright © 2015 Hardcastle. All rights reserved.
//

#import "loadingPage.h"

@interface loadingPage ()
{
    
    __weak IBOutlet UIView *loadingView;
    __weak IBOutlet UIActivityIndicatorView *loadingIndicator;
}
@end

@implementation loadingPage

- (void)viewDidLoad
{
    [super viewDidLoad];
    [loadingIndicator startAnimating];
    loadingView.layer.masksToBounds=YES;
    loadingView.layer.cornerRadius=5.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
