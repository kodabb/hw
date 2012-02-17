/*
 * Hedgewars-iOS, a Hedgewars port for iOS devices
 * Copyright (c) 2009-2012 Vittorio Giovara <vittorio.giovara@gmail.com>
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
 * File created on 18/04/2012.
 */


#import <Foundation/Foundation.h>

@class EngineProtocolNetwork;

@interface GameInterfaceBridge : NSObject {
    UIView *blackView;
    NSString *savePath;
    EngineProtocolNetwork *proto;
}

@property (nonatomic,retain) UIView *blackView;
@property (nonatomic,retain) NSString *savePath;
@property (nonatomic,retain) EngineProtocolNetwork *proto;

+(void) startLocalGame:(NSDictionary *)withOptions;
+(void) startSaveGame:(NSString *)atPath;
+(void) startMissionGame:(NSString *)withScript;

+(void) registerCallingController:(UIViewController *)controller;

@end
