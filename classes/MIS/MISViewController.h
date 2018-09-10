//
//  MISViewController.h
//  mckinsey
//
//  Created by Akshay Ambekar on 10/03/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google-Maps-iOS-Utils/GMUMarkerClustering.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MISViewController : UIViewController

@property (nonatomic,strong) NSString *surveyID;
@property (nonatomic,strong) NSString *surveyName;
@property (nonatomic,strong) NSString *surveyType;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@end
