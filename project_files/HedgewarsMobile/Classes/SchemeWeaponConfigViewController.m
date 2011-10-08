/*
 * Hedgewars-iOS, a Hedgewars port for iOS devices
 * Copyright (c) 2009-2011 Vittorio Giovara <vittorio.giovara@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * File created on 13/06/2010.
 */


#import "SchemeWeaponConfigViewController.h"


#define LABEL_TAG 57423

@implementation SchemeWeaponConfigViewController
@synthesize listOfSchemes, listOfWeapons, listOfScripts, lastIndexPath_sc, lastIndexPath_we, lastIndexPath_lu,
            selectedScheme, selectedWeapon, selectedScript, scriptCommand, topControl, hideSections;

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return rotationManager(interfaceOrientation);
}

#pragma mark -
#pragma mark custom setters/getters
-(NSString *)selectedScheme {
    if (selectedScheme == nil)
        self.selectedScheme = @"Default.plist";
    return selectedScheme;
}

-(NSString *)selectedWeapon {
    if (selectedWeapon == nil)
        self.selectedWeapon = @"Default.plist";
    return selectedWeapon;
}

-(NSString *)selectedScript {
    if (selectedScript == nil)
        self.selectedScript = @"Normal.plist";
    return selectedScript;
}

-(NSString *)scriptCommand {
    if (scriptCommand == nil)
        self.scriptCommand = @"";
    return scriptCommand;
}

-(NSArray *)listOfSchemes {
    if (listOfSchemes == nil)
        self.listOfSchemes = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:SCHEMES_DIRECTORY() error:NULL];
    return listOfSchemes;
}

-(NSArray *)listOfWeapons {
    if (listOfWeapons == nil)
        self.listOfWeapons = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:WEAPONS_DIRECTORY() error:NULL];
    return listOfWeapons;
}

-(NSArray *)listOfScripts {
    if (listOfScripts == nil)
        self.listOfScripts = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:SCRIPTS_DIRECTORY() error:NULL];
    return listOfScripts;
}

-(UISegmentedControl *)topControl {
    if (topControl == nil) {
        NSArray *array = [[NSArray alloc] initWithObjects:
                          NSLocalizedString(@"Scheme",@""),
                          NSLocalizedString(@"Weapon",@""),
                          NSLocalizedString(@"Style",@""),nil];
        UISegmentedControl *controller = [[UISegmentedControl alloc] initWithItems:array];
        [array release];
        [controller addTarget:self.tableView action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
        controller.segmentedControlStyle = UISegmentedControlStyleBar;
        controller.tintColor = [UIColor lightGrayColor];
        controller.selectedSegmentIndex = 0;
        self.topControl = controller;
        [controller release];
    }
    return topControl;
}

-(void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle
-(void) viewDidLoad {
    [super viewDidLoad];

    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.view.frame = CGRectMake(0, 0, screenSize.height, screenSize.width - 44);

    if ([self.tableView respondsToSelector:@selector(setBackgroundView:)]) {
        if (IS_IPAD())
            [self.tableView setBackgroundView:nil];
        else {
            UIImage *backgroundImage = [[UIImage alloc] initWithContentsOfFile:@"background~iphone.png"];
            UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
            [backgroundImage release];
            [self.tableView setBackgroundView:background];
            [background release];
        }
    } else {
        self.view.backgroundColor = [UIColor blackColor];
    }

    self.tableView.separatorColor = [UIColor darkYellowColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark -
#pragma mark Table view data source
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.hideSections ? 0 : 1);
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.topControl.selectedSegmentIndex == 0)
        return [self.listOfSchemes count];
    else if (self.topControl.selectedSegmentIndex == 1)
        return [self.listOfWeapons count];
    else
        return [self.listOfScripts count];
}

// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    NSInteger index = self.topControl.selectedSegmentIndex;
    NSInteger row = [indexPath row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];

    cell.accessoryView = nil;
    if (0 == index) {
        cell.textLabel.text = [[self.listOfSchemes objectAtIndex:row] stringByDeletingPathExtension];
        NSString *str = [NSString stringWithFormat:@"%@/%@",SCHEMES_DIRECTORY(),[self.listOfSchemes objectAtIndex:row]];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:str];
        cell.detailTextLabel.text = [dict objectForKey:@"description"];
        [dict release];
        if ([[self.listOfSchemes objectAtIndex:row] isEqualToString:self.selectedScheme]) {
            UIImageView *checkbox = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"checkbox.png"]];
            cell.accessoryView = checkbox;
            [checkbox release];
            self.lastIndexPath_sc = indexPath;
        }
    } else if (1 == index) {
        cell.textLabel.text = [[self.listOfWeapons objectAtIndex:row] stringByDeletingPathExtension];
        NSString *str = [NSString stringWithFormat:@"%@/%@",WEAPONS_DIRECTORY(),[self.listOfWeapons objectAtIndex:row]];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:str];
        cell.detailTextLabel.text = [dict objectForKey:@"description"];
        [dict release];
        if ([[self.listOfWeapons objectAtIndex:row] isEqualToString:self.selectedWeapon]) {
            UIImageView *checkbox = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"checkbox.png"]];
            cell.accessoryView = checkbox;
            [checkbox release];
            self.lastIndexPath_we = indexPath;
        }
    } else {
        cell.textLabel.text = [[self.listOfScripts objectAtIndex:row] stringByDeletingPathExtension];
        NSString *str = [NSString stringWithFormat:@"%@/%@",SCRIPTS_DIRECTORY(),[self.listOfScripts objectAtIndex:row]];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:str];
        cell.detailTextLabel.text = [dict objectForKey:@"description"];
        [dict release];
        if ([[self.listOfScripts objectAtIndex:row] isEqualToString:self.selectedScript]) {
            UIImageView *checkbox = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"checkbox.png"]];
            cell.accessoryView = checkbox;
            [checkbox release];
            self.lastIndexPath_lu = indexPath;
        }
    }

    cell.backgroundColor = [UIColor blackColorTransparent];
    cell.textLabel.textColor = [UIColor lightYellowColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *theView = [[[UIView alloc] init] autorelease];
    self.topControl.frame = CGRectMake(0, 0, self.view.frame.size.width * 80/100, 30);
    self.topControl.center = CGPointMake(self.view.frame.size.width/2, 24);
    [theView addSubview:self.topControl];
    return theView;
}

#pragma mark -
#pragma mark Table view delegate
-(void) tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *lastIndexPath;
    NSInteger index = self.topControl.selectedSegmentIndex;
    if (index == 0)
        lastIndexPath = self.lastIndexPath_sc;
    else if (index == 1)
        lastIndexPath = self.lastIndexPath_we;
    else
        lastIndexPath = self.lastIndexPath_lu;

    int newRow = [indexPath row];
    int oldRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;

    if (newRow != oldRow) {
        //TODO: this code works only for a single section table
        UITableViewCell *newCell = [aTableView cellForRowAtIndexPath:indexPath];
        UIImageView *checkbox = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"checkbox.png"]];
        newCell.accessoryView = checkbox;
        [checkbox release];
        UITableViewCell *oldCell = [aTableView cellForRowAtIndexPath:lastIndexPath];
        oldCell.accessoryView = nil;

        if (index == 0) {
            self.lastIndexPath_sc = indexPath;
            self.selectedScheme = [self.listOfSchemes objectAtIndex:newRow];

            // also set weaponset when selecting scheme, if set
            NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
            if ([[settings objectForKey:@"sync_ws"] boolValue]) {
                for (NSString *str in self.listOfWeapons) {
                    if ([str isEqualToString:self.selectedScheme]) {
                        int index = [self.listOfSchemes indexOfObject:str];
                        self.selectedWeapon = str;
                        self.lastIndexPath_we = [NSIndexPath indexPathForRow:index inSection:1];
                        [self.tableView reloadData];
                        break;
                    }
                }
            }
        } else if (index == 1) {
            self.lastIndexPath_we = indexPath;
            self.selectedWeapon = [self.listOfWeapons objectAtIndex:newRow];
        } else {
            self.lastIndexPath_lu = indexPath;
            self.selectedScript = [self.listOfScripts objectAtIndex:newRow];

            // some styles disable or force the choice of a particular scheme/weaponset
            NSString *path = [[NSString alloc] initWithFormat:@"%@/%@",SCRIPTS_DIRECTORY(),self.selectedScript];
            NSDictionary *scriptDict = [[NSDictionary alloc] initWithContentsOfFile:path];
            [path release];
            self.scriptCommand = [scriptDict objectForKey:@"command"];
            NSString *scheme = [scriptDict objectForKey:@"scheme"];
            if ([scheme isEqualToString:@""]) {
                self.selectedScheme = @"Default.plist";
                [self.topControl setEnabled:NO forSegmentAtIndex:0];
            } else {
                self.selectedScheme = scheme;
                [self.topControl setEnabled:YES forSegmentAtIndex:0];
            }

            NSString *weapon = [scriptDict objectForKey:@"weapon"];
            if ([weapon isEqualToString:@""]) {
                self.selectedWeapon = @"Default.plist";
                [self.topControl setEnabled:NO forSegmentAtIndex:1];
            } else {
                self.selectedWeapon = weapon;
                [self.topControl setEnabled:YES forSegmentAtIndex:1];
            }

            [scriptDict release];
        }

        [aTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark called externally to empty or fill the sections completely
-(void) fillSections {
    if (self.hideSections == YES) {
        self.hideSections = NO;
        NSRange range;
        range.location = 0;
        range.length = 1;
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
        self.tableView.scrollEnabled = YES;

        [[self.view viewWithTag:LABEL_TAG] removeFromSuperview];
    }
}

-(void) emptySections {
    hideSections = YES;
    NSRange range;
    range.location = 0;
    range.length = 1;
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
    self.tableView.scrollEnabled = NO;

    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width * 80/100, 60);
    UILabel *theLabel = [[UILabel alloc] initWithFrame:frame
                                              andTitle:NSLocalizedString(@"Missions don't need further configuration",@"")];
    theLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    theLabel.numberOfLines = 2;
    theLabel.tag = LABEL_TAG;

    [self.view addSubview:theLabel];
    [theLabel release];
}

#pragma mark -
#pragma mark Memory management
-(void) didReceiveMemoryWarning {
    if ([[HedgewarsAppDelegate sharedAppDelegate] isInGame]) {
        self.lastIndexPath_sc = nil;
        self.lastIndexPath_we = nil;
        self.lastIndexPath_lu = nil;
        self.selectedScheme = nil;
        self.selectedWeapon = nil;
        self.selectedScript = nil;
        self.scriptCommand = nil;
        self.topControl = nil;
    }
    self.listOfSchemes = nil;
    self.listOfWeapons = nil;
    self.listOfScripts = nil;
    MSG_MEMCLEAN();
    [super didReceiveMemoryWarning];
}

-(void) viewDidUnload {
    self.listOfSchemes = nil;
    self.listOfWeapons = nil;
    self.listOfScripts = nil;
    self.lastIndexPath_sc = nil;
    self.lastIndexPath_we = nil;
    self.lastIndexPath_lu = nil;
    self.selectedScheme = nil;
    self.selectedWeapon = nil;
    self.selectedScript = nil;
    self.scriptCommand = nil;
    self.topControl = nil;
    MSG_DIDUNLOAD();
    [super viewDidUnload];
}

-(void) dealloc {
    releaseAndNil(listOfSchemes);
    releaseAndNil(listOfWeapons);
    releaseAndNil(listOfScripts);
    releaseAndNil(lastIndexPath_sc);
    releaseAndNil(lastIndexPath_we);
    releaseAndNil(lastIndexPath_lu);
    releaseAndNil(selectedScheme);
    releaseAndNil(selectedWeapon);
    releaseAndNil(selectedScript);
    releaseAndNil(scriptCommand);
    releaseAndNil(topControl);
    [super dealloc];
}


@end

