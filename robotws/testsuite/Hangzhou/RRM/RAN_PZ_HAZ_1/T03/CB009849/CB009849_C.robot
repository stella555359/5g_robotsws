*** Settings ***
Documentation
...   author: Yin Ran
...   contact: ran.yin@nokia-sbell.com
...   this is a robot case about CB009849_C

Resource          ../Resources/common_resource.robot
#Resource          ../../HAZ5/Resources/pet_all.robot
Force Tags        CRT    RAN_5G    STATE_SKIP_AGENT
...               SBTS00   CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG07_ST_RRM    TA_LEVEL_22
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Library    check_rules.py

*** Variables ***

@{mcs_setting}           ${19}    ${15}   ${12}
@{mo_list}               MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31
...                      MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31
${TTI_cell}              NRCELL_R-31
&{fault_4655}            faultId=${4655}
&{fault_4654}            faultId=${4654}
&{fault_61524}           faultId=${61524}
&{fault_61652}           faultId=${61652}
&{fault_2002}            faultId=${2002}
&{fault_7300}            faultId=${7300}
&{fault_61649}           faultId=${61649}
&{fault_4592}            faultId=${4592}
@{Ohter_Allow_Alarms}    &{fault_4655}    &{fault_4654}    &{fault_2002}    &{fault_61524}    &{fault_61652}
&{dcap_info}    host=10.56.218.4    port=443    username=utfuser    password=utfadmin!
${tti_path}      /home/ute/test_results/
@{tti_condition_1}    dlFdSchedData.scheduledBytesPerBearer[1]    >    0
@{tti_condition_2}    dlFdSchedData.scheduledBytesPerBearer[2]    >    0
@{tti_condition_3}    dlFdSchedData.scheduledBytesPerBearer[5]    >    0
@{tti_condition_4}    dlFdSchedData.scheduledBytesPerBearer[6]    >    0
@{tti_condition_5}    dlFdSchedData.scheduledBytesPerBearer[1]    ==    0
@{tti_condition_6}    dlFdSchedData.scheduledBytesPerBearer[2]    ==    0
@{tti_condition_7}    dlFdSchedData.scheduledBytesPerBearer[5]    ==    0
@{tti_condition_8}    dlFdSchedData.dciFormat    !=    DL_10_FORCE
@{tti_stat_condition_1}    max    dlFdSchedData.rrmDlUsedMcs    >    19
@{tti_stat_condition_2}    max    dlFdSchedData.rrmDlUsedMcs    >    15
@{tti_stat_condition_3}    max    dlFdSchedData.rrmDlUsedMcs    >    12
@{tti_stat_condition_4}    max    dlFdSchedData.rrmCorrAvgCqi    >    15
@{tti_stat_conditions_1}    or     ${tti_stat_condition_1}    ${tti_stat_condition_1}
@{tti_stat_conditions_2}    or     ${tti_stat_condition_2}    ${tti_stat_condition_2}
@{tti_stat_conditions_3}    or     ${tti_stat_condition_3}    ${tti_stat_condition_4}
@{tti_conditions_1}    or    ${tti_condition_1}    ${tti_condition_2}
@{tti_conditions_2}    and    ${tti_condition_5}    ${tti_condition_6}    ${tti_condition_3}
...                           ${tti_condition_8}
@{tti_conditions_3}    and    ${tti_condition_5}    ${tti_condition_6}    ${tti_condition_7}
...                           ${tti_condition_4}
&{tti_check_rules_1}         basic_rules=${tti_conditions_1}    statistics_rules=${tti_stat_conditions_1}
&{tti_check_rules_2}         basic_rules=${tti_conditions_2}    statistics_rules=${tti_stat_conditions_2}
&{tti_check_rules_3}         basic_rules=${tti_conditions_3}    statistics_rules=${tti_stat_conditions_3}
&{tti_analysis_1}       check_rules=${tti_check_rules_1}    row_count=${50}
&{tti_analysis_2}       check_rules=${tti_check_rules_2}    row_count=${50}
&{tti_analysis_3}       check_rules=${tti_check_rules_3}    row_count=${50}
@{tti_analysis_dict}     ${tti_analysis_1}    ${tti_analysis_2}    ${tti_analysis_3}

*** Test Cases ***

CB009849_C_01_Update VoNR downlink rank reduction algorithm to use CQI data for VoNR 5QI1 only

    [Documentation]
    ...    author: ran.yin@nokia-sbell.com
    [Tags]
    Change CB009849_C_actDlForceRankDowng_to_dlVoNROnly
    #Start TTI trace for specific cell
    AT Operation    operation=attach
    AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    start_call    ue_index=0  number=6688
    sleep    30s
    AT Operation    stop_call    ue_index=0
    AT Operation    stop_traffic  ue_index=0  direction=dl    remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    operation=detach
    #Stop TTI trace for specific cell

CB009849_C_02_Update VoNR downlink rank reduction algorithm to use CQI data for VoNR 5QI1 only

    [Documentation]
    ...    author: ran.yin@nokia-sbell.com
    [Tags]
    Change CB009849_C_actDlForceRankDowng_to_dlVoNROnly
    #Start TTI trace for specific cell
    AT Operation    operation=attach
    AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    start_call    ue_index=0  number=6688
    sleep    30s
    AT Operation    stop_call    ue_index=0
    AT Operation    stop_traffic  ue_index=0  direction=dl    remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    operation=detach
    #Stop TTI trace for specific cell

CB009849_C_03_Update VoNR downlink rank reduction algorithm for VoNR control 5QI5 only

    [Documentation]
    ...    author: ran.yin@nokia-sbell.com
    [Tags]
    Change CB009849_C_actDlForceRankDowng_to_dlVoNRCtrlOnly
    #Start TTI trace for specific cell
    AT Operation    operation=attach
    AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    AT Operation    stop_call    ue_index=0
    AT Operation    stop_traffic  ue_index=0  direction=dl    remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    operation=detach
    #Stop TTI trace for specific cell

CB009849_C_04_Update VoNR downlink rank reduction algorithm for SRB only

    [Documentation]
    ...    author: ran.yin@nokia-sbell.com
    [Tags]
    Change CB009849_C_actDlForceRankDowng_to_dlSRBOnly
    #Start TTI trace for specific cell
    AT Operation    operation=attach
    AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    AT Operation    stop_call    ue_index=0
    AT Operation    stop_traffic  ue_index=0  direction=dl    remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    operation=detach
    #Stop TTI trace for specific cell

CB009849_C_05_Update VoNR downlink rank reduction algorithm for SRB, 5QI5 and 5QI1

    [Documentation]
    ...    author: ran.yin@nokia-sbell.com
    [Tags]
    Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrl
    AT Operation    operation=attach
    AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 300 -b 300k -p 50001  direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    Start TTI trace for specific cell
    AT Operation    start_call    ue_index=0  number=6688
    sleep    5s
    Stop TTI trace for specific cell
    AT Operation    stop_call    ue_index=0
    AT Operation    stop_traffic  ue_index=0  direction=dl    remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    operation=detach
    Analyze TTI log

CB009849_C_06_Online parameter modification for VoNR 5QI1 related option

    [Documentation]
    ...    author: ran.yin@nokia-sbell.com
    [Tags]
    Change CB009849_C_actDlForceRankDowng_to_disabled
    #Start TTI trace for specific cell
    AT Operation    operation=attach
    AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 600 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_dlVoNROnly
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_disabled
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrl
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_disabled
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    stop_traffic  ue_index=0  direction=dl    remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    operation=detach
    #Stop TTI trace for specific cell

CB009849_C_07_Online parameter modification for VoNR 5QI5 related option

    [Documentation]
    ...    author: ran.yin@nokia-sbell.com
    [Tags]
    Change CB009849_C_actDlForceRankDowng_to_disabled
    #Start TTI trace for specific cell
    AT Operation    operation=attach
    AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 600 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_dlVoNRCtrlOnly
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_disabled
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrl
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_disabled
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    stop_traffic  ue_index=0  direction=dl    remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    operation=detach
    #Stop TTI trace for specific cell

CB009849_C_08_Online parameter modification for SRB related option

    [Documentation]
    ...    author: ran.yin@nokia-sbell.com
    [Tags]
    Change CB009849_C_actDlForceRankDowng_to_disabled
    #Start TTI trace for specific cell
    AT Operation    operation=attach
    AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 600 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_dlSRBOnly
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_disabled
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrl
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_disabled
    sleep    15s
    AT Operation    stop_call    ue_index=0
    sleep    5s
    AT Operation    stop_traffic  ue_index=0  direction=dl    remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    operation=detach
    #Stop TTI trace for specific cell

CB009849-C_12_Update VoNR downlink rank reduction algorithm to use CQI data for SRB, 5QI5, 5QI1 and non-GBR

    [Documentation]
    ...    author: ran.yin@nokia-sbell.com
    [Tags]
    Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrNonGbrBr
    #Start TTI trace for specific cell
    AT Operation    operation=attach
    AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 300 -b 1M -p 50001  direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    AT Operation    stop_call    ue_index=0
    AT Operation    stop_traffic  ue_index=0  direction=dl    remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    operation=detach
    #Stop TTI trace for specific cell
    #Analyze TTI log

CB009849-C_13_interworking with CNI-135068

    [Documentation]
    ...    author: ran.yin@nokia-sbell.com
    [Tags]
    Change CB009849_C_actDlForceRankDowng_to_dlNonGbrBrOnly
    #Start TTI trace for specific cell
    AT Operation    operation=attach
    AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 300 -b 1M -p 50001  direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    start_call    ue_index=0  number=6688
    sleep    15s
    Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrNonGbrBr
    AT Operation    stop_call    ue_index=0
    AT Operation    stop_traffic  ue_index=0  direction=dl    remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
    AT Operation    operation=detach
    #Stop TTI trace for specific cell
    #Analyze TTI log

*** Keywords ***
Case Setup
    Log To Console    Case Setup

Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Disconnect All VM

Change CB009849_C_actDlForceRankDowng_to_dlVoNROnly
    @{para_list}      Create List    actDlForceRankDowng    actDlVoNrLimMaxMcsAndLayer
    @{mo_list}        Create List    MRBTS-37421/NRBTS-37421/NRCELL-21    MRBTS-37421/NRBTS-37421/NRCELL-21
    @{value_list}     Create List    dlVoNROnly    false
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Start TTI trace for specific cell
    [Tags]    tti
    Log To Console    start to capture tti with DCAP
    ${dcap_argument}   Create Dictionary   nrCells=${TTI_cell}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    tti    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}

Stop TTI trace for specific cell
    Log To Console    stopping tti with DCAP
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}
    Set Test Variable    ${tti_path}     ${local_file_path}
    Log To Console    \nTTI log: ${local_file_path}

Change CB009849_C_actDlForceRankDowng_to_dlVoNRCtrlOnly
    &{staged_dict}    create dictionary   maxMcsForDlSrb=${19}  maxMcsForDlVoNRCtrl=${19}
    @{staged_param_list}     Create List   ${staged_dict}
    @{value_list}     Create List   ${staged_param_list}    dlVoNRCtrlOnly
    @{para_list}      Create List   dlForceRankDowngCtl    actDlForceRankDowng
    @{mo_list}        Create List   MRBTS-37421/NRBTS-37421/NRCELL-21    MRBTS-37421/NRBTS-37421/NRCELL-21
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Change CB009849_C_actDlForceRankDowng_to_dlSRBOnly
    &{staged_dict}    create dictionary   maxMcsForDlSrb=${19}  maxMcsForDlVoNRCtrl=${19}
    @{staged_param_list}     Create List   ${staged_dict}
    @{value_list}     Create List   ${staged_param_list}    dlSRBOnly
    @{para_list}      Create List   dlForceRankDowngCtl    actDlForceRankDowng
    @{mo_list}        Create List   MRBTS-37421/NRBTS-37421/NRCELL-21    MRBTS-37421/NRBTS-37421/NRCELL-21
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrl
    &{staged_dict}    create dictionary   maxMcsForDlSrb=${mcs_setting[0]}  maxMcsForDlVoNRCtrl=${mcs_setting[1]}
    @{staged_param_list}     Create List   ${staged_dict}
    @{value_list}     Create List   ${staged_param_list}    dlVonrSrbVoNRCtrl    false
    @{para_list}      Create List   dlForceRankDowngCtl    actDlForceRankDowng    actDlVoNrLimMaxMcsAndLayer
    #@{mo_list}        Create List   MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Change CB009849_C_actDlForceRankDowng_to_dlVonrSrbVoNRCtrNonGbrBr
    &{staged_dict}    create dictionary   maxMcsForDlSrb=${15}  maxMcsForDlVoNRCtrl=${19}
    @{staged_param_list}     Create List   ${staged_dict}
    @{value_list}     Create List   ${staged_param_list}    dlVonrSrbVoNRCtrNonGbrBr    false    12    10
    @{para_list}      Create List   dlForceRankDowngCtl    actDlForceRankDowng    actDlVoNrLimMaxMcsAndLayer
    ...                             shortTermBlerThreshold1    shortTermBlerThreshold2
    @{mo_list}        Create List   MRBTS-37421/NRBTS-37421/NRCELL-13    MRBTS-37421/NRBTS-37421/NRCELL-13    MRBTS-37421/NRBTS-37421/NRCELL-13
    ...                             MRBTS-37421/NRBTS-37421/NRCELL-13    MRBTS-37421/NRBTS-37421/NRCELL-13
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Change CB009849_C_actDlForceRankDowng_to_dlNonGbrBrOnly
    @{value_list}     Create List   true    dlNonGbrBrOnly    false    12    10
    @{para_list}      Create List   actCsiImRandomizationFddNonDss    actDlForceRankDowng    actDlVoNrLimMaxMcsAndLayer
    ...                             shortTermBlerThreshold1    shortTermBlerThreshold2
    @{mo_list}        Create List   MRBTS-37421/NRBTS-37421/NRCELL-13    MRBTS-37421/NRBTS-37421/NRCELL-13    MRBTS-37421/NRBTS-37421/NRCELL-13
    ...                             MRBTS-37421/NRBTS-37421/NRCELL-13    MRBTS-37421/NRBTS-37421/NRCELL-13
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Change CB009849_C_actDlForceRankDowng_to_disabled
    @{para_list}      Create List    actDlForceRankDowng    actDlVoNrLimMaxMcsAndLayer    dlForceRankDowngCtl
    ...                              shortTermBlerThreshold1    shortTermBlerThreshold2
    #@{mo_list}        Create List    MRBTS-37421/NRBTS-37421/NRCELL-13    MRBTS-37421/NRBTS-37421/NRCELL-13    MRBTS-37421/NRBTS-37421/NRCELL-13
    #...                              MRBTS-37421/NRBTS-37421/NRCELL-13    MRBTS-37421/NRBTS-37421/NRCELL-13
    @{value_list}     Create List    disabled    true    ${None}    ${None}    ${None}
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Analyze TTI log
    [Tags]    tti
    Log To Console    \nStart Log Analysis for ${tti_path}
    ${result}=    Log Analysis    check    tti    ${tti_path}    ${tti_analysis_dict}
    Log To Console    \nAnalyze TTI log: ${result}
    ${status}    check_rules     ${tti_path}    ${mcs_setting[0]}    ${mcs_setting[1]}    ${mcs_setting[2]}
    Log To Console    \nCheck rule log: ${status}
    should be true    ${status}


