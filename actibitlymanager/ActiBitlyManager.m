#import <libactivator/libactivator.h> 
#import <UIKit/UIKit.h>
#import "../BitlyConnection.h"
#import "../UIViewController+Additions.h"
#import "../BitlyPreferences.h"

@class BitlyConnection;

@interface ActiBitlyManager : NSObject <LAListener, UIAlertViewDelegate, BitlyConnectionDelegate> {

@private
BitlyConnection *connection;

}
@end

@implementation ActiBitlyManager

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
		[event setHandled:YES];
}


- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {

	NSString *pbText = [[UIPasteboard generalPasteboard] string];

	if (!pbText) return;

	NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
   	NSTextCheckingResult *match = [detect firstMatchInString:pbText options:0 range:NSMakeRange(0, [pbText length])];
    
    if (!match) {
    	[self performSelector:@selector(dismiss) withObject:nil afterDelay:1];
        return;
    }

    connection = [[BitlyConnection alloc] init];
    [connection setDelegate:self];
	[connection shortURL:match.URL.absoluteString withAccessToken:[BitlyPreferences getAccessToken]];
	NSLog(@"AC Token: %@",[BitlyPreferences getAccessToken]);
	[event setHandled:YES];
}

- (void)connection:(BitlyConnection *)connection didShortURLWithReturningInfo:(NSDictionary *)info {

	NSString *link = info[@"aggregate_link"];
	[self performSelector:@selector(dismiss) withObject:nil afterDelay:1];
	NSLog(@"Shortened: %@",link);
	if (link) {
		[[UIPasteboard generalPasteboard] setString:link];
	}	
	
}

- (void)dealloc {
    [connection release];
	[super dealloc];
}

+ (void)load { 

	@autoreleasepool { 
		[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.sharedroutine.actibitlymanager"];
	}
}

@end