*** Settings ***
Documentation    This is common keywords for siso RRH related cases level
...              Please do not modify the file without notification to author
...              Author: Chen Jun
...              Contact: jun.8.chen@nokia-sbell.com
...              Squard: HZ SG6

Library    BuiltIn
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    ./siso_resource.robot

*** Variables ***
&{fault_61652}    faultId=${61652}
&{fault_61524}    faultId=${61524}
&{fault_7319}     faultId=${7319}
&{fault_7300}     faultId=${7300}
&{fault_4592}    faultId=${4592}
&{fault_4655}    faultId=${4655}
&{fault_4654}    faultId=${4654}
&{fault_1932}    faultId=${1932}
&{fault_4681}    faultId=${4681}
&{fault_7308}     faultId=${7308}
&{fault_61649}     faultId=${61649}
@{ALLOWED_FAULT_ID}    &{fault_61652}    &{fault_61524}    &{fault_4592}    &{fault_4655}    &{fault_4654}    &{fault_1932}    &{fault_4681}
...                    &{fault_61649}

*** Keywords ***
General SiSo Cell Lock Unlock
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ...                Descrition：query cell number then lock&unlock cell one by one, Single cell in one cell_group
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=180
    ${cell_num}    RRH_common_keyword.COAM Get GNB CELL Number    connection=${connection}
    @{cell_list}    Create List
    ${allowed_faults}    Create List    @{ALLOWED_FAULT_ID}    ${fault_7319}    ${fault_7300}
    FOR    ${cell_index}    IN RANGE    1    ${cell_num}+${1}
        Append To List    ${cell_list}    ${cell_index}
    END
    FOR    ${cell_idx}    IN    @{cell_list}
        ${cell_group_idx}    Evaluate    ${cell_idx}-1
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
        Perform cell lock via rest api    cell_idx=${cell_idx}    timeout=${timeout}
        Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Locked    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
        ...    connection=${connection}
        Run Keyword If    '${cell_num}'=='${1}'    run keywords
        ...    Wait For Expect Fault Present   faultId=${7300}   timeout=600    connection=${connection}    AND
        ...    Unexpect Alarm Should Not Exist  allowed_faults=${allowed_faults}    connection=${connection}
        ...    ELSE    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}
        ...                                                                                      connection=${connection}
        Perform cell unlock via rest api    cell_idx=${cell_idx}    timeout=${timeout}
        Wait Until Keyword Succeeds    600 sec    3 sec    Cell Should Be Unlocked    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
        ...    connection=${connection}
        Wait Until Keyword Succeeds    600 sec    5 sec    COAM Check GNB cell on air    connection=${connection}
        Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
        Perform cell group lock via rest api    cellgrp_idx=${cell_group_idx}    timeout=${timeout}
        Wait Until Keyword Succeeds    600 sec    3 sec    Cell Group Should Be Locked    cell_group_idx=${cell_group_idx}
        Wait Until Keyword Succeeds    600 sec    3 sec    Cell Should Be Locked    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
        ...    connection=${connection}
        Run Keyword If    '${cell_num}'=='${1}'    run keywords
        ...    Wait For Expect Fault Present   faultId=${7300}   timeout=600    connection=${connection}    AND
        ...    Unexpect Alarm Should Not Exist  allowed_faults=${allowed_faults}    connection=${connection}
        ...    ELSE    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}
        ...                                                                                      connection=${connection}
        Perform cell group unlock via rest api    cellgrp_idx=${cell_group_idx}    timeout=${timeout}
        Wait Until Keyword Succeeds    600 sec    3 sec    Cell Group Should Be Unlocked    cell_group_idx=${cell_group_idx}
        Wait Until Keyword Succeeds    600 sec    3 sec    Cell Should Be Unlocked    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
        ...    connection=${connection}
        Wait Until Keyword Succeeds    600 sec    5 sec    COAM Check GNB cell on air    connection=${connection}
        Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
    END
    COAM Wait for gnb ready and cell setup    timeout=10 min    connection=${connection}

General SiSo RU Lock Unlock
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ...                Descrition：query ru number then lock&unlock cell one by one
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=120    ${gnb_id}=0
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    ${allowed_faults}    Create List    @{ALLOWED_FAULT_ID}    ${fault_7319}    ${fault_7300}    ${fault_7308}
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        ${cell_group_idx}    Evaluate    ${ru_index}-1
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
        Perform RU lock via rest api    ru_idx=${ru_index}    connection=${connection}    timeout=${timeout}    gnb_id=${gnb_id}
        Wait Until Keyword Succeeds    180 sec    3 sec    RU Should Be Locked    ru_index=${ru_index}    connection=${connection}
        Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Disabled    cell_idx=${ru_index}    cell_group_idx=${cell_group_idx}
        ...    connection=${connection}
        Run Keyword If    '${ru_num}'=='${1}'    run keywords
        ...    Wait For Expect Fault Present   faultId=${7300}   timeout=600    connection=${connection}    AND
        ...    Unexpect Alarm Should Not Exist  allowed_faults=${allowed_faults}    connection=${connection}
        ...    ELSE    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}
        ...                                                                                      connection=${connection}
        Perform RU unlock via rest api    ru_idx=${ru_index}    connection=${connection}    timeout=${timeout}    gnb_id=${gnb_id}
        Wait Until Keyword Succeeds    240 sec    3 sec    RU Should Be Unlocked    ru_index=${ru_index}    connection=${connection}
        Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Enabled    cell_idx=${ru_index}    cell_group_idx=${cell_group_idx}
        ...             connection=${connection}
        Wait Until Keyword Succeeds    600 sec   5 sec     COAM Check GNB cell on air    connection=${connection}
        Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui    connection=${connection}    gnb_index=${gnb_id}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
    END
    COAM Wait for gnb ready and cell setup    timeout=10 min    connection=${connection}

General SiSo RF Module Power Reset
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ...                Descrition：query ru number then power reset ru one by one
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0    ${du_index}=0
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        ${cell_group_idx}    Evaluate    ${ru_index}-1
        &{fault_10} =    Create Dictionary    faultId=${10}    source=RMOD_R-${ru_index}
        ${allowed_faults}   Create List   @{ALLOWED_FAULT_ID}    ${fault_10}    ${fault_7319}    ${fault_7300}
        ${allowed_1_faults}   Create List   @{ALLOWED_FAULT_ID}    ${fault_10}
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
        Perform RU Power Off    ru_index=${ru_index}
        ...    model=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
        Wait Until Keyword Succeeds    180 sec    3 sec    RU Should Be Power Off    ru_index=${ru_index}    connection=${connection}
        Run Keyword If    '${ru_num}'=='${1}'    run keywords
        ...    Wait For Expect Fault Present   faultId=${10}   source=RMOD_R-1   timeout=60    connection=${connection}    AND
        ...    Wait For Expect Fault Present   faultId=${7300}   timeout=600    connection=${connection}    AND
        ...    Unexpect Alarm Should Not Exist  allowed_faults=${allowed_faults}    connection=${connection}
        ...    ELSE    run keywords
        ...    Wait For Expect Fault Present   faultId=${10}   source=RMOD_R-${ru_index}   timeout=60    connection=${connection}    AND
        ...    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${allowed_1_faults}
        ...                                                                                      connection=${connection}
        Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Disabled    cell_idx=${ru_index}    cell_group_idx=${cell_group_idx}
        ...    connection=${connection}
        Perform RU Power On    ru_index=${ru_index}
        ...    model=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
        Wait For Expect Fault To Disappear   faultId=${10}  source=RMOD_R-${ru_index}   timeout=600
        ...    connection=${connection}
        Wait Until Keyword Succeeds    240 sec    3 sec    RU Should Be Online    ru_index=${ru_index}    connection=${connection}
        Wait Until Keyword Succeeds    600 sec   5 sec     COAM Check GNB cell on air    connection=${connection}
        Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui
        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
    END
    COAM Wait for gnb ready and cell setup    timeout=10 min    connection=${connection}

General SiSo RU Module Reset From GUI
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ...                Descrition：query ru number then reset ru one by one
    [Arguments]    ${connection}=GNB_OAM
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        ${cell_group_idx}    Evaluate    ${ru_index}-1
        Perform RU Reset    ru_index=${ru_index}
        Wait Until Keyword Succeeds    90 sec    5 sec    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
        Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Disabled    cell_idx=${ru_index}    cell_group_idx=${cell_group_idx}
        ...    connection=${connection}
    END
    Wait For Expect Fault Present   faultId=${7300}   timeout=600    connection=${connection}
    ${allowed_faults}   Create List   @{ALLOWED_FAULT_ID}   ${fault_7319}   ${fault_7300}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${allowed_faults}    connection=${connection}
    COAM Wait for gnb ready and cell setup    timeout=15 min    connection=${connection}
    Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}

General SiSo SOAP RP1 Verification
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ru_resource_build_key}    ${connection}=GNB_OAM    ${gnb_connection}=ASIK Master
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}   ru_alias=RU${ru_index}   asik_alias=${gnb_connection}   connection=${connection}
        Enable capture soap msg flag on RU    ru_alias=RU${ru_index}
        ${soap_log_path} =    Download soap msg from RU    ru_alias=RU${ru_index}
        &{soap_info}    Get Detail Info In SOAP Message    Soap_log_path=${soap_log_path}
        ${ru_info} =    COAM get ru detial info by ru index    ru_index=${ru_index}    connection=${connection}
        ${ru_target_build} =    COAM get expected ru sw version from target BD file    ru_resource_build_key=${ru_resource_build_key}
        ...                                                                            asik_alias=${gnb_connection}
        Run Keyword And Ignore Error    csn.disconnect    connection=RU${ru_index}
        Should Be Equal As Strings    ${soap_info['productCode']}    ${ru_info['productCode']}
        Should Be Equal As Strings    ${soap_info['serialNum']}     ${ru_info['serialNumber']}
        Should Be Equal As Strings    ${soap_info['moduleType']}     RRH
#        Should Be Equal As Strings    ${soap_info['interfaceType']}     CPRI
        Should Be Equal As Strings    ${soap_info['bldName']}        ${ru_target_build}
        Should Be Equal As Strings    ${soap_info['bldVersion']}     ${ru_target_build}
    END

General SiSo RF Module Addition In BIM And WebUI
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_connection}=ASIK Master
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}   ru_alias=RU${ru_index}   asik_alias=${gnb_connection}   connection=${connection}
        ${product_code_on_ru}     csn.execute    command=cat /mnt/factory/configs/unit/module_product_code.txt    connection=RU${ru_index}
        ${serial_number_on_ru}    csn.execute    command=cat /mnt/factory/configs/unit/module_serial_number.txt    connection=RU${ru_index}
        ${ru_info}      COAM get ru detial info by ru index    ru_index=${ru_index}   connection=${connection}
        Run Keyword And Ignore Error    csn.disconnect    connection=RU${ru_index}
        Should Be Equal As Strings   ${product_code_on_ru.strip()}   ${ru_info['productCode']}
        Should Be Equal As Strings    ${serial_number_on_ru.strip()}   ${ru_info['serialNumber']}
    END

General SiSo BTS Reset With RF Power Reset
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM     ${gnb_index}=0    ${du_index}=0
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        Perform RU Power Off    ru_index=${ru_index}
        ...    model=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
        Wait Until Keyword Succeeds    180 sec    3 sec    RU Should Be Power Off    ru_index=${ru_index}    connection=${connection}
    END
    Perform BTS Site Reset
    Wait Until Keyword Succeeds    600 sec    5 sec   Verify BTS Restart
    Wait Until Keyword Succeeds    6min    5 sec   Connect to gnb coam via ssl
    Sleep    10 sec
    FOR    ${ru_index}    IN    @{ru_list}
        Perform RU Power On    ru_index=${ru_index}
        ...    model=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
    END
    COAM Wait for gnb ready and cell setup    timeout=18 min    connection=${connection}
    Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}

General SiSo Collect RFSW Logs From RU Into BTS Snapshot
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_connection}=ASIK Master
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU${ru_index}    asik_alias=${gnb_connection}
        ...                                                                                  connection=${connection}
        Verify RFSW Log Include In Snapshot    ru_index=${ru_index}    ru_alias=RU${ru_index}    connection=${connection}
    END

General SiSo BTS Startup With RF Delayed Startup
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0    ${du_index}=0
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    Perform Site Power Off
    FOR    ${ru_index}    IN    @{ru_list}
        Perform RU Power Off    ru_index=${ru_index}
        ...    model=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
    END
    Sleep    10 sec
    Perform Site Power On
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5 min    20 sec    COAM Check GNB ABIL status    connection=${connection}
    Wait Until Keyword Succeeds    5 min    20 sec    COAM Check GNB ASIK status    connection=${connection}
    FOR    ${ru_index}    IN    @{ru_list}
        Wait Until Keyword Succeeds    30 sec    3 sec    RU Should Be Power Off    ru_index=${ru_index}    connection=${connection}
        Perform RU Power On    ru_index=${ru_index}
        ...    model=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
    END
    COAM Wait for gnb ready and cell setup    timeout=15 min    connection=${connection}
    Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}

General SiSo RF Module Reset Triggered By User As Part Of BTS Reset
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_connection}=ASIK Master
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
    Connect to Common Unit Master    alias=${gnb_connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}   ru_alias=RU${ru_index}   asik_alias=${gnb_connection}   connection=${connection}
        ${ru_reset_tag} =    gnb_classical_hangzhou.Create RU temp file    ru_alias=RU${ru_index}
    END
    Run Keyword And Ignore Error    csn.disconnect    connection=${gnb_connection}
    Perform BTS Site Reset
    Wait Until Keyword Succeeds    600 sec    5 sec   Verify BTS Restart
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
#    Wait For Expect Fault Present   faultId=${7300}   timeout=420
    COAM Wait for gnb ready and cell setup    timeout=15 min    connection=${connection}
    csn.Reset Cache
    Connect to Common Unit Master    alias=${gnb_connection}
    FOR    ${ru_index}    IN    @{ru_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}   ru_alias=RU${ru_index}   asik_alias=${gnb_connection}   connection=${connection}
        gnb_classical_hangzhou.Verify RU temp file disappeared     last_ru_tag=${ru_reset_tag}    ru_alias=RU${ru_index}
    END
    Run Keyword And Ignore Error    csn.disconnect    connection=${gnb_connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}

General SiSo CPRI Link Configuration
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    ...            ${gnb_connection}=ASIK Master
    ...            ${hw_slot}=${1}
    ...            ${alias}=ABIL Loner
    ...            ${CPRI_LINK_8_STATE_REGISTER}=0xdf261004              #for 19B
    ...            ${CPRI_LINK_9_STATE_REGISTER}=0xdf271004              #for 19B
    Wait Until Keyword Succeeds   5 min   15 sec   COAM Check GNB cell on air
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}
    Perform BTS Site Reset
    Wait Until Keyword Succeeds    600 sec    5 sec   Verify BTS Restart
    COAM Wait for gnb ready and cell setup    timeout=15 min    connection=${connection}
    Connect to Common Unit Master    alias=${gnb_connection}
    Connect to Capacity Unit Loner    hw_slot=${hw_slot}    alias=${alias}    asik_alias=${gnb_connection}
    Repeat keyword    180 s    Run keywords
    ...    RRH_common_keyword.Verify CPRI Link Status    cpri_state_register=${CPRI_LINK_8_STATE_REGISTER}    loner_alias=${alias}    AND
    ...    RRH_common_keyword.Verify CPRI Link Status    cpri_state_register=${CPRI_LINK_9_STATE_REGISTER}    loner_alias=${alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${gnb_connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ID}    connection=${connection}

COAM Get GNB RU Number
    [Documentation]  Author: Jia Lei
    ...                Descrition：get rru number from site
    [Arguments]    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    log    ${hw_info}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${count_RUs}    convert to integer    ${count_RUs}
    [Return]    ${count_RUs}

COAM Get GNB CELL Number
    [Documentation]  Author: mengping cai
    ...                Descrition：get cell number from site
    [Arguments]    ${connection}=GNB_OAM
    ${cell_info}    coam.get_cells_info    connection=${connection}
    log    ${cell_info}
    @{list_CELLs}    Set variable    ${cell_info}
    ${count_CELLs}    Get length    ${list_CELLs}
    ${count_CELLs}    convert to integer    ${count_CELLs}
    [Return]    ${count_CELLs}

Verify CPRI Link Status
    [Arguments]     ${cpri_state_register}    ${loner_alias}=ABIL Loner
    ${cmd_get_cpri_link_state}    set variable    devmem ${cpri_state_register}
    ${cpri_link_state_raw}    csn.Execute    command=${cmd_get_cpri_link_state}    connection=${loner_alias}
    ${cpri_link_state}    Strip String     ${cpri_link_state_raw}
    ${cpri_link_state_explainatin}    Set variable if    '${cpri_link_state}'=='0x00000010'    Synced
    ...    '${cpri_link_state}'=='0x00000002'    Loss of Frame
    ...    '${cpri_link_state}'=='0x00000003'    Loss of Signal
    ...    Undefined state
    should be equal    ${cpri_link_state}    0x00000010
    ...    msg=CPRI Link NOT Synced, current state is: ${cpri_link_state}, ${cpri_link_state_explainatin}

Verify All Used RU Type
    [Arguments]  ${ru_num}=1    ${ru_type}=AZQG    ${connection}=GNB_OAM
    FOR  ${index}    IN RANGE    ${ru_num}
        ${index}    Evaluate    ${index}+${1}
        ${ru_info}      COAM get ru detial info by ru index    ru_index=${index}    connection=${connection}
        Should Be Equal    ${ru_type}   ${ru_info['productName']}
    END

Modify All Chbw Para
    [Documentation]  Author: xiaoxia.hao
    ...                Descrition：get cell number from site
    ...                modify_cell_ids: can be a list for cell index, and also can be a string, like 1;
    ...                   Default to all: all cells on GNB will be updated
    ...               it only support modify NSA CHBW
    [Arguments]   ${bandwidth}=100MHz
    ...            ${shutdown_value}=none
    ...            ${gscn}=none
    ...            ${connection}=GNB_OAM
    ...            ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...            ${PDCCH_CONFIG_DEDICATED}=PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...            ${modify_cell_ids}=all
    ...            ${gnb_index}=0
    ...            ${prachRootSequenceIndex}=none
    &{shutdown_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}   parameter=shutdownNogNBCellTmr    value=${shutdown_value}
    @{modify_param}    Create List
    run keyword if  not "${shutdown_value}"=="none"    Append To List    ${modify_param}    ${shutdown_param}
    ${gnb_nr_cell_id_mapping}    get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    ${all_cell_ids}    Get dictionary keys    ${gnb_nr_cell_id_mapping}
    ${is_all_cellls_entered}    Run keyword and return status    Should contain    ${modify_cell_ids}    all
    ${modify_cell_ids}    Set variable if    ${is_all_cellls_entered}    ${all_cell_ids}    ${modify_cell_ids}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    FOR    ${cell_index}    IN    @{modify_cell_ids}
        &{bandwidth_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}    parameter=chBw    value=${bandwidth}
        Append To List    ${modify_param}    ${bandwidth_param}
        ${gscn_value}    coam_parameter.get_single_value_from_scf_file    parameter=gscn    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}
        ...                                                               connection=${connection}
        ${gscn_value_length}    Get Length    ${gscn_value}
        ${gscn_param_name}    set variable if    "${gscn_value_length}"=="0"     gscnOrSsPbchArfcn    gscn
        &{gscn_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}    parameter=${gscn_param_name}    value=${gscn}
        run keyword if  not "${gscn}"=="none"    Append To List    ${modify_param}    ${gscn_param}
        &{prachRootSequenceIndex_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_index}
        ...    parameter=prachRootSequenceIndex    value=${prachRootSequenceIndex}
        run keyword if  not "${prachRootSequenceIndex}"=="none"    Append To List    ${modify_param}    ${prachRootSequenceIndex_param}
    END
    ${PDCCH_CONFIG_DEDICATED_params}    Modify 2197 parameter based on chbw for cells    modify_cell_ids=${modify_cell_ids}
    ...    connection=${connection}        gnb_index=${gnb_index}    bandwidth=${bandwidth}
    ${modify_param}    combine lists    ${modify_param}    ${PDCCH_CONFIG_DEDICATED_params}
    [Return]    @{modify_param}

Verify BTS Restart
    [Documentation]   Author:xiangyue.zhou@nokia-sbell.com
    ...              Description: This keyword for verify cluster restart function take action
    ${status} =    Run Keyword And Return Status    coam_gnb_classical.Connect to gnb coam via ssl
    Should Be Equal    ${status}    ${False}

Get Cell ID list via Admin CLI
    [Documentation]    :Author: xiaoxia.hao@nokia-sbell.com
    ...                  this keyword is used to get cell id list from GNB via admin cli.
    ...                  FOR example:    [u'NRCELL-2', u'NRCELL-1']
    [Arguments]    ${connection}=GNB_OAM
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_group_list}    get dictionary keys    ${cell_info}
    ${cell_list}   create list
    FOR    ${cell_group}    IN    @{cell_group_list}
        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    ${cell_group}
        ${cell_id_list}    Get Dictionary Keys    ${cell_from_cellgrp}
        ${cell_list}    combine lists    ${cell_id_list}    ${cell_list}
    END
    sort list    ${cell_list}
    [Return]    ${cell_list}

Modify 2197 parameter based on chbw for cells
    [Documentation]  Author: Jia Lei
    ...    list_cell_ids: can be a list for cell index, and also can be a string, like 1;
    ...                   Default to all: all cells on GNB will be updated
    [Arguments]    ${modify_cell_ids}=all    ${connection}=GNB_OAM    ${gnb_index}=0
    ...             ${bandwidth}=100MHz
    ...             ${connection}=GNB_OAM
    ...             ${PDCCH_CONFIG_DEDICATED}=PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    @{bwpdN_list}    Create List
    @{modify_2197_params}    Create List
    FOR    ${cell_index}    IN    @{modify_cell_ids}
        ${dist_name}    set variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell_index}
        ${bwpDN_value}    Get BWPDN From SCF File based on cellid    nrcell_id=${cell_index}
        ...                                                          connection=${connection}
        ...                                                          nr_bts_id=${tl.gnbs[${gnb_index}].global_bts_id}
        append to list    ${bwpdN_list}    ${bwpDN_value}
    END
    FOR    ${bwpDN}    IN    @{bwpdN_list}
         ${2197_params}    Modify 2197 related Paras    bwpDN=${bwpDN}    bandwidth=${bandwidth}    connection=${connection}
         ${modify_2197_params}    combine lists    ${modify_2197_params}    ${2197_params}
    END
    [Return]    @{modify_2197_params}

Get BWPDN From SCF File based on cellid
    [Documentation]    :Author: lei.jia@nokia-sbell.com
    ...                  this keyword is used to get BWP Profile Dist Name from SCF according to cellBwpId.
    ...                  for example: for cellBwpId==1, bwpDN is MRBTS-275/NRBTS-1/BWP_PROFILE-41
    [Arguments]     ${cellBwpId}=1
    ...              ${nrcell_id}=1
    ...              ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ${bwp_dn_paras}    Get BWPDN For Specific Cell    nrcell_id=${nrcell_id}
    ...                                               connection=${connection}
    ...                                               nr_bts_id=${nr_bts_id}
    FOR    ${bwp_dn_para}    IN    @{bwp_dn_paras}
        ${cellbwpid_value}    Get from Dictionary    ${bwp_dn_para}    cellBwpId
        ${bwpDN_value}    run keyword if    ${cellbwpid_value}==${cellBwpId}    Get from Dictionary    ${bwp_dn_para}    bwpDN
    END
    [Return]    ${bwpDN_value}

Get BWPDN For Specific Cell
    [Documentation]    :Author: xiaoxia.hao@nokia-sbell.com
    ...                  this keyword is used to get BWP Profile Dist Name Paras.
    ...                  for example:    [{u'cellBwpId': '1', u'bwpDN': 'MRBTS-84/NRBTS-1/BWP_PROFILE-44'}]
    [Arguments]    ${nrcell_id}=1
    ...             ${connection}=GNB_OAM
    ...             ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    @{bwp_profile_ids}    create list
    @{bwp_dn_value}    create list
    @{cellBwpList_params}    create list
    &{cellBwpList0}    Create Dictionary    cellBwpId=0    bwpDN=None
    &{cellBwpList1}    Create Dictionary    cellBwpId=1    bwpDN=None
    Append To List    ${bwp_dn_value}    ${cellBwpList0}    ${cellBwpList1}
    @{bwp_profile_ids}    Create List
    &{bwp_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${nrcell_id}
    ...    parameter=cellBwpList
    ...    value=${bwp_dn_value}
    Append To List    ${cellBwpList_params}    ${bwp_param}
    ${bwp_profile_dn}    coam_parameter.get_list_values_from_scf_file    parameters=${cellBwpList_params}   connection=${connection}
    [Return]    ${bwp_profile_dn[0]['value']}

Modify 2197 related Paras
    [Documentation]    :Author: xiaoxia.hao@nokia-sbell.com
    ...                  this keyword is used to modify 2197 related paras for chbw 20M/40M on NSA
    ...                  paras: size, numOfPdcchCandidatesInAL4, numOfPdcchCandidatesInAL4
    [Arguments]    ${bwpDN}
    ...             ${bandwidth}=100MHz
    ...             ${connection}=GNB_OAM
    ...             ${PDCCH_CONFIG_DEDICATED}=PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    @{coresetDedicated}    create list
    @{searchSpaceDedicated_value}    create list
    @{PDCCH_CONFIG_DEDICATED_params}    create list
    ${chBw}    Fetch From Left    string=${bandwidth}    marker=MHz
    ${numOfPdcchCandidatesInAL4_coresetid0}   Set Variable If
    ...   '${chBw}' in ['20', '30', '40', '70', '80', '90', '100']    n2
    ...   '${chBw}' in ['50', '60']    n4
    ${numOfPdcchCandidatesInAL4_coresetid1} =    run keyword if
    ...               '${chBw}' == '20'    set variable    n2
    ...    ELSE IF    '${chBw}' == '30'    set variable    n3
    ...    ELSE IF    '${chBw}' == '40'    set variable    n4
    ...    ELSE       set variable    n5
    &{searchSpaceDedicated0}    Create Dictionary    numOfPdcchCandidatesInAL4=${numOfPdcchCandidatesInAL4_coresetid0}
    &{searchSpaceDedicated1}    Create Dictionary    numOfPdcchCandidatesInAL4=${numOfPdcchCandidatesInAL4_coresetid1}
    Append To List    ${searchSpaceDedicated_value}    ${searchSpaceDedicated0}    ${searchSpaceDedicated1}
    &{searchSpaceDedicated_params}    Create Dictionary    dist_name=${bwpDN}/${PDCCH_CONFIG_DEDICATED}
    ...    parameter=searchSpaceDedicated
    ...    value=${searchSpaceDedicated_value}
    ${coresetDedicated_size} =    run keyword if
    ...               '${chBw}' == '20'    set variable    48
    ...    ELSE IF    '${chBw}' == '30'    set variable    72
    ...    ELSE IF    '${chBw}' == '40'    set variable    96
    ...    ELSE       set variable    120
    &{coresetDedicated_size_dict}    Create Dictionary    size=${coresetDedicated_size}
    Append To List    ${coresetDedicated}    ${coresetDedicated_size_dict}
    &{coresetDedicated_params}    Create Dictionary    dist_name=${bwpDN}/${PDCCH_CONFIG_DEDICATED}
    ...    parameter=coresetDedicated
    ...    value=${coresetDedicated}
    Append To List    ${PDCCH_CONFIG_DEDICATED_params}    ${searchSpaceDedicated_params}    ${coresetDedicated_params}
    [Return]    @{PDCCH_CONFIG_DEDICATED_params}

Get gNbCuType From SCF
    [Documentation]     Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    ...              ${nr_bts_id}=${tl.gnbs[0].global_bts_id}
    ...              ${MRBTS_id}= ${tl.gnbs[0].instance_id}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${gNbCuType_dist_name}    convert to string    MRBTS-${MRBTS_id}/NRBTS-${nr_bts_id}
    ${gNbCuType}    coam_parameter.get_single_value_from_scf_file    parameter=gNbCuType    dist_name=${gNbCuType_dist_name}
    ...                                                               connection=${connection}
    [Return]    ${gNbCuType}

Check GNB Cell status via Webui
    [Documentation]    Author:Zhou xiangyue
    [Arguments]    ${connection}=GNB_OAM   ${timeout}=20    ${gnb_index}=0
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${availabilityStatus}    Set Variable If    ${result}    Online    ${None}
    ${relation_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_idx_list}    Get Dictionary Keys    ${relation_mapping}
    ${subcells_status}   coam.get_subcells_status   timeout=${timeout}    connection=${connection}
    FOR    ${cell_idx}    IN    @{cell_idx_list}
        ${cell_group_idx}    Set Variable    ${relation_mapping[${cell_idx}]["cell_group_id"]}
        Run keyword and continue on failure    Should Be Equal As Strings
        ...  ${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["proceduralStatus"]}    configured
        Run keyword and continue on failure    Should Be Equal As Strings
        ...  ${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["administrativeState"]}    Unlocked
        Run keyword and continue on failure    Should Be Equal As Strings
        ...  ${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["operationalState"]}    ${enabled}
        Run keyword and continue on failure    Should Be Equal As Strings
        ...  ${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["availabilityStatus"]}    ${availabilityStatus}
    END

Check Gnb Type Via Webui
    [Documentation]    Author:Zhou xiangyue
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${gNbCuType}    Get gNbCuType From SCF    connection=${connection}
    Run Keyword If    '${gNbCuType}' == 'both' or '${gNbCuType}' == 'SA+NSA'    Run Keyword    Check GNB Cell status via Webui
    ...    connection=${connection}    gnb_index=${gnb_index}

#### [Start] step level kw ####
##General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
"${Step}" login webui and check RU status
    log to console           \n"${Step}": login webui and check RU status
    WEBUI Login
    check RU STATUS

"${Step}" verify content of TargetBD file
    log to console           \n"${Step}": verify content of TargetBD file
    ${TargetBD_FileName}   ${save_path}    check TargetBD exist and match
    ${regist_info}=          check RU registration info    ${TargetBD_FileName}

"${Step}" verify content of BPF file
    log to console           \n"${Step}": verify content of BPF file
    ${bpf_gzfileName}=         get bpf gz fileName
    ${bpf_content}    ${bpf_file}     get BPF file content    ${bpf_gzfileName}
    verify BPF params        ${bpf_content}

##General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
"${Step}" Login WebEM and check gNB onair
    log to console           \n"${Step}": Login WebEM and check gNB onair
    Wait Until Keyword Succeeds    2min    30s    WEBUI Login
    ${mrbts_id}  ${nrbts_id}    Get BTS ID
    check gNB Staus onAir    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}    search_text=Operational state

"${Step}" Backup SCF with current config
    log to console           \n"${Step}": Backup SCF with current config
    ${scfFile}=    backup commission file via WebUI    ${SAVE LOG DIRECTORY}
    set test variable    ${scfFile}

"${Step}" Modify pMax to tirgger fault
    log to console           \n"${Step}": Modify pMax to tirgger fault
#   get original pMax
    ${pMax_origin_dBm}   selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Maximum output power   timeout=30
    ${pMax_origin_tmp}    string.get substring    ${pMax_origin_dBm}    start=0    end=-3
    set test variable    ${pMax_origin}    ${pMax_origin_tmp}
#   get norminal pMax
    ${bpf_gzfileName}=         get bpf gz fileName
    ${bpf_content}   ${bpf_file}   get BPF file content    ${bpf_gzfileName}
    ${xml handler}=    ParseXML.Parse Xml    ${bpf_content}
    ${MaxPapower_list}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power"]/p
    Collections.Sort List    ${MaxPapower_list}
    set test variable    ${MaxPower}    ${MaxPapower_list}[-1]
    #PowerAllocated <= 10*log10(PowerRated*1000)+DLPowerAccuracy; DLPowerAccuracy is set 0.1dB #PR509046
    ${MaxPower} =    Evaluate    ${MaxPower} + 0.1
    set test variable    ${MinPower}    ${MaxPapower_list}[0]
    ${pMax_modify_f} =    Evaluate    ${MaxPower} + 0.1
    ${pMax_modify}    convert to string    ${pMax_modify_f}
    set test variable    ${pMax_modify}
    wait until keyword succeeds    1min    20s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Maximum output power
    ...    new_value=${pMax_modify}    abbr=pMax
    Validate and activate and check activate plan status

"${step}" Check Fault 1900 via WebEM
    log to console           \n"${Step}": Check Fault 1900 via WebEM
    wait until keyword succeeds    8min    1min    WEBUI Login
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${BTS_Name}    wait until keyword succeeds    2min    30s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name
    set test variable     ${BTS_Name}
    wait until keyword succeeds     15min    1min    Check active fault on WebUI
    ...    alarm_filter=RF Module configuring failed
    ...    Severity_expect=critical
    ...    AlarmID_expect=7116
    ...    AlarmName_expect=BASE STATION SERVICE PROBLEM
    ...    FaultID_expect=1900
    ...    FaultName_expect=RF Module configuring failed
    ...    AlarmOB_expect=[${BTS_Name}] MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1

"${Step}" Modify pMax to Min Power
    log to console           \n"${Step}" Modify pMax to Min Power: ${MinPower} - started
    wait until keyword succeeds    1min    20s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Maximum output power
    ...    new_value=${MinPower}    abbr=pMax
    Validate and activate and check activate plan status
    Wait Until Keyword Succeeds    8min    1min    WEBUI Login
    ${flag}    Run Keyword And Return Status    wait until keyword succeeds    10min    1min
    ...    "StepX" Login WebEM and check gNB onair
    run keyword if     '${flag}'=='False'    reload scf
    #start l3call and check Tput
    log to console           \n"${Step}" Modify pMax to Min Power: ${MinPower} - completed

"${Step}" Modify pMax to Max Power
    log to console           \n"${Step}" Modify pMax to Max Power: ${MaxPower} - started
    wait until keyword succeeds    1min    20s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1    filter_param=Maximum output power
    ...    new_value=${MaxPower}    abbr=pMax
    Validate and activate and check activate plan status
    Wait Until Keyword Succeeds    8min    1min    WEBUI Login
    ${flag}    Run Keyword And Return Status    wait until keyword succeeds    10min    1min
    ...    "StepX" Login WebEM and check gNB onair
    run keyword if     '${flag}'=='False'    reload scf
    #start l3call and check Tput
    log to console           \n"${Step}" Modify pMax to Max Power: ${MaxPower} - completed

##General_SiSo_RF_module_addition_in_BIM_and_WebUI
"${step}" Check HW modules detection
    log to console           \n"${Step}": Check HW modules detection
    Wait Until Keyword Succeeds    10min    1min    WEBUI Login
    wait until keyword succeeds    10min    30s    Check ASIK is UP
    wait until keyword succeeds    10min    30s    Check ABIL is UP
    wait until keyword succeeds    10min    30s    Check Cell is UP
    wait until keyword succeeds    2min     30s     Check RU STATUS

"${step}" Check RF config from webui
    log to console           \n"${Step}": Check RF config from webui
    #get RF SW from TargetBD
    log to console    \nget RF SW from TargetBD
    ${ruSW_expect}=    get RFSW version from TargetBD
    #get RF SW from RF module
    log to console    \nget RF SW from RF module
    ${ruSW_fromModule}=    get RFSW version from radio module
    #get RF configuration from webui
    log to console    \nget RF configuration from webui
    ${output_ru}      selenium_coam.get_ru_info
    ${output_cell}    selenium_coam.get_cell_info
    &{rmodInfo_webui}    selenium_coam.get_hw_parameters     hw_type=RMOD    ###index=1
    ${pCode_webui}     set variable      ${output_ru}[Product code]    # 474877A.X21
    ${pName_webui}     set variable      ${output_ru}[Product name]    # AWHQG
    ${serNum_webui}    set variable      ${output_ru}[Serial number]   # EB193764266
    ${hwVer_webui}     set variable      ${output_ru}[HW version]      # X21
    ${nrBand_webui}    set variable      ${output_cell}[Band]          # n78
    ${runtimeParam_ru}     set variable    ${rmodInfo_webui}[Runtime parameters]
    ${ruSW_webui}          set variable    ${runtimeParam_ru}[RU active SW version]    # MRM69.11.R03
    #get RF configuration from M-Plane (OAM)
    log to console    \nget RF configuration from M-Plane (OAM)
    coam.connect_to    bts_host=${asik_addr}    name=GNB_OAM
    &{hw_info}       coam.get_detected_hw_info    connection=GNB_OAM
    ${pCode_oam}    set variable    ${hw_info.radioModules.rmod[0].productCode}    # 474877A.X21
    ${pName_oam}    set variable    ${hw_info.radioModules.rmod[0].productName}    # AWHQG
    ${serNum_oam}   set variable    ${hw_info.radioModules.rmod[0].serialNumber}   # EB193764266
    @{tmp}          split string    ${pCode_oam}    separator=.
    ${hwVer_oam}    set variable    ${tmp}[-1]       # X21
    coam.teardown    connection=GNB_OAM
    #get RF configuration from spec
    log to console    \nget RF configuration from spec
    define BPF params value from spec
    @{prodCode_tmp}    Get Regexp matches    ${ProductCode_expect}    <p Name="Visible.Product.Code">(.*)</p>   1
    set test variable    ${prodCode_expect}    ${prodCode_tmp}[0]
    @{unitType_tmp}    Get Regexp matches    ${unitType_expect}    <unitType>(.*)</unitType>   1
    set test variable    ${unitType_expect}    ${unitType_tmp}[0]
    @{variant_tmp}    Get Regexp matches    ${variant_expect}    <variant>(.*)</variant>   1
    set test variable    ${variant_expect}    ${variant_tmp}[0]
    ${pName_expect}    Catenate   SEPARATOR=   ${unitType_expect}    ${variant_expect}
    @{NRFreqBand_tmp}    Get Regexp matches    ${NRFreqBand_expect}   <list Name="NR.Frequency.Band"><p>(.*)</p><p>(.*)</p></list>  1
    set test variable    ${NRFreqBand_expect}    ${NRFreqBand_tmp}[0]
    ${NRFreqBand_expect}    Catenate   SEPARATOR=   n   ${NRFreqBand_expect}
    #compare RF configuration
    log to console    \ncompare RF configuration
    should be true    '${ruSW_fromModule}'=='${ruSW_webui}' and '${ruSW_webui}'=='${ruSW_expect}'
    should be true    '${serNum_webui}'=='${serNum_oam}'
    should be true    '${hwVer_webui}'=='${hwVer_oam}'
    should be true    '${pCode_webui}'=='${pCode_oam}' and '${pCode_oam}'=='${prodCode_expect}.${hwVer_webui}'
    should be true    '${pName_webui}'=='${pName_oam}' and '${pName_oam}'=='${pName_expect}'
    should be true    '${nrBand_webui}'=='${NRFreqBand_expect}'

##General_SiSo_CPRI_link_configuration
"${step}" Site reset from webui
    log to console           \n"${Step}": Site reset from webui
    Wait Until Keyword Succeeds    1min    30s   selenium_coam.reset_site
    sleep   2min

"${step}" Verify CPRI link status
    log to console           \n"${Step}": Verify CPRI link status
    Wait Until Keyword Succeeds    6min    30s    check ping is enabled    Unit_ip=${asik_addr}
    Wait Until Keyword Succeeds    5min    30s    WEBUI Login
    Wait Until Keyword Succeeds    15min    30s    Check ASIK is UP
    Wait Until Keyword Succeeds    15min    30s    Check ABIL is UP
    Wait Until Keyword Succeeds    2min    30s    check RU STATUS
    ${output_links}=    Get cpri Link State from BTSOM
    verify cpri link state from BTSOM    output_links=${output_links}

"${Step}" Verify CPRI link status via loner register
    log to console           \n"${Step}": Verify CPRI link status via loner register
    Wait Until Keyword Succeeds    6min    30s    check ping is enabled    Unit_ip=${asik_addr}
    Wait Until Keyword Succeeds    5min    30s    WEBUI Login
    Wait Until Keyword Succeeds    15min    30s    Check ASIK is UP
    Wait Until Keyword Succeeds    15min    30s    Check ABIL is UP
    Wait Until Keyword Succeeds    2min    30s    check RU STATUS
    Verify CPRI link status via loner register    cpri_state_register=0xdf261004 32
    Verify CPRI link status via loner register    cpri_state_register=0xdf271004 32

"${step}" check status after site reset
    log to console           \n"${Step}": check status after site reset
    BuiltIn.Log    Start checking bts reset result.
    Wait Until Keyword Succeeds    6min    30s    check ping is enabled    Unit_ip=${asik_addr}
    Wait Until Keyword Succeeds    5min    30s    WEBUI Login
    Wait Until Keyword Succeeds    15min    30s    Check ASIK is UP
    Wait Until Keyword Succeeds    15min    30s    Check ABIL is UP
    Wait Until Keyword Succeeds    2min    30s    check RU STATUS
    Wait Until Keyword Succeeds    5min    30s    Check Cell is UP
    BuiltIn.Log    BTS reset check finished, reset successfully.

##General_SiSo_RF_module_IP_adress_allocation
"${step}" check ru ip allocation
    log to console           \n"${Step}": check ru ip allocation
    Wait Until Keyword Succeeds    20min    1min    check ru ip allocation
    run keyword and ignore error   should be equal as strings    ${ru_ip}   ${ru_addr}
    ...    msg=Waring: please double check your ru addr in init.py

"${step}" verify RF module accessible
    log to console           \n"${Step}": verify RF module accessible
    #Wait Until Keyword Succeeds    5min    30s    check ru ping is enabled    Unit_ip=${ru_ip}
    Connect to gnb coam via ssl
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}   alias=asik
    Wait Until Keyword Succeeds    5min    30s    Check RU Connection    ru_alias=ru    asik_alias=asik
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    run keyword and ignore error    csn.disconnect    connection=ru
    run keyword and ignore error    csn.disconnect    connection=asik
    Wait Until Keyword Succeeds    5min    30s    WEBUI Login
    Wait Until Keyword Succeeds    15min   1min   check RU STATUS
    ${ruSW_fromModule}    get RFSW version from radio module    ru_ip=${ru_ip}

##General_SiSo_Cell_lock_and_unlock_under_creation
"${step}" Lock Cell
    log to console        \n"${step}": Lock Cell
    Perform Cell Lock      cell_idx=${1}     download_dir=${SAVE LOG DIRECTORY}
    WEBUI Login
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Wait Until Keyword Succeeds    5min    30s    Check Cell Be Locked     cell_idx=${1}
    WEBUI Logout

"${step}" Unlock Cell
    log to console        \n"${step}": Unlock Cell
    #Run Keyword And Ignore Error       selenium_coam.logout
    WEBUI Login
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    WEBUI Logout
    Perform Cell Unlock    cell_idx=${1}     download_dir=${SAVE LOG DIRECTORY}
    WEBUI Login
    Wait Until Keyword Succeeds    15min    1min    Check RU STATUS
    Wait Until Keyword Succeeds    10min    10s     Check Cell is UP

##  General_SiSo_RU_block_unblock_under_creation
"${step}" Lock RU
    log to console        \n"${step}": Lock RU
    Wait Until Keyword Succeeds    5min    10s    lock RU via webui
    run keyword and ignore error   WEBUI Login
    Wait Until Keyword Succeeds    15min    10s    check RU STATUS    expected_status=Locked

    Perform RU Lock    ru_index=${1}   download_dir=${SAVE LOG DIRECTORY}
    WEBUI Login
    Wait Until Keyword Succeeds    5min    10s    Check RU Be Locked
    WEBUI Logout
    sleep    10s

"${step}" Unlock RU
    log to console        \n"${step}": Unlock RU
    Wait Until Keyword Succeeds    5min    10s    unlock RU via webui
    run keyword and ignore error   WEBUI Login
    Wait Until Keyword Succeeds    15min   1min    check RU STATUS    expected_status=Unlocked
    Wait Until Keyword Succeeds    10min    10s    Check Cell is UP

##General_SiSo_BTS_startup_with_RF_delayed_startup
"${step}" Perform RU Power Off
    log to console    \n"${step}": Perform RU Power Off
    Perform RU Power Off    ru_index=${1}    model=${ru_pb_model}
    WEBUI Login
    Check RU Disabled

"${step}" Perform RU Power On
    log to console    \n"${step}": Perform RU Power On
    sleep    10s
    Perform RU Power On    ru_index=${1}    model=${ru_pb_model}
    Wait Until Keyword Succeeds    15min    1min    check RU STATUS
    Wait Until Keyword Succeeds    5min    30s    Check Cell is UP

"${step}" Perform RAC and RAU Power Off
    log to console    \n"${step}": Perform RAC and RAU Power Off
    Perform Site Power Off
    Perform RU Power Off    ru_index=${1}
    sleep    15s

"${step}" Perform RAC and RU Power On
    log to console    \n"${step}": Perform RAC and RU Power On
    Perform Site Power On
    #sleep    2min
    Wait Until Keyword Succeeds    5min     30s     WEBUI Login
    Check RU Disabled
    Wait Until Keyword Succeeds    15min    1min    Check ASIK is UP
    Wait Until Keyword Succeeds    15min    1min    Check ABIL is UP

"${step}" Check RF Delayed Startup
    log to console    \n"${step}": Check RF Delayed Startup
    Perform RU Power On    ru_index=${1}
    Wait Until Keyword Succeeds    15min    1min    check RU STATUS
    Wait Until Keyword Succeeds    5min     30s     Check Cell is UP

##General_SiSo_NR-ARFCN_check
"${step}" get necessary param values and bkp scf
    log to console    \n"${step}" get necessary param values and backup scf

    ${nrarfcn_orig}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number
    set test variable    ${nrarfcn_orig}
    log to console    \nnrarfcn_orig: ${nrarfcn_orig}
    ${gscn_orig}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Global synchronization channel number
    set test variable    ${gscn_orig}
    log to console    \ngscn_orig: ${gscn_orig}
    ${ssbScs_orig}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=SS Block Subcarrier Spacing
    set test variable    ${ssbScs_orig}
    log to console    \nssbScs_orig: ${ssbScs_orig}
    ${scs_orig}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-0
    ...    filter_param=SCS
    set test variable    ${scs_orig}
    log to console    \nscs_orig: ${scs_orig}
    ${opt_cell}    selenium_coam.get_cell_info
    set test variable     ${nrBand_orig}    ${opt_cell}[Band]          # n78
    ${chBw}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Channel bandwidth

    @{chBw}    Get Regexp matches    ${chBw}   (.*)MHz    1
    set test variable    ${chBw}    ${chBw}[0]
    ${chBw}=    convert to integer    ${chBw}
    log to console    \nchBw: ${chBw} MHz

    define nrarfcn range from 3GPP FR1    operateBand=${nrBand_orig}      scs_param=${scs_orig}
    define GSCN range from 3GPP FR1       NRoperateBand=${nrBand_orig}    ssbSCS_param=${ssbScs_orig}

    #In case of 'mod(nrarfcn,2)!=0', e.g. nrarfcn = 6340003,
    #convert to 634004   #suppose current nrarfcn is not nearest to boundary
    ${nrarfcn_orig_tmp}=    Evaluate    ${nrarfcn_orig}/${NrarfcnStep_3gpp}    # 6340003/2= 317001
    ${mod_orig}=    Evaluate        ${nrarfcn_orig}-${nrarfcn_orig_tmp}*${NrarfcnStep_3gpp}  #1
    ${mod_orig_zero}    set variable      ${nrarfcn_orig}
    ${mod_orig_nonzero}=    Evaluate      ${nrarfcn_orig}+(${NrarfcnStep_3gpp}-${mod_orig})  #634004
    run keyword if    '${mod_orig}' == '0'
    ...    set test variable    ${nrarfcn_orig}    ${mod_orig_zero}
    ...    ELSE    set test variable    ${nrarfcn_orig}    ${mod_orig_nonzero}

    #In case of 'original gscn' is not align with 'original nrarfcn'
    ${gscn_calculate}     get gscn align with nrarfcn from 3gpp FR1   ${nrarfcn_orig}
    run keyword if    '${gscn_orig}' != '${gscn_calculate}'    run keywords
    ...     log to console    \nWarning: the gscn: ${gscn_orig} is not align with nrarfcn: ${nrarfcn_orig}   AND
    ...     set test variable     ${gscn_orig}    ${gscn_calculate}

    ${scfFile}=    backup commission file via WebUI    scfSaved_dir=${SAVE LOG DIRECTORY}
    set test variable    ${scfFile}

"${step}" verify nrarfcn out of TX/RX range
    log to console    \n"${step}" verify nrarfcn out of TX/RX range

    ######## out of min NRARFCN #########
    log to console   \n"${step}"-1 out of min NRARFCN: ${minNrarfcn_1807}
    should be true    ${minNrarfcn_3gpp}<=${minNrarfcn_1807}<=${maxNrarfcn_3gpp}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${minNrarfcn_1807}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Global synchronization channel number    new_value=${minNrarfcn_1807_gscn}
    Validate and activate and check activate plan status
    sleep   60s
    #Check fault 1807 on WebUI
    log to console    \nCheck fault 1807 on WebUI
    wait until keyword succeeds    8min    1min    WEBUI Login
    ${BTS_Name}    wait until keyword succeeds    2min    30s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name
    set test variable     ${BTS_Name}
    wait until keyword succeeds     20min    1min    Check active fault on WebUI
    ...    alarm_filter=Invalid frequency channel for the BTS HW
    ...    Severity_expect=critical
    ...    AlarmID_expect=7112
    ...    AlarmName_expect=BASE STATION CONFIGURATION PROBLEM
    ...    FaultID_expect=1807
    ...    FaultName_expect=Invalid frequency channel for the BTS HW
    ...    AlarmOB_expect=[${BTS_Name}] MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    #check cell status - should be faulty
    log to console    \ncheck cell should be faulty
    ${result_cell}    selenium_coam.get_cell_info
    set test variable     ${cellState_list}       ${result_cell}[Status]
    set test variable     ${operational_state}    ${cellState_list}[Operational state]
    set test variable     ${availability_status}    ${cellState_list}[Availability status]
    should be equal as strings     ${operational_state}      Disabled
    should be equal as strings     ${availability_status}    Failed

    #recover with min NRARFCN considering chBw
    log to console    \nrecover with min NRARFCN considering chBw
    get nrarfcn recovery TX/RX frequency range
#    ${minNrarfcn_recover}=    Evaluate     ${minNrarfcn_1807}+${NrarfcnStep_3gpp}
    ${minNrarfcn_recover}=    Evaluate     ${minNrarfcn_pbf_chBw}+${NrarfcnStep_3gpp}
    ${minNrarfcn_recover_gscn}     get gscn align with nrarfcn from 3gpp FR1   ${minNrarfcn_recover}
    set test variable    ${minNrarfcn_recover}
    set test variable    ${minNrarfcn_recover_gscn}
    log to console    \nrecover with min NRARFCN: ${minNrarfcn_recover} and gscn: ${minNrarfcn_recover_gscn}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${minNrarfcn_recover}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Global synchronization channel number    new_value=${minNrarfcn_recover_gscn}
    Validate and activate and check activate plan status
    sleep    60s
    #check fault 1807 on webui - should not visible
    log to console    \ncheck fault 1807 should not visible
    wait until keyword succeeds    8min    1min    WEBUI Login
    @{alarm_info}=    wait until keyword succeeds    30min    1min    selenium_coam.get_active_alarm_info
    ...    alarm_filter=Invalid frequency channel for the BTS HW    timeout=60
    should be empty    ${alarm_info}
    #check cell status - should be onair
    log to console    \ncheck cell should be onair
    wait until keyword succeeds     20min    30s    Check Cell is UP

    ########## out of max NRARFCN ##########
    log to console   \n"${step}"-2 out of max NRARFCN: ${maxNrarfcn_1807}
    #should be true    ${minNrarfcn_3gpp}<=${maxNrarfcn_1807}<=${maxNrarfcn_3gpp}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${maxNrarfcn_1807}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Global synchronization channel number    new_value=${maxNrarfcn_1807_gscn}
    Validate and activate and check activate plan status
    sleep   60s
    #Check fault 1807 on WebUI
    log to console    \nCheck fault 1807 on WebUI
    wait until keyword succeeds    8min    1min    WEBUI Login
    ${BTS_Name}    wait until keyword succeeds    2min    30s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}    filter_param=BTS name
    set test variable     ${BTS_Name}
    wait until keyword succeeds     20min    1min    Check active fault on WebUI
    ...    alarm_filter=Invalid frequency channel for the BTS HW
    ...    Severity_expect=critical
    ...    AlarmID_expect=7112
    ...    AlarmName_expect=BASE STATION CONFIGURATION PROBLEM
    ...    FaultID_expect=1807
    ...    FaultName_expect=Invalid frequency channel for the BTS HW
    ...    AlarmOB_expect=[${BTS_Name}] MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    #check cell status - should be faulty
    log to console    \ncheck cell should be faulty
    ${result_cell}    selenium_coam.get_cell_info
    set test variable     ${cellState_list}       ${result_cell}[Status]
    set test variable     ${operational_state}    ${cellState_list}[Operational state]
    set test variable     ${availability_status}    ${cellState_list}[Availability status]
    should be equal as strings     ${operational_state}      Disabled
    should be equal as strings     ${availability_status}    Failed

    #recover with max NRARFCN considering chBw
    log to console    \nrecover with max NRARFCN considering chBw
#    ${maxNrarfcn_recover}=    Evaluate     ${maxNrarfcn_1807}-${NrarfcnStep_3gpp}
    ${maxNrarfcn_recover}=    Evaluate     ${maxNrarfcn_pbf_chBw}-${NrarfcnStep_3gpp}
    ${maxNrarfcn_recover_gscn}     get gscn align with nrarfcn from 3gpp FR1   ${maxNrarfcn_recover}
    set test variable    ${maxNrarfcn_recover}
    set test variable    ${maxNrarfcn_recover_gscn}
    log to console     \nrecover with max NRARFCN: ${maxNrarfcn_recover} and gscn: ${maxNrarfcn_recover_gscn}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${maxNrarfcn_recover}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=Global synchronization channel number    new_value=${maxNrarfcn_recover_gscn}
    Validate and activate and check activate plan status
    sleep    60s
    #check fault 1807 on webui - should not visible
    log to console    \ncheck fault 1807 should not visible
    wait until keyword succeeds    8min    1min    WEBUI Login
    @{alarm_info_tmp}=    wait until keyword succeeds    30min    1min    selenium_coam.get_active_alarm_info
    ...    alarm_filter=Invalid frequency channel for the BTS HW    timeout=60
    should be empty    ${alarm_info_tmp}
    #check cell status - should be onair
    log to console    \ncheck cell should be onair
    wait until keyword succeeds     15min    30s    Check Cell is UP

"${step}" verify nrarfcn out of band boundary
    log to console    \n"${step}" verify nrarfcn out of band boundary
    # maxNrarfcn_validateErr
    log to console    \n"${step}"-1 maxNrarfcn_validateErr: ${maxNrarfcn_validateErr}
    should be true    ${minNrarfcn_General}<=${maxNrarfcn_validateErr}<=${maxNrarfcn_General}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${maxNrarfcn_validateErr}
    ${status}    ${paramErrInfo}    run keyword and ignore error    selenium_coam.get_error_info_after_set_parameter
    run keyword and ignore error    should be true    '${status}' == 'FAIL'
    run keyword and continue on failure    selenium_coam.validate_plan
    ${relErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${relErrs_str}    convert to string    ${relErrs_dic}
    @{nrarfcnRang_list}    Get Regexp matches    ${relErrs_str}    \\d+
    List Should Contain Value    ${nrarfcnRang_list}    ${maxNrarfcn_3gpp}
    # recover to origial Actual value
    log to console    \nrecover nrarfcn to origial Actual value:${nrarfcn_orig} and gscn: ${gscn_orig}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${nrarfcn_orig}
    ${status}    ${paramErrInfo}    run keyword and ignore error    selenium_coam.get_error_info_after_set_parameter
    run keyword and ignore error    should be true    '${status}' == 'FAIL'
    run keyword and continue on failure    selenium_coam.validate_plan
    ${relErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${relErrs_str}    convert to string    ${relErrs_dic}
    @{nrarfcnRang_list}    Get Regexp matches    ${relErrs_str}    \\d+
    List Should Not Contain Value    ${nrarfcnRang_list}    ${maxNrarfcn_3gpp}

    # minNrarfcn_validateErr
    log to console    \n\n"${step}"-2 minNrarfcn_validateErr: ${minNrarfcn_validateErr}
    should be true    ${minNrarfcn_General}<=${minNrarfcn_validateErr}<=${maxNrarfcn_General}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${minNrarfcn_validateErr}
    ${status}    ${paramErrInfo}    run keyword and ignore error    selenium_coam.get_error_info_after_set_parameter
    run keyword and ignore error    should be true    '${status}' == 'FAIL'
    run keyword and continue on failure    selenium_coam.validate_plan
    ${relErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${relErrs_str}    convert to string    ${relErrs_dic}
    @{nrarfcnRang_list}    Get Regexp matches    ${relErrs_str}    \\d+
    List Should Contain Value    ${nrarfcnRang_list}    ${minNrarfcn_3gpp}
    # recover to origial Actual value
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    filter_param=NR Absolute radio frequency channel number    new_value=${nrarfcn_orig}
    ${status}    ${paramErrInfo}    run keyword and ignore error    selenium_coam.get_error_info_after_set_parameter
    run keyword and ignore error    should be true    '${status}' == 'FAIL'
    run keyword and continue on failure    selenium_coam.validate_plan
    ${relErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${relErrs_str}    convert to string    ${relErrs_dic}
    @{nrarfcnRang_list}    Get Regexp matches    ${relErrs_str}    \\d+
    List Should Not Contain Value    ${nrarfcnRang_list}    ${minNrarfcn_3gpp}

"${step}" get nrarfcn boudary values and GSCN
    log to console    \n"${step}" get nrarfcn boudary values and GSCN
    get nrarfcn general range from OAM webui
    get nrarfcn range from TX/RX frequency
    get nrarfcn out of band boundary from 3gpp
    get nrarfcn out of TX/RX frequency range
    ${maxNrarfcn_pbf_gscn}     get gscn align with nrarfcn from 3gpp FR1   ${maxNrarfcn_pbf}
    ${minNrarfcn_pbf_gscn}     get gscn align with nrarfcn from 3gpp FR1   ${minNrarfcn_pbf}
    ${maxNrarfcn_1807_gscn}    get gscn align with nrarfcn from 3gpp FR1   ${maxNrarfcn_1807}
    ${minNrarfcn_1807_gscn}    get gscn align with nrarfcn from 3gpp FR1   ${minNrarfcn_1807}
    set test variable    ${maxNrarfcn_pbf_gscn}
    set test variable    ${minNrarfcn_pbf_gscn}
    set test variable    ${maxNrarfcn_1807_gscn}
    set test variable    ${minNrarfcn_1807_gscn}

#### [End] step level kw ####
