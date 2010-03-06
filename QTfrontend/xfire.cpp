/*
 * Hedgewars Xfire integration
 * Copyright (c) 2010 Mario Liebisch <mario.liebisch AT googlemail.com>
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
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */

#include <string>
#include <stdio.h>

#include "xfire.h"
#include "../misc/xfire/xfiregameclient.h"

// use_xfire: stores if xfire is loaded and functions should do something at all
bool use_xfire = false;
char *keys[XFIRE_KEY_COUNT];
char *values[XFIRE_KEY_COUNT];

// xfire_init(): used to initialize all variables and set their default values
void xfire_init(void)
{
    if(use_xfire)
        return;
    use_xfire = XfireIsLoaded() == 1;
    
    if(!use_xfire)
        return;
    
    for(int i = 0; i < XFIRE_KEY_COUNT; i++)
    {
        keys[i] = new char[256];
        values[i] = new char[256];
        strcpy(keys[i], "");
        strcpy(values[i], "");
    }
    
    strcpy(keys[XFIRE_NICKNAME], "Nickname");
    strcpy(keys[XFIRE_ROOM], "Room");
    strcpy(keys[XFIRE_SERVER], "Server");
    strcpy(keys[XFIRE_STATUS], "Status");
    xfire_update();
}

// xfire_free(): used to free up ressources used etc.
void xfire_free(void)
{
    if(!use_xfire)
        return;
    
    for(int i = 0; i < XFIRE_KEY_COUNT; i++)
    {
        delete [] keys[i];
        delete [] values[i];
    }
}

// xfire_setvalue(): set a specific value
void xfire_setvalue(const XFIRE_KEYS status, const char *value)
{
    if(!use_xfire || strlen(value) > 255)
        return;
    strcpy(values[status], value);
}

// xfire_update(): submits current values to the xfire app
void xfire_update(void)
{
    if(!use_xfire)
        return;
    XfireSetCustomGameDataA(XFIRE_KEY_COUNT, (const char**)keys, (const char**)values);
}
