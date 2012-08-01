//
//  ExpandableTableView.m
//  ExpandableTableView
//
//  Created by Tom Fewster on 02/04/2012.
//

#import "ExpandableTableView.h"

@interface ExpandableTableView ()
@property (weak) id<ExpandableTableViewDataSource> expandableDataSource;
@property (weak) id<ExpandableTableViewDelegate> expandableDelegate;
@property (strong) NSMutableIndexSet *expandedSectionIndexes;
@property (assign) NSUInteger dropGroupHighlightIndex;
@property (assign) NSUInteger changesCount;

@property (strong) NSMutableIndexSet *pendingSectionInsert;
@property (strong) NSMutableIndexSet *pendingSectionDelete;
@property (strong) NSMutableIndexSet *pendingSectionMove;
@property (strong) NSMutableArray *pendingRowInsert;
@property (strong) NSMutableArray *pendingRowDelete;
@property (strong) NSMutableArray *pendingRowMove;

- (void)_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)_moveSection:(NSInteger)section toSection:(NSInteger)newSection;
- (void)_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

- (NSIndexSet *)_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;
- (NSIndexSet *)_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

@end

@implementation ExpandableTableView

@synthesize expandableDataSource = _expandableDataSource;
@synthesize expandableDelegate = _expandableDelegate;
@synthesize expandedSectionIndexes = _expandedSectionIndexes;
@synthesize ungroupSingleElement = _ungroupSingleElement;
@synthesize dropGroupHighlightIndex = _dropGroupHighlightIndex;
@synthesize changesCount = _changesCount;

@synthesize pendingSectionInsert = _pendingSectionInsert;
@synthesize pendingSectionDelete = _pendingSectionDelete;
@synthesize pendingSectionMove = _pendingSectionMove;
@synthesize pendingRowInsert = _pendingRowInsert;
@synthesize pendingRowDelete = _pendingRowDelete;
@synthesize pendingRowMove = _pendingRowMove;

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[super setDataSource:self];
		[super setDelegate:self];
		_expandedSectionIndexes = [NSMutableIndexSet indexSet];
		_dropGroupHighlightIndex = NSNotFound;
		
		_pendingSectionInsert = [NSMutableIndexSet indexSet];
		_pendingSectionDelete = [NSMutableIndexSet indexSet];
		_pendingSectionMove = [NSMutableIndexSet indexSet];
		_pendingRowInsert = [NSMutableArray array];
		_pendingRowDelete = [NSMutableArray array];
		_pendingRowMove = [NSMutableArray array];
	}
	
	return self;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate {
	_expandableDelegate = (id<ExpandableTableViewDelegate>)delegate;
	[super setDelegate:self];
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
	_expandableDataSource = (id<ExpandableTableViewDataSource>)dataSource;
	[super setDataSource:self];

	if ([_expandableDataSource respondsToSelector:@selector(ungroupSimpleElementsInTableView:)]) {
		_ungroupSingleElement = [_expandableDataSource ungroupSimpleElementsInTableView:self];
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	if (!editing) {
		if (_dropGroupHighlightIndex != NSNotFound) {
			[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_dropGroupHighlightIndex]].highlighted = NO;
		}
		_dropGroupHighlightIndex = NSNotFound;
	}
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
	[_pendingRowInsert addObjectsFromArray:indexPaths];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
	[self _moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
	[_pendingRowDelete addObjectsFromArray:indexPaths];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
	[_pendingSectionInsert addIndexes:sections];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
	[super moveSection:section toSection:newSection];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
	[_pendingSectionDelete addIndexes:sections];
}

- (void)beginUpdates {
	_changesCount++;	
	[super beginUpdates];
}

- (void)endUpdates {
	
	_changesCount--;
	if (_changesCount == 0) {
		// we need to apply all the pending changes
		
		NSMutableIndexSet *reloadRows = [NSMutableIndexSet indexSet];
		
		// handle deletes and section deletes first
		NSIndexSet *r = [self _deleteRowsAtIndexPaths:_pendingRowDelete withRowAnimation:UITableViewRowAnimationFade];
		[reloadRows addIndexes:r];
		[self _deleteSections:_pendingSectionDelete withRowAnimation:UITableViewRowAnimationFade];
		
		// .... now handle inserts and section inserts
		[self _insertSections:_pendingSectionInsert withRowAnimation:UITableViewRowAnimationFade];
		r = [self _insertRowsAtIndexPaths:_pendingRowInsert withRowAnimation:UITableViewRowAnimationFade];
		[reloadRows addIndexes:r];

		[reloadRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
			if (![_pendingSectionInsert containsIndex:idx] && ![_pendingSectionDelete containsIndex:idx]) {
				[super reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:idx]] withRowAnimation:UITableViewRowAnimationFade];
			}
		}];
		
		[_pendingRowDelete removeAllObjects];
		[_pendingSectionDelete removeAllIndexes];
		[_pendingRowInsert removeAllObjects];
		[_pendingSectionInsert removeAllIndexes];
	}
	
	[super endUpdates];
}


- (UITableViewCell *)cellForChildRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0 && _ungroupSingleElement && [self numberOfRowsInSection:indexPath.section] == 1) {
		return [super cellForRowAtIndexPath:indexPath];
	}
	return [super cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
}

- (UITableViewCell *)cellForSection:(NSUInteger)section {
	if (_ungroupSingleElement && [self numberOfRowsInSection:section] == 1) {
		return nil;
	}
	return [super cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
}

- (BOOL)cellVisibleForIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return YES;
	} else if ([_expandedSectionIndexes containsIndex:indexPath.section] && [self numberOfRowsInSection:indexPath.section] > indexPath.row) {
		return YES;
	}

	return NO;
}

- (NSString *)description {
	
	NSMutableString *s = [NSMutableString string];
	
	[s appendFormat:@"\n\n--- Table ---\n"];
	NSInteger sections1 = [self numberOfSections];
	for (NSInteger i = 0; i < sections1; i++) {
		NSInteger rows = [self numberOfRowsInSection:i];
		[s appendFormat:@"Section %d has %d rows\n", i, rows];
	}
	
	[s appendFormat:@"--- DataModel ---\n"];
	NSInteger sections2 = [self numberOfSectionsInTableView:self];
	for (NSInteger i = 0; i < sections2; i++) {
		NSInteger rows = [self tableView:self numberOfRowsInSection:i];
		[s appendFormat:@"Section %d has %d rows\n", i, rows];
	}
	
	[s appendFormat:@"--- Representation ---\n"];
	NSInteger sections3 = [_expandableDataSource numberOfSectionsInTableView:self];
	for (NSInteger i = 0; i < sections3; i++) {
		NSInteger rows = [_expandableDataSource tableView:self numberOfRowsInSection:i];
		[s appendFormat:@"Section %d has %d rows\n", i, rows];
	}
	[s appendFormat:@"\n"];
	
	return s;
}

- (void)expandSection:(NSUInteger)section {
	if (![_expandedSectionIndexes containsIndex:section]) {
		[self beginUpdates];
		if ([_expandableDelegate respondsToSelector:@selector(tableView:willExpandSection:)]) {
			[_expandableDelegate tableView:self willExpandSection:section];
		}
		[_expandedSectionIndexes addIndex:section];
		NSUInteger count = [_expandableDataSource tableView:self numberOfRowsInSection:section];
		NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:count];
		for (NSUInteger i = 0; i < count; i++) {
			[indexPaths addObject:[NSIndexPath indexPathForRow:i+1 inSection:section]];
		}
		[super insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
		if ([_expandableDelegate respondsToSelector:@selector(tableView:didExpandSection:)]) {
			[_expandableDelegate tableView:self didExpandSection:section];
		}
		[self endUpdates];
	}
}

- (void)contractSection:(NSUInteger)section {
	if ([_expandedSectionIndexes containsIndex:section]) {
		[self beginUpdates];
		if ([_expandableDelegate respondsToSelector:@selector(tableView:willContractSection:)]) {
			[_expandableDelegate tableView:self willContractSection:section];
		}
		[_expandedSectionIndexes removeIndex:section];
		NSUInteger count = [_expandableDataSource tableView:self numberOfRowsInSection:section];
		NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:count];
		for (NSUInteger i = count; i > 0; i--) {
			[indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
		}
		[super deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
		if ([_expandableDelegate respondsToSelector:@selector(tableView:didContractSection:)]) {
			[_expandableDelegate tableView:self didContractSection:section];
		}
		[self endUpdates];
	}
}

- (NSIndexSet *)indexesForExpandedSections {
	return [_expandedSectionIndexes copy];
}

- (void)reloadSectionCellsAtIndexes:(NSIndexSet *)indexes withRowAnimation:(UITableViewRowAnimation)animation {
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[indexes count]];
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:idx]];
	}];

	[self reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([_expandedSectionIndexes containsIndex:indexPath.section] && indexPath.row != 0) {
		return [_expandableDataSource tableView:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
	} else if (indexPath.row == 0 && _ungroupSingleElement && [_expandableDataSource tableView:self numberOfRowsInSection:indexPath.section] == 1) {
		return [_expandableDataSource tableView:self cellForRowAtIndexPath:indexPath];
	} else {
		// display just the header
		return [_expandableDataSource tableView:self cellForGroupInSection:indexPath.section];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([_expandedSectionIndexes containsIndex:section]) {
		NSInteger rows = [_expandableDataSource tableView:self numberOfRowsInSection:section];
		if (rows == 1 && _ungroupSingleElement) {
			return 1;
		}
		return rows + 1;
	}
	return 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		if ([_expandableDataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
			if (indexPath.row == 0 && _ungroupSingleElement && [_expandableDataSource tableView:self numberOfRowsInSection:indexPath.section] == 1) {
				[_expandableDataSource tableView:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
			} else if (indexPath.row == 0) {
				// delete a group
				if ([_expandableDelegate respondsToSelector:@selector(tableView:canRemoveSection:)]) {
					if ([_expandableDelegate tableView:self canRemoveSection:indexPath.section]) {
						NSLog(@"Need to remove everything in our group");
						NSInteger count = [_expandableDataSource tableView:self numberOfRowsInSection:indexPath.section];
						for (NSInteger i = count; i > 0; i--) {
							NSLog(@"Requesting removal of indexPath %@", [NSIndexPath indexPathForRow:i - 1 inSection:indexPath.section]);
							[_expandableDataSource tableView:self commitEditingStyle:editingStyle forRowAtIndexPath:[NSIndexPath indexPathForRow:i - 1 inSection:indexPath.section]];
						}
					}
				}
			} else {
				NSLog(@"Requesting removal of indexPath %@", [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]);
				[_expandableDataSource tableView:self commitEditingStyle:editingStyle forRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
			}
		}
	} else {
		if ([_expandableDataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
			[_expandableDataSource tableView:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger sections = 1;
	if ([_expandableDataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
		sections = [_expandableDataSource numberOfSectionsInTableView:self];
	}
	return sections;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (([_expandedSectionIndexes containsIndex:indexPath.section] && indexPath.row != 0) || (indexPath.row == 0 && _ungroupSingleElement && [self numberOfRowsInSection:indexPath.section] == 1)) {
		if ([_expandableDataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
			return [_expandableDataSource tableView:self canEditRowAtIndexPath:indexPath];
		}
	} else {
		if ([_expandableDataSource respondsToSelector:@selector(tableView:canEditSection:)]) {
			return [_expandableDataSource tableView:self canEditSection:indexPath.section];
		}
	}
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if (([_expandedSectionIndexes containsIndex:indexPath.section] && indexPath.row != 0) || (indexPath.row == 0 && _ungroupSingleElement && [self numberOfRowsInSection:indexPath.section] == 1)) {
		if ([_expandableDataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
			return [_expandableDataSource tableView:self canMoveRowAtIndexPath:indexPath];
		}
	}	
	return NO;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if ([_expandableDataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
		return [_expandableDataSource tableView:self titleForFooterInSection:section];
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([_expandableDataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
		return [_expandableDataSource tableView:self titleForHeaderInSection:section];
	}
	return nil;
}

#pragma mark -
#pragma mark UITableViewDelegateMethods

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	//[_expandableDelegate tableView:<#(UITableView *)#> indentationLevelForRowAtIndexPath:<#(NSIndexPath *)#>
	if (indexPath.row != 0 && [_expandedSectionIndexes containsIndex:indexPath.section]) {
		return 1;
	}
	
	return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([_expandedSectionIndexes containsIndex:indexPath.section] && indexPath.row != 0) {
		if ([_expandableDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
			[_expandableDelegate tableView:self willDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
		}
	} else if (indexPath.row == 0 && _ungroupSingleElement && [self numberOfRowsInSection:indexPath.section] == 1) {
		if ([_expandableDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
			[_expandableDelegate tableView:self willDisplayCell:cell forRowAtIndexPath:indexPath];
		}
	} else {
		if ([_expandableDelegate respondsToSelector:@selector(tableView:willDisplayCell:forSection:)]) {
			[_expandableDelegate tableView:self willDisplayCell:cell forSection:indexPath.section];
		}
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *newIndexPath = indexPath;
	if ([_expandedSectionIndexes containsIndex:indexPath.section] && indexPath.row != 0) {
		if ([_expandableDelegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
			newIndexPath = [_expandableDelegate tableView:self willSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
			if (newIndexPath != nil) {
				if ([_expandedSectionIndexes containsIndex:newIndexPath.section]) {
					newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];
				} else if (newIndexPath.row == 0 && _ungroupSingleElement) {
					// newIndexPath should stay the same
				} else {
					// we can't select a row that isn't visible
					newIndexPath = nil;
				}
			}
		}
	} else if (indexPath.row == 0 && _ungroupSingleElement && [self numberOfRowsInSection:indexPath.section] == 1) {
		if ([_expandableDelegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
			newIndexPath = [_expandableDelegate tableView:self willSelectRowAtIndexPath:indexPath];
			if (newIndexPath != nil) {
				if ([_expandedSectionIndexes containsIndex:newIndexPath.section]) {
					newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];
				} else if (newIndexPath.row == 0 && _ungroupSingleElement) {
					// newIndexPath should stay the same
				} else {
					// we can't select a row that isn't visible
					newIndexPath = nil;
				}
			}
		}
	}	
	return newIndexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// either expand the section or call the  delegates method if already expanded
	if ([_expandedSectionIndexes containsIndex:indexPath.section]) {
		// we're already expanded
		if (indexPath.row == 0) {
			// close the section
			[self contractSection:indexPath.section];
			[super deselectRowAtIndexPath:indexPath animated:YES];
		} else {
			if ([_expandableDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
				[_expandableDelegate tableView:self didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
			}
		}
	} else if (indexPath.row == 0 && _ungroupSingleElement && [_expandableDataSource tableView:self numberOfRowsInSection:indexPath.section] == 1) {
		if ([_expandableDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
			[_expandableDelegate tableView:self didSelectRowAtIndexPath:indexPath];
		}
	} else {
		[self expandSection:indexPath.section];
		[super deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (NSIndexPath *)tableView:(ExpandableTableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *newIndexPath = indexPath;
	if ([_expandedSectionIndexes containsIndex:indexPath.section] && indexPath.row != 0) {
		if ([_expandableDelegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
			newIndexPath = [_expandableDelegate tableView:self willDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
			// TODO: correct the new indexPath
		}
	} else if (indexPath.row == 0 && _ungroupSingleElement && [self numberOfRowsInSection:indexPath.section] == 1) {
		if ([_expandableDelegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
			newIndexPath = [_expandableDelegate tableView:self willDeselectRowAtIndexPath:indexPath];
			// TODO: correct the new indexPath
		}
	}	
	return newIndexPath;
}

- (void)tableView:(ExpandableTableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([_expandedSectionIndexes containsIndex:indexPath.section] && indexPath.row != 0) {
		if ([_expandableDelegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
			[_expandableDelegate tableView:self didDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
		}
	} else if (indexPath.row == 0 && _ungroupSingleElement && [self numberOfRowsInSection:indexPath.section] == 1) {
		if ([_expandableDelegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
			[_expandableDelegate tableView:self didDeselectRowAtIndexPath:indexPath];
		}
	}	
}

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	if ([_expandableDataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
		[_expandableDataSource tableView:self moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
	}
}
*/

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	NSLog(@"Proposed Location: %@", proposedDestinationIndexPath);
	// if the section is expanded we can drop in there
	if ([_expandedSectionIndexes containsIndex:proposedDestinationIndexPath.section] && proposedDestinationIndexPath.row != 0) {
		if (_dropGroupHighlightIndex != NSNotFound) {
			[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_dropGroupHighlightIndex]].highlighted = NO;
			_dropGroupHighlightIndex = NSNotFound;
		}
		return proposedDestinationIndexPath;
	} else if (proposedDestinationIndexPath.row == 0) {
		if (_dropGroupHighlightIndex != NSNotFound) {
			[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_dropGroupHighlightIndex]].highlighted = NO;
		}
		[self cellForRowAtIndexPath:proposedDestinationIndexPath].highlighted = YES;
		_dropGroupHighlightIndex = proposedDestinationIndexPath.section;
		//return [NSIndexPath indexPathForRow:1 inSection:proposedDestinationIndexPath.section];
	}
	
	//	if (sourceIndexPath.section == proposedDestinationIndexPath.section) {
	//	return proposedDestinationIndexPath;
	//}
	return sourceIndexPath;
}

#pragma mark -
#pragma mark Private insert/update methods

- (void)_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
	[super insertSections:sections withRowAnimation:animation];
}

- (void)_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
	[super moveSection:section toSection:newSection];
}

- (void)_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
	[super deleteSections:sections withRowAnimation:animation];
}

- (NSIndexSet *)_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
	NSMutableArray *correctedIndexPaths = [NSMutableArray array];
	NSMutableIndexSet *reloadIndexPaths = [NSMutableIndexSet indexSet];
	for (NSIndexPath *indexPath in indexPaths) {
		NSInteger rowsInSection = [_expandableDataSource tableView:self numberOfRowsInSection:indexPath.section];
		if (indexPath.row == 0 && _ungroupSingleElement && rowsInSection == 1) {
			NSLog(@"Adding stand alone element");
			[correctedIndexPaths addObject:indexPath];
		} else {
			if (rowsInSection == 1) {
				// we are adding our first cell in our section, we need to add the header too
				NSLog(@"Adding section header (%@)", [NSIndexPath indexPathForRow:0 inSection:indexPath.section]);
				[correctedIndexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
			} else {
				[reloadIndexPaths addIndex:indexPath.section];
			}
			if ([_expandedSectionIndexes containsIndex:indexPath.section]) {
				NSLog(@"Adding child to section %@", [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]);
				[correctedIndexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
			}
			NSLog(@"Adding complete (%@)", indexPath);
		}
	}
	if ([correctedIndexPaths count]) {
		[super insertRowsAtIndexPaths:correctedIndexPaths withRowAnimation:animation];
		NSLog(@"Adding %d rows", [correctedIndexPaths count]);
	}
	
	return reloadIndexPaths;
}

- (void)_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
	[self deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[self insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (NSIndexSet *)_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
	
	NSMutableArray *correctedIndexPaths = [NSMutableArray array];
	NSMutableIndexSet *reloadIndexPaths = [NSMutableIndexSet indexSet];
	for (NSIndexPath *indexPath in indexPaths) {
		if (indexPath.row == 0 && _ungroupSingleElement && [self numberOfRowsInSection:indexPath.section] == 1) {
			[correctedIndexPaths addObject:indexPath];
		} else {
			if ([_expandedSectionIndexes containsIndex:indexPath.section]) {
				[correctedIndexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
			}
			if ([self numberOfRowsInSection:indexPath.section] == 2) {
				// we are delting the last cell in our section, we need to remove the header too
				[correctedIndexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
				[_expandedSectionIndexes removeIndex:indexPath.section];
			} else if (_ungroupSingleElement && [self numberOfRowsInSection:indexPath.section] == 3) {
				// our number of rows has dropped to 1 (+ the header), since we are displaying ungrouped single elements
				// we need to remove, 1 more and refresh the header
				if ([_expandedSectionIndexes containsIndex:indexPath.section]) {
					[correctedIndexPaths addObject:[NSIndexPath indexPathForRow:1 inSection:indexPath.section]];
					[_expandedSectionIndexes removeIndex:indexPath.section];
				}
				[reloadIndexPaths addIndex:indexPath.section];
			}
		}
	}
	if ([correctedIndexPaths count]) {
		[super deleteRowsAtIndexPaths:correctedIndexPaths withRowAnimation:animation];
		NSLog(@"Removing %d rows", [correctedIndexPaths count]);
	}

	return reloadIndexPaths;
}

@end
