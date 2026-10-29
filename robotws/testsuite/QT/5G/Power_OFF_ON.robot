*** Settings ***
Force Tags    PY39    RF50

Documentation
...          author: Yang Le
...          contact: le.yang@nokia-sbell.com
...          description:  This test case allows below power action options for 5G SA/NSA site:
...                         power on/off only SMOD for GNB
...	                        power reset only SMOD for GNB
...	                        power on/off only RF(s) for GNB
...	                        power reset only RF(s) for GNB
...	                        power on/off both RF(s) and SMOD for GNB
...	                        power reset both RF(s) and SMOD for GNB
...	                        power on/off both RF(s) and SMOD for GNB and ENB(if dedicated ENB for NSA site)
...          :param POWER_ACTION: On, OFF, RESET
...          :param HW: SMOD, RF, ALL
...          :param GNBorENB: GNB, ALL

Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      ${CURDIR}/../SRAN/resources/python/QTListener.py
Library      ${CURDIR}/../SRAN/resources/python/TestCaseRequirement.py
Resource    ${CURDIR}/../SRAN/resources/robot/common.robot
Resource    ${CURDIR}/../SRAN/resources/robot/classical_keywords.robot
Resource    ${CURDIR}/../SRAN/resources/robot/states.robot
Resource    ${CURDIR}/../SRAN/resources/robot/AIC_common_keywords.robot
Resource    ${CURDIR}/../SRAN/resources/robot/common_variables.robot

Suite Setup    Custom Suite Setup

*** Variables ***
${POWER_ACTION}
${HW}
${GNBorENB}
${vran_version}    vran2
${force_shared_ENB}    False

*** Test Cases ***

Perform Power Action for HW(s)
    [Tags]    POWER_ACTION
    [Timeout]    10min
    Run Keyword If    '${HW}'=='SMOD'    POWER ACTION SMOD
    ...    ELSE IF    '${HW}'=='RF' and '${POWER_ACTION}'=='RESET'    POWER RESET RF for ${GNBorENB}
    ...    ELSE IF    '${HW}'=='RF' and '${POWER_ACTION}'!='RESET'    POWER OnOff RF for ${GNBorENB}
    ...    ELSE IF    '${HW}'=='ALL'    Perform Power Action for All HW Units

Check Cells OnAir
    [Tags]    ONAIR
    [Setup]    Requires TC    Perform Power Action for HW(s)
    Check Cells OnAir

*** Keywords ***

Perform Power Action for All HW Units
    run keyword if    '${POWER_ACTION}'=='RESET'  POWER RESET ${GNBorENB}
    run keyword if    '${POWER_ACTION}'!='RESET'  POWER OnOff RF and SMOD  GNBorENB=${GNBorENB}

POWER RESET RF for GNB
    FOR  ${i}  IN RANGE  ${gnb_rf_pdu_num}
        ${PDU_IP}=  Set Variable If  ${is_not_vdu}  ${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
        ...  ${${vdu}.rus[${i}].pdu_port.pdu.addr}
        ${PDU_PORT}=  Set Variable If  ${is_not_vdu}  ${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
        ...  ${${vdu}.rus[${i}].pdu_port.port_no}
        ${version}=  Set Variable If  ${is_not_vdu}  ${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.version}
        ...  ${${vdu}.rus[${i}].pdu_port.pdu.version}
        ${pdu_model}    Set Variable If  ${is_not_vdu}   ${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}
        ...  ${${vdu}.rus[${i}].pdu_port.pdu.vendor}
        run keyword if  '${pdu_model}'=='Gude'    Reset port on Gude PDU
        ...    PDU_IP=${PDU_IP}
        ...    PDU_PORT=${PDU_PORT}
        ...    version=${version}
        ...    alias=rfpdu
        ...    model=${pdu_model}
        ...    ELSE    Reset port on PDU
        ...    PDU_IP=${PDU_IP}
        ...    PDU_PORT=${PDU_PORT}
        ...    alias=rfpdu
        ...    model=${pdu_model}
    END
    [Teardown]    Run Keyword And Ignore Error    pdu.teardown_pdu    pdu_device=rfpdu

POWER RESET RF for ENB
    POWER OnOff RF for ENB    action=OFF
    POWER OnOff RF for ENB    action=ON

POWER RESET RF for ALL
    POWER RESET RF for GNB
    Run Keyword If   ${has_enb}    POWER RESET RF for ENB

POWER OnOff RF for GNB
    [Arguments]    ${action}=${POWER_ACTION}
    FOR    ${i}    IN RANGE    ${gnb_rf_pdu_num}
        ${PDU_IP}=  Set Variable If  ${is_not_vdu}  ${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
        ...  ${${vdu}.rus[${i}].pdu_port.pdu.addr}
        ${PDU_PORT}=  Set Variable If  ${is_not_vdu}  ${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
        ...  ${${vdu}.rus[${i}].pdu_port.port_no}
        ${version}=  Set Variable If  ${is_not_vdu}  ${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.version}
        ...  ${${vdu}.rus[${i}].pdu_port.pdu.version}
        ${pdu_model}    Set Variable If  ${is_not_vdu}   ${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}
        ...  ${${vdu}.rus[${i}].pdu_port.pdu.vendor}
        run keyword if  '${pdu_model}'=='Gude'    pdu.Setup Pdu
        ...    host=${PDU_IP}
        ...    model=${pdu_model}
        ...    version=${version}
        ...    alias=gnbrfpdu
        ...    ELSE    pdu.Setup Pdu
        ...    host=${PDU_IP}
        ...    model=${pdu_model}
        ...    alias=gnbrfpdu
        run keyword if  '${action}'=='OFF'
        ...    pdu.power_off  port=${PDU_PORT}  pdu_device=gnbrfpdu
        ...    ELSE
        ...    pdu.power_on  port=${PDU_PORT}  pdu_device=gnbrfpdu
        BuiltIn.Sleep    10s
        ${pdu_status}=  pdu.get_port_status    port=${PDU_PORT}    pdu_device=gnbrfpdu
        ${expected_status}=    Convert to lowercase    ${action}
        Should contain    ${pdu_status}    ${expected_status}
    END
    [Teardown]  Run Keyword And Ignore Error    pdu.teardown_pdu    pdu_device=gnbrfpdu

POWER OnOff RF for ENB
    [Arguments]    ${action}=${POWER_ACTION}
    IF    ${enb_rf_num}==0
        Fail    ${\n}${red}POWER OnOff RF action for ENB will not be executed due to RF was not configed, manually check needed!${rm_color}
    END
    FOR  ${i}  IN RANGE  ${enb_rf_num}
        ${pdu_model}=    Get variable Value    ${tl.enbs[0].rms[${i}].pdu_port.pdu.vendor}   ${tl.enbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}
        ${pdu_ip}=    Get variable Value    ${tl.enbs[0].rms[${i}].pdu_port.pdu.addr}    ${tl.enbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
        ${pdu_version}=     Run Keyword If    '${pdu_model}'=='Gude'    Get variable Value    ${tl.enbs[0].rms[${i}].pdu_port.pdu.version}
        ...    ${tl.enbs[0].dus[0].rus[${i}].pdu_port.pdu.version}
        ${pdu_port}    Get variable Value    ${tl.enbs[0].rms[${i}].pdu_port.port_no}    ${tl.enbs[0].dus[0].rus[${i}].pdu_port.port_no}
        run keyword if    '${pdu_model}'=='Gude'    pdu.Setup Pdu
        ...    host=${pdu_ip}
        ...    model=${pdu_model}
        ...    version=${pdu_version}
        ...    alias=enbrfpdu
        ...    ELSE    pdu.Setup Pdu
        ...    host=${pdu_ip}
        ...    model=${pdu_model}
        ...    alias=enbrfpdu
        Run Keyword If  '${action}'=='OFF'  pdu.power_off  port=${pdu_port}  pdu_device=enbrfpdu
        ...  ELSE  pdu.power_on  port=${pdu_port}  pdu_device=enbrfpdu
        BuiltIn.Sleep  10s
        ${pdu_status}=    pdu.get_port_status    port=${pdu_port}  pdu_device=enbrfpdu
        ${expected_status}=    Convert to lowercase    ${action}
        Should contain    ${pdu_status}    ${expected_status}
    END
    [Teardown]  Run Keyword And Ignore Error    pdu.teardown_pdu    pdu_device=enbrfpdu

POWER OnOff RF for ALL
    POWER OnOff RF for GNB
    Run Keyword If   ${has_enb}    POWER OnOff RF for ENB

POWER ACTION SMOD
    [Arguments]    ${GNBorENB}=${GNBorENB}
    ${bts_list}    Create List
    IF    '${GNBorENB}'=='ALL'
        IF    not ${has_enb}
            Append To List    ${bts_list}    GNB
        ELSE IF  not ${has_gnb_pdu}
            Append To List    ${bts_list}    ENB
        ELSE
            Append To List    ${bts_list}    GNB    ENB
        END
    ELSE
        Append To List    ${bts_list}    ${GNBorENB}
    END
    FOR    ${bts}    IN      @{bts_list}
        IF    ${${bts}_bbu_num}==0
            Fail   ${\n}${red}Power action will not be executed due to ${bts} BBU was not configed, manually check needed!${rm_color}
        END
        FOR  ${num}  IN RANGE  ${${bts}_bbu_num}
            Run Keyword If  '${bts}' == 'GNB'  Get GNB SMOD Configuration  num=${num}
            ...  ELSE IF  '${bts}' == 'ENB'  Get ENB SMOD Configuration  num=${num}
            ${pdu_model}    Set variable    ${${bts}_SMOD${num}_PDU_VENDOR}
                run keyword if  '${pdu_model}'=='Gude'    pdu.Setup Pdu
                ...    host=${${bts}_SMOD${num}_PDU_IP}
                ...    model=${pdu_model}
                ...    version=${${bts}_SMOD${num}_PDU_VERSION}
                ...    alias=${bts}smodpdu
                ...    ELSE    pdu.Setup Pdu
                ...    host=${${bts}_SMOD${num}_PDU_IP}
                ...    model=${pdu_model}
                ...    alias=${bts}smodpdu
            run keyword if    '${POWER_ACTION}'=='OFF'    pdu.power_off    port=${${bts}_SMOD${num}_PDU_PORT}    pdu_device=${bts}smodpdu
            ...    ELSE IF    '${POWER_ACTION}'=='ON'     pdu.power_on    port=${${bts}_SMOD${num}_PDU_PORT}    pdu_device=${bts}smodpdu
            ...    ELSE IF    '${POWER_ACTION}'=='RESET'  Run Keywords
            ...    pdu.power_off    port=${${bts}_SMOD${num}_PDU_PORT}    pdu_device=${bts}smodpdu
            ...    AND    BuiltIn.Sleep   10
            ...    AND    pdu.power_on    port=${${bts}_SMOD${num}_PDU_PORT}    pdu_device=${bts}smodpdu
            BuiltIn.Sleep  10
            ${pdu_status}=  pdu.get_port_status    port=${${bts}_SMOD${num}_PDU_PORT}  pdu_device=${bts}smodpdu
            run keyword if  '${POWER_ACTION}'=='OFF'  Should contain  ${pdu_status}  off
            ...  ELSE  Should contain  ${pdu_status}  on
        END
        Run Keyword And Ignore Error    pdu.teardown_pdu    pdu_device=${bts}smodpdu
    END

POWER OnOff RF and SMOD
    [Arguments]  ${GNBorENB}=${GNBorENB}
    run keyword if  ('${GNBorENB}'=='GNB' or '${GNBorENB}'=='ALL') and ${has_gnb_rf_pdu}    POWER OnOff RF for GNB
    run keyword if  ('${GNBorENB}'=='ENB' or '${GNBorENB}'=='ALL') and ${has_enb_rf_pdu} and ${has_enb}
    ...   POWER OnOff RF for ENB

    run keyword if  ('${GNBorENB}'=='GNB' or '${GNBorENB}'=='ALL') and ${has_gnb_pdu}    POWER ACTION SMOD  GNBorENB=GNB
    run keyword if  ('${GNBorENB}'=='ENB' or '${GNBorENB}'=='ALL') and ${has_enb_rf_pdu} and ${has_enb}
    ...   POWER ACTION SMOD  GNBorENB=ENB

POWER RESET ${GNBorENB}
    [Arguments]
    run keyword if  ('${GNBorENB}'=='GNB' or '${GNBorENB}'=='ALL') and ${has_gnb_rf_pdu}  POWER RESET RF for GNB
    run keyword if  ('${GNBorENB}'=='GNB' or '${GNBorENB}'=='ALL') and ${has_gnb_pdu}  POWER ACTION SMOD  GNBorENB=GNB
    run keyword if  ('${GNBorENB}'=='ENB' or '${GNBorENB}'=='ALL') and ${has_enb} and ${has_enb_rf_pdu}  POWER RESET RF for ENB
    run keyword if  ('${GNBorENB}'=='ENB' or '${GNBorENB}'=='ALL') and ${has_enb} and ${has_enb_pdu}  POWER ACTION SMOD  GNBorENB=ENB

Get HW Configuration
    Get GNB HW Configuration
    Get ENB HW Configuration
    run keyword if    '${vran_version}'!='vran2'    Get OAM Configuration

Get GNB HW Configuration
    ${is_not_vdu}    Evaluate    '${vran_version}'!='vran2'
    IF    ${is_not_vdu} and $tl.gnbs is not None
        ${has_gnb_pdu}    Set Variable    ${True}
    ELSE
        ${has_gnb_pdu}    Set Variable    ${False}
    END
    IF    ${has_gnb_pdu}
        ${gnb_bbu_num}    Evaluate    len($tl.gnbs[0].dus[0].airscale.common_units)
    ELSE
        ${gnb_bbu_num}    Set Variable    0
    END
    IF    not ${has_gnb_pdu}
        Log To Console  ${byellow}Power action to GNB SMOD will not be executed as corresponding PDU is not configured or GNB has VDU.${rm_color}
        IF    not ${is_not_vdu}
            ${vdu_rf_pdu}    Set Variable If    "${${vdu}.rus[0].pdu_port}"!="None"    ${True}    ${False}
        END
    ELSE
        IF    ${is_not_vdu}
            ${gnb_rf_pdu}    Set Variable If    "${tl.gnbs[0].dus[0].rus[0].pdu_port}"!="None"    ${True}    ${False}
        END
        Get GNB SMOD Configuration
    END
    ${gnb_rf_pdu}    Get Variable Value    ${gnb_rf_pdu}    ${False}
    ${vdu_rf_pdu}    Get Variable Value    ${vdu_rf_pdu}    ${False}
    ${has_gnb_rf_pdu}    Evaluate    ${gnb_rf_pdu} or ${vdu_rf_pdu}
    Set Suite Variable  ${has_gnb_rf_pdu}
    IF    not ${has_gnb_rf_pdu}
        Log To Console  ${byellow}Power action to GNB RF(s) will not be executed as corresponding PDU is not configured.${rm_color}
        ${gnb_rf_pdu_num}    Set Variable    0
    ELSE
        IF    ${is_not_vdu}
            ${gnb_rf_pdu_num}    Evaluate    len($tl.gnbs[0].dus[0].rus)
        ELSE
            ${gnb_rf_pdu_num}    Evaluate    len($${vdu}.rus)
        END
    END

    Set Suite Variable  ${gnb_bbu_num}
    Set Suite Variable  ${gnb_rf_pdu_num}
    Set Suite Variable  ${has_gnb_pdu}
    Set Suite Variable  ${is_not_vdu}

Get GNB SMOD Configuration
    [Arguments]  ${num}=0
    Set Suite Variable    ${GNB_SMOD${num}_PDU_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[${num}].pdu_port.pdu.addr}
    Set Suite Variable    ${GNB_SMOD${num}_PDU_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[${num}].pdu_port.port_no}
    Set Suite Variable    ${GNB_SMOD${num}_PDU_VENDOR}    ${tl.gnbs[0].dus[0].airscale.common_units[${num}].pdu_port.pdu.vendor}
    Run Keyword if    '${GNB_SMOD${num}_PDU_VENDOR}'=='Gude'
    ...    Set Suite Variable    ${GNB_SMOD${num}_PDU_VERSION}    ${tl.gnbs[0].dus[0].airscale.common_units[${num}].pdu_port.pdu.version}

Get ENB SMOD Configuration
    [Arguments]  ${num}=0
    ${pdu_ip}    Get Variable Value    ${tl.enbs[0].system_module.common_units[${num}].pdu_port.pdu.addr}
    ...    ${tl.enbs[0].dus[0].airscale.common_units[${num}].pdu_port.pdu.addr}
    Set Suite Variable    ${ENB_SMOD${num}_PDU_IP}    ${pdu_ip}
    ${pdu_port}    Get Variable Value    ${tl.enbs[0].system_module.common_units[${num}].pdu_port.port_no}
    ...     ${tl.enbs[0].dus[0].airscale.common_units[${num}].pdu_port.port_no}
    Set Suite Variable    ${ENB_SMOD${num}_PDU_PORT}   ${pdu_port}
    ${pdu_vendor}    Get Variable Value     ${tl.enbs[0].system_module.common_units[${num}].pdu_port.pdu.vendor}
    ...    ${tl.enbs[0].dus[0].airscale.common_units[${num}].pdu_port.pdu.vendor}
    Set Suite Variable    ${ENB_SMOD${num}_PDU_VENDOR}    ${pdu_vendor}
    ${pdu_version}=    Run Keyword if    '${ENB_SMOD${num}_PDU_VENDOR}'=='Gude'    Get Variable Value
    ...    ${tl.enbs[0].system_module.common_units[${num}].pdu_port.pdu.version}
    ...    ${tl.enbs[0].dus[0].airscale.common_units[${num}].pdu_port.pdu.version}
    Run Keyword if    '${ENB_SMOD${num}_PDU_VENDOR}'=='Gude'
    ...    Set Suite Variable    ${ENB_SMOD${num}_PDU_VERSION}    ${pdu_version}

Get ENB HW Configuration
    ${has_enb}    Evaluate    "${tl.enbs}"!="None"
    IF    ${has_enb}
        ${enb_rf}     Get Variable Value   ${tl.enbs[0].rms}    ${tl.enbs[0].dus[0].rus}
        ${enb_rf_num}    Evaluate    len($enb_rf)
        ${enb_bbu}=    Get Variable Value    ${tl.enbs[0].system_module.common_units}
        ...    ${tl.enbs[0].dus[0].airscale.common_units}
        ${enb_pdu}     Get Variable Value    ${tl.enbs[0].dus[0].airscale.common_units[0].pdu_port}
        ...    ${tl.enbs[0].system_module.common_units[0].pdu_port}
        ${has_enb_pdu}    Set Variable If    "${enb_pdu}"!='None'    ${True}    ${False}
        Set Suite Variable  ${has_enb_pdu}
        ${has_enb_rf_pdu}     Set Variable If    "${enb_rf[0].pdu_port}"!="None"    ${True}    ${False}
        ${enb_bbu_num}    Evaluate    len($enb_bbu)
        IF    not ${has_enb_pdu}
            Log To Console    ${byellow}Power action to ENB SMOD will not be executed as corresponding PDU is not configured.${rm_color}
        ELSE IF    not ${has_enb_rf_pdu}
            Log To Console    ${byellow}Power action to ENB RF will not be executed as corresponding PDU is not configured.${rm_color}
        ELSE IF    ${is_shared_enb} and not ${force_shared_ENB}
            Log To Console  ${byellow}Power action to ENB HW units will not be executed as ENB is shared.${rm_color}
        ELSE
            Get ENB SMOD Configuration
        END
    ELSE
        Log To Console  ${byellow}Power action to ENB HW units will not be executed as ENB is not configured.${rm_color}
        ${enb_rf_num}    Set Variable    0
        ${enb_bbu_num}    Set Variable    0
    END
    ${has_enb_rf_pdu}    Get Variable Value    ${has_enb_rf_pdu}     ${False}
    ${has_enb_pdu}    Get Variable Value    ${has_enb_pdu}    ${False}
    Set Suite Variable  ${has_enb}
    Set Suite Variable  ${enb_rf_num}
    Set Suite Variable  ${enb_bbu_num}
    Set Suite Variable  ${has_enb_pdu}
    Set Suite Variable  ${has_enb_rf_pdu}

Reset port on Gude PDU
    [Arguments]        ${PDU_IP}    ${PDU_PORT}    ${version}    ${alias}=atenpdu   ${model}=Gude
    Log To Console     \n Reset ongoing for PDU ${PDU_IP}, port ${PDU_PORT}
    pdu.setup_pdu      host=${PDU_IP}
    ...                model=${model}
    ...                version=${version}
    ...                alias=${alias}
    pdu.power_off      port=${PDU_PORT}
    ...                pdu_device=${alias}
    BuiltIn.Sleep              10s
    pdu.power_on       port=${PDU_PORT}
    ...                pdu_device=${alias}
    BuiltIn.Sleep              10s
    ${port_status}     pdu.get_port_status    port=${PDU_PORT}
    ...                                       pdu_device=${alias}
    Should Contain     ${port_status}    on
    [Teardown]    Run Keyword And Ignore Error    pdu.teardown_pdu    pdu_device=${alias}

Get OAM Configuration
    ${OAM_host}    Set variable if    '${vran_version}' == 'classic'    192.168.255.129
    ...    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    Set Suite Variable    ${OAM_host}

Check Cells OnAir
    run keyword if    '${vran_version}'=='vran2'    Run Keywords
    ...    Common variables setup
    ...    AND    Check Cell setup for vDU    loop_check=20
    ...    ELSE IF    '${vran_version}' == 'classic'    Check Cell setup for Classic

Check Cell setup for Classic
    Wait Until Keyword Succeeds    5min  15s    coam.connect to    bts_host=${OAM_host}   update_interval=1000   name=coam_admin   release=SBTS00
    Run Keyword If  '${tl.ues[0].ue_type}'=='cus'
    ...   Wait Until Keyword Succeeds  15min  30s  Check RF Status
    ...   ELSE  Wait Until Keyword Succeeds    10min  30s    Verify Cells Setup
    coam.teardown    connection=coam_admin

Check FHGW Exist
    [Documentation]    Author: weichao tong
    ...                Description: check if FHGW exist
    ${FHGW_Exist}    Run Keyword And Return Status    Variable Should Exist    ${tl.gnbs[0].dus[0].fhgws[0]}
    ${RANNIC_Exist}    Run Keyword And Return Status    Variable Should Exist    ${tl.gnbs[0].dus[0].rannics[0]}
    IF    ${FHGW_Exist}
        Set Suite Variable    ${vdu}    tl.gnbs[0].dus[0].fhgws[0]
    ELSE IF    ${RANNIC_Exist}
        Set Suite Variable    ${vdu}    tl.gnbs[0].dus[0].rannics[0]
    ELSE
        Set Suite Variable    ${vdu}    tl.gnbs[0].dus[0]
    END

Custom Suite Setup
    Set Color For Logs
    Check FHGW Exist
    Get HW Configuration
