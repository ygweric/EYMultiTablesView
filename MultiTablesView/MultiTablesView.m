//
//  MultiTablesView.m
//  MultiTablesView
//
//  Created by Zouhair on 20/06/13.
//  Copyright (c) 2013 Zedenem. All rights reserved.
//

#import "MultiTablesView.h"
#import <QuartzCore/QuartzCore.h>
#import "UITableView+FixedTableHeaderView.h"

#pragma mark - Interface
@interface MultiTablesView () <UITableViewDataSource, UITableViewDelegate>

/** @name Setup */
#pragma mark Setup
- (void)setup;

/** @name Properties */
#pragma mark Properties
@property (nonatomic, strong) NSMutableArray *tableViews;
@property (nonatomic, readonly) CGFloat defaultNextTableViewHorizontalGap;

/** store previous indexPaths */
@property (nonatomic, strong) NSMutableArray* indexPaths;

/** @name Levels Details */
#pragma mark Levels Details
- (NSInteger)levelOfTableView:(UITableView *)tableView;
- (NSArray*)indexPathsOfTableView:(UITableView *)tableView;

/** @name Default Headers and Footers Heights */
#pragma mark Default Headers and Footers Heights
- (CGFloat)defaultHeightForHeaderInSection:(NSInteger)section atIndexPaths:(NSArray*)indexPaths;
- (CGFloat)defaultHeightForFooterInSection:(NSInteger)section atIndexPaths:(NSArray*)indexPaths;

@end

#pragma mark - Implementation
@implementation MultiTablesView

#pragma mark Properties
@synthesize dataSource = _dataSource;
- (void)setDataSource:(id<MultiTablesViewDataSource>)dataSource {
	if (![_dataSource isEqual:dataSource]) {
		_dataSource = dataSource;
	}
}
@synthesize delegate = _delegate;
- (void)setDelegate:(id<MultiTablesViewDelegate>)delegate {
	if (![_delegate isEqual:delegate]) {
		_delegate = delegate;
	}
}

@dynamic defaultNextTableViewHorizontalGap;
- (CGFloat)defaultNextTableViewHorizontalGap {
	return 44.0;
}

@synthesize currentTableView = _currentTableView;
- (UITableView *)currentTableView {
	return [self tableViewAtLevel:self.currentTableViewIndex];
}
@synthesize currentTableViewIndex = _currentTableViewIndex;


-(void)setCurrentTableViewIndex:(NSUInteger)currentTableViewIndex indexPath:(NSIndexPath*)indexPath{
    _currentTableViewIndex = currentTableViewIndex;
    if ([self.delegate respondsToSelector:@selector(multiTablesView:levelDidChangeAtIndexPaths:)]) {
        for (int i=0; i<(_indexPaths.count-currentTableViewIndex); i++) {
            [_indexPaths removeLastObject];
        }
        if (indexPath) {
            [_indexPaths removeLastObject];
            [_indexPaths addObject:indexPath];//update the root indexPath
        }
        [self.delegate multiTablesView:self levelDidChangeAtIndexPaths:_indexPaths];
    }
}

- (void)addPanGestureRecognizer {
	if ([self.gestureRecognizers count] == 0) {
		UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragTableView:)];
		[self addGestureRecognizer:panGestureRecognizer];
	}
}
- (void)removePanGestureRecognizer {
	[self removeGestureRecognizer:[self.gestureRecognizers lastObject]];
}

#pragma mark Setup
- (void)setup {
    self.indexPaths=[NSMutableArray new];
    self.tableViews = [NSMutableArray new];
    
    [self initTableViewData];
    
	[self setAutomaticPush:YES];
	[self setNextTableViewHorizontalGap:[self defaultNextTableViewHorizontalGap]];
	[self addPanGestureRecognizer];
}

#pragma mark View Lifecycle
- (void)awakeFromNib {
	[super awakeFromNib];
	[self setup];
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}

- (void)dealloc {
	[self setDataSource:nil];
	[self setDelegate:nil];
	[self setCurrentTableViewIndex:NSNotFound indexPath:nil];
}

#pragma mark Reload Datas
- (void)initTableViewData {
    // TODO: MAYBE DO NOTHING
    [self createTableViewAtLastLevel];
}

//- (void)createTableViewAtIndexPaths:(NSArray*)indexPaths{






- (void)createTableViewAtLastLevel{
    [self createTableViewAtIndexPaths:_indexPaths];
}
- (void)createTableViewAtIndexPaths:(NSArray*)indexPaths{
    CGRect tableViewFrame = self.bounds;
    if (indexPaths.count > 0) {
        tableViewFrame = CGRectMake(self.bounds.size.width + 20.0, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    }
    UITableView *tableView = nil;
    if (indexPaths.count < [self.tableViews count]) {
        tableView = [self.tableViews objectAtIndex:indexPaths.count];
        [tableView setFrame:tableViewFrame];
        [tableView reloadData];
        [tableView.fixedTableHeaderView removeFromSuperview];
        [tableView setFixedTableHeaderView:nil];
    }
    else {
        tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
        [self.tableViews addObject:tableView];
        [self addSubview:tableView];
        
        // Add a Shadow to the table View
        tableView.layer.shadowColor = [[UIColor blackColor] CGColor];
        tableView.layer.shadowOffset = CGSizeMake(-2, 0);
        tableView.layer.masksToBounds = NO;
        tableView.layer.shadowRadius = 5.0;
        tableView.layer.shadowOpacity = 0.4;
        tableView.layer.shouldRasterize = YES;
        tableView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:tableView.bounds];
        tableView.layer.shadowPath = path.CGPath;
        
        [tableView setDelegate:self];
        [tableView setDataSource:self];
    }
    
    // Set UITableView separator style
    UITableViewCellSeparatorStyle separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self.delegate respondsToSelector:@selector(multiTablesView:separatorStyleForIndexPaths:)]) {
        separatorStyle = [self.delegate multiTablesView:self separatorStyleForIndexPaths:indexPaths];
    }
    [tableView setSeparatorStyle:separatorStyle];
    
    if ([self.delegate respondsToSelector:@selector(multiTablesView:tableHeaderViewAtIndexPaths:)]) {
        [tableView setTableHeaderView:[self.delegate multiTablesView:self tableHeaderViewAtIndexPaths:indexPaths]];
    }
    else {
        [tableView setTableHeaderView:nil];
    }
    
    if ([self.delegate respondsToSelector:@selector(multiTablesView:fixedTableHeaderViewAtIndexPaths:)]) {
        UIView *fixedTableHeaderView = [self.delegate multiTablesView:self fixedTableHeaderViewAtIndexPaths:indexPaths];
        [fixedTableHeaderView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, fixedTableHeaderView.frame.size.width, fixedTableHeaderView.frame.size.height)];
        
        // Add a Shadow to the fixed table header view
        fixedTableHeaderView.layer.shadowColor = [[UIColor blackColor] CGColor];
        fixedTableHeaderView.layer.shadowOffset = CGSizeMake(-2, 0);
        fixedTableHeaderView.layer.masksToBounds = NO;
        fixedTableHeaderView.layer.shadowRadius = 5.0;
        fixedTableHeaderView.layer.shadowOpacity = 0.4;
        fixedTableHeaderView.layer.shouldRasterize = YES;
        fixedTableHeaderView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:fixedTableHeaderView.bounds];
        fixedTableHeaderView.layer.shadowPath = path.CGPath;
        
        [self addSubview:fixedTableHeaderView];
        [tableView setFixedTableHeaderView:fixedTableHeaderView];
    }
}


- (UITableViewCell *)dequeueReusableCellForLevel:(NSInteger)level withIdentifier:(NSString *)identifier{
	return [[self tableViewAtLevel:level] dequeueReusableCellWithIdentifier:identifier];
}

#pragma mark Levels Details
- (NSInteger)numberOfLevels {
	return [self.tableViews count];
}
- (NSInteger)levelOfTableView:(UITableView *)tableView {
	return [self.tableViews indexOfObject:tableView];
}
- (NSArray*)indexPathsOfTableView:(UITableView *)tableView{
    int level=[self levelOfTableView:tableView];
    NSMutableArray* indexPaths=[NSMutableArray new];
    for (int i=0; i<level; i++) {
        [indexPaths addObject:[_indexPaths objectAtIndex:i]];
    }
    return indexPaths;
}
- (UITableView *)tableViewAtLevel:(NSInteger)level {
	UITableView *tableView = nil;
	if (level >= 0 && level < [self.tableViews count]) {
		tableView = [self.tableViews objectAtIndex:level];
	}
	return tableView;
}
- (NSIndexPath *)indexPathForSelectedRowAtLevel:(NSInteger)level {
	return [[self tableViewAtLevel:level] indexPathForSelectedRow];
}

-(void)animateRight{
    CGFloat newXCoordinate = self.bounds.size.width;
    UITableView *draggedTableView = self.currentTableView;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [draggedTableView setFrame:CGRectMake(newXCoordinate, self.bounds.origin.y, self.frame.size.width, self.frame.size.height)];
                    	 [draggedTableView.fixedTableHeaderView setCenter:CGPointMake(draggedTableView.center.x, draggedTableView.fixedTableHeaderView.center.y)];
					 }
                     completion:^(BOOL finished) {
                     }];
}

#pragma mark Levels Dragging Animations & Interactions
- (void)dragTableView:(UIPanGestureRecognizer *)panGestureRecognizer {
	UITableView *draggedTableView = self.currentTableView;
	
	// Calculate default X Coordinate of current Table View
	CGFloat draggedTableViewDefaultXCoordinate = 0.0;
	UITableView *previousTableView = [self tableViewAtLevel:self.currentTableViewIndex-1];
	if (self.currentTableViewIndex > 0) {
		draggedTableViewDefaultXCoordinate = previousTableView.frame.origin.x + self.nextTableViewHorizontalGap;
	}
	
	switch (panGestureRecognizer.state) {
		case UIGestureRecognizerStateEnded: {
			if (self.currentTableViewIndex > 0) {
				if ([panGestureRecognizer velocityInView:draggedTableView].x > 500.0 || draggedTableView.frame.origin.x > self.bounds.size.width/3*2) {
					draggedTableViewDefaultXCoordinate = self.bounds.size.width;
					if (self.currentTableViewIndex > 0) {
						draggedTableViewDefaultXCoordinate = self.bounds.size.width + 20;
					}
					[self setCurrentTableViewIndex:self.currentTableViewIndex-1 indexPath:nil];
				}
			}
			[UIView animateWithDuration:0.2
								  delay:0.0
								options:UIViewAnimationCurveEaseInOut
							 animations:^{
								 [draggedTableView setFrame:CGRectMake(draggedTableViewDefaultXCoordinate, self.bounds.origin.y, self.frame.size.width, self.frame.size.height)];
								 [draggedTableView.fixedTableHeaderView setCenter:CGPointMake(draggedTableView.center.x, draggedTableView.fixedTableHeaderView.center.y)];
							 }
							 completion:^(BOOL finished) {
							 }];
		} break;
		default: {
			CGFloat newXCenter = MAX(draggedTableView.center.x + [panGestureRecognizer translationInView:draggedTableView].x, draggedTableViewDefaultXCoordinate + draggedTableView.frame.size.width/2);
			[draggedTableView setCenter:CGPointMake(newXCenter, draggedTableView.center.y)];
			[draggedTableView.fixedTableHeaderView setCenter:CGPointMake(draggedTableView.center.x, draggedTableView.fixedTableHeaderView.center.y)];
			[panGestureRecognizer setTranslation:CGPointZero inView:draggedTableView];
		} break;
	}
}

#pragma mark Default Headers and Footers Heights
- (CGFloat)defaultHeightForHeaderInSection:(NSInteger)section atLevel:(NSInteger)level {
	return [self tableViewAtLevel:level].sectionHeaderHeight;
}
- (CGFloat)defaultHeightForFooterInSection:(NSInteger)section atLevel:(NSInteger)level {
	return [self tableViewAtLevel:level].sectionFooterHeight;
}

#pragma mark - UITableViewDataSource
#pragma mark Sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSections = 0;
	if ([self.dataSource respondsToSelector:@selector(multiTablesView:numberOfSectionsAtIndexPaths:)]) {
		numberOfSections = [self.dataSource multiTablesView:self numberOfSectionsAtIndexPaths:[self indexPathsOfTableView:tableView]];
	}
	return numberOfSections;
}
#pragma mark Sections Headers & Footers
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section indexPaths:(NSArray*)indexPaths{
	NSString *titleForHeaderInSection = nil;
    if ([self.dataSource respondsToSelector:@selector(multiTablesView:indexPaths:titleForHeaderInSection:)]) {
		titleForHeaderInSection = [self.dataSource multiTablesView:self indexPaths:indexPaths titleForHeaderInSection:section];
	}
	return titleForHeaderInSection;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section indexPaths:(NSArray*)indexPaths{
	NSString *titleForFooterInSection = nil;
    if ([self.dataSource respondsToSelector:@selector(multiTablesView:indexPaths:titleForFooterInSection:)]) {
		titleForFooterInSection = [self.dataSource multiTablesView:self indexPaths:indexPaths titleForFooterInSection:section];
	}
	return titleForFooterInSection;
}
#pragma mark Rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numberOfRows = 0;
	if ([self.dataSource respondsToSelector:@selector(multiTablesView:indexPaths:numberOfRowsInSection:)]) {
		numberOfRows = [self.dataSource multiTablesView:self indexPaths:[self indexPathsOfTableView:tableView] numberOfRowsInSection:section];
	}
	return numberOfRows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	if ([self.dataSource respondsToSelector:@selector(multiTablesView:indexPaths:cellForRowAtIndexPath:)]) {
        cell = [self.dataSource multiTablesView:self indexPaths:[self indexPathsOfTableView:tableView] cellForRowAtIndexPath:indexPath];
	}
	return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(multiTablesView:indexPaths:canEditRowAtIndexPath:)]) {
        return [self.dataSource multiTablesView:self indexPaths:[self indexPathsOfTableView:tableView] canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

#pragma mark - UITableViewDelegate
#pragma mark Sections Headers & Footers
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	CGFloat heightForHeader = 0.0;
	if ([self.delegate respondsToSelector:@selector(multiTablesView:indexPaths:heightForHeaderInSection:)]) {
		heightForHeader = [self.delegate multiTablesView:self indexPaths:[self indexPathsOfTableView:tableView] heightForHeaderInSection:section];
	}
	else {
		heightForHeader = [self defaultHeightForHeaderInSection:section atIndexPaths:[self indexPathsOfTableView:tableView]];
	}
	return heightForHeader;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	CGFloat heightForFooter = 0.0;
	if ([self.delegate respondsToSelector:@selector(multiTablesView:indexPaths:heightForFooterInSection:)]) {
		heightForFooter = [self.delegate multiTablesView:self indexPaths:[self indexPathsOfTableView:tableView] heightForFooterInSection:section];
	}
	else {
		heightForFooter = [self defaultHeightForFooterInSection:section atIndexPaths:[self indexPathsOfTableView:tableView]];
	}
	return heightForFooter;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView * viewForHeaderInSection = nil;
    if ([self.delegate respondsToSelector:@selector(multiTablesView:indexPaths:viewForHeaderInSection:)]) {
		viewForHeaderInSection = [self.delegate multiTablesView:self indexPaths:[self indexPathsOfTableView:tableView] viewForHeaderInSection:section];
	}
    return viewForHeaderInSection;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView * viewForFooterInSection = nil;
    if ([self.delegate respondsToSelector:@selector(multiTablesView:indexPaths:viewForFooterInSection:)]) {
		viewForFooterInSection = [self.delegate multiTablesView:self indexPaths:[self indexPathsOfTableView:tableView] viewForFooterInSection:section];
	}
    return viewForFooterInSection;
}
#pragma mark Rows
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(multiTablesView:indexPaths:willDisplayCell:forRowAtIndexPath:)]) {
		[self.delegate multiTablesView:self indexPaths:[self indexPathsOfTableView:tableView] willDisplayCell:cell forRowAtIndexPath:indexPath];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(multiTablesView:level:willSelectRowAtIndexPath:)]) {
		return [self.delegate multiTablesView:self level:[self levelOfTableView:tableView] willSelectRowAtIndexPath:indexPath];
	}
	else {
		return indexPath;
	}
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(multiTablesView:indexPaths:didSelectRowAtIndexPath:)]) {
        [self.delegate multiTablesView:self indexPaths:[self indexPathsOfTableView:tableView] didSelectRowAtIndexPath:indexPath];
    }
    if ([self.dataSource respondsToSelector:@selector(hasSubTableViewInMultiTablesView:indexPaths:indexPath:)]) {
        if([self.dataSource hasSubTableViewInMultiTablesView:self indexPaths:[self indexPathsOfTableView:tableView] indexPath:indexPath]){
            if (self.automaticPush) {
                [self pushNextTableView:tableView indexPath:indexPath];
            }
        }
    }
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(multiTablesView:indexPaths:commitEditingStyle:forRowAtIndexPath:)]) {
		[self.delegate multiTablesView:self indexPaths:[self indexPathsOfTableView:tableView] commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
	}
}
#pragma mark Push Level
/**
 @ tableView current tableView tapped
 */
-(void)pushNextTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
    NSInteger levelOfTableView = [self levelOfTableView:tableView];
    
    for (int i = levelOfTableView + 1; i < [self numberOfLevels]; i++) {
        [[self tableViewAtLevel:i] reloadData];
    }
    
    
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         for (int i = levelOfTableView+1; i < [self numberOfLevels]; i++) {
                             UITableView *nextTableView = [self tableViewAtLevel:i];
                             [nextTableView setFrame:CGRectMake(self.bounds.size.width + 20, nextTableView.frame.origin.y, nextTableView.frame.size.width, nextTableView.frame.size.height)];
                             [nextTableView.fixedTableHeaderView setCenter:CGPointMake(nextTableView.center.x, nextTableView.fixedTableHeaderView.center.y)];
                         }
                     }
                     completion:^(BOOL finished) {
                         NSMutableArray* tableViewsToRemove=[NSMutableArray new];
                         for (int i = levelOfTableView+1; i < [self numberOfLevels]; i++) {
                             UITableView *nextTableView = [self tableViewAtLevel:i];
                             [nextTableView removeFromSuperview];
                             [tableViewsToRemove addObject:nextTableView];
                         }
                         
                         [_indexPaths removeObjectsInRange:NSMakeRange(levelOfTableView, _indexPaths.count-levelOfTableView)];
                         [self.tableViews removeObjectsInArray:tableViewsToRemove];
                         
                         [_indexPaths addObject:indexPath];
                         [self createTableViewAtLastLevel];
                         [self setCurrentTableViewIndex:levelOfTableView + 1 indexPath:indexPath];
                         
                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options:UIViewAnimationCurveEaseOut
                                          animations:^{
                                              [self.currentTableView setFrame:CGRectMake(tableView.frame.origin.x + self.nextTableViewHorizontalGap, self.currentTableView.frame.origin.y, self.currentTableView.frame.size.width, self.currentTableView.frame.size.height)];
                                              [self.currentTableView.fixedTableHeaderView setCenter:CGPointMake(self.currentTableView.center.x, self.currentTableView.fixedTableHeaderView.center.y)];
                                          }
                                          completion:^(BOOL finished) {
                                              NSLog(@"DEBUG  _indexPaths:%@",_indexPaths);
                                          }
                          ];
                     }];
}


#pragma mark Pop Levels
- (void)popCurrentTableViewAnimated:(BOOL)animated {
	if (self.currentTableViewIndex > 0) {
		// Calculate default X Coordinate of current Table View
		CGFloat tableViewDefaultXCoordinate = self.bounds.size.width;
		if (self.currentTableViewIndex > 0) {
			tableViewDefaultXCoordinate = self.bounds.size.width + 20;
		}
		
		[UIView animateWithDuration:animated?0.2:0.0
							  delay:0.0
							options:UIViewAnimationCurveEaseInOut
						 animations:^{
							 [self.currentTableView setFrame:CGRectMake(tableViewDefaultXCoordinate, self.bounds.origin.y, self.frame.size.width, self.frame.size.height)];
							 [self.currentTableView.fixedTableHeaderView setCenter:CGPointMake(self.currentTableView.center.x, self.currentTableView.fixedTableHeaderView.center.y)];
						 }
						 completion:^(BOOL finished) {
							 [self setCurrentTableViewIndex:self.currentTableViewIndex-1 indexPath:nil];
						 }];
	}
}

-(CGFloat)defaultHeightForHeaderInSection:(NSInteger)section atIndexPaths:(NSArray *)indexPaths{
    return 0;
}
-(CGFloat)defaultHeightForFooterInSection:(NSInteger)section atIndexPaths:(NSArray *)indexPaths{
    return 0;
}

@end
