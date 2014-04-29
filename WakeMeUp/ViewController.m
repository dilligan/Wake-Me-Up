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
@interface ViewController () <UITextFieldDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, MPMediaPickerControllerDelegate>
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
    float vibrateLength;
    MPMusicPlayerController *playa;
    AVQueuePlayer *queuePlayer;
    NSURL *songURL;
    float soundLength;
	float prevVol;
    BOOL musicPlaying;
}
@synthesize stopChooser, vibrateLabel, vibrateTime, songSegment, songTextField, locationField, chooseLocLabel, locLabel, locTypeLabel, topBar, slider, vibSwith, switchBack;
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
    MPVolumeView *v = [[MPVolumeView alloc] initWithFrame:CGRectMake(400, 600, 100, 30)];
    v.showsRouteButton = NO;
    [self.view addSubview:v];
    
}




-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"asdad");
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"stopKey"] == nil) {
        stopChooser.placeholder = @"CHOOSE A LOCATION";
        locTypeLabel.hidden = YES;
        locLabel.hidden = YES;
    } else {
        
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"stopKey"];
        stopChooser.text = [dict objectForKey:@"Name"];
        NSLog(@"%@", dict);
        locLabel.hidden = NO;
        chooseLocLabel.hidden = YES;
        locTypeLabel.text = NO;
        NSMutableString *locString = [[[dict objectForKey:@"Name"] uppercaseString] mutableCopy];
        int locIdx = (int)[locString rangeOfString:@"&"].location;
        [locString insertString:@"\n" atIndex:locIdx];
        locLabel.text = locString;
        UIFont *light = [UIFont fontWithName:@"Helvetica-Light" size:18];
        UIFont *bold = [UIFont fontWithName:@"ArialMT" size:18];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"BUS | " attributes:@{NSFontAttributeName: light}];
        NSAttributedString *routeText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"ROUTE %@", [dict objectForKey:@"Route #"]] attributes:@{NSFontAttributeName: bold}];
        [text appendAttributedString:routeText];
        locTypeLabel.attributedText = text;

        
        
    }
    
    

        songURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], [[NSUserDefaults standardUserDefaults] objectForKey:@"songCode"]]];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:songURL options:nil];
    CMTime audDur = asset.duration;
    soundLength = CMTimeGetSeconds(audDur);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"songCode"] != nil) {
        NSString *start = [[NSUserDefaults standardUserDefaults] objectForKey:@"songCode"];
        start = [start substringToIndex:[start length] - 4];
        songTextField.text = start;
    }
    
    //[ap play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == locationField) {
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Nav"];
    [self presentViewController:vc animated:YES completion:nil];
    } else {
        if (songSegment.selectedSegmentIndex == 0) {
        ToneNavController *t = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ToneNav"];
        [self presentViewController:t animated:YES completion:nil];
        } else {
            MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
            picker.delegate = self;
            picker.allowsPickingMultipleItems = NO;
            picker.prompt = NSLocalizedString(@"Select a song", nil);
            [picker loadView];
            [self presentViewController:picker animated:YES completion:nil];
        }
        
    }
    
    return NO;
}

- (IBAction)wakeMeUp:(id)sender {
    [self startStandardUpdates];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Interval"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"Interval"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    switch ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Interval"] intValue]) {
        case 0:
            vibrateLength = 0.5;
            break;
        case 1:
            vibrateLength = 1.0;
            break;
        case 2:
            vibrateLength = 1.5;
            break;
        case 3:
            vibrateLength = 2.0;
            break;
        default:
            break;
    }
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"nextStops"] != nil) {
        
        NSArray *stops = [[NSUserDefaults standardUserDefaults] objectForKey:@"nextStops"];
        NSDictionary *first = stops[0];
        NSDictionary *second = stops[1];
        NSLog(@"%@ %@", first, second);
        float lat1, lat2, lon1, lon2;
        
        if ([stops[0] allKeys].count > 0 && [stops[1] allKeys].count > 0) {
            
            lat1 = [[stops[0] objectForKey:@"Lat"] floatValue];
            lon1 = [[stops[0] objectForKey:@"Lon"] floatValue];
            region1 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat1, lon1) radius:100 identifier:@"stop1"];
            lat2 = [[stops[1] objectForKey:@"Lat"] floatValue];
            lon2 = [[stops[1] objectForKey:@"Lon"] floatValue];
            region2 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat2, lon2) radius:100 identifier:@"stop2"];
            
        } else if ([stops[0] allKeys].count > 0 && [stops[1] allKeys].count == 0) {
            lat1 = [[stops[0] objectForKey:@"Lat"] floatValue];
            lon1 = [[stops[0] objectForKey:@"Lon"] floatValue];
            region1 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat1, lon1) radius:100 identifier:@"stop1"];
            lat2 = 0.0;
            lon2 = 0.0;
        region2 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat2, lon2) radius:100 identifier:@"stop2"];
    } else {
        lat1 = 0.0;
        lon1 = 0.0;
        region1 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat1, lon1) radius:100 identifier:@"stop1"];
        lat2 = [[stops[1] objectForKey:@"Lat"] floatValue];
        lon2 = [[stops[1] objectForKey:@"Lon"] floatValue];
        region2 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat2, lon2) radius:100 identifier:@"stop2"];
    }
        NSLog(@"%f %f %f %f", lat1, lon1, lat2, lon2);
    }
    
    float lat3 = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"stopKey"] objectForKey:@"lat"] floatValue];
    float lon3 = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"stopKey"] objectForKey:@"lon"] floatValue];
    region3 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat3, lon3) radius:80 identifier:@"stop3"];
    
    [[[UIAlertView alloc] initWithTitle:@"Alarm Set!" message:@"We'll wake you up when you get close to your stop." delegate:nil cancelButtonTitle:@"Ok!" otherButtonTitles:nil] show];
}



- (IBAction)vibrateSwitched:(id)sender {
    if ([sender isOn]) {
        vibrateTime.hidden = NO;
        vibrateLabel.hidden = NO;
        shouldVibrate = YES;
    }
    else {
        vibrateLabel.hidden = YES;
        vibrateTime.hidden = YES;
        shouldVibrate = NO;
    }
}

- (IBAction)soundSwitched:(id)sender {
    if ([sender isOn]) {
        songSegment.hidden = NO;
        songTextField.hidden = NO;
        shouldSound = YES;
    }
    else {
        songSegment.hidden = YES;
        songTextField.hidden = YES;
        shouldSound = NO;
    }
}


-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    [self dismissViewControllerAnimated:YES completion:nil];
    playa = [MPMusicPlayerController iPodMusicPlayer];
    [playa setQueueWithItemCollection:mediaItemCollection];
    
    NSArray *music = [mediaItemCollection items];
    MPMediaItem *song = music[0];
    NSString *songName = [song valueForProperty:MPMediaItemPropertyTitle];
    songTextField.text = songName;
    
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    locationManager.distanceFilter = 2;
    [locationManager startUpdatingLocation];
    canPushAlarm = YES;
    ap = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Apex" withExtension:@"wav"] error:nil];
    ap.numberOfLoops = -1;
    [ap setVolume:1.0];
    [ap prepareToPlay];
    
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coord = location.coordinate;
    
    //if ([region1 containsCoordinate:coord] || [region2 containsCoordinate:coord] || [region3 containsCoordinate:coord]) {
    count++;
   if (count > 3) {
       [[AVAudioSession sharedInstance] setActive:YES error:nil];
       [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];

       if (canPushAlarm == YES) {
            [[[UIAlertView alloc] initWithTitle:@"Wake up!" message:@"You are getting close to your stop!" delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil] show];
           musicPlaying = ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) ? YES : NO;
           
           if (musicPlaying) {
           [[MPMusicPlayerController iPodMusicPlayer] pause];
           prevVol = [[MPMusicPlayerController applicationMusicPlayer] volume];
           }
           else
           prevVol = [[MPMusicPlayerController iPodMusicPlayer] volume];

           
           [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.7];
           
            UILocalNotification *not = [[UILocalNotification alloc] init];
            not.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            not.alertAction = @"Stop Alarm";
            not.alertBody = @"Wake up! Your stop's coming up!";
            [[UIApplication sharedApplication] scheduleLocalNotification:not];
            if (shouldSound == YES && shouldVibrate == YES) {
                
                soundTimer = [NSTimer scheduledTimerWithTimeInterval:soundLength target:self selector:@selector(sound) userInfo:nil repeats:YES];
                [soundTimer fire];
                vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:vibrateLength target:self selector:@selector(vibrate) userInfo:nil repeats:YES];
                [vibrateTimer fire];
                
            } else if (shouldSound == YES && shouldVibrate == NO) {
                
                soundTimer = [NSTimer scheduledTimerWithTimeInterval:soundLength target:self selector:@selector(sound) userInfo:nil repeats:YES];
                [soundTimer fire];
                
            } else if (shouldVibrate == YES && shouldSound == NO) {
                
            vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:vibrateLength target:self selector:@selector(vibrate) userInfo:nil repeats:YES];
            [vibrateTimer fire];
                
            }
           [ap play];
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
    [locationManager stopUpdatingLocation];
    count = 0;
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:prevVol];
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

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self stopTimer];

}


- (IBAction)locationChoice:(id)sender {
    [self textFieldShouldBeginEditing:locationField];
}




@end
