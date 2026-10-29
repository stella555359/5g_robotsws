*** Settings ***
Documentation
...    Author:  Hou Yuguo
...    Contact: yuguo.hou@nokia-sbell.com
...    Feature: CB009794
...    Release: 23R4

Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    SBTS00    SBTS23R3    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../resources/Airphone/Airphone_resource.robot

*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
CB009794_TC02_NR_FR1_TDD_eCPRI_ABIO_AZHL_activate_deactivate_feature_and_RTWP_measurement
    [Documentation]
    ...    This case is to verify ABIO PMcounter with 9794 NR RTWP activate.
    [Tags]    LOKI    L1CRT    ABIO     airphone    CB009794
    Online Change Parameter    MRBTS-1/NRBTS-1    actRtwpMeasurement    true    update
    Check PM counter 1
    ue_register    ue_id=1    cell_id=1
    traffic_start_and_throughput_verify    ue_id=1    dl_mbps=1    ul_mbps=100
    Check PM counter 2
    Online Change Parameter    MRBTS-1/NRBTS-1    actRtwpMeasurement    false    update
    Check PM counter 3
    traffic_data_stop   ue_id=1
    release_ues    ue_id=1

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/CB009794_2cell_ecpri    cfg=wts.cfg

Check PM counter 1
    Clear Counter files
    ${pm_counters}    Create List    NRCELL-1:M55369C00000     NRCELL-1:M55369C00001    NRCELL-1:M55369C00002    NRCELL-1:M55369C00003
    ...    NRCELL-1:M55369C00004    NRCELL-1:M55369C00005    NRCELL-1:M55369C00006    NRCELL-1:M55369C00007
    ...    NRCELL-1:M55369C00100    NRCELL-1:M55369C00101    NRCELL-1:M55369C00102    NRCELL-1:M55369C00103
    ...    NRCELL-1:M55369C00104    NRCELL-1:M55369C00105    NRCELL-1:M55369C00106    NRCELL-1:M55369C00107
    ...    NRCELL-1:M55369C00200    NRCELL-1:M55369C00201    NRCELL-1:M55369C00202    NRCELL-1:M55369C00203
    ...    NRCELL-1:M55369C00204    NRCELL-1:M55369C00205    NRCELL-1:M55369C00206    NRCELL-1:M55369C00207
    ${M55369C00000}    ${M55369C00001}    ${M55369C00002}    ${M55369C00003}
    ...    ${M55369C00004}    ${M55369C00005}    ${M55369C00006}    ${M55369C00007}
    ...    ${M55369C00100}    ${M55369C00101}    ${M55369C00102}    ${M55369C00103}
    ...    ${M55369C00104}    ${M55369C00105}    ${M55369C00106}    ${M55369C00107}
    ...    ${M55369C00200}    ${M55369C00201}    ${M55369C00202}    ${M55369C00203}
    ...    ${M55369C00204}    ${M55369C00205}    ${M55369C00206}    ${M55369C00207}    get_counters_value    ${pm_counters}
    should_be_true    ${M55369C00000}<=-85
    should_be_true    ${M55369C00001}<=-85
    should_be_true    ${M55369C00002}<=-85
    should_be_true    ${M55369C00003}<=-85
    should_be_true    ${M55369C00004}==0
    should_be_true    ${M55369C00005}==0
    should_be_true    ${M55369C00006}==0
    should_be_true    ${M55369C00007}==0

    should_be_true    ${M55369C00100}<=-85
    should_be_true    ${M55369C00101}<=-85
    should_be_true    ${M55369C00102}<=-85
    should_be_true    ${M55369C00103}<=-85
    should_be_true    ${M55369C00104}==0
    should_be_true    ${M55369C00105}==0
    should_be_true    ${M55369C00106}==0
    should_be_true    ${M55369C00107}==0

    should_be_true    ${M55369C00200}<=-85
    should_be_true    ${M55369C00201}<=-85
    should_be_true    ${M55369C00202}<=-85
    should_be_true    ${M55369C00203}<=-85
    should_be_true    ${M55369C00204}==0
    should_be_true    ${M55369C00205}==0
    should_be_true    ${M55369C00206}==0
    should_be_true    ${M55369C00207}==0

Check PM counter 2
    Clear Counter files
    ${pm_counters}    Create List    NRCELL-1:M55369C00000     NRCELL-1:M55369C00001    NRCELL-1:M55369C00002    NRCELL-1:M55369C00003
    ...    NRCELL-1:M55369C00004    NRCELL-1:M55369C00005    NRCELL-1:M55369C00006    NRCELL-1:M55369C00007
    ...    NRCELL-1:M55369C00100    NRCELL-1:M55369C00101    NRCELL-1:M55369C00102    NRCELL-1:M55369C00103
    ...    NRCELL-1:M55369C00104    NRCELL-1:M55369C00105    NRCELL-1:M55369C00106    NRCELL-1:M55369C00107
    ...    NRCELL-1:M55369C00200    NRCELL-1:M55369C00201    NRCELL-1:M55369C00202    NRCELL-1:M55369C00203
    ...    NRCELL-1:M55369C00204    NRCELL-1:M55369C00205    NRCELL-1:M55369C00206    NRCELL-1:M55369C00207
    ${M55369C00000}    ${M55369C00001}    ${M55369C00002}    ${M55369C00003}
    ...    ${M55369C00004}    ${M55369C00005}    ${M55369C00006}    ${M55369C00007}
    ...    ${M55369C00100}    ${M55369C00101}    ${M55369C00102}    ${M55369C00103}
    ...    ${M55369C00104}    ${M55369C00105}    ${M55369C00106}    ${M55369C00107}
    ...    ${M55369C00200}    ${M55369C00201}    ${M55369C00202}    ${M55369C00203}
    ...    ${M55369C00204}    ${M55369C00205}    ${M55369C00206}    ${M55369C00207}    get_counters_value    ${pm_counters}
    should_be_true    ${M55369C00000}>=-85
    should_be_true    ${M55369C00001}>=-85
    should_be_true    ${M55369C00002}>=-85
    should_be_true    ${M55369C00003}>=-85
    should_be_true    ${M55369C00004}==0
    should_be_true    ${M55369C00005}==0
    should_be_true    ${M55369C00006}==0
    should_be_true    ${M55369C00007}==0

    should_be_true    ${M55369C00100}>=-85
    should_be_true    ${M55369C00101}>=-85
    should_be_true    ${M55369C00102}>=-85
    should_be_true    ${M55369C00103}>=-85
    should_be_true    ${M55369C00104}==0
    should_be_true    ${M55369C00105}==0
    should_be_true    ${M55369C00106}==0
    should_be_true    ${M55369C00107}==0

    should_be_true    ${M55369C00200}>=-85
    should_be_true    ${M55369C00201}>=-85
    should_be_true    ${M55369C00202}>=-85
    should_be_true    ${M55369C00203}>=-85
    should_be_true    ${M55369C00204}==0
    should_be_true    ${M55369C00205}==0
    should_be_true    ${M55369C00206}==0
    should_be_true    ${M55369C00207}==0

Check PM counter 3
    Clear Counter files
    ${pm_counters}    Create List    NRCELL-1:M55369C00000     NRCELL-1:M55369C00001    NRCELL-1:M55369C00002    NRCELL-1:M55369C00003
    ...    NRCELL-1:M55369C00004    NRCELL-1:M55369C00005    NRCELL-1:M55369C00006    NRCELL-1:M55369C00007
    ...    NRCELL-1:M55369C00100    NRCELL-1:M55369C00101    NRCELL-1:M55369C00102    NRCELL-1:M55369C00103
    ...    NRCELL-1:M55369C00104    NRCELL-1:M55369C00105    NRCELL-1:M55369C00106    NRCELL-1:M55369C00107
    ...    NRCELL-1:M55369C00200    NRCELL-1:M55369C00201    NRCELL-1:M55369C00202    NRCELL-1:M55369C00203
    ...    NRCELL-1:M55369C00204    NRCELL-1:M55369C00205    NRCELL-1:M55369C00206    NRCELL-1:M55369C00207
    ${M55369C00000}    ${M55369C00001}    ${M55369C00002}    ${M55369C00003}
    ...    ${M55369C00004}    ${M55369C00005}    ${M55369C00006}    ${M55369C00007}
    ...    ${M55369C00100}    ${M55369C00101}    ${M55369C00102}    ${M55369C00103}
    ...    ${M55369C00104}    ${M55369C00105}    ${M55369C00106}    ${M55369C00107}
    ...    ${M55369C00200}    ${M55369C00201}    ${M55369C00202}    ${M55369C00203}
    ...    ${M55369C00204}    ${M55369C00205}    ${M55369C00206}    ${M55369C00207}    get_counters_value    ${pm_counters}
    should_be_true    ${M55369C00000}==0
    should_be_true    ${M55369C00001}==0
    should_be_true    ${M55369C00002}==0
    should_be_true    ${M55369C00003}==0
    should_be_true    ${M55369C00004}==0
    should_be_true    ${M55369C00005}==0
    should_be_true    ${M55369C00006}==0
    should_be_true    ${M55369C00007}==0

    should_be_true    ${M55369C00100}==0
    should_be_true    ${M55369C00101}==0
    should_be_true    ${M55369C00102}==0
    should_be_true    ${M55369C00103}==0
    should_be_true    ${M55369C00104}==0
    should_be_true    ${M55369C00105}==0
    should_be_true    ${M55369C00106}==0
    should_be_true    ${M55369C00107}==0

    should_be_true    ${M55369C00200}==0
    should_be_true    ${M55369C00201}==0
    should_be_true    ${M55369C00202}==0
    should_be_true    ${M55369C00203}==0
    should_be_true    ${M55369C00204}==0
    should_be_true    ${M55369C00205}==0
    should_be_true    ${M55369C00206}==0
    should_be_true    ${M55369C00207}==0
