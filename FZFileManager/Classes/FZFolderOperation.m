//
//  FZFolderOperation.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/25.
//

#import "FZFolderOperation.h"

#import "FZPathOperation.h"
/**
 * NSFileAppendOnly
 * 这个键的值需要设置为一个表示布尔值的NSNumber对象，表示创建的目录是否是只读的。
 * 
 * NSFileCreationDate
 * 这个键的值需要设置为一个NSDate对象，表示目录的创建时间。
 * 
 * NSFileOwnerAccountName
 * 这个键的值需要设置为一个NSString对象，表示这个目录的所有者的名字。
 * 
 * NSFileGroupOwnerAccountName
 * 这个键的值需要设置为一个NSString对象，表示这个目录的用户组的名字。
 * 
 * NSFileGroupOwnerAccountID
 * 这个键的值需要设置为一个表示unsigned int的NSNumber对象，表示目录的组ID。
 * 
 * NSFileModificationDate
 * 这个键的值需要设置一个NSDate对象，表示目录的修改时间。
 * 
 * NSFileOwnerAccountID
 * 这个键的值需要设置为一个表示unsigned int的NSNumber对象，表示目录的所有者ID。
 * 
 * NSFilePosixPermissions
 * 这个键的值需要设置为一个表示short int的NSNumber对象，表示目录的访问权限。
 * 
 * NSFileReferenceCount
 * 这个键的值需要设置为一个表示unsigned long的NSNumber对象，表示目录的引用计数，即这个目录的硬链接数。
 * 
 * 这样，通过合理的设计attributes字典中的不同键的值，这个接口所创建的目录的属性就会基本满足我们的需求了。
 */
@implementation FZFolderOperation

/** 沙盒的主目录路径 */
+ (NSString *)home{
    return NSHomeDirectory();
}
/** 沙盒中Documents的目录路径 */
+ (NSString *)documents{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}
/** 沙盒中Library的目录路径 */
+ (NSString *)library{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];;
}
/** 沙盒中Libarary/Preferences的目录路径 */
+ (NSString *)preferences {
    NSString *libraryDir = [self library];
    return [libraryDir stringByAppendingPathComponent:@"Preferences"];
}
/** 沙盒中Library/Caches的目录路径 */
+ (NSString *)caches {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}
/** 沙盒中tmp的目录路径 */
+ (NSString *)tmp {
    return NSTemporaryDirectory();
}


/**
 * 创建文件(夹)
 *
 * @param path 路径
 * @param error error
 * @return return value
 */
+(BOOL)createFolderAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    /** 如果路径存在，但是不是文件路径,直接返回 */
    if ([self isExistingPath:path] && [self isExistingFilePath:path error:error]) return false;
    /* withIntermediateDirectories: 表示是否可以覆盖中间已存在的文件夹 */
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
}

/** 清理路径 */
+(BOOL)removePath:(NSString *)path{
    if ([self isExistingPath:path] == false) return true;
    NSArray *subpaths = [self subpathsOfPath:path deep:NO error:nil];
    if (subpaths.count == 0) return [self removeItemAtPath:path error:nil];
    BOOL result = true;
    for (NSString *subpath in subpaths) {
        NSString *absolutePath = [path stringByAppendingPathComponent:subpath];
        result &= [self removeItemAtPath:absolutePath error:nil];
    }
    return result;
}

/** 清理Caches文件夹 */
+(BOOL)clearCachesFolder{
    return [self removePath:[self caches]];
}

/** 清理Tmp文件夹 */
+(BOOL)clearTmpFolder{
    return [self removePath:[self tmp]];
}


@end
