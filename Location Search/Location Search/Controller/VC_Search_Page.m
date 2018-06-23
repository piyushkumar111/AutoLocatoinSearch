//
//  VC_Search_Page.m
//  Location Search
//
//  Created by Piyush Kachariya on 6/2/18.
//  Copyright © 2018 kachariyainfotech. All rights reserved.
//

#import "VC_Search_Page.h"
#import "Cell_SearchResult.h"
#import "VC_Mapview.h"
#import "Obj_address.h"

@interface VC_Search_Page ()
{
    NSMutableArray *array_searchlist;
}
@end

@implementation VC_Search_Page

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Inital Methods

-(void)initialize{
    
    array_searchlist = [[NSMutableArray alloc]init];

//    [array_searchlist addObject:@"test1"];
//    [array_searchlist addObject:@"test2"];
//    [array_searchlist addObject:@"test3"];

    //Instantiate a location object.
    locationManager = [[CLLocationManager alloc] init];
    
    //Make this controller the delegate for the location manager.
    [locationManager setDelegate:self];
    
    //Set some paramater for the location object.
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        //[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways
        ) {
        // Will open an confirm dialog to get user's approval
        [locationManager requestWhenInUseAuthorization];
        //[_locationManager requestAlwaysAuthorization];
    } else {
        [locationManager startUpdatingLocation]; //Will update location immediately
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"User still thinking..");
        } break;
        case kCLAuthorizationStatusDenied: {
            NSLog(@"User hates you");
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [locationManager startUpdatingLocation]; //Will update location immediately
        } break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations lastObject];
    NSLog(@"lat%f - lon%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    [locationManager stopUpdatingLocation];
    locationManager = nil;
}


#pragma mark - Tableview Delegates Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0 && array_searchlist.count > 1)
    {
        return 1;
    }
    
    if (array_searchlist.count == 0) {
        return 1;
    }
    return array_searchlist.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (array_searchlist.count > 1)
    {
        return 2;
    }
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    [view setBackgroundColor: [UIColor colorWithRed:201.0f/255.0f green:201.0f/255.0f blue:206.0f/255.0f alpha:1.0f]];
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *cell_identifier = @"Cell_SearchResult";
    
    Cell_SearchResult *cell = (Cell_SearchResult *)[_tblvw_search_result dequeueReusableCellWithIdentifier:cell_identifier];
    
    if (cell == nil) {
        
        cell = (Cell_SearchResult *)[[[NSBundle mainBundle] loadNibNamed:@"Cell_SearchResult" owner:self options:nil] lastObject];
    }

    cell.btn_arrow.frame = CGRectMake(_tblvw_search_result.frame.size.width-30, 15,20,20);
    
    
    if (indexPath.section == 0 && array_searchlist.count > 1)
    {
        cell.btn_arrow.hidden = NO;
        cell.lbl_result_title.text = @"Display All on Map";
        
    }
    else if(array_searchlist.count == 0)
    {
        cell.btn_arrow.hidden = YES;

        cell.lbl_result_title.text = @"No Results";
    }
    else
    {
        cell.btn_arrow.hidden = NO;

        Obj_address *placeObject = [array_searchlist objectAtIndex:indexPath.row];
        cell.lbl_result_title.text = placeObject.name;
    }
    
    cell.btn_arrow.userInteractionEnabled = NO;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    VC_Mapview *map_view = loadViewController(TMStoryboard_Main,@"VC_Mapview");

    if (indexPath.section == 0 && array_searchlist.count > 1)
    {
        map_view.display = DISPLAY_ALL;
    }
    else if (indexPath.section == 1)
    {
        map_view.obj_selected = [array_searchlist objectAtIndex:indexPath.row];
        map_view.display = DISPLAY_CENTER;
    }
    map_view.array_search_result = array_searchlist;
    [self.navigationController pushViewController:map_view animated:YES];
}


#pragma mark - Searchbar methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"%@",_searchbar_top.text);
    [self queryGooglePlaces:_searchbar_top.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
}


#pragma mark - Mapview methods

-(void) queryGooglePlaces: (NSString *) googleType
{
    if ([googleType isEqualToString:@""] || [googleType isEqualToString:@" "])
    {
        [array_searchlist removeAllObjects];
        [_tblvw_search_result reloadData];
        return;
    }
    
    googleType = [googleType stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
//    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=2000&search=%@&sensor=true&key=%@", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, googleType, kGOOGLE_API_KEY];

    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=2000000&search=%@&sensor=true&key=%@", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, googleType, kGOOGLE_API_KEY];



    
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);
    
    [array_searchlist removeAllObjects];
    
    //Loop through the array of places returned from the Google API.
    for (int i=0; i<[places count]; i++)
    {
        
        //Retrieve the NSDictionary object in each index of the array.
        NSDictionary* place = [places objectAtIndex:i];
        
        //There is a specific NSDictionary object that gives us location info.
        NSDictionary *geo = [place objectForKey:@"geometry"];
        
        
        //Get our name and address info for adding to a pin.
        NSString *name=[place objectForKey:@"name"];
        
        //NSString *vicinity=[place objectForKey:@"vicinity"];
        
        //Get the lat and long for the location.
        NSDictionary *loc = [geo objectForKey:@"location"];
        
        //Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        
        //Set the lat and long.
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        
        NSString *str_Add = [NSString stringWithFormat:@"(%f %f)",[[loc objectForKey:@"lat"] doubleValue],[[loc objectForKey:@"lng"] doubleValue]];
        
        //Create a new annotiation.
        Obj_address *placeObject = [[Obj_address alloc] initWithName:name address:str_Add coordinate:placeCoord];

        [array_searchlist addObject:placeObject];
    
    }
    
    [_tblvw_search_result reloadData];
    
    //Plot the data in the places array onto the map with the plotPostions method.
//    [self plotPositions:places];
    
    
}





@end
