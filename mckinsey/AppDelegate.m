
//
//  AppDelegate.m
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "AppDelegate.h"
#import "notifications.h"
#import "constant.h"
#import "dashboard.h"
#import "userManagement.h"
#import <UserNotifications/UserNotifications.h>

@import GoogleMaps;

// define macro
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
@interface AppDelegate () <UNUserNotificationCenterDelegate>
{
    NSString *userDeviceToken;
    NSMutableArray *notificationData;
}
@end

@implementation AppDelegate
@synthesize loginViewObj,navObj,featurePrioritizationObj,previewPageObj,inputPageObj,fpOutputObj,fpUsingMdOutputObj,maxDiffOutputObj;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSMutableDictionary *userData = [[NSUserDefaults standardUserDefaults]valueForKey:@"USER_DATA"];
    if ([[userData valueForKey:@"USER_TYPE"] isEqualToString:@"ADMIN"] && [[userData valueForKey:@"USERNAME"] length] > 0 && [[userData valueForKey:@"PASSWORD"] length] > 0)
    {
        dashboard *dashboardObj = [[dashboard alloc]initWithNibName:@"dashboard" bundle:nil];
        navObj = [[UINavigationController alloc]initWithRootViewController:dashboardObj];
    }
    else if ([[userData valueForKey:@"USER_TYPE"] isEqualToString:@"SUPER_ADMIN"] && [[userData valueForKey:@"USERNAME"] length] > 0 && [[userData valueForKey:@"PASSWORD"] length] > 0)
    {
        userManagement *usermgmtObj = [[userManagement alloc]initWithNibName:@"userManagement" bundle:nil];
        navObj = [[UINavigationController alloc]initWithRootViewController:usermgmtObj];
    }
    else
    {
        loginViewObj = [[loginView alloc]initWithNibName:@"loginView" bundle:nil];
        navObj = [[UINavigationController alloc]initWithRootViewController:loginViewObj];
    }
    
    self.window.rootViewController = navObj;
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"FIRST_TIME"];
    //For Push Notification
    [self registerForRemoteNotifications];
    
    //Google maps
    [GMSServices provideAPIKey:@"AIzaSyCNax2orANufyRRjOUOKLsvXsr0v7ibamQ"];
    //[GMSPlacesClient provideAPIKey:@"AIzaSyAS0lzWZpjKyT6q1Z3jtjFot3Udakm6pVc"];

    
    return YES;
}

- (void)registerForRemoteNotifications
{
    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) )
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    else
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to
                                });
                  //get the app to do anything at all about push notifications
                 NSLog( @"Push registration success." );
             }
             else
             {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
             }
         }];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *strDevicetoken = [[NSString alloc]initWithFormat:@"%@",[[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSLog(@"Device Token = %@",strDevicetoken);
    deviceTokenStr = strDevicetoken;
    [[NSUserDefaults standardUserDefaults]setValue:strDevicetoken forKey:@"DEVICE_TOKEN"];
    [self updateDeviceToken:deviceTokenStr];
    
}

-(void)updateDeviceToken:(NSString *)deviceToken
{
    NSLog(@"User id= %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"ADMIN_ID"]);
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"DEVICE_TOKEN"] isEqualToString:deviceToken])
    {
        NSLog(@"Device token already exists");
        [self callWebserviceToUpdateDeviceToken:deviceToken];
    }
    else
    {
        if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"ADMIN_ID"] length] == 0)
        {
            NSLog(@"Admin id not found");
        }
        else
        {
            [self callWebserviceToUpdateDeviceToken:deviceToken];
        }
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Push Notification Information : %@",userInfo);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    [self saveDataLocally:[[userInfo valueForKey:@"aps"]valueForKey:@"alert"]];
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        [self appActive:userInfo];
    }
    else if(state == UIApplicationStateBackground)
    {
        notifications *notificationViewObj = [[notifications alloc]initWithNibName:@"notifications" bundle:nil];
        [self.navObj pushViewController:notificationViewObj animated:YES];
    }
    else
    {
        notifications *notificationViewObj = [[notifications alloc]initWithNibName:@"notifications" bundle:nil];
        [self.navObj pushViewController:notificationViewObj animated:YES];
    }
}

-(void)saveDataLocally:(NSString *)text
{
    NSMutableArray *nameArr = [[NSMutableArray alloc]init];
    int badgeCount = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"notification_Data.plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    nameArr = [dict objectForKey:@"NOTIFICATION_DATA"];
    badgeCount = (int)[[dict objectForKey:@"BADGE_COUNT"] integerValue];
    
    if (nameArr == nil || nameArr.count == 0)
    {
        nameArr = [[NSMutableArray alloc]init];
        [nameArr addObject:text];
        badgeCount ++;
    }
    else
    {
        [nameArr addObject:text];
        badgeCount ++;
    }
    
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
    [plistDict setObject:nameArr forKey:@"NOTIFICATION_DATA"];
    [plistDict setValue:[NSNumber numberWithInt:badgeCount] forKey:@"BADGE_COUNT"];
    
    NSString *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    if(plistData)
    {
        [plistData writeToFile:plistPath atomically:YES];
        NSLog(@"Data saved sucessfully");
    }
    else
    {
        NSLog(@"Data not saved");
    }
}

-(void)appActive:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setbadge" object:self];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@ = %@", NSStringFromSelector(_cmd), error);
    NSLog(@"Error = %@",error);
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else  /* iphone */
        return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)callWebserviceToUpdateDeviceToken:(NSString *)deviceToken
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"updateDeviceToken.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"&TYPE=%@&ID=%@&UDID=%@",@"ADMIN",[[NSUserDefaults standardUserDefaults]valueForKey:@"ADMIN_ID"],deviceToken];
                       
                       //Convert the String to Data
                       NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
                       
                       //Apply the data to the body
                       [request setHTTPBody:data1];
                       
                       NSURLSession *session = [NSURLSession sharedSession];
                       [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                 NSURLResponse *response,
                                                                                 NSError *error) {
                           if (data == nil)
                           {
                               NSLog(@"Error updating device token");
                           }
                           else
                           {
                               NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               
                               [self responseResult:resStr];
                           }
                       }] resume];
                   });
}

-(void)responseResult:(NSString  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           NSLog(@"Device token updated successfully");
                       }
                });
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
