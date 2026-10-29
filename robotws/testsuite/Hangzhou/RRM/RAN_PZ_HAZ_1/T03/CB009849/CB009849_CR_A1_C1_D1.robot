*** Settings ***
Documentation
...   Author: zhuo.1.gao@nokia-sbell.com
...   Contact: zhuo.1.gao@nokia-sbell.com
...   this is a robot case about CB009849_CR_A1_C1_D1

Resource           ../Resources/vran_resource.robot
Suite Setup       Common Suite Setup For AIC
Test Setup        Common Test Setup For AIC
Test Teardown     Common Test Teardown For AIC
Suite Teardown    Common Suite Teardown For AIC


Test Timeout    600 minutes

*** Variables ***
# ${DEBUG_MODE}            ${TRUE}
# ${parameter}             actDlForceRankDowng
# @{mo_list}               MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31
# ...                      MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31
${TTI_cell}              NRCELL-7801
# &{fault_4655}            faultId=${4655}
# &{fault_4654}            faultId=${4654}
# &{fault_61524}           faultId=${61524}
# &{fault_61652}           faultId=${61652}
# &{fault_2002}            faultId=${2002}
# &{fault_7300}            faultId=${7300}
# &{fault_61649}           faultId=${61649}
# &{fault_4592}            faultId=${4592}
# @{Ohter_Allow_Alarms}    &{fault_4655}    &{fault_4654}    &{fault_2002}    &{fault_61524}    &{fault_61652}
&{dcap_info}    host=10.56.218.4    port=443    username=utfuser    password=utfadmin!
${tti_path}      /home/ute/test_results/
# @{tti_condition_1}    dlFdSchedData.scheduledBytesPerBearer[1]    >    0
# @{tti_condition_2}    dlFdSchedData.scheduledBytesPerBearer[2]    >    0
# @{tti_condition_3}    dlFdSchedData.scheduledBytesPerBearer[5]    >    0
# @{tti_condition_4}    dlFdSchedData.scheduledBytesPerBearer[6]    >    0
# @{tti_condition_5}    dlFdSchedData.scheduledBytesPerBearer[1]    ==    0
# @{tti_condition_6}    dlFdSchedData.scheduledBytesPerBearer[2]    ==    0
# @{tti_condition_7}    dlFdSchedData.scheduledBytesPerBearer[5]    ==    0
# #@{tti_condition_8}    dlFdSchedData.numOfLayers    ==    RANK1
# #@{tti_condition_9}    dlFdSchedData.numOfLayers    ==    RANK2
# @{tti_stat_condition_1}    max    dlFdSchedData.rrmDlUsedMcs    ==    19
# @{tti_stat_condition_2}    max    dlFdSchedData.rrmDlUsedMcs    ==    15
# @{tti_stat_condition_3}    max    dlFdSchedData.rrmDlUsedMcs    ==    12
# @{tti_stat_condition_4}    max    dlFdSchedData.rrmCorrAvgCqi    ==    15
# @{tti_stat_conditions_1}    and     ${tti_stat_condition_3}    ${tti_stat_condition_4}
# @{tti_conditions_1}    or    ${tti_condition_1}    ${tti_condition_2}
# @{tti_conditions_2}    and    ${tti_condition_5}    ${tti_condition_6}    ${tti_condition_3}
# @{tti_conditions_3}    and    ${tti_condition_5}    ${tti_condition_6}    ${tti_condition_7}
# ...                           ${tti_condition_4}
# &{tti_check_rules_1}         basic_rules=${tti_conditions_1}    statistics_rules=${tti_stat_condition_1}
# &{tti_check_rules_2}         basic_rules=${tti_conditions_2}    statistics_rules=${tti_stat_condition_2}
# &{tti_check_rules_3}         basic_rules=${tti_conditions_3}    statistics_rules=${tti_stat_conditions_1}
# &{tti_analysis_1}       check_rules=${tti_check_rules_1}    row_count=${50}
# &{tti_analysis_2}       check_rules=${tti_check_rules_2}    row_count=${50}
# &{tti_analysis_3}       check_rules=${tti_check_rules_3}    row_count=${50}
# @{tti_analysis_dict_1}     ${tti_analysis_1}
# @{tti_analysis_dict_2}     ${tti_analysis_2}
# @{tti_analysis_dict_3}    ${tti_analysis_3}

*** Test Cases ***
CB009849-CR_A_Case01 Successful user setup with 5QI1 bearer UE supports Transform precoding on TDD
    #[Tags]    QC_193607    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    set_testline_cell_status_onair
    CB009849_A_enable actForcedDftSOfdmVonrUl
    Start_Collect_Wireshark_For_Cloud
    sleep    15s
    detach_QC8450
    sleep    5s
    attach_QC8450
    AT Operation    start_call    ue_index=0  number=6688
    8450_DLstart
    sleep    180s
    8450_DLstop
    AT Operation    stop_call    ue_index=0
    sleep    5s
    Stop_Collect_Wireshark_For_Cloud
    CB009849_A_disable actForcedDftSOfdmVonrUl
    recover_testline_cell_status_initial

CB009849-CR_C_Case01 Update VoNR downlink rank reduction algorithm to use CQI data for VoNR 5QI1 only - TDD
    #[Tags]    QC_193611    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    set_testline_cell_status_onair
    Change CB009849_C_actDlForceRankDowng_to_dlVoNROnly
    Start TTI trace for specific cell
    sleep    15s
    detach_QC8450
    sleep    5s
    attach_QC8450
    8450_DLstart
    AT Operation    start_call    ue_index=0  number=6688
    sleep    180s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    8450_DLstop
    Stop TTI trace for specific cell
    Change CB009849_C_disabled_DlForceRankDowng_to_dlVoNROnly
    recover_testline_cell_status_initial

CB009849-CR_D_Case01 VoNR specific DRX profile is enabled during cell setup and successful setup of VoNR call with TDD
    #[Tags]    QC_193609    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    set_testline_cell_status_onair
    Online activate CB009849-D
    Start TTI trace for specific cell
    sleep    15s
    detach_QC8450
    sleep    5s
    attach_QC8450
    AT Operation    start_call    ue_index=0  number=6688
    8450_DLstart
    sleep    180s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    8450_DLstop
    Stop TTI trace for specific cell
    Online deactivate CB009849-D
    recover_testline_cell_status_initial

*** Keywords ***
CB009849_A_disable actForcedDftSOfdmVonrUl
    [Documentation]    disable actForcedDftSOfdmVonrUl
    @{para_list}   Create List   actForcedDftSOfdmVonrUl
    @{value_list}   Create List   false
    @{mo_list}   Create List   MRBTS-11184/NRBTS-11184/NRCELL-7801
    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console        VDU paramter update result: ${out}

CB009849_A_enable actForcedDftSOfdmVonrUl
    [Documentation]    enable actForcedDftSOfdmVonrUl
    @{para_list}   Create List   actForcedDftSOfdmVonrUl
    @{value_list}   Create List   true
    @{mo_list}   Create List   MRBTS-11184/NRBTS-11184/NRCELL-7801
    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console        VDU paramter update result: ${out}

Counter Check CB009849 enable on target cell
    ${rule1}    Catenate
    ...    Distname: MRBTS-11184/NRBTS-11184/NRCELL-7801;
    ...    Counter: M55302C15092;
    ...    Counter rule: sum(M55302C15092)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-11184/NRBTS-11184/NRCELL-7801;
    ...    Counter: M55302C15101;
    ...    Counter rule: sum(M55302C15101)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=vdu
    ...    counter_rule=${rule_list}

detach_QC8450
   AT Operation    detach    ue_index=0

attach_QC8450
   AT Operation    attach    ue_index=0

8450_DLstart
    AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
8450_DLstop
    AT Operation    stop_traffic  direction=dl
Start_Collect_Wireshark_For_Cloud
   Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
   Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}

Stop_Collect_Wireshark_For_Cloud
   ${local_file_pathcu}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
   ${local_file_pathdu}    Log Collection    stop_and_download    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
   Log To Console        \nWireshark log of VCU: ${local_file_pathcu}
   Log To Console        \nWireshark log of VDU: ${local_file_pathdu}

# Case Setup
#     Log To Console    Case Setup

# Case Teardown
#     Log To Console    Case Teardown
#     # Run Keyword And Ignore Error    AT.UE Detach
#     Run Keyword And Ignore Error    Disconnect All VM

Change CB009849_C_actDlForceRankDowng_to_dlVoNROnly
    @{para_list}      Create List    actDlForceRankDowng    actDlVoNrLimMaxMcsAndLayer
    @{mo_list}        Create List    MRBTS-11184/NRBTS-11184/NRCELL-7801    MRBTS-11184/NRBTS-11184/NRCELL-7801
    @{value_list}     Create List    dlVoNROnly    false
    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console        VDU paramter update result: ${out}

Change CB009849_C_disabled_DlForceRankDowng_to_dlVoNROnly
    @{para_list}      Create List    actDlForceRankDowng
    @{mo_list}        Create List    MRBTS-11184/NRBTS-11184/NRCELL-7801
    @{value_list}     Create List    disabled
    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console        VDU paramter update result: ${out}

Start TTI trace for specific cell
    [Tags]    tti
    Log To Console    start to capture tti with DCAP
    ${dcap_argument}   Create Dictionary   nrCells=${TTI_cell}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    dict_argument=${dict_argument}

Stop TTI trace for specific cell
    Log To Console    stopping tti with DCAP
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}
    Set Test Variable    ${tti_path}     ${local_file_path}
    Log To Console    \nTTI log: ${local_file_path}


Analyze TTI log
    [Tags]    tti
    Log To Console    \nStart Log Analysis
    ${result}=    Log Analysis    check    tti    ${tti_path}    ${tti_analysis_dict_1}
    ${result}=    Log Analysis    check    tti    ${tti_path}    ${tti_analysis_dict_2}
    ${result}=    Log Analysis    check    tti    ${tti_path}    ${tti_analysis_dict_3}
    Log To Console    \nAnalyze log: ${result}

Online activate CB009849-D
    [Documentation]    Enable 40ms period of proactive grant for VoNR UE
    @{para_list}   Create List    actVonr40msProGrant
    @{value_list}   Create List   true
    @{mo_list}   Create List   MRBTS-11184/NRBTS-11184/NRCELL-7801    MRBTS-11184/NRBTS-11184/NRCELL-7801
    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console        VDU paramter update result: ${out}

Online deactivate CB009849-D
    [Documentation]    Disable 40ms period of proactive grant for VoNR UE
    @{para_list}   Create List    actVonr40msProGrant
    @{value_list}   Create List   false
    @{mo_list}   Create List   MRBTS-11184/NRBTS-11184/NRCELL-7801
    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console        VDU paramter update result: ${out}

set_testline_cell_status_onair
    BTS Operation    operation=cell_block           product_type=vdu    bts_index=0    distname_id=NRCELL-7802       need_verify=True
    BTS Operation    operation=cell_block           product_type=vdu    bts_index=0    distname_id=NRCELL-1001       need_verify=True
    BTS Operation    operation=cell_block           product_type=vdu    bts_index=0    distname_id=NRCELL-1002       need_verify=True
    BTS Operation    operation=verify    product_type=vdu    distname_id=NRCELL-7801    verify_status=CELL_ONAIR

recover_testline_cell_status_initial
    BTS Operation    operation=cell_unblock           product_type=vdu    bts_index=0    distname_id=NRCELL-7802       need_verify=True
    BTS Operation    operation=cell_unblock           product_type=vdu    bts_index=0    distname_id=NRCELL-1001       need_verify=True
    BTS Operation    operation=cell_unblock           product_type=vdu    bts_index=0    distname_id=NRCELL-1002       need_verify=True
    BTS Operation    operation=verify    product_type=vdu    distname_id=NRCELL-ALL           verify_status=CELL_ONAIR