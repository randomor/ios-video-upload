//
//  LTViewController.m
//  VideoUpload
//
//  Created by Shaomeng Zhang on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LTViewController.h"

#define SERVER_PATH @"http://192.168.0.5:4567/upload"

@interface LTViewController (){
    UIPopoverController *p; 
    NSData *webData;
}

@end

@implementation LTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)uploadVideo:(UIButton*)sender {
    [self post:webData];
    NSLog(@"posted data");
}

- (IBAction)recordVideo:(UIButton*)sender {
    UIImagePickerController *i = [[UIImagePickerController alloc] init];
    [i setDelegate:self];
    if ([UIImagePickerController
         isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray* mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        [i setMediaTypes:mediaTypes];
        [i setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [i setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];        
    }
    
    p = [[UIPopoverController alloc] initWithContentViewController:i];
    [p presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (NSData *)generatePostDataForData:(NSData *)uploadData
{
    // Generate the post header:
    NSString *post = [NSString stringWithCString:"--AaB03x\r\nContent-Disposition: form-data; name=\"file\"; filename=\"ios-video.mov\"\r\nContent-Type: video/mov\r\nContent-Transfer-Encoding: binary\r\n\r\n" encoding:NSASCIIStringEncoding];
    
    // Get the post header int ASCII format:
    NSData *postHeaderData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // Generate the mutable data variable:
    NSMutableData *postData = [[NSMutableData alloc] initWithLength:[postHeaderData length] ];
    [postData setData:postHeaderData];
    
    // Add the file:
    [postData appendData: uploadData];
    
    // Add the closing boundry:
    [postData appendData: [@"\r\n--AaB03x--" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    // Return the post data:
    return postData;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{ 
    
    //assign the mediatype to a string 
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    //check the media type string so we can determine if its a video
    if ([mediaType isEqualToString:@"public.movie"]){
        NSLog(@"got a movie");
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        webData = [NSData dataWithContentsOfURL:videoURL];
    }
    [p dismissPopoverAnimated:YES];
}

- (void)post:(NSData *)fileData
{
    
    NSLog(@"POSTING");
    
    // Generate the postdata:
    NSData *postData = [self generatePostDataForData: fileData];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    // Setup the request:
    NSMutableURLRequest *uploadRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:SERVER_PATH] cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 30 ];
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setValue:@"multipart/form-data; boundary=AaB03x" forHTTPHeaderField:@"Content-Type"];
    [uploadRequest setHTTPBody:postData];
    
    // Execute the reqest:
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:uploadRequest delegate:self];
    if (conn)
    {
        // Connection succeeded (even if a 404 or other non-200 range was returned).
        NSLog(@"sucess");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Got Server Response" message:@"Success" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        // Connection failed (cannot reach server).
        NSLog(@"fail");
    }
    
}

@end
