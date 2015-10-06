//
//  NibLoader.m
//  Brabble-iOSClient
//
//  Created by Alexey on 2/9/14.
//
//

#import "NibLoader.h"

static NSMutableDictionary * NibsCache = nil;

id loadViewFromNibWithOwner(NSString *nibName, id owner)
{
    if (!NibsCache) {
        NibsCache = [NSMutableDictionary dictionary];
    }
    
    UINib *nib = NibsCache[nibName];
    
    if (!nib) {
        nib = [UINib nibWithNibName:nibName bundle:nil];
        if (!nib) {
            return nil;
        }
        
        NibsCache[nibName] = nib;
    }
    
    return [nib instantiateWithOwner:owner options:nil].firstObject;
}

id loadViewFromNib(NSString *nibName)
{
    UIView *view = loadViewFromNibWithOwner(nibName, nil);
    
    if (![view isKindOfClass:[UIView class]]) {
        return nil;
    }
    
    return view;
}
