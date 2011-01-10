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

@interface RootViewController (Private)

- (NSDictionary *)tweetForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)textForTweetAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)imageURLForTweetAtIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)imageForTweetAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation RootViewController

@synthesize tweets, images;

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	self.images = [NSMutableDictionary dictionary];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	NSString *stringURL = @"http://api.twitter.com/1/statuses/public_timeline.json";
	[Seriously get:stringURL handler:^(id body, NSHTTPURLResponse *response, NSError *error){
	         if(error)
	         {
	                 NSLog (@"Error: %@", error);
	                 return;
			 }
	         self.tweets = body;
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
	return self.tweets == nil ? 0 : [self.tweets count];
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
	}
	NSString *text = [self textForTweetAtIndexPath:indexPath];
	cell.textLabel.text = text;
	cell.imageView.image = [self imageForTweetAtIndexPath:indexPath];
	return cell;
}

/* Return the custom height of the cell based on the content that will be displayed */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *text = [self textForTweetAtIndexPath:indexPath];
	UIFont *font = [UIFont systemFontOfSize:14 ];
	CGSize withinSize = CGSizeMake( 350, 150);
	CGSize size = [text sizeWithFont:font constrainedToSize:withinSize lineBreakMode:UILineBreakModeWordWrap];
	CGFloat textHeight = size.height + 35;
	return textHeight;
}

- (NSDictionary *)tweetForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *tweet = [tweets objectAtIndex:indexPath.row];
	return tweet;
}

- (NSString *)textForTweetAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *tweet = [self tweetForRowAtIndexPath:indexPath];
	NSString *text = [tweet objectForKey:@"text"];
	return text;
}

- (NSString *)imageURLForTweetAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *tweet = [self tweetForRowAtIndexPath:indexPath];
	NSDictionary *user = [tweet objectForKey:@"user"];
	NSString *url = [user objectForKey:@"profile_image_url"];
	return url;
}

- (UIImage *)imageForTweetAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *tweet = [self tweetForRowAtIndexPath:indexPath];
	NSDictionary *user = [tweet objectForKey:@"user"];
	NSString *userID = [user objectForKey:@"id_str"];
	UIImage *image = [self.images objectForKey:userID];
	if(!image)
	{
		image = [UIImage imageNamed:@"Placeholder.png"];
		[self.images setValue:image forKey:userID];
		NSString *url = [user objectForKey:@"profile_image_url"];
		[Seriously get:url handler:^(id body, NSHTTPURLResponse *response, NSError *error){
		         UIImage *anImage = [UIImage imageWithData:body];
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
	[super dealloc];
}

@end

