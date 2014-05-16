//
//  Map.m
//  WakeMeUp
//
//  Created by Milo Gosnell on 3/19/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "Map.h"
#import <MapKit/MapKit.h>
@interface Map () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation Map
@synthesize stopData, mapView, isStop, polylines;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [mapView setDelegate:self];
    if (isStop) {
    double lat = [[stopData objectForKey:@"Lat"] doubleValue];
    double lon = [[stopData objectForKey:@"Lon"] doubleValue];
    CLLocationCoordinate2D stopC = CLLocationCoordinate2DMake(lat, lon);

    mapView.region = MKCoordinateRegionMake(stopC, MKCoordinateSpanMake(0.01, 0.01));
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = stopC;
    annotation.title = [stopData objectForKey:@"Name"];
    [mapView addAnnotation:annotation];
    } else {
        [self traceRoute];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)traceRoute {
    
    CLLocationCoordinate2D one, two, three;
    int count = 0;
    for (NSDictionary *encodedPolyline in polylines) {
        count++;
        NSString *polylineString = encodedPolyline[@"points"];
        NSMutableArray *preCoords = [self decodePolyLine:polylineString];
        int numOfStops = (int)preCoords.count;
        CLLocationCoordinate2D coordinates[numOfStops];
        for (int i = 0; i < numOfStops; i++) {
            CLLocation *cllocation = preCoords[i];
            CLLocationCoordinate2D coordinate = cllocation.coordinate;
            coordinates[i] = coordinate;
            if (count == 1) {
            if (i == 0) {
                one = coordinate;
            }
            if (i == numOfStops - 1) {
                two = coordinate;
            }
            
            if (i == round(numOfStops/2)) {
                three = coordinate;
            }
            }
        }
        MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numOfStops];
        [mapView addOverlay:polyLine];
    }
    
    double oneD = fabs(one.latitude - two.latitude);
    double twoD = fabs(one.longitude - two.longitude);
    
    [mapView setRegion:MKCoordinateRegionMake(three, MKCoordinateSpanMake(oneD, twoD)) animated:YES];
    
}

-(NSMutableArray *)decodePolyLine:(NSString *)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    //[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        printf("[%f,", [latitude doubleValue]);
        printf("%f]\n", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *polyRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    polyRenderer.strokeColor = [UIColor colorWithRed:3.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1];
    polyRenderer.lineWidth = 3.0;
    return polyRenderer;
}


@end
