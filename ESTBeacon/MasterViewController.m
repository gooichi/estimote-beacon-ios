//
//  MasterViewController.m
//  ESTBeacon
//

#import "DetailViewController.h"
#import "MasterViewController.h"

@interface MasterViewController ()
@property(nonatomic,copy) NSString *identifier;
@property(nonatomic,strong) ESTBeaconManager *beaconManager;
@property(nonatomic,copy) NSArray *beacons;
@end

@implementation MasterViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.beaconManager = [ESTBeaconManager new];
    _beaconManager.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_beaconManager startEstimoteBeaconsDiscoveryForRegion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_beaconManager stopEstimoteBeaconDiscovery];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowDetail"]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        detailViewController.beacon = _beacons[indexPath.row];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_beacons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconCell" forIndexPath:indexPath];
    ESTBeacon *beacon = _beacons[indexPath.row];
    NSData *colorData = beacon.macAddress ? [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"Colors"][beacon.macAddress] : nil;
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
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Major: %u, Minor: %u", @""), [beacon.major unsignedShortValue], [beacon.minor unsignedShortValue]];
    cell.detailTextLabel.text = [beacon.proximityUUID UUIDString];
    return cell;
}

#pragma mark - ESTBeaconManagerDelegate

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    self.beacons = beacons;
    [self.tableView reloadData];
}

- (void)beaconManager:(ESTBeaconManager *)manager didFailDiscoveryInRegion:(ESTBeaconRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
