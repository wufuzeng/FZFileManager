//
//  FZPathOperation.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FZPathOperation : NSObject

/** 路径项大小(不包括子路径项)（格式化后的数值） */
+ (NSString *)sizeFormattedOfItemAtPath:(NSString *)path error:(NSError **)error;

/** 路径项大小(不包括子路径项)  */
+ (NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error;

/** 路径内容大小（格式化后的数值） */
+ (NSString *)sizeFormattedOfContentsAtPath:(NSString *)path error:(NSError *__autoreleasing*)error;

/** 路径内容大小 */
+ (NSNumber *)sizeOfContentsAtPath:(NSString *)path error:(NSError *__autoreleasing *)error;


/** 文件(夹)属性 */
+ (NSDictionary *)attributesOfPath:(NSString *)path error:(NSError *__autoreleasing *)error;

/** 父路径 */
+ (NSString *)superPathOfPath:(NSString *)path;
/** 子路径 */
+ (NSArray *)subpathsOfPath:(NSString *)path deep:(BOOL)deep error:(NSError *__autoreleasing*)error;

/** 是否是已存在路径 */
+ (BOOL)isExistingPath:(NSString *)path;
/** 是否是已存在文件夹路径 */
+ (BOOL)isExistingFolderPath:(NSString *)path;
/** 是否是已存在文件路径 */
+ (BOOL)isExistingFilePath:(NSString *)path error:(NSError *__autoreleasing *)error;

/** 移除路径项 */
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error;

/** 复制路径项 */
+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error;

/** 移动路径项 */
+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error;

/** 不希望Documents目录下指定资源会被iCloud备份 */
+ (BOOL)disableBackingupSubpathOfDocuments:(NSString *)path error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
