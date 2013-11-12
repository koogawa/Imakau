//
//  NekoViewController.h
//  Imakau
//
//  Created by koogawa on 2013/11/12.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NekoViewController : UIViewController
{
    NSString *_question;
}

@property (weak, nonatomic) NSString *productName;

@property (weak, nonatomic) IBOutlet UILabel *qaLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerTextView;

@end
