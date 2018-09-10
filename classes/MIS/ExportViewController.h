//
//  ExportViewController.h
//  mckinsey
//
//  Created by Mac on 04/04/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol exportTypeDelegate
-(void)pdfBtnPressed:(BOOL)isMap;
-(void)csvBtnPressed:(BOOL)isMap;
@end

@interface ExportViewController : UIViewController

@property (nonatomic, assign) BOOL isMap;

@property (nonatomic,weak) id <exportTypeDelegate> delegate;

@end
