//
//  analysisTypeView.h
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "inputPage.h"
#import "featurePrioritization.h"
#import "commingSoon.h"
#import "previewPage.h"
@interface analysisTypeView : UIViewController<iCarouselDataSource, iCarouselDelegate>
@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (strong, nonatomic) inputPage *inputPageObj;
@property (strong, nonatomic) featurePrioritization *featurePrioritizationObj;
@property (strong, nonatomic) commingSoon *commingSoonObj;
@property (strong, nonatomic) previewPage *previewPageObj;
@property (strong, nonatomic) NSString *surveyName;
@property (strong, nonatomic) NSString *surveyID;
@property (strong, nonatomic) NSString *surveyCurrency;
@end
