#import <Preferences/Preferences.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSEditableTableCell.h>
#import <substrate.h>
#import "SSKeychain.h"
#import "BitlyConnection.h"

@interface BitlyManagerListController: PSListController <BitlyConnectionDelegate> {
	BitlyConnection *connection;
}
@end

@implementation BitlyManagerListController

- (void)viewWillAppear:(BOOL)arg1 {

	connection = [[BitlyConnection alloc] init];
	[connection setDelegate:self];
}

- (id)specifiers {
    
	if(_specifiers == nil) {
	
	NSMutableArray *specs = [[[self loadSpecifiersFromPlistName:@"BitlyManager" target:self] retain] mutableCopy];
	
	BOOL isLoggedIn = FALSE;
	
	for (PSSpecifier *spec in specs) {
	    if ([spec.identifier isEqualToString:@"bitly_access_token"]) {
            if (((NSString *)[self readPreferenceValue:spec]).length > 0)
                isLoggedIn = TRUE; //access token available so it is logged in
	    }
	}
	
	for (PSSpecifier *spec in specs) {
	 
        if (!isLoggedIn) break;
		
            if ([spec.identifier isEqualToString:@"bitlyusername"] || [spec.identifier isEqualToString:@"bitlypassword"])
                [spec setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
		
            if ([spec.identifier isEqualToString:@"bitlyLoginButton"]) {
                spec.name = @"Logout";
                MSHookIvar<SEL>((PSSpecifier *)spec,"action") = @selector(logout);
            }
		
            if ([spec.identifier isEqualToString:@"bitlyuserhistory"])
                    [spec setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];

            if ([spec.identifier isEqualToString:@"bitlyurltextfield"])
                    [spec setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
		    
            if ([spec.identifier isEqualToString:@"bitlyshortbutton"])
                    [spec setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
        
            if ([spec.identifier isEqualToString:@"bitlyshorturltextfield"])
                [spec setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
	    
	}
	
        _specifiers = [specs copy];
	
	}
    
	return _specifiers;
}

-(void)setPassword:(NSString *)password forSpecifier:(PSSpecifier *)spec {

	NSError *pwError = nil;
	[SSKeychain setPassword:password forService:@"com.sharedroutine.bitlymanager" account:@"SRBitlyManager" error:&pwError];

	if (pwError) {

		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Saving Password" message:[NSString stringWithFormat:@"Error = %@\nPlease show this to the developer",pwError.description] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[av show];
		[av release];
	}
}

-(NSString *)getPasswordForSpecifier:(PSSpecifier *)spec {

	return [SSKeychain passwordForService:@"com.sharedroutine.bitlymanager" account:@"SRBitlyManager"];
}

-(void)loginToBitly {

	if (!connection) {
		connection = [[BitlyConnection alloc] init];
	}

	[connection requestAccessTokenForUsername:(NSString *)[self readPreferenceValue:[self specifierForID:@"bitlyusername"]]
													andPassword:(NSString *)[self getPasswordForSpecifier:[self specifierForID:@"bitlypassword"]]];
        
}

- (void)logout {

	NSError *pwError = nil;
	[SSKeychain deletePasswordForService:@"com.sharedroutine.bitlymanager" account:@"SRBitlyManager" error:&pwError];

	if (pwError) {

		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Loggin Out" message:[NSString stringWithFormat:@"Error = %@\nPlease show this to the developer",pwError.description] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[av show];
		[av release];
		return;
	}
	[self setPreferenceValue:@"" specifier:[self specifierForID:@"bitly_access_token"]];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[((PSSpecifier *)[self specifierForID:@"bitlyusername"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
    [((PSSpecifier *)[self specifierForID:@"bitlypassword"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
    [((PSSpecifier *)[self specifierForID:@"bitlyuserhistory"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
    [((PSSpecifier *)[self specifierForID:@"urlfieldtext"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
    [((PSSpecifier *)[self specifierForID:@"bitlyshortbutton"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
    [((PSSpecifier *)[self specifierForID:@"bitlyshorturltextfield"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
    [((PSSpecifier *)[self specifierForID:@"bitlyurltextfield"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
    ((PSSpecifier *)[self specifierForID:@"bitlyLoginButton"]).name = @"Login";
    
    MSHookIvar<SEL>((PSSpecifier *)[self specifierForID:@"bitlyLoginButton"],"action") = @selector(loginToBitly);
    
    [self reloadSpecifierID:@"bitly_access_token" animated:YES];
    [self reloadSpecifierID:@"bitlyusername" animated:YES];
    [self reloadSpecifierID:@"bitlypassword" animated:YES];
    [self reloadSpecifierID:@"bitlyLoginButton" animated:YES];
    [self reloadSpecifierID:@"bitlyuserhistory" animated:YES];
    [self reloadSpecifierID:@"bitlyurltextfield" animated:YES];
    [self reloadSpecifierID:@"bitlyshortbutton" animated:YES];
    [self reloadSpecifierID:@"bitlyshorturltextfield" animated:YES];
}

-(void)shortenURL {

	NSString *urlToBeShortened = (NSString *)[self readPreferenceValue:[self specifierForID:@"bitlyurltextfield"]];
	NSString *accessToken = (NSString *)[self readPreferenceValue:[self specifierForID:@"bitly_access_token"]];

	if (!connection) {
		connection = [[BitlyConnection alloc] init];
	}

	[connection shortURL:urlToBeShortened withAccessToken:accessToken];

}

#pragma mark - BitlyConnectionDelegate

- (void)connection:(BitlyConnection *)connection didReceiveAccessToken:(NSString *)accessToken {

	[self setPreferenceValue:accessToken specifier:[self specifierForID:@"bitly_access_token"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadSpecifierID:@"bitly_access_token" animated:YES];

    ((PSSpecifier *)[self specifierForID:@"bitlyLoginButton"]).name = @"Logout";
    MSHookIvar<SEL>((PSSpecifier *)[self specifierForID:@"bitlyLoginButton"],"action") = @selector(logout);
    [self reloadSpecifierID:@"bitlyLoginButton" animated:YES];
	
    [((PSSpecifier *)[self specifierForID:@"bitlyusername"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
    [((PSSpecifier *)[self specifierForID:@"bitlypassword"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
    [((PSSpecifier *)[self specifierForID:@"bitlyuserhistory"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
    [((PSSpecifier *)[self specifierForID:@"bitlyurltextfield"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
    [((PSSpecifier *)[self specifierForID:@"bitlyshortbutton"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
        
    [self reloadSpecifierID:@"bitlyusername" animated:YES];
    [self reloadSpecifierID:@"bitlypassword" animated:YES];
    [self reloadSpecifierID:@"bitlyuserhistory" animated:YES];
    [self reloadSpecifierID:@"bitlyurltextfield" animated:YES];
    [self reloadSpecifierID:@"bitlyshortbutton" animated:YES];
}

- (void)connection:(BitlyConnection *)connection didFailWithMessage:(NSString *)message {

	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[av show];
	[av release];
}

- (void)connection:(BitlyConnection *)connection didShortURLWithReturningInfo:(NSDictionary *)info {

	[self setPreferenceValue:info[@"aggregate_link"] specifier:[self specifierForID:@"bitlyshorturltextfield"]];
    [((PSSpecifier *)[self specifierForID:@"bitlyshorturltextfield"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
    [self reloadSpecifierID:@"bitlyshorturltextfield"];
}

@end

@interface SREditTextCell : PSEditableTableCell
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
@end

@implementation SREditTextCell 
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}
@end
