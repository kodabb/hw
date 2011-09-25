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
 * File created on 07/03/2010.
 */


#import "WeaponCellView.h"
#import "CommodityFunctions.h"

@implementation WeaponCellView
@synthesize delegate, weaponName, weaponIcon, initialSli, probabilitySli, delaySli, crateSli, helpLabel,
            initialImg, probabilityImg, delayImg, crateImg, initialLab, probabilityLab, delayLab, crateLab;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        delegate = nil;

        weaponName = [[UILabel alloc] init];
        weaponName.backgroundColor = [UIColor clearColor];
        weaponName.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        weaponIcon = [[UIImageView alloc] init];

        initialSli = [[UISlider alloc] init];
        [initialSli addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [initialSli addTarget:self action:@selector(startDragging:) forControlEvents:UIControlEventTouchDown];
        [initialSli addTarget:self action:@selector(stopDragging:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        initialSli.maximumValue = 9;
        initialSli.minimumValue = 0;
        initialSli.tag = 100;

        probabilitySli = [[UISlider alloc] init];
        [probabilitySli addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [probabilitySli addTarget:self action:@selector(startDragging:) forControlEvents:UIControlEventTouchDown];
        [probabilitySli addTarget:self action:@selector(stopDragging:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        probabilitySli.maximumValue = 9;
        probabilitySli.minimumValue = 0;
        probabilitySli.tag = 200;

        delaySli = [[UISlider alloc] init];
        [delaySli addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [delaySli addTarget:self action:@selector(startDragging:) forControlEvents:UIControlEventTouchDown];
        [delaySli addTarget:self action:@selector(stopDragging:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        delaySli.maximumValue = 9;
        delaySli.minimumValue = 0;
        delaySli.tag = 300;

        crateSli = [[UISlider alloc] init];
        [crateSli addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [crateSli addTarget:self action:@selector(startDragging:) forControlEvents:UIControlEventTouchDown];
        [crateSli addTarget:self action:@selector(stopDragging:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        crateSli.maximumValue = 9;
        crateSli.minimumValue = 0;
        crateSli.tag = 400;

        NSString *imgAmmoStr = [[NSString alloc] initWithFormat:@"%@/ammopic.png",ICONS_DIRECTORY()];
        initialImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imgAmmoStr]];
        [imgAmmoStr release];
        NSString *imgDamageStr = [[NSString alloc] initWithFormat:@"%@/iconDamage.png",ICONS_DIRECTORY()];
        probabilityImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imgDamageStr]];
        [imgDamageStr release];
        NSString *imgTimeStr = [[NSString alloc] initWithFormat:@"%@/iconTime.png",ICONS_DIRECTORY()];
        delayImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imgTimeStr]];
        [imgTimeStr release];
        NSString *imgBoxStr = [[NSString alloc] initWithFormat:@"%@/iconBox.png",ICONS_DIRECTORY()];
        crateImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imgBoxStr]];
        [imgBoxStr release];

        initialLab = [[UILabel alloc] init];
        initialLab.backgroundColor = [UIColor clearColor];
        initialLab.textColor = [UIColor grayColor];
        initialLab.textAlignment = UITextAlignmentCenter;

        probabilityLab = [[UILabel alloc] init];
        probabilityLab.backgroundColor = [UIColor clearColor];
        probabilityLab.textColor = [UIColor grayColor];
        probabilityLab.textAlignment = UITextAlignmentCenter;

        delayLab = [[UILabel alloc] init];
        delayLab.backgroundColor = [UIColor clearColor];
        delayLab.textColor = [UIColor grayColor];
        delayLab.textAlignment = UITextAlignmentCenter;

        crateLab = [[UILabel alloc] init];
        crateLab.backgroundColor = [UIColor clearColor];
        crateLab.textColor = [UIColor grayColor];
        crateLab.textAlignment = UITextAlignmentCenter;

        helpLabel = [[UILabel alloc] init];
        helpLabel.backgroundColor = [UIColor clearColor];
        helpLabel.textColor = [UIColor grayColor];
        helpLabel.textAlignment = UITextAlignmentRight;
        helpLabel.font = [UIFont italicSystemFontOfSize:[UIFont smallSystemFontSize]];

        [self.contentView addSubview:weaponName];
        [self.contentView addSubview:weaponIcon];

        [self.contentView addSubview:initialSli];
        [self.contentView addSubview:probabilitySli];
        [self.contentView addSubview:delaySli];
        [self.contentView addSubview:crateSli];

        [self.contentView addSubview:initialImg];
        [self.contentView addSubview:probabilityImg];
        [self.contentView addSubview:delayImg];
        [self.contentView addSubview:crateImg];

        [self.contentView addSubview:initialLab];
        [self.contentView addSubview:probabilityLab];
        [self.contentView addSubview:delayLab];
        [self.contentView addSubview:crateLab];

        [self.contentView addSubview:helpLabel];
    }
    return self;
}

-(void) layoutSubviews {
    [super layoutSubviews];

    CGRect contentRect = self.contentView.bounds;
    CGFloat shiftSliders = contentRect.origin.x;
    CGFloat shiftLabel = 0;

    if (IS_IPAD()) {
        shiftSliders += 65;
        shiftLabel += 165;
    } else
        shiftSliders -= 13;

    weaponIcon.frame = CGRectMake(5, 5, 32, 32);
    weaponName.frame = CGRectMake(45, 8, 200, 25);
    
    helpLabel.frame = CGRectMake(shiftLabel + 200, 8, 250, 15);

    // second line
    initialImg.frame = CGRectMake(shiftSliders + 20, 40, 32, 32);
    initialLab.frame = CGRectMake(shiftSliders + 56, 40, 20, 32);
    initialLab.text = ((int)initialSli.value == 9) ? @"∞" : [NSString stringWithFormat:@"%d",(int)initialSli.value];
    initialSli.frame = CGRectMake(shiftSliders + 80, 40, 150, 32);

    probabilityImg.frame = CGRectMake(shiftSliders + 255, 40, 32, 32);
    probabilityLab.frame = CGRectMake(shiftSliders + 291, 40, 20, 32);
    probabilityLab.text = ((int)probabilitySli.value == 9) ? @"∞" : [NSString stringWithFormat:@"%d",(int)probabilitySli.value];
    probabilitySli.frame = CGRectMake(shiftSliders + 314, 40, 150, 32);

    // third line
    delayImg.frame = CGRectMake(shiftSliders + 20, 80, 32, 32);
    delayLab.frame = CGRectMake(shiftSliders + 56, 80, 20, 32);
    delayLab.text = ((int)delaySli.value == 9) ? @"∞" : [NSString stringWithFormat:@"%d",(int)delaySli.value];
    delaySli.frame = CGRectMake(shiftSliders + 80, 80, 150, 32);

    crateImg.frame = CGRectMake(shiftSliders + 255, 80, 32, 32);
    crateLab.frame = CGRectMake(shiftSliders + 291, 80, 20, 32);
    crateLab.text = ((int)crateSli.value == 9) ? @"∞" : [NSString stringWithFormat:@"%d",(int)crateSli.value];
    crateSli.frame = CGRectMake(shiftSliders + 314, 80, 150, 32);
}

/*
-(void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
*/

-(void) valueChanged:(id) sender {
    if (self.delegate != nil) {
        initialLab.text = ((int)initialSli.value == 9) ? @"∞" : [NSString stringWithFormat:@"%d",(int)initialSli.value];
        probabilityLab.text = ((int)probabilitySli.value == 9) ? @"∞" : [NSString stringWithFormat:@"%d",(int)probabilitySli.value];
        delayLab.text = ((int)delaySli.value == 9) ? @"∞" : [NSString stringWithFormat:@"%d",(int)delaySli.value];
        crateLab.text = ((int)crateSli.value == 9) ? @"∞" : [NSString stringWithFormat:@"%d",(int)crateSli.value];

        [delegate updateValues:[NSArray arrayWithObjects:
                                [NSNumber numberWithInt:(int)initialSli.value],
                                [NSNumber numberWithInt:(int)probabilitySli.value],
                                [NSNumber numberWithInt:(int)delaySli.value],
                                [NSNumber numberWithInt:(int)crateSli.value], nil]
                       atIndex:self.tag];
    } else
        DLog(@"error - delegate = nil!");
}

-(void) startDragging:(id) sender {
    UISlider *slider = (UISlider *)sender;
    NSString *str = nil;
    
    switch (slider.tag) {
        case 100:
            str = NSLocalizedString(@"Initial quantity ",@"ammo selection");
            break;
        case 200:
            str = NSLocalizedString(@"Presence probability in crates ",@"ammo selection");
            break;
        case 300:
            str = NSLocalizedString(@"Number of turns before you can use this weapon ",@"ammo selection");
            break;
        case 400:
            str = NSLocalizedString(@"Quantity that you will find in a crate ",@"ammo selection");
            break;
        default:
            DLog(@"Nope");
            break;
    }
    self.helpLabel.text = str;
}

-(void) stopDragging:(id) sender {
    self.helpLabel.text = @"";
}

-(void) dealloc {
    self.delegate = nil;
    releaseAndNil(weaponName);
    releaseAndNil(weaponIcon);
    releaseAndNil(initialSli);
    releaseAndNil(probabilitySli);
    releaseAndNil(delaySli);
    releaseAndNil(crateSli);
    releaseAndNil(initialImg);
    releaseAndNil(probabilityImg);
    releaseAndNil(delayImg);
    releaseAndNil(crateImg);
    releaseAndNil(initialLab);
    releaseAndNil(probabilityLab);
    releaseAndNil(delayLab);
    releaseAndNil(crateLab);
    releaseAndNil(helpLabel);
    [super dealloc];
}

@end
