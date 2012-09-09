//
//  EditRecordViewController.m
//  Billy
//
//  Created by Eugenijus on 2010-12-23.
//  Copyright 2010 Eugenijus Radlinskas. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EditRecordViewController.h"
#import "ERUtils.h"
#import "ERPalette.h"

#define SIGN_BUTTON_SIZE 30
#define DATE_PICKER_HEIGHT 216
#define PADDING 15

#define DATE_FONT_SIZE 19
#define TITLE_FONT_SIZE 24
#define DATE_BUTTON_HEIGHT 44
#define TITLE_MAX_LENGTH 255

#define TITLE_FIELD_HEIGHT (TITLE_FONT_SIZE+PADDING*2)

@implementation EditRecordViewController

@synthesize delegate, dateFormatter, amountFormatter, record, isPositive, 
			saveButtonItem, titleField, amountField, dateButton, datePicker, signButton;

#pragma mark -
#pragma mark Property overrides

- (void)setIsPositive:(BOOL)value {
	isPositive = value;
	
	[self.signButton setBackgroundImage:[UIImage imageNamed:isPositive ? @"Positive.png" : @"Negative.png"] 
							   forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Class methods

- (void)changeDate:(UIDatePicker *)sender {
	[self.dateButton setTitle:[self.dateFormatter stringFromDate:[self.datePicker date]] forState:UIControlStateNormal];
	
	// Animate only when selected by user from the picker.
	if (sender != nil) {
		[UIView beginAnimations:@"changedDate" context:nil];
		[UIView setAnimationDuration:1.0f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[self.dateButton setAlpha:0.5];
		[self.dateButton setAlpha:1.0];
		[UIView commitAnimations];
	}
}

- (void)cancel {
	[delegate editRecordViewController:self didFinishWithSave:NO];
}

- (void)save {
	
	NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[[amountFormatter numberFromString:self.amountField.text] decimalValue]];
	if (!self.isPositive) {
		amount = [ERUtils invertDecimalNumber:amount];
	}
	
	// Set the record attributes from UI.
	[self.record setTitle:(self.titleField.text == nil || [self.titleField.text isEqual:@""]) ? @"Untitled" : self.titleField.text];
	[self.record setAmount:amount];
	[self.record setTransactionDate:self.datePicker.date];
	if (self.record.creationDate == nil) {
		[self.record setCreationDate:[NSDate date]];
	}
	
	[delegate editRecordViewController:self didFinishWithSave:YES];
}

- (void)loadData {
	
	if (self.record.creationDate != nil) {
		[self setTitle:@"Edit item"];
		
		[self.titleField setText:record.title];
		[self.amountField setText:[self.amountFormatter stringFromNumber:[ERUtils absoluteDecimalNumber:record.amount]]];
		[self.datePicker setDate:record.transactionDate];
		[self setIsPositive:([record.amount compare:[NSDecimalNumber zero]] == NSOrderedDescending)];
	}
	else {
		[self setTitle:@"New item"];
		
		[self.datePicker setDate:[ERUtils today]];
	}
	
	// Fire the date picker change date event manually.
	[self changeDate:nil];
}

- (void)showDatePicker:(UIButton *)sender {
	
	[self.titleField resignFirstResponder];
	[self.amountField resignFirstResponder];
}

- (void)toggleSign:(UIButton *)sender {
	[self setIsPositive:!isPositive];
}

- (BOOL)isFormFilled {
	return self.amountField.text.length > 0;
}

- (void)checkFieldContents:(UITextField *)sender {
	
	// Limit title field length.
	if (sender == self.titleField && [sender.text length] > TITLE_MAX_LENGTH) {
		sender.text = [sender.text substringToIndex:TITLE_MAX_LENGTH];
	}
	
	[self.saveButtonItem setEnabled:[self isFormFilled]];
}

#pragma mark -
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		// Setup the navigation bar.
		UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] 
											 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
		self.navigationItem.leftBarButtonItem = cancelButtonItem;
		[cancelButtonItem release];		
		
		UIBarButtonItem *tempSaveButtonItem = [[UIBarButtonItem alloc] 
										   initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
		[self setSaveButtonItem:tempSaveButtonItem];
		[tempSaveButtonItem release];
		
		self.navigationItem.rightBarButtonItem = self.saveButtonItem;
		[self.saveButtonItem setEnabled:NO];
		
		// Create the date formatter.
		NSDateFormatter *tempDateFormatter = [[NSDateFormatter alloc] init];
		[self setDateFormatter:tempDateFormatter];
		[tempDateFormatter release];
		
		// Create the amount formatter.
		NSNumberFormatter *tempAmountFormatter = [[NSNumberFormatter alloc] init];
		[self setAmountFormatter:tempAmountFormatter];
		[tempAmountFormatter release];
		
		[self.amountFormatter setLocale:[NSLocale currentLocale]];
		
		// Retrieve the minimum fraction digits for currency style.
		[self.amountFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		NSUInteger fractionDigits = [amountFormatter minimumFractionDigits];
		
		// Assign it to our decimal style.
		[self.amountFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[self.amountFormatter setMinimumFractionDigits:fractionDigits];
		[self.amountFormatter setMaximumFractionDigits:fractionDigits];
		[self.amountFormatter setMaximum:[NSDecimalNumber maximumDecimalNumber]];
	}
	return self;
}

- (void)loadView {
	[super loadView];
	
	// Create UI elements that we're going to instantly release.
	UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-DATE_PICKER_HEIGHT-TITLE_FIELD_HEIGHT, self.view.bounds.size.width, TITLE_FIELD_HEIGHT)];
	UIView *amountView = [[UIView alloc] initWithFrame:CGRectMake(0, DATE_BUTTON_HEIGHT, self.view.bounds.size.width, 
													self.view.bounds.size.height-(DATE_PICKER_HEIGHT+DATE_BUTTON_HEIGHT+TITLE_FIELD_HEIGHT+1))];
	
	// Create UI elements that we're going to hold on to.
	UIButton *tempDateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, DATE_BUTTON_HEIGHT)];
	[self setDateButton:tempDateButton];
	[tempDateButton release];
	
	UITextField *tempTitleField = [[UITextField alloc] initWithFrame:CGRectMake(PADDING, 0, titleView.bounds.size.width-PADDING*2, titleView.bounds.size.height)];
	[self setTitleField:tempTitleField];
	[tempTitleField release];
	
	UITextField *tempAmountField = [[UITextField alloc] initWithFrame:
									CGRectMake(PADDING*2+SIGN_BUTTON_SIZE, 0, amountView.bounds.size.width-(PADDING*3+SIGN_BUTTON_SIZE), amountView.bounds.size.height)];
	[self setAmountField:tempAmountField];
	[tempAmountField release];
	
	UIButton *tempSignButton = [[UIButton alloc] initWithFrame:CGRectMake(PADDING, amountView.bounds.size.height/2-SIGN_BUTTON_SIZE/2, 
																	  SIGN_BUTTON_SIZE, SIGN_BUTTON_SIZE)];
	[self setSignButton:tempSignButton];
	[tempSignButton release];
	
	UIDatePicker *tempDatePicker = [[UIDatePicker alloc] initWithFrame:
									CGRectMake(0, self.view.bounds.size.height-DATE_PICKER_HEIGHT, self.view.bounds.size.width, DATE_PICKER_HEIGHT)];
	[self setDatePicker:tempDatePicker];
	[tempDatePicker release];
	
	// Customize the UI elements.
	[self.view setBackgroundColor:[ERPalette editRecordViewBackground]];
	
	[self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
	
	[[self.dateButton titleLabel] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:DATE_FONT_SIZE]];
	[[self.dateButton titleLabel] setShadowOffset:CGSizeMake(-1, -1)];
	[self.dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.dateButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] forState:UIControlStateNormal];
	[self.dateButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[self.dateButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, PADDING, 0.0, PADDING)];
	[self.dateButton addTarget:self action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
	UIImage *dateButtonBackground = [UIImage imageNamed:@"Date.png"];
	[dateButtonBackground stretchableImageWithLeftCapWidth:1 topCapHeight:DATE_BUTTON_HEIGHT];
	[self.dateButton setBackgroundImage:dateButtonBackground forState:UIControlStateNormal];
	[self.dateButton setAutoresizingMask:
	 UIViewAutoresizingFlexibleWidth];
	
	[titleView setBackgroundColor:[UIColor blackColor]];
	[titleView setAutoresizingMask:
	 UIViewAutoresizingFlexibleWidth | 
	 UIViewAutoresizingFlexibleTopMargin];
	
	[self.titleField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[self.titleField setTextColor:[UIColor whiteColor]];
	[self.titleField setBackgroundColor:[UIColor blackColor]];
	[self.titleField setFont:[UIFont fontWithName:@"Helvetica" size:TITLE_FONT_SIZE]];
	[self.titleField setTextAlignment:UITextAlignmentLeft];
	[self.titleField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[self.titleField setPlaceholder:@"Title"];
	[self.titleField setReturnKeyType:UIReturnKeyDone];
	[self.titleField setEnablesReturnKeyAutomatically:YES];
	[self.titleField addTarget:self action:@selector(checkFieldContents:) forControlEvents:UIControlEventAllEditingEvents];
	[self.titleField setDelegate:self];
	
	[amountView setBackgroundColor:[UIColor blackColor]];
	[amountView setAutoresizingMask:
	 UIViewAutoresizingFlexibleWidth | 
	 UIViewAutoresizingFlexibleHeight];
	CAGradientLayer *amountViewGradient = [CAGradientLayer layer];
	amountViewGradient.frame = amountView.bounds;
	amountViewGradient.colors = [NSArray arrayWithObjects:
								  (id)[[UIColor colorWithRed:51.0/255.0 green:53.0/255.0 blue:57.0/255.0 alpha:1.0] CGColor], 
								  (id)[[UIColor blackColor] CGColor], 
								  (id)[[UIColor blackColor] CGColor], 								 
								  nil];
	[amountView.layer insertSublayer:amountViewGradient atIndex:0];
	[amountView.layer setMasksToBounds:YES];
	
	[self.amountField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[self.amountField setTextColor:[UIColor whiteColor]];
	[self.amountField setBackgroundColor:[UIColor blackColor]];
	[self.amountField setKeyboardType:UIKeyboardTypeNumberPad];
	[self.amountField setFont:[UIFont fontWithName:@"Helvetica-Bold" size:amountView.bounds.size.height-PADDING*5]];
	[self.amountField setTextAlignment:UITextAlignmentRight];
	[self.amountField setAdjustsFontSizeToFitWidth:YES];
	[self.amountField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[self.amountField setPlaceholder:[amountFormatter stringFromNumber:[NSNumber numberWithInt:0]]];
	[self.amountField addTarget:self action:@selector(checkFieldContents:) forControlEvents:UIControlEventAllEditingEvents];
	[self.amountField setDelegate:self];
	[self.amountField setAutoresizingMask:
	 UIViewAutoresizingFlexibleWidth | 
	 UIViewAutoresizingFlexibleHeight];
	[self.amountField becomeFirstResponder];
	
	CAGradientLayer *amountFieldGradient = [CAGradientLayer layer];
	amountFieldGradient.frame = self.amountField.bounds;
	amountFieldGradient.colors = [NSArray arrayWithObjects:
								 (id)[[UIColor colorWithRed:51.0/255.0 green:53.0/255.0 blue:57.0/255.0 alpha:1.0] CGColor], 
								 (id)[[UIColor blackColor] CGColor], 
								 (id)[[UIColor blackColor] CGColor], 
								 nil];
	[self.amountField.layer insertSublayer:amountFieldGradient atIndex:0];
	[self.amountField.layer setMasksToBounds:YES];
	
	[self.signButton setBackgroundColor:[UIColor clearColor]];
	[self.signButton setBackgroundImage:[UIImage imageNamed:@"Negative.png"] forState:UIControlStateNormal];
	[self.signButton addTarget:self action:@selector(toggleSign:) forControlEvents:UIControlEventTouchUpInside];
	[self.signButton setAutoresizingMask:
	 UIViewAutoresizingFlexibleTopMargin | 
	 UIViewAutoresizingFlexibleBottomMargin];
	
	[self.datePicker setDatePickerMode:UIDatePickerModeDate];
	[self.datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
	[self.datePicker setAutoresizingMask:
	 UIViewAutoresizingFlexibleWidth | 
	 UIViewAutoresizingFlexibleTopMargin];
	
	// Create UI elemement hierarchy.
	[amountView addSubview:self.amountField];
	[amountView addSubview:self.signButton];
	[titleView addSubview:self.titleField];
	[self.view addSubview:self.dateButton];
	[self.view addSubview:self.datePicker];
	[self.view addSubview:titleView];
	[self.view addSubview:amountView];
	
	// Release the unnecessary objects.
	[titleView release];
	[amountView release];
	
	// Load record data if it was assigned.
	[self loadData];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if (textField == self.amountField) {
		
		NSString *currentNumericValue = 
			[[textField.text 
			  stringByReplacingOccurrencesOfString:[self.amountFormatter currencyDecimalSeparator] withString:@""] 
			  stringByReplacingOccurrencesOfString:[self.amountFormatter currencyGroupingSeparator] withString:@""];
		
		string = [[string 
				stringByReplacingOccurrencesOfString:[self.amountFormatter currencyDecimalSeparator] withString:@""] 
				stringByReplacingOccurrencesOfString:[self.amountFormatter currencyGroupingSeparator] withString:@""];
		
		if (string.length > 0) {
			
			if ([amountFormatter numberFromString:string] == nil) {
				// Input is not a number.
				return NO;
			}
			
			// Number tapped.
			
			if (textField.text.length == 0) {
				// New number from scratch.
				
				NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[[self.amountFormatter numberFromString:string] decimalValue]];
				amount = [amount decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithMantissa:pow(10, [self.amountFormatter minimumFractionDigits]) exponent:0 isNegative:NO]];
				
				[textField setText:[self.amountFormatter stringFromNumber:amount]];
			}
			else {
				// Append to an existing number.
				
				NSMutableString *result = [[NSMutableString alloc] initWithString:currentNumericValue];
				[result appendString:string];
				[result insertString:[self.amountFormatter currencyDecimalSeparator] atIndex:result.length-[self.amountFormatter minimumFractionDigits]];
				
				[textField setText:[self.amountFormatter stringFromNumber:[self.amountFormatter numberFromString:result]]];
				[result release];
			}
		}
		else {
			// Backspace tapped.
			
			if (textField.text.length > 0) {
				// Erase last number.
				
				NSMutableString *result = [[NSMutableString alloc] initWithString: [currentNumericValue substringToIndex:currentNumericValue.length-1]];
				[result insertString:[self.amountFormatter currencyDecimalSeparator] atIndex:result.length-[self.amountFormatter minimumFractionDigits]];
				
				NSNumber *number = [self.amountFormatter numberFromString:result];
				if ([number isEqualToNumber:[NSNumber numberWithInt:0]]) {
					[textField setText:@""];
				}
				else {
					[textField setText:[self.amountFormatter stringFromNumber:number]];
				}

				[result release];
			}
		}
		return NO;
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if (textField == self.titleField) {
		if ([self isFormFilled]) {
			// Submit form.
			[self save];
		}
		else {
			// Jump to amount field.
			[self.amountField becomeFirstResponder];
		}
		return NO;
	}
	return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[dateFormatter release];
	[amountFormatter release];
	[record release];
	[saveButtonItem release];
	[titleField release];
	[amountField release];
	[dateButton release];
	[datePicker release];
	[signButton release];
	
    [super dealloc];
}

@end
