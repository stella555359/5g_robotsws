*** Settings ***
Documentation
...    Author:  Gao Claire
...    Contact: Claire.gao@nokia-sbell.com
...    Feature: CB012605
...    Release: 25R2

Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../resources/Airphone/Airphone_resource.robot

*** Variables ***
${tl_type}    AP_LOOO/tdd_sansa_cmwv/3cells_ecpri_CB012605
&{enable_vendor_dict}    xEc=14    maxNumLayerPrbL1Sp=200

*** Test Cases ***

CB012605_C_D_TC12_NR_FR1_TDD_eCPRI_ABIP_72e_L1_subpool_DL_UL_PRB_Pooling_L3_call
    [Documentation]
    ...    This case is to verify ABIP NR FR1 TDD eCPRI enbale 72e in UL/DL.
    ...    Deploy 3*100MHz NR cells in each L1 subpool, reduce maxNumLayerPrbL1Sp both in DL and UL in vendor file.
    ...    Trigger intra/inter DL and UL L1 Layer-PRBs pooling via load-based algorithm for eCPRI 72e.
    [Tags]    ABIP    CB012605    Trunk    airphone
    ${scf_file}    Get Current Scfc
    ${bbpool_list}    Get Value From SCF By Class    ${scf_file}    BBPOOL    BBPOOL-11    bbPoolCellsList
    Log To Console     \start ue attach
    Ue Attach to 3cells    ${bbpool_list}
    Log To Console     \start L3 call
    Start 5G L3 call and verify for UL and DL
    Sleep    300s
    Log To Console     \start to check PM counter
    Check Layer PRBs PDSCH PM counter    ${bbpool_list}
    Check Layer PRBs PUSCH PM counter    ${bbpool_list}
    [Teardown]    UE stop data transfer and detach

*** Keywords ***

Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/3cells_ecpri_CB012605    cfg=wts.cfg    withCommission=True    isVendor=True

Ue Attach to 3cells
    [Arguments]    ${bbpool_list}
    ue_register    ue_id=1    cell_id=${bbpool_list}[0][0]
    ue_register    ue_id=2    cell_id=${bbpool_list}[0][0]
    ue_register    ue_id=22    cell_id=${bbpool_list}[0][1]
    ue_register    ue_id=24    cell_id=${bbpool_list}[0][2]

Start 5G L3 call and verify for UL and DL
    Traffic Start And Throughput Verify    ue_id=1    dl_mbps=60    ul_mbps=20    thresh=0.65    level=ue_stats_nr
    Traffic Start And Throughput Verify    ue_id=2    dl_mbps=60    ul_mbps=20    thresh=0.65    level=ue_stats_nr
    Traffic Start And Throughput Verify    ue_id=22    dl_mbps=120    ul_mbps=40    thresh=0.8    level=ue_stats_nr
    Traffic Start And Throughput Verify    ue_id=24    dl_mbps=120    ul_mbps=40    thresh=0.8    level=ue_stats_nr

UE stop data transfer and detach
    traffic_data_stop   ue_id=1
    traffic_data_stop   ue_id=2
    traffic_data_stop   ue_id=22
    traffic_data_stop   ue_id=24
    release_ues    ue_id=1-24


Check Layer PRBs PDSCH PM counter
    [Arguments]    ${bbpool_list}
    Clear Counter files
    ${pm_counters}    Create List    NRCELL-${bbpool_list}[0][0]:M55308C36005    NRCELL-${bbpool_list}[0][1]:M55308C36005
    ...    NRCELL-${bbpool_list}[0][2]:M55308C36005    NRCELL-${bbpool_list}[0][0]:M55308C36006    NRCELL-${bbpool_list}[0][1]:M55308C36006
    ...    NRCELL-${bbpool_list}[0][2]:M55308C36006
    ${M55308C36005_c1}    ${M55308C36005_c2}    ${M55308C36005_c3}
    ...    ${M55308C36006_c1}    ${M55308C36006_c2}    ${M55308C36006_c3}    get_counters_value    ${pm_counters}
    ${Layer_PRBs_Used_PDSCH_c1} =    Run Keyword And Return Status    Should Be True
    ...    ${M55308C36006_c1}<${M55308C36005_c1} and ${M55308C36006_c1}>=20000000
    ${Layer_PRBs_Used_PDSCH_c2} =    Run Keyword And Return Status    Should Be True
    ...    ${M55308C36006_c2}<${M55308C36005_c2} and ${M55308C36006_c2}>=20000000
    ${Layer_PRBs_Used_PDSCH_c3} =    Run Keyword And Return Status    Should Be True
    ...    ${M55308C36006_c3}<${M55308C36005_c3} and ${M55308C36006_c3}>=20000000
    Run Keyword If    not ${Layer_PRBs_Used_PDSCH_c1}    Fail    The DL pooling PM counter can not match.
    Run Keyword If    not ${Layer_PRBs_Used_PDSCH_c2}    Fail    The DL pooling PM counter can not match.
    Run Keyword If    not ${Layer_PRBs_Used_PDSCH_c3}    Fail    The DL pooling PM counter can not match.

Check Layer PRBs PUSCH PM counter
    [Arguments]    ${bbpool_list}
    Clear Counter files
    ${pm_counters}    Create List    NRCELL-${bbpool_list}[0][0]:M55308C36007    NRCELL-${bbpool_list}[0][1]:M55308C36007
    ...    NRCELL-${bbpool_list}[0][2]:M55308C36007    NRCELL-${bbpool_list}[0][0]:M55308C36008    NRCELL-${bbpool_list}[0][1]:M55308C36008
    ...    NRCELL-${bbpool_list}[0][2]:M55308C36008
    ${M55308C36007_c1}    ${M55308C36007_c2}    ${M55308C36007_c3}
    ...    ${M55308C36008_c1}    ${M55308C36008_c2}    ${M55308C36008_c3}    get_counters_value    ${pm_counters}
    ${Layer_PRBs_Used_PUSCH_c1} =    Run Keyword And Return Status    Should Be True
    ...    ${M55308C36008_c1}<${M55308C36007_c1} and ${M55308C36008_c1}>=10000000
    ${Layer_PRBs_Used_PUSCH_c2} =    Run Keyword And Return Status    Should Be True
    ...    ${M55308C36008_c2}<${M55308C36007_c2} and ${M55308C36008_c2}>=10000000
    ${Layer_PRBs_Used_PUSCH_c3} =    Run Keyword And Return Status    Should Be True
    ...    ${M55308C36008_c3}<${M55308C36007_c3} and ${M55308C36008_c3}>=10000000
    Run Keyword If    not ${Layer_PRBs_Used_PUSCH_c1}    Fail    The UL pooling PM counter can not match.
    Run Keyword If    not ${Layer_PRBs_Used_PUSCH_c2}    Fail    The UL pooling PM counter can not match.
    Run Keyword If    not ${Layer_PRBs_Used_PUSCH_c3}    Fail    The UL pooling PM counter can not match.

Configure TL With Vendor Update Airphone
    [Arguments]    ${param_dict}    ${scf_file}    ${btsid}
    vendor_update    ${SUITE_LOG_DIRECTORY}    ${param_dict}    ${scf_file}    ${btsid}
    Wait Until Keyword Succeeds    5 min    30 sec    sbts_admin.connect_to    name=vendor_update
    [Teardown]    sbts_admin.teardown    connection=vendor_update