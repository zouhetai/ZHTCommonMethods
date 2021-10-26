//
//  ZHTViewController.m
//  ZHTCommonMethods
//
//  Created by 1452327617@qq.com on 10/25/2021.
//  Copyright (c) 2021 1452327617@qq.com. All rights reserved.
//

#import "ZHTViewController.h"
#import "ZHTUtils.h"
#import "TestModel.h"

@interface ZHTViewController ()
{
    UIButton *baseBtn;
}
@end

@implementation ZHTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    baseBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 50)];
    [baseBtn setTitle:@"测试" forState:UIControlStateNormal];
    [baseBtn addTarget:self action:@selector(baseBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    baseBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:baseBtn];
    
    UIButton *baseBtnBottom = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 100, 50)];
    [baseBtnBottom setTitle:@"测试" forState:UIControlStateNormal];
    [baseBtnBottom addTarget:self action:@selector(baseBtnBottomAction:) forControlEvents:UIControlEventTouchUpInside];
    baseBtnBottom.backgroundColor = [UIColor redColor];
    [self.view addSubview:baseBtnBottom];

}

- (void)baseBtnAction:(UIButton*)btn
{
//    [self dicFromObject:nil];
//    [self getRandom:100];
//    [self nowTimeStr];
//    [self compareDate];
//    [self objectWithStr];
//    [self convertToJsonData];
//    [self getHexStringForData];
//    [self getCurrentVC];
//    [self alertMsg];
//    [self getAppVersion];
//    [self isJailBreak];
//    [self isPhoneNumber];
//    [self regularCheck];
//    [self diskOfAllSizeMBytes];
//    [self diskOfFreeSizeMBytes];
//    [self allScreenShotsView];
//    [self screenShotsWithView];
//    [self fetchBundle];
//    [self getDeviceModelName];
//    [self isHaveSafeRange];
//    [self phoneSystemVersion];
//    [self callPhoneWithNumber];
//    [self getImageFromImage];
//    [self scaleToSizeImage];
//    [self rotateImage];
//    [self openSafariWithLinkAddress];
//    [self openAppStoreWithAppLink];
//    [self alertMsgWithBlock];
//    [self pasteBoardSetString];
//    [self pasteBoardShow];
    [self interactionControllerWithURL];

}

- (void)baseBtnBottomAction:(UIButton*)btn
{
    [self pasteBoardShow];
}

//model转字典
- (void)dicFromObject:(NSObject *)object
{
    TestModel *model = [[TestModel alloc]init];
    model.nameStr = @"测试";
    model.promtStr = @"测试2";
//    model.promtffStr = @"测试2";
    NSDictionary *backDic = [ZHTUtils dicFromObject:model];
    NSLog(@"backDic====%@",backDic);
}

//获取随机数
- (void)getRandom:(NSInteger)randomScope
{
    NSString *backString = [ZHTUtils getRandom:randomScope withNeedTime:NO];
    NSLog(@"backString====%@",backString);
}

//获取随机数
- (void)nowTimeStr
{
    NSString *dateFormatStr = @"yyyy-MM-dd HH:mm:ss";
    NSString *backString = [ZHTUtils nowTimeStr:dateFormatStr];
    NSLog(@"backString====%@",backString);
}

//与当前时间比较
- (void)compareDate
{
    BOOL isMore = [ZHTUtils compareDate:@"2021-05-17 16:05:32" withDateformat:@"yyyy-MM-dd HH:mm:ss"];
    NSLog(@"backString====%d",isMore);
}

//json字符串转OC对象
- (void)objectWithStr
{
    NSString *dataString = @"{\"Title\":\"启动广告\",\"Type\":\"H\",\"Url\":\"https:\/\/xyk.boubank.com\/wqca\/wlmq\/index\",\"MPSUrl\":\"webPage\/webPage.html\"}";
    NSLog(@"backString====%@",dataString);
    id object = [ZHTUtils objectWithStr:dataString];
    NSLog(@"object====%@",object);

}

//OC对象（字典、数组等）转json字符串
- (void)convertToJsonData
{
    NSDictionary *dic = @{
        @"MPSUrl":@"webPage/webPage.html",
        @"Title":@"启动广告",
        @"Type":@"H",
        @"Url":@"https://xyk.boubank.com/wqca/wlmq/index"
    };
    NSString *backString = [ZHTUtils convertToJsonData:dic];
    NSLog(@"backString====%@",backString);
}


/*
 *二进制data转16进制字符串
 *返回字符串对象
 */
- (void)getHexStringForData
{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"thirdWebList" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSLog(@"data====%@",data);
    NSString *backString = [ZHTUtils getHexStringForData:data];
    NSLog(@"backString====%@",backString);
}

/*
 *二进制data转16进制字符串
 *返回字符串对象
 */
- (void)getCurrentVC
{
    UIViewController *viewController = [ZHTUtils getCurrentVC];
    NSLog(@"viewController====%@",viewController);
}

//快捷显示系统提示框
- (void)alertMsg
{
    [ZHTUtils alertMsg:@"你好，测试，测试中"];
}

//快捷显示系统提示框(可选择)
- (void)alertMsgWithBlock
{
    [ZHTUtils alertMsg:@"你好，测试，测试中" withBlock:^(BOOL isDetermine) {
        if (isDetermine) {
            NSLog(@"确定");
        }else
        {
            NSLog(@"取消");
        }
    }];
}

//获取系统版本参数
- (void)getAppVersion
{
    NSString *appVersion = [ZHTUtils getAppVersion:CFBundleShortVersionString];
    NSString *bundleVersion = [ZHTUtils getAppVersion:CFBundleVersion];
    NSLog(@"appVersion:%@======bundleVersion:%@",appVersion,bundleVersion);
}

//检测应用是否越狱
- (void)isJailBreak
{
    BOOL isJailBreak = [ZHTUtils isJailBreak:NO];
    NSLog(@"isJailBreak===%d",isJailBreak);
}

//检测是否为手机号码
- (void)isPhoneNumber
{
    NSString *phoneNum = @"13899999999";
    BOOL isPhoneNumber = [ZHTUtils isPhoneNumber:phoneNum];
    NSLog(@"isPhoneNumber===%d",isPhoneNumber);
}

//检测是否符合正则校验
- (void)regularCheck
{
    NSString *checkString = @"a13899999999";
    NSString *checkStringT = @"?103814";
    //6到16位数字字母组合
    NSString *regularCheck = @"^(?![a-zA-Z]+$)(?![0-9]+$)[0-9a-zA-Z]{6,16}$";
    BOOL isRegularCheck = [ZHTUtils regularCheck:regularCheck withCheck:checkString];
    BOOL isRegularCheckT = [ZHTUtils regularCheck:regularCheck withCheck:checkStringT];
    NSLog(@"isRegularCheck===%d",isRegularCheck);
    NSLog(@"isRegularCheckT===%d",isRegularCheckT);
}

//磁盘空间大小
- (void)diskOfAllSizeMBytes
{
    CGFloat diskMbSize = [ZHTUtils diskOfAllSizeMBytes];
    NSLog(@"diskMbSize===%f",diskMbSize);
}

//可用磁盘空间大小
- (void)diskOfFreeSizeMBytes
{
    CGFloat freeDiskMbSize = [ZHTUtils diskOfFreeSizeMBytes];
    NSLog(@"freeDiskMbSize===%f",freeDiskMbSize);
}

//整屏幕截图
- (void)allScreenShotsView
{
    UIImage *allScreenImg = [ZHTUtils allScreenShotsView];
    NSLog(@"allScreenImg===%@",allScreenImg);

    UIImageView *allScreenView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 300, 200, 300)];
    allScreenView.image = allScreenImg;
    allScreenView.backgroundColor = [UIColor lightGrayColor];
    allScreenView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:allScreenView];
    
}

//按钮视图截图
- (void)screenShotsWithView
{
    UIImage *viewImg = [ZHTUtils screenShotsWithView:baseBtn];
    NSLog(@"viewImg===%@",viewImg);

    UIImageView *allScreenView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 300, 200, 300)];
    allScreenView.image = viewImg;
    allScreenView.backgroundColor = [UIColor lightGrayColor];
    allScreenView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:allScreenView];
    
}

//获取bundle中的图片
- (void)fetchBundle
{
    UIImage *fetchImg = [ZHTUtils fetchBundle:@"BLMBProgressHUD" Image:@"error"];
    NSLog(@"fetchImg===%@",fetchImg);
    UIImageView *allScreenView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 300, 50, 50)];
    allScreenView.image = fetchImg;
    allScreenView.backgroundColor = [UIColor lightGrayColor];
    allScreenView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:allScreenView];
}

//获取设备名称
- (void)getDeviceModelName
{
    NSString *deviceName = [ZHTUtils getDeviceModelName];
    NSLog(@"deviceName===%@",deviceName);
}


//获取是否刘海屏设备
- (void)isHaveSafeRange
{
    BOOL isHaveSafeRange = [ZHTUtils isHaveSafeRange];
    NSLog(@"isHaveSafeRange===%d",isHaveSafeRange);
}

//获取设备系统
- (void)phoneSystemVersion
{
    NSString *phoneVersion = [ZHTUtils phoneSystemVersion];
    NSLog(@"phoneVersion===%@",phoneVersion);
}

//调起手机拨打电话
- (void)callPhoneWithNumber
{
    [ZHTUtils callPhoneWithNumber:@"17600133710"];
}


//图片裁剪
- (void)getImageFromImage
{
    UIImage *orgImg = [UIImage imageNamed:@"IMG_3250.PNG"];
    //裁剪范围
    CGRect rectFrame = CGRectMake(0, 0, orgImg.size.width/2.0, orgImg.size.height);
    UIImage *subImg;
    if (orgImg) {
        subImg = [ZHTUtils getImageFromImage:orgImg subImageRect:rectFrame];
    }else
    {
        
    }
    NSLog(@"subImg===%@",subImg);
    UIImageView *allScreenView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 300, 200, 300)];
    if (subImg) {
        allScreenView.image = subImg;
    }
    allScreenView.backgroundColor = [UIColor lightGrayColor];
    allScreenView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:allScreenView];
}


//图片尺寸压缩
- (void)scaleToSizeImage
{
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"IMG_3250" ofType:@"PNG"];
    UIImage *orgImg = [UIImage imageNamed:@"IMG_3250.PNG"];
//    NSData *imageData = UIImageJPEGRepresentation(orgImg,1.0f);//第二个参数为压缩倍数
    UIImage *subImg;
    if (orgImg) {
        subImg = [ZHTUtils scaleToSize:orgImg size:CGSizeMake(orgImg.size.width/2.0, orgImg.size.height/2.0)];
    }
    NSLog(@"orgImg===width:%f====height:%f",orgImg.size.width,orgImg.size.height);
    NSLog(@"subImg===width:%f====height:%f",subImg.size.width,subImg.size.height);
    UIImageView *allScreenView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 300, 100, 200)];
    if (subImg) {
        allScreenView.image = orgImg;
    }
    allScreenView.backgroundColor = [UIColor lightGrayColor];
    allScreenView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:allScreenView];
    
    UIImageView *subView = [[UIImageView alloc]initWithFrame:CGRectMake(150, 300, 100, 200)];
    if (subImg) {
        subView.image = subImg;
    }
    subView.backgroundColor = [UIColor lightGrayColor];
    subView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:subView];
}

//图片旋转
- (void)rotateImage
{
    
    UIImage *orgImg = [UIImage imageNamed:@"IMG_3250.PNG"];
//    NSData *imageData = UIImageJPEGRepresentation(orgImg,1.0f);//第二个参数为压缩倍数
    UIImage *subImg;
    if (orgImg) {
        subImg = [ZHTUtils rotateImage:orgImg rotation:UIImageOrientationRight];
    }
    UIImageView *allScreenView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 300, 100, 200)];
    if (subImg) {
        allScreenView.image = orgImg;
    }
    allScreenView.backgroundColor = [UIColor lightGrayColor];
    allScreenView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:allScreenView];
    
    UIImageView *subView = [[UIImageView alloc]initWithFrame:CGRectMake(150, 300, 100, 200)];
    if (subImg) {
        subView.image = subImg;
    }
    subView.backgroundColor = [UIColor lightGrayColor];
    subView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:subView];

}

//调起Safari浏览器打开应用
- (void)openSafariWithLinkAddress
{
    [ZHTUtils openSafariWithLinkAddress:@"https://www.baidu.com"];
}

//调起快速跳转AppStore
- (void)openAppStoreWithAppLink
{
    [ZHTUtils openAppStoreWithAppLink:@"https://itunes.apple.com/cn/app/id1050551165"];
}

//字符串写入剪切板
- (void)pasteBoardSetString
{
    [ZHTUtils pasteBoardSetString:@"https://itunes.apple.com/cn/app/id1050551165"];
}

//获取剪切板数据
- (void)pasteBoardShow
{
    NSString *string = [ZHTUtils pasteBoardShow];
}

//文件共享
- (void)interactionControllerWithURL
{
    NSURL *url = [[NSBundle mainBundle]URLForResource:@"IMG_3250" withExtension:@"PNG"];
    ZHTUtils *utils = [[ZHTUtils alloc]init];
    [utils interactionController:nil WithURL:url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
