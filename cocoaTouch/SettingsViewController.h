//
//  SettingsViewController.h
//  hwengine
//
//  Created by Vittorio on 08/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITextField *username;
	UITextField *password;
	UISwitch *musicSwitch;
	UISwitch *effectsSwitch;
	UISwitch *altDamageSwitch;
	UISlider *volumeSlider;
	UILabel *volumeLabel;
	UITableView *table;
	UITableViewCell *volumeCell;
}
@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) UISwitch *musicSwitch;
@property (nonatomic, retain) UISwitch *effectsSwitch;
@property (nonatomic, retain) UISwitch *altDamageSwitch;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) IBOutlet UILabel *volumeLabel;
@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UITableViewCell *volumeCell;

-(IBAction) sliderChanged: (id)sender;
-(IBAction) backgroundTap: (id)sender;
-(IBAction) textFieldDoneEditing: (id)sender;
@end
