//
//  BAMapViewController.m
//  EmeraldStreet
//
//  Created by Sandip on 14/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BAMapViewController.h"
#import "BAPlaceMark.h"

@interface BAMapViewController ()

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *allPlacemarks;

- (IBAction)backButtonTapped:(UIButton *)sender;

@end

@implementation BAMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.viewHeader.bounds];
    self.viewHeader.layer.masksToBounds = NO;
    self.viewHeader.layer.shadowColor = [UIColor grayColor].CGColor;
    self.viewHeader.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.viewHeader.layer.shadowOpacity = 0.5f;
    self.viewHeader.layer.shadowPath = shadowPath.CGPath;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (nil == self.allPlacemarks)
    {
        self.allPlacemarks = [[NSMutableArray alloc] initWithCapacity:0];
        
        [self addAnnotationForData:self.data];
        
        if (self.mapView.annotations.count)
        {
            [self.mapView selectAnnotation:[self.mapView.annotations lastObject] animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonTapped:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -

- (BOOL)isValidCoordinate:(CLLocationCoordinate2D)coordinate
{
    if ((0.0 == coordinate.latitude) || (0.0 == coordinate.longitude))
        return NO;
    
    return CLLocationCoordinate2DIsValid(coordinate);
}

- (void)centerMapForAnnotations
{
	MKCoordinateRegion region;
    
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
    
    for (BAPlaceMark *placemark in self.allPlacemarks)
    {
        CLLocationCoordinate2D aCoordinate = CLLocationCoordinate2DMake(placemark.coordinate.latitude, placemark.coordinate.longitude);
        
        if(aCoordinate.latitude > maxLat)
            maxLat = aCoordinate.latitude;
        if(aCoordinate.latitude < minLat)
            minLat = aCoordinate.latitude;
        if(aCoordinate.longitude > maxLon)
            maxLon = aCoordinate.longitude;
        if(aCoordinate.longitude < minLon)
            minLon = aCoordinate.longitude;
    }
    
	region.center.latitude     = (maxLat + minLat) / 2.0;
	region.center.longitude    = (maxLon + minLon) / 2.0;
    region.span.latitudeDelta  = maxLat - minLat;
    region.span.longitudeDelta = maxLon - minLon;
    
    region.span.latitudeDelta  += 0.01;
    region.span.longitudeDelta += 0.01;
    
	[self.mapView setRegion:region animated:YES];
}

- (BOOL)addAnnotationForData:(NSDictionary *)data
{
    id latitudeValue = [data valueForKey:kBarLatitudeKey];
    double latitude = [latitudeValue isKindOfClass:[NSNull class]]?0:[latitudeValue doubleValue];
    id longitudeValue = [data valueForKey:kBarLongitudeKey];
    double longitude = [longitudeValue isKindOfClass:[NSNull class]]?0:[longitudeValue doubleValue];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    if ([self isValidCoordinate:coordinate])
    {
        NSString *pID = [[data valueForKey:kBarIdKey] stringValue];
        NSString *headerText = [[data valueForKey:kBarTitleKey] uppercaseString];
        NSString *subheaderText = [[data valueForKey:kBarStandFirstKey] uppercaseString];
        
        BAPlaceMark* aPlaceMark = [[BAPlaceMark alloc] initWithID:pID coordinate:coordinate header:headerText subheader:subheaderText];
        [self.allPlacemarks addObject:aPlaceMark];
        [self.mapView addAnnotation:aPlaceMark];
        
        [self centerMapForAnnotations];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isEqual:[self.mapView userLocation]])
        return nil;
    
	static NSString *annotationIdentifier = @"aPin";
    
    MKPinAnnotationView *aAnnotation = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (!aAnnotation)
    {
        aAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        aAnnotation.animatesDrop = NO;
        aAnnotation.canShowCallout = YES;
        aAnnotation.pinColor = MKPinAnnotationColorGreen;
    }
    
    [aAnnotation setAnnotation:annotation];
    
    return aAnnotation;
}

@end
