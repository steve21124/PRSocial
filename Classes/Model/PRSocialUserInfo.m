//
//  PRSocialUserInfo.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 6/26/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRSocialUserInfo.h"

@implementation PRSocialUserInfo

- (NSString *)description
{
    NSString *genderString;
    switch (self.gender) {
        case PRSocialUserGenderUnknown:
            genderString = @"Unknown";
            break;
        case PRSocialUserGenderMale:
            genderString = @"Male";
            break;
        case PRSocialUserGenderFemale:
            genderString = @"Female";
            break;
        case PRSocialUserGenderOther:
            genderString = @"Other";
            break;
    }
    NSString *description = [NSString stringWithFormat:@"<%@: %p> UserID: %@; UserName: %@; Nickname: %@; AvatarURL: %@; Gender: %@; Intro: %@; Location: %@", NSStringFromClass(self.class), self, self.userID, self.userName, self.nickname, self.avatarURL, genderString, self.intro, self.location];
    return description;
}

@end
