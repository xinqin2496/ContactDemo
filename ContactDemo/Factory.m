//
//  Factory.m
//  ContactDemo
//
//  Created by 郑文青 on 2017/6/27.
//  Copyright © 2017年 zhengwenqing’s mac. All rights reserved.
//

#import "Factory.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

@implementation Factory
//获取通讯录数组

+(NSArray *)getIOS9BeforeAddressBooks

{
    
    NSMutableArray *peopleArray = [NSMutableArray array];
    
    int __block tip = 0;
    
    ABAddressBookRef addBook = nil;
    
    addBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error){
        
        if (!greanted) {
            
            tip = 1;
            
        }
        
        dispatch_semaphore_signal(sema);
        
    });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    if (tip) {
        
        //        ChooseAlertShow(@"请您设置允许APP访问您的通讯录\n设置>通用>隐私");
        
        return nil;
        
    }
    
    CFArrayRef allLinkPeople = ABAddressBookCopyArrayOfAllPeople(addBook);
    
    CFIndex number = ABAddressBookGetPersonCount(addBook);
    
    for (int i = 0; i < number; i++) {
        
        ABRecordRef  people = CFArrayGetValueAtIndex(allLinkPeople, i);
        
        CFTypeRef abName = ABRecordCopyValue(people, kABPersonFirstNameProperty);
        
        CFTypeRef abLastName = ABRecordCopyValue(people, kABPersonLastNameProperty);
        
        CFStringRef abFullName = ABRecordCopyCompositeName(people);
        
        NSString *nameString = (__bridge NSString *)abName;
        
        NSString *lastNameString = (__bridge NSString *)abLastName;
        
        if ((__bridge id)abFullName != nil) {
            
            nameString = (__bridge NSString *)abFullName;
            
        } else {
            
            if ((__bridge id)abLastName != nil)
                
            {
                
                nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
                
            }
            
        }
        
        NSMutableArray * phoneArr = [[NSMutableArray alloc]init];
        
        ABMultiValueRef phones= ABRecordCopyValue(people, kABPersonPhoneProperty);
        
        for (NSInteger j = 0; j < ABMultiValueGetCount(phones); j++) {
            
            [phoneArr addObject:(__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j))];
            
        }
        
        NSString * notes = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonNoteProperty));
        
        NSString * email = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonEmailProperty));
        
        NSString * department = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonDepartmentProperty));
        
        NSString * organ = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonOrganizationProperty));
        
        NSString * birth = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonBirthdayProperty));
        
        //把相应的值 添加到数组里面返回 我这里举几个
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict setObject: nameString forKey:@"getName"];
        
        [dict setObject:[phoneArr firstObject] forKey:@"getNumber"];//这里只取第一个联系人电话
        
        [dict setObject: notes forKey:@"getNotes"];
        
        [dict setObject: email forKey:@"getEmail"];
        
        [dict setObject: department forKey:@"getDepartment"];
        
        [dict setObject: organ forKey:@"getOrgan"];
        
        [dict setObject: birth forKey:@"getBirth"];
        
        [peopleArray addObject:dict];
        
        if(abName) CFRelease(abName);
        
        if(abLastName) CFRelease(abLastName);
        
        if(abFullName) CFRelease(abFullName);
        
        if(people) CFRelease(people);
        
    }
    
    if(allLinkPeople) CFRelease(allLinkPeople);
    
    return peopleArray;
    
}
//查看是否有权限读取通讯录

+(void)CheckAddressBookIOS9BeforeAuthorization:(void (^)(bool isAuthorized))block

{
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    if (authStatus != kABAuthorizationStatusAuthorized)
        
    {
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                 
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!granted)
                    
                {
                    
                    block(NO);
                    
                }
                
                else
                    
                {
                    
                    block(YES);
                    
                }
                
            });
            
        });
        
    }
    
    else{
        
        block(YES);
        
    }
    
}

//ios 9 以后 使用block 返回 联系人数组

+(void)getIOS9AfterContactsSuccess:(void (^)(NSArray *))block

{
    
    NSMutableArray *contacts = [NSMutableArray array];
    
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        
        CNContactStore *store = [[CNContactStore alloc] init];
        
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if (granted) {
                
                CNContactStore * store = [[CNContactStore alloc] init];
                
                NSArray * keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
                
                CNContactFetchRequest * request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
                
                [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                    
                    NSString * givenName = contact.givenName;
                    
                    NSString * familyName = contact.familyName;
                    
                    NSString *nameString = [NSString stringWithFormat:@"%@ %@",familyName,givenName];
                    
                    NSMutableArray *tmpArr = [NSMutableArray array];
                    
                    NSArray * phoneArray = contact.phoneNumbers;
                    
                    for (CNLabeledValue * labelValue in phoneArray) {
                        
                        CNPhoneNumber * number = labelValue.value;
                        
                        [tmpArr addObject:number.stringValue];
                        
                    }
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    
                    [dict setObject:nameString  forKey:@"getName"];
                    
                    [dict setObject: [tmpArr firstObject] forKey:@"getNumber"];
                    
                    [contacts addObject:dict];
                    
                }];
                
            }
            
            block(contacts);
            
        }];
        
    }else{//没有权限
        
        block(contacts);
        
    }
    
}

//ios 9以后查看是否有权限读取通讯录

+ (void)checkAddressBookIOS9AfterAuthorization:(void (^)(bool isAuthorized))block

{
    
    CNContactStore *addressBook = [[CNContactStore alloc]init];
    
    CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];;
    
    if (authStatus != CNAuthorizationStatusAuthorized){
        
        [addressBook requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (error){
                    
                    NSLog(@"ios9以后Error: %@",error);
                    
                    if (error.code == 100) {//ios 9 以后第一次被用户拒绝访问之后就走 error 的方法
                        
                        block(NO);
                        
                    }
                    
                }else if (!granted){
                    
                    block(NO);
                    
                }else{
                    
                    block(YES);
                    
                }
                
            });
            
        }];
        
    }else{
        
        block(YES);
        
    }
    
}
@end
