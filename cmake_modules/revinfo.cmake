#detect Mercurial revision and init rev/hash information
find_program(HGCOMMAND hg)
if(HGCOMMAND AND (EXISTS ${CMAKE_SOURCE_DIR}/.hg))
    execute_process(COMMAND ${HGCOMMAND} identify -in
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                    OUTPUT_VARIABLE internal_version
                    ERROR_QUIET
                )
    #check local repo status
    string(REGEX REPLACE "[^+]" "" HGCHANGED ${internal_version})
    string(REGEX REPLACE "[0-9a-zA-Z]+(.*) ([0-9]+)(.*)" "\\2" HEDGEWARS_REVISION ${internal_version})
    string(REGEX REPLACE "([0-9a-zA-Z]+)(.*) [0-9]+(.*)" "\\1" HEDGEWARS_HASH ${internal_version})

    if(HGCHANGED)
        message(${WARNING} "You have uncommitted changes in your repository!")
    endif()
    #let's assume that if you have hg you might be interested in debugging
    set(default_build_type "DEBUG")
    #write down hash and rev for easy picking should hg be missing
    file(WRITE "${CMAKE_SOURCE_DIR}/share/version_info.txt" "Hedgewars versioning information, do not modify\nrev ${HEDGEWARS_REVISION}\nhash ${HEDGEWARS_HASH}\n")
else()
    set(default_build_type "RELEASE")
    # when compiling outside rev control, fetch revision and hash information from version_info.txt
    find_file(version_info version_info.txt PATH ${CMAKE_SOURCE_DIR}/share)
    if(version_info)
        file(STRINGS ${version_info} internal_version REGEX "rev")
        string(REGEX REPLACE "rev ([0-9]*)" "\\1" HEDGEWARS_REVISION ${internal_version})
        file(STRINGS ${version_info} internal_version REGEX "hash")
        string(REGEX REPLACE "hash ([a-zA-Z0-9]*)" "\\1" HEDGEWARS_HASH ${internal_version})
    else()
        message(${WARNING} "${CMAKE_SOURCE_DIR}/share/version_info.txt not found, revision information "
                           "will be incorrect!!! Contact your source provider to fix this!")
        set(HEDGEWARS_REVISION "0000")
        set(HEDGEWARS_HASH "unknown")
    endif()
endif()


