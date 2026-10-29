*** Settings ***
Documentation
...    Author: Shuangfeng.f.sun
...    Contact: shuangfeng.f.sun@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Force Tags
...      TRUNK             #Tag Item
...      CA_RAN_PZ_HAZ_1             #Competence Area
...      TA_LEVEL_22                 #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout           6h

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Resource    ../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../../T02/Common_Case/common_resource_new.robot
Library     taf.sw.scout    WITH NAME    scout
Library     SSHLibrary
Library     Collections

*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${TestLine_Name}          7_5_UTE5GAIC025T001
#${SCF_Path}     /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL10772/CB006139/
${SCF_Name_BA}     /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL10772/CB006139/CB006139_BA_B1_B2.xml
${SCF_Name_CD_B1}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL10772/CB006139/CB006139_CD_B1.xml
${SCF_Name_CD_B2}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL10772/CB006139/CB006139_CD_B2.xml
${SCF_Name_AAD}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL10772/CB006139/CB006139_AAD.xml

${log_type}    syslog+cell_trace
*** Test Cases ***

CB006139_CD_01_B1_gNB_adds_only_FDD_SCells_during_one-shot_SCell_addition_and_UE_has_reached_maximum_CCs
    [Tags]    CRT    CB006139_CD_01_B1
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    SCF_Config_activate_CD    scf_path=${SCF_Name_CD_B1}
    Check_CellandSite_Status
    log to console      \n >>> Site is on-air, start to test. \n >>> update the case's SCF
    BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0    distname_id=NRCELL-4    need_verify=False
    sleep    5min
    Open DCAP
    start_log_collection    log_type=${log_type}
    Initialize PA Signal
    Set Initialize PA Value    pa_port=10;    pa_value=10;
    Prepare And Attach UE For Qualcomm    ue_index=0
    Set Initialize PA Value    pa_port=24,32;    pa_value=12;
    Start big data DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    300s
    Set Initialize PA Value    pa_port=8,10;    pa_value=20;
    Set Initialize PA Value    pa_port=32;    pa_value=120;
    sleep    30s
    Set Initialize PA Value    pa_port=8,10;    pa_value=0;
    Set Initialize PA Value    pa_port=28,18;    pa_value=10;
    sleep    30s    reason=wait log generated
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    [Teardown]    Teardown_for_OAM

CB006139_CD_02_B2_gNB_adds_only_FDD_SCells_during_one-shot_SCell_addition_and_UE_has_not_reached_maximum_CCs
    [Tags]    CRT    CB006139_CD_02_B2
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    SCF_Config_activate_CD    scf_path=${SCF_Name_CD_B2}
    sleep    5min
    Check_CellandSite_Status
    log to console      \n >>> Site is on-air, start to test. \n >>> update the case's SCF
    BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0    distname_id=NRCELL-3    need_verify=False
    sleep    5min
    Open DCAP
    start_log_collection    log_type=${log_type}
    Initialize PA Signal
    Set Initialize PA Value    pa_port=8,10;    pa_value=10;
    Prepare And Attach UE For Qualcomm    ue_index=0
    Set Initialize PA Value    pa_port=6,26;    pa_value=12;
    Start big data DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    300s
    Set Initialize PA Value    pa_port=8,10;    pa_value=20;
    Set Initialize PA Value    pa_port=26;    pa_value=120;
    sleep    30s
    Set Initialize PA Value    pa_port=8,10;    pa_value=0;
    Set Initialize PA Value    pa_port=18,28;    pa_value=12;
    sleep    120
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    [Teardown]    Teardown_for_OAM

CB006139_BA_01_B1_Monitoring_of_NR_FR1_step-wise_SCell_addition_in_PCMD_records_in_gNB-CU
    [Tags]    CRT    CB006139_BA_01
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    SCF_Config_activate_CD    scf_path=${SCF_Name_BA}
    Check_CellandSite_Status
    log to console      \n >>> Site is on-air, start to test. \n >>> update the case's SCF
    Open DCAP
    start_log_collection    log_type=${log_type}
    Initialize PA Signal
    Set Initialize PA Value    pa_port=10;    pa_value=0;
    Prepare And Attach UE For Qualcomm    ue_index=0
    Set Initialize PA Value    pa_port=18,3,6,28;    pa_value=10;
    Start big data DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    300s    reason=wait call stable
    Set Initialize PA Value    pa_port=18;    pa_value=120;
    Stop Call For UE    ue_index=0    ue_type=qualcomm
    sleep    15s
    Set Initialize PA Value    pa_port=18;    pa_value=10;
    Start big data DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    10s    reason=wait log generated
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    [Teardown]    Teardown_for_OAM

CB006139_BA_02_B2_Monitoring_of_NR_FR1_step-wise_SCell_addition_in_PCMD_records_in_gNB-DU
    [Tags]    CRT    CB006139_BA_02
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Common Test Setup For RRM
    SCF_Config_activate_CD    scf_path=${SCF_Name_BA}
    Check_CellandSite_Status
    log to console      \n >>> Site is on-air, start to test. \n >>> update the case's SCF
    start_log_collection    log_type=${log_type}
    Initialize PA Signal
    Set Initialize PA Value    pa_port=10;    pa_value=0;
    Prepare And Attach UE For Qualcomm    ue_index=0
    Set Initialize PA Value    pa_port=18,3,6,28;    pa_value=10;
    Start big data DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    300s    reason=wait call stable
    Set Initialize PA Value    pa_port=18;    pa_value=120;
    Stop Call For UE    ue_index=0    ue_type=qualcomm
    sleep    15s
    Set Initialize PA Value    pa_port=18;    pa_value=10;
    Start big data DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    10s    reason=wait log generated
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    [Teardown]    Teardown_for_OAM

CB006139_AAD_02_Counter_update_for_configuration_of_A1_measurements
    [Tags]    CRT    CB006139_AAD_02
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    SCF_Config_activate_CD    scf_path=${SCF_Name_AAD}
    Check_CellandSite_Status
    log to console      \n >>> Site is on-air, start to test. \n >>> update the case's SCF
    BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0    distname_id=NRCELL-3    need_verify=False
    sleep    5min
    Open DCAP
    start_log_collection    log_type=${log_type}
    Start Counter For CB006139_AAD
    Initialize PA Signal
    Set Initialize PA Value    pa_port=10;    pa_value=0;
    Prepare And Attach UE For Qualcomm    ue_index=0
    Set Initialize PA Value    pa_port=2;18,11,26;31;    pa_value=0;10;20;
    Start big data DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    300s
    Set Initialize PA Value    pa_port=31;    pa_value=120;
    sleep    10s
    Set Initialize PA Value    pa_port=31;    pa_value=20;
    sleep    10s
    Set Initialize PA Value    pa_port=18;    pa_value=120;
    sleep    10s
    Set Initialize PA Value    pa_port=18;    pa_value=10;
    sleep    0
    Set Initialize PA Value    pa_port=26;    pa_value=120;
    sleep    10s
    Set Initialize PA Value    pa_port=26;    pa_value=10;
    sleep    10s
    Set Initialize PA Value    pa_port=2;    pa_value=120;
    sleep    10s
    Set Initialize PA Value    pa_port=2;    pa_value=0;
    sleep    10s
    Set Initialize PA Value    pa_port=11;    pa_value=120;
    sleep    10s
    Set Initialize PA Value    pa_port=11;    pa_value=10;
    sleep    10s
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    Collect And Check Counter
    [Teardown]    Teardown_for_OAM

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM
    Run Keyword And Ignore Error    Get Iperf Info
#    HAZ TC02 Get SCF Internal Id By Scout    no_ute=False

SCF_Config_activate
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...                             scf_path=${SCF_Path}${SCF_Name}
    Log To Console    full commission result: ${out}

SCF_Config_activate_CD
    [Arguments]    ${scf_path}
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...                             scf_path=${scf_path}
    Log To Console    full commission result: ${out}

Check_CellandSite_Status
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=SITE_ONAIR+CELL_ONAIR

Common Suite Setup For RRM
    _Create Suite Directory

Case Postcondition
    [Arguments]    ${ue_index}=${0}
    Log To Console    ${ue_index}
    log to console    Case Postcondition
    Common Test Teardown For RRM

Prepare And Attach UE For Qualcomm
    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_QUALCOMM_UE
    set test variable    ${ue_type}    qualcomm
    Log to Console    \n***Prepare UE***
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    Detach UE    ue_index=${ue_index}    ue_type=qualcomm
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_type}

Start big data DL Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    ...            ${RemoteHost}=10.108.237.194    ${Account}=ute    ${Password}=Ut3pa5s#ff97
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    dt_index=${ue_index}
    ...              throughput=2000M    duration=${600}    RemoteHost=${RemoteHost}
    ...              Account=${Account}     Password=${Password}
Stop Call For UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    Log to Console    \n***Prepare to Stop a Call..***
    Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    sleep    5s    reason=wait call stoped
    Log to Console    \n***Call stoped..***

Initialize PA Signal
    SetInitializePAValue    pa_port=1-32;    pa_value=120;

Modify PA Signal For Source
    ${source_pa_port_list}     Create List     9
    ${source_pa_value_list}    Create List     127    0
    Modify PA Only In Source    source_pa_port_list=${source_pa_port_list}
    ...                         source_pa_value_list=${source_pa_value_list}
    ...                         step=${10}

Modify PA Signal For Source And Target
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     127    20
    ${target_pa_port_list}     Create List    5    6    9
    ${target_pa_value_list}    Create List    0    127
    Modify PA    source_pa_port_list=${source_pa_port_list}
    ...          source_pa_value_list=${source_pa_value_list}
    ...          target_pa_port_list=${target_pa_port_list}
    ...          target_pa_value_list=${target_pa_value_list}
    ...          step=${10}

Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller startLS

start_log_collection
    [Arguments]  ${log_type}=emil+syslog+cell_trace
    ${dict_argument}  Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start  ${log_type}  product_type=gnb  bts_index=${0}  cudu_index=${0}  dict_argument=${dict_argument}

Check Log For CB006139_BA_01
    [Arguments]    ${trace_file}
    ${trace_message_count}    Create Dictionary    UeContextModificationRequest=0    CuCaConfigurationTraceRecord=0
    ${multi_filters}   catenate   SEPARATOR=    "User data"="F1AP: UeContextModificationRequest";
    ...    "User data"="CU: CuCaConfigurationTraceRecord";
    ${json_file_list}=    Log Analysis   check   cell_trace   ${trace_file}   filter_cell_trace=${multi_filters}    convert_type=json
    ${trace_info_list}    Get trace info from json file    ${json_file_list}
    FOR    ${trace}    IN    @{trace_info_list}
        FOR    ${trace}    IN    @{trace}
            ${User_data}=    Set Variable    ${trace}[User_data]
            ${prefix}  ${record_type}   Split String From Right    ${User_data}    :${SPACE}    1
            ${tmp_info}=    Run Keyword If    '${record_type}' == 'UeContextModificationRequest'
                ...    Run Keyword And Ignore Error    Check UE Context Modification Request    ${trace}    exp_reason=pdcpCountWraparound
            ...    ELSE IF    '${record_type}' == 'CuCaConfigurationTraceRecord'
                ...    Run Keyword And Ignore Error    Check Cu Ca Configuration Trace Record    ${trace}
            ...    ELSE     Log To Console    \nThe value of user dta is unexpected!
            Run Keyword If    '${tmp_info}[0]' == 'PASS'    Add Value To Dictionary Key    ${trace_message_count}    ${record_type}    1
        END
    END
    Log To Console    The trace_message_count dict is: ${trace_message_count}

    Should Be True    ${trace_message_count}[UeContextModificationRequest] >= ${0}
    Should Be True    ${trace_message_count}[CuCaConfigurationTraceRecord] >= ${1}

Get trace info from json file
    [Arguments]    ${file_path}
    ${trace_info_list}    Create List
    FOR    ${file}    IN    @{file_path}
        ${parsed_json}    OperatingSystem.Get File    ${file}
        ${context_dict}    json.Loads    ${parsed_json}
        ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
        Run Keyword If    ${trace_info} != []    Append to list    ${trace_info_list}    ${trace_info}
        ...    ELSE    Log    The trace info is empty
    END
    [Return]    ${trace_info_list}

Check Log For CB006139_BA_02
    [Arguments]    ${trace_file}
    ${trace_message_count}    Create Dictionary    UeContextModificationRequest=0    DuCaConfigurationTraceRecord=0
    ${multi_filters}   catenate   SEPARATOR=    "User data"="F1AP: UeContextModificationRequest";
    ...    "User data"="DU: DuCaConfigurationTraceRecord";
    ${json_file_list}=    Log Analysis   check   cell_trace   ${trace_file}   filter_cell_trace=${multi_filters}    convert_type=json
    ${trace_info_list}    Get trace info from json file    ${json_file_list}
    FOR    ${trace}    IN    @{trace_info_list}
        FOR    ${trace}    IN    @{trace}
            ${User_data}=    Set Variable    ${trace}[User_data]
            ${prefix}  ${record_type}   Split String From Right    ${User_data}    :${SPACE}    1
            ${tmp_info}=    Run Keyword If    '${record_type}' == 'UeContextModificationRequest'
                ...    Run Keyword And Ignore Error    Check UE Context Modification Request    ${trace}    exp_reason=pdcpCountWraparound
            ...    ELSE IF    '${record_type}' == 'DuCaConfigurationTraceRecord'
                ...    Run Keyword And Ignore Error    Check Du Ca Configuration Trace Record    ${trace}
            ...    ELSE     Log To Console    \nThe value of user dta is unexpected!
            Run Keyword If    '${tmp_info}[0]' == 'PASS'    Add Value To Dictionary Key    ${trace_message_count}    ${record_type}    1
        END
    END
    Log To Console    The trace_message_count dict is: ${trace_message_count}

    Should Be True    ${trace_message_count}[UeContextModificationRequest] >= ${1}
    Should Be True    ${trace_message_count}[DuCaConfigurationTraceRecord] > ${1}

Start Counter For CB006139_AAD
    #M55190C00001    M55187C00001    M55187C00003    M55205C00001    M55118C00032
    ${rule1}    Catenate
    ...         Distname: MRBTS-10772/NRBTS-10772/NRCELL-9;
    ...         Counter: M55190C00001;
    ...         Counter rule: max(M55190C00001)>=1;
    ${rule2}    Catenate
    ...         Distname: MRBTS-10772/NRBTS-10772/NRCELL-9;
    ...         Counter: M55187C00001;
    ...         Counter rule:max(M55187C00001)>=1;
    ${rule3}    Catenate
    ...         Distname: MRBTS-10772/NRBTS-10772/NRCELL-9;
    ...         Counter: M55187C00003;
    ...         Counter rule: max(M55187C00003)>=1;
    ${rule4}    Catenate
    ...         Distname: MRBTS-10772/NRBTS-10772/NRCELL-9;
    ...         Counter:M55205C00001;
    ...         Counter rule:max(M55205C00001)>=1;
    ${rule5}    Catenate
    ...         Distname: MRBTS-10772/NRBTS-10772/NRCELL-9;
    ...         Counter: M55118C00032;
    ...         Counter rule:max(M55118C00032)>=1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                                                     counter_rule=${rule_list}

Collect And Check Counter
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb
    ...                               bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}

Teardown_for_OAM
    HAZ TC02 Get SCF Internal Id By Scout  no_ute=False
    Common Test Teardown For RRM


