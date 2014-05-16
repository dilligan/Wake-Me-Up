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
@property (strong, nonatomic) IBOutlet UIButton *lineChoiceButton;
@property (strong, nonatomic) IBOutlet UITabBar *tabBar;
- (IBAction)numPressed:(id)sender;
- (IBAction)searchPressed:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *lineButtons;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lineLabels;
- (IBAction)lineChoice:(id)sender;
- (IBAction)linePressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;

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
    BOOL isLine;
    
}



@synthesize routeField, stepper, searchButton, stepperLabel, stopLabel, numField, indicator, acivityView, routeSearchTable, routeDirectionTable, stopTable, customKeyboard, numButtons, tabBar, stopImage, stopTypeLabel, lineButtons, lineLabels, lineChoiceButton;
- (void)viewDidLoad
{
    [super viewDidLoad];
    MGSetDark;
	// Do any additional setup after loading the view.
    routeField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" ROUTE #" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1]}];
    
    for (UIButton *lineButton in lineButtons) {
        lineButton.hidden = YES;
    }
    
    for (UILabel *lineLabel in lineLabels) {
        lineLabel.hidden = YES;
    }
    
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
    
    for (UIButton *lineButton in lineButtons) {
        [lineButton setAdjustsImageWhenHighlighted:NO];
        [lineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [lineButton setBackgroundImage:selBack forState:UIControlStateHighlighted];
    }
    
    [lineChoiceButton setAdjustsImageWhenHighlighted:NO];
    [lineChoiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [lineChoiceButton setBackgroundImage:selBack forState:UIControlStateHighlighted];
    
    [searchButton setAdjustsImageWhenHighlighted:NO];
    [searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [searchButton setBackgroundImage:selBack forState:UIControlStateHighlighted];
    
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
    
    isLine = NO;
    
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
        
        if ([stopTextPre rangeOfString:@" & "].location != NSNotFound) {
            stopTextPre = [[stopTextPre stringByReplacingOccurrencesOfString:@" & " withString:@"& "] mutableCopy];
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
    if (tableView == stopTable) {
        
        NSDictionary *stopd = stopArray[indexPath.row];
        [m setStopData:stopd];
        [m setIsStop:YES];
        [self.navigationController pushViewController:m animated:YES];
    } else if (tableView == routeSearchTable) {
        
        NSString *routeID = routeSearchArray[indexPath.row][@"routeID"];
        if (isLine) {
            routeID = [routeID stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
        
        startP;
        dispatch_async(dispatch_queue_create("router", 0), ^{
            
            NSData *routeDataD = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SWF(@"http://api.pugetsound.onebusaway.org/api/where/stops-for-route/%@.json?key=TEST&version=2", routeID)]] returningResponse:nil error:nil];
            NSDictionary *routeDict = [NSJSONSerialization JSONObjectWithData:routeDataD options:0 error:nil];
            NSArray *polylines = routeDict[@"data"][@"entry"][@"polylines"];
            [m setPolylines:polylines];
            [m setIsStop:NO];
            stopP;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:m animated:YES];
            });
        });
        
        
    }
    m.navigationItem.title = @"map";
    //NSLog(@"Accessory Row Tapped");
    
    
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
    phrase = [phrase capitalizedString];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"routeNum = %@", phrase];
    return [routeData filteredArrayUsingPredicate:filter];
}

-(NSArray *)directionsOfRoute:(NSString *)routeID {
    
    if (isLine) {
        routeID = [routeID stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    }
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
        if ([routeField.text isEqualToString:@"F - LINE"]) {
            MGAlert(@"UH-OH!", @"SORRY, THAT ROUTE DOESN'T EXIST JUST YET. PLEASE TRY AGAIN AFTER JUNE 24TH.");
            return YES;
        }
        
        [routeField resignFirstResponder];
        startP;
        routeDirectionTable.hidden = YES;
        stopTable.hidden = YES;
        [stopTable setContentOffset:CGPointZero];
        dispatch_async(dispatch_queue_create("routeSearch", 0), ^{
            NSString *searchPhrase = [routeField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if (isLine) {
                searchPhrase = [searchPhrase stringByReplacingOccurrencesOfString:@"-" withString:@" "];
            }
            
            NSArray *routes =[self searchRoutesWithPhrase:searchPhrase];
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



- (IBAction)lineChoice:(id)sender {
    
    isLine = !isLine;
    
    if (isLine) {
        [lineChoiceButton setTitle:@"123" forState:UIControlStateNormal];
        for (UIButton *lineButton in lineButtons) {
            lineButton.hidden = NO;
        }
        
        for (UILabel *lineLabel in lineLabels) {
            lineLabel.hidden = NO;
        }
        
        for (UIButton *routeButton in numButtons) {
            routeButton.hidden = YES;
        }
        
    } else {
        [lineChoiceButton setTitle:@"LINES" forState:UIControlStateNormal];
        for (UIButton *lineButton in lineButtons) {
            lineButton.hidden = YES;
        }
        
        for (UILabel *lineLabel in lineLabels) {
            lineLabel.hidden = YES;
        }
        
        for (UIButton *routeButton in numButtons) {
            routeButton.hidden = NO;
        }
    }
    
}

- (IBAction)linePressed:(id)sender {
    
    switch ([sender tag]) {
        case 1:
            routeField.text = @" A - LINE";
            break;
        case 2:
            routeField.text = @" B - LINE";
            break;
        case 3:
            routeField.text = @" C - LINE";
            break;
        case 4:
            routeField.text = @" D - LINE";
            break;
        case 5:
            routeField.text = @" E - LINE";
            break;
        case 6:
            routeField.text = @" F - LINE";
            break;
        default:
            break;
    }
}
@end




