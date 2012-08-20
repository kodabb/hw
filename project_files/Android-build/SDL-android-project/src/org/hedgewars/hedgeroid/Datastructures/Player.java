/*
 * Hedgewars for Android. An Android port of Hedgewars, a free turn based strategy game
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

package org.hedgewars.hedgeroid.Datastructures;

import java.util.Comparator;

/**
 * Basic information about a player on a server.
 */
public final class Player {
	public final String name;
	public final boolean registered, admin;
	
	public Player(String name, boolean registered, boolean admin) {
		this.name = name;
		this.registered = registered;
		this.admin = admin;
	}

	@Override
	public String toString() {
		return "Player [name=" + name + ", registered=" + registered
				+ ", admin=" + admin + "]";
	}

	public static Comparator<Player> NAME_ORDER = new Comparator<Player>() {
		public int compare(Player lhs, Player rhs) {
			return lhs.name.compareToIgnoreCase(rhs.name);
		}
	};
}
