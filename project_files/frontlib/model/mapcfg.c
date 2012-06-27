/*
 * Hedgewars, a free turn based strategy game
 * Copyright (C) 2012 Simeon Maxein <smaxein@googlemail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "mapcfg.h"

#include "../util/util.h"
#include "../util/logging.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

void removeNewline(char *str) {
	for(;*str;str++) {
		if(*str=='\n' || *str=='\r') {
			*str = 0;
			return;
		}
	}
}

int flib_mapcfg_read(const char *dataDirPath, const char *mapname, flib_mapcfg *out) {
	int result = -1;
	if(!log_badparams_if(!dataDirPath || !mapname || !out)
			&& !log_e_if(flib_contains_dir_separator(mapname), "Illegal character in mapname %s", mapname)) {
		char *path = flib_asprintf("%sMaps/%s/map.cfg", dataDirPath, mapname);
		if(path) {
			FILE *file = fopen(path, "rb");
			if(!log_e_if(!file, "Unable to open map config file %s", path)) {
				if(!log_e_if(!fgets(out->theme, sizeof(out->theme), file), "Error reading theme from %s", path)) {
					removeNewline(out->theme);
					char buf[64];
					if(!log_e_if(!fgets(buf, sizeof(buf), file), "Error reading hoglimit from %s", path)) {
						removeNewline(buf);
						errno = 0;
						out->hogLimit = strtol(buf, NULL, 10);
						result = !log_e_if(errno, "Invalid hoglimit in %s: %i", path, buf);
					}
				}
				fclose(file);
			}
		}
		free(path);
	}
	return result;
}
