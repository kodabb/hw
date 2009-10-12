/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2007 Andrey Korotaev <unC0Rr@gmail.com>
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

#include "SDLs.h"

#include "SDL.h"
#include "hwconsts.h"

#include <QApplication>

extern char sdlkeys[1024][2][128];
extern char xb360buttons[][128];
extern char xb360dpad[128];
extern char xbox360axes[][128];

bool hardware;
extern char *programname;

SDLInteraction::SDLInteraction()
{
	music = -1;
	hardware = false;
	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK);


	if(SDL_NumJoysticks())
		addGameControllerKeys();
	SDL_QuitSubSystem(SDL_INIT_JOYSTICK);
}

SDLInteraction::~SDLInteraction()
{
	SDL_Quit();
	openal_close();
}

void SDLInteraction::setHardwareSound(bool hardware_snd)
{
	hardware = hardware_snd;
}

QStringList SDLInteraction::getResolutions() const
{
	QStringList result;

	SDL_Rect **modes;

	modes = SDL_ListModes(NULL, SDL_FULLSCREEN);

	if((modes == (SDL_Rect **)0) || (modes == (SDL_Rect **)-1))
	{
		result << "640x480";
	} else
	{
		for(int i = 0; modes[i]; ++i)
			if ((modes[i]->w >= 640) && (modes[i]->h >= 480))
				result << QString("%1x%2").arg(modes[i]->w).arg(modes[i]->h);
	}

	return result;
}

void SDLInteraction::addGameControllerKeys() const
{
	QStringList result;

	int i = 0;
	while(i < 1024 && sdlkeys[i][1][0] != '\0')
		i++;

	// Iterate through all game controllers
	for(int jid = 0; jid < SDL_NumJoysticks(); jid++)
	{
		SDL_Joystick* joy = SDL_JoystickOpen(jid);
		
		// Retrieve the game controller's name and strip "Controller (...)" that's added by some drivers (English only)
		QString joyname = QString(SDL_JoystickName(jid)).replace(QRegExp("^Controller \\((.*)\\)$"), "\\1");

		// Connected Xbox 360 controller? Use specific button names then
		// Might be interesting to add 'named' buttons for the most often used gamepads
		bool isxb = joyname.contains("Xbox 360");

		// This part of the string won't change for multiple keys/hats, so keep it
		QString prefix = QString("%1 (%2): ").arg(joyname).arg(jid + 1);

		// Register entries for missing axes not assigned to sticks of this joystick/gamepad
		for(int aid = 0; aid < SDL_JoystickNumAxes(joy) && i < 1021; aid++)
		{
			// Axis 2 on xbox 360 is left/right trigger but those are used as buttons anyway so skip it
			if(aid == 2 && isxb)
				continue;

			// Again store the part of the string not changing for multiple uses
			QString axis = prefix + QApplication::translate("binds (keys)", "Axis") + QString(" %1 ").arg(aid + 1);
			
			// Entry for "Axis Up"
			sprintf(sdlkeys[i][0], "j%da%du", jid, aid);
			sprintf(sdlkeys[i++][1], "%s", ((isxb && aid < 5) ? (prefix + QApplication::translate("binds (keys)", xbox360axes[aid * 2])) : axis + QApplication::translate("binds (keys)", "(Up)")).toStdString().c_str());

			// Entry for "Axis Down"
			sprintf(sdlkeys[i][0], "j%da%dd", jid, aid);
			sprintf(sdlkeys[i++][1], "%s", ((isxb && aid < 5) ? (prefix + QApplication::translate("binds (keys)", xbox360axes[aid * 2 + 1])) : axis + QApplication::translate("binds (keys)", "(Down)")).toStdString().c_str());
		}

		// Register entries for all coolie hats of this joystick/gamepad
		for(int hid = 0; hid < SDL_JoystickNumHats(joy) && i < 1019; hid++)
		{
			// Again store the part of the string not changing for multiple uses
			QString hat = prefix + (isxb ? (QApplication::translate("binds (keys)", xb360dpad) + QString(" ")) : QApplication::translate("binds (keys)", "Hat") + QString(" %1 ").arg(hid + 1));

			// Entry for "Hat Up"
			sprintf(sdlkeys[i][0], "j%dh%du", jid, hid);			
			sprintf(sdlkeys[i++][1], "%s", (hat + QApplication::translate("binds (keys)", "(Up)")).toStdString().c_str());

			// Entry for "Hat Down"
			sprintf(sdlkeys[i][0], "j%dh%dd", jid, hid);			
			sprintf(sdlkeys[i++][1], "%s", (hat + QApplication::translate("binds (keys)", "(Down)")).toStdString().c_str());

			// Entry for "Hat Left"
			sprintf(sdlkeys[i][0], "j%dh%dl", jid, hid);			
			sprintf(sdlkeys[i++][1], "%s", (hat + QApplication::translate("binds (keys)", "(Left)")).toStdString().c_str());

			// Entry for "Hat Right"
			sprintf(sdlkeys[i][0], "j%dh%dr", jid, hid);			
			sprintf(sdlkeys[i++][1], "%s", (hat + QApplication::translate("binds (keys)", "(Right)")).toStdString().c_str());
		}
		
		// Register entries for all buttons of this joystick/gamepad
		for(int bid = 0; bid < SDL_JoystickNumButtons(joy) && i < 1022; bid++)
		{
			// Buttons
			sprintf(sdlkeys[i][0], "j%db%d", jid, bid);			
			sprintf(sdlkeys[i++][1], "%s", (prefix + ((isxb && bid < 10) ? (QApplication::translate("binds (keys)", xb360buttons[bid]) + QString(" ")) : QApplication::translate("binds (keys)", "Button") + QString(" %1").arg(bid + 1))).toStdString().c_str());
		}
		// Close the game controller as we no longer need it
		SDL_JoystickClose(joy);
	}
	
	// Terminate the list
	sdlkeys[i][0][0] = '\0';
	sdlkeys[i][1][0] = '\0';
}

void SDLInteraction::StartMusic()
{
	OpenAL_Init();
	if (music < 0) {
		music = openal_loadfile(QString(datadir->absolutePath() + "/Music/main theme.ogg").toLocal8Bit().constData());
		openal_toggleloop(music);
	
	}
	openal_setvolume(music, 60);
	openal_fadein(music, 30);
}

void SDLInteraction::StopMusic()
{
	if (music >= 0) openal_fadeout(music, 40);
}

//we need thjs wrapper because of some issues with windows drivers
//beware that this cause a slight delay when playing the first sound
void OpenAL_Init()
{
	if (!openal_ready())
        	openal_init(programname, hardware ? 1 : 0, 5);
}

