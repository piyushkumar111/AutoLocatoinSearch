//
//  VC_Mapview.h
//  Location Search
//
//  Created by Piyush Kachariya on 6/2/18.
//  Copyright © 2018 kachariyainfotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Obj_address.h"

@interface VC_Mapview : UIViewController<MKMapViewDelegate>

@property (nonatomic,retain) NSString *display;

@property (nonatomic,retain) NSArray *array_search_result;

@property (nonatomic,retain) Obj_address *obj_selected;

@property (strong, nonatomic) IBOutlet MKMapView *map_results;

@property (strong, nonatomic) IBOutlet UIButton *btn_save;

@end
