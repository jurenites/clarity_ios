//
//  EventsTracker.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 10/23/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const ETCatWhatsNew = @"what_new";
static NSString * const ETCatSocial = @"social";
static NSString * const ETCatQA = @"q_a";
static NSString * const ETCatProfile = @"profile";

static NSString * const ETActionFacebook = @"facebook";
static NSString * const ETActionInstagram = @"instagram";
static NSString * const ETActionGPlus = @"g_plus";
static NSString * const ETActionTwitter = @"twitter";
static NSString * const ETActionMail = @"mail";
static NSString * const ETActionCopy = @"copy";
static NSString * const ETActionDownload = @"download";

static NSString * const ETActionAddQuestion = @"add_question";
static NSString * const ETActionAddAnswer = @"add_answer";
static NSString * const ETActionUpVote = @"up_vote";
static NSString * const ETActionDownVote = @"down_vote";

static NSString * const ETActionCall = @"call";
static NSString * const ETActionSMS = @"sms";

@interface EventsTracker : NSObject

+ (void)trackAction:(NSString *)actionName cat:(NSString *)cat;

@end
