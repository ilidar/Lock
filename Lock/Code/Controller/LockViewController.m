//
//  LockViewController.m
//  Lock
//
//  Created by Denys Kotelovych on 20.11.13.
//  Copyright (c) 2013 D.K. All rights reserved.
//

#import "LockViewController.h"
#import "LockView.h"

@implementation LockViewController

- (void)loadView {
  self.view = [[LockView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.view.backgroundColor = [UIColor blackColor];
}

@end
