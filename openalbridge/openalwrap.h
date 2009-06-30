/*
 * OpenAL Bridge - a simple portable library for OpenAL interface
 * Copyright (c) 2009 Vittorio Giovara <vittorio.giovara@gmail.com>
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

#ifndef _OALB_INTERFACE_H
#define _OALB_INTERFACE_H


#ifdef __CPLUSPLUS
extern "C" {
#endif 
		
	int openal_init				(int memorysize);
	int openal_close			(void);
	int openal_loadfile			(const char *filename);
	int openal_toggleloop		(int index);
	int openal_setvolume		(int index, unsigned char percentage);
	int openal_setglobalvolume	(unsigned char percentage);
	int openal_togglemute		(void);
	int openal_fadeout			(int index, unsigned int quantity);
	int openal_fadein			(int index, unsigned int quantity);
	int openal_fade				(int index, unsigned int quantity, char direction);
	int openal_playsound		(int index);	
	int openal_pausesound		(int index);
	int openal_stopsound		(int index);
	
#ifdef __CPLUSPLUS
}
#endif

#endif /*_OALB_INTERFACE_H*/
