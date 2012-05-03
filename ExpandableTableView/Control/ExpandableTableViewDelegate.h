//
//  ExpandableTableViewDelegate.h
//  ExpandableTableView
//
//  Created by Tom Fewster on 05/04/2012.
//

#import <Foundation/Foundation.h>

@class ExpandableTableView;

@protocol ExpandableTableViewDelegate <NSObject>

@optional
- (void)tableView:(ExpandableTableView *)tableView willExpandSection:(NSUInteger)section;
- (void)tableView:(ExpandableTableView *)tableView didExpandSection:(NSUInteger)section;
- (void)tableView:(ExpandableTableView *)tableView willContractSection:(NSUInteger)section;
- (void)tableView:(ExpandableTableView *)tableView didContractSection:(NSUInteger)section;

- (BOOL)tableView:(ExpandableTableView *)tableView canRemoveSection:(NSUInteger)section;

//- (CGFloat)tableView:(ExpandableTableView *)tableView heightForSection:(NSUInteger)section;
//- (CGFloat)tableView:(ExpandableTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(ExpandableTableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(ExpandableTableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(ExpandableTableView *)tableView willDisplayCell:(UITableViewCell *)cell forSection:(NSUInteger)section;

//- (void)tableView:(ExpandableTableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)tableView:(ExpandableTableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(ExpandableTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(ExpandableTableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(ExpandableTableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

//- (void)tableView:(ExpandableTableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath;
//- (void)tableView:(ExpandableTableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath;
//- (UITableViewCellEditingStyle)tableView:(ExpandableTableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
//- (NSString *)tableView:(ExpandableTableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)tableView:(ExpandableTableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath;

////- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;

//- (BOOL)tableView:(ExpandableTableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)tableView:(ExpandableTableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
//- (void)tableView:(ExpandableTableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;

@end
