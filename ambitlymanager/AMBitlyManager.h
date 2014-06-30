#import "../ActionMenu/ActionMenu.h"
#import "../UIViewController+Additions.h"
#import "../BitlyConnection.h"

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.sharedroutine.bitlymanager.plist"

@interface AMBitlyManager : NSObject <BitlyConnectionDelegate,UIAlertViewDelegate> {
	NSDictionary *_preferences;
	BitlyConnection *connection;
	BOOL multipleURLS;
	NSMutableArray *shortLinks;
	int count, arrayCount;
	NSString *link;
}
-(void)shortenURLs:(NSArray *)urls;
@end

@interface UIResponder (AMBitlyManager)
- (BOOL)canExecute;
- (void)shortenURL;
@end