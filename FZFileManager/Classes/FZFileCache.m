//
//  FZFileCache.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/7/26.
//

#import "FZFileCache.h"
#import "FZFolderOperation.h"
#import <CommonCrypto/CommonDigest.h>
@interface FZFileCache ()


@end

@implementation FZFileCache

+ (void)writeToCachedWithURL:(NSString *)URL content:(NSObject *)content async:(BOOL)async completedHandler:(void(^)(BOOL result,NSError *error))completedHandler{
    NSString *fileName = [self cachedFileNameForKey:URL]; 
    NSString *path = [[self FileCachesPath] stringByAppendingPathComponent:fileName];
    [FZFileOperation writeToFile:path content:content async:async completedHandler:completedHandler];
   
}

+ (void)readCachedWithURL:(NSString *)URL type:(Class)type async:(BOOL)async completedHandler:(void(^)(id result,NSError *error))completedHandler{
    NSString *fileName = [self cachedFileNameForKey:URL];
    NSString *path = [[self FileCachesPath] stringByAppendingPathComponent:fileName];
    [FZFileOperation readFile:path type:type async:async completedHandler:completedHandler];
}






/** MD5 */
+ (NSString *)cachedFileNameForKey:(NSString *)key{
    const char *fooData = [key UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(fooData, (CC_LONG)strlen(fooData), result);
    NSMutableString *saveResult = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [saveResult appendFormat:@"%02x", result[i]];
    }
    return saveResult;
}

+(NSString *)FileCachesPath{
    return [NSString stringWithFormat:@"%@/%@",[FZFolderOperation library],@"FileCaches"];
}

+(BOOL)clearCache{
    return [FZPathOperation removeItemAtPath:[self FileCachesPath] error:nil];
}

@end
