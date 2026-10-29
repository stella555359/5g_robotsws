# @Time    : 2025/8/18 15:00
# @Author  : Chen Jian
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB012724.robot
# @Software: PyCharm
# @Doc     : robot for CB012724 AP TCs
*** Settings ***

Documentation
...    author: Chen Jian
...    Contact: jian.1.chen@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: CB012724:NR Counters of Utilization and Quality Measurements

Test Setup    Run Keywords    Common Suite Setup    AND    Common Test Setup
...    AND    Start DCAP Containers in UTE
Test Teardown    Run Keywords    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
...    AND    Common Test Teardown    AND    Common Suite Teardown
...    AND    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file '${None}'
Force Tags    AP    CRT    SBTS00   CLOUD_5G_I_LOO_AP_LOOO
Resource    CB012724_check_counter.robot
Resource    CB012724_check_syslog.robot
*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
@{CUSTOM_PROFILE}    condor5gSyslog
#@{CUSTOM_PROFILE_SYSLOG}    cp_5g    condor5gSyslog
#@{CUSTOM_PROFILE_L2}    L2Ps_Component    L2Lo_Component    L2HiRlc_Component    L2HiPdcp_Component
#${qfi1_tp}    50

##For B103
&{B103_COMMON_VARIABLES}    SCFC_NAME=B_103.xml    AIRPHONE_NAME=B_103_ap.xml    WTS_NAME=B_103_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=H_bts_swconfig.txt    AP_SWCONFIG_NAME=H_ap_swconfig.txt
@{B_103_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_attach id\=51    1s
...    ue_dc_enb_start ue\=51 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg    1s
...    bearer_add ue\=51 id\=3 filter\=0 precedence\=7 proto\=17    1s
...    enb_ue_dc_modify ue\=51 bearer_to_add\=3 by\=enb cause\=RN_action_desirable_for_radio_reasons    1s
...    ue_attach id\=52    1s
...    ue_dc_enb_start ue\=52 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg    1s
...    ue_attach id\=53    1s
...    ue_dc_enb_start ue\=53 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg    1s
...    bearer_add ue\=53 id\=3 filter\=0 precedence\=7 proto\=17    1s
...    enb_ue_dc_modify ue\=53 bearer_to_add\=3 by\=enb cause\=RN_action_desirable_for_radio_reasons    1s
...    trf_data_start ue\=51 id\=2 dir\=ul mbps\=5 trf_id\=1    0.1s
...    trf_data_start ue\=51 id\=2 dir\=dl mbps\=10 trf_id\=1    0.1s
...    trf_data_start ue\=51 id\=3 dir\=ul mbps\=5 trf_id\=1    0.1s
...    trf_data_start ue\=51 id\=3 dir\=dl mbps\=10 trf_id\=1    0.1s
...    trf_data_start ue\=52 id\=2 dir\=ul mbps\=5 trf_id\=1    0.1s
...    trf_data_start ue\=52 id\=2 dir\=dl mbps\=10 trf_id\=1    0.1s
...    trf_data_start ue\=53 id\=3 dir\=ul mbps\=5 trf_id\=1    0.1s
...    trf_data_start ue\=53 id\=3 dir\=dl mbps\=10 trf_id\=1    2s
...    trf_data_stop ue\=51    1s
...    trf_data_stop ue\=52    1s
...    trf_data_stop ue\=53    1s
...    ue_detach id\=51    1s
...    ue_detach id\=52    1s
...    ue_detach id\=53    10s
@{B_103_AP_CMDS_WITH_SLEEP_TIME_STEP2}
...    ue_attach id\=51    1s
...    ue_dc_enb_start ue\=51 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg    1s
...    bearer_add ue\=51 id\=3 filter\=0 precedence\=7 proto\=17    1s
...    enb_ue_dc_modify ue\=51 bearer_to_add\=3 by\=enb cause\=RN_action_desirable_for_radio_reasons    1s
...    ue_attach id\=52    1s
...    ue_dc_enb_start ue\=52 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg    1s
...    ue_attach id\=53    1s
...    ue_dc_enb_start ue\=53 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg    1s
...    bearer_add ue\=53 id\=3 filter\=0 precedence\=7 proto\=17    1s
...    enb_ue_dc_modify ue\=53 bearer_to_add\=3 by\=enb cause\=RN_action_desirable_for_radio_reasons    1s
...    bler_testmode_nr profile_id\=1 dl_bler\=1,0,0,0 pdcch_misd_rate\=1    1s
...    ue_testmode_set_nr id\=52 testmode\=bler profile_id\=1 action\=activate scell\=8    1s
...    trf_data_start ue\=51 id\=2 dir\=ul mbps\=5 trf_id\=1    0.1s
...    trf_data_start ue\=51 id\=2 dir\=dl mbps\=10 trf_id\=1    0.1s
...    trf_data_start ue\=51 id\=3 dir\=ul mbps\=5 trf_id\=1    0.1s
...    trf_data_start ue\=51 id\=3 dir\=dl mbps\=10 trf_id\=1    0.1s
...    trf_data_start ue\=52 id\=2 dir\=ul mbps\=5 trf_id\=1    0.1s
...    trf_data_start ue\=52 id\=2 dir\=dl mbps\=10 trf_id\=1    0.1s
...    trf_data_start ue\=53 id\=3 dir\=ul mbps\=5 trf_id\=1    0.1s
...    trf_data_start ue\=53 id\=3 dir\=dl mbps\=10 trf_id\=1    2s
...    ue_testmode_set_nr id\=52 testmode\=bler profile_id\=1 action\=deactivate scell\=8    1s
...    trf_data_stop ue\=51    1s
...    trf_data_stop ue\=52    1s
...    trf_data_stop ue\=53    1s
...    ue_detach id\=51    1s
...    ue_detach id\=52    1s
...    ue_detach id\=53    10s

#For B106
&{B106_COMMON_VARIABLES}    SCFC_NAME=B_106.xml    AIRPHONE_NAME=B_106_ap.xml    WTS_NAME=B_106_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=H_bts_swconfig.txt    AP_SWCONFIG_NAME=H_ap_swconfig.txt

#For B108
&{B108_COMMON_VARIABLES}    SCFC_NAME=B_108.xml    AIRPHONE_NAME=B_108_ap.xml    WTS_NAME=B_108_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=H_bts_swconfig.txt    AP_SWCONFIG_NAME=H_ap_swconfig.txt
@{B_108_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_register id\=1    1s
...    set_pdu_param ue\=1 pdu\=1 trf_type\=internal    1s
...    ue_register id\=2    1s
...    set_pdu_param ue\=2 pdu\=1 trf_type\=internal    1s
...    ue_register id\=3    1s
...    set_pdu_param ue\=3 pdu\=1 trf_type\=internal    1s
...    ue_register id\=4    1s
...    set_pdu_param ue\=4 pdu\=1 trf_type\=internal    1s
...    ue_register id\=5    1s
...    set_pdu_param ue\=5 pdu\=1 trf_type\=internal    1s
...    ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=2    1s
...    ue_pdu_session_setup pdu\=1 ue\=2 nwslice\=3    1s
...    ue_pdu_session_setup pdu\=1 ue\=3 nwslice\=3    1s
...    ue_pdu_session_setup pdu\=1 ue\=4 nwslice\=2    1s
...    ue_pdu_session_setup pdu\=1 ue\=5 nwslice\=3    1s
...    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=2 by\=amf    1s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul Kbps\=20    0.01s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl Kbps\=20    0.01s
...    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul Kbps\=20    0.01s
...    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl Kbps\=20    0.01s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul mbps\=5    0.01s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl mbps\=5    0.01s
...    trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=ul mbps\=5    0.01s
...    trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=dl mbps\=5    0.01s
...    trf_data_start ue\=4 pdu\=1 qfi\=1 dir\=ul mbps\=1    0.01s
...    trf_data_start ue\=4 pdu\=1 qfi\=1 dir\=dl mbps\=1    0.01s
...    trf_data_start ue\=5 pdu\=1 qfi\=1 dir\=ul mbps\=5    0.01s
...    trf_data_start ue\=5 pdu\=1 qfi\=1 dir\=dl mbps\=5    1s
...    trf_data_stop ue\=2 pdu\=1 qfi\=1    2s
...    ue_deregister id\=2 ue_deregister_type\=switch_off    2s
...    ue_register id\=2    1s
...    set_pdu_param ue\=2 pdu\=1 trf_type\=internal    1s
...    ue_pdu_session_setup pdu\=1 ue\=2 nwslice\=3    1s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul mbps\=5    0.01s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl mbps\=5    1s
...    bler_testmode_nr profile_id\=1 ul_bler\=100,500,0,0,0,0,0,0 pdcch_misd_rate\=10    0.01s
...    ue_testmode_set_nr id\=2 testmode\=bler profile_id\=1 action\=activate    0.01s
...    ue_testmode_set_nr id\=5 testmode\=bler profile_id\=1 action\=activate    0.01s
...    trf_data_stop ue\=1 pdu\=1    0.01s
...    trf_data_stop ue\=2 pdu\=1 qfi\=1    0.01s
...    trf_data_stop ue\=3 pdu\=1 qfi\=1    0.01s
...    trf_data_stop ue\=4 pdu\=1 qfi\=1    0.01s
...    trf_data_stop ue\=5 pdu\=1 qfi\=1    0.01s
...    ue_testmode_set_nr id\=2 testmode\=bler profile_id\=1 action\=deactivate    0.01s
...    ue_testmode_set_nr id\=5 testmode\=bler profile_id\=1 action\=deactivate    0.01s
...    ue_deregister id\=1 ue_deregister_type\=switch_off    0.01s
...    ue_deregister id\=2 ue_deregister_type\=switch_off    0.01s
...    ue_deregister id\=3 ue_deregister_type\=switch_off    0.01s
...    ue_deregister id\=4 ue_deregister_type\=switch_off    0.01s
...    ue_deregister id\=5 ue_deregister_type\=switch_off    10s

#For D202
&{D202_COMMON_VARIABLES}    SCFC_NAME=D_202.xml    AIRPHONE_NAME=D_202_ap.xml    WTS_NAME=D_202_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=D_bts_swconfig.txt    AP_SWCONFIG_NAME=D_ap_swconfig.txt

#For D204
&{D204_COMMON_VARIABLES}    SCFC_NAME=D_204.xml    AIRPHONE_NAME=D_204_ap.xml    WTS_NAME=D_204_wts.cfg
...    GNBCUTYPE=${EMPTY}    GNB_SWCONFIG_NAME=D_bts_swconfig.txt    AP_SWCONFIG_NAME=D_ap_swconfig.txt

#For H304
&{H304_COMMON_VARIABLES}    SCFC_NAME=H_304.xml    AIRPHONE_NAME=H_304_ap.xml    WTS_NAME=H_304_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=H_bts_swconfig.txt    AP_SWCONFIG_NAME=H_ap_swconfig.txt
@{H_304_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_attach id\=51    1s
...    ue_dc_enb_start ue\=51 target_gnb\=2 target_cells\=11 bearer\=2 type\=split_scg    1s
...    trf_data_start ue\=51 id\=2 dir\=ul mbps\=10 trf_id\=1    1s
...    bearer_add ue\=51 id\=3 filter\=0 precedence\=7 proto\=17    0.5s
...    enb_ue_dc_modify ue\=51 bearer_to_add\=3 by\=enb cause\=RN_action_desirable_for_radio_reasons    0.5s
...    trf_data_start ue\=51 id\=3 dir\=ul mbps\=30 trf_id\=1    0.5s
...    csi_override_testmode_nr profile_id\=1 cqi\=12 cqi_mode\=fixed cqi_min\=1 cqi_max\=15 ri_mode\=fixed ri\=0    0.5s
...    ue_testmode_set_nr id\=51 profile_id\=1 action\=activate testmode\=csi_override scell\=8    0.5s
...    csi_override_testmode_nr profile_id\=1 cqi\=7 cqi_mode\=fixed cqi_min\=1 cqi_max\=15 ri_mode\=fixed ri\=0    0.5s
...    csi_override_testmode_nr profile_id\=1 cqi\=4 cqi_mode\=fixed cqi_min\=1 cqi_max\=15 ri_mode\=fixed ri\=0    0.5s
...    enb_ue_dc_modify ue\=51 bearer_to_release\=2 by\=enb cause\=RN_normal_release    0.5s
...    csi_override_testmode_nr profile_id\=1 cqi\=7 cqi_mode\=fixed cqi_min\=1 cqi_max\=15 ri_mode\=fixed ri\=0    0.5s
...    csi_override_testmode_nr profile_id\=1 cqi\=4 cqi_mode\=fixed cqi_min\=1 cqi_max\=15 ri_mode\=fixed ri\=0    0.5s
...    ue_testmode_set_nr id\=51 testmode\=csi_override profile_id\=1 action\=deactivate    0.5s
...    trf_data_stop ue\=51    1s
...    ue_detach id\=51    10s

#For H310
&{H310_COMMON_VARIABLES}    SCFC_NAME=H_310.xml    AIRPHONE_NAME=H_310_ap.xml    WTS_NAME=H_310_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=H_bts_swconfig.txt    AP_SWCONFIG_NAME=H_ap_swconfig.txt
@{H_310_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    set_pdu_param ue\=1 pdu\=1 trf_type\=internal    1s
...    ue_register id\=1    1s
...    ue_pdu_session_setup pdu\=1 ue\=1    1s
...    ue_register id\=2    1s
...    set_pdu_param ue\=2 pdu\=1 trf_type\=internal    1s
...    ue_pdu_session_setup pdu\=1 ue\=2    1s
...    bler_testmode_nr profile_id\=1 ul_bler\=100,600,700,800 dl_bler\=100,400,500,600 pdcch_misd_rate\=100    1s
...    ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=activate    1s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=10 trf_id\=1    1s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=5    1s
...    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=5 trf_id\=1    1s
...    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul mbps\=5    1s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl mbps\=10 trf_id\=1    1s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul mbps\=5    1s
...    ue_testmode_set_nr id\=1 testmode\=bler action\=deactivate profile_id\=1    1s
...    trf_data_stop ue\=2 pdu\=1 qfi\=1    1s
...    trf_data_stop ue\=1 pdu\=1 qfi\=1    1s
...    ue_pdu_session_release ue\=2 pdu\=1 by\=amf    1s
...    ue_deregister id\=2 ue_deregister_type\=switch_off    1s
...    ue_pdu_session_release ue\=1 pdu\=1 by\=amf    1s
...    ue_deregister id\=1 ue_deregister_type\=switch_off    1s

#For H312
&{H312_COMMON_VARIABLES}    SCFC_NAME=H_312.xml    AIRPHONE_NAME=H_ap.xml    WTS_NAME=H_312_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=H_bts_swconfig.txt    AP_SWCONFIG_NAME=H_ap_swconfig.txt
@{H_312_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_register id\=1    1s
...    set_pdu_param ue\=1 pdu\=1 trf_type\=internal    1s
...    ue_register id\=2    1s
...    set_pdu_param ue\=2 pdu\=1 trf_type\=internal    1s
...    ue_register id\=3    1s
...    set_pdu_param ue\=3 pdu\=1 trf_type\=internal    1s
...    ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1    1s
...    ue_pdu_session_setup pdu\=1 ue\=2 nwslice\=1 gw\=1    1s
...    ue_pdu_session_setup pdu\=1 ue\=3 nwslice\=1 gw\=1    1s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=175    0.1s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=1 mbps\=175    0.1s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=175    0.1s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl trf_id\=1 mbps\=175    0.1s
...    trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=175    0.1s
...    trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=dl trf_id\=1 mbps\=175    1s
...    trf_data_stop ue\=1 pdu\=1 qfi\=1    0.1s
...    trf_data_stop ue\=2 pdu\=1 qfi\=1    0.1s
...    trf_data_stop ue\=3 pdu\=1 qfi\=1    0.1s
...    ue_deregister id\=1 ue_deregister_type\=switch_off    0.1s
...    ue_deregister id\=2 ue_deregister_type\=switch_off    0.1s
...    ue_deregister id\=3 ue_deregister_type\=switch_off    10s

*** Test Cases ***
CB012724-B_103_num_of_slots_for_PDSCH_per_PMQAP_multiUE_HARQ_DTX_NACK
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/10/17 10:39
    [Tags]    B_103
    Airphone Set Common Test Variables    common_variables=${B103_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    B103 Need Retry

CB012724-B_106_num_of_slots_scheduled_PUSCH_per_PMQAP_multi_NSA_UE_HARQ_DTX_NACK
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/24 10:37
    [Tags]    B_106
    Airphone Set Common Test Variables    common_variables=${B106_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    B106 Need Retry

CB012724-B_108_num_of_UEs_scheduled_PUSCH_per_slot_per_PMQAP_HARQ_DTX_NACK
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/30 10:52
    [Tags]    B_108
    Airphone Set Common Test Variables    common_variables=${B108_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    B108 Need Retry

CB012724-D_202_max_num_of_UE_and_DRB_in_BB_Pool_intra_gnb_CA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/29 13:13
    [Tags]    D_202
    Airphone Set Common Test Variables    common_variables=${D202_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    D202 Need Retry

CB012724-D_204_FR2_max_num_of_UE_and_DRB_in_BB_Pool_NR_DC_Cell
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/29 13:13
    [Tags]    D_204
    Airphone Set Common Test Variables    common_variables=${D204_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    D204 Need Retry

CB012724-H_304_FR1_FDD_NSA_UL_grant_HARQ_ACK_BWP1_BR_HR_switch_with_HR_DRB_add_release
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/15 15:36
    [Tags]    H_304
    Airphone Set Common Test Variables    common_variables=${H304_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    H304 Need Retry

CB012724-H_310_FR2_TDD_SA_DL_UL_grant_HARQ_ACK_NACK_DTX_without_DynamicAL
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/17 14:29
    [Tags]    H_310
    Airphone Set Common Test Variables    common_variables=${H310_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    H310 Need Retry

CB012724-H_312_RedCap_2RX_UL_CCE_Usage_counter_verfiy_for_TDD_Cell_BW_100M
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/18 15:04
    [Tags]    H_312
    Airphone Set Common Test Variables    common_variables=${H312_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    H312 Need Retry

*** Keywords ***
B103 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/10/17 10:40
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    wait_until_next_5_min    extra_sleep_time=60
    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=1
    Batch Execute AP CMDS With Sleep Time    ${B_103_AP_CMDS_WITH_SLEEP_TIME_STEP1}

    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${except_counters}    cal_DATA_SLOT_PDSCH_PMQAP_For_B103    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv

    # check counter
    Check Counters For B103    ${except_counters}

    wait_until_next_5_min    extra_sleep_time=60
    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=1
    Batch Execute AP CMDS With Sleep Time    ${B_103_AP_CMDS_WITH_SLEEP_TIME_STEP2}

    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${except_counters}    cal_DATA_SLOT_PDSCH_PMQAP_For_B103    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv

    # check counter
    Check Counters For B103    ${except_counters}

B106 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/20 13:35
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    wait_until_next_5_min    extra_sleep_time=60
    Start GNB Ttitrace With Streaming Mode UL    lcr_cell_id=1
    airphone_execute_egate_command    script file\=${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/B_106.lua
    Sleep    60s

    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${except_counters}    cal_DATA_SLOT_PUSCH_PMQAP    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv

    # check counter
    Check Counters For B106    ${except_counters}

B108 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/30 11:02
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    wait_until_next_5_min
    Start GNB Ttitrace With Streaming Mode UL    lcr_cell_id=11
    Batch Execute AP CMDS With Sleep Time    ${B_108_AP_CMDS_WITH_SLEEP_TIME_STEP1}

    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${except_counters}    cal_DATA_SLOT_PUSCH_PMQAP_For_B108    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv

    # check counter
    Check Counters For B108    ${except_counters}

D202 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/10/22 11:19
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Run    sudo ip addr add 10.0.2.91/24 dev eth3
    Run    sudo ip addr add 10.0.1.123/24 dev eth3
    Run    sudo ip addr add 10.0.1.122/24 dev eth3
    Run    sudo ip addr add 10.0.2.90/24 dev eth3
    Run    sudo ip addr add 10.0.1.30/24 dev eth3
    Prepare gnb onair

    wait_until_next_5_min    extra_sleep_time=60
    airphone_execute_egate_command    script file\=${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/D_202.lua

    Check Counters For D202

D204 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/30 14:06
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    airphone_execute_egate_command    script file\=${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/D_204_1.lua
    Sleep    80s
    Wait Until Keyword Succeeds    30x    2s    airphone_measurement_send_nr    id=12    meas_id=3
    ...    event=A4    report_type=event_triggered    srsrp_nr=10
    ...    phycell_id=52    nrsrp_nr=50    pass_regexp=measResultNeighCells measResultListNR
    Wait Until Keyword Succeeds    30x    2s    airphone_measurement_send_nr    id=13-16    meas_id=5
    ...    event=A4    report_type=event_triggered    srsrp_nr=10
    ...    phycell_id=52    nrsrp_nr=50    pass_regexp=measResultNeighCells measResultListNR
    Wait Until Keyword Succeeds    30x    2s    airphone_measurement_send_nr    id=17-23    meas_id=8
    ...    event=A4    report_type=event_triggered    srsrp_nr=10
    ...    phycell_id=53    nrsrp_nr=50    pass_regexp=measResultNeighCells measResultListNR
    Check Counters For D204    BBPOOL1_M55207C00005=14    BBPOOL1_M55207C00006=2    BBPOOL1_M55207C00007=14
    ...        BBPOOL2_M55207C00005=12    BBPOOL2_M55207C00006=0    BBPOOL2_M55207C00007=12

    airphone_execute_egate_command    script file\=${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/D_204_2.lua
    wait_until_next_5_min    extra_sleep_time=60
    Check Counters For D204    BBPOOL1_M55207C00005=14    BBPOOL1_M55207C00006=2    BBPOOL1_M55207C00007=14
    ...        BBPOOL2_M55207C00005=10    BBPOOL2_M55207C00006=0    BBPOOL2_M55207C00007=10

    airphone_execute_egate_command    script file\=${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/D_204_3.lua
    Wait Until Keyword Succeeds    60x    2s    airphone_measurement_send_nr    id=24-26    meas_id=4
    ...    event=A4    report_type=event_triggered    srsrp_nr=10
    ...    phycell_id=53    nrsrp_nr=50    pass_regexp=measResultNeighCells measResultListNR
    wait_until_next_5_min    extra_sleep_time=60
    Check Counters For D204    BBPOOL1_M55207C00005=10    BBPOOL1_M55207C00006=1    BBPOOL1_M55207C00007=10
    ...        BBPOOL2_M55207C00005=8    BBPOOL2_M55207C00006=0    BBPOOL2_M55207C00007=8

    airphone_execute_egate_command    script file\=${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/D_204_4.lua
    Wait Until Keyword Succeeds    60x    2s    airphone_measurement_send_nr    id=13-16    meas_id=3
    ...    event=A4    report_type=event_triggered    srsrp_nr=10
    ...    phycell_id=52    nrsrp_nr=50    pass_regexp=measResultNeighCells measResultListNR
    wait_until_next_5_min    extra_sleep_time=60
    Check Counters For D204    BBPOOL1_M55207C00005=16    BBPOOL1_M55207C00006=1    BBPOOL1_M55207C00007=16
    ...        BBPOOL2_M55207C00005=12    BBPOOL2_M55207C00006=0    BBPOOL2_M55207C00007=12

H304 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/17 10:55
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=11
    Batch Execute AP CMDS With Sleep Time    ${H_304_AP_CMDS_WITH_SLEEP_TIME_STEP1}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${M55335C00034}    ${M55335C00034_DTX}    check_dtx_cellBwpId    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv

    Check Counters For H304    M55335C00034=${M55335C00034}    M55335C00034_DTX=${M55335C00034_DTX}

H310 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/18 16:50
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    wait_until_next_5_min    extra_sleep_time=60
    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=1
    Batch Execute AP CMDS With Sleep Time    ${H_310_AP_CMDS_WITH_SLEEP_TIME_STEP1}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${M55335C00034}    ${M55335C03003}    check_dtx_cellBwpId    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv
    ${M55335C00043_44}    ${M55335C03008}    check_dtx_dl    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv

    Check Counters For H310    M55335C00034=${M55335C00034}    M55335C03003=${M55335C03003}
    ...    M55335C00043_44=${M55335C00043_44}    M55335C03008=${M55335C03008}

H312 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/20 13:35
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    wait_until_next_5_min
    # collect dcap syslog and l2-ps tti
    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}    is_ute_cloud=True
    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=1

    # trigger case
    Batch Execute AP CMDS With Sleep Time    ${H_312_AP_CMDS_WITH_SLEEP_TIME_STEP1}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode

    # get ue rnti list
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE   unzip=TRUE
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE/egate_console.log.001   crnti: (\\d+)

    # analysis l2-ps ul tti csv
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${ue1_ue2}    ${sum}    check_dciFormat_cellBwpId
    ...    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    rnti_list=${rnti_list}

    # check syslog
    #Check Syslog For H312

    # check counter
    Check Counters For H312    M55335C00066=${ue1_ue2}    M55335C10001=${sum}

Batch Execute AP CMDS With Sleep Time
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/30 13:27
    [Arguments]    ${cmd_list}
    FOR    ${cmd}    ${wait_time}    IN    @{cmd_list}
        airphone_execute_egate_command    ${cmd}
        Sleep    ${wait_time}
    END

Start GNB Ttitrace With Streaming Mode
    [Arguments]     ${lcr_cell_id}=All    ${up_sw}=L2Ps     ${name}=l2stream3
    [Documentation]    This keyword will collect gnb ttitrace log.
    ...    | Input Parameters | Man. | Description |
    ...    | ${lcr_cell_id} | No | lcr cell id, it can be like 1 or 1,2 or ALL. The default value is ALL. |
    ...    | ${up_sw}       | No | option for capture. Default value is "L2Ps". It can be "L2Ps", "L2Lo", "L2iPdcp", "L2HiRlc"  |
    ...    | ${name}        | No | It can be the same as alias. The default value is l2stream3 |
    ...    Examples(BTS should be Onair and UE attach and data transfer is started. ):
    ...    | Start GNB Ttitrace With Streaming Mode | lcr_cell_id=1,2  | name=myttitrace |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} | name=myttitrace |
    ...    or
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
	&{asik_vm}=         Create Dictionary
	...    host=${GNB.ip}
	...    user=Nemuadmin
	...    password=nemuuser
	...    port=443
	...    release=${sw_list[0]}
	${scfc_on_gnb_now}=    common_gnb.Backup Scf     ${test_log_directory()}      scfc_for_tti.xml
	${lcr_cell_id}=     String.Convert To Upper Case       ${lcr_cell_id}
	${nr_phy_cell_ids}=    Run Keyword If     '${lcr_cell_id}'=='ALL'    _Get All PhysCellId In GNB    ${scfc_on_gnb_now}
	...    ELSE    _Get PhysCellId In GNB By LcrdId    ${scfc_on_gnb_now}    ${lcr_cell_id}
	${local_ip_addr}=    _Get localIpAddr Of GNB      ${scfc_on_gnb_now}
	${eth_port}    ${eth_ip}=      _Get EIF Info From Control PC
  @{event_filter_list}    Create List    ULFDSCHEDDATA
    ${l2_stream_config_1}=    Create Dictionary       nr_phy_cell_ids=${nr_phy_cell_ids}     up_sw=${up_sw}    profile_filter_list=PDCCH
    # event_filter_list=ULFDSCHEDDATA
    @{l2_stream_configuration}=    Create List    ${l2_stream_config_1}
	TCPDUMP.Create Tcpdump Collector
	...  name=tcpdump
	...  options=-i ${eth_port} udp and dst ${eth_ip} and dst port 5678
	...  sudo_password=ute
	L2STREAM3.Create Sbts L2stream Collector
	...  name=${name}
	...  destination_ip_addr=${eth_ip}
	...  collector=tcpdump
	...  l2_stream_configuration=${l2_stream_configuration}
	...  webservice=${asik_vm}
    ...  dscp=15
    L2STREAM3.Set Suite Alias    alias=${name}
    CORE.setup_collectors    names=${name}
    CORE.start_collectors    names=${name}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${scfc_on_gnb_now}

Start GNB Ttitrace With Streaming Mode UL
    [Arguments]     ${lcr_cell_id}=All    ${up_sw}=L2Ps     ${name}=l2stream3
    [Documentation]    This keyword will collect gnb ttitrace log.
    ...    | Input Parameters | Man. | Description |
    ...    | ${lcr_cell_id} | No | lcr cell id, it can be like 1 or 1,2 or ALL. The default value is ALL. |
    ...    | ${up_sw}       | No | option for capture. Default value is "L2Ps". It can be "L2Ps", "L2Lo", "L2iPdcp", "L2HiRlc"  |
    ...    | ${name}        | No | It can be the same as alias. The default value is l2stream3 |
    ...    Examples(BTS should be Onair and UE attach and data transfer is started. ):
    ...    | Start GNB Ttitrace With Streaming Mode | lcr_cell_id=1,2  | name=myttitrace |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} | name=myttitrace |
    ...    or
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
	&{asik_vm}=         Create Dictionary
	...    host=${GNB.ip}
	...    user=Nemuadmin
	...    password=nemuuser
	...    port=443
	...    release=${sw_list[0]}
	${scfc_on_gnb_now}=    common_gnb.Backup Scf     ${test_log_directory()}      scfc_for_tti.xml
	${lcr_cell_id}=     String.Convert To Upper Case       ${lcr_cell_id}
	${nr_phy_cell_ids}=    Run Keyword If     '${lcr_cell_id}'=='ALL'    _Get All PhysCellId In GNB    ${scfc_on_gnb_now}
	...    ELSE    _Get PhysCellId In GNB By LcrdId    ${scfc_on_gnb_now}    ${lcr_cell_id}
	${local_ip_addr}=    _Get localIpAddr Of GNB      ${scfc_on_gnb_now}
	${eth_port}    ${eth_ip}=      _Get EIF Info From Control PC
  @{event_filter_list}    Create List    ULFDSCHEDDATA    ULPDUDEMUXDATA
  @{profile_filter_list}    Create List    PUCCH
    ${l2_stream_config_1}=    Create Dictionary       nr_phy_cell_ids=${nr_phy_cell_ids}     up_sw=${up_sw}
    ...    event_filter_list=${event_filter_list}    profile_filter_list=${profile_filter_list}
#     event_filter_list=ULFDSCHEDDATA
    @{l2_stream_configuration}=    Create List    ${l2_stream_config_1}
	TCPDUMP.Create Tcpdump Collector
	...  name=tcpdump
	...  options=-i ${eth_port} udp and dst ${eth_ip} and dst port 5678
	...  sudo_password=ute
	L2STREAM3.Create Sbts L2stream Collector
	...  name=${name}
	...  destination_ip_addr=${eth_ip}
	...  collector=tcpdump
	...  l2_stream_configuration=${l2_stream_configuration}
	...  webservice=${asik_vm}
    ...  dscp=15
    L2STREAM3.Set Suite Alias    alias=${name}
    CORE.setup_collectors    names=${name}
    CORE.start_collectors    names=${name}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${scfc_on_gnb_now}
