//
//  YTViewController.m
//  iOSYoutubeUploadTest
//
//  Created by 주영 이 on 2013. 12. 17..
//  Copyright (c) 2013년 uptown. All rights reserved.
//

#import "YTViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "GTLYouTube.h"

@interface YTViewController (){
    BOOL _isFirst;
}
- (void)_uploadYoutubeWithFileURL:(NSURL *)fileURL auth:(id <GTMFetcherAuthorizationProtocol>)auth;
@end

@implementation YTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    //signIn.shouldFetchGooleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = @"706222367191.apps.googleusercontent.com";
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ @"https://www.googleapis.com/auth/plus.login", @"https://www.googleapis.com/auth/youtube" ];  // plus.login scope defined in GTLPlusConstants.h
    //signIn.scopes = @[ @"profile" ];            // profile scope
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
	// Do any additional setup after loading the view, typically from a nib.
	// Do any additional setup after loading the view.
    self.movieController = [[MPMoviePlayerController alloc] init];
    
    [self.movieController setContentURL:self.movieURL];
    [self.movieController.view setFrame:self.view.bounds];
    [self.view addSubview:self.movieController.view];
    
    [self.movieController play];
    _isFirst = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_isFirst){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        [self presentViewController:picker animated:YES completion:NULL];
        _isFirst = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    [self _uploadYoutubeWithFileURL:self.movieURL auth:auth];

}

#pragma - image picker controller

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.movieURL = info[UIImagePickerControllerMediaURL];
//    [[MYGoogleCenter defaultCenter] uploadVideoFileWithTempUrl:self.movieURL];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [[GPPSignIn sharedInstance] authenticate];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma - private

- (void)_uploadYoutubeWithFileURL:(NSURL *)fileURL auth:(id <GTMFetcherAuthorizationProtocol>)auth{
    
    
    GTLYouTubeVideoStatus *status = [GTLYouTubeVideoStatus object];
    status.privacyStatus = @"public";
    GTLYouTubeVideoSnippet *snippet = [GTLYouTubeVideoSnippet object];
    snippet.title = @"test";
    NSString *desc = @"desc test";
    if ([desc length] > 0) {
        snippet.descriptionProperty = desc;
    }
    NSString *tagsStr = @"tag test";
    if ([tagsStr length] > 0) {
        snippet.tags = [tagsStr componentsSeparatedByString:@","];
    }
    
    GTLYouTubeVideo *video = [GTLYouTubeVideo object];
    video.status = status;
    video.snippet = snippet;
    
    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    if (data) {
        
        NSString *mimeType = @"video/mp4";
        NSString *extension = [fileURL pathExtension];
        CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                                (__bridge CFStringRef)extension, NULL);
        if (uti) {
            CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
            if (cfMIMEType) {
                mimeType = CFBridgingRelease(cfMIMEType);
            }
            CFRelease(uti);
        }
        
        GTLUploadParameters *uploadParameters =
        [GTLUploadParameters uploadParametersWithData:data
                                             MIMEType:mimeType];
        
        GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosInsertWithObject:video
                                                                            part:@"snippet,status"
                                                                uploadParameters:uploadParameters];
        GTLServiceYouTube *service = [[GTLServiceYouTube alloc] init];
        [service setAuthorizer:auth];
        GTLServiceTicket *ticket = [service executeQuery:query
                                completionHandler:^(GTLServiceTicket *ticket,
                                                    GTLYouTubeVideo *uploadedVideo,
                                                    NSError *error) {
                                    
                                    NSLog(@"%@ %@ %@",ticket, uploadedVideo, error);
                                }];
        
        ticket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
                                                  unsigned long long numberOfBytesRead,
                                                  unsigned long long dataLength) {
            NSLog(@"%@ %llu %llu",ticket,numberOfBytesRead, dataLength);
        };
        
        GTMHTTPUploadFetcher *uploadFetcher = (GTMHTTPUploadFetcher *)[ticket objectFetcher];
        uploadFetcher.locationChangeBlock = ^(NSURL *url) {
        };
        
    } else {
        // Could not read file data.
    }

}

@end
