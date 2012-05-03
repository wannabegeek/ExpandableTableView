//
//  ExpandableTableViewDataSource.h
//  ExpandableTableView
//
//  Created by Tom Fewster on 05/04/2012.
//

#import <Foundation/Foundation.h>

@class ExpandableTableView;

@protocol ExpandableTableViewDataSource <NSObject>

@required
- (UITableViewCell *)tableView:(ExpandableTableView *)tableView cellForGroupInSection:(NSUInteger)section;
- (UITableViewCell *)tableView:(ExpandableTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(ExpandableTableView *)tableView numberOfRowsInSection:(NSInteger)section;
@optional
- (void)tableView:(ExpandableTableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(ExpandableTableView *)tableView;
- (BOOL)tableView:(ExpandableTableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(ExpandableTableView *)tableView canEditSection:(NSInteger)section;
- (BOOL)tableView:(ExpandableTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
//- (void)tableView:(ExpandableTableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (NSString *)tableView:(ExpandableTableView *)tableView titleForFooterInSection:(NSInteger)section;
- (NSString *)tableView:(ExpandableTableView *)tableView titleForHeaderInSection:(NSInteger)section;

- (BOOL)ungroupSimpleElementsInTableView:(ExpandableTableView *)tableView;

@end
