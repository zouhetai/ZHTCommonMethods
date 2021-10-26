//
//  ZHTUtils.h
//  ZHTCommonMethods_Example
//
//  Created by zouhetai on 2021/5/17.
//  Copyright © 2021 1452327617@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,APPBundleVERSION)//app版本
{
    CFBundleShortVersionString = 0,//应用AppStore显示版本
    CFBundleVersion = 1//应用build版本
};
typedef void(^UtilsAlertBlock)(BOOL isDetermine);//通用提示框回调block
NS_ASSUME_NONNULL_BEGIN

@interface ZHTUtils : NSObject

//MARK:数据快捷保存取出
/*
 * dict为需保存字典参数，写入数据到本地沙盒，若dict为空，则做不保存操作
 * 返回值为dataUrl通过/分割的最后一段，再去除.json
*/
+ (NSString*)saveJsonWith:(id)dict withDataUrl:(NSString *)dataUrl;

/*
 *根据fileName，读取本地json数据
 *返回本地保存的字典
 */
+ (NSDictionary *)dictWithJsonFile:(NSString *)fileName;


//MARK:时间参数相关功能
/*
 *返回当前时间，时区为GMT+0800，时间格式通过dateFormat控制
 *dateFormat默认参数为yyyy-MM-dd HH:mm:ss
 */
+ (NSString *)nowTimeStr:(NSString*)dateFormat;

/*
 *与当前时间比较yyyy-MM-dd，时间格式通过dateFormat控制
 *paramsDateString为传入时间参数，参数格式需与dateFormat参数相同
 *dateFormat默认参数为yyyy-MM-dd HH:mm:ss
 */
+ (BOOL)compareDate:(NSString*)paramsDateString withDateformat:(NSString*)dateFormat;

//MARK:数据格式转换
/*
 *json字符串转OC对象，格式为UTF8，返回OC对象
 *返回字典、数组对象
 */
+ (id)objectWithStr:(NSString *)jsonString;

/*
 *model对象转字典
 *
 */
+ (NSDictionary *)dicFromObject:(NSObject *)object;

/*
 *二进制data转16进制字符串
 *返回字符串对象，用于推送DeviceToken转换
 */
+ (NSString*)getHexStringForData:(NSData *)data;

/*
 *OC对象转换为json字符串
 *返回字符串对象
 */
+ (NSString *)convertToJsonData:(id)object;

//MARK:获取手机系统相关参数
/**
 *获取手机设备型号
 *当前最新为iPhone 12 pro max
 */
+ (NSString *)getDeviceModelName;

/**
 *获取手机是否存在安全区间
 *存在则为刘海屏手机，XR、XS、XSPro等
 */
+ (BOOL)isHaveSafeRange;

/**
 *获取手机系统版本
 */
+ (NSString *)phoneSystemVersion;

/*
 *获取应用系统版本参数
 *appBundleVersion为应用版本参数,用于区分返回版本参数
 *根据参数返回对应版本号，默认返回商店显示版本
 */
+ (NSString *)getAppVersion:(APPBundleVERSION )appBundleVersion;

/**
 *磁盘总空间大小，单位MB
 */
+ (CGFloat)diskOfAllSizeMBytes;

/**
 *磁盘可用空间，单位MB
 */
+ (CGFloat)diskOfFreeSizeMBytes;

/*
 *返回随机数
 *randomScope为随机数范围
 *needTime为是否添加时间戳到返回参数
 */
+ (NSString*)getRandom:(NSInteger)randomScope withNeedTime:(BOOL)needTime;

//MARK:图片处理
/**
 *全屏截图
 */
+ (UIImage *)allScreenShotsView;

/**
 *根据传入视图参数生成图片
 *view视图参数
 */
+ (UIImage *)screenShotsWithView:(UIView *)view;

/**
 *获取bundle中的图片
 *bundleName 为bundle名称
 *imageName 为图片名称
 *返回图片对象
 */
+ (UIImage *)fetchBundle:(NSString *)bundleName Image:(NSString *)imageName;

/**
 *  图片裁剪
 *
 *  @param superImage   原始图片
 *  @param subImageRect 裁剪的区域
 *
 *  @return 裁剪之后的图片
 */
+ (UIImage * __nullable)getImageFromImage:(UIImage * __nonnull) superImage  subImageRect:(CGRect)subImageRect;

/**
 *  压缩图片尺寸
 *
 *  @param img  原始图片
 *  @param size 压缩的大小
 *
 *  @return 压缩之后的图片
 */
+ (UIImage * __nullable)scaleToSize:(UIImage *  __nonnull)img size:(CGSize)size;



/**
 *  @orient 对照片旋转方向
 *
 *  @param img 原照片
 *
 *  @return 返回旋转后的图片
 */
+ (UIImage*)rotateImage:(UIImage *)img rotation:(UIImageOrientation)orient;


//MARK:获取当前控制器
/*
 *获取当前页面的控制器
 *返回当前页控制器
 */
+ (UIViewController *)getCurrentVC;

//MARK:通用提示框
/*
 *快速显示显示系统提示框
 *message为提示参数
 *
 */
+ (void)alertMsg:(NSString*)message;

/*
 *显示系统提示框
 *message为提示参数
 *提示框点击确定或取现按钮回调
 */
+ (void)alertMsg:(NSString*)message withBlock:(UtilsAlertBlock)utilsAlertBlock;


//MARK:正则判断
/**
 *正则校验通用方法
 * @param regularPattern 正则规则
 * @param parameter 需进行正则校验的参数
 * 返回参数是否符合正则校验
 */
+ (BOOL)regularCheck:(NSString*)regularPattern withCheck:(NSString*)parameter;

//MARK:调用手机外部功能，拨打电话
/**
 *调起手机拨打电话
 *phoneNumber 拨打的电话号码
 */
+ (void)callPhoneWithNumber:(NSString*)phoneNumber;

/**
 *调起自带Safari浏览器
 *linkAddress为链接地址
 */
+ (void)openSafariWithLinkAddress:(NSString*)linkAddress;

/**
 *快速跳转App Store查看应用
 *appId为应用在商店唯一标识码
 */
+ (void)openAppStoreWithAppLink:(NSString*)appId;

//MARK:自定义规则处理与判断
/*
 *根据图片url,截取分割方式返回图片名称
 *分割字符串为navi_Tabbar/，若url中不包含，则使用/进行分割
 *若url分割失败，返回空字符串
 */
+ (NSString*)returnImageName:(NSString *)imageUrlName;

/*
 *判断字典中是否存在特定参数key，若存在返回YES
 *特定参数包含Url、FeedUrl、AppUrl、MPSUrl、MPSNativeUrl
 */
+ (BOOL)dictWithUrl:(NSDictionary *)dict;

/*
 *判断是否为手机号码
 *phoneNumber为传入参数
 *返回值NO为非手机号，YES为手机号
 */
+ (BOOL)isPhoneNumber:(NSString*)phoneNumber;

/*
 *检测应用是否越狱
 *exitApp为检测越狱后是否提示并退出应用
 *返回值NO为未越狱，YES为越狱
 */
+ (BOOL)isJailBreak:(BOOL)needPrompt;


/**
 *UIPasteboard是剪切板功能
 *pasteString为需写入剪切板内容字符串
 */
+ (void)pasteBoardSetString:(NSString*)pasteString;

/**
 *获取剪切板内容
 *返回剪切板字符串
 */
+ (NSString*)pasteBoardShow;


/**
 *文件共享功能，文件可共享到其他应用或设备
 *viewController参数，为当前控制器
 *url参数，文件转化为url
 *url如[[NSBundle mainBundle]URLForResource:@"" withExtension:@""]
 */
- (void)interactionController:(UIViewController*)viewController WithURL:(NSURL*)url;

@end

NS_ASSUME_NONNULL_END
