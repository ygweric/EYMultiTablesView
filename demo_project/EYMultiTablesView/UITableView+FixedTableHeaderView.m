//
//  UITableView+FixedTableHeaderView.m
//  MultiTablesView
//
//  Created by Eric Yang on 18/09/14.
//  Copyright (c) 2014 ygweric. All rights reserved.
//

#import "UITableView+FixedTableHeaderView.h"

#import <objc/runtime.h>

@implementation UITableView (FixedTableHeaderView)

static const char* fixedTableHeaderViewKey = "FixedTableHeaderView";

- (UIView *)fixedTableHeaderView {
    return objc_getAssociatedObject(self, fixedTableHeaderViewKey);
}

- (void)setFixedTableHeaderView:(UIView *)fixedTableHeaderView {
    objc_setAssociatedObject(self, fixedTableHeaderViewKey, fixedTableHeaderView, OBJC_ASSOCIATION_ASSIGN);
	[self setContentInset:UIEdgeInsetsMake(fixedTableHeaderView.frame.size.height, self.contentInset.left, self.contentInset.bottom, self.contentInset.right)];
}

@end
