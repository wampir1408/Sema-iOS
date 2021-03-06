//
//  SEChooseWhoToSendViewModel.m
//  Sema
//
//  Created by Joanna Furmaniak on 15.06.2016.
//  Copyright © 2016 The Company. All rights reserved.
//

#import "SEChooseWhoToSendViewModel.h"

#import "NSString+Validation.h"
#import "UIAlertController+Errors.h"

//Account
#import "SEAccount.h"

@interface SEChooseWhoToSendViewModel ()
@property (nonatomic, strong) NSArray <SERoomUser *> *roomUsers;
@end

@implementation SEChooseWhoToSendViewModel

- (instancetype)initWithRoom:(SERoom *)room {
    self = [super init];
    if (self) {
        _room = room;
    }
    return self;
}

- (NSInteger)numberOfRoomUsers {
    return (NSInteger) _roomUsers.count;
}

- (SERoomUserCellViewModel *)cellViewModelForIndexPath:(NSIndexPath *)indexPath {
    SERoomUser *roomUser = [self roomUserForIndexPath:indexPath];
    
    return [[SERoomUserCellViewModel alloc] initWithRoomUser:roomUser];
}

- (SERoomUser *)roomUserForIndexPath:(NSIndexPath *)indexPath {
    return _roomUsers[(NSUInteger)indexPath.row];
}

- (void)fetchRoomUsersWithCompletionBlock:(SERoomUsersViewModelFetchSubjectsCompletion)block {
    SERoomParams *roomParams = [[SERoomParams alloc] initWithRoomId:_room.rId];
    __weak typeof (self) wSelf = self;
    [[SERoomUsersService new] fetchRoomUsersWithParams:roomParams completion:^(BOOL success, NSArray<SERoomUser *> *roomUsers, NSError *error) {
        if (!success && error && block) {
            block(nil, [UIAlertController alertWithErrorMessage:@"Something went wrong. Please try again."]);
            
            return;
        }
        
        wSelf.roomUsers = roomUsers;
        if (block) {
            block([wSelf.roomUsers copy], nil);
        }
    }];
}

- (void)fetchGameCardsWithCompletionBlock:(SEGameCardsViewModelFetchSubjectsCompletion)block {
    SERoomParams *roomParams = [[SERoomParams alloc] initWithRoomId:_room.rId];
    __weak typeof (self) wSelf = self;
    [[SEGameCardsService new] fetchGameCardsWithParams:roomParams completion:^(BOOL success, NSArray<SEGameCard *> *gameCards, NSError *error) {
        if (!success && error && block) {
            block(nil, [UIAlertController alertWithErrorMessage:@"Something went wrong. Please try again."]);
            
            return;
        }
        
        wSelf.gameCards = gameCards;
        if (block) {
            block([wSelf.gameCards copy], nil);
        }
    }];
}

@end
