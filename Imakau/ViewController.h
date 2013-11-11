//
//  ViewController.h
//  Imakau
//
//  Created by koogawa on 2013/11/11.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

- (IBAction)searchButtonTapped:(id)sender;

@end
