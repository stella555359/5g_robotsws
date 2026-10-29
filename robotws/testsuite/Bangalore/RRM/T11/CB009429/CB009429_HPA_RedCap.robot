*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED
Documentation    : copyright: Nokia



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../5G_CRT/resources/common_Resource.robot
Resource         ../5G_CRT/resources/common_keywords.robot
Resource          ./resources/CB009429_keywords.robot
Library          ta5g_cell_operations
Library          taf.sw.syslog
Resource        ../../../resources/robot/configuration_id.robot

*** Variables ***
${delta_configuration}       ${CURDIR}/config/scf/Delta_Configuration_Hpa_RedCap2.json
${wts_cfg_file_TC1}          ${CURDIR}/config/wts/basic_HPA_REDCAP_setup.cfg
${decommission_CB009429_A_B1_ALT1}    ${CURDIR}/config/scf/Decommission_CB009429_A_B1_ALT1.json
${Add_NRREL_MOs_CB009429_B_B1}                ${CURDIR}/config/scf/Addition_of_NRREL_MOs_CB009429_B_B1.json
${Activate_CB009429_B_B1}       ${CURDIR}/config/scf/Activate_CB009429_B_B1.json
${cfg_file_CB009429_B_B1}          ${CURDIR}/config/wts/basic_setup_CB009429_B_B1.cfg
${decommission_CB009429_B_B1}    ${CURDIR}/config/scf/Decommission_CB009429_B_B1.json

*** Test Cases ***
USCB009429-A#B1-ALT1 Handling 5QI1 RRC Release Delay timer for VoNR Call for a RedCap and HPA UE
    [Documentation]    :copyright: Nokia
    ...              :author: sanjeev
    ...              :contact: sanjeev.pandey@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes handling in gNB-CU when fiveQI1RrcRelDelayTimer
    ...             is running and then Handling 5QI1 RRC Release Delay timer for VoNR Call for a RedCap and HPA UE
    ...             TEST SET NAME:    CB009429
    ...             TESTING SPLIT:    CB009429
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB009429 CFAMDocumentation    :copyright: Nokia
    ...              :author: sanjeev
    ...              :contact: sanjeev.pandey@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes handling in gNB-CU when fiveQI1RrcRelDelayTimer
    ...             is running and then Handling 5QI1 RRC Release Delay timer for VoNR Call for a RedCap and HPA UE
    ...             TEST SET NAME:    CB009429
    ...             TESTING SPLIT:    CB009429
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB009429 CFAM
     [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    sleep    30s
    ...        AND    Start WTS Using WTS_Runner      ${wts_cfg_file_TC1}
    ${TEST_NAME}    Set Variable   TC2
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}

    Delta file commissioning for HPA and RedCap
    sleep    20s
    Check SIB messagges for all cells
    Start Tshark on eth3
    sleep    10s
    Start VONR call on UE-1
    sleep    10s
    Verify 5QI-1 addition
    Stop Tshark on eth3
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog  log_dir=/tmp  log_name=feat_act.log  alias=feat_act  ip=192.168.255.126   ports=51000
    Delete Normal VONR QoSflow
    sleep    15s
    Verify fiveQI1RrcRelDelayTimer started
    Start Tshark on eth3 after New VONR call
    sleep    10s
    Add QoSflow for VONR call
    Verify 5QI-1 addition after New VONR call
    Stop Tshark on eth3 after New VONR call
    Verify fiveQI1RrcRelDelayTimer stop
    sleep    10s
    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act.log    unzip=True    alias=feat_act
    Detach UE-1

    sleep    20s
    Start Tshark for redcap ue
    sleep    10s
    Start VONR for RedCap call on UE-91
    sleep    10s
    Verify RedCap addition
    Stop Tshark for redcap ue
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog  log_dir=/tmp  log_name=feat_act1.log  alias=feat_act  ip=192.168.255.126  ports=51000
    Delete Normal RedcapVONR QoSflow
    sleep    15s
    Verify fiveQI1RrcRelDelayTimer started
    Start Tshark on eth3 after New VONR call
    sleep    10s
    Add QoSflow for RedCapVONR call
    Verify 5QI-1 addition after New VONR call
    Stop Tshark on eth3 after New VONR call
    Verify fiveQI1RrcRelDelayTimer stop
    sleep    10s
    taf.sw.syslog.Collect Syslog Results  destination=${OUTPUTDIR}${/}feat_act1.log    unzip=True  alias=feat_act
    Detach UE-91
    [Teardown]    Run Keywords     Decommission the feature changes    ${decommission_CB009429_A_B1_ALT1}
     ...    AND   Link SCOUT SCF to Configuration ID for Reporting
    ...     AND   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...     AND   Stop Log   snapshot    sosreport


USCB009429-B#B1 Handling RRC Release Delay timer during intra-gNB Handover when feature is enabled in target cell
    [Documentation]    :copyright: Nokia
    ...              :author: Vishal K V
    ...              :contact: vishal.k_v@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes starting handling in gNB-CU a UE with 5QI1 RRC
    ...                               Release Delay Timer running performs an intra-gNB handover.
    ...             TEST SET NAME:    CB009429
    ...             TESTING SPLIT:    CB009429
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB009429 CFAM
     [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    sleep    30s
    ...        AND    Start WTS Using WTS_Runner      ${cfg_file_CB009429_B_B1}

    Add NRREL MOs and Activate CB009429_B#B1 scenario    ${Add_NRREL_MOs_CB009429_B_B1}    ${Activate_CB009429_B_B1}
    sleep    20s
    Check SIB messagges for all cells
    Start Tshark on eth3
    Change UE_1 location to ENB_2 Cell_7
    sleep    10s
    Start VONR call on UE-1
    sleep    10s
    Verify 5QI-1 addition
    Stop Tshark on eth3
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog  log_dir=/tmp  log_name=feat_act.log  alias=feat_act  ip=192.168.255.126   ports=51000
    Delete Normal VONR QoSflow
    sleep    15s
    Verify fiveQI1RrcRelDelayTimer started
    Send A1 measurement report and verify HO to cell_1
    sleep    10s
    Verify fiveQI1RrcRelDelayTimer is not stopped
    Sleep    10s
    Start Tshark on eth3 after New VONR call
    Add QoSflow for VONR call
    Verify 5QI-1 addition after New VONR call
    Stop Tshark on eth3 after New VONR call
    Verify fiveQI1RrcRelDelayTimer stop
    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act.log    unzip=True    alias=feat_act
    taf.sw.syslog.Start Syslog  log_dir=/tmp  log_name=feat_act1.log  alias=feat_act  ip=192.168.255.126   ports=51000
    Delete Normal VONR QoSflow
    sleep    15s
    Verify fiveQI1RrcRelDelayTimer started
    Send A1 measurement report and verify HO to cell_2
    sleep    10s
    Verify fiveQI1RrcRelDelayTimer is not stopped
    Sleep    10s
    Start Tshark on eth3 after New VONR call
    Add QoSflow for VONR call
    Verify 5QI-1 addition after New VONR call
    Stop Tshark on eth3 after New VONR call
    Verify fiveQI1RrcRelDelayTimer stop
    [Teardown]    Run keywords    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act1.log    unzip=True    alias=feat_act
     ...    AND    Detach UE-1
     ...    AND    Link SCOUT SCF to Configuration ID for Reporting
     ...    AND    Decommission the feature changes    ${decommission_CB009429_B_B1}
     ...    AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
     ...    AND    Stop Log   snapshot    sosreport






