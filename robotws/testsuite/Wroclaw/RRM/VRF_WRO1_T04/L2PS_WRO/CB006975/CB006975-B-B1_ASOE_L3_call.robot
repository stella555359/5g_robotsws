*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_O_E_AP_KL_SANSA_FS_CPRI_CMWV_FDD    CRT    SBTS00    SBTS22R4    SBTS23R1    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      ../CB007262/CB007262_A/CB007262_keywords.py


Suite Setup    Run Keywords    Activate L1Bypass ASOE
    ...        AND             Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AHPF.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=scfc_1_cell_30mhz_asoe_fdd.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_30mhz.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB006975-5G-B-B1_ASOE_1Cell_SA_L3_Call
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start DL and UL Data Traffic
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=9.5
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=4.5
    [Teardown]    Stop All Data Transfers And Detach UE

*** Keywords ***
Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Start DL and UL Data Traffic
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=10
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=5
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    30s

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} >= ${expected_tput}

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Activate L1Bypass ASOE
   Execute Enb Command    cmd=echo "tag -3w app.btsom.nts.L1BypassMap 0x104D:0x574A" | nc 0 15007
