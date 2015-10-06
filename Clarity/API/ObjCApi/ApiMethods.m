//
//  ApiMethods.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/15/14.
//
//

#import "ApiMethods.h"
#import "ApiMethod.h"

@implementation ApiMethods

+ (NSDictionary *)getMethods
{
    return @{
        //refactored
        //Auth
        @(AMLoginViaEmail)      :   [ApiMethod srv:AMSLogin method:HttpMethodGet url:@"/auth/login"],
        @(AMLogout)             :   [ApiMethod srv:AMSLogin method:HttpMethodGet url:@"/auth/logout"],
        @(AMRecoverPassword)    :   [ApiMethod srv:AMSLogin method:HttpMethodGet url:@"/auth/reset_password"],
        //Orders
        @(AMGetOrderStatuses)   :   [ApiMethod srv:AMSLogin method:HttpMethodGet url:@"/orders/statuses"],
        @(AMGetOrders)          :   [ApiMethod srv:AMSLogin method:HttpMethodGet url:@"/orders"],
        @(AMGetOrder)           :   [ApiMethod srv:AMSLogin method:HttpMethodGet url:@"/orders/:id"],
        @(AMUpdateOrder)        :   [ApiMethod srv:AMSLogin method:HttpMethodPut url:@"/orders/:id"],
        @(AMAcceptOrder)        :   [ApiMethod srv:AMSLogin method:HttpMethodPost url:@"/orders/:id/accept"],
        @(AMAcceptOrderWithConditions) : [ApiMethod srv:AMSLogin method:HttpMethodPost url:@"/orders/:id/accept_with_condition"],
        @(AMDeclineOrder)       :   [ApiMethod srv:AMSLogin method:HttpMethodPost url:@"/orders/:id/decline"],
        //Messages
        @(AMGetMessages)        :   [ApiMethod srv:AMSLogin method:HttpMethodGet url:@"/orders/:order_id/messages"],
        @(AMCreateMessage)      :   [ApiMethod srv:AMSLogin method:HttpMethodPost url:@"/orders/:order_id/messages"],
        @(AMUpdateMessage)      :   [ApiMethod srv:AMSLogin method:HttpMethodPut url:@"/orders/:order_id/messages/:message_id"],
        
        //not refactored
        @(AMForgotPassword)     :   [ApiMethod srv:AMSLogin method:HttpMethodPost url:@"/user/password/update"],
        
        @(AMCreateUser)         :   [ApiMethod srv:AMSLogin method:HttpMethodPost url:@"/user/create"],
        @(AMGetUser)            :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/user/get/:id"],
        @(AMFindUsers)          :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/user/get"],
        @(AMGetUsers)           :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/user/get"],
        @(AMUpdateUser)         :   [ApiMethod srv:AMSUser method:HttpMethodPost url:@"/user/update/:id"],
        @(AMGetLocations)       :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/location/get"],
        @(AMGetLocation)        :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/location/get/:id"],
        @(AMCreateLocation)     :   [ApiMethod srv:AMSUser method:HttpMethodPost url:@"/location/create"],
        @(AMGetRegions)         :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/region/get"],
        @(AMCreateSchedule)     :   [ApiMethod srv:AMSUser method:HttpMethodPost url:@"/schedule/create"],
        @(AMGetSchedule)        :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/schedule/get"],
        @(AMClearSchedule)      :   [ApiMethod srv:AMSUser method:HttpMethodPost url:@"/schedule/delete"],
        @(AMUpdateBlock)        :   [ApiMethod srv:AMSUser method:HttpMethodPost url:@"/schedule/block/update/:id"],
        @(AMRemoveBlock)        :   [ApiMethod srv:AMSUser method:HttpMethodPost url:@"/schedule/block/delete/:id"],
        
        @(AMCreateSession)      :   [ApiMethod srv:AMSUser method:HttpMethodPost url:@"/session/create"],
        @(AMGetSession)         :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/session/get/:id"],
        @(AMGetSessions)        :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/session/get"],
        @(AMUpdateSession)      :   [ApiMethod srv:AMSUser method:HttpMethodPost url:@"/session/update/:id"],
        
        @(AMGetStaticPage)      :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/static/get/:page"],
        @(AMGetBraintreeToken)  :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/payment/get/token"],
        @(AMGetHomeScreenInfo)  :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/user/homescreen"],
        
        @(AMGetChats)           :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/chat/get"],
        @(AMGetChat)            :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/chat/get/:id"],
        @(AMGetChatMessages)    :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/chat/message/get"],
        @(AMSendChatMessage)    :   [ApiMethod srv:AMSUser method:HttpMethodPost url:@"/chat/message/create"],
        
        @(AMCreatePromo)        :   [ApiMethod srv:AMSUser method:HttpMethodPost url:@"/session/promo/create"],
        @(AMGetPromo)           :   [ApiMethod srv:AMSUser method:HttpMethodGet url:@"/session/promo/get"]

    };
}

@end
