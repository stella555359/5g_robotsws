*** Settings ***
Documentation
...  Collect all SW download and activation files to Snapshot after the SW Update fails.
...  Example of execution:
...  pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results "testsuite/WMP/SOAM3/SWM/LBT2679/SRAN_Trunk_Rel4/
...         ABIO_OAM_LBT2679_Collect SW download and activation files after SW update fails.robot"
...
...  "Author: lyon.wang@nokia.com"
...  "Team: I_NWS_LTE_RA_RD_FDD_OAM_BEJ_SCTEAM14_GMS@internal.nsn.com"


*** Variables ***
${snapshot_local_directory}=    ${CURDIR}${/}Snapshot
${log_dir}=                     ${/}var${/}tmp
${indent}=                      \ \ \ \
@{log_file_names}               FileList_SWDownload_Start.xz  FileList_SWDownload_End.xz
${destination_dir}=                /home/ute/btsauto/Basic/
${part}            		BTSOM
${fault_id}         		28
${keyword}=			wupdate
${FileNumber}                   22


*** Keywords ***
OAM_LBT2679_Collect SW download and activation files after SW update fails
    [Documentation]    Short description.
    Get eNB HW Platform
    Get SW load and Type
    ${active_build_path}=   prepare different build
    #Check which T type it should be
    #Change '${part}' in '${active_build_path}' to make SW '${T_type}' update fail for FSM'${FSM_num}'
    #Update Modified SW and Check alarm    ${active_build_path}
    #Run    rm ${destination_dir}*.zip
    #Check Log Files are present on eNB
    #Run Keyword And Expect Error  *  Collect Dedicated File from BTS    ${log_dir}/FileList_SWActivation_Done.xz
    #...    ${Test Results Dir}/FileList_SWActivation_Done.xz
    #Sleep    10
    #Trigger and Check Snapshot
    #Run Keyword And Expect Error  *  Check Log Files are present on eNB
    #Run Keyword And Expect Error  *  Collect Dedicated File from BTS    ${log_dir}/FileList_SWActivation_Done.xz
    #...    ${Test Results Dir}/FileList_SWActivation_Done.xz

Check Log Files are present on eNB
    [Documentation]    Short description.
	FOR    ${fileName}  IN  @{log_file_names}
	   Collect Dedicated File from BTS    ${log_dir}/${fileName}    ${Test Results Dir}/${fileName}
    END

Trigger and Check Snapshot
    [Documentation]    Short description.
	taf.sbts.oam.coam.admin.Collect Snapshot     snapshot.zip   Full
	Run     unzip -o snapshot.zip -d snapshot
	${matching_lines}=    Grep file    snapshot/snapshot_file_list.txt    ${keyword}
	${matchstring_BTS_name}=    Split string         ${matching_lines}    separator=\_
        ${BTS_name1}=     Get from list    ${matchstring_BTS_name}    0
        ${BTS_node}=     Get from list    ${matchstring_BTS_name}    1
        ${BTS_name1}=    Replace String     ${BTS_name1}  ${SPACE}  ${EMPTY}
        #${BTS_name}=    Get Substring     ${matching_lines}   4     13
	Set Test Variable     ${BTS_name}    ${BTS_name1}_${BTS_node}
	FOR    ${index}   IN RANGE  1   ${FileNumber}
	    Run 	unzip -o snapshot/${BTS_name}_part_${index}.zip -d ${BTS_name}
    END
	Check Log Files are present in Snapshot

Check Log Files are present in Snapshot
    [Documentation]    Short description.
	FOR    ${fileName}  IN  @{log_file_names}
	   OperatingSystem.File Should Exist  ${BTS_name}/${BTS_name}_${fileName}
    END

Custom TC Teardown
    [Documentation]    Short description.
    Run    rm -r /home/ute/btsauto/Basic
    ${ACTIVE_SW_BEFORE}    ${PASSIVE_SW_BEFORE}    Admin Get BTS SW Version
    ${build_type}=  Should Match Regexp  ${ACTIVE_SW_BEFORE}  .{2}$
    run keyword if    '${build_type}'=='T1'     taf.sbts.oam.coam.admin.Rollback Software
    TC Teardown
