//
//  FZPathOperation.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/26.
//

#import "FZPathOperation.h"
#import "FZFolderOperation.h"

@implementation FZPathOperation



/** 路径项大小（格式化后的数值） */
+ (NSString *)sizeFormattedOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing*)error{
    NSNumber *size = [self sizeOfItemAtPath:path error:error];
    if (size) {
        return [NSByteCountFormatter stringFromByteCount:[size unsignedLongLongValue] countStyle:NSByteCountFormatterCountStyleFile];
    }else{
        return nil;
    }
}

/**
 * 路径项大小
 *
 * @param path path
 * @param error error
 * @return return value
 */
+ (NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error{
    NSDictionary *info = [self attributesOfPath:path error:error];
    return info[NSFileSize];
}

/** 路径内容大小（格式化后的数值） */
+ (NSString *)sizeFormattedOfContentsAtPath:(NSString *)path error:(NSError *__autoreleasing*)error{
    NSNumber *size = [self sizeOfContentsAtPath:path error:error];
    if (size) {
        return [NSByteCountFormatter stringFromByteCount:[size unsignedLongLongValue] countStyle:NSByteCountFormatterCountStyleFile];
    }else{
        return nil;
    }
}

/**
 * 路径内容大小
 *
 * @param path path
 * @param error error
 * @return return value
 */
+ (NSNumber *)sizeOfContentsAtPath:(NSString *)path error:(NSError *__autoreleasing *)error{
    NSInteger totalByteSize = [[self sizeOfItemAtPath:path error:error] integerValue];
    if ([self isExistingFolderPath:path]) {
        NSArray *subpaths = [FZFolderOperation subpathsOfPath:path deep:YES error:error];
        for (NSString *subpath in subpaths) {
            NSString *fullSubpath = [path stringByAppendingPathComponent:subpath];
            totalByteSize += [[self sizeOfItemAtPath:fullSubpath error:error] integerValue];
        }
    }
    return @(totalByteSize);
}


/**
 * 文件(夹)属性
 *
 * @param path 路径
 * @param error error
 * @return 文件属性
 */
+ (NSDictionary *)attributesOfPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:error];
}


/** 父路径 */
+ (NSString *)superPathOfPath:(NSString *)path{
    //删除最后一个路径节点
    return [path stringByDeletingLastPathComponent];
}

/**
 * 子路径
 * @param path 路径
 * @param deep 深层次(所有后代)
 * @return 目录树
 */
+ (NSArray *)subpathsOfPath:(NSString *)path deep:(BOOL)deep error:(NSError *__autoreleasing*)error {
    NSArray *listArr = nil; 
    NSFileManager *manager = [NSFileManager defaultManager];
    if (deep) {
        NSArray *deepArr = [manager subpathsOfDirectoryAtPath:path error:error];
        if (!error) {
            listArr = deepArr;
        }
    }else {
        NSArray *shallowArr = [manager contentsOfDirectoryAtPath:path error:error];
        if (!error) {
            listArr = shallowArr;
        }
    }
    return listArr;
}


/** 是否是已存在路径 */
+ (BOOL)isExistingPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
/** 是否是已存在文件夹路径 */
+ (BOOL)isExistingFolderPath:(NSString *)path{
    BOOL result = false;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&result];
    return result;
}
/** 是否是已存在文件路径 */
+ (BOOL)isExistingFilePath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSDictionary * info = [self attributesOfPath:path error:error];
    if (info[NSFileType] == NSFileTypeRegular) {
        return true;
    }else{
        return false;
    }
}

/**
 * 移除路径项
 *
 * @param path path
 * @param error error
 * @return return value 
 */
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

/**
 * 复制路径项
 *
 * @param path path
 * @param toPath toPath
 * @param overwrite overwrite
 * @param error error
 * @return return value 
 */
+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 先要保证源文件路径存在，不然抛出异常
    if ([self isExistingPath:path] == false) {
        [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
        return NO;
    }
    NSString *toFolderPath = [self superPathOfPath:toPath];
    /** 目标路径不存在，且创建失败，直接放回 */
    if (([self isExistingPath:toFolderPath] == false) && ([FZFolderOperation createFolderAtPath:toFolderPath error:error] == false)) return false;
    /** 目标路径不存在，且允许覆盖，删掉原文件 */
    if ([self isExistingPath:toPath] && overwrite ) {
        /** 删掉原文件失败，直接返回 */
        if([self removeItemAtPath:toPath error:error]) return false;
    }
    /** 复制文件 */
    BOOL result = [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:error];
    return result;
}

/**
 * 移动路径项
 *
 * @param path path
 * @param toPath toPath
 * @param overwrite overwrite
 * @param error error
 * @return return value 
 */
+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![FZFolderOperation isExistingPath:path]) {
        [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
        return NO;
    }
    NSString *toDirPath = [self superPathOfPath:toPath];
    // 创建目标文件路径,失败直接返回
    if (([FZFolderOperation isExistingPath:toDirPath] == false )&& ([FZFolderOperation createFolderAtPath:toPath error:error] == false)) return false;
    // 如果覆盖，那么先删掉原文件
    if ([FZFolderOperation isExistingPath:toPath]) {
        if (overwrite) {
            [self removeItemAtPath:toPath error:error];
        }else {
            [self removeItemAtPath:path error:error];
            return true;
        }
    }
    // 移动文件
    BOOL result = [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:error];
    return result;
}


/** 不希望Documents目录下指定资源会被iCloud备份 */
+ (BOOL)disableBackingupSubpathOfDocuments:(NSString *)path error:(NSError **)error{
    if ([self isExistingPath:path] == false) {
        [NSException raise:@"非法的文件路径" format:@"文件路径%@不存在，请检查文件路径", path];
        return NO;
    }
    return [[NSURL fileURLWithPath:path] setResourceValue:[NSNumber numberWithBool:YES]
                                                   forKey:NSURLIsExcludedFromBackupKey
                                                    error:error];
}


@end
