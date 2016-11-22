//
//  WJKeyChain.m
//  moyouAPP
//
//  Created by 幻想无极（谭启宏） on 2016/11/22.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import "WJKeyChain.h"

static NSString * const kPDDictionaryKey = @"com.xxx.dictionaryKey";
static NSString * const kPDKeyChainKey = @"com.xxx.keychainKey";

@implementation WJKeyChain

#pragma mark - 钥匙串管理

+ (void)keyChainSave:(NSString *)service {
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    [tempDic setObject:service forKey:kPDDictionaryKey];
    [self save:kPDKeyChainKey data:tempDic];
}

+ (NSString *)keyChainLoad{
    NSMutableDictionary *tempDic = (NSMutableDictionary *)[self load:kPDKeyChainKey];
    return [tempDic objectForKey:kPDDictionaryKey];
}

+ (void)keyChainDelete{
    [self delete:kPDKeyChainKey];
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

#pragma mark - UUID + 钥匙串唯一标识

+ (void)saveUUIDToKeyChain {
    //如果更新了provisioning profile的话, Keychain data会丢失.所以我们应该将UUID在NSUserDefault备份.
    NSString *string = [self readUUIDFromKeyChain];
    if ([string isEqualToString:@""] || !string) {
        NSString *UUID = [[NSUserDefaults standardUserDefaults]objectForKey:@"UUID"];
        if (UUID) {
             [self keyChainSave:UUID];
        }else {
            [[NSUserDefaults standardUserDefaults]setObject:[self getUUIDString] forKey:@"UUID"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self keyChainSave:[self getUUIDString]];
        }
       
    }
}

+ (NSString *)readUUIDFromKeyChain {
    
    return [self keyChainLoad];
}

+ (void)deletekeyChain {
    [self keyChainDelete];
}

+ (NSString *)getUUIDString {
    return [[NSUUID UUID] UUIDString];
}

@end
