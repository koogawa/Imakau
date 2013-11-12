//
//  ViewController.m
//  Imakau
//
//  Created by koogawa on 2013/11/11.
//  Copyright (c) 2013年 Kosuke Ogawa. All rights reserved.
//

#import "ViewController.h"
#import "FSNConnection.h"
#import "NekoViewController.h"

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

- (IBAction)upload:(UIImage *)image
{
    // 1. セッションコンフィグレーションを作成します．
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // 2. コンフィグレーションオブジェクトと self デリゲートを指定してセッションを作成します．
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    // 3. 任意の接続先を設定します．
    NSString *urlString = @"http://eval.api.pux.co.jp:8080/webapi/planar.do";
    NSURL *url = [NSURL URLWithString:urlString];
    
    // アップロードするファイルの名前を適当に設定します．
    double timeUploaded = [[NSDate date] timeIntervalSince1970];
    NSString *fileNameUploaded = @"uploaded_";
    fileNameUploaded = [fileNameUploaded stringByAppendingString:[NSString stringWithFormat:@"%f", timeUploaded]];
    fileNameUploaded = [fileNameUploaded stringByAppendingString:@".dat"];
    
    // サーバ側のフォーム <input type="file" name="file"> に合わせておきます．
    NSString *nameUploaded = @"file";
    // ここは適当に．
    NSString *post = @"mogmog";
    
    // アップロードするファイルの中身を作成します．
    // ここでは 1,000,000 バイトの意味の無いデータを作成しています．
    //NSMutableData *md = [[NSMutableData alloc] initWithLength:1000000]; // 1e6
    NSData *md = UIImageJPEGRepresentation(image, 1.0);
    
    // boundary に任意の文字列を設定します．
    NSString *boundary = @"-boundary";
    
    // POST multipart/form-data のボディ部分を作成します．
    NSMutableData *dataSend = [[NSMutableData alloc] init];
    [dataSend appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"status\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[[NSString stringWithFormat:@"%@", post] dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [dataSend appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", nameUploaded, fileNameUploaded] dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:md];
    [dataSend appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // apiKey=RCGHACKA15&mode=recognize&inputBase64=%@&no=0
    [dataSend appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"apiKey\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[@"RCGHACKA15" dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    [dataSend appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"mode\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[@"recognize" dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    [dataSend appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"no\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[@"0" dataUsingEncoding:NSUTF8StringEncoding]];
    [dataSend appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    // POST リクエストを作成します．
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:dataSend];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            if (error)
                                            {
                                                NSLog(@"Error! %@", error);
                                                return;
                                            }
                                            
                                            // Success
                                            NSLog(@"PUX: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                            
                                            // 正規表現で1を取り出す
                                            NSString *planarNo = @"1";
                                            
                                            // JANコード
                                            NSString *janCode = [self getJanCodeFromPlanarNo:planarNo];
                                            
                                            // 最安値チェック
                                            [self fetchLowestProductFromJanCode:janCode];
                                        }];
    
    // 通信開始
    [task resume];

    return;
    // 4. タスクオブジェクトを作成します．
    NSURLSessionUploadTask *sessionUploadTask = [session uploadTaskWithRequest:request fromData:dataSend];
    [sessionUploadTask resume];
    // インジケータを開始します．
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// ---------------------------------------------------------------------
//  NSURLSessionTaskDelegate
// ---------------------------------------------------------------------
/*
 The NSURLSessionTaskDelegate protocol defines the methods that a delegate of an NSURLSession object should implement to handle task-level events that are common to all task types.
 
 Delegates of sessions with download tasks should also implement the methods in the NSURLSessionDownloadDelegate protocol to handle task-level events specific to download tasks.
 
 Delegates of sessions with data tasks should also implement the methods in the NSURLSessionDataDelegate protocol to handle task-level events specific to download tasks.
 
 Note: An NSURLSession object need not have a delegate. If no delegate is assigned, a system-provided delegate is used.
 */

// URLSession:task:didCompleteWithError:
// Tells the delegate that the task finished transferring data.
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
//    BLog();
    
    // インジケータを停止します．
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // エラーオブジェクトがあるかどうか確認します．
    if(error){
        
        NSLog(@"%@", [error localizedDescription]);
        
        // DNS 名前解決に失敗すると呼ばれます．
        // A server with the specified hostname could not be found.
        
        // サーバからリセットを返されると呼ばれます．
        // Could not connect to the server.
        
        // タイムアウトすると呼ばれます．
        // The request timed out.
        
    }else{
        
        NSLog(@"done!");
    }
    
    // セッションを必要としなくなった場合，未処理のタスクをキャンセルするために invalidateAndCancel を呼ぶことでセッションを無効とします．
    [session invalidateAndCancel];
}
- (IBAction)searchButtonTapped:(UIImage *)image
{
    [self.nameTextField resignFirstResponder];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [FSNData withImage:image jpegQuality:.75 fileName:@"fileName"],  @"inputFile",
                                @"RCGHACKA15",    @"apiKey",
                                @"recognize",    @"mode",
                                @"0",    @"no",
                                nil];
    
    FSNConnection *connection =
    [FSNConnection withUrl:[NSURL URLWithString:@"http://eval.api.pux.co.jp:8080/webapi/planar.do"]
                    method:FSNRequestMethodPOST
                   headers:nil
                parameters:parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData stringFromUTF8];
                }
           completionBlock:^(FSNConnection *c) {
               NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
               
               // 正規表現で1を取り出す
               // <planarNo>3</planarNo>
               NSString *string = [NSString stringWithFormat:@"%@", c.parseResult];
               NSError *error   = nil;
               NSRegularExpression *regexp =
               [NSRegularExpression regularExpressionWithPattern:@"<planarNo>([0-9])</planarNo>"
                                                         options:0
                                                           error:&error];
               if (error != nil) {
                   NSLog(@"%@", error);
               } else {
                   NSTextCheckingResult *match =
                   [regexp firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
                   NSLog(@"%d", match.numberOfRanges); // 3のはず
                   NSLog(@"%@", [string substringWithRange:[match rangeAtIndex:0]]); // マッチした文字列全部
                   
                   NSString *planarNo = [string substringWithRange:[match rangeAtIndex:0]];
                   
                   // JANコード
                   NSString *janCode = [self getJanCodeFromPlanarNo:planarNo];
                   
                   // レビュー平均チェック
                   [self fetchReviewRateFromJanCode:janCode];
               }
               

           }
             progressBlock:^(FSNConnection *c) {
                 NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
             }];
    
    [connection start];

    return;
    [self upload:image];
    return;
//    NSString *encodedString = [[UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedString = [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:0];
//    NSString *encodedString = [UIImageJPEGRepresentation(image, 1.0) base64Encoding];
    NSString *parameter = [NSString stringWithFormat:@"apiKey=RCGHACKA15&mode=recognize&inputBase64=%@&no=0", [encodedString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
//    NSLog(@"urlString %@", urlSting);
    
    
    NSData *postData = [parameter dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://eval.api.pux.co.jp:8080/webapi/planar.do"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        if (error)
                                        {
                                            NSLog(@"Error! %@", error);
                                            return;
                                        }
                                        
                                        // Success
                                        NSLog(@"PUX: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                        
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
    if ([planarNo isEqualToString:@"1"]) {
        return @"0885155001696";
    }
    else if ([planarNo isEqualToString:@"2"]) {
        return @"4545350044695";
    }
    else {
        return @"0885155001672";
    }
}

- (void)fetchLowestProductFromJanCode:(NSString *)janCode
{
    NSString *urlSting = [NSString stringWithFormat:@"http://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch?appid=dj0zaiZpPVM1ZzlQQWlFWVlVbiZzPWNvbnN1bWVyc2VjcmV0Jng9NjI-&jan=%@&sort=%@", janCode, @"%2Bprice"];
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
                                        NSDictionary *product = [[[[jsonDictionary objectForKey:@"ResultSet"] objectForKey:@"0"] objectForKey:@"Result"] objectForKey:@"0"];
                                        [self performSelectorOnMainThread:@selector(showWebViewWithProductInfo:) withObject:product waitUntilDone:YES];
                                    }];
    
    // 通信開始
    [task resume];
}

- (void)fetchReviewRateFromJanCode:(NSString *)janCode
{
    NSString *urlSting = [NSString stringWithFormat:@"http://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch?appid=dj0zaiZpPVM1ZzlQQWlFWVlVbiZzPWNvbnN1bWVyc2VjcmV0Jng9NjI-&jan=%@&sort=%@", janCode, @"-review_count"];
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
                                        NSDictionary *product = [[[[jsonDictionary objectForKey:@"ResultSet"] objectForKey:@"0"] objectForKey:@"Result"] objectForKey:@"0"];
                                        NSString *reviewRate = [[product objectForKey:@"Review"] objectForKey:@"Rate"];
                                        NSLog(@"reviewRate %@", reviewRate);
                                        _reviewRate = reviewRate;
                                        [self fetchLowestProductFromJanCode:janCode];
                                    }];
    
    // 通信開始
    [task resume];
}

- (void)showWebViewWithProductInfo:(NSDictionary *)product
{
    [SVProgressHUD dismiss];
    self.webView.hidden = NO;
    
    NSLog(@"product : %@", product);
    NSString *productName = [product objectForKey:@"Name"];
    _productName = productName;
    NSString *lowestPrice = [[product objectForKey:@"PriceLabel"] objectForKey:@"DefaultPrice"];
    NSString *reviewRate = [[product objectForKey:@"Review"] objectForKey:@"Rate"];
    NSString *imageUrlString = [[product objectForKey:@"Image"] objectForKey:@"Medium"];
    NSLog(@"%@", [NSString stringWithFormat:@"商品名：%@, 最安値：%@, url:%@", productName, lowestPrice, imageUrlString]);
    self.resultView.text = [NSString stringWithFormat:@"商品名：%@\n\n最安値：%@\n\nレビュー：%@", productName, lowestPrice, _reviewRate];

    
    // ここでWebViewを開いてあげる
    NSString *urlString = [NSString stringWithFormat:@"http://whispering-ravine-4623.herokuapp.com/"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    // TODO: 関数化
    UIBarButtonItem *cameraButton =
    [[UIBarButtonItem alloc] initWithTitle:@"ネコにきいてみる"
style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(showNekoView)];
    
	
	UIBarButtonItem *adjustment =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
	
	NSArray *buttons = [NSArray arrayWithObjects:adjustment, cameraButton, adjustment, nil];
	[self setToolbarItems:buttons animated:NO];

}

- (void)showNekoView
{
    NekoViewController *viewController = [[NekoViewController alloc] init];
    viewController.productName = _productName;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:YES completion:nil];
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
    
    // オリジナル画像を取得する
    UIImage *originalImage;
    originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"originalSize = %@", NSStringFromCGSize(originalImage.size));
    
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
    NSLog(@"shrinkedSize = %@", NSStringFromCGSize(size));
    UIGraphicsBeginImageContext(size);
    
    // 画像を縮小して描画する
    CGRect rect;
    rect.origin = CGPointZero;
    rect.size = size;
    [originalImage drawInRect:rect];
    
    // 描画した画像を取得する
    UIImage *shrinkedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self searchButtonTapped:shrinkedImage];
    [SVProgressHUD show];

    // 画像を表示する
//    self.attachedImageView.image = shrinkedImage;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    // イメージピッカーを隠す
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
