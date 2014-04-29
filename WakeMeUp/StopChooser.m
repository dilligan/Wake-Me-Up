//
//  StopChooser.m
//  WakeMeUp
//
//  Created by Milo Gosnell on 3/18/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "StopChooser.h"
#import "GDataXMLNode.h"
#import "Map.h"
#import "NSString+NSString_AddressFormat.h"

@interface StopChooser () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *routeField;
@property (strong, nonatomic) IBOutlet UITextField *numField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *acivityView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation StopChooser {
    NSMutableArray *stopsArray;
    NSMutableArray *routes;
    NSDictionary *stopd;
    NSInteger stopNumStop;
    BOOL isRoute;
    BOOL isStop;
    NSDictionary *stopDictionary;    
    
}



@synthesize routeField, stepper, stepperLabel, stopLabel, numField, indicator, acivityView;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView.hidden = YES;
    self.tableView.dataSource = self;
    routeField.delegate = self;
    numField.delegate = self;
    self.tableView.delegate = self;
    isRoute = YES;
    isStop = NO;
    stopNumStop = (NSInteger)stepper.value;
    acivityView.hidden = YES;
    acivityView.layer.cornerRadius = 15.0f;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == routeField) {
        [routeField resignFirstResponder];
        [self searchRoutes];
    } else {
        [numField resignFirstResponder];
        [self searchStops];
    }
    return YES;
    
}



-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == routeField) {
        isRoute = YES;
        isStop = NO;
    } else {
        isStop = YES;
        isRoute = NO;
    }
    
}



-(void)searchRoutes {
    NSLog(@"Start");
    
    acivityView.hidden = NO;
    NSLog(@"Hidden: %@", [acivityView isHidden] ? @"YES" : @"NO");
    [indicator startAnimating];
    
    dispatch_queue_t download_queue = dispatch_queue_create("download", 0);
    
    dispatch_async(download_queue, ^{
        stopsArray = [NSMutableArray array];
        NSString *URL = [NSString stringWithFormat:@"http://api.pugetsound.onebusaway.org/api/where/stops-for-route/1_%@.xml?key=TEST&version=2", routeField.text];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
        //[request setValue:agentString forHTTPHeaderField:@"User-Agent"];
        NSData *xmlFile = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSError *er;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlFile options:0 error:&er];
        @try {
            NSArray *stops = [[doc nodesForXPath:@"//response/data/references/stops" error:&er][0] elementsForName:@"stop"];
            
            for (GDataXMLElement *stop in stops) {
                NSString *stopNum = [NSString stringWithFormat:@"%@", [(GDataXMLElement *)[stop elementsForName:@"code"][0] stringValue]];
                NSString *lat = [NSString stringWithFormat:@"%@", [(GDataXMLElement *)[stop elementsForName:@"lat"][0] stringValue]];
                NSString *lon = [NSString stringWithFormat:@"%@", [(GDataXMLElement *)[stop elementsForName:@"lon"][0] stringValue]];
                NSString *nameDir = [NSString stringWithFormat:@"%@", [(GDataXMLElement *)[stop elementsForName:@"name"][0] stringValue]];
                nameDir = [self formattedAdd:nameDir];
                NSString *stopId = [NSString stringWithFormat:@"%@", [(GDataXMLElement *)[stop elementsForName:@"id"][0] stringValue]];
                NSString *routeNum = [NSString stringWithFormat:@"%@", routeField.text];
                
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:stopNum, @"Stop #", lat, @"Lat", lon, @"Lon",nameDir, @"Name", stopId, @"Stop ID", routeNum, @"Route #", nil];
                [stopsArray addObject:dict];
            }
            /*
             NSString *lastName = nil;
             NSMutableArray *newArray = [NSMutableArray array];
             
             NSSortDescriptor *titleDes = [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES];
             NSArray *sortDesc = [NSArray arrayWithObject:titleDes];
             stopsArray = [[stopsArray sortedArrayUsingDescriptors:sortDesc] copy];
             */
            
            /*
             for (NSDictionary *d in stopsArray) {
             NSString *testTitle = [d objectForKey:@"Name"];
             if (![testTitle isEqualToString:lastName]) {
             [newArray addObject:d];
             lastName = testTitle;
             }
             }
             */
            /*
             NSSortDescriptor *stopDes = [[NSSortDescriptor alloc] initWithKey:@"Lat" ascending:YES];
             NSArray *sortDescs = [NSArray arrayWithObject:stopDes];
             stopsArray = [[newArray sortedArrayUsingDescriptors:sortDescs] copy];
             
             NSSortDescriptor *lonDes = [[NSSortDescriptor alloc] initWithKey:@"Lon" ascending:YES];
             NSArray *lonDescs = [NSArray arrayWithObject:lonDes];
             NSArray *lonArray = [[newArray sortedArrayUsingDescriptors:lonDescs] copy];
             
             
             float lonMax = [[lonArray lastObject] floatValue];
             float lonMin = [[lonArray firstObject] floatValue];
             float lonDifference = lonMax - lonMin;
             
             float latMax = [[stopsArray lastObject] floatValue];
             float latMin = [[stopsArray firstObject] floatValue];
             float latDifference = latMax - latMin;
             
             if (latDifference > lonDifference) {
             stopsArray = [[newArray sortedArrayUsingDescriptors:sortDescs] copy];
             } else if (lonDifference > latDifference) {
             stopsArray = [[newArray sortedArrayUsingDescriptors:lonDescs] copy];
             }
             */
            
            NSArray *stopGroups= [[doc nodesForXPath:@"//response/data/entry/stopGroupings/stopGrouping/stopGroups" error:&er][0] elementsForName:@"stopGroup"];
            NSArray *stopIdsHigh = [(GDataXMLElement *)stopGroups[1] elementsForName:@"stopIds"];
            NSArray *stopIdsLow = [(GDataXMLElement *)stopIdsHigh[0] elementsForName:@"string"];
            NSMutableArray *stopIds = [NSMutableArray array];
            for (GDataXMLElement *sE in stopIdsLow) {
                NSString *string = sE.stringValue;
                [stopIds addObject:string];
            }
            NSMutableArray *finalArray = [NSMutableArray array];
            for (NSString *idName in stopIds) {
                NSString *fname;
                for (NSDictionary *theDict in stopsArray) {
                    fname = [theDict objectForKey:@"Stop ID"];
                    
                    if ([fname isEqualToString:idName]) {
                        [finalArray addObject:theDict];
                        ;
                    }
                }
            }
            
            stopsArray = finalArray;
            
            

            NSLog(@"Hidden: %@", [acivityView isHidden] ? @"YES" : @"NO");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView setHidden:NO];
                [self.tableView reloadData];
            });

        }
        @catch (NSException *e) {
            dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Uh-oh!" message:@"Sorry but there is no route listed for that #. Please try again" delegate:nil cancelButtonTitle:@"Ok." otherButtonTitles:nil] show];
            });
        }
        @finally {
            dispatch_async(dispatch_get_main_queue(), ^{
                acivityView.hidden = YES;
                [indicator startAnimating];
            });
        }
        
        
        
    });
    
}


-(void)searchStops {
    acivityView.hidden = NO;
    [indicator startAnimating];
    dispatch_queue_t download_queue = dispatch_queue_create("downloader", 0);
    dispatch_async(download_queue, ^{
        routes = [NSMutableArray array];
        NSString *URL = [NSString stringWithFormat:@"http://api.pugetsound.onebusaway.org/api/where/stop/1_%@.xml?key=TEST", numField.text];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
        NSData *xmlFile = [NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:Nil];
        NSError *er;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlFile options:0 error:&er];
        @try {
            GDataXMLElement *stopInfoXML = [doc nodesForXPath:@"//response/data" error:Nil][0];
            NSString *stopNum = [NSString stringWithFormat:@"%@", [[stopInfoXML elementsForName:@"code"][0] stringValue]];
            NSString *lat = [NSString stringWithFormat:@"%@", [[stopInfoXML elementsForName:@"lat"][0] stringValue]];
            NSString *lon = [NSString stringWithFormat:@"%@", [[stopInfoXML elementsForName:@"lon"][0] stringValue]];
            NSString *nameDir = [NSString stringWithFormat:@"%@", [[stopInfoXML elementsForName:@"name"][0] stringValue]];
            nameDir = [self formattedAdd:nameDir];
            NSString *stopId = [NSString stringWithFormat:@"%@", [[stopInfoXML elementsForName:@"id"][0] stringValue]];
            stopDictionary = [NSDictionary dictionaryWithObjectsAndKeys:stopNum, @"Stop #", lat, @"Lat", lon, @"Lon",nameDir, @"Name", stopId, @"Stop ID", nil];
            
            
            GDataXMLElement *routesXML = [doc nodesForXPath:@"//response/data/routes" error:nil][0];
            NSArray *routesXMLArray = [routesXML elementsForName:@"route"];
            for (GDataXMLElement *route in routesXMLArray) {
                NSString *routeNum = [NSString stringWithFormat:@"%@", [[route elementsForName:@"shortName"][0] stringValue]];
                NSString *routeName = [NSString stringWithFormat:@"%@", [[route elementsForName:@"description"][0] stringValue]];
                NSString *routeID = [NSString stringWithFormat:@"%@", [[route elementsForName:@"id"][0] stringValue]];
                NSDictionary *routeDict = [NSDictionary dictionaryWithObjectsAndKeys:routeNum, @"#", routeName, @"Name", routeID, @"Route ID", nil];
                [routes addObject:routeDict];
                
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView setHidden:NO];
                [self.tableView reloadData];
            });
            
        }
        @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Uh-oh!" message:@"Sorry but that stop could not be found." delegate:nil cancelButtonTitle:@"Ok." otherButtonTitles:nil] show];
                [self.tableView setHidden:YES];
            });
            
        }
        @finally {
            dispatch_async(dispatch_get_main_queue(), ^{
                acivityView.hidden = YES;
                [indicator stopAnimating];
            });
        }
        
        
    });
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%@", isRoute ? @"YES" : @"NO");
    if (isRoute)
        return stopsArray.count;
    else
        return routes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isRoute) {
        if (stopsArray.count > 0) {
            static NSString *cellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            NSDictionary *stop = stopsArray[indexPath.row];
            cell.textLabel.text = [stop objectForKey:@"Name"];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Stop #: %@", [stop objectForKey:@"Stop #"]];
            
            
            return cell;
        }
        else {
            return nil;
        }
        //Is Stop
    } else {
        if (routes.count > 0) {
            static NSString *cellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            NSDictionary *theRoute = routes[indexPath.row];
            cell.textLabel.text = [theRoute objectForKey:@"#"];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [theRoute objectForKey:@"Name"]];
            return cell;
        } else {
            return nil;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isRoute) {
        [[NSUserDefaults standardUserDefaults] setObject:[stopsArray objectAtIndex:indexPath.row] forKey:@"stopKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSDictionary *first;
        NSDictionary *second;
        if (indexPath.row >= stopNumStop && indexPath.row <= stopsArray.count - stopNumStop) {
            first = stopsArray[indexPath.row - stopNumStop];
            second = stopsArray[indexPath.row + stopNumStop];
        } else if (indexPath.row < stopNumStop) {
            first = stopsArray[indexPath.row + stopNumStop];
            second = [NSDictionary dictionary];
        } else if (indexPath.row > stopsArray.count - stopNumStop) {
            first = [NSDictionary dictionary];
            second = stopsArray[indexPath.row - stopNumStop];
        }
        [[NSUserDefaults standardUserDefaults] setObject:@[first, second] forKey:@"nextStops"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.tableView.hidden = YES;
        stopLabel.text = [[stopsArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
        NSLog(@"%@ %@", first, second);
    } else {
        int index = (int)indexPath.row;
        NSString *routeID = [[routes objectAtIndex:index] objectForKey:@"Route ID"];
        acivityView.hidden = NO;
        [indicator startAnimating];
        
        dispatch_queue_t d = dispatch_queue_create("d", 0);
        dispatch_async(d, ^{
            stopsArray = [NSMutableArray array];
            NSString *URL = [NSString stringWithFormat:@"http://api.pugetsound.onebusaway.org/api/where/stops-for-route/%@.xml?key=TEST&version=2", routeID];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
            //[request setValue:agentString forHTTPHeaderField:@"User-Agent"];
            NSData *xmlFile = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSError *er;
            GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlFile options:0 error:&er];
            @try {
                NSArray *stops = [[doc nodesForXPath:@"//response/data/references/stops" error:&er][0] elementsForName:@"stop"];
                
                for (GDataXMLElement *stop in stops) {
                    NSString *stopNum = [NSString stringWithFormat:@"%@", [(GDataXMLElement *)[stop elementsForName:@"code"][0] stringValue]];
                    NSString *lat = [NSString stringWithFormat:@"%@", [(GDataXMLElement *)[stop elementsForName:@"lat"][0] stringValue]];
                    NSString *lon = [NSString stringWithFormat:@"%@", [(GDataXMLElement *)[stop elementsForName:@"lon"][0] stringValue]];
                    NSString *nameDir = [NSString stringWithFormat:@"%@", [(GDataXMLElement *)[stop elementsForName:@"name"][0] stringValue]];
                    nameDir = [self formattedAdd:nameDir];
                    NSString *stopId = [NSString stringWithFormat:@"%@", [(GDataXMLElement *)[stop elementsForName:@"id"][0] stringValue]];
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:stopNum, @"Stop #", lat, @"Lat", lon, @"Lon",nameDir, @"Name", stopId, @"Stop ID", nil];
                    [stopsArray addObject:dict];
                }
                
                NSArray *stopGroups= [[doc nodesForXPath:@"//response/data/entry/stopGroupings/stopGrouping/stopGroups" error:&er][0] elementsForName:@"stopGroup"];
                NSArray *stopIdsHigh = [(GDataXMLElement *)stopGroups[1] elementsForName:@"stopIds"];
                NSArray *stopIdsLow = [(GDataXMLElement *)stopIdsHigh[0] elementsForName:@"string"];
                NSMutableArray *stopIds = [NSMutableArray array];
                for (GDataXMLElement *sE in stopIdsLow) {
                    NSString *string = sE.stringValue;
                    [stopIds addObject:string];
                }
                NSMutableArray *finalArray = [NSMutableArray array];
                for (NSString *idName in stopIds) {
                    NSString *fname;
                    for (NSDictionary *theDict in stopsArray) {
                        fname = [theDict objectForKey:@"Stop ID"];
                        
                        if ([fname isEqualToString:idName]) {
                            [finalArray addObject:theDict];
                            ;
                        }
                    }
                }
                
                stopsArray = finalArray;
            
            @try {
                NSLog(@"%@", stopDictionary);
                NSLog(@"%@", stopsArray);
                int index = (int)[stopsArray indexOfObject:stopDictionary];
                NSLog(@"%d", index);

                NSMutableDictionary *theDict = [[stopsArray objectAtIndex:index] mutableCopy];
                [theDict setObject:[[routes objectAtIndex:indexPath.row] objectForKey:@"#"] forKey:@"Route #"];
                [[NSUserDefaults standardUserDefaults] setObject:[theDict copy]     forKey:@"stopKey"];
                
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSDictionary *first;
                NSDictionary *second;
                if (index >= stopNumStop && index <= stopsArray.count - stopNumStop) {
                    first = stopsArray[index- stopNumStop];
                    second = stopsArray[index + stopNumStop];
                } else if (index < stopNumStop) {
                    first = stopsArray[index + stopNumStop];
                    second = [NSDictionary dictionary];
                } else if (index > stopsArray.count - stopNumStop) {
                    first = [NSDictionary dictionary];
                    second = stopsArray[index - stopNumStop];
                }
                NSLog(@"%@ %@", first, second);
                [[NSUserDefaults standardUserDefaults] setObject:@[first, second] forKey:@"nextStops"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                stopLabel.text = [[stopsArray objectAtIndex:index] objectForKey:@"Name"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [tableView setHidden:YES];
                    });
                    
                });
                
                
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
                dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Don't know what happened there. Please try searching via route, or try again." delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                });
            }
            @finally {
                dispatch_async(dispatch_get_main_queue(), ^{
                    acivityView.hidden = YES;
                    [indicator stopAnimating];
                    
                });
            }
            }
            @catch (NSException *e) {
                dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Don't know what happened there. Please try searching via route, or try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                });
            }
            @finally {
                dispatch_async(dispatch_get_main_queue(), ^{
                    acivityView.hidden = YES;
                    [indicator stopAnimating];
                });
            }
            
            
        });
    
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    
    Map *m = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Map"];
    stopd = stopsArray[indexPath.row];
    [m setStopData:stopd];
    [self.navigationController pushViewController:m animated:YES];
    NSLog(@"Accessory Row Tapped");
    
    
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)stepperChange:(id)sender {
    stopNumStop = stepper.value;
    stepperLabel.text = [NSString stringWithFormat:@"%d", (int)stopNumStop];
}

-(NSString *)formattedAdd:(NSString *)address {
    address = [address capitalizedString];
    NSArray *directions = @[@"Ne", @"Se", @"Sw", @"Nw"];
    for (NSString *direc in directions) {
        if ([address rangeOfString:direc options:NSCaseInsensitiveSearch].location != NSNotFound) {
            address = [address stringByReplacingOccurrencesOfString:direc withString:[direc uppercaseString]];
        }
    }
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    NSString *pattern = @"[0-9]\\w+";
    NSString *patterntwo = @"\\s(?:St|Ave|Pl)";
    
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:nil];
    NSRegularExpression *regextwo = [NSRegularExpression regularExpressionWithPattern:patterntwo options:regexOptions error:nil];
    
    
    NSArray *matches = [regex matchesInString:address options:0 range:NSMakeRange(0, address.length)];
    for (NSTextCheckingResult *re in matches) {
        NSString *numSt = [address substringWithRange:re.range];
        address = [address stringByReplacingCharactersInRange:re.range withString:[numSt lowercaseString]];
    }
    
    NSArray *matchestwo = [regextwo matchesInString:address options:0 range:NSMakeRange(0, address.length)];
    NSMutableString *adMut = [address mutableCopy];
    int count = 0;
    for (NSTextCheckingResult *re in matchestwo) {
        //NSLog(@"%d", re.range.location);
        int index = (int)re.range.location + (int)re.range.length;
        [adMut insertString:@"." atIndex:index + (count == 1 ? 1:0)];
        count++;
    }
    address = [adMut copy];
    return address;
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end



