//
//  ExampleSecondView.m
//  ExpandableTableView
//
//  Created by Tom Fewster on 17/04/2012.
//

#import "ExampleSecondView.h"

@implementation ExampleSecondView

@synthesize viewLabel = _viewLabel;
@synthesize text = _text;

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_viewLabel.text = _text;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
