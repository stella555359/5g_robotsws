*** Settings ***
Documentation
...  Name: eNB software update
...  Author: Marek Bednarek, Alicja Kozikowska
...  Purpose: To update eNB software through Site Manager. Will choose from local folder a version that is different from those on both partitions.
...  Preconditions: BTS is in onAir state with minimum 1 RF. Three packages (normal, testpackage T1, testpackage T2) are in /home/ute/package.
...  Trigger: Software update button in BTS SM
...  Expected results: BTS updated to latest SW build.
...  Execution: /opt/ute/python/bin/robot -v CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d /home/ute/logs/ testsuite/WMP/SOAM3/SWM/
...         SRAN_SWM/Trunk_Rel4/CRT/ASIL_Automated__SW_Management_File__Corrupted_in_SW_Download_uboot_ftif_FL00.robot
...  Dryrun: pybot -t "Automated__SW_Management_File__Corrupted_in_SW_Download_uboot_ftif_FL00" --dryrun --log NONE --report NONE --output NONE
...             -v CONFIGURATION:dryrun -C off -d /opt/ute/logs -L TRACE "testsuite/WMP/SOAM3/SWM/SRAN_SWM/Trunk_Rel4/CRT/
...             Automated__SW_Management_File__Corrupted_in_SW_Download_uboot_ftif_FL00.robot"
...  For TDD testing You can try switch -v HW_VERSION:TDD (or --variable HW_VERSION:TDD) to change InfoModel connection port.
...  LTE_OPR_AC_1646


*** Variables ***
${fault_id}         28
${part}				FSP-MC-BW


*** Keywords ***
Automated__SW_Management_File__Corrupted_in_SW_Download_uboot_ftif_FL00
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Reset Site

    Wait for eNB configure and RF swCheckDone status
    Get eNB HW Platform
    Get SW load and Type
    ${active_build_path}=   prepare different build
    Check which T type it should be
    Change '${part}' in '${active_build_path}' to make SW '${T_type}' update fail for FSM'${FSM_num}'
    Update Modified SW and Check alarm    ${active_build_path}
    #taf_sbts_OAM_Common.Check if LNBTS fault '${fault_id}' exists in '30' seconds
    Wait Until Keyword Succeeds    1 min    3 sec    Check if fault present    ${fault_id}
    Update Modified SW and Check alarm    ${active_build_path}
    #taf_sbts_OAM_Common.Check if LNBTS fault '${fault_id}' exists in '30' seconds
    Wait Until Keyword Succeeds    1 min    3 sec    Check if fault present    ${fault_id}
    Run    rm ${destination_dir}/*.zip
    ${active_build_path}=   prepare different build
    Log to console    Upload the correct sw: ${active_build_path}
    taf.sbts.oam.coam.admin.Update Software    ${active_build_path}  timeout=2000
    Wait for eNB configure and RF swCheckDone status
#    Let eNB onAir and Make call

#    taf.sbts.oam.coam.admin.Rollback Software             # return to original software
#    Wait for eNB configure and RF swCheckDone status

Custom TC Teardown
    [Documentation]    Short description.
    ${ACTIVE_SW_BEFORE}    ${PASSIVE_SW_BEFORE}    Admin Get BTS SW Version
    ${build_type}=  Should Match Regexp  ${ACTIVE_SW_BEFORE}  .{2}$
    run keyword if    '${build_type}'=='T1'     taf.sbts.oam.coam.admin.Rollback Software
    sleep    120s
    Wait until keyword succeeds  15min  10 sec    Admin Check BTS Procedural and Blocking states    OnAir
    TC Teardown
