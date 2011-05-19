//
//  SeriouslyOAuthOperation.m
//  Seriously
//
//  Created by Adam Duke on 1/20/11.
//  Copyright 2011 Adam Duke. All rights reserved.
//

#import "SeriouslyOAuthOperation.h"

@implementation SeriouslyOAuthOperation

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	
	[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
	return;	
}

@end
