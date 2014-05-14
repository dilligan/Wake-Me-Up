//
//  ToneTable.m
//  WakeMeUp
//
//  Created by Milo Gosnell on 3/19/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "ToneTable.h"
#import <AVFoundation/AVFoundation.h>
@interface ToneTable ()
- (IBAction)dismiss:(id)sender;

@end

@implementation ToneTable {
    
    NSArray *songList;
    NSArray *songCodes;
    NSIndexPath *lastIndexPath;
    AVAudioPlayer *ap;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    songList = [NSArray arrayWithObjects:@"Apex", @"Bulletin", @"Circuit", @"Crystals", @"Night Owl", @"Presto", @"Ripples", @"Silk", @"Summit", @"Waves", nil];
    songCodes = [NSArray arrayWithObjects:@"Apex.wav", @"Bulletin.wav", @"Circuit.wav", @"Crystals.wav", @"Night Owl.wav", @"Presto.wav", @"Ripples.wav", @"Silk.wav", @"Summit.wav", @"Waves.wav", nil];
    
   
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return songList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = songList[indexPath.row];
    
    if ([indexPath compare:lastIndexPath] == NSOrderedSame) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    lastIndexPath = indexPath;
    [self.tableView reloadData];
    [[NSUserDefaults standardUserDefaults] setObject:songCodes[indexPath.row] forKey:@"songCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [ap stop];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], [[NSUserDefaults standardUserDefaults] objectForKey:@"songCode"]]];
    NSError *er;
    ap = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&er];
    ap.numberOfLoops = -1;
    [ap prepareToPlay];
    [ap play];
    
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
