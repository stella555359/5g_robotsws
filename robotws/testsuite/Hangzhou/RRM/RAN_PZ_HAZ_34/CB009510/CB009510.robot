*** Settings ***
Documentation     Author: Chen Yin
...               Email: yin.1.chen@nokia-sbell.com
...               Squad group: SG_02
Force Tags         5G_RRM
...    PY36
Suite Setup          robot_common_operations.Common Suite Setup
Suite Teardown       robot_common_operations.Common Suite Teardown
Library            OperatingSystem
Library            Collections
Library            BuiltIn
Library            String
Library            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource           Resources/CB009510_common_resources.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Variables          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009510/Resources/CB009510_variables.py


*** Variables ***
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}    #Service account root access is enabled
&{fault_4681}              faultId=${4681}    #Sanity Check Error
&{fault_61649}              faultId=${61649}    #LMP access via port 443
&{fault_4592}              faultId=${4592}    #BTS Reset Cause
&{fault_4459}              faultId=${4459}    #User Account has Default Password
@{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_4654}    &{fault_4655}    &{fault_4681}
              ...    &{fault_61649}    &{fault_4592}     &{fault_4459}
${UL_THROUGHPUT}    200M
${DL_THROUGHPUT}    2000M
${DURATION}    12000
${UL_TDD_EXPECT_100M}    50
${DL_TDD_EXPECT_100M}    500
${UL_TDD_EXPECT_30M}    5
${DL_TDD_EXPECT_30M}    50
@{nrCellIdentity}      22093828
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs


*** Test Cases ***
[1]CB009510_SR_B_01_Online modification_of_ssPbchBlockPower_or_Classical_BTS_gNB_and_SBTS
    [Tags]    QCID:859500
    [Setup]      Test Case Setup      scf_file_name=SCF_SBTS24R3_9510_B.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    UE Attach and Start Traffic      ue_type=${ue_type}
    ${status}      ${TPUT_before_update}      Run keyword and ignore error      Checking UE TPUT      ue_type=${ue_type}
    Setup aasyslog before log collectting      aa_sys_mode=5      aa_sys_addr=0xC0A8FF7E      aa_sys_udp_port=0xC738
    Start Collecting Syslog
    update parameter      parameter_list=${CB009510_update_pamater}
    Sleep      30s
    Collect Syslog
    Setup aasyslog before log collectting
    Checking syslog for ssPbchBlockPower
    ${status}      ${TPUT_after_update}      Run keyword and ignore error      Checking UE TPUT      ue_type=${ue_type}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[0]-${TPUT_after_update}[0]<${5}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[1]-${TPUT_after_update}[1]<${5}
    [Teardown]      RUN keywords       update parameter      parameter_list=${CB009510_recovery_update_pamater}
    ...      AND       UE Teardown      ue_type=${ue_type}
    ...      AND      Test Case Teardown



[1]CB009510_SR_B_03_Online modification of csirsPower for Classical BTS _gNB and SBTS
    [Tags]    QCID:859501
    [Setup]      Test Case Setup      scf_file_name=SCF_SBTS24R3_9510_B.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    UE Attach and Start Traffic      ue_type=${ue_type}
    ${status}      ${TPUT_before_update}      Run keyword and ignore error      Checking UE TPUT      ue_type=${ue_type}
    UE Teardown      ue_type=${ue_type}
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Connect to Common Unit Master     alias=ASIK Master
    Start CP-IF Log Collection     tcpdump_collector_name=tcpdump_${timestamp}
    ...                            asik_connection_alias=ASIK Master
    ...                            du_index=0
    ...                            options=-p -i any sctp -s 0
    update parameter      parameter_list=${CB009510_B_03_update_pamater}
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    UE Attach and Start Traffic      ue_type=${ue_type}
    sleep    20s
    ${status}      ${TPUT_after_update}      Run keyword and ignore error      Checking UE TPUT      ue_type=${ue_type}
    ${tcpdump_log}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...                                                        tcpdump_collector_name=tcpdump_${timestamp}
    ...                                                        target_dir=${TS_CASE_LOG_PATH}
    Checking powerControlOffsetSS in tcpdump during attach procedure      tcpdump_file_path=${tcpdump_log}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[0]-${TPUT_after_update}[0]<${5}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[1]-${TPUT_after_update}[1]<${5}
    [Teardown]      RUN keywords       update parameter      parameter_list=${CB009510_B_03_recovery_update_pamater}
    ...      AND       UE Teardown      ue_type=${ue_type}
    ...      AND      Test Case Teardown

[1]CB009510_SR_A_01_Online modification_of_ssPbchBlockPower_or_Classical_BTS_gNB_and_SBTS
    [Tags]    QCID:859500
    [Setup]      Test Case Setup      scf_file_name=SCF_SBTS24R3_9510_A.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    UE Attach and Start Traffic      ue_type=${ue_type}
    ${status}      ${TPUT_before_update}      Run keyword and ignore error      Checking UE TPUT      ue_type=${ue_type}
    Setup aasyslog before log collectting      aa_sys_mode=5      aa_sys_addr=0xC0A8FF7E      aa_sys_udp_port=0xC738
    Start Collecting Syslog
    update parameter      parameter_list=${CB009510_update_pamater}
    Sleep      30s
    Collect Syslog
    Setup aasyslog before log collectting
    Checking syslog for ssPbchBlockPower
    update parameter      parameter_list=${CB009510_recovery_update_pamater}
    Sleep      2min
    ${status}      ${TPUT_after_update}      Run keyword and ignore error      Checking UE TPUT      ue_type=${ue_type}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[0]-${TPUT_after_update}[0]<${5}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[1]-${TPUT_after_update}[1]<${5}
    [Teardown]      RUN keywords      UE Teardown      ue_type=${ue_type}
    ...      AND      Test Case Teardown



[1]CB009510_SR_A_03_Online modification of csirsPower for Classical BTS _gNB and SBTS
    [Tags]    QCID:859501
    [Setup]      Test Case Setup      scf_file_name=SCF_SBTS24R3_9510_A.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    UE Attach and Start Traffic      ue_type=${ue_type}
    ${status}      ${TPUT_before_update}      Run keyword and ignore error      Checking UE TPUT      ue_type=${ue_type}
    UE Teardown      ue_type=${ue_type}
    ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Connect to Common Unit Master     alias=ASIK Master
    Start CP-IF Log Collection     tcpdump_collector_name=tcpdump_${timestamp}
    ...                            asik_connection_alias=ASIK Master
    ...                            du_index=0
    ...                            options=-p -i any sctp -s 0
    update parameter      parameter_list=${CB009510_B_03_update_pamater}
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    UE Attach and Start Traffic      ue_type=${ue_type}
    sleep    20s
    ${status}      ${TPUT_after_update}      Run keyword and ignore error      Checking UE TPUT      ue_type=${ue_type}
    ${tcpdump_log}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...                                                        tcpdump_collector_name=tcpdump_${timestamp}
    ...                                                        target_dir=${TS_CASE_LOG_PATH}
    Checking powerControlOffsetSS in tcpdump during attach procedure      tcpdump_file_path=${tcpdump_log}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[0]-${TPUT_after_update}[0]<${5}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[1]-${TPUT_after_update}[1]<${5}
    [Teardown]      RUN keywords       update parameter      parameter_list=${CB009510_B_03_recovery_update_pamater}
    ...      AND       UE Teardown      ue_type=${ue_type}
    ...      AND      Test Case Teardown

[1][1.0] CB009510_SR_B_06_Online modification of parameters and UE attach-detach frequently for Classical BTS
    [Setup]      Test Case Setup      scf_file_name=SCF_SBTS24R3_9510_B.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    UE Attach and Start Traffic      ue_type=${ue_type}
    ${status}      ${TPUT_before_update}      Run keyword and ignore error      Checking UE TPUT      ue_type=${ue_type}
    ${timestamp}        Evaluate    datetime.datetime.now().strftime('%Y%m%d%H%M%S')    datetime
    Connect to Common Unit Master     alias=ASIK Master
    Start Bip Log with Suitable Means      target_file_name=l1l2bip_log_${timestamp}
    update parameter      parameter_list=${CB009510_B_06_update_pamater}
    sleep      1 min
    ${full_log_path}      Stop Bip Log with Suitable Means      target_file_name=l1l2bip_log_${timestamp}
    Checking numofprb in bip file       bip_path=${full_log_path}[0]
    ${status}      ${TPUT_after_update}      Run keyword and ignore error      Checking UE TPUT      ue_type=${ue_type}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[0]-${TPUT_after_update}[0]<${5}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[1]-${TPUT_after_update}[1]<${5}
    UE Teardown      ue_type=${ue_type}
    Start Bip Log with Suitable Means      target_file_name=l1l2bip_log_${timestamp}
    UE Attach and Start Traffic      ue_type=${ue_type}
    ${full_log_path_2nd}      Stop Bip Log with Suitable Means      target_file_name=l1l2bip_log_${timestamp}
    Checking numofprb in bip file       bip_path=${full_log_path_2nd}[0]
    ${status}      ${TPUT_after_update_2nd}      Run keyword and ignore error      Checking UE TPUT      ue_type=${ue_type}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[0]-${TPUT_after_update_2nd}[0]<${5}
    Run keyword and ignore error      Should Be True      ${TPUT_before_update}[1]-${TPUT_after_update_2nd}[1]<${5}
    [Teardown]      RUN keywords       update parameter      parameter_list=${CB009510_B_06_recovery_pamater}
    ...      AND       UE Teardown      ue_type=${ue_type}
    ...      AND      Test Case Teardown
