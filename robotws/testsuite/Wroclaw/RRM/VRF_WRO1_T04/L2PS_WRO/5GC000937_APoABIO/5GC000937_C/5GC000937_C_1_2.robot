*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...   CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ../../resources/Python/webem_alarms.py
Library      ../5GC000937_A/5GC000937_keywords.py
Library      5GC000937-C_keywords.py
Resource     ../../resources/configuration_id.robot


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_2AEQE.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_5GC000937_C_2CC_TDD-TDD_ABIP.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_CA.lua

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC000937_C_1_2_Single-UE_Switch_To_Power_Saving_BWP_And_Switch_To_Large_BWP_With_CA_Activated
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Big DL Data Transfer And Check Switch To Large BWP And SCell Activation
    Verify DL Tput For 2CC
    Start Low Data Traffic And Check Scell Deactivation And Switch To Power Saving BWP
    Verify Low Data Traffic
    Start Big DL Data Transfer And Check Switch To Large BWP And SCell Activation
    Verify DL Tput For 2CC
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Start Big DL Data Transfer And Check Switch To Large BWP And SCell Activation
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=4
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=3
    ...    pass_regexp=Bwp switch received from bwpId 2 to 1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=2
    ...    pass_regexp=SCellIndex 1 activated successfully
    Sleep    20s

Verify DL Tput For 2CC
    ${pcell_tput}=    Get Avg Dl Data Traffic For Given Cc    ue_id=1    cc=0    unit=Mbps
    ${scell_tput}=    Get Avg Dl Data Traffic For Given Cc    ue_id=1    cc=1    unit=Mbps
    Should Be True    ${pcell_tput} > ${150}
    Should Be True    ${scell_tput} > ${150}

Verify Low Data Traffic
    ${pcell_tput}=    Get Avg Dl Data Traffic For Given Cc    ue_id=1    cc=0    unit=Kbps
    Should Be True    ${pcell_tput} < ${30}
    Verify There Is No Tput On Scell    ue_id=1

Start Low Data Traffic And Check Scell Deactivation And Switch To Power Saving BWP
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl kbps=10 trf_id=1 period_ms=100
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=ul kbps=10 trf_id=1 period_ms=100
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_stop ue=1 pdu=1 dir=dl trf_id=2-4
    ...    pass_regexp=SCellIndex 1 deactivated successfully.*Bwp switch received from bwpId 1 to 2
    Sleep    10s

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1 trf_id=1-4
    Sleep    10s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

