//
//  WJKeyChain.h
//  moyouAPP
//
//  Created by 幻想无极（谭启宏） on 2016/11/22.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

/**钥匙串管理*/

@interface WJKeyChain : NSObject

/**储存UUID在钥匙串*/
+ (void)saveUUIDToKeyChain;

/**从钥匙串读取UUID*/
+ (NSString *)readUUIDFromKeyChain;

/**从钥匙串删除UUID*/
+ (void)deletekeyChain;

@end
