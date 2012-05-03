//
//  ExpandableTableViewController.h
//  ExpandableTableView
//
//  Created by Tom Fewster on 02/04/2012.
//

#import <UIKit/UIKit.h>
#import "ExpandableTableViewController.h"

@interface ExampleController : ExpandableTableViewController <ExpandableTableViewDataSource, ExpandableTableViewDelegate>

@property (strong) NSMutableArray *dataModel;

- (IBAction)addNewRow:(id)sender;

@end
