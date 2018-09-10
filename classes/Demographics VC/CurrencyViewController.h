//
//  CurrencyViewController.h
//  mckinsey
//
//  Created by Mac on 20/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol currencyProtocol
- (void)setCurrency:(NSDictionary *)currencyDict;
@end

@interface CurrencyViewController : UIViewController
{
    
}

//@property (nonatomic, strong) NSMutableArray *currencyList;
@property (nonatomic, weak) id <currencyProtocol> delegate;


@end
