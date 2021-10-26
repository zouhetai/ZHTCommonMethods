//
//  ZHTUtils.m
//  ZHTCommonMethods_Example
//
//  Created by zouhetai on 2021/5/17.
//  Copyright © 2021 1452327617@qq.com. All rights reserved.
//

#import "ZHTUtils.h"
#import <objc/runtime.h>
#include <sys/sysctl.h>


#define DOCUMENT_FOLDER(fileName) [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:fileName]

//越狱检测，多种方法共用
#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
#define USER_APP_PATH @"/User/Applications/"

@interface ZHTUtils ()<UIDocumentInteractionControllerDelegate>

@property(nonatomic,strong)UIViewController *viewController;
@end

const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/usr/sbin/sshd",
    "/etc/apt"
};

BOOL match(NSRegularExpression *regex, NSString *string)
{
    NSTextCheckingResult *match = [regex firstMatchInString:string
                                                    options:0
                                                      range:NSMakeRange(0, [string length])];
    if (match) {
        NSRange matchRange = [match range];
        if (matchRange.length == [string length]) {
            return TRUE;
        }
    }
    return FALSE;
}

@implementation ZHTUtils
//MARK:数据存取
/*
 * dict为需保存字典参数，写入数据到本地沙盒，若dict为空，则做不保存操作
 * 返回值为dataUrl通过/分割的最后一段，再去除.json
*/
+ (NSString*)saveJsonWith:(id)dict withDataUrl:(NSString *)dataUrl
{
    NSArray *urlArr = [dataUrl componentsSeparatedByString:@"/"];
    NSString *typeString;
    if(urlArr.count != 0){
        NSString *urlSring = [urlArr lastObject];
        if ([urlSring containsString:@".json"]) {
            NSArray *jsonArr = [urlSring componentsSeparatedByString:@".json"];
            if (jsonArr.count != 0) {
                typeString = [jsonArr firstObject];
            }
        }else
        {
            typeString = urlSring;
        }
    }
    //保存数据到沙河，后期获取json时打开，Application supports iTunes file sharing
    if (dict) {
        NSString *jsonName = [NSString stringWithFormat:@"%@.json",typeString];
        [dict writeToFile:DOCUMENT_FOLDER(jsonName) atomically:YES];
    }
    
    return typeString;
}

/*
 *根据fileName，读取本地json数据
 *返回本地保存的字典
 */
+ (NSDictionary *)dictWithJsonFile:(NSString *)fileName
{
    
    NSString *fileJson = [self saveJsonWith:nil withDataUrl:fileName];
    NSString *navPath = [[NSBundle mainBundle] pathForResource:fileJson ofType:@"json"];
    
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:navPath];
    NSDictionary *dict;
    if (data) {
        dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];;
    }
    
    return dict;
}
//MARK:关键字判断
/*
 *判断字典中是否存在特定参数key，若存在返回YES
 *特定参数包含Url、FeedUrl、AppUrl、MPSUrl、MPSNativeUrl
 */
+ (BOOL)dictWithUrl:(NSDictionary *)dict{
    if (dict[@"Url"] || dict[@"FeedUrl"] ||  dict[@"AppUrl"] ||  dict[@"MPSUrl"] ||  dict[@"MPSNativeUrl"]) {
        return YES;
    }
    return NO;
}

//MARK:时间获取与比较
/*
 *返回当前时间，时区为GMT+0800，时间格式通过dateFormat控制
 *dateFormat默认参数为yyyy-MM-dd HH:mm:ss
 */
+ (NSString *)nowTimeStr:(NSString*)dateFormat
{
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    form.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    NSString *dateFormatStr = @"yyyy-MM-dd HH:mm:ss";
    if (dateFormat) {
        dateFormatStr = dateFormat;
    }
    [form setDateFormat:dateFormatStr];
    NSDate *date = [NSDate date];
    
    return [form stringFromDate:date];

}

/*
 *与当前时间比较yyyy-MM-dd，时间格式通过dateFormat控制
 *paramsDateString为传入时间参数，参数格式需与dateFormat参数相同
 *dateFormat默认参数为yyyy-MM-dd HH:mm:ss
 */
+ (BOOL)compareDate:(NSString*)paramsDateString withDateformat:(NSString*)dateFormat
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    // 设置日期格式 为了转换成功
    NSString *dateFormatStr = @"yyyy-MM-dd HH:mm:ss";
    if (dateFormat) {
        dateFormatStr = dateFormatStr;
    }
    format.dateFormat = dateFormatStr;
    // NSString * -> NSDate *
    //参数时间
    NSDate *paramDate = [format dateFromString:paramsDateString];
    NSString *nowTimeStr = [self nowTimeStr:format.dateFormat];
    //当前时间
    NSDate *nowDate = [format dateFromString:nowTimeStr];

    NSComparisonResult result = [paramDate compare:nowDate];
    if (result == NSOrderedDescending) {
        //NSLog(@"oneDay比 anotherDay时间晚");
        return YES;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"oneDay比 anotherDay时间早");
        return NO;
    }
    //NSLog(@"两者时间是同一个时间");
    return NO;

}

//MARK:json字符串转OC对象
/*
 *json字符串转OC对象，格式为UTF8，返回OC对象
 *返回字典、数组对象
 */
+ (id)objectWithStr:(NSString *)jsonString
{
    if (jsonString) {
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        return  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    } else {
        return nil;
    }
}

//MARK:model对象转字典
/*
 *model对象转字典
 *
 */
+ (NSDictionary *)dicFromObject:(NSObject *)object {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([object class], &count);
 
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:cName];
        NSObject *value = [object valueForKey:name];//valueForKey返回的数字和字符串都是对象
 
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            //string , bool, int ,NSinteger
            [dic setObject:value forKey:name];
 
        } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            //字典或字典
            [dic setObject:[self arrayOrDicWithObject:(NSArray*)value] forKey:name];
 
        } else if (value == nil) {
            //null
            //[dic setObject:[NSNull null] forKey:name];//这行可以注释掉?????
 
        } else {
            //model
            [dic setObject:[self dicFromObject:value] forKey:name];
        }
    }
 
    return [dic copy];
}
//将可能存在model数组转化为普通数组
+ (id)arrayOrDicWithObject:(id)origin
{
    if ([origin isKindOfClass:[NSArray class]]) {
        //数组
        NSMutableArray *array = [NSMutableArray array];
        for (NSObject *object in origin) {
            if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [array addObject:object];
 
            } else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [array addObject:[self arrayOrDicWithObject:(NSArray *)object]];
 
            } else {
                //model
                [array addObject:[self dicFromObject:object]];
            }
        }
 
        return [array copy];
 
    } else if ([origin isKindOfClass:[NSDictionary class]]) {
        //字典
        NSDictionary *originDic = (NSDictionary *)origin;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *key in originDic.allKeys) {
            id object = [originDic objectForKey:key];
 
            if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [dic setObject:object forKey:key];
 
            } else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [dic setObject:[self arrayOrDicWithObject:object] forKey:key];
 
            } else {
                //model
                [dic setObject:[self dicFromObject:object] forKey:key];
            }
        }
 
        return [dic copy];
    }
 
    return [NSNull null];
}

//MARK:生成随机数
/*
 *返回随机数
 *randomScope为随机数范围
 *needTime为是否添加时间戳到返回参数
 */
+ (NSString*)getRandom:(NSInteger)randomScope withNeedTime:(BOOL)needTime
{

    NSInteger randomScp = 100;
    if (randomScope) {
        randomScp = randomScope;
    }
    int x = arc4random()%randomScp;
    if (needTime) {
        NSString *randomStr= [NSString stringWithFormat:@"%.0f",[[[NSDate alloc]init] timeIntervalSince1970]];
    //    NSLog(@"randomStr%@",randomStr);
        NSString *aStr=[NSString stringWithFormat:@"%d%@",x,randomStr];
    //    NSLog(@"aStr%@",aStr);
        return aStr;

    }else
    {
        return [NSString stringWithFormat:@"%d",x];
    }
}

//MARK:url截取图片名称
/*
 *根据图片url,截取分割方式返回图片名称
 *分割字符串为navi_Tabbar/，若url中不包含，则使用/进行分割
 *若url分割失败，返回空字符串
 */
+ (NSString*)returnImageName:(NSString *)imageUrlName
{
    NSArray *imgStringArr = [imageUrlName componentsSeparatedByString:@"navi_Tabbar/"];
    NSString *imgString = @"";
    if (imgStringArr.count > 1) {
        imgString = [imgStringArr lastObject];
        return imgString;
    }else{
        //该段代码暂未使用，预留通过/分割字符串入口
        NSArray *imgArr = [imageUrlName componentsSeparatedByString:@"/"];
        if (imgArr.count > 1) {
            imgString = [imgArr lastObject];
        }
        return imgString;
    }
    return imgString;
}

//MARK:二进制data转16进制字符串
/*
 *二进制data转16进制字符串
 *返回字符串对象，用于推送DeviceToken转换
 */
+ (NSString*)getHexStringForData:(NSData *)data
{
    NSUInteger len = [data length];
    char *chars = (char *)[data bytes];
    NSMutableString *hexString = [[NSMutableString alloc]init];
    for (NSUInteger i = 0; i<len; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx",chars[i]]];
    }
    return hexString;
}

//MARK:对象转换为json字符串
/*
 *OC对象转换为json字符串
 *返回字符串对象
 */
+ (NSString *)convertToJsonData:(id)object
{
    NSError *error;
    NSString *jsonString;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}

//MARK:当前控制器
/*
 *获取当前页面的控制器
 *返回当前页控制器
 */
+ (UIViewController *)getCurrentVC
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    //从根控制器开始查找
    UIViewController *rootVC = window.rootViewController;
    UIViewController *activityVC = nil;
    
    while (true) {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            activityVC = [(UINavigationController *)rootVC visibleViewController];
        } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
            activityVC = [(UITabBarController *)rootVC selectedViewController];
        } else if (rootVC.presentedViewController) {
            activityVC = rootVC.presentedViewController;
        }else {
            break;
        }
        
        rootVC = activityVC;
    }
    
    return rootVC;
}

//MARK:系统提示框
/*
 *显示系统提示框
 *message为提示参数
 *提示框点击确定或取现按钮回调
 */
+ (void)alertMsg:(NSString*)message
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertVC addAction:alertAction];
    [[self getCurrentVC] presentViewController:alertVC animated:YES completion:nil];

}

/*
 *显示系统提示框
 *message为提示参数
 *提示框点击确定或取现按钮回调
 */
+ (void)alertMsg:(NSString*)message withBlock:(UtilsAlertBlock)utilsAlertBlock
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (utilsAlertBlock) {
            utilsAlertBlock(YES);
        }
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if (utilsAlertBlock) {
            utilsAlertBlock(NO);
        }
    }];
    [alertVC addAction:alertAction];
    [alertVC addAction:cancleAction];
    [[self getCurrentVC] presentViewController:alertVC animated:YES completion:nil];

}

//MARK:系统版本
/*
 *获取系统版本参数
 *appBundleVersion为应用版本参数,用于区分返回版本参数
 *根据参数返回对应版本号，默认返回商店显示版本
 */
+ (NSString *)getAppVersion:(APPBundleVERSION )appBundleVersion
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    NSString *bundleVersion = [infoDic objectForKey:@"CFBundleVersion"];
//    NSLog(@"appVersion:%@====bundleVersion:%@",appVersion,bundleVersion);
    NSString *version = appVersion;
    if (appBundleVersion == CFBundleShortVersionString) {
        version = appVersion;
    }else if (appBundleVersion == CFBundleVersion)
    {
        version = bundleVersion;
    }
    return version;
}
//MARK:越狱检测
static const char * __jb_app = NULL;
/*
 *检测应用是否越狱
 *返回值NO为未越狱，YES为越狱
 */
+ (BOOL)isJailBreak:(BOOL)needPrompt
{
    static const char * __jb_apps[] =
    {
        "/Application/Cydia.app",
        "/Application/limera1n.app",
        "/Application/greenpois0n.app",
        "/Application/blackra1n.app",
        "/Application/blacksn0w.app",
        "/Application/redsn0w.app",
        NULL
    };
    __jb_app = NULL;
    BOOL isJailBreak = NO;
    // method 1
    for ( int i = 0; __jb_apps[i]; ++i )
    {
        if ( [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:__jb_apps[i]]] )
        {
            __jb_app = __jb_apps[i];
            isJailBreak = YES;
//            return YES;
        }
    }
    // method 2
    if ( [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] )
    {
        isJailBreak = YES;
//        return YES;
    }
    // method 3
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        NSLog(@"存在cydia的URL scheme，设备已越狱");
        isJailBreak = YES;

//        return YES;
    } else {
//        NSLog(@"不存在cydia的URL scheme，设备未越狱");
    }
    // method 4
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Applications/"]) {
        NSLog(@"具备读取系统所有应用名称的权限，设备已越狱");
        isJailBreak = YES;
//        return YES;
    } else {
//        NSLog(@"不具备读取系统所有应用名称的权限，设备未越狱");
    }
    NSLog(@"结束检测,未检测到越狱");
    //越狱提示，退出应用
    if (!isJailBreak && needPrompt) {
        [self alertMsg:@"您的设备已经越狱，存在安全风险，将无法使用本应用"];
    }
    return isJailBreak;
}

//MARK:正则校验
/*
 *判断是否为手机号码
 *phoneNumber为传入参数
 *返回值NO为非手机号，YES为手机号
 */
+ (BOOL)isPhoneNumber:(NSString*)phoneNumber
{
    NSString *pattern = @"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    return  match(regex, phoneNumber);
}

/**
 * 检测是否为6到16位，字母或数字组合
 * @param password 密码
 */
+ (BOOL)isValidPassword:(NSString*)password
{
    NSString *pattern = @"^(?![a-zA-Z]+$)(?![0-9]+$)[0-9a-zA-Z]{6,16}$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    return match(regex, password);
}

/**
 *正则校验通用方法
 * @param regularPattern 正则规则
 * @param parameter 需进行正则校验的参数
 * 返回参数是否符合正则校验
 */
+ (BOOL)regularCheck:(NSString*)regularPattern withCheck:(NSString*)parameter
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularPattern options:0 error:nil];
    return match(regex, parameter);
}

/**
 *磁盘总空间，单位MB
 */
+ (CGFloat)diskOfAllSizeMBytes
{
    CGFloat size = 0.0;
    NSError *error;
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) {
#ifdef DEBUG
        NSLog(@"error: %@", error.localizedDescription);
#endif
    }else{
        NSNumber *number = [dic objectForKey:NSFileSystemSize];
        size = [number floatValue]/1024/1024;
    }
    return size;
}


/**
 *磁盘可用空间，单位MB
 */
+ (CGFloat)diskOfFreeSizeMBytes
{
    CGFloat size = 0.0;
    NSError *error;
    NSDictionary *dic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) {
#ifdef DEBUG
        NSLog(@"error: %@", error.localizedDescription);
#endif
    }else{
        NSNumber *number = [dic objectForKey:NSFileSystemFreeSize];
        size = [number floatValue]/1024/1024;
    }
    return size;
}


/**
 *全屏截图
 */
+ (UIImage *)allScreenShotsView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIGraphicsBeginImageContext(window.bounds.size);
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 *根据传入视图参数生成图片
 *view视图参数
 */
+ (UIImage *)screenShotsWithView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 *获取bundle中的图片
 *bundleName 为bundle名称
 *imageName 为图片名称
 *返回图片对象
 */
+ (UIImage *)fetchBundle:(NSString *)bundleName Image:(NSString *)imageName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    UIImage * iamge = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    return iamge;
}

//裁剪图片
+ (UIImage *)getImageFromImage:(UIImage*) superImage  subImageRect:(CGRect)subImageRect
{
    if (superImage) {
        CGImageRef imageRef = superImage.CGImage;
        CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, subImageRect);
        UIGraphicsBeginImageContext(subImageRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, subImageRect, subImageRef);
        UIImage* returnImage = [UIImage imageWithCGImage:subImageRef];
        CFRelease(subImageRef);
        UIGraphicsEndImageContext();
        return returnImage;
    }else
    {
        return nil;
    }
}

//压缩图片
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

/**
 *  @orient 对照片旋转方向
 *
 *  @param img 原照片
 *
 *  @return 返回旋转后的图片
 */
+ (UIImage*)rotateImage:(UIImage *)img rotation:(UIImageOrientation)orient
{
    CGRect bnds = CGRectZero;
    UIImage* copy = nil;
    CGContextRef ctxt = nil;
    CGImageRef imag = img.CGImage;
    CGRect rect = CGRectZero;
    CGAffineTransform tran = CGAffineTransformIdentity;
    
    rect.size.width = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    switch (orient)
    {
        case UIImageOrientationUp:
            return img;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        default:
            return img;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}
/** 交换宽和高 */
static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat swap = rect.size.width;
    
    rect.size.width = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}


#pragma mark -- 判断手机型号
/**
 *获取手机设备型号
 *当前最新为iPhone 12 pro max
 */
+ (NSString *)getDeviceModelName
{
    //https://www.theiphonewiki.com/wiki/Models 设备型号官网
    static dispatch_once_t one;
    static NSString *name;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = (char *)malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSString *deviceModalName = [NSString stringWithUTF8String:machine];
        free(machine);
        
        NSDictionary *dic = @{
                              @"iPhone1,1" : @"iPhone 1G",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPhone3,1" : @"iPhone 4 (GSM)",
                              @"iPhone3,2" : @"iPhone 4",
                              @"iPhone3,3" : @"iPhone 4 (CDMA)",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPhone5,1" : @"iPhone 5",
                              @"iPhone5,2" : @"iPhone 5",
                              @"iPhone5,3" : @"iPhone 5c",
                              @"iPhone5,4" : @"iPhone 5c",
                              @"iPhone6,1" : @"iPhone 5s",
                              @"iPhone6,2" : @"iPhone 5s",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6s",
                              @"iPhone8,2" : @"iPhone 6s Plus",
                              @"iPhone8,4" : @"iPhone SE",
                              @"iPhone9,1" : @"iPhone 7",
                              @"iPhone9,2" : @"iPhone 7 Plus",
                              @"iPhone9,3" : @"iPhone 7",
                              @"iPhone9,4" : @"iPhone 7 Plus",
                              @"iPhone10,3" : @"iPhone X",
                              @"iPhone10,6" : @"iPhone X",
                              @"iPhone11,8" : @"iPhone XR",
                              @"iPhone11,2" : @"iPhone XS",
                              @"iPhone11,4" : @"iPhone XS Max",
                              @"iPhone11,6" : @"iPhone XS Max",
                              @"iPhone12,1" : @"iPhone 11",
                              @"iPhone12,3" : @"iPhone 11 Pro",
                              @"iPhone12,5" : @"iPhone 11 Pro Max",
                              @"iPhone12,8" : @"iPhone SE2",
                              @"iPhone13,1" : @"iPhone 12 mini",
                              @"iPhone13,2" : @"iPhone 12",
                              @"iPhone13,3" : @"iPhone 12  Pro",
                              @"iPhone13,4" : @"iPhone 12  Pro Max",

                              @"i386" : @"Simulator x86",
                              @"x86_64" : @"Simulator x64",
                              };
        name = dic[deviceModalName];
        if (!name) name = deviceModalName;
    });
    return name;
}

/**
 *获取手机是否存在安全区间
 *存在则为刘海屏手机，XR、XS、XSPro等
 */
+ (BOOL)isHaveSafeRange
{
    if (@available(iOS 11.0, *)) {
                UIWindow *window = [UIApplication sharedApplication].delegate.window;
                if (window.safeAreaInsets.bottom > 0.0) {
                    // 是机型iPhoneX/iPhoneXR/iPhoneXS/iPhoneXSMax
                    return YES;
                }
    }
    return NO;
}

/**
 *获取手机系统版本
 *
 */
+ (NSString *)phoneSystemVersion
{
    NSString *phoneVersion = [[UIDevice currentDevice] systemVersion];
    return phoneVersion;
}

/**
 *调起手机拨打电话
 *phoneNumber 拨打的电话号码
 */
+ (void)callPhoneWithNumber:(NSString*)phoneNumber
{
    
    NSString *phoneStr = [NSString stringWithFormat:@"tel://%@",phoneNumber];
    //设备系统为IOS 10.0或者以上的
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr] options:@{} completionHandler:nil];
    } else {
        //设备系统为IOS 10.0以下的
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
    }
    
}

/**
 *调起自带Safari浏览器
 *linkAddress为链接地址
 */
+ (void)openSafariWithLinkAddress:(NSString*)linkAddress
{
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkAddress] options:@{} completionHandler:nil];
    } else {
        //设备系统为IOS 10.0以下的
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkAddress]];
    }
}

/**
 *快速跳转App Store查看应用
 *appId为应用在商店唯一标识码
 */
+ (void)openAppStoreWithAppLink:(NSString*)AppLink
{
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppLink] options:@{} completionHandler:nil];
    } else {
        //设备系统为IOS 10.0以下的
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppLink]];
    }
}


/**
 *获取剪切板内容
 *返回剪切板字符串
 */
+ (void)pasteBoardSetString:(NSString*)pasteString
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:pasteString];
    NSLog(@"pasteString====%@",pasteString);
}

/**
 *UIPasteboard是剪切板功能
 *pasteString为需写入剪切板内容字符串
 */
+ (NSString*)pasteBoardShow
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    NSString *pasteString = pasteBoard.string;
    return pasteString;
}

/**
 *文件共享功能，文件可共享到其他应用或设备
 *url参数，文件转化为url
 */
- (void)interactionController:(UIViewController*)viewController WithURL:(NSURL*)url
{

    if (url && [viewController isKindOfClass:[UIViewController class]]) {
        UIDocumentInteractionController *interface =[UIDocumentInteractionController interactionControllerWithURL:url];
        _viewController = viewController;
        [interface setDelegate:self];
        [interface presentPreviewAnimated:YES];
    }else if(url){
        UIDocumentInteractionController *interface =[UIDocumentInteractionController interactionControllerWithURL:url];
        [interface setDelegate:self];
        [interface presentPreviewAnimated:YES];
    }
        
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    if ([self.viewController isKindOfClass:[UIViewController class]]) {
        return self.viewController;
    }
    UIViewController *viewController = [[UIViewController alloc]init];
    if ([ZHTUtils getCurrentVC]) {
        viewController = [ZHTUtils getCurrentVC];
    }
    return viewController;
}

@end
