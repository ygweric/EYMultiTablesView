//
//  UITableView+FixedTableHeaderView.h
//  MultiTablesView
//
//  Created by Eric Yang on 18/09/14.
//  Copyright (c) 2014 ygweric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (FixedTableHeaderView)

/**
 * FixedTableHeaderView is a new property of UITableView that represents a replacement to the original tableHeaderView.
 * A fixedTableHeaderView is stacked at the top of the tableView.
 *
 * To use a fixedTableHeaderView, you must do something like this (where your UITableView is subview to another UIView) :
 * [fixedTableHeaderView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, fixedTableHeaderView.frame.size.width, fixedTableHeaderView.frame.size.height)];
 * [tableView.superview addSubview:fixedTableHeaderView];
 * [tableView setFixedTableHeaderView:fixedTableHeaderView];
 */
@property(nonatomic, readwrite, retain) UIView *fixedTableHeaderView;

@end
