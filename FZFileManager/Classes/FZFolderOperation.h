//
//  FZFolderOperation.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/25.
//

/*
 * iphone沙箱模型的有四个文件夹
 * > 手动保存的文件在documents文件里
 * > Nsuserdefaults保存的文件在tmp文件夹里
 * 1、Documents 目录：
 *    您应该将所有的应用程序数据文件写入到这个目录下。
 *    这个目录用于存储用户数据或其它应该定期备份的信息。
 * 2、AppName.app 目录：
 *    这是应用程序的程序包目录，包含应用程序的本身。
 *    由于应用程序必须经过签名，所以您在运行时不能对这个目录中的内容进行修改，否则可能会使应用程序无法启动。
 * 3、Library 目录：
 *    这个目录下有两个子目录：Caches 和 Preferences
 *     Preferences 目录：
 *        包含应用程序的偏好设置文件。
 *        您不应该直接创建偏好设置文件，而是应该使用NSUserDefaults类来取得和设置应用程序的偏好.
 *    Caches 目录：
 *        用于存放应用程序专用的支持文件，保存应用程序再次启动过程中需要的信息。
 * 4、tmp 目录：这个目录用于存放临时文件，保存应用程序再次启动过程中不需要的信息。
 */

#import "FZPathOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface FZFolderOperation : FZPathOperation

/** 沙盒的主目录路径 */
+(NSString *)home;
/** 沙盒中Documents的目录路径 */
+(NSString *)documents;
/** 沙盒中Library的目录路径 */
+(NSString *)library;
/** 沙盒中Libarary/Preferences的目录路径 */
+(NSString *)preferences;
/** 沙盒中Library/Caches的目录路径 */
+(NSString *)caches;
/** 沙盒中tmp的目录路径 */
+(NSString *)tmp;

/**
 * 创建文件(夹)
 * 
 * @param path 路径
 * @param error error
 * @return return value
 */
+(BOOL)createFolderAtPath:(NSString *)path error:(NSError *__autoreleasing *)error;

/** 清理Caches文件夹 */
+(BOOL)clearCachesFolder;

/** 清理Tmp文件夹 */
+(BOOL)clearTmpFolder;

@end

NS_ASSUME_NONNULL_END
