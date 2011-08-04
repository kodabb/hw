(*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2004-2011 Andrey Korotaev <unC0Rr@gmail.com>
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
 *)

Library hwLibrary;

{$IFDEF fpc}
{$MODE delphi}
{$ENDIF}

{$IFDEF ANDROID}
    {$MACRO ON}
    {$DEFINE Java_Prefix := 'Java_org_hedgewars_mobile_EngineProtocol_PascalExports_'}
{$ENDIF}

// Add all your Pascal units to the "uses" clause below to add them to the program.
// Mark all Pascal procedures/functions that you wish to call from C/C++/Objective-C code using
// "cdecl; export;" (see the fpclogo.pas unit for an example), and then add C-declarations for
// these procedures/functions to the PascalImports.h file (also in the "Pascal Sources" group)
// to make these functions available in the C/C++/Objective-C source files
// (add "#include PascalImports.h" near the top of these files if it's not there yet)
uses PascalExports, hwengine{$IFDEF ANDROID},jni{$ENDIF};
exports Game{$IFNDEF ANDROID}, HW_versionInfo{$ENDIF};

function JNI_HW_versionInfoNet(env: PJNIEnv; obj: JObject):JInt;cdecl;
begin
    JNI_HW_versionInfoNet := cNetProtoVersion;
end;

function JNI_HW_versionInfoVersion(env: PJNIEnv; obj: JObject):JString; cdecl;
begin
    JNI_HW_versionInfoVersion := env^.NewStringUTF(env, PChar(cVersionString));
end;


{$IFDEF ANDROID}
    exports
    JNI_HW_versionInfoNet name Java_Prefix+'HWversionInfoNetProto', 
    JNI_HW_versionInfoVersion name Java_Prefix+'HWversionInfoVersion', 
    GenLandPreview name Java_Prefix + 'GenLandPreview',
    HW_getNumberOfweapons name Java_Prefix + 'HWgetNumberOfWeapons',
    HW_getMaxNumberOfHogs name Java_Prefix + 'HWgetMaxNumberOfHogs',
    HW_getMaxNumberOfTeams name Java_Prefix + 'HWgetMaxNumberOfTeams';
{$ENDIF}

begin

end.

