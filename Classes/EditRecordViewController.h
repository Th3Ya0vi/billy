//
//  EditRecordViewController.h
//  Billy
//
//  Created by Eugenijus on 2010-12-23.
//  Copyright 2010 Eugenijus Radlinskas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Record.h"

@protocol EditRecordViewControllerDelegate;

@interface EditRecordViewController : UIViewController<UITextFieldDelegate> {
	id<EditRecordViewControllerDelegate> delegate;
	
	NSDateFormatter *dateFormatter;
	NSNumberFormatter *amountFormatter;
	
	Record *record;
	BOOL isPositive;
	
	UIBarButtonItem *saveButtonItem;
	UITextField *titleField;
	UITextField *amountField;
	UIButton *dateButton;
	UIDatePicker *datePicker;
	UIButton *signButton;
}

@property (nonatomic, assign) id<EditRecordViewControllerDelegate> delegate;

@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSNumberFormatter *amountFormatter;

@property (nonatomic, retain) Record *record;
@property (nonatomic, assign) BOOL isPositive;

@property (nonatomic, retain) UIBarButtonItem *saveButtonItem;
@property (nonatomic, retain) UITextField *titleField;
@property (nonatomic, retain) UITextField *amountField;
@property (nonatomic, retain) UIButton *dateButton;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIButton *signButton;

@end

@protocol EditRecordViewControllerDelegate
- (void)editRecordViewController:(EditRecordViewController *)controller didFinishWithSave:(BOOL)save;
@end
