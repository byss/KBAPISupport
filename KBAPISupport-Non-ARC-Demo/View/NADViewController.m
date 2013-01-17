//
//  NADViewController.m
//  KBAPISupport-Non-ARC-Demo
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

#import "NADViewController.h"

#import "GDataXMLNode.h"
#import "GDataXMLElement+stuff.h"

#import "NADConcreteDataRequest.h"
#import "KBAPISupport-debug.h"

@implementation NADViewController {
@private
	NSArray *_keys;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.clearsSelectionOnViewWillAppear = YES;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.containsURLs) {
		self.title = @"Main menu";
	} else if ([self.contents isKindOfClass:[NSArray class]]) {
		self.title = @"Array";
	} else if ([self.contents isKindOfClass:[NSDictionary class]]) {
		self.title = @"Dictionary";
	} else {
		self.title = @"Object";
	}
}

- (void) setContents:(id)contents {
	if (_contents != contents) {
		[_contents release];
		_contents = [contents retain];
		
		[_keys release];
		if ([_contents isKindOfClass:[NSDictionary class]]) {
			_keys = [[_contents allKeys] retain];
		} else {
			_keys = nil;
		}
		
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([self.contents respondsToSelector:@selector(count)]) {
		return [self.contents count];
	} else {
		return 0;
	}
}

+ (NSString *) descriptionForCell: (id) object {
	if ([object isKindOfClass:[NSDictionary class]]) {
		return [NSString stringWithFormat:@"Dictionary (%d fields)", [object count]];
	} else if ([object isKindOfClass:[NSArray class]]) {
		return [NSString stringWithFormat:@"Array (%d values)", [object count]];
	} else if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
		return [object description];
	} else {
		return [NSString stringWithFormat:@"%@ object", [object class]];
	}
}

- (UITableViewCell *)tableView: (UITableView*) tableView cellForDictAtIndexPath: (NSIndexPath *) indexPath {
	static NSString *cellID = @"dictCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellID] autorelease];
	}
	
	id key = [_keys objectAtIndex:indexPath.row];
	cell.textLabel.text = [[self class] descriptionForCell:key];
	cell.detailTextLabel.text = [[self class] descriptionForCell:[self.contents objectForKey:key]];
	
	return cell;
}

- (UITableViewCell *)tableView: (UITableView*) tableView cellForArrayAtIndexPath: (NSIndexPath *) indexPath {
	static NSString *cellID = @"arrayCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellID] autorelease];
	}
	
	cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
	cell.detailTextLabel.text = [[self class] descriptionForCell:[self.contents objectAtIndex:indexPath.row]];
	
	return cell;
}

- (UITableViewCell *)tableView: (UITableView*) tableView cellForUnknownAtIndexPath: (NSIndexPath *) indexPath {
	static NSString *cellID = @"unknownCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	}
	
	cell.textLabel.text = nil;
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([_contents isKindOfClass:[NSDictionary class]]) {
		return [self tableView:tableView cellForDictAtIndexPath:indexPath];
	} else if ([_contents isKindOfClass:[NSArray class]]) {
		return [self tableView:tableView cellForArrayAtIndexPath:indexPath];
	} else {
		BUG_HERE
		return [self tableView:tableView cellForUnknownAtIndexPath:indexPath];
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.containsURLs) {
		NADConcreteDataRequest *req = [NADConcreteDataRequest request];
		req.basename = [self.contents objectAtIndex:indexPath.row];
		self.view.userInteractionEnabled = NO;
		[[KBAPIConnection connectionWithRequest:req delegate:self] start];
	} else {
		id newRoot = nil;
		if ([self.contents isKindOfClass:[NSDictionary class]]) {
			newRoot = [self.contents objectForKey:[_keys objectAtIndex:indexPath.row]];
		} else if ([self.contents isKindOfClass:[NSArray class]]) {
			newRoot = [self.contents objectAtIndex:indexPath.row];
		}
		
		if ([newRoot isKindOfClass:[NSArray class]] || [newRoot isKindOfClass:[NSDictionary class]]) {
			[self pushNewVCWithContents:newRoot];
		} else {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
}

- (void) pushNewVCWithContents: (id) contents {
	NADViewController *vc = [[NADViewController alloc] initWithNibName:@"NADViewController" bundle:nil];
	vc.contents = contents;
	vc.containsURLs = NO;
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - KBAPIConnection delegate

- (void) apiConnection:(KBAPIConnection *)connection didFailWithError:(NSError *)error {
	KBAPISUPPORT_LOG (@"error: %@", error);
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[av show];

	self.view.userInteractionEnabled = YES;
}

- (void) apiConnection:(KBAPIConnection *)connection didReceiveJSON:(id)JSON {
	[self pushNewVCWithContents:JSON];

	self.view.userInteractionEnabled = YES;
}

- (void) apiConnection:(KBAPIConnection *)connection didReceiveXML:(GDataXMLDocument *)XML {
	id response = [XML.rootElement objectValue];
	if (response) {
		[self pushNewVCWithContents:response];
	} else {
		UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"XML is not parseable." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[av show];
	}

	self.view.userInteractionEnabled = YES;
}

@end
