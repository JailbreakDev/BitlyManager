#import "AMBitlyManager.h"

@implementation AMBitlyManager

-(id)init {

	self = [super init];

	if (self) {
		 NSLog(@"Init");
		_preferences = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] ?: [NSDictionary dictionary];
		connection = [[BitlyConnection alloc] init];
	}

	return self;
}

-(void)shortenURL:(NSString *)url {
	NSLog(@"SHort url: %@",url);
    [connection setDelegate:self];
    [connection shortURL:url withAccessToken:_preferences[@"kBitlyAccessToken"]];
    NSLog(@"Short with ACToken: %@",_preferences[@"kBitlyAccessToken"]);
}

- (void)connection:(BitlyConnection *)connection didShortURLWithReturningInfo:(NSDictionary *)info {
	 NSLog(@"return info: %@",info);
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Shortened" message:[NSString stringWithFormat:@"Your Link has been shortened: %@",info] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:@"Copy",@"Open",nil];
	[av show];
	[av release];
}

- (void)connection:(BitlyConnection *)connection didFailWithMessage:(NSString *)message {
	 NSLog(@"Failed");
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[av show];
	[av release];
}

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
    
    NSString *selection = [self selectedTextualRepresentation];
    
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    
    NSTextCheckingResult *result = [detect firstMatchInString:selection options:0 range:NSMakeRange(0, [selection length])];
    
    if (result.range.location == NSNotFound) {
        return;
    }
    NSLog(@"Start shortening");
    AMBitlyManager *bitlyManager = [[AMBitlyManager alloc] init];
    [bitlyManager shortenURL:result.URL.absoluteString];
    [bitlyManager release];
    [detect release];
}

@end