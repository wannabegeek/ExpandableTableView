//
//  ExampleController.m
//  ExpandableTableView
//
//  Created by Tom Fewster on 02/04/2012.
//

#import "ExampleController.h"
#import "ExampleSecondView.h"

@implementation ExampleController

@synthesize dataModel = _dataModel;


// Callback for when the '+' button is pressed to insert a new row
- (IBAction)addNewRow:(id)sender {
	[self.tableView beginUpdates];
	
	// select a random section either from the existing list or add a new one
	NSUInteger section = arc4random() % MIN(([_dataModel count] + 1), 6);
	if (section >= [_dataModel count]) {
		[_dataModel addObject:[NSMutableArray array]];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
	}

	// from the selected section, select a random row insert position
	NSUInteger row = arc4random() % ([[_dataModel objectAtIndex:section] count] + 1);

	static NSUInteger s_count = 0;
	// add the new row to the data model
	[[_dataModel objectAtIndex:section] insertObject:[NSString stringWithFormat:@"Row %d", s_count++] atIndex:row];
	
	// and insert it into the table
	// depeneding on the group type and if the group is expanded, the row may not acually be inserted
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationFade];

//	[[_dataModel objectAtIndex:section] insertObject:[NSString stringWithFormat:@"Row %d", s_count++] atIndex:row+1];
//	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row+1 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];

	[self.tableView endUpdates];

	
	// Temporarily flash the row that updated, so it is easily identifiable
	UITableViewCell *headerCell = [self.tableView cellForSection:section];
	[UIView animateWithDuration:0.3f animations:^{
		headerCell.contentView.backgroundColor = [UIColor colorWithRed:0.3 green:0.8 blue:0.3 alpha:1.0];
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.3f animations:^{
			headerCell.contentView.backgroundColor = [UIColor whiteColor];
		}];
	}];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	_dataModel = [NSMutableArray arrayWithObjects:
				  [NSMutableArray arrayWithObjects:@"Row 1a", @"Row 2a", @"Row 3a", nil],
				  [NSMutableArray arrayWithObjects:@"Row 1b", @"Row 2b", nil],
				  [NSMutableArray arrayWithObjects:@"Row 1c", @"Row 2c", @"Row 3c", @"Row 4c", nil],
				  [NSMutableArray arrayWithObjects:@"Row 1d", nil],
				  nil];

	//((ExpandableTableView *)self.tableView).ungroupSingleElement = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (BOOL)ungroupSimpleElementsInTableView:(ExpandableTableView *)tableView {
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(ExpandableTableView *)tableView
{
    // Return the number of sections.
    return [_dataModel count];
}

- (NSInteger)tableView:(ExpandableTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([_dataModel count] == 0) {
		return 0;
	}
    // Return the number of rows in the section.
    return [[_dataModel objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(ExpandableTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RowCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	cell.textLabel.text = [[_dataModel objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	// just change the cells background color to indicate group separation
	cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
	cell.backgroundView.backgroundColor = [UIColor colorWithRed:232.0/255.0 green:243.0/255.0 blue:1.0 alpha:1.0];
	
    return cell;
}

- (UITableViewCell *)tableView:(ExpandableTableView *)tableView cellForGroupInSection:(NSUInteger)section
{
    static NSString *CellIdentifier = @"GroupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	cell.textLabel.text = [NSString stringWithFormat: @"Group %d (%d)", section, [self tableView:tableView numberOfRowsInSection:section]];
	
	// We add a custom accessory view to indicate expanded and colapsed sections
	cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ExpandableAccessoryView"] highlightedImage:[UIImage imageNamed:@"ExpandableAccessoryView"]];
	UIView *accessoryView = cell.accessoryView;
	if ([[tableView indexesForExpandedSections] containsIndex:section]) {
		accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
	} else {
		accessoryView.transform = CGAffineTransformMakeRotation(0);		
	}
    return cell;
}

// The next two methods are used to rotate the accessory view indicating whjether the 
// group is expanded or now
- (void)tableView:(ExpandableTableView *)tableView willExpandSection:(NSUInteger)section {
	UITableViewCell *headerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
	[UIView animateWithDuration:0.3f animations:^{
		headerCell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI - 0.00001); // we need this little hack to subtract a small amount to make sure we rotate in the correct direction
	}];
}

- (void)tableView:(ExpandableTableView *)tableView willContractSection:(NSUInteger)section {
	UITableViewCell *headerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
	[UIView animateWithDuration:0.3f animations:^{
		headerCell.accessoryView.transform = CGAffineTransformMakeRotation(0);
	}];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(ExpandableTableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(ExpandableTableView *)tableView canEditSection:(NSInteger)section {
	return YES;
}


// Override to support editing the table view.
- (void)tableView:(ExpandableTableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[[_dataModel objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
		// cellVisibleForIndexPath: isn't strictly required sicne the table view will determine if the 
		// the row at that indexPath is actually visible, and do the appropriate manipulation
		if ([(ExpandableTableView *)tableView cellVisibleForIndexPath:indexPath]) {
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}

		if ([[_dataModel objectAtIndex:indexPath.section] count] == 0) {
			[_dataModel removeObjectAtIndex:indexPath.section];
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
		} else {
			[tableView reloadSectionCellsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
		}
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
	[tableView endUpdates];
}

// Override to support rearranging the table view.
- (void)tableView:(ExpandableTableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(ExpandableTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (BOOL)tableView:(ExpandableTableView *)tableView canRemoveSection:(NSUInteger)section {
	return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(ExpandableTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:@"showDetails" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	ExampleSecondView *viewController = segue.destinationViewController;
	
	NSIndexPath *indexPath = (NSIndexPath *)sender;
	viewController.text = [NSString stringWithFormat:@"Hello from '%@'", [[_dataModel objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
}

@end
