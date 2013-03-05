/*  RootViewController.m */

/*  SeriouslyDemo
 *
 *  Created by Adam Duke on 1/10/11.
 *  Copyright 2011 None. All rights reserved.
 *
 *  This UIViewController is the bulk of the SeriouslyDemo.
 *  It uses the (SeriouslyOperation *)get:(id)url handler:(SeriouslyHandler)handler
 *  method to asynchronously fetch the current public timeline from twitter in json
 *  format and subsequently display each tweet in a table view. It also uses the
 *  same method to asynchronously fetch the images for each of those tweets as the
 *  cells are drawn on the screen.
 *
 *  (void)viewDidAppear:(BOOL)animated kicks off the fetch of the twitter timeline
 *  (UIImage)imageForTweetAtIndexPath:(NSIndexPath *)indexPath kicks off the fetch
 *  for each individual image
 */

#import "RootViewController.h"
#import "Seriously.h"
#import "SeriouslyJSON.h"

#error You must create a client at http://instagram.com/developer/clients/manage/ and fill the client id in below
#define CLIENT_ID @"your-client-id"

@interface RootViewController ()

- (NSDictionary *)postForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)textForPostAtIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)imageForPostAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, retain) NSArray *posts;
@property (nonatomic, retain) NSDictionary *images;

@end

@implementation RootViewController

@synthesize posts, images;

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	self.images = [NSMutableDictionary dictionary];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	NSString *stringURL = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/popular?client_id=%@", CLIENT_ID];
	[Seriously get:stringURL handler:^(id data, NSHTTPURLResponse *response, NSError *error)
    {
		if(error)
		{
			NSLog (@"Error: %@", error);
			return;
		}
		NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		id jsonValue = [SeriouslyJSON parse:jsonString];
        [jsonString release];
		self.posts = [jsonValue objectForKey:@"data"];
		[self.tableView reloadData];
	}];
}

#pragma mark -
#pragma mark Table view data source

/* Customize the number of sections in the table view. */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

/* Customize the number of rows in the table view. */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.posts == nil ? 0 : [self.posts count];
}

/* Customize the appearance of table view cells. */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	NSString *text = [self textForPostAtIndexPath:indexPath];
	cell.textLabel.text = text;
	cell.imageView.image = [self imageForPostAtIndexPath:indexPath];
	return cell;
}

/* Return the custom height of the cell based on the content that will be displayed */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *text = [self textForPostAtIndexPath:indexPath];
	UIFont *font = [UIFont systemFontOfSize:14 ];
	CGSize withinSize = CGSizeMake( 350, 150);
	CGSize size = [text sizeWithFont:font constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap];
	CGFloat textHeight = size.height + 35;
	return textHeight;
}

- (NSDictionary *)postForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *post = [self.posts objectAtIndex:indexPath.row];
	return post;
}

- (NSString *)textForPostAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *post = [self postForRowAtIndexPath:indexPath];
	NSDictionary *user = [post objectForKey:@"user"];
    NSString *postText = [user objectForKey:@"username"];
	return postText;
}

- (UIImage *)imageForPostAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *post = [self postForRowAtIndexPath:indexPath];
	NSDictionary *user = [post objectForKey:@"user"];
	NSString *userID = [user objectForKey:@"id"];
	UIImage *image = [self.images objectForKey:userID];
	if(!image)
	{
		image = [UIImage imageNamed:@"Placeholder.png"];
		[self.images setValue:image forKey:userID];
		NSString *url = [user objectForKey:@"profile_picture"];
		[Seriously get:url handler:^(id data, NSHTTPURLResponse *response, NSError *error){
			UIImage *anImage = [UIImage imageWithData:data];
			[self.images setValue:anImage forKey:userID];
			[self.tableView reloadData];
		}];
	}
	return image;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
	/* Releases the view if it doesn't have a superview. */
	[super didReceiveMemoryWarning];

	/* Relinquish ownership any cached data, images, etc that aren't in use. */
}

- (void)dealloc
{
	[tweets release];
	[images release];
	[super dealloc];
}

@end

