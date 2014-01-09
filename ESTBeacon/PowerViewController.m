//
//  PowerViewController.m
//  ESTBeacon
//

#import "PowerViewController.h"

@interface PowerViewController ()
- (NSIndexPath *)indexPathForPower:(NSNumber *)power;
- (NSNumber *)powerAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation PowerViewController

- (void)setPower:(NSNumber *)power {
    if (_power != power) {
        if (_power) {
            if ([self isViewLoaded]) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self indexPathForPower:_power]];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        _power = power;
        if (_power) {
            if ([self isViewLoaded]) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self indexPathForPower:_power]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([indexPath isEqual:[self indexPathForPower:_power]]) {
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

#pragma mark - Anonymous category

- (NSIndexPath *)indexPathForPower:(NSNumber *)power {
    if (power) {
        switch ([power charValue]) {
            case ESTBeaconPowerLevel1:
                return [NSIndexPath indexPathForRow:0 inSection:0];
            case ESTBeaconPowerLevel2:
                return [NSIndexPath indexPathForRow:1 inSection:0];
            case ESTBeaconPowerLevel3:
                return [NSIndexPath indexPathForRow:2 inSection:0];
            case ESTBeaconPowerLevel4:
                return [NSIndexPath indexPathForRow:3 inSection:0];
            case ESTBeaconPowerLevel5:
                return [NSIndexPath indexPathForRow:4 inSection:0];
            case ESTBeaconPowerLevel6:
                return [NSIndexPath indexPathForRow:5 inSection:0];
            case ESTBeaconPowerLevel7:
                return [NSIndexPath indexPathForRow:6 inSection:0];
            case ESTBeaconPowerLevel8:
                return [NSIndexPath indexPathForRow:7 inSection:0];
            default:
                return nil;
        }
    } else {
        return nil;
    }
}

- (NSNumber *)powerAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 0:
                        return [NSNumber numberWithChar:ESTBeaconPowerLevel1];
                    case 1:
                        return [NSNumber numberWithChar:ESTBeaconPowerLevel2];
                    case 2:
                        return [NSNumber numberWithChar:ESTBeaconPowerLevel3];
                    case 3:
                        return [NSNumber numberWithChar:ESTBeaconPowerLevel4];
                    case 4:
                        return [NSNumber numberWithChar:ESTBeaconPowerLevel5];
                    case 5:
                        return [NSNumber numberWithChar:ESTBeaconPowerLevel6];
                    case 6:
                        return [NSNumber numberWithChar:ESTBeaconPowerLevel7];
                    case 7:
                        return [NSNumber numberWithChar:ESTBeaconPowerLevel8];
                    default:
                        return nil;
                }
                break;
            case 1:
                return nil;
            default:
                return nil;
        }
    } else {
        return nil;
    }
}

@end
