//
//  RecordTableViewController.m
//  Billy
//
//  Created by Eugenijus on 2010-12-23.
//  Copyright 2010 Eugenijus Radlinskas. All rights reserved.
//

#import "RecordTableViewController.h"
#import "BillyAppDelegate.h"
#import "Record.h"
#import "ERUtils.h"
#import "ERPalette.h"

#define TITLE_LABEL_TAG 101
#define AMOUNT_LABEL_TAG 102
#define ACTION_SHEET_TAG 103
#define DELETE_ALL_SHEET_TAG 104

#define SECTION_HEADER_FONT_SIZE 17
#define RECORD_FONT_SIZE 17
#define TOTALS_FONT_SIZE 16

#define SPACE_BETWEEN_SECTIONS 10
#define SPACE_FROM_THE_SIDES 10
#define TABLE_PADDING 15

#define AMOUNT_LABEL_WIDTH 92
#define SECTION_HEADER_IMAGE_HEIGHT 7
#define SECTION_FOOTER_IMAGE_HEIGHT 34
#define BOTTOM_BAR_HEIGHT 44
#define TOTALS_LABEL_WIDTH 58
#define TOTALS_IMAGE_SIZE 20

#define ROW_HEIGHT (RECORD_FONT_SIZE*2)
#define SECTION_HEADER_LABEL_HEIGHT (SECTION_HEADER_FONT_SIZE*2)
#define SECTION_HEADER_HEIGHT (SPACE_BETWEEN_SECTIONS+SECTION_HEADER_IMAGE_HEIGHT+TABLE_PADDING+SECTION_HEADER_LABEL_HEIGHT)

@implementation RecordTableViewController

@synthesize recordTableView, incomeLabel, expenseLabel, balanceLabel, actionButtonItem, amountFormatter, dateFormatter, dataProvider;

#pragma mark -
#pragma mark Class methods

- (void)editRecordWithObject:(Record *)record {
	
	if (record == nil) {
		record = [self.dataProvider createObject];
	}
	
	// Prepare an add edit record view.
	EditRecordViewController *editRecordViewController = [[EditRecordViewController alloc] init];
	[editRecordViewController setDelegate:self];
	[editRecordViewController setRecord:record];
	
	// Show the add record view controller wrapped in navigation controller.
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editRecordViewController];
	[ERPalette styleNavigationBar:navigationController.navigationBar];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
	[editRecordViewController release];	
}

- (void)addRecord {
	
	[self editRecordWithObject:nil];
}

- (UITableViewCell *)createCellWithIdentifier:(NSString *)cellIdentifier {
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	cell.frame = CGRectMake(0, 0, self.recordTableView.frame.size.width, ROW_HEIGHT);

	UILabel *titleLabel = [[UILabel alloc] initWithFrame:
						   CGRectMake(TABLE_PADDING, 0, cell.contentView.bounds.size.width-TABLE_PADDING*2-AMOUNT_LABEL_WIDTH, cell.bounds.size.height)];
	[titleLabel setTag:TITLE_LABEL_TAG];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setTextAlignment:UITextAlignmentLeft];
	[titleLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:RECORD_FONT_SIZE]];
	[titleLabel setHighlightedTextColor:[UIColor whiteColor]];
	[cell.contentView addSubview:titleLabel];
	[titleLabel release];
	
	UIView *amountView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TABLE_PADDING+AMOUNT_LABEL_WIDTH, cell.bounds.size.height)];
	UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, AMOUNT_LABEL_WIDTH, amountView.bounds.size.height)];
	[amountLabel setTag:AMOUNT_LABEL_TAG];
	[amountLabel setBackgroundColor:[UIColor clearColor]];
	[amountLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:RECORD_FONT_SIZE]];
	[amountLabel setHighlightedTextColor:[UIColor whiteColor]];
	[amountLabel setTextAlignment:UITextAlignmentRight];
	[amountLabel setAdjustsFontSizeToFitWidth:YES];
	[amountView addSubview:amountLabel];
	[cell setAccessoryView:amountView];
	[amountLabel release];
	[amountView release];
	
	// Background view setup.
	UIView *backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
	[backgroundView setBackgroundColor:[UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0]];
	[cell setBackgroundView:backgroundView];
	[backgroundView release];
	
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	// Table cell setup.
	Record *record = [self.dataProvider objectAtIndexPath:indexPath];
	
	// Set the title.
	UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TITLE_LABEL_TAG];
	UILabel *amountLabel = (UILabel *)[cell.accessoryView viewWithTag:AMOUNT_LABEL_TAG];
	
	[titleLabel setText:record.title];
	
	// Set the amount.
	if ([record.amount compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
		[amountLabel setTextColor:[UIColor colorWithRed:198.0/255.0 green:0 blue:0 alpha:1.0]];
	}
	else if ([record.amount compare:[NSDecimalNumber zero]] == NSOrderedDescending) {
		[amountLabel setTextColor:[UIColor colorWithRed:78.0/255.0 green:127.0/255.0 blue:0 alpha:1.0]];
	}
	else {
		[amountLabel setTextColor:[UIColor blackColor]];		
	}
	
	[self.amountFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[amountLabel setText:[self.amountFormatter stringFromNumber:[ERUtils absoluteDecimalNumber:record.amount]]];
}

- (void)reloadTotals {
	NSDecimalNumber *income = [self.dataProvider amountSumNegative:NO];
	NSDecimalNumber *expenses = [self.dataProvider amountSumNegative:YES];	
	NSDecimalNumber *balance = [income decimalNumberByAdding:expenses];
	
	[self.amountFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[self.incomeLabel setText:[self.amountFormatter stringFromNumber:income]];
	[self.expenseLabel setText:[self.amountFormatter stringFromNumber:[ERUtils absoluteDecimalNumber:expenses]]];
	[self.balanceLabel setText:[self.amountFormatter stringFromNumber:balance]];
}

- (void)showDeleteAll {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete all your records?" 
											delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes, Delete Everything" 
											otherButtonTitles:nil];
	[actionSheet setTag:DELETE_ALL_SHEET_TAG];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)showActions {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:@"Delete Everything" otherButtonTitles:@"Export to Mail", nil];
	[actionSheet setTag:ACTION_SHEET_TAG];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)createEmail {
	MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
	mailComposeViewController.mailComposeDelegate = self;
	
	NSArray *records = [self.dataProvider getAll];
	
	[self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
	
	[self.amountFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSUInteger fractionDigits = [amountFormatter minimumFractionDigits];
	
	[self.amountFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[self.amountFormatter setMinimumFractionDigits:fractionDigits];
	[self.amountFormatter setMaximumFractionDigits:fractionDigits];
	
	NSString* columnSeparator = @",";
	NSString* lineSeparator = @"\n";
	
	// For compatibility with countries where currency separator is comma.
	if ([[self.amountFormatter decimalSeparator] isEqualToString:@","]) {
		columnSeparator = @";";
	}
	
	NSMutableString *csv = [NSMutableString string];
	for (Record* record in records) {
		[csv appendString:[self.dateFormatter stringFromDate:record.transactionDate]];
		[csv appendString:columnSeparator];
		[csv appendString:[NSString stringWithFormat:@"\"%@\"", [record.title stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""]]];
		[csv appendString:columnSeparator];
		// This is a hack for Excel to recognize minus sign properly.
		[csv appendString:[[self.amountFormatter stringFromNumber:record.amount] stringByReplacingOccurrencesOfString:@"−" withString:@"-"]];
		[csv appendString:lineSeparator];
	}
	
	// This is a hack for Excel to recognize file as UTF-8.
	char BOM[] = {0xEF, 0xBB, 0xBF};
	NSMutableData *csvData = [NSMutableData data];
	[csvData appendBytes:BOM length:3];
	[csvData appendData:[csv dataUsingEncoding:NSUTF8StringEncoding]];
	
	[self.dateFormatter setDateFormat:@"yyyyMMdd"];
	[mailComposeViewController addAttachmentData:csvData mimeType:@"text/csv" fileName:[NSString stringWithFormat:@"BillyReport%@.csv", 
																						[self.dateFormatter stringFromDate:[ERUtils today]]]];
	[self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[mailComposeViewController setSubject:[NSString stringWithFormat:@"[Billy] Report for %@", [self.dateFormatter stringFromDate:[ERUtils today]]]];
	[mailComposeViewController setMessageBody:[NSString stringWithFormat:@"Billy report for %@ attached as CSV file.", 
											   [self.dateFormatter stringFromDate:[ERUtils today]]] isHTML:NO];
	[self presentModalViewController:mailComposeViewController animated:YES];
	
	[mailComposeViewController release];
}

#pragma mark -
#pragma mark UIViewController

- (id)initWithObjectContext:(NSManagedObjectContext *)managedObjectContext {
	if ((self = [super initWithNibName:nil bundle:nil])) {
		
		// Setup the navigation bar.
		[self setTitle:@"Everything"];
		
		self.navigationItem.leftBarButtonItem = self.editButtonItem;
		
		UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] 
										  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRecord)];
		self.navigationItem.rightBarButtonItem = addButtonItem;
		[addButtonItem release];
		
		// Create the amount formatter.
		NSNumberFormatter *tempAmountFormatter = [[NSNumberFormatter alloc] init];
		[self setAmountFormatter:tempAmountFormatter];
		[tempAmountFormatter release];
		
		// Configure the amount formatter.
		[self.amountFormatter setLocale:[NSLocale currentLocale]];
		[self.amountFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[self.amountFormatter setMaximum:[NSDecimalNumber maximumDecimalNumber]];
		
		// Create the date formatter.
		NSDateFormatter *tempDateformatter = [[NSDateFormatter alloc] init];
		[self setDateFormatter:tempDateformatter];
		[tempDateformatter release];
		
		// Setup data access.
		RecordDataProvider *tempDataProvider = [[RecordDataProvider alloc] initWithObjectContext:managedObjectContext];
		[self setDataProvider:tempDataProvider];
		[tempDataProvider release];
		
		[self.dataProvider setFetchedResultsDelegate:self];
	}
	return self;
}

- (void)loadView {
	[super loadView];
	
	// Setup the view.
	[self.view setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];

	// Create the table view.
	UITableView *tempRecordTableView = [[UITableView alloc] initWithFrame:
				CGRectMake(SPACE_FROM_THE_SIDES, 0, self.view.bounds.size.width-SPACE_FROM_THE_SIDES*2, 
						   self.view.bounds.size.height-BOTTOM_BAR_HEIGHT)];
	[self setRecordTableView:tempRecordTableView];
	[tempRecordTableView release];
	
	[self.recordTableView setDelegate:self];
	[self.recordTableView setDataSource:self];
	[self.recordTableView setAutoresizingMask:
					UIViewAutoresizingFlexibleWidth | 
					UIViewAutoresizingFlexibleHeight | 	 
					UIViewAutoresizingFlexibleTopMargin];
	[self.view addSubview:self.recordTableView];
	
	// Setup the table view.
	[self.recordTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.recordTableView setBackgroundColor:[UIColor clearColor]];
	
	// Hack to disable the floating header and footer behaviour of the plain style UITableView.
	[self.recordTableView setContentInset:UIEdgeInsetsMake(-SECTION_HEADER_HEIGHT, 0, -BOTTOM_BAR_HEIGHT, 0)];
	UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.recordTableView.bounds.size.width, SECTION_HEADER_HEIGHT)];
	[self.recordTableView setTableHeaderView:tableHeader];
	[tableHeader release];
	UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.recordTableView.bounds.size.width, BOTTOM_BAR_HEIGHT+SPACE_BETWEEN_SECTIONS)];
	[self.recordTableView setTableFooterView:tableFooter];
	[tableFooter release];
	
	// Setup the bottom bar, we're going to show our totals here.
	UIToolbar *bottomBar = [[UIToolbar alloc] 
							initWithFrame:CGRectMake(0, self.view.bounds.size.height-BOTTOM_BAR_HEIGHT, 
													 self.view.bounds.size.width, BOTTOM_BAR_HEIGHT)];
	[bottomBar setBarStyle:UIBarStyleBlack];
	[bottomBar setAutoresizingMask:
				 UIViewAutoresizingFlexibleWidth | 
				 UIViewAutoresizingFlexibleTopMargin];
	
	// Setup the labels for totals.
	UILabel *tempIncomeLabel = [[UILabel alloc] initWithFrame:CGRectMake((SPACE_FROM_THE_SIDES+TOTALS_IMAGE_SIZE+5)*1+TOTALS_LABEL_WIDTH*0, bottomBar.bounds.size.height/2-TOTALS_FONT_SIZE/2, TOTALS_LABEL_WIDTH, TOTALS_FONT_SIZE)];
	UILabel *tempExpenseLabel = [[UILabel alloc] initWithFrame:CGRectMake((SPACE_FROM_THE_SIDES+TOTALS_IMAGE_SIZE+5)*2+TOTALS_LABEL_WIDTH*1, bottomBar.bounds.size.height/2-TOTALS_FONT_SIZE/2, TOTALS_LABEL_WIDTH, TOTALS_FONT_SIZE)];
	UILabel *tempBalanceLabel = [[UILabel alloc] initWithFrame:CGRectMake((SPACE_FROM_THE_SIDES+TOTALS_IMAGE_SIZE+5)*3+TOTALS_LABEL_WIDTH*2, bottomBar.bounds.size.height/2-TOTALS_FONT_SIZE/2, TOTALS_LABEL_WIDTH, TOTALS_FONT_SIZE)];

	[self setIncomeLabel:tempIncomeLabel];
	[self setExpenseLabel:tempExpenseLabel];
	[self setBalanceLabel:tempBalanceLabel];
	
	[tempIncomeLabel release];
	[tempExpenseLabel release];
	[tempBalanceLabel release];
	
	// Set the UI properties for labels.
	[self.incomeLabel setBackgroundColor:[UIColor clearColor]];
	[self.expenseLabel setBackgroundColor:[UIColor clearColor]];
	[self.balanceLabel setBackgroundColor:[UIColor clearColor]];
	
	[self.incomeLabel setTextColor:[UIColor whiteColor]];
	[self.expenseLabel setTextColor:[UIColor whiteColor]];
	[self.balanceLabel setTextColor:[UIColor whiteColor]];
	
	[self.incomeLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
	[self.expenseLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
	[self.balanceLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
	
	UIColor *shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
	[self.incomeLabel setShadowColor:shadowColor];
	[self.expenseLabel setShadowColor:shadowColor];
	[self.balanceLabel setShadowColor:shadowColor];
	
	[self.incomeLabel setShadowOffset:CGSizeMake(0, -1)];
	[self.expenseLabel setShadowOffset:CGSizeMake(0, -1)];
	[self.balanceLabel setShadowOffset:CGSizeMake(0, -1)];
	
	[self.incomeLabel setAdjustsFontSizeToFitWidth:YES];
	[self.expenseLabel setAdjustsFontSizeToFitWidth:YES];
	[self.balanceLabel setAdjustsFontSizeToFitWidth:YES];
	
	[bottomBar addSubview:self.incomeLabel];
	[bottomBar addSubview:self.expenseLabel];
	[bottomBar addSubview:self.balanceLabel];
	
	// Setup the icons for totals.
	UIImageView *incomeImage = [[UIImageView alloc] initWithFrame:CGRectMake(SPACE_FROM_THE_SIDES*1+(TOTALS_IMAGE_SIZE+SPACE_FROM_THE_SIDES/2+TOTALS_LABEL_WIDTH)*0, bottomBar.bounds.size.height/2-TOTALS_IMAGE_SIZE/2, TOTALS_IMAGE_SIZE, TOTALS_IMAGE_SIZE)];
	UIImageView *expenseImage = [[UIImageView alloc] initWithFrame:CGRectMake(SPACE_FROM_THE_SIDES*2+(TOTALS_IMAGE_SIZE+SPACE_FROM_THE_SIDES/2+TOTALS_LABEL_WIDTH)*1, bottomBar.bounds.size.height/2-TOTALS_IMAGE_SIZE/2, TOTALS_IMAGE_SIZE, TOTALS_IMAGE_SIZE)];
	UIImageView *balanceImage = [[UIImageView alloc] initWithFrame:CGRectMake(SPACE_FROM_THE_SIDES*3+(TOTALS_IMAGE_SIZE+SPACE_FROM_THE_SIDES/2+TOTALS_LABEL_WIDTH)*2, bottomBar.bounds.size.height/2-TOTALS_IMAGE_SIZE/2, TOTALS_IMAGE_SIZE, TOTALS_IMAGE_SIZE)];
	
	[incomeImage setImage:[UIImage imageNamed:@"Income.png"]];
	[expenseImage setImage:[UIImage imageNamed:@"Expenses.png"]];
	[balanceImage setImage:[UIImage imageNamed:@"Balance.png"]];
	
	[bottomBar addSubview:incomeImage];
	[bottomBar addSubview:expenseImage];
	[bottomBar addSubview:balanceImage];
	
	[incomeImage release];
	[expenseImage release];
	[balanceImage release];
	
	// Setup the rest of the bottom bar.
	UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	UIBarButtonItem *tempActionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions)];
	[self setActionButtonItem:tempActionButtonItem];
	[tempActionButtonItem release];
	
	[bottomBar setItems:[NSArray arrayWithObjects:flexibleSpaceItem, self.actionButtonItem, nil]];
	[flexibleSpaceItem release];
	
	[self.view addSubview:bottomBar];
	[bottomBar release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self reloadTotals];
	[self.dataProvider fetchData];
	[self.actionButtonItem setEnabled:[[self.dataProvider sections] count] > 0];
}

- (void)viewWillAppear {
	[self.recordTableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.recordTableView setEditing:editing animated:animated];
}

#pragma mark -
#pragma mark EditRecordViewControllerDelegate

- (void)editRecordViewController:(EditRecordViewController *)controller didFinishWithSave:(BOOL)save {
	
	// Check if used saved on the edit record view.
	if (save) {
		[self.dataProvider saveChanges];
		[self.actionButtonItem setEnabled:YES];
		[self reloadTotals];
	}
	else {
		[self.dataProvider cancelChanges];
	}
	
	// Slides the add record view out from display.
	[self dismissModalViewControllerAnimated:YES];
	
	[self.recordTableView deselectRowAtIndexPath:self.recordTableView.indexPathForSelectedRow animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.dataProvider sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[self.dataProvider sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSString *rawDateString = [[[self.dataProvider sections] objectAtIndex:section] name];
	
	// Convert rawDateString string to NSDate.
	[self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
	NSDate *date = [self.dateFormatter dateFromString:rawDateString];
	
	// Convert NSDate to format we want.
	[self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
	NSString *formattedDateString = [self.dateFormatter stringFromDate:date];
	
	return formattedDateString;  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"RecordCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		cell = [self createCellWithIdentifier:cellIdentifier];
    }
    
	// Setup the table cell.
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		[self.dataProvider deleteObjectAtIndexPath:indexPath];
		[self.actionButtonItem setEnabled:[[self.dataProvider sections] count] > 0];
		[self reloadTotals];
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self editRecordWithObject:(Record *)[self.dataProvider objectAtIndexPath:indexPath]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ROW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SECTION_HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return SECTION_FOOTER_IMAGE_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.recordTableView.frame.size.width, SECTION_HEADER_HEIGHT)] autorelease];
	
	UIView *headerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, SPACE_BETWEEN_SECTIONS, headerView.bounds.size.width, SECTION_HEADER_IMAGE_HEIGHT)];
	[headerBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Header.png"]]];
	[headerBackgroundView setOpaque:NO];
	[headerView addSubview:headerBackgroundView];
	[headerBackgroundView release];
	
	UIView *headerLabelContainer = [[UIView alloc] initWithFrame:
									CGRectMake(0, SPACE_BETWEEN_SECTIONS+SECTION_HEADER_IMAGE_HEIGHT, headerView.bounds.size.width, TABLE_PADDING+SECTION_HEADER_LABEL_HEIGHT)];
	[headerLabelContainer setBackgroundColor:[UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0]];
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:
							CGRectMake(TABLE_PADDING, TABLE_PADDING, headerLabelContainer.bounds.size.width-TABLE_PADDING*2, SECTION_HEADER_LABEL_HEIGHT)];
	[headerLabel setText:[self tableView:tableView titleForHeaderInSection:section]];
	[headerLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:SECTION_HEADER_FONT_SIZE]];
	[headerLabel setBackgroundColor:[UIColor clearColor]];
	[headerLabel setShadowColor:[UIColor whiteColor]];
	[headerLabel setShadowOffset:CGSizeMake(0, 1)];
	[headerLabelContainer addSubview:headerLabel];
	
	[headerView addSubview:headerLabelContainer];
	
	[headerLabelContainer release];
	[headerLabel release];
	
	return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView* footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, SECTION_FOOTER_IMAGE_HEIGHT)] autorelease];
	[footerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Footer.png"]]];
	[footerView setOpaque:NO];
	return footerView;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self setEditing:YES animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self setEditing:NO animated:YES];
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.recordTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.recordTableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject 
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.recordTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.recordTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[self.recordTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.recordTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.recordTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo 
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.recordTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.recordTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (actionSheet.tag) {
		case ACTION_SHEET_TAG:
			if (buttonIndex == 0) {
				[self showDeleteAll];
			}
			else if (buttonIndex == 1) {
				[self createEmail];
			}
			break;
		case DELETE_ALL_SHEET_TAG:
			if (buttonIndex == 0) {
				[self.dataProvider deleteAll];
				[self.actionButtonItem setEnabled:NO];
				[self reloadTotals];
			}
			break;

		default:
			break;
	}
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[recordTableView release];
	[incomeLabel release];
	[expenseLabel release];
	[balanceLabel release];
	[actionButtonItem release];
	
	[amountFormatter release];
	[dateFormatter release];
	
	[dataProvider release];
	 
    [super dealloc];
}

@end

