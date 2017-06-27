//
//  Factory.h
//  ContactDemo
//
//  Created by 郑文青 on 2017/6/27.
//  Copyright © 2017年 zhengwenqing’s mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Factory : NSObject

// ios 9 以前 获取通讯录数组

+(NSArray *)getIOS9BeforeAddressBooks;
//ios 9 以前 查看是否有权限读取通讯录

+(void)CheckAddressBookIOS9BeforeAuthorization:(void (^)(bool isAuthorized))block;

//ios 9 以后 使用block 返回 联系人数组

+(void)getIOS9AfterContactsSuccess:(void (^)(NSArray *contacts))block;
//ios 9以后查看是否有权限读取通讯录

+ (void)checkAddressBookIOS9AfterAuthorization:(void (^)(bool isAuthorized))block;
@end
