//
//  DetailViewController.h
//  ESTBeacon
//

@import UIKit;

#import "ESTBeacon.h"

@interface DetailViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate, ESTBeaconDelegate>

@property(nonatomic,strong) ESTBeacon *beacon;

- (IBAction)powerDone:(UIStoryboardSegue *)segue;
- (IBAction)powerCancel:(UIStoryboardSegue *)segue;

@end
