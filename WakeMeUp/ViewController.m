//
//  ViewController.m
//  WakeMeUp
//
//  Created by Milo Gosnell on 3/18/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "ViewController.h"
#import "StopChooser.h"
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "ToneNavController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>
#import "UIColor+FlatUI.h"
#import "FUISwitch.h"
#import "DQAlertView.h"
@interface ViewController () <UITextFieldDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, MPMediaPickerControllerDelegate, DQAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *chooseLocLabel;
@property (strong, nonatomic) IBOutlet UILabel *locLabel;
- (IBAction)locationChoice:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *locTypeLabel;
@property (strong, nonatomic) IBOutlet UITextField *stopChooser;
@property (strong, nonatomic) IBOutlet UINavigationBar *topBar;
@property (strong, nonatomic) IBOutlet UISlider *slider;
-(void)sound;
- (IBAction)chooseSound:(id)sender;
@property (strong, nonatomic) IBOutlet FUISwitch *vibSwith;

@end

@implementation ViewController {
    CLLocationManager *locationManager;
    CLCircularRegion *region1;
    CLCircularRegion *region2;
    CLCircularRegion *region3;
    BOOL canPushAlarm;
    AVAudioPlayer *ap;
    NSTimer *vibrateTimer;
    NSTimer *soundTimer;
    NSTimer *bothTimer;
    int count;
    BOOL shouldVibrate;
    BOOL shouldSound;
    double vibrateLength;
    MPMusicPlayerController *playa;
    AVQueuePlayer *queuePlayer;
    NSURL *songURL;
    double soundLength;
	double prevVol;
    BOOL musicPlaying;
    BOOL tracking;
    CGRect frame;
    MGCreateDark;
    
}
@synthesize stopChooser, vibrateLabel, vibrateTime, songSegment, songTextField, locationField, chooseLocLabel, locLabel, locTypeLabel, topBar, slider, vibSwith, switchBack, soundLabel;
- (void)viewDidLoad
{
    [super viewDidLoad];
    stopChooser.delegate = self;
    canPushAlarm = YES;
    count = 0;
    vibrateTime.selectedSegmentIndex = 1;
    songSegment.selectedSegmentIndex = 0;
    songTextField.delegate = self;
    
    shouldSound = YES;
    shouldVibrate = YES;
    topBar.clipsToBounds = YES;
    
    [slider setThumbImage:[UIImage imageNamed:@"SliderImage.png"] forState:UIControlStateNormal];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    vibSwith.onColor = [UIColor grayDetailColor];
    vibSwith.offColor = [UIColor tealColor];
    vibSwith.onBackgroundColor = [UIColor tealColor];
    vibSwith.offBackgroundColor = [UIColor grayDetailColor];
    vibSwith.offLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
    vibSwith.onLabel.font = [UIFont fontWithName:@"ArialMT" size:14];
    vibSwith.switchCornerRadius = 5.0f;
    switchBack.layer.cornerRadius = 6.0f;
    switchBack.backgroundColor = [UIColor tealColor];
    shouldSound = YES;
    shouldVibrate = YES;
    frame = CGRectMake(134, 70, 171, 72);
    MPVolumeView *v = [[MPVolumeView alloc] initWithFrame:CGRectMake(400, 600, 100, 30)];
    v.showsRouteButton = NO;
    [self.view addSubview:v];
    
}



-(void)viewWillAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"stopKey"] == nil) {
        stopChooser.placeholder = @"CHOOSE A LOCATION";
        locTypeLabel.hidden = YES;
        locLabel.hidden = YES;
    } else {
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopKey"];
        
        locLabel.hidden = NO;
        chooseLocLabel.hidden = YES;
        locTypeLabel.text = NO;
        locLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopName"];
        [locLabel sizeToFit];
        locLabel.frame = CGRectMake(locLabel.frame.origin.x, locLabel.frame.origin.y, frame.size.width, locLabel.frame.size.height);
        
        UIFont *light = [UIFont fontWithName:@"Helvetica-Light" size:18];
        UIFont *regular = [UIFont fontWithName:@"Helvetica" size:18];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"BUS | " attributes:@{NSFontAttributeName: light}];
        NSAttributedString *routeText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"ROUTE %@", [dict objectForKey:@"Route #"]] attributes:@{NSFontAttributeName: regular}];
        [text appendAttributedString:routeText];
        locTypeLabel.attributedText = text;
    }
    BOOL shouldSong = [[NSUserDefaults standardUserDefaults] boolForKey:@"playSong"];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"playSound"]) {
        
        NSMutableAttributedString *soundString = nil;
        UIFont *light = [UIFont fontWithName:@"Helvetica-Light" size:20];
        UIFont *reg = [UIFont fontWithName:@"Helvetica" size:20];
        shouldSound = [[NSUserDefaults standardUserDefaults] boolForKey:@"playSound"];
        if (shouldSound) {
            soundString = [[NSMutableAttributedString alloc] initWithString:@"SOUND | " attributes:@{NSFontAttributeName: light}];
            NSAttributedString *soundText = [[NSAttributedString alloc] initWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"soundName"] uppercaseString] attributes:@{NSFontAttributeName: reg}];
            [soundString appendAttributedString:soundText];
        }
        if (shouldSong) {
            soundString = [[NSMutableAttributedString alloc] initWithString:@"SONG | " attributes:@{NSFontAttributeName: light}];
            MPMediaQuery *query = [MPMediaQuery songsQuery];
            MPMediaPropertyPredicate *pred = [MPMediaPropertyPredicate predicateWithValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"songID"] forProperty:MPMediaItemPropertyPersistentID];
            [query addFilterPredicate:pred];
            NSString *songName = [[[query items][0] valueForProperty:MPMediaItemPropertyTitle] uppercaseString];
            NSAttributedString *songText = [[NSAttributedString alloc] initWithString:songName attributes:@{NSFontAttributeName: reg}];
            [soundString appendAttributedString:songText];
        }
        soundLabel.attributedText = soundString;
    } else {
        UIFont *light = [UIFont fontWithName:@"Helvetica-Light" size:20];
        UIFont *reg = [UIFont fontWithName:@"Helvetica" size:20];
        [[NSUserDefaults standardUserDefaults] setObject:@"Apex" forKey:@"soundName"];
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"soundIdx"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"playSound"];
        NSMutableAttributedString *tempStr = [[NSMutableAttributedString alloc] initWithString:@"SOUND | " attributes:@{NSFontAttributeName: light}];
        NSAttributedString *soundText = [[NSAttributedString alloc] initWithString:@"APEX" attributes:@{NSFontAttributeName: reg}];
        [tempStr appendAttributedString:soundText];
        soundLabel.attributedText = tempStr;
        
    }
    if (shouldSound == NO && shouldSong == NO) {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"soundIdx"] intValue] == 0) {
        soundLabel.text = @"NONE";
    }
    }
    //[ap play];
    MGSetDark
    [self.navigationController.view addSubview:darkView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)wakeMeUp:(id)sender {
    [self startStandardUpdates];
    
    //if ([[NSUserDefaults standardUserDefaults] objectForKey:@"stopsSelOne"]) {
        
        NSArray *first = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopSelOne"];
        NSArray *second = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopSelTwo"];
    
        NSInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:@"stopAlertIdx"] integerValue] - 1;
        
        double lat1, lat2, lon1, lon2;
        NSDictionary *firstStop;
        NSDictionary *secondStop;
        
        @try {
            firstStop = first[index];
        }
        @catch (NSException *exception) {
            if (first.count > 0) {
                firstStop = [first lastObject];
            } else {
                firstStop = [NSDictionary dictionary];
            }
        }
        @finally {}
        
        @try {
            secondStop = second[index];
        }
        @catch (NSException *exception) {
            if (second.count > 0) {
                secondStop = [second lastObject];
            } else {
                secondStop = [NSDictionary dictionary];
            }
        }
        @finally {}
    
        NSLog(@"%d %@ %@", index, firstStop, secondStop);

    
        if ([firstStop allKeys].count > 0 && [secondStop allKeys].count > 0) {
            
            lat1 = [[firstStop objectForKey:@"Lat"] doubleValue];
            lon1 = [[firstStop objectForKey:@"Lon"] doubleValue];
            region1 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat1, lon1) radius:100 identifier:@"stop1"];
            lat2 = [[secondStop objectForKey:@"Lat"] doubleValue];
            lon2 = [[secondStop objectForKey:@"Lon"] doubleValue];
            region2 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat2, lon2) radius:100 identifier:@"stop2"];
            
        } else if ([firstStop allKeys].count > 0 && [secondStop allKeys].count == 0) {
            lat1 = [[firstStop objectForKey:@"Lat"] doubleValue];
            lon1 = [[firstStop objectForKey:@"Lon"] doubleValue];
            region1 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat1, lon1) radius:100 identifier:@"stop1"];
            lat2 = 0.0;
            lon2 = 0.0;
            region2 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat2, lon2) radius:100 identifier:@"stop2"];
        } else {
            lat1 = 0.0;
            lon1 = 0.0;
            region1 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat1, lon1) radius:100 identifier:@"stop1"];
            lat2 = [[secondStop objectForKey:@"Lat"] doubleValue];
            lon2 = [[secondStop objectForKey:@"Lon"] doubleValue];
            region2 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat2, lon2) radius:100 identifier:@"stop2"];
        }
    //}
    
    double lat3 = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"stopKey"] objectForKey:@"lat"] doubleValue];
    double lon3 = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"stopKey"] objectForKey:@"lon"] doubleValue];
    region3 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat3, lon3) radius:80 identifier:@"stop3"];
    
 
    MGAlert(@"ALARM SET!", @"WE'LL WAKE YOU UP WHEN YOU GET CLOSE TO YOUR STOP")
    

    tracking = YES;
}


-(void)DQAlertViewCancelButtonClicked {

    MGHideDark
    
}


- (IBAction)vibSwitchChanged:(id)sender {
    
    
    if (vibSwith.isOn) {
        switchBack.backgroundColor = [UIColor tealColor];
    } else {
        switchBack.backgroundColor = [UIColor grayDetailColor];
    }
    
}

-(void)startStandardUpdates {
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    locationManager.pausesLocationUpdatesAutomatically = YES;
    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = 100;
    [locationManager startUpdatingLocation];
    canPushAlarm = YES;
    NSString *soundName;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"soundName"] == nil) {
        soundName = @"Apex";
    } else {
        soundName = [[NSUserDefaults standardUserDefaults] objectForKey:@"soundName"];
    }
    
    ap = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:soundName withExtension:@"mp3"] error:nil];
    ap.numberOfLoops = -1;
    [ap setVolume:1.0];
    [ap prepareToPlay];
    
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coord = location.coordinate;
    
    if ([region1 containsCoordinate:coord] || [region2 containsCoordinate:coord] || [region3 containsCoordinate:coord]) {
    count++;
    //if (count > 3) {
        
        
        if (canPushAlarm == YES) {
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
            //[[[UIAlertView alloc] initWithTitle:@"Wake up!" message:@"You are getting close to your stop!" delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil] show];
            MGAlert(@"WAKE UP!", @"YOU ARE GETTING CLOSE TO YOUR STOP!");
            alert.cancelButtonAction = ^{
                [self stopTimer];
            };
            prevVol = [[MPMusicPlayerController applicationMusicPlayer] volume];
            musicPlaying = ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) ? YES : NO;
            [[MPMusicPlayerController iPodMusicPlayer] pause];
            

            
            double volume = ([[NSUserDefaults standardUserDefaults] objectForKey:@"volume"] == nil) ? 0.5 : [[[NSUserDefaults standardUserDefaults] objectForKey:@"volume"] doubleValue];
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:volume];
            
            
            UILocalNotification *not = [[UILocalNotification alloc] init];
            not.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            not.alertAction = @"Stop Alarm";
            not.alertBody = @"Wake up! Your stop's coming up!";
            [[UIApplication sharedApplication] scheduleLocalNotification:not];
            
            BOOL shouldSong = [[NSUserDefaults standardUserDefaults] boolForKey:@"playSong"];
            
            shouldSound = [[NSUserDefaults standardUserDefaults] boolForKey:@"playSound"];
            shouldVibrate = (vibSwith.on) ? YES : NO;
            
            if (shouldSound) {
                [ap play];
            } else if (shouldSong) {
                @try {
                    playa = [MPMusicPlayerController applicationMusicPlayer];
                    //[playa setVolume:volume];
                MPMediaQuery *query = [MPMediaQuery songsQuery];
                MPMediaPropertyPredicate *pred = [MPMediaPropertyPredicate predicateWithValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"songID"] forProperty:MPMediaItemPropertyPersistentID];
                [query addFilterPredicate:pred];
                NSArray *mediaItems = [query items];
                MPMediaItemCollection *col = [[MPMediaItemCollection alloc] initWithItems:mediaItems];
                [playa setQueueWithItemCollection:col];
                [playa setCurrentPlaybackTime:60];
                [playa play];
                }                @catch (NSException *exception) {
                }
                @finally {
                }
            }
            if (shouldVibrate) {
                vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:0.45 target:self selector:@selector(vibrate) userInfo:nil repeats:YES];
                [vibrateTimer fire];
            }
            
        }
        canPushAlarm = NO;
        
    }
    //}
    //[self log];
}


-(void)stopTimer {
    [vibrateTimer invalidate];
    [soundTimer invalidate];
    [ap stop];
    [playa stop];
    [playa setQueueWithItemCollection:nil];
    [locationManager stopUpdatingLocation];
    count = 0;
    tracking = NO;
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:prevVol];
    //[[AVAudioSession sharedInstance] setActive:NO error:nil];
    if (musicPlaying)
    [[MPMusicPlayerController iPodMusicPlayer] play];
}

-(void)playSound {
    [ap play];
}

-(void)sound{
    SystemSoundID idd;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(songURL), &idd);
    //AudioServicesPlaySystemSound(idd);
}

- (IBAction)chooseSound:(id)sender {
    [self textFieldShouldBeginEditing:songTextField];
    
}



-(void)vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
-(BOOL)shouldAutorotate {
    return NO;
}



- (IBAction)locationChoice:(id)sender {
    [self presentViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Nav"] animated:YES completion:nil];
    
}




@end
