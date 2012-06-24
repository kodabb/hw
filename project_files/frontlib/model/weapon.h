#ifndef MODEL_WEAPON_H_
#define MODEL_WEAPON_H_

#include "../hwconsts.h"

/**
 * These values are all in the range 0..9
 *
 * For loadout, 9 means inifinite ammo.
 * For the other setting, 9 is invalid.
 */
typedef struct {
	int _referenceCount;
	char loadout[WEAPONS_COUNT+1];
	char crateprob[WEAPONS_COUNT+1];
	char crateammo[WEAPONS_COUNT+1];
	char delay[WEAPONS_COUNT+1];
	char *name;
} flib_weaponset;

typedef struct {
	int _referenceCount;
	int weaponsetCount;
	flib_weaponset **weaponsets;
} flib_weaponsetlist;

/**
 * Returns a new weapon set, or NULL on error.
 * name must not be NULL.
 *
 * The new weapon set is pre-filled with default
 * settings (see hwconsts.h)
 */
flib_weaponset *flib_weaponset_create(const char *name);

/**
 * Increase the reference count of the object. Call this if you store a pointer to it somewhere.
 * Returns the parameter.
 */
flib_weaponset *flib_weaponset_retain(flib_weaponset *weaponset);

/**
 * Decrease the reference count of the object and free it if this was the last reference.
 */
void flib_weaponset_release(flib_weaponset *weaponset);

/**
 * Create a weaponset from an ammostring. This format is used both in the ini files
 * and in the net protocol.
 */
flib_weaponset *flib_weaponset_from_ammostring(const char *name, const char *ammostring);

/**
 * Load a list of weaponsets from the ini file.
 * Returns NULL on error.
 */
flib_weaponsetlist *flib_weaponsetlist_from_ini(const char *filename);

/**
 * Store the list of weaponsets to an ini file.
 * Returns NULL on error.
 */
int flib_weaponsetlist_to_ini(const char *filename, const flib_weaponsetlist *weaponsets);

/**
 * Create an empty weaponset list. Returns NULL on error.
 */
flib_weaponsetlist *flib_weaponsetlist_create();

/**
 * Insert a new weaponset into the list at position pos, moving all higher weaponsets to make place.
 * pos must be at least 0 (insert at the start) and at most list->weaponsetCount (insert at the end).
 * The weaponset is retained automatically.
 * Returns 0 on success.
 */
int flib_weaponsetlist_insert(flib_weaponsetlist *list, flib_weaponset *weaponset, int pos);

/**
 * Delete a weaponset from the list at position pos, moving down all higher weaponsets.
 * The weaponset is released automatically.
 * Returns 0 on success.
 */
int flib_weaponsetlist_delete(flib_weaponsetlist *list, int pos);

/**
 * Increase the reference count of the object. Call this if you store a pointer to it somewhere.
 * Returns the parameter.
 */
flib_weaponsetlist *flib_weaponsetlist_retain(flib_weaponsetlist *list);

/**
 * Decrease the reference count of the object and free it if this was the last reference.
 */
void flib_weaponsetlist_release(flib_weaponsetlist *list);

#endif
