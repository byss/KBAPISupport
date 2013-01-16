//
//  ADViewController.m
//  KBAPISupport-ARC-Demo
//
//  Created by Kirill byss Bystrov on 01.12.12.
//  Copyright (c) 2012 Kirill byss Bystrov. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "ADViewController.h"

#import "WPArticleHeader.h"
#import "WPHeadersList.h"
#import "WPOpenSearchRequest.h"

@implementation ADViewController {
@private
	WPHeadersList *_list;
}

- (IBAction)updateSearch:(UITextField *)sender {
	_list = nil;
	[self.tableView reloadData];
	
	WPOpenSearchRequest *req = [WPOpenSearchRequest request];
	req.searchText = sender.text;
	[[KBAPIConnection connectionWithRequest:req delegate:self] start];
}

- (void) apiConnection:(KBAPIConnection *)connection didFailWithError:(NSError *)error {
	KBAPISUPPORT_LOG (@"error: %@", error);
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[av show];
}

- (void) apiConnection:(KBAPIConnection *)connection didReceiveResponse:(id<KBEntity>)response {
	KBAPISUPPORT_LOG (@"response: %@", [response class]);
	_list = response;
	[self.tableView reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_list count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
	}
	
	WPArticleHeader *header = [_list entityForIndex:indexPath.row];
	cell.textLabel.text = header.title;
	
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	F_START
	
	WPArticleHeader *header = [_list entityForIndex:indexPath.row];
	KBAPISUPPORT_LOG (@"%@ %@", header.link, [header.link class]);
	[[UIApplication sharedApplication] openURL:header.link];
	
	F_END
}

- (void) viewWillAppear:(BOOL)animated {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end
