//
//  PRSocialUserInfo.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 6/26/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PRSocialUserGender) {
    PRSocialUserGenderUnknown,
    PRSocialUserGenderMale,
    PRSocialUserGenderFemale,
    PRSocialUserGenderOther
};

@interface PRSocialUserInfo : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, strong) NSURL *avatarURL;
@property (nonatomic, assign) PRSocialUserGender gender;
@property (nonatomic, copy) NSString *intro;
@property (nonatomic, copy) NSString *location;

@end
