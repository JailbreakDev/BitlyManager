#import <Preferences/Preferences.h>
#import <objc/runtime.h>
#import "BitlyConnection.h"

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.sharedroutine.bitlymanager.plist"

@class BitlyConnection;

@interface PSBitlyUserHistoryViewController : PSViewController <BitlyConnectionDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate> {
	
	UITableView *_tableView;
	NSMutableDictionary *information;
	BitlyConnection *connection;
	NSDictionary *_preferences;
}

- (id)initForContentSize:(CGSize)size;
- (UIView *)view;
- (CGSize)contentSize;
- (id)navigationTitle;

@end