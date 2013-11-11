//
//  ViewController.m
//  Imakau
//
//  Created by koogawa on 2013/11/11.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem *cameraButton =
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                   target:self
                                                   action:@selector(cameraButtonTapped)];
	
	UIBarButtonItem *adjustment =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
												   target:nil
												   action:nil];
	
	NSArray *buttons = [NSArray arrayWithObjects:adjustment, cameraButton, adjustment, nil];
	[self setToolbarItems:buttons animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private

- (void)cameraButtonTapped
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
	sheet.delegate = self;
    
        [sheet addButtonWithTitle:@"写真を撮る"];
        [sheet addButtonWithTitle:@"ライブラリから選択する"];
        [sheet addButtonWithTitle:@"キャンセル"];
        
        sheet.cancelButtonIndex = 2;
    
    [sheet showInView:self.view];
}


- (IBAction)searchButtonTapped:(id)sender
{
    [self.nameTextField resignFirstResponder];
    
    NSString *urlSting = [NSString stringWithFormat:@"http://eval.api.pux.co.jp:8080/webapi/planar.do?apiKey=RCGHACKA15&mode=recognize&imageURL=http://koogawa.com/iphone.jpg&no=0"];
    
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
                                        NSLog(@"data : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                        
                                        // 正規表現で1を取り出す
                                        NSString *planarNo = @"1";
                                        
                                        // JANコード
                                        NSString *janCode = [self getJanCodeFromPlanarNo:planarNo];
                                        
                                        // 最安値チェック
                                        [self fetchLowestProductFromJanCode:janCode];
                                    }];
    
    // 通信開始
    [task resume];
}

- (NSString *)getJanCodeFromPlanarNo:(NSString *)planarNo
{
    return @"0885155001696";
}

- (void)fetchLowestProductFromJanCode:(NSString *)janCode
{
    NSString *urlSting = [NSString stringWithFormat:@"http://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch?appid=dj0zaiZpPVM1ZzlQQWlFWVlVbiZzPWNvbnN1bWVyc2VjcmV0Jng9NjI-&jan=%@&sort=%@", janCode, @"%2Bprice"];
    
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
                                        NSDictionary *product = [[[[jsonDictionary objectForKey:@"ResultSet"] objectForKey:@"0"] objectForKey:@"Result"] objectForKey:@"0"];
                                        NSLog(@"data : %@", [[product objectForKey:@"PriceLabel"] objectForKey:@"DefaultPrice"]);
                                        NSString *productName = [product objectForKey:@"Name"];
                                        NSString *lowestPrice = [[product objectForKey:@"PriceLabel"] objectForKey:@"DefaultPrice"];
                                        self.priceLabel.text = [NSString stringWithFormat:@"商品名：%@, 最安値：%@", productName, lowestPrice];
                                        
                                        // ここでWebViewを開いてあげる
                                    }];
    
    // 通信開始
    [task resume];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // ソースタイプを決定する
    UIImagePickerControllerSourceType sourceType = 0;
    
        switch (buttonIndex)
        {
            case 0:
            {
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            }
            case 1:
            {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            }
            case 2:
            {
                return;
                break;
            }
        }
    
    // 使用可能かどうかチェックする
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        return;
    }
    
    // イメージピッカーを作る
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    imagePicker.delegate = self;
    
    // イメージピッカーを表示する
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // イメージピッカーを隠す
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self searchButtonTapped:nil];
    return;
    
    // オリジナル画像を取得する
    UIImage *originalImage;
    originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //LOG(@"size = %@", NSStringFromCGSize(originalImage.size));
    
    // 長辺をMAX_IMAGE_SIZEに縮小する
	CGSize originalSize = originalImage.size;
	CGFloat ratio = 0;
	if (originalSize.width > originalSize.height) {
		// 横長なので横幅で比率計算
		ratio = 640 / originalSize.width;
	} else {
		// 縦長
		ratio = 640 / originalSize.height;
	}
    
    // もともとMAX_IMAGE_SIZE以下なら比率はそのまま
    if (ratio > 1.0) ratio = 1.0;
    //LOG(@"ratio = %f", ratio);
    
    // グラフィックスコンテキストを作る
    CGSize size = CGSizeMake(ratio * originalSize.width, ratio * originalSize.height);
    //LOG(@"size = %@", NSStringFromCGSize(size));
    UIGraphicsBeginImageContext(size);
    
    // 画像を縮小して描画する
    CGRect rect;
    rect.origin = CGPointZero;
    rect.size = size;
    [originalImage drawInRect:rect];
    
    // 描画した画像を取得する
    UIImage *shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 画像を表示する
//    self.attachedImageView.image = shrinkedImage;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    // イメージピッカーを隠す
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self searchButtonTapped:nil];

}

@end
