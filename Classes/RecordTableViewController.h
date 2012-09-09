//
//  RecordTableViewController.h
//  Billy
//
//  Created by Eugenijus on 2010-12-23.
//  Copyright 2010 Eugenijus Radlinskas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "EditRecordViewController.h"
#import "RecordDataProvider.h"

@interface RecordTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, 
	NSFetchedResultsControllerDelegate, EditRecordViewControllerDelegate, UIActionSheetDelegate, 
	MFMailComposeViewControllerDelegate> {
		
	UITableView *recordTableView;
	UILabel *incomeLabel;
	UILabel *expenseLabel;
	UILabel *balanceLabel;
	UIBarButtonItem *actionButtonItem;
															
	NSDateFormatter *dateFormatter;
	NSNumberFormatter *amountFormatter;
															
	RecordDataProvider *dataProvider;
}

@property (nonatomic, retain) UITableView *recordTableView;
@property (nonatomic, retain) UILabel *incomeLabel;
@property (nonatomic, retain) UILabel *expenseLabel;
@property (nonatomic, retain) UILabel *balanceLabel;
@property (nonatomic, retain) UIBarButtonItem *actionButtonItem;

@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSNumberFormatter *amountFormatter;

@property (nonatomic, retain) RecordDataProvider *dataProvider;

- (id)initWithObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
