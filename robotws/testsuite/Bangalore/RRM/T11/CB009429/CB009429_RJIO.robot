*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: sujeet
...              :contact: sujeet.sharma@nokia.com
...
...             INTRODUCTION:     This user scenario describes handling in gNB-CU when fiveQI1RrcRelDelayTimer
...             is runningand subsequent 5QI-1 setup is failing due to RAC failure which triggers Voice Fallback to LTE.
...             TEST SET NAME:    CB009429
...             TESTING SPLIT:    Refer CB013789 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB009429 CFAM
...             Requirement ID:   12680563

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
${delta_configuration_IRAT}       ${CURDIR}/config/scf/Delta_Configuration_IRAT.json
${delta_configuration_No_Resorce}      ${CURDIR}/config/scf/Delta_Configuration_No_resource.json
${delta_configuration_deactivation}      ${CURDIR}/config/scf/Delta_feature_disable.json
${delta_configuration_activation}       ${CURDIR}/config/scf/Delta_feature_enable.json
${wts_cfg_file_TC1}          ${CURDIR}/config/wts/basic_setup_IRAT.cfg

*** Test Cases ***
USCB009429-A#IWK6_Interworking_with_5GC000749_Voice_Fallback_to_LTE

     [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    Update bsr package
    ...        AND    sleep    30s
    ...        AND    Run cfg file      ${wts_cfg_file_TC1}

    Delta file commissioning for IRAT
    sleep    20s
    Check SIB messagges for all cells_RJIO
    Start Tshark on eth3
    sleep    10s
    Start non-emergency VONR call on UE    i1=1     i2=2
    sleep    10s
    Verify 5QI-1 addition
    Stop Tshark on eth3
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog    log_dir=/tmp    log_name=feat_act.log    alias=feat_act  ip=192.168.255.126       ports=51000
    Delete non-emergency VONR QoSflow UE    i1=1     i2=2
    sleep    10s
    Verify fiveQI1RrcRelDelayTimer started
    Delta file commissioning for No Resouce
    sleep    5s
    Start Tshark on eth3 for re-direct
    Add QoSflow for non-emergency VONR call    i1=1     i2=2
    sleep    10s
    Verify voice fallback to eutran
    Stop Tshark on eth3 for re-direct
    Detach non-emergency VONR Call     i1=1     i2=2
    Feature deactivation by delta file
    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act.log    unzip=True    alias=feat_act
    taf.sw.syslog.teardown_all_aliases_for_syslog
    Verify fiveQI1RrcRelDelayTimer stop after IRAT
    sleep    10s
    taf.sw.syslog.Start Syslog    log_dir=/tmp    log_name=feat_act_1.log    alias=feat_act_1  ip=192.168.255.126       ports=51000
    Start non-emergency VONR call on UE    i1=2     i2=3
    sleep    10s
    Delete non-emergency VONR QoSflow UE    i1=2    i2=3
    sleep    15s
    Verify fiveQI1RrcRelDelayTimer not started
    Detach non-emergency VONR Call     i1=2     i2=3
    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act_1.log    unzip=True    alias=feat_act_1
    taf.sw.syslog.teardown_all_aliases_for_syslog
    sleep    10s
    taf.sw.syslog.Start Syslog    log_dir=/tmp    log_name=feat_act_2.log    alias=feat_act_2  ip=192.168.255.126       ports=51000
    Feature activation by delta file
    Start non-emergency VONR call on UE     i1=3     i2=8
    sleep    10s
    Delete non-emergency VONR QoSflow UE    i1=3    i2=6
    sleep    10s
    Verify fiveQI1RrcRelDelayTimer started for multi-UE
    Delta file commissioning for No Resouce
    sleep    10s
    Add QoSflow for non-emergency VONR call    i1=3     i2=6
    sleep    12s
    wait_for_next_full_pm_interval
    Verify multi VONR established
    Verify voicefallback counter
	 [Teardown]     Run Keywords    syslog crash verification
	 ...    AND       taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act_2.log    unzip=True    alias=feat_act_2
	 ...    AND      Verify fiveQI1RrcRelDelayTimer stop for multi-UE
     ...    AND     Link SCOUT SCF to Configuration ID for Reporting
 	 ...    AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner







