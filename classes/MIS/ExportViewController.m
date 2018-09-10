//
//  ExportViewController.m
//  mckinsey
//
//  Created by Mac on 04/04/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import "ExportViewController.h"
#import "APIManager.h"
#import <MessageUI/MessageUI.h>
#import "loadingPage.h"



@interface ExportViewController ()
@end

@implementation ExportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)exportPDFBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [_delegate pdfBtnPressed:_isMap];
}

- (IBAction)exportCSVBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [_delegate csvBtnPressed:_isMap];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
