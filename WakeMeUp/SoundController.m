//
//  SoundController.m
//  WakeMeUp
//
//  Created by Milo Gosnell on 4/29/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "SoundController.h"
#import "SongCell.h"
#import "SoundCell.h"
#import "SliderCell.h"
#import "UIColor+FlatUI.h"
#import "UISlider+FlatUI.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
#import "DQAlertView.h"
@interface SoundController () <MPMediaPickerControllerDelegate, DQAlertViewDelegate>

@end

@implementation SoundController {
    NSArray *soundArray;
    AVAudioPlayer *av;
    NSIndexPath *lastIndex;
    MPMediaPickerController *picker;
    BOOL shouldSong;
    NSString *songName;
    double sliderValue;
    double prevVol;
    MGCreateDark;
    UISlider *vSlider;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    soundArray = @[@"Apex", @"Bulletin",@"Circuit",@"Crystals",@"Night Owl", @"Presto", @"Ripples",@"Silk", @"Summit",@"Waves"];
    //[av setVolume:1.0];
    //[av setNumberOfLoops:0];
    //[av prepareToPlay];
    [self.tableView reloadData];
    prevVol = [[MPMusicPlayerController applicationMusicPlayer] volume];
    [[MPMusicPlayerController iPodMusicPlayer] pause];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"volume"] != nil)
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:[[[NSUserDefaults standardUserDefaults] objectForKey:@"volume"] doubleValue]];
    else
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    MPVolumeView *v = [[MPVolumeView alloc] initWithFrame:CGRectMake(400, 100, 1, 1)];
    vSlider = nil;
    vSlider = (UISlider *)[v subviews][0];
    [vSlider addTarget:self action:@selector(changed) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:v];
}

-(void)changed{
    sliderValue = vSlider.value;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)viewWillAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"volume"]) {
        sliderValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"volume"] doubleValue];
    } else {
        sliderValue = 0.5;
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"playSound"]) {
        lastIndex = [NSIndexPath indexPathForRow:[[[NSUserDefaults standardUserDefaults] objectForKey:@"soundIdx"] intValue] inSection:1];
    } else {
        lastIndex = [NSIndexPath indexPathForRow:2 inSection:1];
        [[NSUserDefaults standardUserDefaults] setObject:@"Apex" forKey:@"soundName"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"playSound"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"playSong"]) {
        shouldSong = [[NSUserDefaults standardUserDefaults] boolForKey:@"playSong"];
        lastIndex = nil;
        MPMediaQuery *query = [MPMediaQuery songsQuery];
        MPMediaPropertyPredicate *pred = [MPMediaPropertyPredicate predicateWithValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"songID"] forProperty:MPMediaItemPropertyPersistentID];
        [query addFilterPredicate:pred];
        NSArray *mediaItems = [query items];
        songName = [[mediaItems[0] valueForProperty:MPMediaItemPropertyTitle] uppercaseString];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
    } else {
        return 2 + soundArray.count;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    SliderCell *sliderCell = (SliderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [[NSUserDefaults standardUserDefaults] setObject:@(sliderCell.volumeSlider.value) forKey:@"volume"];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:prevVol];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *SliderCellID = @"SliderCell";
        SliderCell *sliderCell = (SliderCell *)[tableView dequeueReusableCellWithIdentifier:SliderCellID];
        if (sliderCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SliderCell" owner:self options:nil];
            sliderCell = [nib objectAtIndex:0];
        }
    
        sliderCell.backgroundColor = [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0];
        [sliderCell.volumeSlider configureFlatSliderWithTrackColor:[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.15 alpha:1.0] progressColor:[UIColor tealDetailColor] thumbColor:[UIColor tealColor]];
        sliderCell.volumeSlider.value = sliderValue;
        [sliderCell.volumeSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    return sliderCell;
    }

    if (indexPath.section == 1) {
        static NSString *SoundCellID = @"SoundCell";
        SoundCell *soundCell = (SoundCell *)[tableView dequeueReusableCellWithIdentifier:SoundCellID];
        if (soundCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SoundCell" owner:self options:nil];
            soundCell = [nib objectAtIndex:0];
        }
        
        static NSString *SongCellID = @"SongCell";
        SongCell *songCell = (SongCell *)[tableView dequeueReusableCellWithIdentifier:SongCellID];
        if (songCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SongCell" owner:self options:nil];
            songCell = [nib objectAtIndex:0];
        }
        UIView *selectedColor = [[UIView alloc] init];
        selectedColor.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.19 alpha:1];
        soundCell.backgroundColor = [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0];
        songCell.backgroundColor = [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1.0];
        soundCell.selectedBackgroundView = selectedColor;
        songCell.selectedBackgroundView = selectedColor;
        
        
        if (indexPath.row == 0) {
            soundCell.soundLabel.text = @"NONE";
        } else if (indexPath.row > 1) {
            soundCell.soundLabel.text = [soundArray[indexPath.row - 2] uppercaseString];
        }
        
        if (indexPath.row == 1) {
            if (shouldSong)
                songCell.songLabel.text = songName;
            else
                songCell.songLabel.text = @"CHOOSE A SONG...";
            
        }
        
        if ([indexPath compare:lastIndex] == NSOrderedSame) {
            soundCell.checkImage.hidden = NO;
        } else {
            soundCell.checkImage.hidden = YES;
        }
        
        if (indexPath.row == 0 || indexPath.row > 1) {
            return soundCell;
        } else {
            return songCell;
        }
        
        
    }

    // Configure the cell...
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"VOLUME";
    } else {
        return @"ALARM SOUND";
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
    SliderCell *sliderCell = (SliderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    sliderValue = sliderCell.volumeSlider.value;
    if (indexPath.section == 1) {
        
    
    if (indexPath.row > 1) {
        [[NSUserDefaults standardUserDefaults] setObject:soundArray[indexPath.row - 2] forKey:@"soundName"];
        [[NSUserDefaults standardUserDefaults] setObject:@(indexPath.row) forKey:@"soundIdx"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"playSound"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"playSong"];
        av = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:soundArray[indexPath.row - 2] withExtension:@"mp3"] error:nil];
        av.volume = 1.0f;
        av.numberOfLoops = 0;
        [av play];
        shouldSong = NO;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"songID"];
        
    }
    if (indexPath.row == 0) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"playSound"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"playSong"];
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"soundIdx"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"songID"];
        

        shouldSong = NO;
    }
    lastIndex = indexPath;
    
    if (indexPath.row == 1) {
        picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
        picker.allowsPickingMultipleItems = NO;
        picker.title = NSLocalizedString(@"CHOOSE A SONG", @"CHOOSE A SONG");
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
    
    [self.tableView reloadData];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

-(void)sliderChanged:(UISlider *)slider {
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:slider.value];
    sliderValue = slider.value;
}

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    [self dismissViewControllerAnimated:YES completion:nil];
    //playa = [MPMusicPlayerController iPodMusicPlayer];
    //[playa setQueueWithItemCollection:mediaItemCollection];
    lastIndex = nil;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"playSound"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"playSong"];
    shouldSong = YES;
    NSArray *music = [mediaItemCollection items];
    MPMediaItem *song = music[0];
    NSNumber *value = [song valueForProperty:MPMediaItemPropertyPersistentID];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"songID"];
    songName = [[song valueForProperty:MPMediaItemPropertyTitle] uppercaseString];
    [self.tableView reloadData];
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
