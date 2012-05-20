//
//  LTViewController.h
//  VideoUpload
//
//  Created by Shaomeng Zhang on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    
}


- (IBAction)uploadVideo:(id)sender;
- (IBAction)recordVideo:(id)sender;
@end
