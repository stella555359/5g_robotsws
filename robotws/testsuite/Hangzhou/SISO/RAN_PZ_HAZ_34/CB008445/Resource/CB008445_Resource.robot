*** Settings ***
Documentation    Suite description
...    Author:Frank Luo
...    contact:frank.s.luo@nokia-sbell.com
Resource     ../../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_CP_Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Variables    ./TLConfigurationDefault.py
Variables    ./CaseConfiguration.py

*** Variables ***
#${E500_PORT}              5030
#${E500_TMA_PATH}          /cygdrive/c/Program Files (x86)/VIAVI/TM500/5G NR - NLA 5.11.1/Test Mobile Application/TMA
#${E500_IP}                10.68.86.232
#${E500_USERNAME_DOMAIN}   nokia5G
#${E500_PASSWORD}          noki@123
#${E500_SCRIPT_DIR}        /home/ute/ZWJ/11/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/viviscript/
#${ALIAS_APPSERVER}        appserver

${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}
&{condition_ru_same}     rf-FRU6=diff
${PA_INFO}             ${tl.attenuator[0]}


*** Keywords ***
TC.Manual_SiSo_ALD_Detect_and_setup_AL_devices_Start-up
    #General_SiSo_ALD_Configuration_Management_ALD_site_commissioning
    COAM_WebEM.Login
    ${ALDSN_NO}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/EQM-1/APEQM-1/ALD-1   abbr=serialNumber
    should be equal    ${ALDSN_NO}   ${CASE_INPUT_CB008445['Manual_SiSo_ALD_SN']}
    #Run Keyword And Continue On Failure   DoTputCall

TC.Manual_SiSo_CALL_LTE_data_call
    [Documentation]   detail steps
    ...       1.commission with correct SCF
    ...       2.Call and check Tput
    [Arguments]   ${scf}=${TL_BASE_SCF}
    #${casescf}    SCF.GetCaseSCFFromDelta    InputFile=${scf}    TCID=TC01
    #run keyword if  '${scf}!='NULL'  COAM_Admin.commission  scf_file=${casescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
    #Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
    DoTputCall

TC.SiSo_Plug-in_Package_check
    [Documentation]   detail steps
    ...       1.Download Plugin and Sw package then compare some file
    ...       2.Check some file align with each other
    ${stream}    ${version}    Basic.GetStreamAndVersion
    #${filepath}  SoftwareUpdate.DownloadPackageFromWFT     build_version=${version}
    Fail    what plugin to downloaded
    #download plugin
    #check alignment


TC.SiSo_Plug-in_Update_RFM_plug-in_package
    [Arguments]   ${old_plugin}=NULL
    #download new plugin and old plugin
    #COAM_WebEM.SoftwareUpdate    ${filepath}   check_reset=false     check_onair=true
    Fail    what plugin to downloaded

TC.SiSo_Plug-in_Download_RFM_plug-in_package_and_insert_new_Radio_Module
    #Software update to old version
    #YAFT to NewVersion
    #Check Fault 23
    #Software update to new version.
    #fault 23 disappear.
    Fail    what plugin to downloaded
TC.BS-RF__LTE1530_Activation_Deactivation_in_WebEM
    [Documentation]
    ...    ****************RF__LTE1530_Activation_Deactivation_in_WebEM
    ...    - [TEST PURPOSE] Activates the reduced frequency offset feature.
    ...    ******************
    COAM_WebEM.Login
#    COAM_WebEM.ModifyAndActiveParameters    DistName=${MRBTS_ID}/${NRBTS_ID}/LNCEL-1/LNCEL_FDD-0
#    ...      FilterParam=Activation reduced frequency offset    NewValue=false
    #Run Keyword And Continue On Failure   DoTputCall

    COAM_WebEM.ModifyAndActiveParameters    DistName=${MRBTS_ID}/${NRBTS_ID}/LNCEL-1/LNCEL_FDD-0
    ...      FilterParam=Activation reduced frequency offset     NewValue=true
    #COAM_WEBEM.LockUnlcokCell

#    ${dlChBwTmp1}    run keyword and return status    should be true    '${dlChBw}'=='20 MHz'
#    ${ulChBwTmp1}    run keyword and return status    should be true
    ModifyRedFreqOffsetinLoop
    COAM_WebEM.ModifyAndActiveParameters    DistName=${MRBTS_ID}/${NRBTS_ID}/LNCEL-1/LNCEL_FDD-0
        ...      FilterParam=Activation reduced frequency offset     NewValue=false
    #Run Keyword And Continue On Failure   DoTputCall

TC.BS-RF__EDA_Validation_of_power_exceeding_max_allowed_power_per_pipe
    [Documentation]   detail steps
    ...       1.Modify Pmax to exceed max value
    ...       2.check fault
    [Arguments]    ${cellid}=1    ${invalid_value}=${34}
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${stream}/SCF_NR_2CC.xml
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    gnb.formatbtsid
    COAM_WebEM.Login
    ${default}    COAM_WebEM.GetParameterValue  distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cellid}    abbr=Maximum output power
    COAM_WebEM.SetParameterValue  distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cellid}    abbr=Maximum output power    value=${invalid_value}
    COAM_WebEM.ValidateAndActiveParameters
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3 times    30s    COAM_WebEM.CheckAlarm    id=1900    present=true
    Run Keyword And Continue On Failure    COAM_WebEM.SetParameterValue
    ...    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cellid}    abbr=Maximum output power    value=${default}
    Run Keyword And Continue On Failure    COAM_WebEM.ValidateAndActiveParameters
    Run Keyword And Continue On Failure   Wait Until Keyword Succeeds    3 times    30s    COAM_WebEM.CheckAlarm    id=4008    present=false
    Run Keyword And Continue On Failure   Wait Until Keyword Succeeds    15min   1min    COAM_WebEM.CheckAlarm    id=1900    present=false
    Run Keyword And Continue On Failure   COAM_WebEM.Logout
#    DoTputCall
#TC.Manual_SiSo_TEST_LTE_NR_RF_Diagnostic_Test
#    [Documentation]   detail steps
#    DoaTputCall    proto=UDP    dl_tput=5    precent=80    direction=dl
#    ${bts_thresholds}    create dictionary    Low RSSI threshold=${-160}
#    ${bands_thresholds}    create list    260    100    3
#    Check RF Diagnostic Result
#    ...    cell=${CELLPREVFIX}-1    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}    cell_id=1

check traffic reserved
    no operation

start traffic reserved
    no operation

ue attach reserved
    no operation

checkUL_DL_BW_on_RF
    no operation

ModifyRedFreqOffsetinLoop
    ${dlChBw}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/LNCEL-1/LNCEL_FDD-0   abbr=Downlink channel bandwidth
    ${ulChBw}    COAM_WebEM.GetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/LNCEL-1/LNCEL_FDD-0   abbr=Uplink channel bandwidth
    ${RedFreqOffsetStart}    ${RedFreqOffsetScope}    Get started value for loop    dlChBw=${dlChBw}
    FOR    ${i}    IN RANGE    ${RedFreqOffsetScope}
        ${RedFreqOffset}    Evaluate   ${RedFreqOffsetStart}+0.1*${i}
        #COAM_WEBEM.LockUnlcokCell_LTE     cell_idx=1    action=lock
        COAM_WebEM.ModifyAndActiveParameters    DistName=${MRBTS_ID}/${NRBTS_ID}/LNCEL-1/LNCEL_FDD-0
        ...      FilterParam=Reduced frequency offset     NewValue=${RedFreqOffset}
        #COAM_WEBEM.LockUnlcokCell_LTE     cell_idx=1    action=unlock
        wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
        #COAM_WEBEM.LockUnlcokCell
        #checkUL_DL_BW_on_RF
        #${dlChBwAfter}    COAM_WebEM.GetParameterValue    distName=MRBTS-1008/LNBTS-209/LNCEL-1/LNCEL_FDD-0   abbr=dlChBw
        #${ulChBwAfter}    COAM_WebEM.GetParameterValue    distName=MRBTS-1008/LNBTS-209/LNCEL-1/LNCEL_FDD-0   abbr=ulChBw
        #COAM_WEBEM.LockUnlcokCell
        #checkUL_DL_BW_on_RF
        #${dlChBwAfter}    COAM_WebEM.GetParameterValue    distName=MRBTS-1008/LNBTS-209/LNCEL-1/LNCEL_FDD-0   abbr=dlChBw
        #${ulChBwAfter}    COAM_WebEM.GetParameterValue    distName=MRBTS-1008/LNBTS-209/LNCEL-1/LNCEL_FDD-0   abbr=ulChBw
        #check traffic reserved
        #DoTputCall
    END

Get started value for loop
    [Arguments]     ${dlChBw}
#    run keyword if       '${dlChBw}'=='5 MHz'    ${RedFreqOffsetStart}    2.3
    ${RedFreqOffsetStart}=    Set Variable If    '${dlChBw}'=='5 MHz'    2.3
    ...    '${dlChBw}'=='10 MHz'    5
    ...    '${dlChBw}'=='15 MHz'    6.8
    ...    9.1
    ${RedFreqOffsetScope}=    Set Variable If    '${dlChBw}'=='5 MHz'    3
    ...    '${dlChBw}'=='10 MHz'    1
    ...    '${dlChBw}'=='15 MHz'    8
    ...    10
   [Return]    ${RedFreqOffsetStart}    ${RedFreqOffsetScope}


TC.62_Manual_SiSo_SM_LTE Cell_block_unblock
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to check RF module support in SW build.
    ...    ******************
    [Arguments]   ${LTE_cell_id_list}=${TCCB008445_TC66['LTE_cell_id_list']}
    #    Manual_SiSo_SM_LTE Cell_block_unblock    LTE_cell_id_list=${LTE_cell_id_list}
#    Run Keyword And Continue On Failure   DoTputCall
    COAM_WebEM.Login
    COAM_WEBEM.BlockUnBlcokCell    cell_idx=${LTE_cell_id_list}    action=block    technology=LTE
    COAM_WEBEM.BlockUnBlcokCell    cell_idx=${LTE_cell_id_list}    action=unblock    technology=LTE
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
#    Run Keyword And Continue On Failure   DoTputCall

General_SiSo_Cell_block_and_unblock_AdaptLte
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify cell and group cell block/ unblock functionality
    ...      during normal operation (OnAir state).
    ...    *******************
    ...    Notice: if cell group has servals cell, get ue failed
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}
    #Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Block and UnBlock Cells and L3call    block_list=${cell_id_list}   with_call=${with_call}  with_peak=${with_peak}
    run keyword if  ${cell_num}>1  Block and UnBlock Cells  block_list=${cell_id_list}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${cell_id_list}
    ...    check_alarm=${True}  gnb_type='${gNb_CuType}'    AND   Selenium Logout And Close Browser

TC.63_LTE_cell_graceful_shutdown_from_WebEm
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to check RF module support in SW build.
    ...    ******************
    [Arguments]   ${cell_idx}=${TCCB008445_TC63['LTE_cell_id_list']}
    LTE_cell_graceful_shutdown_from_WebEm    cell_idx=${cell_idx}


TC.64_LTE_cell_lock_unlock_(administrative_state_change)_from_WebEm
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to check RF module support in SW build.
    ...    ******************
    [Arguments]   ${cell_idx}=${TCCB008445_TC64['LTE_cell_id_list']}
    #    LTE_cell_lock_unlock_(administrative_state_change)_from_WebEm    cell_idx=${cell_idx}
     Run Keyword And Continue On Failure   DoTputCall
     #General_SiSo_Cell_lock_and_unlock_AdaptLte    with_call=${false}
    COAM_WebEM.Login
    COAM_WEBEM.LockUnlcokCell_LTE      cell_idx=${cell_idx}      action=lock
    COAM_WEBEM.LockUnlcokCell_LTE      cell_idx=${cell_idx}      action=unlock
    Run Keyword And Ignore Error     COAM_WebEM.Logout
    Run Keyword And Continue On Failure   DoTputCall

COAM_WEBEM.LockUnlcokCell_LTE
    [Documentation]   Lock Cell if cell is unlocked, UnLock cell if cell is locked.
    [Arguments]   ${cell_idx}=1    ${action}=lock    ${timeout}=60    ${checkstatus}=true
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="unlocked" and '${action}'=='lock'
    ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
    ...    abbr=Administrative state    value=locked
#    ...    selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="locked" and '${action}'=='unlock'
#    ...                selenium_coam.unlock_cell    cell_idx=${cell_idx}    timeout=${timeout}
     ...   COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
     ...    abbr=Administrative state    value=unlocked
    COAM_WebEM.ValidateAndActiveParameters
    return from keyword if    '${checkstatus}'=='false'
    ${status}    set variable if    '${action}'=='lock'    locked    unlocked
    Wait Until Keyword Succeeds    3 times    30s    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}
    ...    status=${status}

General_SiSo_Cell_lock_and_unlock_AdaptLte
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify cell and group cell lock/ unlock functionality
    ...      during normal operation (OnAir state).
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 02.19.2020 - - Created
    ...    *******************
    ...    Notice: if cell group has servals cell, get ue failed
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}
    #Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Lock and Unlock Cells or Groups and L3  lock_list=${cell_id_list}  is_group=${False}  with_call=${with_call}  with_peak=${with_peak}
    Connect to gnb coam via ssl
    ${cellgrp_id_list}  Get All Cell Group Id
    ${cellgrp_num}    get length  ${cellgrp_id_list}
    Lock and Unlock Cells or Groups and L3  lock_list=${cellgrp_id_list}  is_group=${True}  with_call=${with_call}  with_peak=${with_peak}
    run keyword if  ${cell_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}
    run keyword if  ${cellgrp_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cellgrp_id_list}  is_group=${True}

TC.65_Manual_SiSo_SM_LTE RAT reset
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to check RF module support in SW build.
    ...    ******************
    [Arguments]   ${cell_idx}=${TCCB008445_TC65['LTE_cell_id_list']}
    #    Manual_SiSo_SM_LTE RAT reset    cell_idx=${cell_idx}
    set suite variable    ${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['WebUI_reset_times']}    1
    Run Keyword And Continue On Failure   DoTputCall
    TC.GC002479_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
    Run Keyword And Continue On Failure   RU Should Be Online
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
    Run Keyword And Continue On Failure   DoTputCall


TC.66_Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to check RF module support in SW build.
    ...    ******************
    [Arguments]   ${ru_index}=${TCCB008445_TC66['ru_index']}   ${ru_type}=${TCCB008445_TC66['ru_type']}
    ...    ${host_addr}=${ASIK_IP}
    #${TCCB008445_TC66['host_addr']}
    ...    ${Ping from GNB container to RU_IP}=${TCCB008445_TC66['Ping from GNB container to RU_IP']}
    ...    ${ru_product_code}=${TCCB008445_TC66['ru_product_code']}
    ...    ${ru_serial_number}=${TCCB008445_TC66['ru_serial_number']}
    KW.Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module    ru_index=${ru_index}   ru_type=${ru_type}
    ...   host_addr=${host_addr}   Ping from GNB container to RU_IP=${Ping from GNB container to RU_IP}
    ...   ru_product_code=${ru_product_code}    ru_serial_number=${ru_serial_number}
###############################################
Manual_SiSo_SM_LTE Cell_block_unblock
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify LTE cell and group cell lock/ unlock functionality
    ...      during normal operation (OnAir state).
    [Arguments]   ${LTE_cell_id_list}=1
    Run Keyword And Continue On Failure   DoTputCall
    ${cell_num}   get length  ${LTE_cell_id_list}
    run keyword if  ${cell_num}<2    single_cell_block_unblock   block_list=${LTE_cell_id_list}
    run keyword if  ${cell_num}>1    Multi_Cell_block_unblock    block_list=${LTE_cell_id_list}
    wait until keyword succeeds   10x   1min  COAM_Admin.VerifyCellOnAir
    Run Keyword And Continue On Failure   DoTputCall

single_cell_block_unblock
     [Arguments]  ${block_list}=1   ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
    FOR  ${block_id}  IN  @{block_list}
        ${check_cell}  create list  ${block_id}
        Block cells and check status   block_list=${check_cell}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        UnBlock Cells and check status   block_list=${check_cell}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
    END

Multi_Cell_block_unblock
     [Arguments]  ${block_list}=1   ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
    FOR  ${block_id}  IN  @{block_list}
        ${check_cell}  create list  ${block_id}
        Block cells and check status   block_list=${check_cell}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
    END
    FOR  ${block_id}  IN  @{block_list}
        ${check_cell}  create list  ${block_id}
        UnBlock Cells and check status   block_list=${check_cell}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
    END

LTE_cell_graceful_shutdown_from_WebEm
    [Arguments]   ${cell_idx}=1
    Run Keyword And Continue On Failure   DoTputCall
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    wait until keyword succeeds   5x   30s    COAM_WEBEM.shutdownUnlcokCell  cell_idx=${cell_idx}    action=shuttingdown    checkstatus=true
#    log to console    shuttingdown start
#    FOR    ${i}    IN RANGE    ${60}
#        ${res}    run keyword and ignore error    COAM_WEBEM.CheckshutdownUnlcokCellStatus     cell_idx=${cell_idx}    status=Shutting Down
#        Exit For Loop If    '${res[0]}'=='PASS'
#        Sleep    1s
#    END
    wait until keyword succeeds   5x   30s   COAM_WEBEM.shutdownUnlcokCell  cell_idx=${cell_idx}     action=unlock    checkstatus=true
#    log to console    unlock start
#    FOR    ${i}    IN RANGE    ${60}
#        ${res}    run keyword and ignore error    COAM_WEBEM.CheckshutdownUnlcokCellStatus    cell_idx=${cell_idx}    status=Unlocked
#        Exit For Loop If    '${res[0]}'=='PASS'
#        Sleep    1s
#    END
    run keyword and ignore error    COAM_WebEM.Logout
    wait until keyword succeeds   10x   1min  COAM_Admin.VerifyCellOnAir
    Run Keyword And Continue On Failure   DoTputCall

COAM_WEBEM.shutdownUnlcokCell
    [Documentation]   shuttingdown cell if cell is unlocked, UnLock cell if cell is shuttingdown.
    [Arguments]   ${cell_idx}=1    ${action}=shuttingdown    ${timeout}=60    ${checkstatus}=true
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    ${btsstate}    Convert To Lower Case    ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="unlocked" and '${action}'=='shuttingdown'
    ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
    ...    abbr=Administrative state    value=shutting down
#    ...    selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="locked" and '${action}'=='unlock'
#    ...                selenium_coam.unlock_cell    cell_idx=${cell_idx}    timeout=${timeout}
     ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/${CELLPREVFIX}-${cell_idx}
     ...    abbr=Administrative state    value=unlocked
    COAM_WebEM.ValidateAndActiveParameters
    return from keyword if    '${checkstatus}'=='false'
    ${status}    set variable if    '${action}'=='shuttingdown'    	locked    unlocked
    Wait Until Keyword Succeeds    10 times    60s    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}
    ...    status=${status}

COAM_WEBEM.CheckshutdownUnlcokCellStatus
    [Documentation]   shutdown cell if cell is unlocked, UnLock cell if cell is shuttingdown.
    [Arguments]   ${cell_idx}=1    ${status}=shuttingdown    ${timeout}=60
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=='${status}'

LTE_cell_lock_unlock_(administrative_state_change)_from_WebEm
    [Arguments]   ${cell_idx}=1
    Run Keyword And Continue On Failure   DoTputCall
    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
    wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=lock    checkstatus=false
    log to console    lock start
    FOR    ${i}    IN RANGE    ${60}
        ${res}    run keyword and ignore error    COAM_WEBEM.CheckLockUnlcokCellStatus     cell_idx=${cell_idx}    status=Locked
        Exit For Loop If    '${res[0]}'=='PASS'
        Sleep    1s
    END
    wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}     action=unlock    checkstatus=false
    log to console    unlock start
    FOR    ${i}    IN RANGE    ${60}
        ${res}    run keyword and ignore error    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}    status=Unlocked
        Exit For Loop If    '${res[0]}'=='PASS'
        Sleep    1s
    END
    wait until keyword succeeds   10x   1min  COAM_Admin.VerifyCellOnAir
    Run Keyword And Continue On Failure   DoTputCall


Manual_SiSo_SM_LTE RAT reset
   [Arguments]   ${cell_idx}=1
    Run Keyword And Continue On Failure   DoTputCall
    General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
    Run Keyword And Continue On Failure   DoTputCall

KW.Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module
   [Arguments]   ${ru_index}=1   ${ru_type}=AWHKB   ${host_addr}=10.68.88.16    ${ru_product_code}=476086A.X21
   ...   ${Ping from GNB container to RU_IP}=ping 172.16.73.128 -c 3600 -i 1  ${ru_serial_number}=EB2201R0189
   Run Keyword And Continue On Failure   RU Should Be Online    ru_index=${ru_index}
   Run Keyword And Continue On Failure   COAM verify ru detail info via rest api   ru_type=${ru_type}
   ...    ru_product_code=${ru_product_code}    ru_serial_number=${ru_serial_number}
   FOR   ${RUN_times}   IN RANGE    ${2}
       CHECK_SOAP_Power_off_on_RU    ru_index=${ru_index}    ru_type=${ru_type}
       wait until keyword succeeds   10x   1min  COAM_Admin.VerifyCellOnAir
   END
   log     not stable ping from container, tested manually
#   Ping from GNB cotainer to RU_IP    host_addr=${host_addr}
#   ...            Ping from GNB container to RU_IP=${Ping from GNB container to RU_IP}

CHECK_SOAP_Power_off_on_RU
   [Arguments]   ${ru_index}=1   ${ru_type}=AWHKB
   CHECK_SOAP   ru_index=${ru_index}   ru_type=${ru_type}
   FOR   ${times}   IN RANGE    ${2}
       Power_off_on_RU   ru_index=${ru_index}
   END
   sleep   60s

CHECK_SOAP
   [Arguments]   ${ru_index}=1   ${ru_type}==AWHKB
   Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
   ${ru_type}    get ru type    ru_index=${ru_index}
   Verify SOAP RP1  ru_index=${ru_index}    ru_type=${ru_type}
   csn.Disconnect  connection=RU_${ru_index}

Power_off_on_RU
   [Arguments]   ${ru_index}=1
      Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
      sleep   10s
      Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
      sleep   10s

Ping from GNB cotainer to RU_IP
    [Documentation]
    ...               Description: Connect To RU Via FHNET Container
    ...               ContainerID is 0x1018 for left side of AMIA, 0x2018 for right side.
    ...               eth0(FHNET) ip is 192.168.255.254
    [Arguments]    ${container_id}=0x1018    ${container_alias}=Container
    ...            ${asik_alias}=ASIK Master    ${fhnet_host_ip}=192.168.255.254
    ...            ${host_username}=toor4nsn    ${host_addr}=10.68.88.16
    ...            ${host_password}=oZPS0POrRieRtu
    ...            ${Ping from GNB container to RU_IP}=ping 172.16.73.128 -c 3600 -i 1
    csn.connect to     hostname=${host_addr}     username=${host_username}
    ...   password=${host_password}    alias=${asik_alias}
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close
    csn.connect to    hostname=${fhnet_host_ip}
    ...               username=${host_username}
    ...               password=${host_password}
    ...               alias=${container_alias}
    ...               proxy=${asik_alias}
    ${Return}  Conn.Execute  cmd=${Ping from GNB container to RU_IP}  alias=${container_alias}
    run   echo '${Return}' > /tmp/log
    ${Fail_rate}   run   cat /tmp/log |grep 'packet loss'|awk '{print $6}'
    log   ${Fail_rate}
    should be true     ${Fail_rate} <=1%

#VIVI.8445Attach
#    ViVi.Prepare UE vivi_ip= python_path= power_cycle_script_path=
#    ViVi.UE Attach
#    ViVi.DialUp dial_connection= dial_username=tm500 dial_password=tm500
#
#VIVI.8445StartDLTraffic
#    [Arguments]    ${proto}=UDP    ${tput}=5
#    ViVi.Start traffic direction=dl iperf_path= port= host= tp=10M dur=120
#
#VIVI.8445StartULTraffic
#    [Arguments]    ${proto}=UDP
#    ViVi.Start traffic direction=dl iperf_path= port= host= tp=10M dur=120
#
#VIVI.8445CheckTput
#    [Arguments]    ${direction}=both    ${dl_tput}=22   ${ul_tput}=22    ${percent}=80
#    ViVi.Check throughput DLThroughput=22 Percentage=80
#
#VIVI.8445Detach
#    ViVi.DialClose dial_connection=
#    ViVi.UE Detach
#
#VIVI.8445GetUEIP
#    ViVi.DialClose dial_connection=
#
#VIVI.8445SendRRCReestablishScript
#    log    send
#
#VIVI.8445SendHandoverMessage
#    log    send
#
#VIVI.8445CheckHandoverMessage
#    log    send

################################################
# KW Part
KW.CaseSetupForOAMKPI
    #rf-FRU6=diff
    set suite variable   ${OAM_TYPE}    COAM
    set suite variable    ${SCFPrepared}    notstart
    set suite variable    ${StopCase}       false
    set suite variable    ${CaseState}      notstart
    ${stream}    ${version_Target}    Basic.GetStreamAndVersion
    set suite variable    ${TargetBTSVersion}    ${version_Target}
    set suite variable    ${TARGETSW}            ${version_Target}
    set suite variable    ${TargetBTSStream}     ${stream}
    set suite variable    ${TargetStream}        ${stream}
    Set Suite Variable    ${OldCommissionSCF}    ${CFGFILE_PATH}/OldCommissionSCF.xml
#    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['LoopTimeout']    default_value=30
#    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479']['LoopTimeoutForSWUpdate']    default_value=90
#    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_15']['UpdateByYAFT']    default_value=false

    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['RF_reset_times']      default_value=5
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['ru_index']            default_value=1
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_AVG']           default_value=360    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_MAX']           default_value=432    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI51']['KPI51_AVG_ADJ']       default_value=0      is_digit=True

    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['WebUI_reset_times']   default_value=5
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_AVG']           default_value=450    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['KPI1a_MAX']           default_value=540    is_digit=True

    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['SW_update_times']   default_value=1      is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_5GC002479['5GC002479_IA_KPI2d']['KPI2d_MAX']         default_value=864    is_digit=True

    Basic.CheckVariableValid    var=CASE_INPUT_CB008445['TC60']['lock_unlock_retry_times']         default_value=5
    Basic.CheckVariableValid    var=CASE_INPUT_CB008445['ue_index']                    default_value=0
    Basic.CheckVariableValid    var=CASE_INPUT_CB008445['apn']                         default_value=wap1nokiacom
    Basic.CheckVariableValid    var=CASE_INPUT_CB008445['ue_mode']                     default_value=SA
    Basic.CheckVariableValid    var=CASE_INPUT_CB008445['CASE_24']['DL']               default_value=800
    Basic.CheckVariableValid    var=CASE_INPUT_CB008445['CASE_24']['UL']               default_value=100
    Basic.CheckVariableValid    var=CASE_INPUT_CB008445['CASE_24']['Check_TP']         default_value=0.5
    Basic.CheckVariableValid    var=CASE_INPUT_CB008445['CASE_24']['duration']         default_value=30

    #KW.CaseStatusInit    retry_times=${100}
    ${CurrentStreamSCF}   COAM_Admin.BackupSCF
    Set Suite Variable    ${CurrentStreamSCF}     ${CurrentStreamSCF}

KW.AdaptCaseInput
    Basic.CheckVariableValid    var=CB008445['DeltaSCFCellNumber']    default_value=None
    Basic.CheckVariableValid    var=CB008445['CellType']    default_value=SA
    Basic.CheckVariableValid    var=TCCB008445_TC11['ru_index']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC14['ru_index']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC16['with_call']    default_value=${False}
    Basic.CheckVariableValid    var=TCCB008445_TC16['with_peak']    default_value=${False}
    Basic.CheckVariableValid    var=TCCB008445_TC17['with_call']    default_value=${True}
    Basic.CheckVariableValid    var=TCCB008445_TC18['addition_deletion_cell']       default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC18['addition_deletion_cellgrp']    default_value=${0}
    Basic.CheckVariableValid    var=TCCB008445_TC19['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC20['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC21['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC22['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC22['Tdanger_target']    default_value=30.0
    Basic.CheckVariableValid    var=TCCB008445_TC23['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC24['band']        default_value=${71}
    Basic.CheckVariableValid    var=TCCB008445_TC24['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC24['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC37['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC39['ue_index']    default_value=${0}
    Basic.CheckVariableValid    var=TCCB008445_TC47['frame_structure']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC47['ru_index']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC47['cell_id']     default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC47['ue_num_each_call']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC47['random_access']    default_value=${False}
    Basic.CheckVariableValid    var=TCCB008445_TC48['cell_band_frame_structure_list']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC48['cell_id']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC48['ue_num_each_call']    default_value=${1}
    Basic.CheckVariableValid    var=TCCB008445_TC48['random_access']    default_value=${False}
#COMMON SISO SETUP AND TEARDOWM
SISO OAM Suite Setup
    SISO Suite Setup
#    Power.OnOff    pdu_ip=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu.addr}
#    ...    Port_Number=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.port_no}
#    ...    Action=power_on
#    ...    model=${tl.gnbs[0].dus[0].rus[${ru_Index}].pdu_port.pdu}
    gNB.FormatBTSID    lte=true
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    version=${Active_SW_version}
    set suite variable      ${stream}
    ${basescf}    set variable    ${CFGFILE_PATH}/${stream}/SCF_10M_LTE.xml
    COAM_Admin.commission  scf_file=${basescf}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    #Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['dl']}    target_throughput=5M
    #Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']['ul']}    target_throughput=5M
    #Set To Dictionary    ${TLCommonConfig["MultiUECFG"]['0']}    script_path=ViViScriptLTE/
SISO RRM Suite Setup
    SISO Suite Setup
SISO Suite Setup
    log to console    \n***SISO Coam Suite Setup***
    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
    ...    ELSE     UTECloud.AdaptCommissionFiles
    TestSuite.Start
    KW.AdaptCaseInput
    KW.CaseSetupForOAMKPI
    set suite variable    ${testline_scf}   ${CurrentStreamSCF}
#    Get TestLine SCF
#    Commission
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    #${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}    SA
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${testline_scf}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    gNB.FormatBTSID
    #set suite variable    ${MRBTS_ID}    ${MRBTSID}
    #set suite variable  ${mrbtsID}
    #set suite variable  ${nrbtsID}
    set suite variable   ${TL_BASE_SCF}    ${CFGFILE_PATH}/${TL_BASE_SCF_NR_10M}

SISO Suite Teardown
    log to console    \n***SISO Coam Suite Teardown***
    COAM_Admin.commission    scf_file=${CFGFILE_PATH}/SCF_SBTS00.xml
    wait until keyword succeeds   10x   2min  COAM_Admin.VerifyCellOnAir
#    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}
#    ...    Commission
    #COAM Teardown gnb connections
    #Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

SISO Test Setup
    log to console    \n***SISO Coam Test Setup***
    log to console    Active_SW_version:${Active_SW_version}
    run keyword and ignore error    PA.AdjustAttenuationValueByGroup    PAGroup=${TLCommonConfig['PAGroups']['1']}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}    Fail    TEST
#    ...    Commission
#    Start Btslog With Path Check
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Run Keyword And Ignore Error    BtsLog.StartBTSlogCollection

SISO Test Teardown
    log to console    \n***SISO Coam Test Teardown***
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore error    WEBUI.Collect snapshot
#    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
#    log to console  RU status: ${ru_status}
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    should be true    ${cell_status}
#    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
#    should be true    ${alarm_status}
#    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
#    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
#    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
#    run keyword if test failed     Collect Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

Get TestLine SCF
    Log    get test line scf from golden scf
    set suite variable     ${testline_scf}      ${CURDIR}/${testline_name}_scf.xml
    UTECloud.ForceAdaptCommissionFiles
    KW.AdaptCaseInput
    GNB.FormatBTSID
    ${res}    run keyword and ignore error    should not be equal  '${CB008445['DeltaSCFCellNumber']}'  'None'
    ${scffile}    run keyword if    '${res[0]}'!='FAIL'    gNB.Generate TL SCF
    ...    GoldenSCF_PATH=${GoldenSCF_PATH}    TLDelta_PATH=${CFGFILE_PATH}
    ...    TestLineSCF_cell_num=${CB008445['DeltaSCFCellNumber']}
    ...    cell_type=${CB008445['CellType']}    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    run keyword if    '${res[0]}'!='FAIL'    run keyword and ignore error    gNB.Commission
    ...    scf_file=${scffile}    timeout=${1800}
    run keyword if    '${res[0]}'!='FAIL'    Check all cells Should Be On Air
    run keyword if    '${res[0]}'!='FAIL'    set suite variable    ${testline_scf}    ${scffile}
    set suite variable      ${Golden_SCF_Path}     ${testline_scf}

Commission
    [Arguments]    ${scf_file}=${testline_scf}
    COAM_Admin.commission    scf_file=${testline_scf}
    wait until keyword succeeds   10x   2min  COAM_Admin.VerifyCellOnAir

General_SiSo_eCPRI_synchronization_status_NIDD_parameters
    [Arguments]    ${parameters_list}=parameters_list   ${local_dir}=${OUTPUT_DIR}   ${file_name}=full_commission.xml
    ...   ${connection}=GNB_OAM
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    coam.get_current_scf_file   local_dir_path=${local_dir}   file_name=${file_name}   connection=${connection}   timeout=30
    ${xml}   ParseXML.Parse XML   ${OUTPUT_DIR}/${file_name}
    FOR   ${item}   IN   @{parameters_list}
       ${class_name}   Set Variable   ${item['class_name']}
       ${parameter}   Set Variable   ${item['parameter']}
    run Keyword And continue on failure    ParseXML.Element Should Exist
    ...   ${xml}   cmData/managedObject[@class="${class_name}"]/p[@name="${parameter}"]
    END
    Selenium Logout And Close Browser


General_SiSo_BTS_startup_with_RF_delayed_startup
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check the RU connection,
    ...    detection and configuration to the BTS in a reliable time.
    ...    RU should be powered on with delay after the BTS (RAC and RAU) is online, connected.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.19.2020 - - Created
    ...    *******************
    ...    OWNER_tingting.zhong@nokia-sbell.com]
    ${ru_index_list}  Get All RU Index
    Perform RAC and RAU Power Off  ${ru_index_list}
    Perform RAC Power On  ${ru_index_list}
    [Teardown]  Power On RU_and_check RF Delayed Startup  ${ru_index_list}


#Manual_SiSo_SM_LTE Cell_block_unblock
#    [Documentation]    *****************
#    ...    Basic information
#    ...    *****************
#    ...    Description in reStructuredText format on what is tested
#    ...    *****************
#    ...    - [TEST PURPOSE] To verify LTE cell and group cell lock/ unlock functionality
#    ...      during normal operation (OnAir state).
#    [Arguments]   ${LTE_cell_id_list}
#    #CALL
#     ${cell_num}   get length  ${LTE_cell_id_list}
#     single_cell_block_unblock   block_list=${LTE_cell_id_list}
#     run keyword if  ${cell_num}>1    Multi_Cell_block_unblock    block_list=${LTE_cell_id_list}
#     wait until keyword succeeds   10x   1min  COAM_Admin.VerifyCellOnAir
#    #CALL
#
#single_cell_block_unblock
#     [Arguments]  ${block_list}   ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
#    FOR  ${block_id}  IN  @{block_list}
#        ${check_cell}  create list  ${block_id}
#        Block cells and check status   block_list=${check_cell}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
#        UnBlock Cells and check status   block_list=${check_cell}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
#    END
#
#Multi_Cell_block_unblock
#     [Arguments]  ${block_list}   ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
#    FOR  ${block_id}  IN  @{block_list}
#        ${check_cell}  create list  ${block_id}
#        Block cells and check status   block_list=${check_cell}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
#    END
#    FOR  ${block_id}  IN  @{block_list}
#        ${check_cell}  create list  ${block_id}
#        UnBlock Cells and check status   block_list=${check_cell}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
#    END
#
#LTE_cell_graceful_shutdown_from_WebEm
#    [Arguments]   ${cell_idx}=1
#    #CALL
#    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
#    wait until keyword succeeds   5x   30s    COAM_WEBEM.shutdownUnlcokCell  cell_idx=${cell_idx}    action=shuttingdown    checkstatus=false
#    log to console    shuttingdown start
#    FOR    ${i}    IN RANGE    ${60}
#        ${res}    run keyword and ignore error    COAM_WEBEM.CheckshutdownUnlcokCellStatus     cell_idx=${cell_idx}    status=shuttingdown
#        Exit For Loop If    '${res[0]}'=='PASS'
#        Sleep    1s
#    END
#    wait until keyword succeeds   5x   30s   COAM_WEBEM.shutdownUnlcokCell  cell_idx=${cell_idx}     action=unlock    checkstatus=false
#    log to console    unlock start
#    FOR    ${i}    IN RANGE    ${60}
#        ${res}    run keyword and ignore error    COAM_WEBEM.CheckshutdownUnlcokCellStatus    cell_idx=${cell_idx}    status=Unlocked
#        Exit For Loop If    '${res[0]}'=='PASS'
#        Sleep    1s
#    END
#    #CALL
#
#COAM_WEBEM.shutdownUnlcokCell
#    [Documentation]   shuttingdown cell if cell is unlocked, UnLock cell if cell is shuttingdown.
#    [Arguments]   ${cell_idx}=1    ${action}=shuttingdown    ${timeout}=60    ${checkstatus}=true
#    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
#    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
#    run keyword if    '${cell_info['Status']['Administrative state']}'=="Unlocked" and '${action}'=='shuttingdown'
#    ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_idx}    abbr=Administrative state    value=shuttingdown
##    ...    selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
#    run keyword if    '${cell_info['Status']['Administrative state']}'=="shuttingdown" and '${action}'=='unlock'
##    ...                selenium_coam.unlock_cell    cell_idx=${cell_idx}    timeout=${timeout}
#     ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_idx}    abbr=Administrative state    value=Unlocked
#    COAM_WebEM.ValidateAndActiveParameters
#    return from keyword if    '${checkstatus}'=='false'
#    ${status}    set variable if    '${action}'=='shuttingdown'    shuttingdown    Unlocked
#    Wait Until Keyword Succeeds    3 times    30s    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}
#    ...    status=${status}
#
#COAM_WEBEM.CheckshutdownUnlcokCellStatus
#    [Documentation]   shutdown cell if cell is unlocked, UnLock cell if cell is shuttingdown.
#    [Arguments]   ${cell_idx}=1    ${status}=shuttingdown    ${timeout}=60
#    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
#    should be true    '${cell_info['Status']['Administrative state']}'=='${status}'
#
#LTE_cell_lock_unlock_(administrative_state_change)_from_WebEm
#    [Arguments]   ${cell_idx}=1
#    #CALL
#    wait until keyword succeeds   15min    10s    COAM_WebEM.Login
#    wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}    action=lock    checkstatus=false
#    log to console    lock start
#    FOR    ${i}    IN RANGE    ${60}
#        ${res}    run keyword and ignore error    COAM_WEBEM.CheckLockUnlcokCellStatus     cell_idx=${cell_idx}    status=Locked
#        Exit For Loop If    '${res[0]}'=='PASS'
#        Sleep    1s
#    END
#    #CHECK ALARM
#    wait until keyword succeeds   5x   30s    COAM_WEBEM.LockUnlcokCell  cell_idx=${cell_idx}     action=unlock    checkstatus=false
#    log to console    unlock start
#    FOR    ${i}    IN RANGE    ${60}
#        ${res}    run keyword and ignore error    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}    status=Unlocked
#        Exit For Loop If    '${res[0]}'=='PASS'
#        Sleep    1s
#    END
#    #check alarm should disappear
#    #CALL
#
#Manual_SiSo_SM_LTE RAT reset
#   [Arguments]   ${cell_idx}=1
#   #call
#   General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
#   #call

VIVI.8445Attach
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0
    ViVi.Prepare UE    UECFG=${UECFG}    ue_index=${ue_index}
    ${ue_ip}    ViVi.UE Attach     UECFG=${UECFG}    ue_index=${ue_index}
    [Return]    ${ue_ip}

VIVI.8445StartDLTraffic
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}   ${ue_index}=0    ${protocal}=UDP  ${iperf_port}=5001  ${options}=${EMPTY}
    ViVi.Start traffic   UECFG=${UECFG}   ue_index=${ue_index}   direction=dl   protocal=${protocal}
    ...    iperf_port=${iperf_port}  options=${options}

VIVI.8445StartULTraffic
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}   ${ue_index}=0    ${protocal}=UDP  ${iperf_port}=5001  ${options}=${EMPTY}
    ViVi.Start traffic   UECFG=${UECFG}   ue_index=${ue_index}   direction=ul   protocal=${protocal}
    ...    iperf_port=${iperf_port}  options=${options}

VIVI.8445CheckTput
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0   ${direction}=both
    ViVi.Check throughput    UECFG=${UECFG}    ue_index=${ue_index}   direction=${direction}

VIVI.8445Detach
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0
    ViVi.UE Detach    UECFG=${UECFG}    ue_index=${ue_index}

VIVI.8445GetUEIP
    #ViVi.DialClose dial_connection=
    log   get UE IP
    [Return]    ${UE_IP_${ue_index}}

VIVI.8445SendRRCReestablishScript
    Fail    rrc reestatlishscript not ready

VIVI.8445SendHandoverMessage
    Fail    handover call not ready

VIVI.8445CheckHandoverMessage
    Fail    handover call not ready

DoTputCall
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}   ${ue_index}=0    ${direction}=both   ${protocal}=UDP
    ...    ${iperf_port}=5410  ${options}=${EMPTY}
    ${ue_ip}    Wait Until Keyword Succeeds    3 times    60s    DoAttach     UECFG=${UECFG}    ue_index=${ue_index}
    Run Keyword And Continue On Failure    ViVi.Start traffic   UECFG=${UECFG}   ue_index=${ue_index}
    ...    direction=${direction}   protocal=${protocal}
    ...    iperf_port=${iperf_port}  options=${options}
    sleep  30
    Run Keyword And Continue On Failure
    ...    ViVi.Check throughput    UECFG=${UECFG}
    ...    ue_index=${ue_index}   direction=${direction}
    ViVi.Stop traffic    UECFG=${UECFG}    ue_index=${ue_index}    protocal=${protocal}
    ...    direction=${direction}    iperf_port=${iperf_port}
    ViVi.UE Detach    UECFG=${UECFG}    ue_index=${ue_index}
    ViVi.Disconnect    UECFG=${UECFG}    ue_index=${ue_index}

DoAttach
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}   ${ue_index}=0     ${dail}=true
    ViVi.Prepare UE    UECFG=${UECFG}    ue_index=${ue_index}
    ${ue_ip}    ViVi.UE Attach     UECFG=${UECFG}    ue_index=${ue_index}    dail=${dail}
    [Return]    ${ue_ip}

DoHandoverCall
#    VIVI.8445Attach
#    VIVI.8445StartDLTraffic   proto=UDP    tput=5
#    VIVI.8445SendHandoverMessage
#    Sleep    5s
#    VIVI.8445CheckHandoverMessage
#    VIVI.8445CheckTput    direction=dl    dl_tput=5   percent=80
#    VIVI.8445Detach
    Fail    handover call not ready

PingAndGetResult
    [Arguments]    ${ue_index}=0    ${len}=32
    ${iperf_s_host}        set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
#    ${iperf_s_username}    set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
#    ${iperf_s_password}    set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ${log}      Conn.Execute     cmd=ping ${iperf_s_host} -n 4 -l ${len}    alias=${ALIAS_E500}_${ue_index}
    run   echo '${log}' > ${LOG_PATH}/ping.log
    #${loss}   run    cat ${LOG_PATH}/ping.log |grep "packet loss"|awk '{print $6}'
    ${loss}   run    cat ${LOG_PATH}/ping.log |grep "loss"|awk '{print $11}'
    ${loss}   Evaluate    ${loss.strip('%').strip('(')}+0
    #${first}  run    cat ${LOG_PATH}/ping.log |grep "time"|head -n 1|awk '{print $7}'
    #${rtt}  run    cat ${LOG_PATH}/ping.log |grep "rtt"|head -n 1|awk '{print $4}'
    ${first}  run    cat ${LOG_PATH}/ping.log |grep "time"|head -n 1|awk '{print $5}'
    ${rtt}  run    cat ${LOG_PATH}/ping.log |grep "Average"|head -n 1
    ${header}    ${first}    Split String From Right	 string=${first}   separator==     max_split=1
    [Return]    ${loss}    ${first}    ${rtt}

SCF.GetCaseSCFFromDelta
    [Arguments]   ${InputFile}=NULL    ${TCID}=0
    gNB.GenerateCaseSCF     InputFile=${InputFile}
    ...                     OutputFile=${LOG_PATH}/${TCID}.xml
    ...                     ResourceFolder=${CURDIR}
    ...                     ParameterToDelete=PARAMETER_TO_DELETE_${TCID}
    ...                     MOsToAdd=MOS_TO_ADD_${TCID}
    ...                     ParamterToModify=PARAMETER_TO_MODIFY_${TCID}
    ...                     ListParamterToModify=LIST_PARAMS_TO_MODIFY_${TCID}
    ...                     ListToAdd=LIST_TO_ADD_${TCID}
    [Return]    ${LOG_PATH}/${TCID}.xml

Check RF Diagnostic Result
    [Arguments]    ${cell}=${CELLPREVFIX}-1    ${bts_thresholds}=${None}    ${bands_thresholds}=${None}    ${cell_id}=1
    RF Diagnostic Test Setup And Check Time
    ...    cell=${cell}    bts_thresholds=${bts_thresholds}    bands_thresholds=@{bands_thresholds}    cell_id=${cell_id}
    Check Detail Antenna    RSSI_low=-160
    Check General Information

RF Diagnostic Test Setup And Check Time
    [Arguments]    ${cell}=${CELLPREVFIX}-1    ${bts_thresholds}=${None}     ${bands_thresholds}=${None}    ${cell_id}=1
    Log To Console    RF Diagnostic Test Setup
    selenium_coam.configure_rf_diagnostic_test    cell=${cell}    bts_thresholds=${bts_thresholds}    bands_thresholds=${bands_thresholds}
    ...    technology=LTE
    run keyword and ignore error    selenium_coam.save_thresholds
    selenium_coam.start_rf_diagnostic_test    timeout=30
    wait until keyword succeeds    1s    100ms    check test information    cell_id=${cell_id}

check test information
    [Arguments]    ${cell_id}
    ${test_information}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    should not be empty    ${test_information}

Check General Information
    [Arguments]    ${cell_id}=1    ${forward_expected_result}=Pass    ${reverse_expected_result}=Pass
    ...    ${expected_outcome}=Pass
    ${general_result}    selenium_coam.get_general_test_information    cell_id=${cell_id}
    ${general_result_index}    evaluate    ${cell_id}-1
    ${forward_result}    get from dictionary    ${general_result[${general_result_index}]}    Forward test disposition
    ${reverse_result}    get from dictionary    ${general_result[${general_result_index}]}    Reverse test disposition
    ${outcome}    get from dictionary    ${general_result[${general_result_index}]}    Outcome
    should be equal    ${forward_result}    ${forward_expected_result}
    should be equal    ${reverse_result}    ${reverse_expected_result}
    should be equal    ${outcome}    ${expected_outcome}

Check Detail Antenna
    [Arguments]    ${cell_id}=1    ${expected_low}=0     ${expected_high}=120   ${error_low}=-8    ${error_high}=8
    ...    ${RSSI_low}=-180    ${RSSI_high}=-30    ${RTWP_low}=-180    ${RTWP_high}=-30    ${VSWR_high}=3
    ${detail_result}    selenium_coam.get_detailed_result_for_each_antenna    cell_id=${cell_id}
    FOR    ${item}    IN    @{detail_result}
        ${dict_forward_total}    get from dictionary    ${item}   Forward total transmit RF power
        ${value_forward_total}    get from dictionary    ${dict_forward_total}     dBm
        should be true    ${value_forward_total} == 0
        ${dict_forward_expected}    get from dictionary    ${item}   Forward expected transmit RF power
        ${value_forward_expected}    get from dictionary    ${dict_forward_expected}     dBm
        should be true    ${expected_low} < ${value_forward_expected}
        ${value_forward_error}    get from dictionary    ${item}    Forward transmit RF power error (dB)
        should be true    ${value_forward_error} == 0
        ${value_RSSI}    get from dictionary    ${item}    RSSI (dBm)
        should be true    ${value_RSSI} == 0
        ${value_RTWP}    get from dictionary    ${item}    RTWP (dBm)
        should be true    ${value_RTWP} == 0
        ${value_VSWR}    get from dictionary    ${item}    VSWR
        should be true    ${value_VSWR} == 0
    END
