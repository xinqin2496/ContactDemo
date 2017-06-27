//
//  ViewController.m
//  ContactDemo
//
//  Created by 郑文青 on 2017/6/27.
//  Copyright © 2017年 zhengwenqing’s mac. All rights reserved.
//

#import "ViewController.h"
#import "Factory.h"

//ios 9 以前的 通讯录框架
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/ABPersonViewController.h>
//ios 9 以后的 通讯录框架
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

//这样可以根据 ios9 来判断使用哪一种系统框架
#define IOS_VERSION_9_OR_AFTER (([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)? (YES):(NO))

@interface ViewController ()//第一个是 ios9以前的,第二个 ios9以后的
<ABPeoplePickerNavigationControllerDelegate,CNContactPickerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;

@end

@implementation ViewController
//点击从通讯录添加
- (IBAction)addContactsFromSystemBooks:(UIButton *)sender
{
    if (IOS_VERSION_9_OR_AFTER) {//ios 9 之后
        NSLog(@"ios9以后");
        [Factory checkAddressBookIOS9AfterAuthorization:^(bool isAuthorized) {
            
            if (isAuthorized) {
                //调用系统的通讯录界面
                CNContactPickerViewController *contact = [[CNContactPickerViewController alloc]init];
                
                contact.delegate = self;
                
                [self presentViewController:contact animated:YES completion:nil];
                
            }else{
                
                [self alertControllerToSetup];//这里弹出提示让用户选择跳转到本程序的设置，打开通讯录
                
                
            }
            
        }];
        
    }else {
        NSLog(@"ios9之前");
        [Factory CheckAddressBookIOS9BeforeAuthorization:^(bool isAuthorized) {
            
            if (isAuthorized) {
                
                ABPeoplePickerNavigationController *nav = [[ABPeoplePickerNavigationController alloc] init];
                
                nav.peoplePickerDelegate = self;
                
                [self presentViewController:nav animated:YES completion:nil];
                
            }else{
                
                [self alertControllerToSetup];
                
            }
            
        }];
        
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    /**
     
     首先在info.plist里面添加读取通讯录的权限
     
     通讯录权限： Privacy - Contacts Usage Description 是否允许此App访问你的通讯录？
     
     然后导入框架
     
     **/
    if (IOS_VERSION_9_OR_AFTER) {//ios 9 之后
        
        [Factory checkAddressBookIOS9AfterAuthorization:^(bool isAuthorized) {
            
            if (isAuthorized) {
                
                
                [Factory getIOS9AfterContactsSuccess:^(NSArray *contacts) {
                    
                    NSLog(@"ios9以后----%@\n",contacts);
                    
                }];
                
            }else{
                
                [self alertControllerToSetup];
                
            }
            
        }];
        
    }else {
        
        [Factory CheckAddressBookIOS9BeforeAuthorization:^(bool isAuthorized) {
            
            if (isAuthorized) {
                
                
                NSArray *ios9before = [Factory getIOS9BeforeAddressBooks];
                
                NSLog(@"ios9before---%@\n",ios9before);
                
            }else{
                
                [self alertControllerToSetup];
                
            }
            
        }];
        
    }
   
}

-(void)alertControllerToSetup
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您没有开启访问通讯录的权限,是否前往设置打开本程序的通讯录权限" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *goAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:goAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//实现代理方法

#pragma mark ABPeoplePickerNavigationControllerDelegate

//取消选择

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person

{
     //这里有许多属性值可以带过来,参考 factory类里面的数组处理
    CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    CFStringRef abFullName = ABRecordCopyCompositeName(person);
    
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
    
    ABMultiValueRef phones= ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    for (NSInteger j = 0; j < ABMultiValueGetCount(phones); j++) {
        
        [phoneArr addObject:(__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j))];
        
    }
    
    if(nameString.length != 0){
        
        self.nameTF.text =  nameString ;
        
    }
    
    if (phoneArr.count != 0) {
        
        NSString *firstPhone = [phoneArr firstObject];
        
        if ([firstPhone rangeOfString:@"-"].location != NSNotFound) {
            
            firstPhone  = [firstPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
        }
        
        self.phoneTF.text = firstPhone;
        
    }
    
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark  CNContactPickerDelegate

//取消

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker

{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

//选中与取消选中时调用的方法

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    
    //这里有许多属性值可以带过来,参考 factory类里面的数组处理
    NSString * givenName = contact.givenName;
    
    NSString * familyName = contact.familyName;
    
    NSString *nameString = [NSString stringWithFormat:@"%@ %@",familyName,givenName];
    
    NSMutableArray *phoneArray = [NSMutableArray array];
    
    NSArray * tmpArr = contact.phoneNumbers;
    
    for (CNLabeledValue * labelValue in tmpArr) {
        
        CNPhoneNumber * number = labelValue.value;
        
        [phoneArray addObject:number.stringValue];
        
    }
    
    self.nameTF.text = nameString;
    
    if (phoneArray.count != 0) {
        
        NSString *firstPhone = [phoneArray firstObject];
        
        if ([firstPhone rangeOfString:@"-"].location != NSNotFound) {
            
            firstPhone  = [firstPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
        }
        
        self.phoneTF.text = firstPhone;
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
@end
