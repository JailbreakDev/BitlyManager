#import "BitlyConnection.h"

@interface BitlyConnection()
@end

@implementation BitlyConnection

-(void)shortURL:(NSString *)url withAccessToken:(NSString *)accessToken {

	HUD = [[UIProgressHUD alloc] initWithFrame:CGRectZero];
    [HUD setText:@"Shortening..."];
    [HUD showInView:[UIViewController topMostController].view];

    if (url.length <= 0 || accessToken.length <= 0) {
    	[HUD hide];
    	[HUD release];
    	[[self delegate] connection:self didFailWithMessage:@"URL or AccessToken can not be empty"];
    	return;
    }

    NSString *requestURL = [NSString stringWithFormat:@"https://api-ssl.bitly.com/v3/user/link_save?access_token=%@&longUrl=%@",accessToken,url];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60] autorelease];
    [request setHTTPMethod:@"GET"];
    
    __block id <BitlyConnectionDelegate> blockDelegate = [self delegate];
    __block BitlyConnection *blockSelf = self;

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

			if (error) {
    			[blockDelegate connection:blockSelf didFailWithMessage:@"The Connection failed due to an error. Please try again later."];
    			[HUD hide];
    			[HUD release];
    			return;
    		}

    		if (((NSHTTPURLResponse *)response).statusCode != 200 && ((NSHTTPURLResponse *)response).statusCode != 304) {
    			[blockDelegate connection:blockSelf didFailWithMessage:@"Invalid Response from Server."];
    			[HUD hide];
    			[HUD release];
    			return;
    		}

			NSDictionary *jsonDict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			
			if (!jsonDict) {
				[blockDelegate connection:blockSelf didFailWithMessage:@"Received Data is invalid"];
    			[HUD hide];
    			[HUD release];
           		return;
			}
        
        	NSDictionary *info = ((NSDictionary *)jsonDict[@"data"]).allValues[0] ?: NULL;

        	if (!info) {
        		[blockDelegate connection:blockSelf didFailWithMessage:@"Received Data is invalid"];
    			[HUD hide];
    			[HUD release];
            	return;    		
        	}

            [HUD done];
    		[HUD performSelector:@selector(hide) withObject:nil afterDelay:0.5];
    		[HUD release];
    		//[blockDelegate connection:blockSelf didShortURLWithReturningInfo:info];
    }];
}

-(void)requestAccessTokenForUsername:(NSString *)userName andPassword:(NSString *)password {

	HUD = [[UIProgressHUD alloc] initWithFrame:CGRectZero];
    [HUD setText:@"Requesting Access Token..."];
    [HUD showInView:[UIViewController topMostController].view];

	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://api-ssl.bitly.com/oauth/access_token"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60] autorelease];
	NSString *authStr = [NSString stringWithFormat:@"%@:%@",userName,password];
	NSData *dataStr = [authStr dataUsingEncoding:NSUTF8StringEncoding];
	NSString *base64Str = [dataStr base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn | NSDataBase64EncodingEndLineWithLineFeed | NSDataBase64Encoding76CharacterLineLength];
	[request setValue:[NSString stringWithFormat:@"Basic %@",base64Str] forHTTPHeaderField:@"Authorization"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];

    __block id <BitlyConnectionDelegate> blockDelegate = [self delegate];
    __block BitlyConnection *blockSelf = self;

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

		if (error) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"The Connection failed due to an error. Please try again later."];
    		[HUD hide];
    		[HUD release];
    		return;
    	}

    	if (((NSHTTPURLResponse *)response).statusCode != 200) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"Invalid Response from Server."];
    		[HUD hide];
    		[HUD release];
    		return;
    	}

    	NSString *acToken = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    	
    	NSRange invalidLoginRange = [acToken rangeOfString:@"INVALID_LOGIN"];

    	if (invalidLoginRange.location != NSNotFound) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"Invalid Login. Please check your login details"];
    		[HUD hide];
    		[HUD release];
    		return;
    	}

    	[HUD done];
    	[HUD performSelector:@selector(hide) withObject:nil afterDelay:0.5];
    	[HUD release];
    	[blockDelegate connection:blockSelf didReceiveAccessToken:acToken];
    		
    }];
}

-(void)requstLinkHistoryForAccessToken:(NSString *)accessToken {

	HUD = [[UIProgressHUD alloc] initWithFrame:CGRectZero];
    [HUD setText:@"Requesting User History..."];
    [HUD showInView:[UIViewController topMostController].view];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api-ssl.bitly.com/v3/user/link_history?access_token=%@",accessToken]] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60];
    [request setHTTPMethod:@"GET"];

    __block id <BitlyConnectionDelegate> blockDelegate = [self delegate];
    __block BitlyConnection *blockSelf = self;

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

    	if (error) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"The Connection failed due to an error. Please try again later."];
    		[HUD hide];
    		[HUD release];
    		return;
    	}

    	if (((NSHTTPURLResponse *)response).statusCode != 200) {
    		[blockDelegate connection:blockSelf didFailWithMessage:@"Invalid Response from Server."];
    		[HUD hide];
    		[HUD release];
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
    	[HUD release];
    	[blockDelegate connection:blockSelf didLoadHistoryWithItems:(NSArray *)jsonDict[@"data"][@"link_history"]];
    }];
}

-(void)dealloc {

	[HUD release];
	HUD = nil;
	[super dealloc];
}

@end