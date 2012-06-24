/**
 * This file defines a data structure for a hedgewars team.
 *
 * Teams are used in several different contexts in Hedgewars, and some of these require
 * extra information about teams. For example, the weaponset is important
 * to the engine, but not for ini reading/writing, and with the team statistics it is the
 * other way around. To keep things simple, the data structure can hold all information
 * used in any context. On the downside, tat means we can't use static typing to ensure
 * that team information is "complete" for a particular purpose.
 */
#ifndef TEAM_H_
#define TEAM_H_


#include "weapon.h"
#include "../hwconsts.h"

#include <stdbool.h>
#include <stdint.h>

#define TEAM_DEFAULT_HEALTH 100

typedef struct {
	char *action;
	char *binding;
} flib_binding;

typedef struct {
	char *name;
	char *hat;

	// Statistics. They are irrelevant for the engine or server,
	// but provided for ini reading/writing by the frontend.
	int rounds;
	int kills;
	int deaths;
	int suicides;

	int difficulty;

	// Transient setting used in game setup
	int initialHealth;
	flib_weaponset *weaponset;
} flib_hog;

typedef struct {
	int _referenceCount;
	flib_hog hogs[HEDGEHOGS_PER_TEAM];
	char *name;
	char *grave;
	char *fort;
	char *voicepack;
	char *flag;

	flib_binding *bindings;
	int bindingCount;

	// Statistics. They are irrelevant for the engine or server,
	// but provided for ini reading/writing by the frontend.
	int rounds;
	int wins;
	int campaignProgress;

	// Transient settings used in game setup
	uint32_t color;
	int hogsInGame;
	bool remoteDriven;
	char *ownerName;
} flib_team;

/**
 * Returns a new team, or NULL on error. name must not be NULL.
 *
 * The new team is pre-filled with default settings (see hwconsts.h)
 */
flib_team *flib_team_create(const char *name);

/**
 * Loads a team, returns NULL on error.
 */
flib_team *flib_team_from_ini(const char *filename);

/**
 * Write the team to an ini file. Attempts to retain extra ini settings
 * that were already present. Note that not all fields of a team struct
 * are stored in the ini, some are only used intermittently to store
 * information about a team in the context of a game.
 *
 * The flib_team can handle "difficulty" on a per-hog basis, but it
 * is only written per-team in the team file. The difficulty of the
 * first hog is used for the entire team when writing.
 */
int flib_team_to_ini(const char *filename, const flib_team *team);

/**
 * Set the same weaponset for every hog in the team
 */
void flib_team_set_weaponset(flib_team *team, flib_weaponset *set);

/**
 * Increase the reference count of the object. Call this if you store a pointer to it somewhere.
 * Returns the parameter.
 */
flib_team *flib_team_retain(flib_team *team);

/**
 * Decrease the reference count of the object and free it if this was the last reference.
 */
void flib_team_release(flib_team *team);

/**
 * Create a deep copy of a team. Returns NULL on failure.
 * The referenced weaponsets are not copied, so the new
 * team references the same weaponsets.
 */
flib_team *flib_team_copy(flib_team *team);

#endif /* TEAM_H_ */
