#import "../ActionMenu/ActionMenu.h"
#import "../UIViewController+Additions.h"
#import "../BitlyConnection.h"

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.sharedroutine.bitlymanager.plist"

@interface AMBitlyManager : NSObject <BitlyConnectionDelegate,UIAlertViewDelegate> {
	NSDictionary *_preferences;
	BitlyConnection *connection;
}
-(void)shortenURL:(NSString *)url;
@end

@interface UIResponder (AMBitlyManager)
- (BOOL)canExecute;
- (void)shortenURL;
@end