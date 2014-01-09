//
//  BeaconPowerViewController.m
//  ESTBeacon
//
//

#import "BeaconPowerViewController.h"

@interface 

@implementation BeaconPowerViewController

- (void)setPower:(NSNumber *)power {
    if (_power != power) {
        if (_power) {
            if ([self isViewLoaded]) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_power charValue] inSection:0]];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        _power = power;
        if (_power) {
            if ([self isViewLoaded]) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_power charValue] inSection:0]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == [_power charValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.power = [self powerAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)indexPathForPower:(NSNumber *)power {
    if (power) {
        // TODO
        return nil;
    } else {
        return nil;
    }
}

- (NSNumber *)powerAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        // TODO
        return nil;
    } else {
        return nil;
    }
}

// - (NSInteger)rowForPower:(ESTBeaconPower)power {
//     switch (power) {
//         case :
//             return 0;
//     }
// }

@end
