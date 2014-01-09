//
//  DetailViewController.m
//  ESTBeacon
//

#import "DetailViewController.h"
#import "MRProgress.h"
#import "PowerViewController.h"

enum {
    kAlertViewTagMajor = 0,
    kAlertViewTagMinor,
    kAlertViewTagAdvInterval,
    kAlertViewTagFirmware
};

@interface DetailViewController ()
- (void)writeBeaconMajor:(unsigned short)major;
- (void)writeBeaconMinor:(unsigned short)minor;
- (void)writeBeaconAdvInterval:(unsigned short)interval;
- (void)writeBeaconPower:(ESTBeaconPower)power;
- (void)checkFirmwareUpdate;
- (void)updateBeaconFirmware;
@end

@implementation DetailViewController

- (IBAction)powerDone:(UIStoryboardSegue *)segue {
    PowerViewController *powerViewController = segue.sourceViewController;
    NSNumber *power = powerViewController.power;
    NSAssert1(power != nil, @"%s: power is nil", __PRETTY_FUNCTION__);
    [self writeBeaconPower:[power charValue]];
}

- (IBAction)powerCancel:(UIStoryboardSegue *)segue {
    // do nothing
}

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_beacon.isConnected && !_beacon.delegate) {
        _beacon.delegate = self;
        [_beacon connectToBeacon];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (![self.view superview]) {
        if (_beacon.isConnected) {
            _beacon.delegate = nil;
            [_beacon disconnectBeacon];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditPower"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        PowerViewController *powerViewController = navigationController.viewControllers[0];
        powerViewController.power = _beacon.power;
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIColor *color;
    switch (buttonIndex) {
        case 0:
            color = [UIColor colorWithRed:0.42 green:0.75 blue:0.87 alpha:1.0];
            break;
        case 1:
            color = [UIColor colorWithRed:0.49 green:0.64 blue:0.55 alpha:1.0];
            break;
        case 2:
            color = [UIColor colorWithRed:0.38 green:0.00 blue:0.28 alpha:1.0];
            break;
        default:
            color = nil;
            break;
    }
    if (color) {
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *colors = [NSMutableDictionary dictionaryWithDictionary:[userDefaults dictionaryForKey:@"Colors"]];
        colors[_beacon.macAddress] = colorData;
        [userDefaults setObject:colors forKey:@"Colors"];
        [self.tableView reloadData];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case kAlertViewTagMajor:
            switch (buttonIndex) {
                case 1:
                    [self writeBeaconMajor:[[alertView textFieldAtIndex:0].text integerValue]];
                    break;
            }
            break;
        case kAlertViewTagMinor:
            switch (buttonIndex) {
                case 1:
                    [self writeBeaconMinor:[[alertView textFieldAtIndex:0].text integerValue]];
                    break;
            }
            break;
        case kAlertViewTagAdvInterval:
            switch (buttonIndex) {
                case 1:
                    [self writeBeaconAdvInterval:[[alertView textFieldAtIndex:0].text integerValue]];
                    break;
            }
            break;
        case kAlertViewTagFirmware:
            switch (buttonIndex) {
                case 1:
                    [self updateBeaconFirmware];
                    break;
            }
            break;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.detailTextLabel.text = _beacon.macAddress ?: @"(null)";
                    break;
                case 1:
                    cell.detailTextLabel.text = [_beacon.proximityUUID UUIDString] ?: @"(null)";
                    break;
                case 2:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%u", [_beacon.major unsignedShortValue]];
                    break;
                case 3:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%u", [_beacon.minor unsignedShortValue]];
                    break;
                case 4:
                {
                    NSData *colorData = _beacon.macAddress ? [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"Colors"][_beacon.macAddress] : nil;
                    if (colorData) {
                        UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
                        CGRect rect = CGRectMake(0, 0, 21, 21);
                        UIGraphicsBeginImageContext(rect.size);
                        CGContextRef contextRef = UIGraphicsGetCurrentContext();
                        CGContextSetFillColorWithColor(contextRef, [color CGColor]);
                        CGContextFillRect(contextRef, rect);
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        cell.imageView.image = image;
                    } else {
                        cell.imageView.image = nil;
                    }
                }
                break;
                case 5:
                    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%ld dBm", @""), (long)_beacon.rssi];
                    break;
                case 6:
                    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ m", @""), _beacon.distance];
                    break;
                case 7:
                    switch (_beacon.proximity) {
                        case CLProximityUnknown:
                            cell.detailTextLabel.text = NSLocalizedString(@"Unknown", @"");
                            break;
                        case CLProximityImmediate:
                            cell.detailTextLabel.text = NSLocalizedString(@"Immediate", @"");
                            break;
                        case CLProximityNear:
                            cell.detailTextLabel.text = NSLocalizedString(@"Near", @"");
                            break;
                        case CLProximityFar:
                            cell.detailTextLabel.text = NSLocalizedString(@"Far", @"");
                            break;
                        default:
                            cell.detailTextLabel.text = nil;
                            break;
                    }
                    break;
                case 8:
                    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ dBm", @""), _beacon.measuredPower];
                    break;
                default:
                    cell.detailTextLabel.text = nil;
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.detailTextLabel.text = _beacon.power ? [NSString stringWithFormat:NSLocalizedString(@"%d dBm", @""), [_beacon.power charValue]] : NSLocalizedString(@"(null) dBm", @"");
                    break;
                case 1:
                    cell.detailTextLabel.text = _beacon.advInterval ? [NSString stringWithFormat:NSLocalizedString(@"%u ms", @""), [_beacon.advInterval unsignedShortValue]] : NSLocalizedString(@"(null) ms", @"");
                    break;
                case 2:
                    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %%", @""), _beacon.batteryLevel];
                    break;
                case 3:
                    cell.detailTextLabel.text = _beacon.hardwareVersion ?: @"(null)";
                    break;
                case 4:
                    cell.detailTextLabel.text = _beacon.firmwareVersion ?: @"(null)";
                    break;
                default:
                    cell.detailTextLabel.text = nil;
                    break;
            }
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_beacon.isConnected) {
        return indexPath;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 2:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Major Value", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Write", @""), nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    textField.text = [NSString stringWithFormat:@"%u", [_beacon.major unsignedShortValue]];
                    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    alertView.tag = kAlertViewTagMajor;
                    [alertView show];
                }
                break;
                case 3:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Minor Value", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Write", @""), nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    textField.text = [NSString stringWithFormat:@"%u", [_beacon.minor unsignedShortValue]];
                    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    alertView.tag = kAlertViewTagMinor;
                    [alertView show];
                }
                break;
                case 4:
                {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Soft Blue", @""), NSLocalizedString(@"Lime Green", @""), NSLocalizedString(@"Very Dark Pink", @""), nil];
                    [actionSheet showFromRect:[tableView rectForRowAtIndexPath:indexPath] inView:tableView animated:YES];
                }
                break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 1:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter Advertising Interval", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Write", @""), nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    textField.text = [NSString stringWithFormat:@"%u", [_beacon.advInterval unsignedShortValue]];
                    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    alertView.tag = kAlertViewTagAdvInterval;
                    [alertView show];
                }
                break;
                case 4:
                    [self checkFirmwareUpdate];
                    break;
            }
            break;
    }
}

#pragma mark - ESTBeaconDelegate

- (void)beaconConnectionDidFail:(ESTBeacon*)beacon withError:(NSError*)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    [alertView show];
}

- (void)beaconConnectionDidSucceeded:(ESTBeacon*)beacon {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if ([self.view superview]) {
        [self.tableView reloadData];
    } else {
        beacon.delegate = nil;
        [beacon disconnectBeacon];
    }
}

#pragma mark - Anonymous category

- (void)writeBeaconMajor:(unsigned short)major {
    [_beacon writeBeaconMajor:major withCompletion:^(unsigned short value, NSError *error) {
        if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could Not Write Major Value", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alertView show];
        } else {
            [self.tableView reloadData];
        }
    }];
}

- (void)writeBeaconMinor:(unsigned short)minor {
    [_beacon writeBeaconMinor:minor withCompletion:^(unsigned short value, NSError *error) {
        if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could Not Write Minor Value", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alertView show];
        } else {
            [self.tableView reloadData];
        }
    }];
}

- (void)writeBeaconAdvInterval:(unsigned short)interval {
    [_beacon writeBeaconAdvInterval:interval withCompletion:^(unsigned short value, NSError *error) {
        if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could Not Write Advertising Interval", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alertView show];
        } else {
            [self.tableView reloadData];
        }
    }];
}

- (void)writeBeaconPower:(ESTBeaconPower)power {
    [_beacon writeBeaconPower:power withCompletion:^(ESTBeaconPower value, NSError *error) {
        if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could Not Write Power", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alertView show];
        } else {
            [self.tableView reloadData];
        }
    }];
}

- (void)checkFirmwareUpdate {
    [_beacon checkFirmwareUpdateWithCompletion:^(BOOL updateAvailable, ESTBeaconUpdateInfo *updateInfo, NSError *error) {
        if (updateAvailable) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Firmware Update Available", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Update", @""), nil];
            alertView.tag = kAlertViewTagFirmware;
            [alertView show];
        } else {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Updates Available", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)updateBeaconFirmware {
    MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:self.view.window animated:YES];
    [_beacon updateBeaconFirmwareWithProgress:^(NSString *value, NSError *error) {
        if (value) {
            progressView.titleLabelText = value;
        } else {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
        }
    } andCompletion:^(NSError *error) {
        [MRProgressOverlayView dismissOverlayForView:self.view.window animated:YES];
        if (error) {
            NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could Not Update Firmware", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alertView show];
        } else {
            [self.tableView reloadData];
        }
    }];
}

@end
