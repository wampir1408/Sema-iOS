//
//  SERoomViewController.m
//  Sema
//
//  Created by Joanna Furmaniak on 14.06.2016.
//  Copyright © 2016 The Company. All rights reserved.
//

#import "SERoomViewController.h"
#import "SEGameMenuViewController.h"

#import "SERoomUserCell.h"
#import "SEGameMenuViewModel.h"

//Views
#import "MBProgressHUD.h"

@interface SERoomViewController ()

@end

@implementation SERoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize Refresh Control
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    
    // Configure Refresh Control
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [self.tableView registerNib:[SERoomUserCell nib]
         forCellReuseIdentifier:[SERoomUserCell reuseIdentifier]];
    
    self.tableView.rowHeight = [SERoomUserCell height];
    [self reloadData];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    // Do your job, when done:
    [self reloadData];
    [refreshControl endRefreshing];
}

- (IBAction)joinRoomAction:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.view endEditing:YES];
    
    __weak typeof (self) wSelf = self;
    [_viewModel joinRoomWithCompletion:^(BOOL success, UIAlertController *alert) {
        [MBProgressHUD hideHUDForView:wSelf.view animated:YES];
        
        if (!success && alert) {
            [wSelf presentViewController:alert animated:YES completion:nil];
            
            return ;
        }
        SERoom *room = self.viewModel.room;
        SEGameMenuViewModel *gameMenuViewModel = [[SEGameMenuViewModel alloc] initWithRoom:room];
        SEGameMenuViewController *gameMenuViewController = [[UIStoryboard storyboardWithName:@"Game" bundle:nil] instantiateViewControllerWithIdentifier:@"GameMenu"];
        gameMenuViewController.viewModel = gameMenuViewModel;
        [wSelf.navigationController pushViewController:gameMenuViewController animated:YES];
    }];
}

- (void)reloadData {
    __weak typeof (self) wSelf = self;
    [_viewModel fetchRoomUsersWithCompletionBlock:^(NSArray<SERoomUser *> *roomUsers, UIAlertController *alert) {
        if (alert) {
            [wSelf presentViewController:alert animated:YES completion:nil];
            return ;
        }
        
        [wSelf.tableView reloadData];
    }];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRoomUsers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [SERoomUserCell reuseIdentifier];
    SERoomUserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    SERoomUserCellViewModel *cellViewModel = [self.viewModel cellViewModelForIndexPath:indexPath];
    [cell populateWithViewModel:cellViewModel];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate


@end
