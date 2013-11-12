//
//  NekoViewController.m
//  Imakau
//
//  Created by koogawa on 2013/11/12.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "NekoViewController.h"

@interface NekoViewController ()

@end

@implementation NekoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    // ナビゲーションバーにボタンを追加
	UIBarButtonItem *closeButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(closeButtonTapped)];
    self.navigationItem.leftBarButtonItem = closeButton;

    _question = [NSString stringWithFormat:@"%@が一番安いお店を教えて下さい", self.productName];
    // デモ用
    _question = @"ルンバが一番安いお店を教えてください";
    self.qaLabel.text = _question;
    
    [self fetchAnswer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)fetchAnswer
{
    NSString *urlSting = [NSString stringWithFormat:@"https://api.apigw.smt.docomo.ne.jp/knowledgeQA/v1/ask?q=%@&APIKEY=712f6b3549656f5938674c4a587644344d554a5a772f4732626a48352e4e4b3563673166576874704a4e2e", [_question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"urlString = %@", urlSting);
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *url = [NSURL URLWithString:urlSting];
    
    NSURLSessionTask *task = [session dataTaskWithURL:url
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        if (error)
                                        {
                                            NSLog(@"Error! %@", error);
                                            return;
                                        }
                                        
                                        // Success
                                        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                        NSLog(@"result %@", jsonDictionary);
                                        [self performSelectorOnMainThread:@selector(showAnswer:) withObject:jsonDictionary waitUntilDone:YES];
                                    }];
    
    // 通信開始
    [task resume];
}

- (void)showAnswer:(NSDictionary *)answerInfo
{
    NSString *answer = [[answerInfo objectForKey:@"message"] objectForKey:@"textForDisplay"];
    self.answerTextView.text = answer;
}

@end
