*** Settings ***
Documentation
...    Author:  Kong Liang
...    Contact: liang.kong@nokia-sbell.com
...    Feature: CB014942-A
...    Release:

Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../resources/Airphone/Airphone_resource.robot


*** Variables ***
@{ALLOWED_FAULT}
&{tp_with_10M}    DLTP=200    ULTP=50
&{tp_with_20M}    DLTP=360    ULTP=100
&{tp_with_diff_chbw}    10MHz=&{tp_with_10M}    20MHz=&{tp_with_20M}

*** Test Cases ***
CB014942_A_TC5_NR_FDD_eCPRI_ABIP_DCM_ORAN_L3_Call_with_6CC_4T4R_isPrbPoolingEnabled_enable
    [Documentation]
    ...    This case is to verify DCM ORAN OMPA SA NR L3 call operateability on ABIP with FR1 FDD eCPRI 6 cell.
    [Tags]    ABIP    CB014942_A_TC5    Trunk
    Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
    ${cell_band_dict}    Get band From NR Cells
    ${cell_chbw_dict}    Get chBwDl From NR Cells
    ${global_cell_id_list}    Get Dictionary Keys    ${cell_band_dict}
    Log    ${global_cell_id_list}
    Log    ${cell_chbw_dict}
    ${length}=    Get Length    ${global_cell_id_list}
    FOR    ${index}    IN RANGE    ${length}
        ${cellid}    Set Variable    ${global_cell_id_list[${index}]}
        ${band}    Set Variable    ${cell_band_dict[${cellid}].strip('n')}
        ${chbw}    Set Variable    ${cell_chbw_dict[${cellid}]}
        ${dl_ul_tp_dict}    Set Variable    ${tp_with_diff_chbw['${chbw}']}
        Log To Console     \start L3 call on cell ${cellid}
        ${ueid}=    Convert To String    ${cellid}
        Airphone L3 call    call_type=sa    cell_id=${cellid}    ue_id=${ueid}    bearer_id=2
        ...    dl_mbps=${dl_ul_tp_dict['DLTP']}    ul_mbps=${dl_ul_tp_dict['ULTP']}    level=ue_stats_nr
        ...    duration=60    thresh=0.7
        sleep    10s
    END

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/fdd_sansa_cmwv/FS/CB014942_6cells_ecpri    cfg=wts.cfg    withCommission=True
