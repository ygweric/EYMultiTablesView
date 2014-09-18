//
//  MultiTablesView.h
//  MultiTablesView
//
//  Created by Zouhair on 20/06/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MultiTablesView;


/** @name MultiTablesViewDataSource protocol */
#pragma mark - MultiTablesViewDataSource protocol
@protocol MultiTablesViewDataSource <NSObject>

@optional
/** @name Levels */
#pragma mark Levels
- (BOOL)hasSubTableViewInMultiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray *)indexPaths indexPath:(NSIndexPath *)indexPath;
/** 
 @name indexPaths.count == current level
 */
#pragma mark Sections
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView numberOfSectionsAtIndexPaths:(NSArray*)indexPaths;

/** @name Sections Headers & Footers */
#pragma mark Sections Headers & Footers
- (NSString *)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths titleForHeaderInSection:(NSInteger)section;
- (NSString *)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths titleForFooterInSection:(NSInteger)section;

/** @name Fixed Table Headers */
#pragma mark Fixed Table Headers
- (NSString *)multiTablesView:(MultiTablesView *)multiTablesView titleForFixedTableHeaderViewAtIndexPaths:(NSArray*)indexPaths;

/** @name Edit rows */
#pragma mark Edit rows
- (BOOL)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths canEditRowAtIndexPath:(NSIndexPath *)indexPath;

@required
/** @name Rows */
#pragma mark Rows
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


/** @name MultiTablesViewDelegate protocol */
#pragma mark - MultiTablesViewDelegate protocol
@protocol MultiTablesViewDelegate <NSObject>

@optional
/** @name Levels */
#pragma mark Levels
- (void)multiTablesView:(MultiTablesView *)multiTablesView levelDidChangeAtIndexPaths:(NSArray*)indexPaths;

/** @name Sections Headers & Footers */
#pragma mark Sections Headers & Footers
- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths heightForHeaderInSection:(NSInteger)section;
- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths heightForFooterInSection:(NSInteger)section;
- (UIView *)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths viewForHeaderInSection:(NSInteger)section;
- (UIView *)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths viewForFooterInSection:(NSInteger)section;

/** @name Rows */
#pragma mark Rows
- (UITableViewCellSeparatorStyle)multiTablesView:(MultiTablesView *)multiTablesView separatorStyleForIndexPaths:(NSArray*)indexPaths;
- (void)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)multiTablesView:(MultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

/** @name Fixed Table Headers */
#pragma mark Fixed Table Headers
- (UIView *)multiTablesView:(MultiTablesView *)multiTablesView fixedTableHeaderViewAtIndexPaths:(NSArray*)indexPaths;

/** @name Table Headers */
#pragma mark Table Headers
- (UIView *)multiTablesView:(MultiTablesView *)multiTablesView tableHeaderViewAtIndexPaths:(NSArray*)indexPaths;

@end


/** @name MultiTablesView interface */
#pragma mark - MultiTablesView interface
@interface MultiTablesView : UIView

/** @name Properties */
#pragma mark Properties
@property (nonatomic, weak) IBOutlet id<MultiTablesViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<MultiTablesViewDelegate> delegate;

@property (nonatomic, weak, readonly) UITableView *currentTableView;
@property (nonatomic, assign,readwrite) NSUInteger currentTableViewIndex;

@property (nonatomic, assign) BOOL automaticPush;
@property (nonatomic, assign) CGFloat nextTableViewHorizontalGap;



/** @name Reload Datas */
#pragma mark Reload Datas
- (void)initTableViewData;
- (void)reloadDataAtIndexPaths:(NSArray*)indexPaths;
- (UITableViewCell *)dequeueReusableCellForLevel:(NSInteger)level withIdentifier:(NSString *)identifier;

/** @name Levels Details */
#pragma mark Levels Details
- (NSInteger)numberOfLevels;
- (NSIndexPath *)indexPathForSelectedRowAtLevel:(NSInteger)level;
- (UITableView *)tableViewAtLevel:(NSInteger)level ;

/** @name Push Level */
#pragma mark Push Level
-(void)pushNextTableView:(UITableView*)tableView;

/** @name Pop Levels */
#pragma mark Pop Levels
- (void)popCurrentTableViewAnimated:(BOOL)animated;

@end
