//
//  ViewController.m
//  MultiTablesView
//
//  Created by Eric Yang on 18/09/14.
//  Copyright (c) 2014 ygweric. All rights reserved.
//

#import "ViewController.h"
#import "EYMultiTablesView.h"

@interface ViewController () <MultiTablesViewDataSource, MultiTablesViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


#pragma mark - MultiTablesViewDataSource
#pragma mark Levels
- (BOOL)hasSubTableViewInMultiTablesView:(EYMultiTablesView *)multiTablesView indexPaths:(NSArray *)indexPaths indexPath:(NSIndexPath *)indexPath{
    if (indexPaths.count>0) {
        NSIndexPath* ip=[indexPaths objectAtIndex:0];
        return ip.row%2==0;
    }else{
        return YES;
    }
    
//    return indexPaths.count<5; //total is 5
}
#pragma mark Sections
- (NSInteger)multiTablesView:(EYMultiTablesView *)multiTablesView numberOfSectionsAtIndexPaths:(NSArray *)indexPaths{
	return 1+indexPaths.count*2;
}
#pragma mark Sections Headers & Footers
- (NSString *)multiTablesView:(EYMultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"{%d, %d}", section, indexPaths.count];
}
- (NSString *)multiTablesView:(EYMultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths titleForFooterInSection:(NSInteger)section {
	return nil;
}
#pragma mark Rows
- (NSInteger)multiTablesView:(EYMultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths numberOfRowsInSection:(NSInteger)section {
	return indexPaths.count * section + 5;
}
- (UITableViewCell *)multiTablesView:(EYMultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [multiTablesView dequeueReusableCellForLevel:indexPaths.count withIdentifier:CellIdentifier];
    if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	[cell.textLabel setText:[NSString stringWithFormat:@"{%d, %d, %d}", indexPath.row, indexPath.section, indexPaths.count]];
    
    return cell;
}

#pragma mark - MultiTablesViewDelegate
#pragma mark Levels
- (void)multiTablesView:(EYMultiTablesView *)multiTablesView levelDidChangeAtIndexPaths:(NSArray *)indexPaths{
	if (multiTablesView.currentTableViewIndex == indexPaths.count) {
		[multiTablesView.currentTableView deselectRowAtIndexPath:[multiTablesView.currentTableView indexPathForSelectedRow] animated:YES];
	}
}
#pragma mark Rows
- (void)multiTablesView:(EYMultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (void)multiTablesView:(EYMultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
#pragma mark Sections Headers & Footers
- (CGFloat)multiTablesView:(EYMultiTablesView *)multiTablesView indexPaths:(NSArray*)indexPaths heightForFooterInSection:(NSInteger)section {
	return 0.0;
}
#pragma mark Fixed Table Headers
- (UIView *)multiTablesView:(EYMultiTablesView *)multiTablesView fixedTableHeaderViewAtIndexPaths:(NSArray*)indexPaths{
	UILabel *fixedTableHeaderView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 22.0)];
	[fixedTableHeaderView setBackgroundColor:[UIColor redColor]];
	[fixedTableHeaderView setText:[NSString stringWithFormat:@"Level %d", indexPaths.count]];
	return fixedTableHeaderView;
}

@end
