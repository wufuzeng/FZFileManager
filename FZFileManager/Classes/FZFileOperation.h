//
//  FZFileOperation.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/25.
//

#import "FZPathOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface FZFileOperation : FZPathOperation

/** 根据文件路径获取文件名称，是否需要后缀 */
+ (NSString *)fileNameAtPath:(NSString *)path suffix:(BOOL)suffix;

/** 根据文件路径获取文件扩展类型 */
+ (NSString *)suffixAtPath:(NSString *)path;

/** 创建文件 */
+(BOOL)createFileAtPath:(NSString *)path content:(nullable NSObject *)content overwrite:(BOOL)overwrite attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attributes error:(NSError *__autoreleasing *)error;
/** 复制文件 */
+(BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error;

/** 移动文件 */
+(BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error;

/** 写入文件 */
+ (void)writeToFile:(NSString *)path content:(NSObject *)content async:(BOOL)async completedHandler:(void(^)(BOOL result,NSError *error))completedHandler;

/** 读取文件 */
+ (void)readFile:(NSString *)path type:(Class)type async:(BOOL)async completedHandler:(void(^)(id result,NSError *error))completedHandler;
 
@end

NS_ASSUME_NONNULL_END
