#import "BitlyPreferences.h"

@interface BitlyPreferences ()

@end

@implementation BitlyPreferences

+(NSString *)stringForKey:(NSString *)key {

	return (NSString *)[PREFS objectForKey:key];
}

+(NSString *)getAccessToken {

	return (NSString *)[PREFS objectForKey:@"kBitlyAccessToken"];
}

@end