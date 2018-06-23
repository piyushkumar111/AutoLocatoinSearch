//
//  VC_Search_Page.h
//  Location Search
//
//  Created by Piyush Kachariya on 6/2/18.
//  Copyright © 2018 kachariyainfotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface VC_Search_Page : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D currentCentre;
    CLLocation *currentLocation;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar_top;
@property (weak, nonatomic) IBOutlet UITableView *tblvw_search_result;

@end
