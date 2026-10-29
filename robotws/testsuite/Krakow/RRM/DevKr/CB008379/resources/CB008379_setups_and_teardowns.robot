*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Cezary Dudek <cezary.dudek@nokia.com>
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Tomasz Pyrek <michal.szymakowski@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB008379-common_keywords.robot

Library     custom_ta_messaging.py

*** Variables ***

*** Keywords ***
Prepare test environment A_b-1
    Configure       {'MOC': 'NRCELL', 'ID': '1', 'maxNumOfGBRBearersSA': '1'}
    Wait for object attribute value    NRCELL-1    maxNumOfGBRBearersSA   value=1    timeout=60

Prepare test environment DC1
    Configure       ${yaml_enable_interho}
    Set GBR data forwarding for XN Handover to on for simulated gNB3
    Set actNonVoNRGBRService flag to True

Prepare test environment DC2
    Configure       ${yaml_enable_interho}
    Configure       ${yaml_enable_ngho}
    Set NG based handover for simulated gNB3
    Set indirect data forwarding for AMF1 to off
    Set GBR data forwarding for XN Handover to on for simulated gNB3

Prepare test environment DC3
    Configure       ${yaml_enable_ngho}
    Set NG based handover for simulated gNB3
    Set indirect data forwarding for AMF1 to off

Prepare test environment D-d
    Configure       ${CURDIR}/../../resources/yaml_config/inter_rat_ho.yaml

Prepare test environment D-e
    Configure       ${CURDIR}/../../resources/yaml_config/inter_rat_ho.yaml
    Execute egate command   cmd=amf_param id=1 intra5gs_data_forwarding=off

Prepare test environment E_a-12
    Set GBR admission control parameters for E_a-12
    Execute egate command   cmd=amf_param id=1 intra5gs_data_forwarding=off

Cleanup after test E_a-12
    restore_default_iphy_interfaces
    Execute egate command   cmd=amf_param id=1 intra5gs_data_forwarding=on
    Detach and kill UEs from 1 to 27
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'addGbrTrafficHo': '0'}

Cleanup after test A_b-1
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE4
    Detach and kill UE5
    Detach and kill UE6
    Detach and kill UE7
    Detach and kill UE8
    Detach and kill UE9

    Edit object attributes
    ...     object_name=NRCELL-1
    ...     maxNumOfGBRBearersSA=10
    ...     bts_id=1
    Wait for object attribute value    NRCELL-1    maxNumOfGBRBearersSA   value=10    timeout=60

Cleanup after test A_b-2
    Detach and kill UE10
    Detach and kill UE11
    Detach and kill UE12

Prepare test environment A_b-3
    Set UE IDLE timers on gNB: drbInactivityTimerSA=10 srbInactivityTimerSA=10

Cleanup after test A_b-3
    Detach and kill UE13
    Detach and kill UE14
    Detach and kill UE15
    Execute egate command   cmd=amf_ue_ics_param id=1 reset
    Set UE IDLE timers on gNB: drbInactivityTimerSA=600 srbInactivityTimerSA=600

Cleanup after test A_b-4
    Detach and kill UE16
    Detach and kill UE17
    Detach and kill UE18

Cleanup after test A_g-1
    Detach and kill UEs from 1 to 9
    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  True  bts_id=1

Cleanup after test A_g-2
    Detach and kill UEs from 11 to 19
    Change eNB parameter value  NRCELL-1.actNonVoNRGbrService  True  bts_id=1

Cleanup after test A_f-1
    [Documentation]  Make sure GFBR has the same value as in /CB008379/config/SA_FDD_2c_1eNBsim_1gNBsim.lua
    ${default_gfbr_kbitrate}=     Set variable    6000
    FOR  ${5qi}  IN    2  3  4  71  72  76  128  212  254
        ${QoS_FLOW_ID}    Get From Dictionary    ${5QI_TO_EGATE_QOS_FLOW_ID}   ${5qi}
        Execute egate command   cmd=qosflow_modify qos_flow=${QoS_FLOW_ID} gfbr_dl=${default_gfbr_kbitrate} gfbr_ul=${default_gfbr_kbitrate}
        Sleep  1
    END
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3

Restore maxGbrTrafficLimit=${maxGbrTrafficLimit}%, maxNumOfGBRBearersSA=${maxNumOfGBRBearersSA}, GFBR=${gfbr}Mbps and MFBR=${mfbr}Mbps for all 5QIs
    Set for all 5QIs GFBR to ${gfbr}Mbps and MFBR to ${mfbr}Mbps
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'maxGbrTrafficLimit': '${maxGbrTrafficLimit}', 'maxNumOfGBRBearersSA': '${maxNumOfGBRBearersSA}'}

Set GBR admission control parameters for ${test_id}
    ${maxGBRTrafficLimit}   Get From Dictionary  ${maxGBRTrafficLimit_per_test}  ${test_id}
    Set Test Variable  ${maxGBRTrafficLimit}
    ${gfbr}                 Get From Dictionary  ${gfbr_per_test}                ${test_id}
    Set Test Variable  ${gfbr}
    ${traffic_rate}         Get From Dictionary  ${traffic_per_test}             ${test_id}
    Set Test Variable  ${traffic_rate}

    Configure  {'MOC': 'NRCELL', 'ID': '1', 'actGBRAdmissionControl': 'GBRService', 'maxGbrTrafficLimit': '${maxGBRTrafficLimit}'}
    Set for all 5QIs GFBR to ${gfbr}Mbps and MFBR to ${gfbr}Mbps


Set high parameters for ${direction:(DL|UL)} for background UEs
    ${gfbr}                 Get From Dictionary  ${gfbr_direction}                ${direction}
    Set Test Variable  ${gfbr}
    ${bg_gfbr}                 Get From Dictionary  ${bg_gfbr_direction}                ${direction}
    Set Test Variable  ${bg_gfbr}
    ${traffic_rate}         Get From Dictionary  ${traffic_direction}             ${direction}
    Set Test Variable  ${traffic_rate}
    ${bg_traffic_rate}         Get From Dictionary  ${bg_traffic_direction}             ${direction}
    Set Test Variable  ${bg_traffic_rate}
    Set for all 5QIs ${direction} GFBR to ${bg_gfbr}Mbps and MFBR to ${bg_gfbr}Mbps

Set low parameters for ${direction:(DL|UL)}
    ${low_gfbr}                 Get From Dictionary  ${low_gfbr_direction}                ${direction}
    Set Test Variable  ${low_gfbr}
    Set for all 5QIs ${direction} GFBR to ${low_gfbr}Mbps and MFBR to ${low_gfbr}Mbps

Prepare test environment E_a-5
    Configure  [{'MOC':'NRCELL', 'ID':'1', 'maxGBRTrafficLimit':'75'}, {'MOC':'NRBTS', 'drbInactivityTimerSA':'300', 'srbInactivityTimerSA':'300'}]
    Discover bts    bts_id=1
    Set suite variable    ${background_ues}     11,12,13,14,15

Cleanup after test E_a-5
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Execute egate command  cmd=smf_param id=1 reset
    Stop 20Mbps UL and DL traffic and kill background UEs[${background_ues}]

Prepare test environment E_a-6
    Configure  [{'MOC':'NRCELL', 'ID':'1', 'maxGBRTrafficLimit':'26'}, {'MOC':'NRBTS', 'drbInactivityTimerSA':'300', 'srbInactivityTimerSA':'300'}]
    Set actNonVoNRGBRService parameter for both cells
    Discover bts   bts_id=1
    Set suite variable    ${background_ues}    11,12,13,14,15

Cleanup after test E_a-6
    Deconfigure AMFs[1] from including HO capabilities when UE attaches
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Stop 20Mbps UL and DL traffic and kill background UEs[${background_ues}]

Prepare test environment E_a-15
    Set actNonVoNRGBRService parameter for both cells

Cleanup after test E_a-15
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Detach and kill UE4
    Detach and kill UE5
    Detach and kill UE6

    Edit object attributes if other than    NRCELL-2    maxNumOfGBRBearersSA=10
    Discover bts   bts_id=1

Prepare test environment E_a-9
    Configure  [{'MOC':'NRCELL', 'maxGBRTrafficLimit':'26'}, {'MOC':'NRBTS', 'drbInactivityTimerSA':'300', 'srbInactivityTimerSA':'300'}]
    Set actNonVoNRGBRService parameter for both cells
    Discover bts    bts_id=1
    Set test variable    ${background_ues}     11,12,13,14

Cleanup after test E_a-9
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Execute egate command  cmd=smf_param id=1 reset
    Stop 20Mbps UL traffic and kill background UEs[${background_ues}]

Prepare test environment E_a-16
    Set GBR admission control parameters for E_a-16
    Set UE IDLE timers on gNB: drbInactivityTimerSA=600 srbInactivityTimerSA=600

Prepare test environment E_a-11
    Configure  [{'MOC':'NRCELL', 'maxGBRTrafficLimit':'12'}, {'MOC':'NRBTS', 'drbInactivityTimerSA':'300', 'srbInactivityTimerSA':'300'}]
    Set actNonVoNRGBRService parameter for both cells
    Discover bts    bts_id=1
    Set test variable    ${background_ues}     11,12,13

Cleanup after test E_a-11
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3
    Execute egate command  cmd=smf_param id=1 reset
    Stop 20Mbps UL traffic and kill background UEs[${background_ues}]

Prepare test environment E_b-3
    Set GBR admission control parameters for E_b-3
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'addNumOfGBRBearers': '${E_b_3_addNumOfGBRBearers_low}', 'addGbrTrafficHo': '${E_b_3_addGbrTrafficHo}'}

Cleanup after test E_b-3
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'addNumOfGBRBearers': '0', 'addGbrTrafficHo': '0'}
    Detach and kill UEs from 1 to 18

Prepare test environment E_d-2
    # target FDD value for maxGBRTrafficLimit: 20
    Configure  [{'MOC':'NRCELL', 'maxGBRTrafficLimit':'20'}, {'MOC':'NRBTS', 'drbInactivityTimerSA':'300', 'srbInactivityTimerSA':'300'}]
    Discover bts    bts_id=1
    Set test variable    ${background_ues}      11,12,13
    Set test variable    ${bkg_ue_1}            11
    Set test variable    ${bkg_ue_2}            12

Cleanup after test E_d-2
    Sleep  20
    Detach and kill UE1
    Detach and kill UE2
    Detach and kill UE3

    Execute egate command  cmd=smf_param id=1 reset
    Stop 20Mbps UL traffic and kill background UEs[${background_ues}]

Set Maximum GBR Rate for DL and UL for 5QI-1 to ${rate}kb/s and set GBRService AdmissionControl
    ${configured_attributes}  catenate
    ...   {'MOC': 'NRDRB', 'ID': '15', 'maxDataRateGbrDl': '${rate}','maxDataRateGbrUl': '${rate}' },
    ...   {'MOC': 'NRCELL', 'ID': '1', 'actEnhancedVoNR': 'true', 'actGBRAdmissionControl': 'GBRService', 'maxGBRTrafficLimit': '90'}
    Configure  [${configured_attributes}]
    Discover bts    bts_id=1

Cleanup after test E_b-1
    Detach and kill UE1
    Configure  [{'MOC':'NRCELL', 'ID':'1', 'actNonVoNRGbrService':'true', 'actGBRAdmissionControl':'GBRService'}]
    Discover bts    bts_id=1
    Execute egate command    cmd=smf_param id=1 reset

Cleanup after test E_b-2
    Detach and kill UE1
    Detach and kill UE2
    Configure  [{'MOC':'NRCELL', 'ID':'1', 'actNonVoNRGbrService':'true', 'actGBRAdmissionControl':'GBRService'}]
    Discover bts    bts_id=1

Prepare test environment E_c-1
    Configure  [{'MOC':'NRCELL', 'ID':'1', 'maxGBRTrafficLimit':'${maxGBRTrafficLimit}'}]
    Set for all 5QIs GFBR to ${gfbr}Mbps and MFBR to ${mfbr}Mbps
    #  before test attach and run trf for some time to stabilize reported load
    Attach background small BWP UE31 to cell1 and run 30Mbps DL traffic on 5QI2 GBR bearer
    Attach background large BWP UE71 to cell1 and run 30Mbps DL traffic on 5QI2 GBR bearer
    sleep  5
    Detach and kill UE31
    Detach and kill UE71
    sleep  5
