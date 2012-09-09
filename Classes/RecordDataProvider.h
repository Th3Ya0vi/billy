//
//  RecordDataProvider.h
//  Billy
//
//  Created by Eugenijus on 2010-12-27.
//  Copyright 2010 Eugenijus Radlinskas. All rights reserved.
//

#import "Record.h"

@interface RecordDataProvider : NSObject {
	NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
	NSManagedObjectContext *addingManagedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *addingManagedObjectContext;

- (id)initWithObjectContext:(NSManagedObjectContext *)objectContext;
- (void)setFetchedResultsDelegate:(id<NSFetchedResultsControllerDelegate>)delegate;
- (NSArray *)getSortDescriptors;

- (Record *)objectAtIndexPath:(NSIndexPath *)indexPath;
- (Record *)createObject;
- (void)deleteObjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)deleteAll;
- (NSArray *)sections;
- (NSDecimalNumber *)amountSumNegative:(BOOL)negative;
- (NSArray *)getAll;

- (void)fetchData;
- (void)saveChanges;
- (void)cancelChanges;

- (void)handleError:(NSError *)error;

- (void)addingControllerContextDidSave:(NSNotification*)saveNotification;

@end
