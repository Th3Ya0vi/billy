//
//  Record.h
//  Billy
//
//  Created by Eugenijus on 2010-12-25.
//  Copyright 2010 Eugenijus Radlinskas. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Record :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * transactionDate;

@end



