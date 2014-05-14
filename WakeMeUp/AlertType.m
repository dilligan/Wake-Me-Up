//
//  AlertType.m
//  WakeMeUp
//
//  Created by Milo Gosnell on 5/12/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "AlertType.h"
#import "TypeCell.h"
#import "SegmentCell.h"

@interface AlertType ()

@end

@implementation AlertType {
    NSArray *stopsArray;
    NSArray *milesArray;
    NSIndexPath *lastIndex;
    BOOL stops;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    stopsArray = @[@"ONE", @"TWO", @"THREE", @"FOUR", @"FIVE"];
    milesArray = @[@"TENTH", @"QUARTER", @"HALF", @"ONE", @"TWO"];
    stops = YES;
    lastIndex = [NSIndexPath indexPathForRow:[[[NSUserDefaults standardUserDefaults] objectForKey:@"stopAlertIdx"] integerValue] - 1 inSection:1];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    
    if (section == 1) {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
    static NSString *SegmentCellID = @"SegmentCell";
    SegmentCell *segmentCell = (SegmentCell *)[tableView dequeueReusableCellWithIdentifier:SegmentCellID];
    if (segmentCell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SegmentCell" owner:self options:nil];
        segmentCell = [nib objectAtIndex:0];
    }
        segmentCell.backgroundColor = [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0];
        
        [segmentCell.segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
        [segmentCell.segment setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateSelected];
        return segmentCell;
    }
    
    if (indexPath.section == 1) {
        static NSString *TypeCellID = @"TypeCell";
        TypeCell *typeCell = (TypeCell *)[tableView dequeueReusableCellWithIdentifier:TypeCellID];
        if (typeCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TypeCell" owner:self options:nil];
            typeCell = [nib objectAtIndex:0];
        }
        
        typeCell.backgroundColor = [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0];
        
        if (stops) {
            typeCell.typeLabel.text = stopsArray[indexPath.row];
        } else {
            typeCell.typeLabel.text = milesArray[indexPath.row];
        }
        
        if ([indexPath compare:lastIndex] == NSOrderedSame) {
            typeCell.checkImage.hidden = NO;
        } else {
            typeCell.checkImage.hidden = YES;
        }
        
        
        UIView *selectedColor = [[UIView alloc] init];
        selectedColor.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.19 alpha:1];
        typeCell.selectedBackgroundView = selectedColor;
        
        return typeCell;
        
    }
    // Configure the cell...
    
    return 0;
}

-(void)segmentChanged:(id)sender {
    if ([sender selectedSegmentIndex] == 0) {
        stops = YES;
    } else {
        stops = NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:stops forKey:@"stopAlertType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"ALERT TYPE";
    } else {
        if (stops) {
            return @"STOPS AWAY";
        } else {
            return @"MILES AWAY";
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 55.0;
    } else {
        return 44.0;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    [header.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *header = @"customHeader";
    
    UITableViewHeaderFooterView *vHeader;
    
    vHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    
    if (!vHeader) {
        vHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
        vHeader.textLabel.textColor = [UIColor whiteColor];
        vHeader.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    }
    
    vHeader.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    return vHeader;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        lastIndex = indexPath;
        [self.tableView reloadData];
        [[NSUserDefaults standardUserDefaults] setObject:@(indexPath.row + 1) forKey:@"stopAlertIdx"];
        [[NSUserDefaults standardUserDefaults] setBool:stops forKey:@"stopAlertType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
