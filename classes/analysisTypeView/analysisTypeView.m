//
//  analysisTypeView.m
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "analysisTypeView.h"
#import "dashboard.h"
#import "loginView.h"
#import "notifications.h"
#pragma GCC diagnostic ignored "-Wgnu"

@interface analysisTypeView ()<UIActionSheetDelegate>
{
    IBOutlet UILabel *titleTxt;
    IBOutlet UITextView *lowerTxt;
    IBOutlet UIImageView *badgeCountImg;
    IBOutlet UILabel *badgeCountLbl;
    
}
@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, strong) NSMutableArray *items;

- (IBAction)homeBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;
@end

@implementation analysisTypeView
@synthesize carousel,inputPageObj,featurePrioritizationObj,commingSoonObj,previewPageObj;
- (void)setUp
{
    //set up data
    self.wrap = YES;
    self.items = [NSMutableArray array];
    for (int i = 0; i < 2; i++)
    {
        [self.items addObject:@(i)];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)dealloc
{
    //it's a good idea to set these to nil here to avoid
    //sending messages to a deallocated viewcontroller
    carousel.delegate = nil;
    carousel.dataSource = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //configure carousel
    //iCarouselTypeCoverFlow2
    self.carousel.type = iCarouselTypeCoverFlow2;
  //  self.navItem.title = @"CoverFlow2";
}

-(void)viewWillAppear:(BOOL)animated
{
    badgeCountImg.hidden = YES;
    badgeCountLbl.hidden = YES;
    [self setBadgeNumber];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBadgeNumber) name:@"setbadge" object:nil];
}

-(void)setBadgeNumber
{
    NSLog(@"In bagde counter");
    @try
    {
        //Fetch badge count from plist
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"notification_Data.plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        badgeCountLbl.text = [[dict objectForKey:@"BADGE_COUNT"] stringValue];
        if ([[dict objectForKey:@"BADGE_COUNT"]intValue] == 0)
        {
            badgeCountImg.hidden = YES;
            badgeCountLbl.hidden = YES;
        }
        else
        {
            badgeCountImg.hidden = NO;
            badgeCountLbl.hidden = NO;
        }
    }
    @catch (NSException *exception)
    {
        
    }
    @finally
    {
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.carousel = nil;
    //self.navItem = nil;
    //self.orientationBarItem = nil;
    //self.wrapBarItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(__unused UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= 0)
    {
        //map button index to carousel type
        iCarouselType type = buttonIndex;
        
        //carousel can smoothly animate between types
        [UIView beginAnimations:nil context:nil];
        self.carousel.type = type;
        [UIView commitAnimations];
        
        //update title
       // self.navItem.title = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel
{
    return (NSInteger)[self.items count];
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 430.0f, 350.0f)];
        if (index == 0)
        {
            ((UIImageView *)view).image = [UIImage imageNamed:@"type1.png"];
        }
        else if (index == 1)
        {
            ((UIImageView *)view).image = [UIImage imageNamed:@"type2.png"];
        }
//        else
//        {
//            ((UIImageView *)view).image = [UIImage imageNamed:@"type3.png"];
//        }
        // view.contentMode = UIViewContentModeCenter;
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:50];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    
   // label.text = [self.items[(NSUInteger)index] stringValue];
    
    return view;
}

- (NSInteger)numberOfPlaceholdersInCarousel:(__unused iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 2;
}

- (UIView *)carousel:(__unused iCarousel *)carousel placeholderViewAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 354.0f, 246.0f)];
        if (index == 0)
        {
            ((UIImageView *)view).image = [UIImage imageNamed:@"type1.png"];
        }
        else if (index == 1)
        {
            ((UIImageView *)view).image = [UIImage imageNamed:@"type2.png"];
        }
        else
        {
            ((UIImageView *)view).image = [UIImage imageNamed:@"type3.png"];

        }
        //view.contentMode = UIViewContentModeCenter;
        //analysisType2.png
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [label.font fontWithSize:50.0f];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    
   //label.text = (index == 0)? @"[": @"]";
    
    return view;
}

- (CATransform3D)carousel:(__unused iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.carousel.itemWidth);
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return self.wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (self.carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        case iCarouselOptionShowBackfaces:
        case iCarouselOptionRadius:
        case iCarouselOptionAngle:
        case iCarouselOptionArc:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:
        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems:
        {
            return value;
        }
    }
}

#pragma mark -
#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSNumber *item = (self.items)[(NSUInteger)index];
    NSLog(@"Tapped view number: %@", item);
    
    if (index == 0)
    {
//        inputPageObj = [[inputPage alloc]initWithNibName:@"inputPage" bundle:nil];
//        [self.navigationController pushViewController:inputPageObj animated:YES];
        NSLog(@"Surveu Pushed = %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"SURVEY_PUSHED"]);
        if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"SURVEY_PUSHED"]isEqualToString:@"NO"])
        {
            previewPageObj = [[previewPage alloc]initWithNibName:@"previewPage" bundle:nil];
            [self.navigationController pushViewController:previewPageObj animated:YES];
        }
        else
        {
            inputPageObj = [[inputPage alloc]initWithNibName:@"inputPage" bundle:nil];
            inputPageObj.surveyName = _surveyName;
            inputPageObj.surveyID = _surveyID;
            [self.navigationController pushViewController:inputPageObj animated:YES];
        }
    }
    else if (index == 1)
    {
        if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"SURVEY_PUSHED"]isEqualToString:@"NO"])
        {
            previewPageObj = [[previewPage alloc]initWithNibName:@"previewPage" bundle:nil];
            [self.navigationController pushViewController:previewPageObj animated:YES];
        }
        else
        {
           featurePrioritizationObj = [[featurePrioritization alloc]initWithNibName:@"featurePrioritization" bundle:nil];
            featurePrioritizationObj.surveyName = _surveyName;
            featurePrioritizationObj.surveyID = _surveyID;
            featurePrioritizationObj.surveyCurrency = _surveyCurrency;
           [self.navigationController pushViewController:featurePrioritizationObj animated:YES];
        }
    }
    else
    {
        commingSoonObj = [[commingSoon alloc]initWithNibName:@"commingSoon" bundle:nil];
        [self.navigationController pushViewController:commingSoonObj animated:YES];
    }
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel
{
    NSLog(@"Index: %@", @(self.carousel.currentItemIndex));
    NSString *index= [NSString stringWithFormat:@"%@",@(self.carousel.currentItemIndex)];
    if ([index isEqualToString:@"0"])
    {
        titleTxt.text = @"Max Difference";
        lowerTxt.text = @"Maximum difference scaling (Max diff) is a way of evaluating the importance (or preference) of number of alternatives It is a discrete choice technique i.e Respondent are asked to make best/worst, most preferred/least preferred choices";
    }
    else if ([index isEqualToString:@"1"])
    {
        titleTxt.text = @"Feature Prioritization Using Maxdiff";
        lowerTxt.text = @"Feature prioritization using maxdiff is an approach to trade off product features based on their customer value and BOM cost.";
    }
    else if ([index isEqualToString:@"2"])
    {
        titleTxt.text = @"Choice based Conjoint analysis";
        lowerTxt.text = @"Conjoint is a method that allows to estimate the relative importance & different and the relative worth of different products or to estimate the primary demand of a product in a market";

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)homeBtnClicked:(id)sender
{
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i=0;i<[viewControllers count];i++)
    {
        id obj=[viewControllers objectAtIndex:i];
        if([obj isKindOfClass:[dashboard class]])
        {
            [[self navigationController] popToViewController:obj animated:YES];
            return;
        }
    }
}

- (IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutBtnClicked:(id)sender
{
 /*   NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i=0;i<[viewControllers count];i++)
    {
        id obj=[viewControllers objectAtIndex:i];
        if([obj isKindOfClass:[loginView class]])
        {
            [[self navigationController] popToViewController:obj animated:YES];
            return;
        }
        else if ([obj isKindOfClass:[dashboard class]])
        {
            [[self navigationController] popToViewController:obj animated:YES];
            loginView *loginViewObj = [[loginView alloc]initWithNibName:[NSString stringWithFormat:@"loginView"] bundle:nil];
            UINavigationController * navigationController = self.navigationController;
            [navigationController popToRootViewControllerAnimated:NO];
            [navigationController pushViewController:loginViewObj animated:NO];
            return;
        }
    }*/
    
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_DATA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"data = %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"USER_DATA"]);

    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i=0;i<[viewControllers count];i++)
    {
        id obj=[viewControllers objectAtIndex:0];
        if ([obj isKindOfClass:[loginView class]])
        {
            UINavigationController * navigationController = self.navigationController;
            [navigationController popToRootViewControllerAnimated:NO];
            return;
        }
        else if ([obj isKindOfClass:[dashboard class]])
        {
            loginView *loginViewObj = [[loginView alloc]initWithNibName:[NSString stringWithFormat:@"loginView"] bundle:nil];
            UINavigationController * navigationController = self.navigationController;
            //[navigationController popToRootViewControllerAnimated:NO];
            [navigationController pushViewController:loginViewObj animated:NO];
            return;
        }
    }

}

- (IBAction)notificationBtnClicked:(id)sender
{
    badgeCountImg.hidden = YES;
    badgeCountLbl.hidden = YES;
    [self setBadgeCountZeroInPlist];
    notifications *notificationViewObj = [[notifications alloc]initWithNibName:@"notifications" bundle:nil];
    [self.navigationController pushViewController:notificationViewObj animated:YES];
}

-(void)setBadgeCountZeroInPlist
{
    NSMutableArray *nameArr = [[NSMutableArray alloc]init];
    int badgeCount = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"notification_Data.plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    nameArr = [dict objectForKey:@"NOTIFICATION_DATA"];
    
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
    if (nameArr != nil )
    {
        [plistDict setObject:nameArr forKey:@"NOTIFICATION_DATA"];
        [plistDict setValue:[NSNumber numberWithInt:badgeCount] forKey:@"BADGE_COUNT"];
    }
    else
    {
    }
    
    NSString *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    if(plistData)
    {
        [plistData writeToFile:plistPath atomically:YES];
        NSLog(@"Data saved successfully");
    }
    else
    {
        NSLog(@"Data not saved");
    }
}

@end
