*** Settings ***
Documentation
...    Author: Huang Shujun
...    Contact: shujun.j.huang@nokia-sbell.com
...    Feature: CB006915_A
...    Release: 23R3
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    SBTS23R3    5G_RAN_TDD    RAN_5G    SBTS00    CB006915    QCD_MN_RAN    QCP_RAN_RF


Library           taf.selenium.sbts  WITH NAME  selenium_coam
Resource    ../resources/Airphone/Airphone_resource.robot
Resource    ../resources/common_resource_bts.robot


*** Variables ***
${active_sw}     SBTS23R3_ENB_9999_230417_000003
&{GNB_ASIB}       ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik

*** Test Cases ***
CB006915_A_B1_TC02_NR_FR1_TDD_eCPRI_ABIO_3Cells_8DL8UL_L3call
    [Documentation]
    ...    This case is used to verify NR FR1 TDD eCPRI 3 cells L3 call with 8DL8UL 100MHz in half ABIO with IQ capture
    [Tags]    CB006915    CB006915_US02    CRT    Trunk
    step1:UE attach to 3cells
    step2:Setup Parameter for UL 2subcell IQ capture
    step3:Start 5G L3 call and verify TP for UL and DL
    # step4:check UL event trigger count
    step5:Disable IQcapture
    step6:Setup Parameter for DL 2subcell IQ capture
    step7:IQ capture and save snapshot
    step8:UE stop data transfer and detach

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Get BSR package
    Load and active BSR
    Setup Airphone Env  tl_type=AP_LOOO/tdd_sansa_cmwv/FS/3cells_ecpri    cfg=wts.cfg

step1:UE attach to 3cells
    ue_register    ue_id=1    cell_id=1
    ue_register    ue_id=2    cell_id=2
    ue_register    ue_id=3    cell_id=3

step2:Setup Parameter for UL 2subcell IQ capture
    WebUI connection    suite
    ${ul_subcell_index_list}=    Create List    [BBMOD_R-1(ABIO)] [PCI: 50]NRCELL-1: Subcell 0
    ...    [BBMOD_R-1(ABIO)] [PCI: 50]NRCELL-1: Subcell 1
    Configure IQ capture via webUI     ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    common_resource_bts.ADMIN Set RAD debug parameters    NrUlPhy    phyEventEnableExt    2147483648
    ${phyEventEnableExt}    common_resource_bts.ADMIN Get RAD Debug Parameter Details    NrUlPhy    phyEventEnableExt
    log    ${phyEventEnableExt}

step3:Start 5G L3 call and verify TP for UL and DL
    traffic_start_and_throughput_verify    ue_id=1    dl_mbps=400    ul_mbps=100    duration=60
    traffic_start_and_throughput_verify    ue_id=2    dl_mbps=400    ul_mbps=100    duration=60
    traffic_start_and_throughput_verify    ue_id=3    dl_mbps=400    ul_mbps=100    duration=60

step4:check UL event trigger count
    Wait Until Keyword Succeeds    2min    30s    check the event count

step5:Disable IQcapture
    Disable IQ capture via webUI

step6:Setup Parameter for DL 2subcell IQ capture
    ${dl_subcell_index_list}=    Create List    [BBMOD_R-1(ABIO)] [PCI: 50]NRCELL-1: Subcell 0
    ...    [BBMOD_R-1(ABIO)] [PCI: 50]NRCELL-1: Subcell 1
    Configure IQ capture via webUI     ul_subcell_index_list=${None}    dl_subcell_index_list=${dl_subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    common_resource_bts.ADMIN Set RAD debug parameters    NrDlPhy    dlPhyEventEnable    1
    ${dlPhyEventEnable}    common_resource_bts.ADMIN Get RAD Debug Parameter Details    NrDlPhy    dlPhyEventEnable
    log    ${dlPhyEventEnable}

step7:IQ capture and save snapshot
    # Wait Until Keyword Succeeds    2min    30s    check the event count
    Save SnapShot

check the event count
    ${event_count}    Get Event Trigger Count on BBMOD    bsh 1:1    NR
    Should Be True    ${event_count}>0    [ERROR]Event Trigger Count not large than zero

Save SnapShot
    [Arguments]    ${log_dir}=${TEST_LOG_DIR}
    ${coam_connection}    sbts_admin.Connect To    bts_host=${GNB_ASIB.ip}
    sbts_admin.Get SnapShot    target_file_name=${log_dir}/snapShot.zip    coverage=Full    force=True
    ...    connection=${coam_connection}

step8:UE stop data transfer and detach
    traffic_data_stop   ue_id=1
    traffic_data_stop   ue_id=2
    traffic_data_stop   ue_id=3

