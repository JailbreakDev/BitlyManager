#define PLIST_PATH @"/var/mobile/Library/Preferences/com.sharedroutine.bitlymanager.plist"
#define PREFS [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH]

@interface BitlyPreferences : NSObject
+(NSString *)stringForKey:(NSString *)key;
+(NSString *)getAccessToken;
@end