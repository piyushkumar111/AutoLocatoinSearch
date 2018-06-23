//
//  VC_Mapview.m
//  Location Search
//
//  Created by Piyush Kachariya on 6/2/18.
//  Copyright © 2018 kachariyainfotech. All rights reserved.
//

#import "VC_Mapview.h"
#import "AppDelegate.h"

@interface VC_Mapview ()
{
    AppDelegate *app_del;
    BOOL exist_in_database;
    NSManagedObjectContext *context;

}
@end

@implementation VC_Mapview

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initial Methods


-(void)initialize{
    
    app_del = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    context = app_del.persistentContainer.viewContext;
    
    exist_in_database = [self location_exist];

    [self updateExistStatus];
    
    if (_array_search_result.count > 0)
    {
        [self plotPositions:_array_search_result];
    }
    
    if ([_display isEqualToString:DISPLAY_ALL])
    {
        _btn_save.hidden = YES;
    }
    else
    {
        _btn_save.hidden = NO;
    }

//    self.navigationController.navigationBar.topItem.title = @"Back";

}

-(void)updateExistStatus{
    
    if (exist_in_database)
    {
        [_btn_save setTitle:@"Delete" forState:UIControlStateNormal];
    }
    else
    {
        [_btn_save setTitle:@"Save" forState:UIControlStateNormal];
    }
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (@available(iOS 11.2, *)) {
        self.navigationController.navigationBar.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    }
}


#pragma mark - Annotation Methods

- (void)plotPositions:(NSArray *)data
{
    //Remove any existing custom annotations but not the user location blue dot.
    for (id<MKAnnotation> annotation in _map_results.annotations)
    {
        if ([annotation isKindOfClass:[_map_results class]])
        {
            [_map_results removeAnnotation:annotation];
        }
    }
    
    
    //Loop through the array of places returned from the Google API.
    for (int i=0; i<[data count]; i++)
    {
        Obj_address *placeObject = [_array_search_result objectAtIndex:i];
        [_map_results addAnnotation:placeObject];
    }
}

#pragma mark - Uibutton click methods

-(IBAction)btnBackClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btnSaveClicked:(id)sender
{
    if (exist_in_database)
    {
        exist_in_database = NO;
        [_btn_save setTitle:@"Save" forState:UIControlStateNormal];
    }
    else
    {
        exist_in_database = YES;
        [_btn_save setTitle:@"Delete" forState:UIControlStateNormal];
    }
    

    if ([self location_exist])
    {
        NSLog(@"Location Exist");
        [self remove_exist_location];
    }
    else
    {
        NSLog(@"Location Added");

        // Create a new managed object
        NSManagedObject *new_location = [NSEntityDescription insertNewObjectForEntityForName:@"Data_Location" inManagedObjectContext:context];
        
        [new_location setValue:_obj_selected.name forKey:@"name"];
        [new_location setValue:_obj_selected.address forKey:@"address"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}


-(BOOL)location_exist
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Data_Location" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setFetchLimit:1];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", _obj_selected.name]];
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    
    if (count)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)remove_exist_location
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Data_Location" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setFetchLimit:1];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", _obj_selected.name]];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];

    [context deleteObject:[fetchedObjects objectAtIndex:0]];
    
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}

#pragma mark - MKMapViewDelegate methods.


- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    
    //Zoom back to the user location after adding a new set of annotations.
    
    //Get the center point of the visible map.
    CLLocationCoordinate2D centre;
    MKCoordinateRegion region;
    
    if ([_display isEqualToString:DISPLAY_ALL])
    {
        centre = [mv centerCoordinate];
        region = MKCoordinateRegionMakeWithDistance(centre,200000,200000);
        [self zoomToFitMapAnnotations:self.map_results];
    }
    else
    {
        //Set the visible region of the map.
        centre = self.obj_selected.coordinate;
        region = MKCoordinateRegionMakeWithDistance(centre,10000,10000);
        [mv setRegion:region animated:YES];
    }
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    //Define our reuse indentifier.
    static NSString *identifier = @"Obj_address";
    
    
    if ([annotation isKindOfClass:[Obj_address class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.map_results dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    
    for (id<MKAnnotation> currentAnnotation in mapView.annotations)
    {
        if ([currentAnnotation isEqual:_obj_selected])
        {
            [mapView selectAnnotation:currentAnnotation animated:FALSE];
        }
    }
}

- (void)zoomToFitMapAnnotations:(MKMapView *)mapView
{
    if ([mapView.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

@end
