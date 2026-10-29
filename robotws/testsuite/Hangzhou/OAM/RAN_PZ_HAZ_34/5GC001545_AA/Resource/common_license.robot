*** Settings ***
Documentation   Author: johnny.1.jiang@nokia-sbell.com
Resource   ../../common/taf_coam.robot
Resource   ../../common/gnb.robot
Resource   NetAct.robot
Library   XML
Library   Collections
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact
Variables   ../../libraries/global_vars.py
Resource   ../../5GI000114/Resource/NetAct_Fast_Pass_common.robot
Variables   ../var/netact_server.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${backup_scf_name}   old_commission.xml
${DEBUG}   False
${dist_name} =    NRBTS-${MRBTS_ID}
${dist_name_gold}=    Activate general connectivity gold use case level
${dist_name_silver}=    Activate general connectivity silver use case level
${dist_name_bronze}=    Activate general connectivity bronze use case level
${channel_band}=   Channel bandwidth
${WEB_DOWNLOAD_DIR}   ${OUTPUT_DIR}
${SCC}=   Number of Sector Component Carriers
@{LEVELS}   bronze   silver   gold   bandwidth   beam   power

*** Keywords ***
Common Setup
    [Arguments]   ${netact}=${true}   ${server}=Jiang7
#    robot_common_operations.Common Suite Setup
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    Set Suite Variable   ${NETACT_NAME}   ${server}
    Run Keyword If   '${DEBUG}'=='False'   selenium_coam.enable_virtual_display
    Run Keyword If   '${DEBUG}'=='False'   selenium_netact.enable_virtual_display
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    COAM Backup SCF
    Wait Until Keyword Succeeds   3 times   2m   COAM WEBUI Login
    ${bts_info}   COAM Get BTS Info
    ${cell_numbers}    Get Cell Number
    set suite variable    ${cell_numbers}
#    Run Keyword If   @{bts_info.has_key('mrbtsID')}    Set Suite Variable   ${BTS_ID}   ${bts_info['mrbtsID']}
    Run Keyword If   'mrbtsID' in @{bts_info}  Set Suite Variable   ${BTS_ID}   ${bts_info['mrbtsID']}
    ...   ELSE   Set Suite Variable   ${BTS_ID}   ${bts_info['requestMessage']['mrbtsID']}
    ${cell_num}   Get length   ${bts_info['cells']['nr']}
    FOR    ${cell_id}    IN RANGE    ${cell_num}
       Run Keyword And Ignore Error   Verify cOAM Cell Setup   alias=COAM    cell_id=${cell_id+1}   timeout=30
    END
    ${release_info}   Get gnb release
    Run Keyword If   '${release_info}' == '5G19B' or '${release_info}' == '5G19BCLA'   import variables    ${CURDIR}/../var/license_var_5G19B.py
    ...   ELSE IF   '${release_info}' == '5G19A' or '${release_info}' == '5G19ACLA'    import variables    ${CURDIR}/../var/license_var_5G19A.py
    ...   ELSE   import variables    ${CURDIR}/../var/license_var_trunk.py
    run keyword and ignore error    Preconfig TL to 8DL4UL
    run keyword and ignore error    CM Upload on NetAct Background
    Close All Java Application Forced


Common Teardown
    [Arguments]   ${gnb_type}=classical   ${restore}=${true}
    Run Keyword And Ignore Error    Catch Snapshot COAM
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword If   ${restore}   Restore gNB SCF
    Run Keyword And Ignore Error   selenium_coam.logout
    Run Keyword If   '${DEBUG}'=='False'   selenium_coam.disable_virtual_display
    Run Keyword If   '${DEBUG}'=='False'   selenium_netact.disable_virtual_display
    robot_common_operations.Common Suite Teardown

Restore gNB SCF
    COAM Login
    Wait Until Keyword Succeeds   5 times   1m
    ...   COAM SCF Commission
    wait until keyword succeeds    15min    1min    COAM Check All Cells Onair
    COAM Logout

Step1: Open ${lic_level} Flag With ${band_width} ${scc_num}
    @{gold_flag}    create list     true   true     true
    @{silver_flag}    create list     false     true    true
    @{bronze_flag}    create list     false     false   true
    ${lic_level_flag}=  Set Variable If
    ...     "${lic_level}"=="gold"      ${gold_flag}
    ...     "${lic_level}"=="silver"    ${silver_flag}
    ...     "${lic_level}"=="bronze"    ${bronze_flag}
    Set License Flags by Open Level ${lic_level_flag} ${band_width}
    Check License Open Flags With ${band_width} ${scc_num} ${lic_level_flag}

Set License Flags by Open Level ${lic_level_flag} ${band_width}
    ${return_gold}   selenium_coam.get_parameter_value   MRBTS-${BTS_ID}/${dist_name}   ${dist_name_gold}
    Run Keyword If   '${return_gold}'!='${lic_level_flag[0]}'  selenium_coam.set_parameter_value
    ...     MRBTS-${BTS_ID}/${dist_name}   ${dist_name_gold}   ${lic_level_flag[0]}
    ${return_silver}   selenium_coam.get_parameter_value   MRBTS-${BTS_ID}/${dist_name}   ${dist_name_silver}
    Run Keyword If   '${return_silver}'!='${lic_level_flag[1]}'  selenium_coam.set_parameter_value
    ...     MRBTS-${BTS_ID}/${dist_name}   ${dist_name_silver}   ${lic_level_flag[1]}
    ${return_bronze}   selenium_coam.get_parameter_value   MRBTS-${BTS_ID}/${dist_name}   ${dist_name_bronze}
    Run Keyword If   '${return_bronze}'!='${lic_level_flag[2]}'   selenium_coam.set_parameter_value
    ...     MRBTS-${BTS_ID}/${dist_name}   ${dist_name_bronze}   ${lic_level_flag[2]}
    sleep    3s
    ${flag}   run keyword if
    ...     '${return_gold}'=='${lic_level_flag[0]}' and '${return_silver}'=='${lic_level_flag[1]}' and '${return_bronze}'=='${lic_level_flag[2]}'
    ...     set variable   false
    ...   ELSE   set variable   true
    Wait Until Keyword Succeeds     3 times   2m    run keyword if   '${flag}'=='true'   selenium_coam.validate_plan
    sleep   1m
    run keyword if   '${flag}'=='true'   selenium_coam.activate_plan    ${False}    ${True}    ${True}  360
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    ...   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    selenium_coam.disable_screen_lock
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
    FOR   ${index}    IN RANGE    ${cell_numbers}
       ${return_bandwidth}   selenium_coam.get_parameter_value   MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index+1}   ${channel_band}
       Run Keyword If   '${return_bandwidth}'!='${band_width}'   Modify Bandwidth Parameters   band_width=${band_width}   index=${index+1}
    END
    Run Keyword And Ignore Error   selenium_coam.validate_plan
    sleep  5s
    Run Keyword And Ignore Error   selenium_coam.activate_plan   activate_plan_despite_errors=True
    sleep  5m
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    ...   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    selenium_coam.disable_screen_lock
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    Wait Until Keyword Succeeds   5 min   1 min   COAM Check Units Status Normal   fbb-1   fsm-1

Check License Open Flags With ${band_width} ${scc_num} ${lic_level_flag}
    ${return_gold}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_gold}
    Should Be Equal   ${return_gold}   ${lic_level_flag[0]}
    log to console   ${return_gold}
    ${return_silver}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_silver}
    Should Be Equal   ${return_silver}   ${lic_level_flag[1]}
    ${return_bronze}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_bronze}
    Should Be Equal   ${return_bronze}   ${lic_level_flag[2]}
    ${return_bandwith}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1   filter_param=${channel_band}
    Should Be Equal   ${return_bandwith}   ${band_width}
    ${return_SCCnum}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${SCC}
#    ${return_sccnum}       Convert To Integer       ${return_SCCnum}
    Run Keyword And Ignore Error    COAM LOGOUT
#    COAM Login
#    ${bts_info}   coam.get_bts_info   connection=COAM   timeout=10
#    ${cell_list}   Run Keyword If   'requestMessage' in @{bts_info}
#    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
#    ...   ELSE   Set Variable   ${bts_info['cells']['nr']}
#    ${cell_numbers}    get length    ${cell_list}
    ${scc_num}       convert to integer       ${scc_num}
    ${scc_num}       convert to string       ${scc_num}
    Should Be Equal   ${return_sccnum}   ${scc_num}
#    COAM Logout
    Set Suite Variable   ${return_sccnum}

Preconfig TL to 8DL4UL
    ${return_celltype}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...   filter_param=${NRcelltype}
    Run Keyword If   '${return_celltype}'!='8DL4UL'   _set_parameter_all_index   filter_name=${NRcelltype}  newvalue=8DL4UL
    ${return_beamforming}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...   filter_param=Activate Beamforming
    ${return_oamtls}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...   filter_param=TLS usage towards the operation and maintenance system
    Run Keyword If   '${return_oamtls}'!='off'   selenium_coam.set_parameter_value  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...    TLS usage towards the operation and maintenance system   off
    Run Keyword If   '${return_beamforming}'!='true'   _set_parameter_all_index   filter_name=Activate Beamforming  newvalue=true
    ${return_beamset}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...   filter_param=Basic Beam Set
    Run Keyword If   '${return_beamset}'!='beamSet_2'   _set_parameter_all_index   filter_name=Basic Beam Set  newvalue=beamSet_2
    ${return_beamnum}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELLGRP-0
    ...   filter_param=Number of transmitted Synchronization Signal Blocks
    Run Keyword If   '${return_beamnum}'!='2 beams'   _set_parameter_all_cell_beam_index
    ...   filter_name=Number of transmitted Synchronization Signal Blocks  newvalue=2 beams
    Run Keyword And Ignore Error   selenium_coam.validate_plan
    sleep  5s
    Run Keyword And Ignore Error   selenium_coam.activate_plan   activate_plan_despite_errors=True
    sleep  5m
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    Wait Until Keyword Succeeds   5 min   1 min   COAM Check Units Status Normal   fbb-1   fsm-1

Modify Bandwidth Parameters
    [Arguments]   ${band_width}   ${index}
    selenium_coam.set_parameter_value     dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
    ...   filter_param=${channel_band}    new_value=${band_width}

Modify beam Parameters
    [Arguments]   ${celltype}   ${index}
#    selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
#    ...   filter_param=${Basic_Beam_Set}   new_value=beamSet_${beam_value}
#    ${status}    run keyword and return status      selenium_coam.set_parameter_value
#    ...  dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELLGRP-${index}
#    ...   filter_param=${numberOfTransmittedSsBlocks}   new_value=${beam_value} beams
#    run keyword if  ${status}==${false}   selenium_coam.set_parameter_value
#    ...  dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELLGRP-${index-1}
#    ...   filter_param=${numberOfTransmittedSsBlocks}   new_value=${beam_value} beams
#    selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
#    ...   filter_param=${lteToNrFrameShift}   new_value=3ms
#    selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
#    ...   filter_param=${prachConfigurationIndex}   new_value=98
     ${return_celltype}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
    ...   filter_param=${NRcelltype}
     Run Keyword If   '${return_celltype}'!='${celltype}'     selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}   filter_param=${NRcelltype}   new_value=${celltype}
    Run Keyword If   '${return_celltype}'!='${celltype}'     set test variable    ${active_flag}     ${True}
     ...   ELSE   set test variable    ${active_flag}     ${False}



Modify_beam_Parameters_all_cell
    [Arguments]   ${celltype}
    FOR   ${index}    IN RANGE    ${cell_numbers}
        Modify beam Parameters  celltype=${celltype}    index=${index+1}
    END
    run keyword if   ${active_flag}    _acitve after set parameter
    selenium_coam.disable_screen_lock
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
    ${return_celltype}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...   filter_param=${NRcelltype}
    Should Be Equal   ${return_celltype}   ${celltype}

_acitve after set parameter
    Run Keyword And Ignore Error   selenium_coam.validate_plan
    sleep  5s
    Run Keyword And Ignore Error   selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=360
    sleep  5m
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    Wait Until Keyword Succeeds   3 times   2m   COAM Login
    Wait Until Keyword Succeeds   5 min   1 min   COAM Check Units Status Normal   fbb-1   fsm-1


Modify power Parameters
    [Arguments]   ${pmax_value}   ${index}
    selenium_coam.set_parameter_value     dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
    ...    filter_param=${output power_ban}    new_value=${pmax_value}

_Modify_power_Parameters_all_cell
    [Arguments]    ${pmaxvalue}
    FOR   ${index}    IN RANGE    ${cell_numbers}
          Modify power Parameters      pmax_value=${pmaxvalue}  index=${index}
    END

_Modify_Bandwidth_all_cell
    [Arguments]     ${bandwidth}
    FOR   ${index}    IN RANGE    ${cell_numbers}
        run keyword and ignore error    Modify Bandwidth Parameters   band_width=${bandwidth}   index=${index+1}
    END


Step2: Check ${lic_level} SWEM Report With ${scc_num}
    ${gold_request}    create list     ${scc_num}   ${scc_num}     ${scc_num}
    ${silver_request}    create list     ${scc_num}    ${scc_num}   ${0}
    ${bronze_request}    create list     ${scc_num}    ${0}     ${0}
#    @{${lic_level_request}}   set variable   @{${lic_level}_request}
    ${lic_level_request}    run keyword if   '${lic_level}'=='gold'     copy list     ${gold_request}
    ...   ELSE IF   '${lic_level}'=='silver'     copy list     ${silver_request}
    ...   ELSE IF   '${lic_level}'=='bronze'     copy list     ${bronze_request}
    wait until keyword succeeds    3x    1min    Check license level SWEM Report With licese req
    ...   lic_level=${lic_level}   license_req=${lic_level_request}

Check license level SWEM Report With licese req
     [Arguments]    ${lic_level}   ${license_req}
     ${sales_item}=   Set Variable If
     ...   '${lic_level}'=='gold'    5G000004
     ...   '${lic_level}'=='silver'    5G000003
     ...   '${lic_level}'=='bronze'    5G000002
     ${expect_value}=   Set Variable If
     ...   '${lic_level}'=='gold'    ${license_req[2]}
     ...   '${lic_level}'=='silver'    ${license_req[1]}
     ...   '${lic_level}'=='bronze'    ${license_req[0]}
     Download SWEM Report as CSV    report_type=detailed
     ${value}   Get Licensed Capacity Via CSV   sales_item=${sales_item}   report_type=detailed
#     ${value}   Convert To Integer   ${value}
     ${expect_value}   convert to Integer    ${expect_value}
     ${expect_value}   convert to string    ${expect_value}
#     ${expect_value}=    Evaluate    ${expect_value}
     should be equal   ${value}   ${expect_value}



Get Scc by Frequency
    [Arguments]    ${bandwidth}
    ${cell_info}     selenium_coam.get_cell_info    cell_idx=1
    ${frequency}    set variable   ${cell_info['NRARFCN']}
    ${size_scc}    set variable if      ${frequency}<200000      5
    ...            ${frequency}>=200000 and ${frequency}<600000     10
    ...            ${frequency}>=600000 and ${frequency}<800000     20
    ...            ${frequency}>=800000 and ${frequency}<1800000    NA
    ...            ${frequency}>=1800000      200
    ${scc_num}      set variable    ${${bandwidth.split('M')[0]}/${size_scc}}
    [Return]    ${scc_num}


Get Cell Number
    ${cell_list}   COAM Get Cell List
    ${cell_numbers}    get length    ${cell_list}
    [Return]    ${cell_numbers}

_set_parameter_all_index
    [Arguments]    ${filter_name}    ${newvalue}
    FOR   ${index}    IN RANGE    ${cell_numbers}
         run keyword and ignore error    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index+1}   filter_param=${filter_name}  new_value=${newvalue}
    END

_set_parameter_all_cell_beam_index
    [Arguments]    ${filter_name}    ${newvalue}
    FOR   ${index}    IN RANGE    ${cell_numbers}
         run keyword and ignore error    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELLGRP-${index}   filter_param=${filter_name}  new_value=${newvalue}
    END
