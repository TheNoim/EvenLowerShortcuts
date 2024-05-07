//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#ifndef ELS_Bridging_Header_h
#define ELS_Bridging_Header_h

#import <Foundation/Foundation.h>

int _CGSDefaultConnection();
id CGSCopyManagedDisplaySpaces(int conn);
id CGSCopyActiveMenuBarDisplayIdentifier(int conn);

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

#endif
