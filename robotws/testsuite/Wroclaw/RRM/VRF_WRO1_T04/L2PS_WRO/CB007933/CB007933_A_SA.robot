*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD    CRT    SBTS00    SBTS22R4    SBTS23R1    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      ../CB007262/CB007262_A/CB007262_keywords.py
Library     ta5g_pm_counters
Library     ta5g_setups_and_teardowns
Variables    ${CURDIR}/config/swconfig_flags.py

Suite Setup    Run Keywords    Activate L1Bypass
    ...        AND             Update Enb And Iphy Configuration And Perform Full Commissioning
    ...                        scfc_filename=Full_CB007933_enable_4TX_4RX.xml
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_ahib.xml
    ...                        swconfig_flags_list=@{swconfig_flags}
    ...        AND             Start Default Logging
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=     ${WRITE_PM_COUNTERS_EVERY_MINUTE}
${PRB_AVAIL_PDSCH}=    M55308C10003
${DL_DATA_SLOTS}=      M55308C00001

*** Test Cases ***
CB007933_A1_FDD_Cell_Configuration_Setup_With_20Mhz_DL_And_10Mhz_UL_Bandwidth_For_SA_UE_Nulling_The_Middle_PRBs_In_DL
    Set Internal Traffic Type To UE
    Attach SA UE And Establish PDU Session
    Start DL and UL Data Traffic
    Verify If PRBs in the GB has been removed from the available PRBs
    [Teardown]    Stop All Data Transfers And Detach UE

*** Keywords ***
Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
	Sleep   15s

Attach SA UE And Establish PDU Session
    Execute Egate Command   cmd=ue_register id=1
	Sleep   10s
    Execute Egate Command   cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    Sleep   20s

Start DL and UL Data Traffic
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=150
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=50
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    100s

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} >= ${expected_tput}

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Activate L1Bypass
   Execute Enb Command    cmd=echo "tag -3w app.btsom.nts.L1BypassMap 0x224D:0x574A" | nc 0 15007

Get Number Of Available PRB
       Wait For Next Full Pm Interval
       ${available_prb}=    Set Variable     ${0}
       ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
       ${VALUE_OF_PRB_AVAIL_PDSCH}=    Get Latest Pm Counter Value     counter_id=${PRB_AVAIL_PDSCH}
       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
       ${VALUE_OF_DL_DATA_SLOTS}=      Get Latest Pm Counter Value     counter_id=${DL_DATA_SLOTS}
       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
        ${available_prb}=    Evaluate     ${VALUE_OF_PRB_AVAIL_PDSCH}/${VALUE_OF_DL_DATA_SLOTS}
        [Return]    ${available_prb}

Verify If PRBs in the GB has been removed from the available PRBs
    ${available_prb}    Get Number Of Available PRB
    Run Keyword And Continue On Failure    Should Be True    ${available_prb} == 98
