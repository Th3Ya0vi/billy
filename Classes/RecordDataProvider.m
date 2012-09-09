//
//  RecordDataProvider.m
//  Billy
//
//  Created by Eugenijus on 2010-12-27.
//  Copyright 2010 Eugenijus Radlinskas. All rights reserved.
//

#import "RecordDataProvider.h"

@implementation RecordDataProvider

@synthesize fetchedResultsController, managedObjectContext, addingManagedObjectContext;

#pragma mark -
#pragma mark Property overrides

- (NSFetchedResultsController *)fetchedResultsController {
	
	// Check whether it's not already set.
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
	
	// Create and configure a fetch request with the Record entity.
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Record" inManagedObjectContext:self.managedObjectContext]];
	[request setSortDescriptors:[self getSortDescriptors]];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *tempFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
																		managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"transactionDate" cacheName:@"Records"];
	self.fetchedResultsController = tempFetchedResultsController;
	
	// Memory management.
	[tempFetchedResultsController release];
	[request release];
	
	return fetchedResultsController;
}

#pragma mark -
#pragma mark Class methods

- (id)initWithObjectContext:(NSManagedObjectContext *)objectContext {
	if ((self = [super init])) {
		[self setManagedObjectContext:objectContext];
	}
	return self;
}

- (void)setFetchedResultsDelegate:(id<NSFetchedResultsControllerDelegate>)delegate {
	[self.fetchedResultsController setDelegate:delegate];
}

- (NSArray *)getSortDescriptors {
	NSSortDescriptor *creationDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
	NSSortDescriptor *transactionDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"transactionDate" ascending:NO];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:transactionDateDescriptor, creationDateDescriptor, nil];
	
	[creationDateDescriptor release];
	[transactionDateDescriptor release];
	
	return [sortDescriptors autorelease];
}

- (Record *)objectAtIndexPath:(NSIndexPath *)indexPath {
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (Record *)createObject {
	
	// Create a separate data context for adding new record.
	NSManagedObjectContext *tempAddingManagedObjectContext = [[NSManagedObjectContext alloc] init];
	[self setAddingManagedObjectContext:tempAddingManagedObjectContext];
	[tempAddingManagedObjectContext release];
	
	[self.addingManagedObjectContext setPersistentStoreCoordinator:[[self.fetchedResultsController managedObjectContext] persistentStoreCoordinator]];
	
	return (Record *)[NSEntityDescription insertNewObjectForEntityForName:@"Record" inManagedObjectContext:self.addingManagedObjectContext];
}

- (void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	[context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
	
	NSError *error;
	if (![context save:&error]) {
		[self handleError:error];
	}
}

- (void)deleteAll {
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Record" inManagedObjectContext:context]];
	
	NSArray *result = [context executeFetchRequest:request error:nil];
	for (id record in result) {
		[context deleteObject:record];
	}
	
	NSError *error;
	if (![context save:&error]) {
		[self handleError:error];
	}
	
	[request release];
}

- (NSArray *)sections {
	return [self.fetchedResultsController sections];
}

- (NSDecimalNumber *)amountSumNegative:(BOOL)negative {
	NSDecimalNumber *result = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Record" inManagedObjectContext:[self managedObjectContext]]];
	[request setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"amount %@ 0", negative ? @"<" : @">"]]];
	[request setResultType:NSDictionaryResultType];
	
	NSExpression *sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"amount"]]];
	NSExpressionDescription *sumExpressionDescription = [[NSExpressionDescription alloc] init];
	[sumExpressionDescription setName:@"income"];
	[sumExpressionDescription setExpression:sumExpression];
	[sumExpressionDescription setExpressionResultType:NSDecimalAttributeType];
	
	[request setPropertiesToFetch:[NSArray arrayWithObject:sumExpressionDescription]];
	
	NSError *error;
	NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
	if (results != nil && results.count > 0) {
		result = (NSDecimalNumber *)[[results objectAtIndex:0] valueForKey:@"income"];
	}
	else {
		[self handleError:error];
	}
	
	[sumExpressionDescription release];
	[request release];
	
	return result;
}

- (void)fetchData {
	
	NSError *error;
	if (![self.fetchedResultsController performFetch:&error]) {
		[self handleError:error];
	}	
}

- (NSArray *)getAll {
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Record" inManagedObjectContext:context]];
	[request setSortDescriptors:[self getSortDescriptors]];
	
	NSArray *results = [context executeFetchRequest:request error:nil];
	
	[request release];
	
	return results;
}

- (void)saveChanges {
	
	// Check if we added a new record.
	if (self.addingManagedObjectContext != nil) {
		
		// Save the record to database and set the callback for merging the adding context with the main context.
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(addingControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.addingManagedObjectContext];
		
		NSError *error;
		if (![self.addingManagedObjectContext save:&error]) {
			[self handleError:error];
		}
		
		[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.addingManagedObjectContext];
		
		[self setAddingManagedObjectContext:nil];
	}
	else {
		
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			[self handleError:error];
		}
	}
}

- (void)cancelChanges {
	
	// Nilify the separate adding context if it's present.
	if (self.addingManagedObjectContext != nil) {
		[self setAddingManagedObjectContext:nil];
	}
}

- (void)handleError:(NSError *)error {
	
	// TODO: Add proper error handling code.
	NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	exit(-1);
}

- (void)addingControllerContextDidSave:(NSNotification*)saveNotification {
	
	// Merging the changes from the adding context to main context.
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	[context mergeChangesFromContextDidSaveNotification:saveNotification];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[fetchedResultsController release];
	[managedObjectContext release];
	[addingManagedObjectContext release];
	
    [super dealloc];
}

@end
