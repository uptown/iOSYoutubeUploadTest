//
//  YTViewController.h
//  iOSYoutubeUploadTest
//
//  Created by 주영 이 on 2013. 12. 17..
//  Copyright (c) 2013년 uptown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface YTViewController : UIViewController <GPPSignInDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (copy,   nonatomic) NSURL *movieURL;
@property (strong, nonatomic) MPMoviePlayerController *movieController;

@end
