#import "PSBitlyUserHistoryViewController.h"

@implementation PSBitlyUserHistoryViewController

- (id)initForContentSize:(CGSize)size {

    if ([[PSViewController class] instancesRespondToSelector:@selector(initForContentSize:)])
		self = [super initForContentSize:size];
	else
		self = [super init];
	
    if (self)  {
        
		CGRect frame;
		frame.origin = (CGPoint){0, 0};
		frame.size = size;

		_tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];

		_preferences = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] ?: [NSDictionary dictionary];
        
        information = [[NSMutableDictionary alloc] init];

		BOOL isOS7 = (objc_getClass("UIAttachmentBehavior") != nil);
		if (isOS7) _tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
        
        connection = [[BitlyConnection alloc] init];
        [connection setDelegate:self];
        [connection requstLinkHistoryForAccessToken:_preferences[@"kBitlyAccessToken"]];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin];
    }
	return self;
}

- (void)connection:(BitlyConnection *)connection didFailWithMessage:(NSString *)message {

	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[av show];
	[av release];
}

- (void)connection:(BitlyConnection *)connection didLoadHistoryWithItems:(NSArray *)items {

	for (NSDictionary *dict in items) {
     
        [information setObject:dict[@"aggregate_link"] forKey:dict[@"long_url"]];
        
    }

   [_tableView reloadData];
}

- (UIView *)view {
	return _tableView;
}

- (UITableView *)table {
    return _tableView;
}

- (CGSize)contentSize {
	return [_tableView frame].size;
}

- (id)navigationTitle {
    return @"User Link History";
}

- (NSString *)title {
    return @"User Link History";
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.cancelButtonIndex != buttonIndex) {
            
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Copy Link"]) {
                
            [[UIPasteboard generalPasteboard] setString:information.allValues[alertView.tag]];
                
        } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Open in Safari"]) {
                
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:information.allValues[alertView.tag]]];
        }
    }
}

#pragma mark - UITableView Delegate and DataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Link Actions" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Copy Link",@"Open in Safari",nil];
    av.tag = indexPath.row;
    [av show];
    [av release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [information allKeys].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MainCell"];
    }
    
    cell.textLabel.text = [information allValues][indexPath.row];
    cell.detailTextLabel.text = [information allKeys][indexPath.row];
    
    return cell;
}

@end