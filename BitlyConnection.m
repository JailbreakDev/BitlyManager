#import "BitlyConnection.h"

@interface BitlyConnection()
@end

@implementation BitlyConnection

-(void)showHUDWithMessage:(NSString *)message {

	if (!HUD) {
		HUD = [[UIProgressHUD alloc] initWithFrame:CGRectZero];
	}

	[HUD setText:message];
	[HUD showInView:[UIViewController topMostController].view];
}

-(void)shortURL:(NSString *)url withAccessToken:(NSString *)accessToken {

    [self showHUDWithMessage:@"Shortening..."];

    if (url.length <= 0 || accessToken.length <= 0) {
    	[HUD hide];
    	[[self delegate] connection:self didFailWithMessage:@"URL or AccessToken can not be empty"];
    	return;
    }

    NSString *requestURL = [NSString stringWithFormat:@"https://api-ssl.bitly.com/v3/user/link_save?access_token=%@&longUrl=%@",accessToken,url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60];
    [request setHTTPMethod:@"GET"];

    id <BitlyConnectionDelegate> blockDelegate = self.delegate;
    BitlyConnection *blockSelf = self;

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

    	[HUD hide];
		if (error) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"The Connection failed due to an error. Please try again later."];
    		return;
    	}

    	if (((NSHTTPURLResponse *)response).statusCode != 200 && ((NSHTTPURLResponse *)response).statusCode != 304) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"Invalid Response from Server."];
    		return;
    	}

		NSDictionary *jsonDict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			
		if (!jsonDict) {
			[blockDelegate connection:blockSelf didFailWithMessage:@"Received Data is invalid"];
           	return;
		}

        NSDictionary *info = ((NSDictionary *)jsonDict[@"data"]).allValues[0];
        if (!info) {
        	[blockDelegate connection:blockSelf didFailWithMessage:@"Received Data is invalid"];
            return;    		
        }

        [blockDelegate connection:blockSelf didShortURLWithReturningInfo:info];
           
    }];
}

-(void)requestAccessTokenForUsername:(NSString *)userName andPassword:(NSString *)password {

    [self showHUDWithMessage:@"Requesting Access Token..."];

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api-ssl.bitly.com/oauth/access_token"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60];
	NSString *authStr = [NSString stringWithFormat:@"%@:%@",userName,password];
	NSData *dataStr = [authStr dataUsingEncoding:NSUTF8StringEncoding];
	NSString *base64Str = [dataStr base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn | NSDataBase64EncodingEndLineWithLineFeed | NSDataBase64Encoding76CharacterLineLength];
	[request setValue:[NSString stringWithFormat:@"Basic %@",base64Str] forHTTPHeaderField:@"Authorization"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];

     id <BitlyConnectionDelegate> blockDelegate = [self delegate];
     BitlyConnection *blockSelf = self;

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

		if (error) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"The Connection failed due to an error. Please try again later."];
    		[HUD hide];
    		return;
    	}

    	if (((NSHTTPURLResponse *)response).statusCode != 200) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"Invalid Response from Server."];
    		[HUD hide];
    		return;
    	}

    	NSString *acToken = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    	
    	NSRange invalidLoginRange = [acToken rangeOfString:@"INVALID_LOGIN"];

    	if (invalidLoginRange.location != NSNotFound) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"Invalid Login. Please check your login details"];
    		[HUD hide];
    		return;
    	}

    	[HUD done];
    	[HUD performSelector:@selector(hide) withObject:nil afterDelay:0.5];
    	[blockDelegate connection:blockSelf didReceiveAccessToken:acToken];
    		
    }];
}

-(void)requstLinkHistoryForAccessToken:(NSString *)accessToken {

    [self showHUDWithMessage:@"Requesting User History..."];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api-ssl.bitly.com/v3/user/link_history?access_token=%@",accessToken]] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60];
    [request setHTTPMethod:@"GET"];

     id <BitlyConnectionDelegate> blockDelegate = [self delegate];
     BitlyConnection *blockSelf = self;

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

    	if (error) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"The Connection failed due to an error. Please try again later."];
    		[HUD hide];
    		return;
    	}

    	if (((NSHTTPURLResponse *)response).statusCode != 200) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"Invalid Response from Server."];
    		[HUD hide];
    		return;
    	}

    	NSError *jsonError = nil;
     	NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    
    	if (jsonError) {
        	[blockDelegate connection:blockSelf didFailWithMessage:@"Invalid Data returned"];
        	return;
    	}

    	[HUD done];
    	[HUD performSelector:@selector(hide) withObject:nil afterDelay:0.5];
    	[blockDelegate connection:blockSelf didLoadHistoryWithItems:(NSArray *)jsonDict[@"data"][@"link_history"]];
    }];
}

@end