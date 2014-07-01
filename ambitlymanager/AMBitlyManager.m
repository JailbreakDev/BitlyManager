#import "AMBitlyManager.h"

@implementation AMBitlyManager

-(void)showHUDWithMessage:(NSString *)message {

	UIProgressHUD *hud = [[UIProgressHUD alloc] initWithFrame:CGRectZero];
	[hud setText:message];
	[hud showInView:[UIViewController topMostController].view];
	[hud performSelector:@selector(hide) withObject:nil afterDelay:1.5];
}

-(id)init {

	self = [super init];

	if (self) {
		connection = [[BitlyConnection alloc] init];
		[connection setDelegate:self];
		link = [[NSString alloc] init];
	}

	return self;
}

-(void)shortenURL:(NSString *)url; {
	NSString *accessToken = [BitlyPreferences getAccessToken];
	[connection shortURL:url withAccessToken:accessToken];
}

#pragma mark - BitlyConnectionDelegate

- (void)connection:(BitlyConnection *)con didShortURLWithReturningInfo:(NSDictionary *)info {
	link = info[@"aggregate_link"];
	[self showHUDWithMessage:[NSString stringWithFormat:@"Your Link has been shortened: %@",link]];
	[[UIPasteboard generalPasteboard] setString:link];
}

- (void)connection:(BitlyConnection *)connection didFailWithMessage:(NSString *)message {
	[self showHUDWithMessage:message];
}

@end

@implementation UIResponder (AMBitlyManager)

+ (void)load {
    
	//id <AMMenuItem> menuItem = 
	[[UIMenuController sharedMenuController] registerAction:@selector(shortenURL) title:@"Bit.ly" canPerform:@selector(canExecute)];
    //menuItem.image = [UIImage imageWithContentsOfFile:([UIScreen mainScreen].scale == 2.0f) ? @"/Library/ActionMenu/Plugins/AMBitlyManager@2x.png" : @"/Library/ActionMenu/Plugins/AMBitlyManager.png"];
}

- (BOOL)canExecute {
    BOOL selected = [[self selectedTextualRepresentation] length] > 0;
    BOOL loggedIn = [BitlyPreferences getAccessToken].length > 0;
	return selected && loggedIn;
}

- (void)shortenURL {
    
    AMBitlyManager *bitlyManager = [[AMBitlyManager alloc] init];
    NSString *selection = [self selectedTextualRepresentation];
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSTextCheckingResult *match = [detect firstMatchInString:selection options:0 range:NSMakeRange(0, [selection length])];
    
    if (!match) {
        return;
    }
    	
    [bitlyManager shortenURL:match.URL.absoluteString];
}

@end