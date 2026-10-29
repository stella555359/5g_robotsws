# @Time    : 2025/3/31 21:27
# @Author  : Chun.li
# @Email   : chun.li@nokia-sbell.com
# @File    : CB008600.robot
# @Software: PyCharm
# @Doc     : robot for CB008600 AP TCs
*** Settings ***

Documentation
...    author: Chun Li
...    Contact: chun.li@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: CB008600:Delay-critical GBR services

Test Setup    Run Keywords    Common Suite Setup    AND    Common Test Setup
...    AND    Start DCAP Containers in UTE
Test Teardown    Run Keywords    Run Keyword And Ignore Error    Dcap Stop Trace Via Trace ID    download_trace=true
...    AND    Common Test Teardown
...    AND    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5min    5s    Verify BTS Is Onair
...    AND    Common Suite Teardown
...    AND    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file '${None}'
Force Tags    AP    CRT    SBTS00   CLOUD_5G_I_LOO_AP_LOOO
Resource    CB008600_check_counter.robot
Resource    CB008600_check_emil.robot
Library    taf.config.scf    WITH NAME    scf
Variables   assert_emil_value.py

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
@{CUSTOM_PROFILE}    cp_5g
@{CUSTOM_PROFILE_SYSLOG}    cp_5g    condor5gSyslog
@{CUSTOM_PROFILE_L2}    L2Ps_Component    L2Lo_Component    L2HiRlc_Component    L2HiPdcp_Component
${qfi1_tp}    50

#For A108
@{A_108_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_register id\=1    3s
...    set_pdu_param ue\=1 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1    3s
...    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=3 by\=amf    3s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=50    1s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=50    1s
...    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=9    1s
...    trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=ul mbps\=9    20s
@{A_108_AP_CMDS_WITH_SLEEP_TIME_STEP2}
...    trf_data_stop ue\=1 pdu\=1 qfi\=1 dir\=dl    1s
...    trf_data_stop ue\=1 pdu\=1 qfi\=1 dir\=ul    1s
...    trf_data_stop ue\=1 pdu\=1 qfi\=2 dir\=dl    1s
...    trf_data_stop ue\=1 pdu\=1 qfi\=2 dir\=ul    1s
...    ue_deregister id\=1 ue_deregister_type\=switch_off    1s
@{A_108_AP_CMDS_WITH_SLEEP_TIME_STEP3}
...    ue_register id\=2    3s
...    set_pdu_param ue\=2 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=2 nwslice\=1 gw\=2    3s
...    ue_pdu_session_modify ue\=2 pdu\=1 qosflows_to_add\=4 by\=amf    3s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl mbps\=50    1s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul mbps\=50    1s
...    trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=dl mbps\=9    1s
...    trf_data_start ue\=2 pdu\=1 qfi\=2 dir\=ul mbps\=9    20s
@{A_108_AP_CMDS_WITH_SLEEP_TIME_STEP4}
...    trf_data_stop ue\=2 pdu\=1 qfi\=1 dir\=dl    1s
...    trf_data_stop ue\=2 pdu\=1 qfi\=1 dir\=ul    1s
...    trf_data_stop ue\=2 pdu\=1 qfi\=2 dir\=dl    1s
...    trf_data_stop ue\=2 pdu\=1 qfi\=2 dir\=ul    1s
...    ue_deregister id\=2 ue_deregister_type\=switch_off    1s
@{A_108_AP_CMDS_WITH_SLEEP_TIME_STEP5}
...    ue_register id\=3    3s
...    set_pdu_param ue\=3 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=3 nwslice\=1 gw\=3    3s
...    ue_pdu_session_modify ue\=3 pdu\=1 qosflows_to_add\=5 by\=amf    3s
...    trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=dl mbps\=50    1s
...    trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=ul mbps\=50    1s
...    trf_data_start ue\=3 pdu\=1 qfi\=2 dir\=dl mbps\=9    1s
...    trf_data_start ue\=3 pdu\=1 qfi\=2 dir\=ul mbps\=9    20s
@{A_108_AP_CMDS_WITH_SLEEP_TIME_STEP6}
...    trf_data_stop ue\=3 pdu\=1 qfi\=1 dir\=dl    1s
...    trf_data_stop ue\=3 pdu\=1 qfi\=1 dir\=ul    1s
...    trf_data_stop ue\=3 pdu\=1 qfi\=2 dir\=dl    1s
...    trf_data_stop ue\=3 pdu\=1 qfi\=2 dir\=ul    1s
...    ue_deregister id\=3 ue_deregister_type\=switch_off    1s
@{A_108_AP_CMDS_WITH_SLEEP_TIME_STEP7}
...    ue_register id\=4    3s
...    set_pdu_param ue\=4 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=4 nwslice\=1 gw\=4    3s
...    ue_pdu_session_modify ue\=4 pdu\=1 qosflows_to_add\=6 by\=amf    3s
...    trf_data_start ue\=4 pdu\=1 qfi\=1 dir\=dl mbps\=50    1s
...    trf_data_start ue\=4 pdu\=1 qfi\=1 dir\=ul mbps\=50    1s
...    trf_data_start ue\=4 pdu\=1 qfi\=2 dir\=dl mbps\=9    1s
...    trf_data_start ue\=4 pdu\=1 qfi\=2 dir\=ul mbps\=9    20s
@{A_108_AP_CMDS_WITH_SLEEP_TIME_STEP8}
...    trf_data_stop ue\=4 pdu\=1 qfi\=1 dir\=dl    1s
...    trf_data_stop ue\=4 pdu\=1 qfi\=1 dir\=ul    1s
...    trf_data_stop ue\=4 pdu\=1 qfi\=2 dir\=dl    1s
...    trf_data_stop ue\=4 pdu\=1 qfi\=2 dir\=ul    1s
...    ue_deregister id\=4 ue_deregister_type\=switch_off    1s


#For A114
&{A114_COMMON_VARIABLES}    SCFC_NAME=114.xml    AIRPHONE_NAME=8600_A_ap.xml    WTS_NAME=114_wts.cfg    GNBCUTYPE=NSA
@{A_114_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_register id\=1    3s
...    set_pdu_param ue\=1 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=1    3s
...    ue_register id\=2    3s
...    set_pdu_param ue\=2 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=2    3s
...    ue_register id\=3 registration_type\=EmergencyRegistration    3s
...    set_pdu_param ue\=3 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=3 nwslice\=1 gw\=3   10s
...    ue_deregister id\=1 ue_deregister_type\=switch_off    1s
...    ue_deregister id\=2 ue_deregister_type\=switch_off    1s
...    ue_deregister id\=3 ue_deregister_type\=switch_off    1s

#For A236
&{A236_COMMON_VARIABLES}    SCFC_NAME=236.xml    AIRPHONE_NAME=8600_A_ap.xml    WTS_NAME=236_wts.cfg    GNBCUTYPE=NSA
@{A_236_AP_CMDS}
...    ue_register id\=1
...    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
...    set_pdu_param ue\=1 pdu\=2 default_qos_flow\=2 trf_type\=internal
...    ue_pdu_session_setup pdu\=1 ue\=1
...    smf_param id\=1 additional_qosflows_to_activate\=3
...    ue_pdu_session_setup pdu\=2 ue\=1 nwslice\=1 gw\=1
...    ue_deregister id\=1 ue_deregister_type\=switch_off
${BETAEC}	13
${XEC}	14
@{A_236_AP_CMDS_WITH_SLEEP_TIME_STEP2}
...    ue_register id\=1    1s
...    set_pdu_param ue\=1 pdu\=1 default_qos_flow\=2 trf_type\=internal    1s
...    ue_pdu_session_setup pdu\=1 ue\=1    1s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul period_ms\=20 size\=1200 burst\=1 seconds\=40    41s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul period_ms\=4 size\=1500 burst\=1 seconds\=2    3s
...    ue_deregister id\=1 ue_deregister_type\=switch_off    3s

#For B003
&{B003_COMMON_VARIABLES}    SCFC_NAME=B_003.xml    AIRPHONE_NAME=8600_B_003_ap.xml    WTS_NAME=B_003_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=C_103_swconfig_bts.txt    AP_SWCONFIG_NAME=B_005_swconfig_ap.txt
@{DL_GBR_PRIORITYINDEX}    ${15}
@{DL_DCGBR_PRIORITYINDEX}    ${13}
@{UL_GBR_PRIORITYINDEX}    ${16}
@{UL_DCGBR_PRIORITYINDEX}    ${12}    ${14}
@{UL_DCGBR_PRIORITYINDEX_SR}    ${12}

#For B005
&{B005_COMMON_VARIABLES}    SCFC_NAME=B_005.xml    AIRPHONE_NAME=8600_B_005_ap.xml    WTS_NAME=B_005_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=B_005_swconfig_bts.txt    AP_SWCONFIG_NAME=B_005_swconfig_ap.txt
@{B_005_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_register id\=20    3s
...    set_pdu_param ue\=20 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=20    3s
...    ue_register id\=21    3s
...    set_pdu_param ue\=21 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=21    3s
...    trf_data_start ue\=20 pdu\=1 qfi\=1 dir\=dl trf_id\=1 mbps\=175 seconds\=3600    3s
...    trf_data_start ue\=20 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=54 seconds\=3600    3s
...    trf_data_start ue\=20 pdu\=1 qfi\=1 dir\=dl mbps\=25 trf_id\=2    3s
...    trf_data_start ue\=21 pdu\=1 qfi\=1 dir\=dl trf_id\=1 mbps\=175 seconds\=3600    3s
...    trf_data_start ue\=21 pdu\=1 qfi\=1 dir\=ul trf_id\=1 mbps\=54 seconds\=3600    3s
...    trf_data_start ue\=21 pdu\=1 qfi\=1 dir\=dl mbps\=25 trf_id\=2    10s
@{B_005_AP_CMDS_WITH_SLEEP_TIME_STEP2}
...    qosflow_modify qos_flow\=9 gfbr_ul\=200 gfbr_dl\=200 mfbr_ul\=30720 mfbr_dl\=30720    5s
...    qosflow_modify qos_flow\=12 gfbr_ul\=2464 gfbr_dl\=2464 priority\=3 mfbr_ul\=2464 mfbr_dl\=2464    5s
...    qosflow_modify qos_flow\=13 gfbr_ul\=370 gfbr_dl\=370 priority\=2 mfbr_ul\=2464 mfbr_dl\=2464    5s
...    set_pdu_param ue\=22 pdu\=1 trf_type\=internal default_qos_flow\=12    5s
...    set_pdu_param ue\=23 pdu\=1 trf_type\=internal default_qos_flow\=9    5s
...    set_pdu_param ue\=24 pdu\=1 trf_type\=internal default_qos_flow\=13    5s
...    ue_register id\=22    5s
...    ue_pdu_session_setup pdu\=1 ue\=22    5s
...    trf_data_start ue\=22 pdu\=1 qfi\=1 dir\=dl kbps\=2464    5s
...    trf_data_start ue\=22 pdu\=1 qfi\=1 dir\=ul kbps\=2464    10s
@{B_005_AP_CMDS_WITH_SLEEP_TIME_STEP3}
...    ue_register id\=23    5s
...    ue_pdu_session_setup pdu\=1 ue\=23    5s
...    trf_data_start ue\=23 pdu\=1 qfi\=1 dir\=dl kbps\=100    5s
...    trf_data_start ue\=23 pdu\=1 qfi\=1 dir\=ul kbps\=100    10s
@{B_005_AP_CMDS_WITH_SLEEP_TIME_STEP4}
...    ue_register id\=24    5s
...    ue_pdu_session_setup pdu\=1 ue\=24    5s
...    trf_data_start ue\=24 pdu\=1 qfi\=1 dir\=dl kbps\=370    5s
...    trf_data_start ue\=24 pdu\=1 qfi\=1 dir\=ul kbps\=370    10s

#For C103
&{C103_COMMON_VARIABLES}    SCFC_NAME=C_103.xml    AIRPHONE_NAME=8600_B_003_ap.xml    WTS_NAME=C_103_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=C_103_swconfig_bts.txt    AP_SWCONFIG_NAME=B_005_swconfig_ap.txt

#For CA111
&{CA111_COMMON_VARIABLES}    SCFC_NAME=CA_111.xml    AIRPHONE_NAME=8600_B_005_ap.xml    WTS_NAME=CA_111_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=CA_111_swconfig_bts.txt    AP_SWCONFIG_NAME=CA_111_swconfig_ap.txt
@{C_111_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_register id\=1    3s
...    set_pdu_param ue\=1 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=1    3s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl period_ms\=10 size\=64 burst\=1 seconds\=10 trf_id\=1    3s
...    bearer_stats ue\=1 pdu\=1 qfi\=1 dir\=dl    3s
...    ue_stats_nr id\=1 type\=pdsch    3s
@{C_111_AP_CMDS_WITH_SLEEP_TIME_STEP2}
...    bler_testmode_nr profile_id\=1 dl_bler\=100    3s
...    ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=activate    3s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl period_ms\=10 size\=64 burst\=1 seconds\=10 trf_id\=2    3s
...    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl period_ms\=10 size\=1300 burst\=1 seconds\=5 trf_id\=3    60s
@{C_111_AP_CMDS_WITH_SLEEP_TIME_STEP3}
...    ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=deactivate    3s
...    trf_data_stop ue\=1 pdu\=1 qfi\=1    3s
...    ue_deregister id\=1 ue_deregister_type\=switch_off    3s


#For CA112
&{CA112_COMMON_VARIABLES}    SCFC_NAME=CA_112.xml    AIRPHONE_NAME=CA_112_ap.xml    WTS_NAME=CA_112_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=CA_112_swconfig_bts.txt    AP_SWCONFIG_NAME=B_005_swconfig_ap.txt

#For CA114
&{CA114_COMMON_VARIABLES}    SCFC_NAME=CA_114.xml    AIRPHONE_NAME=CA_112_ap.xml    WTS_NAME=CA_114_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=CA_111_swconfig_bts.txt    AP_SWCONFIG_NAME=CA_111_swconfig_ap.txt
@{C_114_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_register id\=2    3s
...    set_pdu_param ue\=2 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=2    3s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl period_ms\=10 size\=1300 burst\=1 seconds\=20    23s
...    ue_deregister id\=2 ue_deregister_type\=switch_off    3s
@{C_114_AP_CMDS_WITH_SLEEP_TIME_STEP2}
...    ue_register id\=2    3s
...    set_pdu_param ue\=2 pdu\=1 trf_type\=internal    3s
...    ue_pdu_session_setup pdu\=1 ue\=2    3s
...    bler_testmode_nr profile_id\=1 dl_bler\=100,100,100 pdcch_misd_rate\=100    3s
...    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=activate    3s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl period_ms\=10 size\=1300 burst\=1 seconds\=20    23s
...    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=deactivate    3s
...    ue_deregister id\=2 ue_deregister_type\=switch_off    3s

#For CA119
&{CA119_COMMON_VARIABLES}    SCFC_NAME=CA_119.xml    AIRPHONE_NAME=CA_112_ap.xml    WTS_NAME=CA_119_wts.cfg
...    GNBCUTYPE=NSA    GNB_SWCONFIG_NAME=CA_111_swconfig_bts.txt    AP_SWCONFIG_NAME=CA_111_swconfig_ap.txt
@{C_119_AP_CMDS_WITH_SLEEP_TIME_STEP1}
...    ue_register id\=2    1s
...    set_pdu_param ue\=2 pdu\=1 trf_type\=internal    1s
...    ue_pdu_session_setup pdu\=1 ue\=2    1s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul period_ms\=20 size\=1200 burst\=1 seconds\=40    41s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul period_ms\=4 size\=1500 burst\=1 seconds\=2    3s
...    ue_deregister id\=2 ue_deregister_type\=switch_off    3s
@{C_119_AP_CMDS_WITH_SLEEP_TIME_STEP2}
...    ue_register id\=2    1s
...    set_pdu_param ue\=2 pdu\=1 trf_type\=internal    1s
...    ue_pdu_session_setup pdu\=1 ue\=2    1s
...    bler_testmode_nr profile_id\=1 ul_bler\=300,200,200,200,300,1000 pdcch_misd_rate\=100    0.3s
...    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=activate    0.3s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul period_ms\=20 size\=1200 burst\=1 seconds\=40    41s
...    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul period_ms\=4 size\=1500 burst\=1 seconds\=2    3s
...    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=deactivate    3s
...    ue_deregister id\=2 ue_deregister_type\=switch_off    3s

*** Test Cases ***
CB008600-A_108_PMO#B3_Counter Behaviour for Successful setup of DC-GBR Bearer on the reception of NGAP_PDUSessionResourceModifyRequest
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Init Define: 2025/04/02 10:30 p
    [Tags]    108
    Wait Until Keyword Succeeds    3x    15s    A108 Need Retry

CB008600-A_114_PMO#B5_Counter Behaviour for Successful setup of emergency DC-GBR Bearer on reception of NGAP_InitialContextSetupRequest
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Init Define: 2025/04/15 16:55 p
    [Tags]    114
    Airphone Set Common Test Variables    common_variables=${A114_COMMON_VARIABLES}
    Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001

    Wait Until Keyword Succeeds    3x    15s    A114 Need Retry

CB008600-A_236_Counter Behaviour for Successful setup of higher priority DC-GBR
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/23 16:57
    [Tags]    236
    # add step for 72e after 26R1, 2025/09/04 9:58 by jian
    Run Keyword If    '${SW_BRANCH}'>'SBTS25R3'
    ...    Set To Dictionary    ${A236_COMMON_VARIABLES}    AIRPHONE_NAME    236_ap.xml
    # add step for 72e after 26R1, 2025/09/04 9:58 by jian

    Airphone Set Common Test Variables    common_variables=${A236_COMMON_VARIABLES}
    Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001

    Wait Until Keyword Succeeds    3x    15s    A236 Need Retry

CB008600-A_237_Counter Behaviour for Unsuccessful setup of DC-GBR bearer due to reception of MDBV value greater than 1400 bytes
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Init Define: 2025/04/15 16:55 p
    [Tags]    237
    Set Test Variable    ${SCFC_NAME}            237.xml
    Set Test Variable    ${AIRPHONE_NAME}        8600_A_ap.xml
    Set Test Variable    ${WTS_NAME}             237_wts.cfg
    Set Test Variable    ${tc237_counters}    M55125C08501,M55125C08502,M55125C09011,M55125C09012,M55163C00001,M55163C00002,M55163C00511,M55163C00512
    Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Airphone SA Attach    ue_id=1
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    Airphone Pdu Session Setup    1    1    1    1
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=2 default_qos_flow\=2 trf_type\=internal
    airphone_execute_egate_command    ue_pdu_session_setup pdu\=2 ue\=1 nwslice\=1 gw\=1

    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=${qfi1_tp}
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=${qfi1_tp}
    Sleep    20s
    #To Check DL/UL traffic From AP
    Verify DL and UL traffic is normal From AP    ue_id=1    pdu_id=1    qfi_id=1    expect_tput=${qfi1_tp}
    Airphone SA Stop Data Traffic    ue_id=1    direction=DL    pdu_id=1
    Airphone SA Stop Data Traffic    ue_id=1    direction=UL    pdu_id=1
    Airphone SA Detach    1

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=${tc237_counters}
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NNGCC']}
    Should Be True    ${counter_values['M55125C08501']}==2
    Should Be True    ${counter_values['M55125C08502']}==1
    Should Be True    ${counter_values['M55125C09011']}==0    #NG_FLOW_SETUP_FAIL_UNSPECIFIED
    Should Be True    ${counter_values['M55125C09012']}==1    #NG_FLOW_SETUP_FAIL_WRONG_MSG
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-10']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1
    Should Be True    ${counter_values['M55163C00002']}==1
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-7']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1
    Should Be True    ${counter_values['M55163C00511']}==0    #NG_FLOW_SETUP_FAIL_UNSPC_PMQAP
    Should Be True    ${counter_values['M55163C00512']}==1    #NG_FLOW_STP_FAIL_WRG_MSG_PMQAP

CB008600-A_239_Counter Behaviour for Unsuccessful setup of DC-GBR bearer due to matching NRDRB_5QI MOC not being configured, multiple PDU sessions
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Init Define: 2025/04/15 16:55 p
    [Tags]    239
    Set Test Variable    ${SCFC_NAME}            239.xml
    Set Test Variable    ${AIRPHONE_NAME}        8600_A_ap.xml
    Set Test Variable    ${WTS_NAME}             239_wts.cfg
    Set Test Variable    ${tc239_counters}    M55125C08501,M55125C08502,M55163C00001,M55163C00002,M55163C00512,M55125C09012
    Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Airphone SA Attach    ue_id=1
    airphone_execute_egate_command    amf_ue_pdu_setup_param id\=1 action\=delay_till_next_pdu_setup
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    airphone_execute_egate_command    ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=2 default_qos_flow\=2 trf_type\=internal
    Airphone Pdu Session Setup    1    2    1    1

    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=2 qfi\=1 dir\=dl mbps\=${qfi1_tp}
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=2 qfi\=1 dir\=ul mbps\=${qfi1_tp}
    Sleep    20s
    #To Check DL/UL traffic From AP
    Verify DL and UL traffic is normal From AP    ue_id=1    pdu_id=2    qfi_id=1    expect_tput=${qfi1_tp}
    Airphone SA Stop Data Traffic    ue_id=1    direction=DL    pdu_id=2
    Airphone SA Stop Data Traffic    ue_id=1    direction=UL    pdu_id=2
    Airphone SA Detach    1

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=${tc239_counters}
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NNGCC']}
    Should Be True    ${counter_values['M55125C08501']}==2
    Should Be True    ${counter_values['M55125C08502']}==1
    Should Be True    ${counter_values['M55125C09012']}==1
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-3']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1
    Should Be True    ${counter_values['M55163C00002']}==1
    ${counter_values}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRPMQAP-6']['NGCCQ']}
    Should Be True    ${counter_values['M55163C00001']}==1
    Should Be True    ${counter_values['M55163C00512']}==1

CB008600-B_003_B2_the scheduling priority of Single DC-GBR UE with 5QI-82 is over multiple GBR UEs under TDD cell
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Init Define: 2025/04/26
    [Tags]    B_003
    Airphone Set Common Test Variables    common_variables=${B003_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    B003 Need Retry

CB008600-B_005_B4_scheduling for multiple DC-GBR UEs and multiple non-GBR UEs concurrently
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Init Define: 2025/04/26
    [Tags]    B_005
    Airphone Set Common Test Variables    common_variables=${B005_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    5x    15s    B005 Need Retry

CB008600-C_103_Flow_Control_for_multi_UEs_with_DC-GBR_or_GBR
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Init Define: 2025/04/26
    [Tags]    C_103
    Airphone Set Common Test Variables    common_variables=${C103_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    C103 Need Retry

CB008600-CA_111_DL_PDCP_Layer_Counters_Verification
    [Documentation]    Author:
    ...    Init Define: 2025/05/14
    [Tags]    CA_111
    Airphone Set Common Test Variables    common_variables=${CA111_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    CA111 Need Retry

CB008600-CA_112_DL_F1_Interface_Counters_Verification
    [Documentation]    Author:
    ...    Init Define: 2025/06/10
    [Tags]    CA_112
    Airphone Set Common Test Variables    common_variables=${CA112_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    3x    15s    CA112 Need Retry

CB008600-CA_114_DL_RLC_MAC_Layer_Counters_Verification_for_Large_Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/17 15:35
    [Tags]    CA_114
    Airphone Set Common Test Variables    common_variables=${CA114_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    10x    15s    CA114 Need Retry

CB008600-CA_119_UL_L2_Counters_Verification_for_Large_Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/17 15:35
    [Tags]    CA_119
    Airphone Set Common Test Variables    common_variables=${CA119_COMMON_VARIABLES}    need_swconfig=True

    Wait Until Keyword Succeeds    5x    15s    CA119 Need Retry

*** Keywords ***
Batch Execute AP CMDS
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/20 14:22
    [Arguments]    ${cmd_list}    ${wait_time}=3s
    FOR    ${cmd}    IN    @{cmd_list}
        airphone_execute_egate_command    ${cmd}
        Sleep    ${wait_time}
    END

Batch Execute AP CMDS With Sleep Time
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/30 13:27
    [Arguments]    ${cmd_list}
    FOR    ${cmd}    ${wait_time}    IN    @{cmd_list}
        airphone_execute_egate_command    ${cmd}
        Sleep    ${wait_time}
    END

Check Syslog For F201
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/12 17:23
    ${results}    get_switched_bwp_type_timestamp    syslog_file=${SYSLOG_FILE}
    ${switched_bwptype_list}    Get Dictionary Values    ${results}
    Lists Should Be Equal    ${switched_bwptype_list[-5:]}    ${F201_EXPECTED_BWP_TYPE_LIST}
    ${switched_bwptype_timestamp_list}    Get Dictionary Keys    ${results}
    [Return]    ${switched_bwptype_timestamp_list}

C103 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/08 10:04
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    wait_until_next_5_min
    Airphone SA Attach    ue_id=22
    Airphone SA Attach    ue_id=23
    airphone_execute_egate_command    set_pdu_param ue\=22 pdu\=1 trf_type\=internal
    airphone_execute_egate_command    set_pdu_param ue\=23 pdu\=1 trf_type\=internal
    airphone_execute_egate_command    ue_pdu_session_setup pdu\=1 ue\=22
    airphone_execute_egate_command    ue_pdu_session_modify ue\=22 pdu\=1 qosflows_to_add\=22 by\=amf
    airphone_execute_egate_command    ue_pdu_session_setup pdu\=1 ue\=23
    airphone_execute_egate_command    ue_pdu_session_modify ue\=23 pdu\=1 qosflows_to_add\=23 by\=amf

    Sleep    5s
    airphone_execute_egate_command    trf_data_start ue\=22 pdu\=1 qfi\=1 dir\=dl period_ms\=20 size\=5100 burst\=10
    airphone_execute_egate_command    trf_data_start ue\=22 pdu\=1 qfi\=1 dir\=ul period_ms\=100 size\=100 burst\=2
    airphone_execute_egate_command    trf_data_start ue\=22 pdu\=1 qfi\=2 dir\=dl period_ms\=20 size\=5100 burst\=10
    airphone_execute_egate_command    trf_data_start ue\=22 pdu\=1 qfi\=2 dir\=ul period_ms\=100 size\=100 burst\=2
    airphone_execute_egate_command    trf_data_start ue\=23 pdu\=1 qfi\=1 dir\=dl period_ms\=20 size\=5100 burst\=10
    airphone_execute_egate_command    trf_data_start ue\=23 pdu\=1 qfi\=1 dir\=ul period_ms\=100 size\=100 burst\=2
    airphone_execute_egate_command    trf_data_start ue\=23 pdu\=1 qfi\=2 dir\=dl period_ms\=20 size\=5100 burst\=10
    airphone_execute_egate_command    trf_data_start ue\=23 pdu\=1 qfi\=2 dir\=ul period_ms\=100 size\=100 burst\=2

    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}    is_ute_cloud=True
    Airphone UE SA Attach And Traffic With Period_ms    ue_id=2    period_ms=10    size=122    burst=1
    Airphone UE SA Attach And Traffic With Period_ms    ue_id=3    period_ms=10    size=650    burst=1
    Airphone UE SA Attach And Traffic With Period_ms    ue_id=4    period_ms=30    size=650    burst=1    qfi=2    default_qos_flow=4
    Airphone UE SA Attach And Traffic With Period_ms    ue_id=5    period_ms=6    size=122    burst=1    qfi=2    default_qos_flow=5
    Airphone UE SA Attach And Traffic With Period_ms    ue_id=6    period_ms=6    size=650    burst=1
    Airphone UE SA Attach And Traffic With Period_ms    ue_id=7    period_ms=6    size=250    burst=1
    Airphone UE SA Attach And Traffic With Period_ms    ue_id=8    period_ms=10    size=550    burst=1
    Airphone UE SA Attach And Traffic With Period_ms    ue_id=9    period_ms=6    size=650    burst=1
    Airphone UE SA Attach And Traffic With Period_ms    ue_id=10    period_ms=6    size=250    burst=1
    Airphone UE SA Attach And Traffic With Period_ms    ue_id=11    period_ms=10    size=550    burst=1

    Sleep    20s
    airphone_execute_egate_command    bler_testmode_nr profile_id\=1 target_mcs\=7
    Sleep    3s
    airphone_execute_egate_command    adv_bler_testmode_nr profile_id\=1 target_bler_profile_id\=1
    Sleep    3s
    airphone_execute_egate_command    target_bler\=1.1,2.1,3.1,4.1,5.1,6.1,7.1,8.1,9.1,10.1,11.1,12.1,13.1,14.1,15.1 target_mcs\=7
    Sleep    3s
    airphone_execute_egate_command    ue_testmode_set_nr id\=22-23 testmode\=bler profile_id\=1 action\=activate
    Sleep    3s
    airphone_execute_egate_command    ue_testmode_set_nr id\=2-11 testmode\=bler profile_id\=1 action\=activate
    Sleep    20s
    airphone_execute_egate_command    ue_testmode_set_nr id\=22-23 testmode\=bler profile_id\=1 action\=deactivate
    Sleep    3s
    airphone_execute_egate_command    ue_testmode_set_nr id\=2-11 testmode\=bler profile_id\=1 action\=deactivate

    Check Emil For C103
    wait_until_next_5_min    extra_sleep_time=60
    Check Counters For C103

    airphone_execute_egate_command    trf_data_stop ue\=4-5 pdu\=1 qfi\=2
    Sleep    3s
    airphone_execute_egate_command    trf_data_stop ue\=2-11,22-23 pdu\=1 qfi\=1
    Sleep    3s
    airphone_execute_egate_command    ue_pdu_session_release ue\=2-11,22-23 pdu\=1 by\=amf
    Sleep    3s
    airphone_execute_egate_command    ue_deregister id\=2-11,22-23 ue_deregister_type\=switch_off

B003 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/07 17:18
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    @{ue_list_23_24_25}    Create List    23    24    25
    Airphone Multi-UE SA Attach    ue_list=${ue_list_23_24_25}    pdu_id=1    trf_type=internal

    airphone_execute_egate_command    trf_data_start ue\=23 pdu\=1 qfi\=1 dir\=ul kbps\=2000 trf_id\=1
    Sleep   3s
    airphone_execute_egate_command    trf_data_start ue\=23 pdu\=1 qfi\=1 dir\=dl kbps\=27770 trf_id\=1
    Sleep   3s
    airphone_execute_egate_command    trf_data_start ue\=24 pdu\=1 qfi\=1 dir\=ul kbps\=2000 trf_id\=1
    Sleep   3s
    airphone_execute_egate_command    trf_data_start ue\=24 pdu\=1 qfi\=1 dir\=dl kbps\=27770 trf_id\=1
    Sleep   3s
    airphone_execute_egate_command    trf_data_start ue\=25 pdu\=1 qfi\=1 dir\=ul kbps\=2000 trf_id\=1
    Sleep   3s
    airphone_execute_egate_command    trf_data_start ue\=25 pdu\=1 qfi\=1 dir\=dl kbps\=38000 trf_id\=1
    Sleep   3s
    Sleep    10s
    ${sum_dl_tp1}    Airphone Multi-UE SA Traffic Summary    ue_list=${ue_list_23_24_25}    direction=DL
    Sleep    120s
    ${counter_before}    Check Counters For B003

    @{ue_list_26}    Create List    26
    Airphone Multi-UE SA Attach    ue_list=${ue_list_26}    pdu_id=1    trf_type=internal
    Airphone Start DL&UL Traffic    ue_id=26    dl_mbps=1    ul_mbps=1
    Sleep    10s
    @{ue_list_23_24_25_26}    Create List    23    24    25    26
    ${sum_dl_tp2}    Airphone Multi-UE SA Traffic Summary    ue_list=${ue_list_23_24_25_26}    direction=DL
    ${result}=    Is Values Close    ${sum_dl_tp1}    ${sum_dl_tp2}    10
    Should Be True    ${result}

    ${rnti_list}    Get UE Rnti List
    Sleep    20s
    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=51
    Sleep    1s
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump
    ${rnti_DC}    Get From List    ${rnti_list}    -1
    @{rnti_DC_list}    Create List    ${rnti_DC}
    ${dl_priorityIndex}    get_dl_priorityIndex    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_dl.csv    ${rnti_DC_list}
    ${ul_priorityIndex}    get_ul_priorityIndex    ${TEST_LOG_DIRECTORY()}/l2stream3/tcpdump_ul.csv    ${rnti_DC_list}

    ${except_dl_priorityIndex}    Create Dictionary    ${rnti_list[-1]}=${DL_DCGBR_PRIORITYINDEX}
    ${except_ul_priorityIndex_1}    Create Dictionary    ${rnti_list[-1]}=${UL_DCGBR_PRIORITYINDEX}
    ${except_ul_priorityIndex_2}    Create Dictionary    ${rnti_list[-1]}=${UL_DCGBR_PRIORITYINDEX_SR}
    Should Be True    ${except_dl_priorityIndex} == ${dl_priorityIndex}
    Should Be True    ${except_ul_priorityIndex_1} == ${ul_priorityIndex} or ${except_ul_priorityIndex_2} == ${ul_priorityIndex}
    ${counter_now}    Check Counters For B003

    Airphone Multi-UE SA Detach    ue_list=${ue_list_26}

    # step 4
    Sleep    120s
    ${counter_after}    Check Counters For B003
    Should Be True    ${counter_before}<${counter_now}
    Should Be True    ${counter_after}<${counter_now}

    Airphone Multi-UE SA Detach    ue_list=${ue_list_23_24_25}

B005 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/07/10 13:26
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    wait_until_next_5_min
    # Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}    is_ute_cloud=True

    Batch Execute AP CMDS With Sleep Time    ${B_005_AP_CMDS_WITH_SLEEP_TIME_STEP1}
    Airphone Verify UE DL&UL TP Normal    ue_id=20    except_dl_tp=${197.6}    except_ul_tp=${54}
    Airphone Verify UE DL&UL TP Normal    ue_id=21    except_dl_tp=${197.6}    except_ul_tp=${54}

    Batch Execute AP CMDS With Sleep Time    ${B_005_AP_CMDS_WITH_SLEEP_TIME_STEP2}
    Airphone Verify UE DL&UL TP Normal    ue_id=20    except_dl_tp=${195.3}    except_ul_tp=${53.17}    tolerance=${50}
    Airphone Verify UE DL&UL TP Normal    ue_id=21    except_dl_tp=${195.3}    except_ul_tp=${53.17}    tolerance=${50}
    Airphone Verify UE DL&UL TP Normal    ue_id=22    except_dl_tp=${2.464}    except_ul_tp=${2.464}

    Batch Execute AP CMDS With Sleep Time    ${B_005_AP_CMDS_WITH_SLEEP_TIME_STEP3}
    Airphone Verify UE DL&UL TP Normal    ue_id=20    except_dl_tp=${195.2}    except_ul_tp=${53.07}    tolerance=${50}
    Airphone Verify UE DL&UL TP Normal    ue_id=21    except_dl_tp=${195.2}    except_ul_tp=${53.07}    tolerance=${50}
    Airphone Verify UE DL&UL TP Normal    ue_id=22    except_dl_tp=${2.464}    except_ul_tp=${2.464}
    Airphone Verify UE DL&UL TP Normal    ue_id=23    except_dl_tp=${0.1}    except_ul_tp=${0.1}

    Batch Execute AP CMDS With Sleep Time    ${B_005_AP_CMDS_WITH_SLEEP_TIME_STEP4}
    Airphone Verify UE DL&UL TP Normal    ue_id=20    except_dl_tp=${194.9}    except_ul_tp=${52.7}    tolerance=${50}
    Airphone Verify UE DL&UL TP Normal    ue_id=21    except_dl_tp=${194.9}    except_ul_tp=${52.7}    tolerance=${50}
    Airphone Verify UE DL&UL TP Normal    ue_id=22    except_dl_tp=${2.464}    except_ul_tp=${2.464}
    Airphone Verify UE DL&UL TP Normal    ue_id=23    except_dl_tp=${0.1}    except_ul_tp=${0.1}
    Airphone Verify UE DL&UL TP Normal    ue_id=24    except_dl_tp=${0.37}    except_ul_tp=${0.37}

    # Check Emil For B005

    wait_until_next_5_min    extra_sleep_time=60
    Check Counters For B005

A108 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/07/31 13:08
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Set Test Variable    ${SCFC_NAME}            108.xml
    Set Test Variable    ${AIRPHONE_NAME}        8600_A_ap.xml
    Set Test Variable    ${WTS_NAME}             108_wts.cfg
    Set Test Variable    ${tc108_qfi2_tp}    9
    ${tc108_counters}    Catenate    SEPARATOR=    M55125C08501,M55125C08502,M55163C00001,M55163C00002,M55138C00075,M55138C00076,
    ...    M55138C01001,M55138C01002,M55139C00034,M55139C00035,M55139C00501,M55139C00502,M55125C03502,M55125C03501,
    ...    M55350C01002,M55350C01006,M55350C00002,M55350C00006,M55349C01002,M55349C01006,M55349C00002,M55349C00006
    Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Set Test Variable    ${GNBCUTYPE}    ${EMPTY}
    Prepare gnb onair

    wait_until_next_5_min
    Batch Execute AP CMDS With Sleep Time    ${A_108_AP_CMDS_WITH_SLEEP_TIME_STEP1}

    #To Check DL/UL traffic From AP
    Verify DL and UL traffic is normal From AP    ue_id=1    pdu_id=1    qfi_id=1    expect_tput=${qfi1_tp}
    Verify DL and UL traffic is normal From AP    ue_id=1    pdu_id=1    qfi_id=2    expect_tput=${tc108_qfi2_tp}
    Batch Execute AP CMDS With Sleep Time    ${A_108_AP_CMDS_WITH_SLEEP_TIME_STEP2}

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=${tc108_counters}
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    Check Counters For A108    counters=${counters}    dcgbr_pmqapid=6

    wait_until_next_5_min
    Batch Execute AP CMDS With Sleep Time    ${A_108_AP_CMDS_WITH_SLEEP_TIME_STEP3}

    #To Check DL/UL traffic From AP
    Verify DL and UL traffic is normal From AP    ue_id=2    pdu_id=1    qfi_id=1    expect_tput=${qfi1_tp}
    Verify DL and UL traffic is normal From AP    ue_id=2    pdu_id=1    qfi_id=2    expect_tput=${tc108_qfi2_tp}
    Batch Execute AP CMDS With Sleep Time    ${A_108_AP_CMDS_WITH_SLEEP_TIME_STEP4}

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=${tc108_counters}
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    Check Counters For A108    counters=${counters}    dcgbr_pmqapid=7

    wait_until_next_5_min
    Batch Execute AP CMDS With Sleep Time    ${A_108_AP_CMDS_WITH_SLEEP_TIME_STEP5}
    #To Check DL/UL traffic From AP
    Verify DL and UL traffic is normal From AP    ue_id=3    pdu_id=1    qfi_id=1    expect_tput=${qfi1_tp}
    Verify DL and UL traffic is normal From AP    ue_id=3    pdu_id=1    qfi_id=2    expect_tput=${tc108_qfi2_tp}
    Batch Execute AP CMDS With Sleep Time    ${A_108_AP_CMDS_WITH_SLEEP_TIME_STEP6}

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=${tc108_counters}
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    Check Counters For A108    counters=${counters}    dcgbr_pmqapid=8

    wait_until_next_5_min
    Batch Execute AP CMDS With Sleep Time    ${A_108_AP_CMDS_WITH_SLEEP_TIME_STEP7}
    #To Check DL/UL traffic From AP
    Verify DL and UL traffic is normal From AP    ue_id=4    pdu_id=1    qfi_id=1    expect_tput=${qfi1_tp}
    Verify DL and UL traffic is normal From AP    ue_id=4    pdu_id=1    qfi_id=2    expect_tput=${tc108_qfi2_tp}
    Batch Execute AP CMDS With Sleep Time    ${A_108_AP_CMDS_WITH_SLEEP_TIME_STEP8}

    wait_until_next_5_min    extra_sleep_time=60
    coam.connect_to    name=GNB_OAM
    ${counters}    coam.get_pm_counters    counter_ids=${tc108_counters}
    ...    connection=GNB_OAM
    coam.teardown    connection=GNB_OAM
    Check Counters For A108    counters=${counters}    dcgbr_pmqapid=9

A114 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/07/08 14:10
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    wait_until_next_5_min
    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}    is_ute_cloud=True
    Batch Execute AP CMDS With Sleep Time    ${A_114_AP_CMDS_WITH_SLEEP_TIME_STEP1}

    Check Emil For A114 Step1

    wait_until_next_5_min
    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}    is_ute_cloud=True

    Airphone UE SA Attach With Detach    ue_id=4    registration_type=EmergencyRegistration
    Airphone UE SA Attach With Detach    ue_id=1    registration_type=EmergencyRegistration    default_qos_flow=4
    Airphone UE SA Attach With Detach    ue_id=2    registration_type=EmergencyRegistration    default_qos_flow=5

    Check Emil For A114 Step2

    wait_until_next_5_min    extra_sleep_time=60
    Check Counters For A114

Modify Vendor 72e XML File
    [Arguments]    ${vendor_path}
    ${vendor_list72e}    Set Variable    text|${ECPRI72E}|//*[@name\="actEcpri72e"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_list72e}

Modify Vendor betaec XML File
    [Arguments]    ${vendor_path}
    ${vendor_listbetaec}    Set Variable    text|${BETAEC}|//*[@name\="betaEc"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listbetaec}

Modify Vendor xec XML File
    [Arguments]    ${vendor_path}
    ${vendor_listxec}    Set Variable    text|${XEC}|//*[@name\="xEc"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listxec}

Modify vendor file 72e and full commission for onair
    [Arguments]    ${wait_bts_timeout}=2000    ${wait_rru_timeout}=800    ${wait_onair_timeout}=800
    Modify Swconfig for AP
    Start capture gnb and ap syslog in 'before_onair' file
    Log to console     Change iphy rru version
    Change iphy rru version    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${AIRPHONE_NAME}
    Log to console         reboot ap
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
    Wait '10s' for stable
    ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}
    ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc_path}    ${test_log_directory()}/full_commission/
    Configure TL VM ETH
    TAF_ADMIN.Setup Admin
    ${vendor_path}    Set Variable    ${test_log_directory()}/vendor_ini.xml
    TAF_ADMIN.Download Vendor File    ${vendor_path}
    Modify Vendor betaec XML File    ${vendor_path}
    Modify Vendor xec XML File    ${vendor_path}
    #Modify Vendor 72e XML File    ${vendor_path}
    TAF_ADMIN.Set Vendor File    ${vendor_path}
    ${connission_status}    Run Keyword And Return Status    TAF_ADMIN.Perform Commissioning
    ...    bts_id=${GNB_IP}
    ...    scf_file=${new_scfc}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    Log to console    Full Commissioning is ${connission_status}
    TAF_ADMIN.teardown admin
    Wait '120s' for stable
    Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
    ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
    ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
    Log to console    celltesttesttest
    sleep        120s
    ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${cfg_path}
    ...    timeout=${wait_onair_timeout}
    Log to console    celltesttesttest2
    Stop capture gnb and ap syslog in 'before_onair' file
    Log To Console    BTS is onAir now
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump

A236 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/07/31 13:08
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    # add step for 72e after 26R1, 2025/09/04 9:58 by jian
    Run Keyword If    '${SW_BRANCH}'=='SBTS25R3'    Prepare gnb onair
    ...    ELSE    Modify vendor file 72e and full commission for onair
    # add step for 72e after 26R1, 2025/09/04 9:58 by jian

    wait_until_next_5_min    extra_sleep_time=60
    Dcap Start Trace Via Custom Profile    custom_profile_list=${CUSTOM_PROFILE}    is_ute_cloud=True
    Batch Execute AP CMDS    ${A_236_AP_CMDS}
    Check Emil For A236
    wait_until_next_5_min    extra_sleep_time=60
    Check Counters For A236

    # add step for 72e after 26R1, 2025/09/04 9:58 by jian
    Run Keyword If    '${SW_BRANCH}'>'SBTS25R3'    Run Keywords
    ...    Batch Execute AP CMDS With Sleep Time    ${A_236_AP_CMDS_WITH_SLEEP_TIME_STEP2}
    ...    AND    wait_until_next_5_min    extra_sleep_time=60
    ...    AND    Check Counters For A236 Step2
    # add step for 72e after 26R1, 2025/09/04 9:58 by jian

CA111 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/08/07 10:01
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    Wait Until Next 5 Min    extra_sleep_time=270
    Batch Execute AP CMDS With Sleep Time    ${C_111_AP_CMDS_WITH_SLEEP_TIME_STEP1}
    Wait Until Next 5 Min
    Batch Execute AP CMDS With Sleep Time    ${C_111_AP_CMDS_WITH_SLEEP_TIME_STEP2}
    Check Counters For CA111    M55352C02003=1000    M55352C02004=0    M55350C00024=1000
    ...    M55159C00002=1000    M55159C00010=0    M55159C00012=0
    Wait Until Next 5 Min    extra_sleep_time=60
    Batch Execute AP CMDS With Sleep Time    ${C_111_AP_CMDS_WITH_SLEEP_TIME_STEP3}
    Check Counters For CA111    M55352C02003=1500    M55352C02004=500    M55350C00024=1000
    ...    M55159C00002=1000    M55159C00010=0    M55159C00012=500

CA112 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/07/10 14:47
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    Wait Until Next 5 Min    extra_sleep_time=270
    @{ue_list}    Create List    2
    Airphone Multi-UE SA Attach    ue_list=${ue_list}    pdu_id=1    trf_type=internal
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl period_ms\=10 size\=1300 burst\=1 seconds\=10 trf_id\=1
    Sleep    3s
    airphone_execute_egate_command    bearer_stats ue\=2 pdu\=1 qfi\=1 dir\=dl
    Sleep    3s
    airphone_execute_egate_command    ue_stats_nr id\=2 type\=pdsch
    Wait Until Next 5 Min
    airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=100
    Sleep    3s
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=bler profile_id\=1 action\=activate
    Sleep    3s
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl period_ms\=10 size\=1300 burst\=1 seconds\=10 trf_id\=2
    Sleep    3s
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=dl period_ms\=10 size\=1400 burst\=1 seconds\=5 trf_id\=3
    Sleep    60s

    Check Counters For CA112
    Wait Until Next 5 Min    extra_sleep_time=60
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=bler profile_id\=1 action\=deactivate
    Sleep    3s
    airphone_execute_egate_command    trf_data_stop ue\=2 pdu\=1 qfi\=1
    Sleep    3s
    airphone_execute_egate_command    ue_deregister id\=2 ue_deregister_type\=switch_off
    Check Counters For CA112    M55159C00012_max=510    M55376C00007_add_M55159C00012=1500
    Check Counters And Snapshot For CA112

CA114 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/06/30 13:57
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    Wait Until Next 5 Min
    Batch Execute AP CMDS With Sleep Time    ${C_114_AP_CMDS_WITH_SLEEP_TIME_STEP1}
    Wait Until Next 5 Min    extra_sleep_time=60
    ${delay1}    Check Counters For CA114 Step1

    Batch Execute AP CMDS With Sleep Time    ${C_114_AP_CMDS_WITH_SLEEP_TIME_STEP2}
    Wait Until Next 5 Min    extra_sleep_time=60
    Check Counters For CA114 Step2    ${delay1}

CA119 Need Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/07/07 16:00
    Run Keyword And Ignore Error    Stop capture gnb and ap syslog in 'before_onair' file
    Prepare gnb onair

    Wait Until Next 5 Min    extra_sleep_time=60
    Batch Execute AP CMDS With Sleep Time    ${C_119_AP_CMDS_WITH_SLEEP_TIME_STEP1}
    Wait Until Next 5 Min    extra_sleep_time=60
    Check Counters For CA119

    Batch Execute AP CMDS With Sleep Time    ${C_119_AP_CMDS_WITH_SLEEP_TIME_STEP2}
    Wait Until Next 5 Min    extra_sleep_time=60
    Check Counters For CA119 Step2

Get Recent Multi Counters Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/27 20:13
    [Arguments]    ${counters}
    ${counter_values}    Create Dictionary
    ${counter_names}    Get Dictionary Keys    ${counters}
    FOR    ${counter_name}    IN    @{counter_names}
        ${values}    Get Dictionary Values    ${counters['${counter_name}']}
        Set To Dictionary    ${counter_values}    ${counter_name}=${values[-1]}
    END
    [Return]    ${counter_values}

Verify DL and UL traffic is normal From AP
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    Init Define: 2025/04/11 17:51
    ...    unit for expect_tput: Mbps
    [Arguments]    ${ue_id}   ${pdu_id}    ${qfi_id}    ${expect_tput}
    ${sa_dl_tput}=    Airphone SA Get Throughput    ue_id=${ue_id}    direction=DL    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ${sa_ul_tput}=    Airphone SA Get Throughput    ue_id=${ue_id}    direction=UL    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ${dl_assert_status}=    Evaluate    ${expect_tput}*1000*0.95<int(${sa_dl_tput})
    ${ul_assert_status}=    Evaluate    ${expect_tput}*1000*0.95<int(${sa_ul_tput})
    Should Be True    ${dl_assert_status}
    Should Be True    ${ul_assert_status}

Airphone Multi-UE SA Attach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 15:47
    [Arguments]    ${ue_list}    ${pdu_id}=1    ${trf_type}=internal    ${sleep_time}=3s
    FOR    ${ue_id}    IN    @{ue_list}
        Airphone SA Attach    ue_id=${ue_id}
        airphone_execute_egate_command    set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type\=${trf_type}
        airphone_execute_egate_command    ue_pdu_session_setup pdu\=${pdu_id} ue\=${ue_id}
        Sleep    ${sleep_time}
    END

Airphone UE SA Attach And Traffic With Period_ms
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/27 17:05
    [Arguments]    ${ue_id}    ${period_ms}    ${size}    ${burst}    ${qfi}=1    ${default_qos_flow}=False
    ...    ${sleep_time}=1s
    Run Keyword And Ignore Error    Airphone SA Attach    ue_id=${ue_id}    timeout=10
    Sleep    ${sleep_time}
    airphone_execute_egate_command    set_pdu_param ue\=${ue_id} pdu\=1 trf_type\=internal
    Sleep    ${sleep_time}
    airphone_execute_egate_command    ue_pdu_session_setup pdu\=1 ue\=${ue_id}
    Sleep    ${sleep_time}
    IF    ${default_qos_flow} != False
        airphone_execute_egate_command
        ...    ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=${default_qos_flow} by\=amf
        Sleep    ${sleep_time}
    END
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=1 qfi\=${qfi} dir\=dl period_ms\=${period_ms} size\=${size} burst\=${burst}
    Sleep    ${sleep_time}
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=1 qfi\=${qfi} dir\=ul period_ms\=${period_ms} size\=${size} burst\=${burst}
    Sleep    ${sleep_time}

Airphone UE SA Attach With Detach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/26 10:54
    [Arguments]    ${ue_id}    ${registration_type}=False    ${default_qos_flow}=False
    ...    ${pdu_id}=1    ${nwslice}=1    ${trf_type}=internal    ${sleep_time}=3s
    IF    '${registration_type}' == 'EmergencyRegistration'
        airphone_execute_egate_command    ue_register id\=${ue_id} registration_type\=EmergencyRegistration
    ELSE
        Airphone SA Attach    ue_id=${ue_id}
    END
    Sleep    ${sleep_time}

    IF    ${default_qos_flow} != False
        airphone_execute_egate_command
        ...    set_pdu_param ue\=${ue_id} pdu\=${pdu_id} default_qos_flow\=${default_qos_flow} trf_type\=${trf_type}
    ELSE
        airphone_execute_egate_command    set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type\=${trf_type}
    END
    Sleep    ${sleep_time}

    Airphone Pdu Session Setup    ${ue_id}    ${pdu_id}    ${nwslice}    ${ue_id}
    Sleep    ${sleep_time}
    Airphone SA Detach    ${ue_id}
    Sleep    ${sleep_time}

Airphone Multi-UE SA Detach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 15:47
    [Arguments]    ${ue_list}    ${pdu_id}=1    ${qfi_id}=1
    FOR    ${ue_id}    IN    @{ue_list}
        airphone_execute_egate_command    trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id}
        airphone_execute_egate_command    ue_deregister id\=${ue_id} ue_deregister_type\=switch_off
    END

Get UE Rnti List
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 15:54
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UEs   unzip=TRUE
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UEs/egate_console.log.001   crnti: (\\d+)
    [Return]    ${rnti_list}

Airphone Start DL&UL Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 16:00
    [Arguments]    ${ue_id}    ${dl_mbps}    ${ul_mbps}    ${pdu_id}=1    ${qfi_id}=1    ${trf_id}=1
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir\=ul mbps\=${ul_mbps} trf_id\=${trf_id}
    Sleep   3s
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir\=dl mbps\=${dl_mbps} trf_id\=${trf_id}
    Sleep   3s

Airphone Multi-UE SA Traffic Summary
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 15:47
    [Arguments]    ${ue_list}    ${direction}=DL    ${pdu_id}=1    ${qfi_id}=1
    ${sum_tp}    Set Variable    0
    FOR    ${ue_id}    IN    @{ue_list}
        ${dl_tp}    Airphone SA Get Throughput    ue_id=${ue_id}    direction=${direction}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
        ${sum_tp}    Evaluate    ${sum_tp} + ${dl_tp}
    END
    [Return]    ${sum_tp}

Airphone Verify UE DL&UL TP Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/20 13:21
    [Arguments]    ${ue_id}    ${except_dl_tp}    ${except_ul_tp}    ${pdu_id}=1    ${qfi_id}=1    ${tolerance}=10
    ${dl_tp}    Airphone SA Get Throughput    ue_id=${ue_id}    direction=dl    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ${ul_tp}    Airphone SA Get Throughput    ue_id=${ue_id}    direction=ul    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    # convert kbps to Mbps
    ${dl_tp}    Evaluate    ${dl_tp}/1000
    ${ul_tp}    Evaluate    ${ul_tp}/1000
    ${dl_result}=    Is Values Close    ${dl_tp}    ${except_dl_tp}    tolerance_percent=${tolerance}
    Should Be True    ${dl_result}
    ${ul_result}=    Is Values Close    ${ul_tp}    ${except_ul_tp}    tolerance_percent=${tolerance}
    Should Be True    ${ul_result}
    Log To Console    ue_id(${ue_id}) dl_tp:${dl_tp}mbps ul_tp:${ul_tp}mbps
    [Return]    ${dl_tp}    ${ul_tp}

Airphone Set Common Test Variables
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 16:48
    [Arguments]    ${common_variables}    ${need_swconfig}=False
    Set Test Variable    ${SCFC_NAME}            ${common_variables["SCFC_NAME"]}
    Set Test Variable    ${AIRPHONE_NAME}        ${common_variables["AIRPHONE_NAME"]}
    Set Test Variable    ${WTS_NAME}             ${common_variables["WTS_NAME"]}
    Set Test Variable    ${GNBCUTYPE}            ${common_variables["GNBCUTYPE"]}
    IF    ${need_swconfig}
        Set Test Variable    ${GNB_SWCONFIG_NAME}        ${common_variables["GNB_SWCONFIG_NAME"]}
        Set Test Variable    ${AP_SWCONFIG_NAME}        ${common_variables["AP_SWCONFIG_NAME"]}
    END
