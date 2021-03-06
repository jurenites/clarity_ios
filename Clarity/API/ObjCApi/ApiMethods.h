//
//  ApiMethods.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/15/14.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ApiMethodID) {
    
    AMLoginViaEmail = 1, AMLogout, AMRecoverPassword,
    
    //orders
    AMGetOrders, AMGetOrder, AMUpdateOrder, AMAcceptOrder, AMAcceptOrderWithConditions, AMDeclineOrder,
    
    //Messages
    AMGetMessages, AMCreateMessage, AMUpdateMessage,
    
    
    //not refactored
    AMForgotPassword,
    //User
    AMCreateUser, AMGetUser, AMGetUsers, AMUpdateUser, AMFindUsers,
    
    //Locations
    AMGetLocations, AMGetLocation, AMGetRegions, AMCreateLocation,
    
    //Schedule
    AMCreateSchedule, AMGetSchedule, AMClearSchedule, AMUpdateBlock, AMRemoveBlock,
    
    //Static
    AMGetStaticPage,
    
    //Session
    AMCreateSession, AMGetSession, AMGetSessions, AMUpdateSession,
    
    //Payments
    AMGetBraintreeToken,
    
    //HomeScreen
    AMGetHomeScreenInfo,
    
    //Chats
    AMGetChats, AMGetChat, AMGetChatMessages, AMSendChatMessage,
    
    //Promo
    AMCreatePromo, AMGetPromo

};

@interface ApiMethods : NSObject

+ (NSDictionary *)getMethods;

@end
