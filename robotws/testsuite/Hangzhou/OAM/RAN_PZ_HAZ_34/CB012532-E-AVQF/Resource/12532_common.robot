*** Settings ***
Documentation
...  author: ruiyu.han
...  contact: ruiyu.han@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB012532-E-AVQF/Resource/resource.py


*** Keywords ***
12532 Common Suite Setup
    robot_common_operations.Common Suite Setup
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}
    Create directory    ${epc_log_path}
    Siso Common Suite Setup
    ${release}    Return scf release name
    Set Suite Variable    ${release}
    Wait Until Keyword Succeeds   3x   6s   COAM Login
    COAM Backup Full SCF    file_name=siso_scf.xml
    ${bbmod_mapping}     Siso Common Get BBMOD Mapping RMOD    source=${OUTPUT_DIR}/siso_scf.xml
    ${bbmod_cell_mapping}    Siso Common Get BBMOD Mapping Cell     source=${OUTPUT_DIR}/siso_scf.xml
    ${bbmods_info}     Get BBMODs info
    ${siso_scf_xml}    set variable    ${OUTPUT_DIR}/siso_scf.xml
    Set Suite Variable    ${siso_scf_xml}
    set Suite variable     ${bbmod_mapping}
    set Suite variable     ${bbmods_info}
    set Suite variable     ${bbmod_cell_mapping}


    ${RU_flag}    COAM Get Parameter Value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=actRuResetResiliency
    run keyword if   '${RU_flag}'=='true'    12532 COAM Change actRuResetResiliency Value    value=false
    run keyword if   '${RU_flag}'=='true'    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    [Teardown]    COAM Logout

Return scf release name
   ${gnb_release}   Get gnb release    host=${LMP_ADDR}
   ${scfname}    Run keyword if   '${gnb_release}'=='TRUNK'     set variable   SBTS00
#   ...   ELSE IF    '${gnb_release}'!='TRUNK'    String.Fetch From Right    string=${gnb_release}    marker=SBTS
   ...   ELSE IF    '${gnb_release}'!='TRUNK'    set variable   ${gnb_release}
   [Return]     ${scfname}

12532 Common Suite Teardown
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds   3x   6s   COAM Login
    COAM SCF Commission     filepath=${OUTPUT_DIR}/siso_scf.xml
    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    Run Keyword and Ignore Error   COAM Logout

Case Setup for 12532
    [Documentation]   Setup WEBUI login and start btslog collection
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds   3x   6s   COAM Login
    Recovery At Case Setup if Fault Occurs
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    ${L3CALL_enable}    run keyword if  '${MRBTS_ID}' in @{L3CALL_TL.keys()}    set variable   ${True}    ${False}
    Set Suite Variable    ${L3CALL_enable}



Case Teardown for 12532
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    Check Extra Reset From Blackbox
    run keyword and ignore error   Wait Until Keyword Succeeds   3x   6s   COAM Login
    Siso Common Save Logs
    Run Keyword and Ignore Error   COAM Logout


12532 COAM Change actRuResetResiliency Value
    [Arguments]    ${value}
    ${dict_param}    Create Dictionary    value=${value}    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actRuResetResiliency
    ${list_param}    Create List    ${dict_param}
    ${param_dic_to_change}    Create Dictionary    update=${list_param}
    COAM Commission Prameters Operation    param_dic_to_change=${param_dic_to_change}


CB012532_Defined_BBMOD_Reset
    [Documentation]   CB012532_Defined_BBMOD_Reset
    [Arguments]    ${times}=${1}
    Case Setup for 12532
   FOR   ${index}    IN RANGE    ${times}
       continue for loop if    '${tl.gnbs[0].global_bts_id}' in @{BB_ignore_TL}
       log to console     //this is index：${index} time do Defined BBMODs Reset...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['bbmod_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
        Reset Defined BBMODs    bbmod_index_list=${BBMOD_TL["${MRBTS_ID}"]}
    END
    [Teardown]     Case Teardown for 12532


CB012532_Change_3cc_to_4cc
    [Documentation]   CB012532_Change_3cc_to_4cc
    Case Setup for 12532
    Start Syslog Collection
    COAM SCF Commission     filepath=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_${release}_4CC.xml
    Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
    [Teardown]     run keywords     Siso Common Each Time Teardown    AND  Case Teardown for 12532

CB012532_nrcelltype_recommisson
    [Documentation]   CB012532_nrcelltype_recommisson
    [Arguments]    ${times}=${10}
    Case Setup for 12532
    Start Syslog Collection
    FOR    ${index}    IN RANGE    ${times}
        Log To Console    this is times:${index} to nrcelltype_recommisson
        COAM Commission Prameters Operation    param_dic_to_change=${nrcelltype_TO_recommison}
        Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
        COAM Commission Prameters Operation    param_dic_to_change=${nrcelltype_TO_recommison_ori}
        Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
    END
    [Teardown]     run keywords     Siso Common Each Time Teardown    AND  Case Teardown for 12532

CB012532_online_add_delete_cells
    [Documentation]   CB012532_online_add_delete_cells
    [Arguments]    ${times}=${10}
    Case Setup for 12532
    FOR   ${index}    IN RANGE    ${times}
        Log To Console    this is times:${index} to online_add_delete_cells
        Start Syslog Collection
        FOR    ${cell}    IN    @{CELLS_TO_DEL['${MRBTS_ID}']}
            COAM Online Delete Nrcell    cell_index=${cell}
        END

        FOR    ${cell}    IN    @{PARAMS_TO_add_cell}
            COAM Online Add Nrcell   params_change=${PARAMS_TO_add_cell['${cell}']}    copy_cellindx=31    cell_index=${cell}
            Repeat Keyword    1min    Run Keywords    COAM Check all cells should be onair but one    exclude_cellid=${cell}
             ...    AND    Sleep    5s
            Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
        END
    END
    [Teardown]    run keywords     Siso Common Each Time Teardown    AND  Case Teardown for 12532


CB012532_multi_parameters_recommisson
    [Documentation]   CB012532_multi_parameters_recommisson
    [Arguments]    ${times}=${10}
    Case Setup for 12532
    FOR   ${index}    IN RANGE    ${times}
        Log To Console    this is times:${index} to subband_TO_recommison
        Start Syslog Collection
        COAM Commission Prameters Operation    param_dic_to_change=${subband_TO_recommison}
        Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
        COAM Commission Prameters Operation    param_dic_to_change=${subband_TO_recommison_ori}
        Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
    END

    FOR   ${index}    IN RANGE    ${times}
        Log To Console    this is times:${index} to 72a_TO_recommison
        Start Syslog Collection
        COAM Commission Prameters Operation    param_dic_to_change=${72a_TO_recommison}
        Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
        COAM Commission Prameters Operation    param_dic_to_change=${72a_TO_recommison_ori}
        Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
    END
    [Teardown]    run keywords     Siso Common Each Time Teardown    AND  Case Teardown for 12532


CB012532 Common Case Setup
    robot_common_operations.Common Case Setup

CB012532 Common Case Teardown
    CI_interface.Common Suite Setup
    run keyword and ignore error   Wait Until Keyword Succeeds   3x   6s   COAM Login
    Wait Until Keyword Succeeds    20m   30s   COAM Check All Cells Onair
    robot_common_operations.Common Case Teardown
