#import "AMBitlyManager.h"

@implementation AMBitlyManager

-(id)init {

	self = [super init];

	if (self) {
		_preferences = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] ?: [[NSDictionary alloc] init];
		connection = [[BitlyConnection alloc] init];
		[connection setDelegate:self];
		multipleURLS = FALSE;
		shortLinks = [[NSMutableArray alloc] init];
		link = [[NSString alloc] init];
		count = 0;
		arrayCount = 0;
	}

	return self;
}

-(void)shortenURLs:(NSArray *)urls {

	multipleURLS = (urls.count > 1);
	[shortLinks removeAllObjects];
	arrayCount = urls.count;
	NSString *accessToken = _preferences[@"kBitlyAccessToken"];
	for (NSTextCheckingResult *result in urls) {
		[connection shortURL:result.URL.absoluteString withAccessToken:accessToken];
	}
}

#pragma mark - BitlyConnectionDelegate

- (void)connection:(BitlyConnection *)connection didShortURLWithReturningInfo:(NSDictionary *)info {

	if (arrayCount == count) {
		link = [shortLinks componentsJoinedByString:@"\n"];
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Shortened" message:[NSString stringWithFormat:@"Your Links (%d) have been shortened: %@",count,link] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Copy",nil];
		[av show];
	} else {
		[shortLinks addObject:info[@"aggregate_link"]];
	}
	count++;
}

- (void)connection:(BitlyConnection *)connection didFailWithMessage:(NSString *)message {
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[av show];
	//[av release];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	if (alertView.cancelButtonIndex == buttonIndex) {
		return;
	}

	NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];

	if ([buttonTitle isEqualToString:@"Copy"]) {

		[[UIPasteboard generalPasteboard] setString:link];

	} 
}

/*
-(void)dealloc {

	[shortLinks release];
	shortLinks = nil;
	[connection release];
	connection = nil;
	[_preferences release];
	_preferences = nil;
	[link release];
	link = nil;
	[super dealloc];
}
*/

@end

@implementation UIResponder (AMBitlyManager)

+ (void)load {
    
	//id <AMMenuItem> menuItem = 
	[[UIMenuController sharedMenuController] registerAction:@selector(shortenURL) title:@"Bit.ly" canPerform:@selector(canExecute)];
    //menuItem.image = [UIImage imageWithContentsOfFile:([UIScreen mainScreen].scale == 2.0f) ? @"/Library/ActionMenu/Plugins/AMBitlyManager@2x.png" : @"/Library/ActionMenu/Plugins/AMBitlyManager.png"];
}

- (BOOL)canExecute {
    
	return [[self selectedTextualRepresentation] length] > 0;
}

- (void)shortenURL {
    
    AMBitlyManager *bitlyManager = [[AMBitlyManager alloc] init];
    NSString *selection = [self selectedTextualRepresentation];
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];

    NSArray *matches = [detect matchesInString:selection options:0 range:NSMakeRange(0, [selection length])];
    
    if (matches.count == 0) {
        return;
    }
    	
    [bitlyManager shortenURLs:matches];
    [bitlyManager release];
    [detect release];
}

@end