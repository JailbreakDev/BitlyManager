#import "UIProgressHUD.h"
#import "UIViewController+Additions.h"

@class BitlyConnection;

@protocol BitlyConnectionDelegate <NSObject>
@optional
- (void)connection:(BitlyConnection *)connection didReceiveAccessToken:(NSString *)accessToken;
- (void)connection:(BitlyConnection *)connection didFailWithMessage:(NSString *)message;
- (void)connection:(BitlyConnection *)connection didShortURLWithReturningInfo:(NSDictionary *)info;
- (void)connection:(BitlyConnection *)connection didLoadHistoryWithItems:(NSArray *)items;
@end

@interface BitlyConnection : NSObject {

	UIProgressHUD *HUD;
}

-(void)shortURL:(NSString *)url withAccessToken:(NSString *)accessToken;
-(void)requestAccessTokenForUsername:(NSString *)userName andPassword:(NSString *)password;
-(void)requstLinkHistoryForAccessToken:(NSString *)accessToken;
@property (assign) id<BitlyConnectionDelegate> delegate;
@end