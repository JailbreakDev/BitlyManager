#import "../ActionMenu/ActionMenu.h"
#import "../UIViewController+Additions.h"
#import "../BitlyConnection.h"
#import "../UIProgressHUD.h"
#import "../BitlyPreferences.h"

@interface AMBitlyManager : NSObject <BitlyConnectionDelegate> {
	BitlyConnection *connection;
	NSString *link;
}
-(void)shortenURL:(NSString *)url;
@end

@interface UIResponder (AMBitlyManager)
- (BOOL)bitlyManager_canExecute;
- (void)bitlyManager_shortenURL;
@end