//
//  FZFileOperation.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/25.
//

#import "FZFileOperation.h"
#import "FZFolderOperation.h"
@implementation FZFileOperation

/** 根据文件路径获取文件名称，是否需要后缀 */
+ (NSString *)fileNameAtPath:(NSString *)path suffix:(BOOL)suffix{
    NSString *fileName = [path lastPathComponent];
    if (!suffix) {
        fileName = [fileName stringByDeletingPathExtension];
    }
    return fileName;
}

/** 根据文件路径获取文件扩展类型 */
+ (NSString *)suffixAtPath:(NSString *)path {
    return [path pathExtension];
}

/**
 * 创建文件
 *
 * @param path path
 * @param content content
 * @param overwrite overwrite
 * @param attributes attributes
 * @return return value
 */
+(BOOL)createFileAtPath:(NSString *)path content:(nullable NSObject *)content overwrite:(BOOL)overwrite attributes:(nullable NSDictionary<NSFileAttributeKey, id> *)attributes error:(NSError *__autoreleasing *)error {
    NSString *folderPath = [FZFolderOperation superPathOfPath:path];
    /** 如果文件夹路径不存在，那么先创建文件夹,失败直接返回 */
    if (folderPath && [FZFolderOperation createFolderAtPath:folderPath error:error] == false) return false;
    
    /** 文件存在，并不想覆盖，那么直接返回*/
    if ([FZFolderOperation isExistingPath:path] && overwrite == false) return true;
    /** 如果路径存在，但是不是文件路径,失败直接返回 */
    if ([FZFolderOperation isExistingPath:path] && ([FZFolderOperation isExistingFilePath:path error:error] == false)) return false;
    /** 创建文件 */
    BOOL result = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    if (content) {
        /** 写入文件 */
        [self writeToFile:path content:content error:error];
    }
    return result;
}

/**
 * 复制文件
 *
 * @param srcPath srcPath
 * @param dstPath dstPath
 * @param error error
 * @return return value
 */
+(BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error{
    return [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:error];
}


/**
 * 移动文件
 *
 * @param srcPath srcPath
 * @param dstPath dstPath
 * @param error error
 * @return return value
 */
+(BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error{
    return [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:error];
}


/**
 * 写入文件
 *
 * @param path path
 * @param content content
 * @param completedHandler completedHandler
 */
+ (void)writeToFile:(NSString *)path content:(NSObject *)content async:(BOOL)async completedHandler:(void(^)(BOOL result,NSError *error))completedHandler{
    if (async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            BOOL result=[self writeToFile:path content:content error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completedHandler){
                    completedHandler(result,error);
                }
            });
        });
    }else{
        NSError *error = nil;
        BOOL result = [self writeToFile:path content:content error:&error];
        if (completedHandler) {
            completedHandler(result,error);
        }
    }
}

/**
 * 写入文件
 *
 * @param path path
 * @param content content
 * @param error error
 * @return return value
 */
+ (BOOL)writeToFile:(NSString *)path content:(NSObject *)content error:(NSError *__autoreleasing *)error {
    if (!content) {
        [NSException raise:@"非法的文件内容" format:@"文件内容不能为nil"];
        return NO;
    }
    if (([self isExistingPath:path]) == false && ([FZFileOperation createFileAtPath:path content:nil overwrite:YES attributes:nil error:error] == false)) return false;
     
    if ([content isKindOfClass:[NSMutableArray class]]) {
        return [(NSMutableArray *)content writeToFile:path atomically:YES];
    } else if ([content isKindOfClass:[NSArray class]]) {
        return [(NSArray *)content writeToFile:path atomically:YES];
    } else if ([content isKindOfClass:[NSMutableData class]]) {
        return [(NSMutableData *)content writeToFile:path atomically:YES];
    } else if ([content isKindOfClass:[NSData class]]) {
        return [(NSData *)content writeToFile:path atomically:YES];
    } else if ([content isKindOfClass:[NSMutableDictionary class]]) {
        return [(NSMutableDictionary *)content writeToFile:path atomically:YES];
    } else if ([content isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)content writeToFile:path atomically:YES];
    } else if ([content isKindOfClass:[NSMutableString class]]) {
        return [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
    } else if ([content isKindOfClass:[NSString class]]) {
        return [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
    } else if ([content isKindOfClass:[UIImage class]]) {
        return [UIImagePNGRepresentation((UIImage *)content) writeToFile:path atomically:YES];
    } else if ([content conformsToProtocol:@protocol(NSCoding)]) {
        return [NSKeyedArchiver archiveRootObject:content toFile:path];
    } else {
        [NSException raise:@"非法的文件内容" format:@"文件类型%@异常，无法被处理。", NSStringFromClass([content class])];
        return false;
    }
}

/** 读取文件 */
+ (void)readFile:(NSString *)path type:(Class)type async:(BOOL)async completedHandler:(void(^)(id result,NSError *error))completedHandler{
    
    if (async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            id result = nil;
            if ([self isExistingFilePath:path error:&error]) {
                //result = [[NSFileManager defaultManager] contentsAtPath:path];
                result = [self readFile:path type:type];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completedHandler){
                    completedHandler(result,error);
                }
            });
        });
    }else{
        NSError *error = nil;
        id result = nil;
        if ([self isExistingFilePath:path error:&error]) {
            //result = [[NSFileManager defaultManager] contentsAtPath:path];
            result = [self readFile:path type:type];
        }
        if (completedHandler) {
            completedHandler(result,error);
        }
    }
}

+ (id)readFile:(NSString *)path type:(Class)type {
    if ([type isEqual:[NSMutableArray class]]) {
        return [NSArray arrayWithContentsOfFile:path].mutableCopy;
    } else if ([type isEqual:[NSArray class]]) {
        return [NSArray arrayWithContentsOfFile:path];
    } else if ([type isEqual:[NSMutableData class]]) {
        return [NSData dataWithContentsOfFile:path].mutableCopy;
    } else if ([type isEqual:[NSData class]]) {
        return [NSData dataWithContentsOfFile:path];
    } else if ([type isEqual:[NSMutableDictionary class]]) {
        return [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy;
    } else if ([type isEqual:[NSDictionary class]]) {
        return [NSDictionary dictionaryWithContentsOfFile:path];
    } else if ([type isEqual:[NSMutableString class]]) {
        return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil].mutableCopy;
    } else if ([type isEqual:[NSString class]]) {
        return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    } else if ([type isEqual:[UIImage class]]) {
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
    } else if ([type conformsToProtocol:@protocol(NSCoding)]) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    } else {
        return [[NSFileManager defaultManager] contentsAtPath:path];;
    }
}


+(void)appendFile:(NSString *)path{
    
}

@end
