#include "schemelist.h"

#include "../util/inihelper.h"
#include "../util/logging.h"
#include "../util/util.h"
#include "../util/refcounter.h"
#include "../util/list.h"

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>

static void flib_schemelist_destroy(flib_schemelist *list) {
	if(list) {
		for(int i=0; i<list->schemeCount; i++) {
			flib_cfg_release(list->schemes[i]);
		}
		free(list);
	}
}

static char *makePrefixedName(int schemeIndex, const char *settingName) {
	return flib_asprintf("%i\\%s", schemeIndex, settingName);
}

static int readSettingsFromIni(flib_ini *ini, flib_cfg *scheme, int index) {
	flib_cfg_meta *meta = scheme->meta;
	bool error = false;
	for(int i=0; i<meta->settingCount && !error; i++) {
		char *key = makePrefixedName(index, meta->settings[i].name);
		if(!key) {
			error = true;
		} else if(flib_ini_get_int_opt(ini, &scheme->settings[i], key, meta->settings[i].def)) {
			flib_log_e("Error reading setting %s in schemes file.", key);
			error = true;
		}
		free(key);
	}
	return error;
}

static int readModsFromIni(flib_ini *ini, flib_cfg *scheme, int index) {
	flib_cfg_meta *meta = scheme->meta;
	bool error = false;
	for(int i=0; i<meta->modCount && !error; i++) {
		char *key = makePrefixedName(index, meta->mods[i].name);
		if(!key) {
			error = true;
		} else if(flib_ini_get_bool_opt(ini, &scheme->mods[i], key, false)) {
			flib_log_e("Error reading mod %s in schemes file.", key);
			error = true;
		}
		free(key);
	}
	return error;
}

static flib_cfg *readSchemeFromIni(flib_cfg_meta *meta, flib_ini *ini, int index) {
	flib_cfg *result = NULL;
	char *schemeNameKey = makePrefixedName(index+1, "name");
	if(schemeNameKey) {
		char *schemeName = NULL;
		if(!flib_ini_get_str_opt(ini, &schemeName, schemeNameKey, "Unnamed")) {
			flib_cfg *scheme = flib_cfg_create(meta, schemeName);
			if(scheme) {
				if(!readSettingsFromIni(ini, scheme, index) && !readModsFromIni(ini, scheme, index)) {
					result = flib_cfg_retain(scheme);
				}
			}
			flib_cfg_release(scheme);
		}
		free(schemeName);
	}
	free(schemeNameKey);
	return result;
}

static flib_schemelist *fromIniHandleError(flib_schemelist *result, flib_ini *ini) {
	flib_ini_destroy(ini);
	flib_schemelist_destroy(result);
	return NULL;
}

flib_schemelist *flib_schemelist_from_ini(flib_cfg_meta *meta, const char *filename) {
	flib_schemelist *list = NULL;
	if(!meta || !filename) {
		flib_log_e("null parameter in flib_schemelist_from_ini");
		return NULL;
	}
	flib_ini *ini = flib_ini_load(filename);
	if(!ini || flib_ini_enter_section(ini, "schemes")) {
		flib_log_e("Missing file or missing section \"schemes\" in file %s.", filename);
		return fromIniHandleError(list, ini);
	}

	list = flib_schemelist_create();
	if(!list) {
		return fromIniHandleError(list, ini);
	}

	int schemeCount = 0;
	if(flib_ini_get_int(ini, &schemeCount, "size")) {
		flib_log_e("Missing or malformed scheme count in config file %s.", filename);
		return fromIniHandleError(list, ini);
	}

	for(int i=0; i<schemeCount; i++) {
		flib_cfg *scheme = readSchemeFromIni(meta, ini, i);
		if(!scheme || flib_schemelist_insert(list, scheme, i)) {
			flib_cfg_release(scheme);
			flib_log_e("Error reading scheme %i from config file %s.", i, filename);
			return fromIniHandleError(list, ini);
		}
		flib_cfg_release(scheme);
	}


	flib_ini_destroy(ini);
	return list;
}

static int writeSchemeToIni(flib_cfg *scheme, flib_ini *ini, int index) {
	flib_cfg_meta *meta = scheme->meta;
	bool error = false;

	char *key = makePrefixedName(index+1, "name");
	error |= !key || flib_ini_set_str(ini, key, scheme->schemeName);
	free(key);

	for(int i=0; i<meta->modCount && !error; i++) {
		char *key = makePrefixedName(index+1, meta->mods[i].name);
		error |= !key || flib_ini_set_bool(ini, key, scheme->mods[i]);
		free(key);
	}

	for(int i=0; i<meta->settingCount && !error; i++) {
		char *key = makePrefixedName(index+1, meta->settings[i].name);
		error |= !key || flib_ini_set_int(ini, key, scheme->settings[i]);
		free(key);
	}
	return error;
}

int flib_schemelist_to_ini(const char *filename, const flib_schemelist *schemes) {
	int result = -1;
	if(!filename || !schemes) {
		flib_log_e("null parameter in flib_schemelist_to_ini");
	} else {
		flib_ini *ini = flib_ini_create(NULL);
		if(ini && !flib_ini_create_section(ini, "schemes")) {
			bool error = false;
			error |= flib_ini_set_int(ini, "size", schemes->schemeCount);
			for(int i=0; i<schemes->schemeCount && !error; i++) {
				error |= writeSchemeToIni(schemes->schemes[i], ini, i);
			}

			if(!error) {
				result = flib_ini_save(ini, filename);
			}
		}
		flib_ini_destroy(ini);
	}
	return result;
}

flib_schemelist *flib_schemelist_create() {
	return flib_schemelist_retain(flib_calloc(1, sizeof(flib_schemelist)));
}

flib_schemelist *flib_schemelist_retain(flib_schemelist *list) {
	if(list) {
		flib_retain(&list->_referenceCount, "flib_schemelist");
	}
	return list;
}

void flib_schemelist_release(flib_schemelist *list) {
	if(list && flib_release(&list->_referenceCount, "flib_schemelist")) {
		flib_schemelist_destroy(list);
	}
}

flib_cfg *flib_schemelist_find(flib_schemelist *list, const char *name) {
	if(list && name) {
		for(int i=0; i<list->schemeCount; i++) {
			if(!strcmp(name, list->schemes[i]->schemeName)) {
				return list->schemes[i];
			}
		}
	}
	return NULL;
}

int flib_schemelist_insert(flib_schemelist *list, flib_cfg *cfg, int pos) {
	flib_cfg **changedList = flib_list_insert(list->schemes, &list->schemeCount, sizeof(*list->schemes), &cfg, pos);
	if(changedList) {
		list->schemes = changedList;
		flib_cfg_retain(cfg);
		return 0;
	} else {
		return -1;
	}
}

int flib_schemelist_delete(flib_schemelist *list, int pos) {
	int result = -1;
	if(!list || pos<0 || pos>=list->schemeCount) {
		flib_log_e("Invalid parameter in flib_schemelist_delete");
	} else {
		flib_cfg *elem = list->schemes[pos];
		flib_cfg **changedList = flib_list_delete(list->schemes, &list->schemeCount, sizeof(*list->schemes), pos);
		if(changedList || list->schemeCount==0) {
			list->schemes = changedList;
			flib_cfg_release(elem);
			result = 0;
		}
	}
	return result;
}
