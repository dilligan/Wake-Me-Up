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
#import "UIColor+FlatUI.h"
#import "UIImage+FlatUI.h"
#import "DQAlertView.h"


@interface StopChooser () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DQAlertViewDelegate, UITabBarDelegate>
@property (strong, nonatomic) IBOutlet UILabel *stopTypeLabel;
@property (strong, nonatomic) IBOutlet UITextField *routeField;
@property (strong, nonatomic) IBOutlet UITextField *numField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *acivityView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UITableView *routeSearchTable;
@property (strong, nonatomic) IBOutlet UITableView *routeDirectionTable;
@property (strong, nonatomic) IBOutlet UITableView *stopTable;
@property (strong, nonatomic) IBOutlet UIView *customKeyboard;
@property (strong, nonatomic) IBOutlet UIImageView *stopImage;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numButtons;
@property (strong, nonatomic) IBOutlet UITabBar *tabBar;
- (IBAction)numPressed:(id)sender;
- (IBAction)searchPressed:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;

@end

@implementation StopChooser {
    //NSMutableArray *stopsArray;
    //NSMutableArray *routes;
    //NSDictionary *stopd;
    NSInteger stopNumStop;
    BOOL isRoute;
    BOOL isStop;
    NSDictionary *stopDictionary;
    NSArray *routeData;
    NSArray *routeSearchArray;
    NSArray *routeDirectionArray;
    NSArray *stopArray;
    NSArray *tempStopArray;
    CGRect origFr;
    MGCreateDark;
    CGRect twoImageFrame;
    CGRect threeImageFrame;
    CGRect labelFrame;
    
}



@synthesize routeField, stepper, stepperLabel, stopLabel, numField, indicator, acivityView, routeSearchTable, routeDirectionTable, stopTable, customKeyboard, numButtons, tabBar, stopImage, stopTypeLabel;
- (void)viewDidLoad
{
    [super viewDidLoad];
    MGSetDark;
	// Do any additional setup after loading the view.
    routeField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" ROUTE #" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1]}];
    
    self.tableView.hidden = YES;
    self.tableView.dataSource = self;
    routeField.delegate = self;
    numField.delegate = self;
    self.tableView.delegate = self;
    isRoute = YES;
    isStop = NO;
    routeSearchTable.contentInset = UIEdgeInsetsMake(-20, 0, -20, 0);
    stopTable.contentInset = UIEdgeInsetsMake(-20, 0, -20, 0);
    routeDirectionTable.contentInset = UIEdgeInsetsMake(-20, 0, -20, 0);
    
    routeSearchTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    routeDirectionTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    stopTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"stopAlertType"] == nil) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"stopAlertType"];
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"stopAlertIdx"];
        
        UIFont *light = [UIFont fontWithName:@"Helvetica-Light" size:20];
        UIFont *regular = [UIFont fontWithName:@"Helvetica" size:20];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"STOPS AWAY | " attributes:@{NSFontAttributeName: light}];
        NSAttributedString *stopTypeText = [[NSAttributedString alloc] initWithString:@"TWO" attributes:@{NSFontAttributeName: regular}];
        [text appendAttributedString:stopTypeText];
        stopTypeLabel.attributedText = text;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    stopNumStop = (NSInteger)stepper.value;
    acivityView.hidden = YES;
    acivityView.layer.cornerRadius = 15.0f;
    NSData *routeNSData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RouteData" ofType:@"json"]];
    routeData = [NSJSONSerialization JSONObjectWithData:routeNSData options:0 error:nil];
    stopTable.hidden = YES;
    routeField.inputView = customKeyboard;
    CGFloat w = 40.0f;
    UIButton *clear = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, w, w)];
    [clear setImage:[UIImage imageNamed:@"Clear"] forState:UIControlStateNormal];
    [clear setImage:[UIImage imageNamed:@"ClearSel"] forState:UIControlStateHighlighted];
    [clear addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    
    
    routeField.rightView = clear;
    routeField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    UIImage *selBack = [UIImage imageWithColor:[UIColor colorWithWhite:0.6 alpha:1] cornerRadius:0.0f];
    
    for (UIButton *numButton in numButtons) {
        [numButton setAdjustsImageWhenHighlighted:NO];
        [numButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [numButton setBackgroundImage:selBack forState:UIControlStateHighlighted];
    }
    
    tabBar.selectedItem = [tabBar items][0];
    labelFrame = stopLabel.frame;
    stopLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopName"];
    [stopLabel sizeToFit];
    
    twoImageFrame = stopImage.frame;
    threeImageFrame = CGRectMake(twoImageFrame.origin.x, twoImageFrame.origin.y + 10, twoImageFrame.size.width, twoImageFrame.size.height);
    
    int height = (int)[self getNumberOfLines:stopLabel];
    
    if (height == 48) {
        stopImage.frame = twoImageFrame;
    } else if (height == 72) {
        stopImage.frame = threeImageFrame;
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"stopAlertType"]) {
        
        BOOL isStopType = [[NSUserDefaults standardUserDefaults] boolForKey:@"stopAlertType"];
        
        if (isStopType) {
            NSNumberFormatter *n = [[NSNumberFormatter alloc] init];
            [n setNumberStyle:NSNumberFormatterSpellOutStyle];
            
            NSString *stopTypeNum = [[n stringFromNumber:[[NSUserDefaults standardUserDefaults] objectForKey:@"stopAlertIdx"]] uppercaseString];
            
            UIFont *light = [UIFont fontWithName:@"Helvetica-Light" size:20];
            UIFont *regular = [UIFont fontWithName:@"Helvetica" size:20];
            
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"STOPS AWAY | " attributes:@{NSFontAttributeName: light}];
            
            NSAttributedString *stopTypeText = [[NSAttributedString alloc] initWithString:stopTypeNum attributes:@{NSFontAttributeName: regular}];
            
            [text appendAttributedString:stopTypeText];
            
            stopTypeLabel.attributedText = text;
        }
    }
}

-(NSInteger)getNumberOfLines:(id)obj {
    UILabel *label = (UILabel *)obj;
    CGSize maxSize = CGSizeMake(label.frame.size.width, MAXFLOAT);
    
    CGRect labelRect = [label.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: label.font} context:nil];
    return labelRect.size.height;
}

-(void)clear {
    routeField.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)doneButton {
    [routeField resignFirstResponder];
    [self textFieldShouldReturn:routeField];
}

/*
 -(void)searchRoutes {
 NSLog(@"Start");
 
 acivityView.hidden = NO;
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
 
 NSString *lastName = nil;
 NSMutableArray *newArray = [NSMutableArray array];
 
 NSSortDescriptor *titleDes = [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES];
 NSArray *sortDesc = [NSArray arrayWithObject:titleDes];
 stopsArray = [[stopsArray sortedArrayUsingDescriptors:sortDesc] copy];
 
 
 
 for (NSDictionary *d in stopsArray) {
 NSString *testTitle = [d objectForKey:@"Name"];
 if (![testTitle isEqualToString:lastName]) {
 [newArray addObject:d];
 lastName = testTitle;
 }
 }
 
 
 NSSortDescriptor *stopDes = [[NSSortDescriptor alloc] initWithKey:@"Lat" ascending:YES];
 NSArray *sortDescs = [NSArray arrayWithObject:stopDes];
 stopsArray = [[newArray sortedArrayUsingDescriptors:sortDescs] copy];
 
 NSSortDescriptor *lonDes = [[NSSortDescriptor alloc] initWithKey:@"Lon" ascending:YES];
 NSArray *lonDescs = [NSArray arrayWithObject:lonDes];
 NSArray *lonArray = [[newArray sortedArrayUsingDescriptors:lonDescs] copy];
 
 
 double lonMax = [[lonArray lastObject] doubleValue];
 double lonMin = [[lonArray firstObject] doubleValue];
 double lonDifference = lonMax - lonMin;
 
 double latMax = [[stopsArray lastObject] doubleValue];
 double latMin = [[stopsArray firstObject] doubleValue];
 double latDifference = latMax - latMin;
 
 if (latDifference > lonDifference) {
 stopsArray = [[newArray sortedArrayUsingDescriptors:sortDescs] copy];
 } else if (lonDifference > latDifference) {
 stopsArray = [[newArray sortedArrayUsingDescriptors:lonDescs] copy];
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
 */

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    [header.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == routeSearchTable)
        return @"CHOOSE A ROUTE";
    if (tableView == routeDirectionTable)
        return @"CHOOSE A DIRECTION";
    if (tableView == stopTable)
        return @"CHOOSE A STOP";
    return @"";
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == routeSearchTable)
        return routeSearchArray.count;
    if (tableView == routeDirectionTable)
        return routeDirectionArray.count;
    if (tableView == stopTable)
        return stopArray.count;
    
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (tableView == routeSearchTable) {
        NSDictionary *routeDetails = routeSearchArray[indexPath.row];
        cell.textLabel.text = [routeDetails[@"routeName"] uppercaseString];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = [SWF(@"Route %@", routeDetails[@"routeNum"]) uppercaseString];
    }
    
    if (tableView == routeDirectionTable) {
        NSDictionary *directionDetails = routeDirectionArray[indexPath.row];
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = directionDetails[@"directionName"];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    if (tableView == stopTable) {
        NSDictionary *stopDetails = stopArray[indexPath.row];
        cell.textLabel.text = stopDetails[kName];
        //NSLog(@"%@", stopDetails);
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = SWF(@"Stop #: %@", stopDetails[@"Stop #"]);
        
    }
    
    
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:0.08 alpha:1];
    } else {
        cell.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
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
     */
    
    if (tableView == routeSearchTable) {
        NSDictionary *routeDict = routeSearchArray[indexPath.row];
        startP;
        dispatch_async(dispatch_queue_create("searchDir", 0), ^{
            NSArray *directions = [self directionsOfRoute:routeDict[@"routeID"]];
            routeDirectionArray = directions;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [routeDirectionTable setHidden:NO];
                [routeDirectionTable reloadData:YES];
                double delayInSeconds = 0.4;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    routeSearchTable.hidden = YES;
                    routeSearchArray = nil;
                });
            });
            stopP;
        });
    }
    
    if (tableView == routeDirectionTable) {
        NSDictionary *direcDict = routeDirectionArray[indexPath.row];
        startP;
        dispatch_async(dispatch_queue_create("searchStop", 0), ^{
            NSArray *stops = [self stopsForRoute:direcDict[@"routeID"] direction:[direcDict[@"directionIdx"] intValue]];
            stopArray = stops;
            NSMutableArray *paths = [NSMutableArray array];
            for (int i = 0 ; i < stopArray.count; i++) {
                [paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [stopTable reloadData:YES];
                double delayInSeconds = 0.4;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    routeDirectionTable.hidden = YES;
                    routeDirectionArray = nil;
                });
                
            });
            stopP;
        });
    }
    
    if (tableView == stopTable) {
        [[NSUserDefaults standardUserDefaults] setObject:stopArray[indexPath.row] forKey:@"stopKey"];
        
        
        NSMutableString *stopTextPre = [stopArray[indexPath.row] objectForKey:kName];
        
        if ([stopTextPre rangeOfString:@"&"].location != NSNotFound) {
            [stopTextPre insertString:@"\n" atIndex:[stopTextPre rangeOfString:@"&"].location];
        }
        
        if ([stopTextPre rangeOfString:@" - "].location != NSNotFound) {
            stopTextPre = [[stopTextPre stringByReplacingOccurrencesOfString:@" - " withString:@"\n"] mutableCopy];
        }
        stopLabel.frame = labelFrame;
        stopLabel.text = stopTextPre;
        [stopLabel sizeToFit];
        
        [[NSUserDefaults standardUserDefaults] setObject:stopTextPre forKey:@"stopName"];
        
        
        int idx = (int)indexPath.row;
        NSMutableArray *stopsOne = [NSMutableArray array];
        for (int i = idx - 1; i > idx - 1 - 5; i--) {
            if (i == -1)
                break;
            [stopsOne addObject:stopArray[i]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:stopsOne forKey:@"stopSelOne"];
        
        NSMutableArray *stopsTwo = [NSMutableArray array];
        for (int i = idx + 1; i < idx + 1 + 5; i++) {
            if (i == stopArray.count)
                break;
            [stopsTwo addObject:stopArray[i]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:stopsTwo forKey:@"stopSelTwo"];
        
        int height = (int)[self getNumberOfLines:stopLabel];
        if (height == 48) {
            stopImage.frame = twoImageFrame;
        } else if (height == 72) {
            stopImage.frame = threeImageFrame;
            NSLog(@"%@", NSStringFromCGRect(stopImage.frame));
        }
        [UIView transitionWithView:stopTable duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:NULL completion:NULL];
        stopTable.hidden = YES;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    
    Map *m = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Map"];
    NSDictionary *stopd = stopArray[indexPath.row];
    [m setStopData:stopd];
    m.navigationItem.title = @"map";
    [self.navigationController pushViewController:m animated:YES];
    //NSLog(@"Accessory Row Tapped");
    
    
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)stepperChange:(id)sender {
    stopNumStop = stepper.value;
    stepperLabel.text = [NSString stringWithFormat:@"%d", (int)stopNumStop];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)DQAlertViewCancelButtonClicked {
    MGHideDark;
    [routeField becomeFirstResponder];
}

-(void)updateBusImage:(BOOL)two {
    
    
    
}

#pragma mark - Bus Data

-(NSArray *)searchRoutesWithPhrase:(NSString *)phrase {
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"routeNum = %@", phrase];
    return [routeData filteredArrayUsingPredicate:filter];
}

-(NSArray *)directionsOfRoute:(NSString *)routeID {
    
    NSData *JSONRouteData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.pugetsound.onebusaway.org/api/where/stops-for-route/%@.json?key=TEST&version=2", routeID]]] returningResponse:nil error:nil];
    NSArray *routeDirectionGroup = [NSJSONSerialization JSONObjectWithData:JSONRouteData options:0 error:nil][@"data"][@"entry"][@"stopGroupings"][0][@"stopGroups"];
    NSMutableArray *directionArray = [NSMutableArray array];
    
    for (NSDictionary *direction in routeDirectionGroup) {
        int preDID = [direction[@"id"] intValue];
        preDID = (preDID == 1) ? 0 : 1;
        NSString *dName = direction[@"name"][@"name"];
        NSString *dId = [@(preDID) stringValue];
        [directionArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:dName, @"directionName", dId, @"directionIdx", routeID, @"routeID", nil]];
    }
    return [directionArray copy];
}

-(NSArray *)stopsForRoute:(NSString *)routeID direction:(int)direction {
    
    NSData *JSONRouteData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.pugetsound.onebusaway.org/api/where/stops-for-route/%@.json?key=TEST&version=2", routeID]]] returningResponse:nil error:nil];
    NSDictionary *masterJSONData = [NSJSONSerialization JSONObjectWithData:JSONRouteData options:0 error:nil][@"data"];
    NSArray *masterStops = masterJSONData[@"references"][@"stops"];
    
    NSMutableArray *masterStopsFinal = [NSMutableArray array];
    
    for (NSDictionary *stop in masterStops) {
        
        NSString *stopNum = stop[@"code"];
        NSString *lat = stop[@"lat"];
        NSString *lon = stop[@"lon"];
        NSString *nameB = stop[@"name"];
        NSString *nameDir = [nameB formatAddress];
        nameDir = [nameDir uppercaseString];
        NSString *stopId = stop[@"id"];
        NSString *routeNum = [routeID substringFromIndex:2];
        NSDictionary *stopDict = [NSDictionary dictionaryWithObjectsAndKeys:stopNum, kStop_Num, lat, kLat, lon, kLon, nameDir, kName, stopId, kStop_ID, routeNum, kRoute_Num, nil];
        [masterStopsFinal addObject:stopDict];
    }
    
    NSArray *stopsInOrder = masterJSONData[@"entry"][@"stopGroupings"][0][@"stopGroups"][direction][@"stopIds"];
    
    NSMutableArray *finalStops = [NSMutableArray array];
    
    for (NSString *stopID in stopsInOrder) {
        for (NSDictionary *stop in masterStopsFinal) {
            
            NSString *fname = [stop objectForKey:@"Stop ID"];
            if ([fname isEqualToString:stopID]) {
                [finalStops addObject:stop];
                
            }
        }
    }
    
    return finalStops;
}

#pragma mark - Textfield Methods
- (IBAction)numPressed:(id)sender {
    NSString *newString;
    if ([routeField.text isEqualToString:@""])
        newString = SWF(@" %d", (int)[sender tag]);
    else
        newString = SWF(@"%@%d", routeField.text, (int)[sender tag]);
    routeField.text = newString;
}

- (IBAction)searchPressed:(id)sender {
    [self textFieldShouldReturn:routeField];
}

- (IBAction)dismissKeyboard:(id)sender {
    [routeField resignFirstResponder];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == routeField) {
        [routeField resignFirstResponder];
        startP;
        routeDirectionTable.hidden = YES;
        stopTable.hidden = YES;
        [stopTable setContentOffset:CGPointZero];
        dispatch_async(dispatch_queue_create("routeSearch", 0), ^{
            NSArray *routes =[self searchRoutesWithPhrase:[routeField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
            if (routes.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MGAlert(@"UH-OH!", @"NO ROUTES WERE FOUND. PLEASE TRY AGAIN");
                });
            } else {
                //if (routes.count == 1) {
                //    NSArray *directions = [self directionsOfRoute:routes[0][@"routeID"]];
                //}
                routeSearchArray = routes;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [routeSearchTable setHidden:NO];
                    [routeSearchTable reloadData:YES];
                });
                //updateTable(routeSearchTable);
            }
            stopP;
        });
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



@end




