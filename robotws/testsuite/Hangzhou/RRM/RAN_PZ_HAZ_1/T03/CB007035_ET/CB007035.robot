*** Settings ***
Documentation
...   author: Sijia Zhang
...   contact: sijia.zhang@nokia-sbell.com
...   this is a robot case about CB007035
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDROID_ASIMR_ABIP_ABIO_ABIQ_AHFIB_AHLOA_AZHL_AVQQA
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
# ${DEBUGMODE}      ${True}
${PA_MaxValue}    ${60}
${PA_NormalValue}    ${50}
${PA_MediumValue}    ${35}
${PA_MinValue}    ${0}
${ChangePA_MinValue}    ${20}
${PASwap_MIN_Value}    ${10}
${MRBTSID}               302
${NRBTSID}               302
${spark_iperf_server}      10.108.233.142
&{fault_4527}              faultId=${4527}
&{fault_4602}              faultId=${4602}
&{fault_4741}              faultId=${4741}
&{fault_61618}             faultId=${61618}
@{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}
${B1HORSRP}               b1ThresholdRsrp
${adminState}             administrativeState
${dist_name}              MRBTS-302/LNBTS-6093
${dist_name1}             MRBTS-302/LNBTS-6093/LNCEL-11
${dist_name2}             MRBTS-302/LNBTS-6093/LNCEL-11/LNHON-0
${MOC_list1}                MRBTS-302/NRBTS-6093/LNCEL-11/SIB-0
${MOC_list2}                MRBTS-302/NRBTS-6093/LNCEL-12/SIB-0
${Redirect From NR to LTE1}      Trigger the rrcReleaseWithRedirectProcedure for voice fallback
${Redirect From NR to LTE2}      measurementType\:B1Redirection
${Redirect From NR to LTE3}      Setup B1 Redirect Measurement
${all_imsi_list}        262033100000002,262033100000003,262033100000006,262033031503107,262033031503108,
...    262033031503159,262033031503147,262033031503151
${3UE_imsi_list}        262033100000002,262033100000003,262033100000006
*** Test Cases ***

CB007035-SR-A-19 NR SBHO is triggered based on received NR SBHO B1-NR measurement report
    [Documentation]    author: Zhang Sijia
    [Tags]    10_5_UTESRAN001T302    SCF_10_5_UTESRAN001T302_CB007035    SWCONFIG_10_5_UTESRAN001T302
    # ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    # ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    ${rule1}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8089C11;
    ...    Counter rule: max(M8089C11)>=1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8089C12;
    ...    Counter rule: max(M8089C12)>=1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8021C61;
    ...    Counter rule: max(M8021C61)>=1;
    ${rule4}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8021C62;
    ...    Counter rule: max(M8021C62)>=1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Initial Case19 PA     #low single for Pcell
    Start Multi Bts Log
    Run Keyword And Ignore Error    Start Capture Emil Log By VM dcap    bts_index=${0}
    AT Operation    attach    ue_index=7
    AT Operation    start_traffic    ue_index=7  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    Sleep    90s
    Check non EN-DC State
    Check SBHO triggered
    AT Operation    stop_traffic  ue_index=7   remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    AT Operation    detach    ue_index=7
    Stop All Bts Log
CB007035_TMOUS_CVR_001 EPS Fallback from TMOUS configuration
    [Documentation]    author: Zhang Sijia
    [Tags]    10_5_UTESRAN001T302    SCF_10_5_UTESRAN001T302_CB007035    SWCONFIG_10_5_UTESRAN001T302
    # ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    # ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    ${rule1}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8089C11;
    ...    Counter rule: max(M8089C11)>=1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8089C12;
    ...    Counter rule: max(M8089C12)>=1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8021C61;
    ...    Counter rule: max(M8021C61)>=1;
    ${rule4}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8021C62;
    ...    Counter rule: max(M8021C62)>=1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Initial Pcell PA     #low single for Pcell
    Start Multi Bts Log
    Run Keyword And Ignore Error    Start Capture Emil Log By VM dcap    bts_index=${0}
    AT Operation    attach    ue_index=7
    Sleep    10s
    AT Operation    start_call    ue_index=7  number=6688
    Sleep    10s
    Check VoLTE present
    # ENDC PScell PA
    AT Operation    start_traffic    ue_index=7  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    Check EN-DC release
    AT Operation    stop_call    ue_index=7
    Sleep    90s
    Check EN-DC State
    Check SBHO triggered
    Check selection non ENDC PCI triggered
    AT Operation    stop_traffic  ue_index=7   remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    AT Operation    detach    ue_index=7
    Stop All Bts Log
CB007035_TMOUS_CVR_002 interaction with ENDC onTMOUS configuration
    [Documentation]    author: Zhang Sijia
    [Tags]    10_5_UTESRAN001T302    SCF_10_5_UTESRAN001T302_CB007035    SWCONFIG_10_5_UTESRAN001T302
    # ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    # ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    ${rule1}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8089C11;
    ...    Counter rule: max(M8089C11)>=1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8089C12;
    ...    Counter rule: max(M8089C12)>=1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8021C61;
    ...    Counter rule: max(M8021C61)>=1;
    ${rule4}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8021C62;
    ...    Counter rule: max(M8021C62)>=1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Initial Pcell PA     #low single for Pcell
    Start Multi Bts Log
    LNHON RSRP change commission
    Run Keyword And Ignore Error    Start Capture Emil Log By VM dcap    bts_index=${0}
    AT Operation    attach    ue_index=7
    SBHO 41 NRCELL PA
    AT Operation    start_traffic    ue_index=7  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    Sleep    90s
    Check EN-DC State
    Check highest priority SBHO triggered
    Check selection ENDC PCI triggered
    AT Operation    stop_traffic  ue_index=7   remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    AT Operation    detach    ue_index=7
    Sleep    6 min    reason=wait for counter ready
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    interval=6
    Stop All Bts Log
CB007035_TMOUS_CVR_003 CB007742 disabled on TMOUS configuration
    [Documentation]    author: Zhang Sijia
    [Tags]    10_5_UTESRAN001T302    SCF_10_5_UTESRAN001T302_CB007035    SWCONFIG_10_5_UTESRAN001T302
    ${rule1}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-1;
    ...    Counter: M8089C11;
    ...    Counter rule: max(M8089C11)>=1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-1;
    ...    Counter: M8089C12;
    ...    Counter rule: max(M8089C12)>=1;
    ${rule3}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-1;
    ...    Counter: M8021C61;
    ...    Counter rule: max(M8021C61)>=1;
    ${rule4}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-1;
    ...    Counter: M8021C62;
    ...    Counter rule: max(M8021C62)>=1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Initial CVR03 Pcell PA     #low single for Pcell
    Start Multi Bts Log
    Run Keyword And Ignore Error    Start Capture Emil Log By VM dcap    bts_index=${0}
    AT Operation    attach    ue_index=4
    AT Operation    start_traffic    ue_index=4  IperfOptions=-u -i 1 -t 300 -b 60M -p 50001  direction=dl
    ...  remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    Change Pcell PA to B2
    SBHO 41 NRCELL PA
    Sleep    30s
    Change Pcell PA to B1
    Sleep    90s
    Check highest priority SBHO triggered
    AT Operation    stop_traffic  ue_index=4   remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    AT Operation    detach    ue_index=4
    Sleep    6 min    reason=wait for counter ready
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    interval=6
    Stop All Bts Log

CB007035-SR-D-01 NR SBHO B1-NR measurement report received from the UE counter threshold NOT crossed
    [Documentation]    author: Zhang Sijia
    [Tags]    10_5_UTESRAN001T302    SCF_10_5_UTESRAN001T302_CB007035    SWCONFIG_10_5_UTESRAN001T302
    ${rule1}    Catenate
    ...    Distname: MRBTS-302/LNBTS-6093/LNCEL-11;
    ...    Counter: M8080C173;
    ...    Counter rule: max(M8080C173)>=1;
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}
    Initial CVR04 Pcell PA     #low single for Pcell
    @{cell_list}=    Create List    21    312
    Change Commission To Lock cell    @{cell_list}
    Start Multi Bts Log
    Run Keyword And Ignore Error    Start Capture Emil Log By VM dcap    bts_index=${0}
    Active ANR
    Multi UE Attach
    Sleep    30s
    Sleep    6 min    reason=wait for counter ready
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    interval=6
    Stop All Bts Log

*** Keywords ***
Initial Pcell PA
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PASwap_MIN_Value}
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"nsa_nr5g_band\\",41
    AT Operation    exec_at_command    ue_index=7   command=AT+CFUN=1
    Sleep    10s
    AT Operation    exec_at_command    ue_index=7   command=AT+CFUN=0
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE:NR5G

Initial CVR03 Pcell PA
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PASwap_MIN_Value}
    AT Operation    exec_at_command    ue_index=4   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE
    AT Operation    exec_at_command    ue_index=4   command=AT+QNWPREFCFG=\\"lte_band\\",66
    AT Operation    exec_at_command    ue_index=4   command=AT+QNWPREFCFG=\\"nsa_nr5g_band\\",41
    AT Operation    exec_at_command    ue_index=4   command=AT+QNWPREFCFG=\\"nr5g_band\\",25:41
    AT Operation    exec_at_command    ue_index=4   command=AT+CFUN=1
    Sleep    10s
    AT Operation    exec_at_command    ue_index=4   command=AT+CFUN=0
    AT Operation    exec_at_command    ue_index=4   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE:NR5G
Initial CVR04 Pcell PA
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PASwap_MIN_Value}
    Log To Console    change UE5 capability
    AT Operation    exec_at_command    ue_index=5   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE
    AT Operation    exec_at_command    ue_index=5   command=AT+QNWPREFCFG=\\"lte_band\\",2
    AT Operation    exec_at_command    ue_index=5   command=AT+QNWPREFCFG=\\"nr5g_band\\",25:41
    AT Operation    exec_at_command    ue_index=5   command=AT+CFUN=1
    Sleep    10s
    AT Operation    exec_at_command    ue_index=5   command=AT+CFUN=0
    AT Operation    exec_at_command    ue_index=5   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE:NR5G
    Log To Console    change UE6 capability
    AT Operation    exec_at_command    ue_index=6   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE
    AT Operation    exec_at_command    ue_index=6   command=AT+QNWPREFCFG=\\"lte_band\\",2
    AT Operation    exec_at_command    ue_index=6   command=AT+QNWPREFCFG=\\"nr5g_band\\",25:41
    AT Operation    exec_at_command    ue_index=6   command=AT+CFUN=1
    Sleep    10s
    AT Operation    exec_at_command    ue_index=6   command=AT+CFUN=0
    AT Operation    exec_at_command    ue_index=6   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE:NR5G
    Log To Console    change UE7 capability
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"lte_band\\",2
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"nsa_nr5g_band\\",0
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"nr5g_band\\",25:41
    AT Operation    exec_at_command    ue_index=7   command=AT+CFUN=1
    Sleep    10s
    AT Operation    exec_at_command    ue_index=7   command=AT+CFUN=0
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE:NR5G
Initial Case19 PA
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PASwap_MIN_Value}
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"nsa_nr5g_band\\",25
    AT Operation    exec_at_command    ue_index=7   command=AT+CFUN=1
    Sleep    10s
    AT Operation    exec_at_command    ue_index=7   command=AT+CFUN=0
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE:NR5G

Change Pcell PA to B2  #B2 activate
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PA_MediumValue}
Change Pcell PA to B1  #B1 activate
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PA_MinValue}
ENDC PScell PA  #B2+N41 ENDC
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${0}    value=${PA_MediumValue}
SBHO 41 NRCELL PA
    Log To Console    PCI 485
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${0}    value=${PA_NormalValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${ChangePA_MinValue}
Initial Pcell PA case12
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_30}
Initial Pcell PA19
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_10}
Repeat attach
    Log To Console repeat attach
    Traffic Uebox Operation    detach    ue_imsi=262033100000003,262033100000006
    Sleep    10s
    Traffic Uebox Operation    attach    ue_imsi=262033100000003,262033100000006
    Sleep    30s
    Traffic Uebox Operation    detach    ue_imsi=262033100000003,262033100000006
    Sleep    10s
    Traffic Uebox Operation    attach    ue_imsi=262033100000003,262033100000006
    Sleep    30s
Set previous_timestamp
    [Arguments]     ${timestamp}    ${previous_timestamp}
    ${time_difference}   Subtract Date From Date   ${timestamp}   ${previous_timestamp}
    Should Be True    9<${time_difference}<10.5

Multi UE Attach
    Log To Console    Multi UE Attach
    AT Operation    attach    ue_index=5
    AT Operation    attach    ue_index=6
    AT Operation    attach    ue_index=7
    Sleep    10s
    AT Operation    start_traffic    ue_index=7  IperfOptions=-u -i 1 -t 300 -b 60M -p 50001  direction=dl
    ...  remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    Sleep    60s
    AT Operation    detach    ue_index=5
    AT Operation    detach    ue_index=6
    Sleep    1s
    AT Operation    attach    ue_index=5
    AT Operation    attach    ue_index=6
    Sleep    60s
    AT Operation    detach    ue_index=5
    AT Operation    detach    ue_index=6
    Sleep    1s
    AT Operation    attach    ue_index=5
    AT Operation    attach    ue_index=6
    Sleep    60s
    AT Operation    detach    ue_index=5
    AT Operation    detach    ue_index=6
    AT Operation    stop_traffic  ue_index=7   remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    Sleep    1s
    AT Operation    detach    ue_index=7
Check voLteBearerProtectTimer
    [Arguments]    ${Starting_voLteBearerProtectTimer_timestamp}  ${activating_timestamp}
    Log To Console    voLteBearerProtectTimer expired
    ${time_difference}    Subtract Date From Date    ${activating_timestamp}    ${Starting_voLteBearerProtectTimer_timestamp}
    Should Be True    14<${time_difference}<15.2

Check Supervisiontimer
    [Arguments]    ${deactivating_timestamp}  ${activating_timestamp}
    Log To Console    voLteBearerProtectTimer expired
    ${time_difference}    Subtract Date From Date   ${deactivating_timestamp}   ${activating_timestamp}
    Should Be True   2<${time_difference}<3.3

Check retrytimer
    [Arguments]     ${ret}
    Log To Console    retrytimer
    @{activating_line}    Evaluate    re.findall(r'.*activating 5G SB HO B1NR.*', '''${ret}''')    re
    ${lineNum}=    Split String      ${ret}    activating 5G SB HO B1NR
    ${lennum}=    Get length    ${lineNum}
    Should Be True  ${lennum}>3
    ${index}    Set Variable    ${0}
    ${previous_timestamp}     Set Variable    ${None}
    FOR    ${line}    IN    @{activating_line}
        ${timestamp}    Evaluate    str(re.search(r'<(.*?)>', '''${line}''').group(1))    re
        ${index}    Set Variable     ${index+1}
        ${previous_timestamp}   Set Variable if   ${index}==1   ${timestamp}
        ...    ${previous_timestamp}
        Continue For Loop If    ${index}==1
        Set previous_timestamp   ${timestamp}    ${previous_timestamp}
        ${previous_timestamp}    Set Variable     ${timestamp}
    END
Check EN-DC State
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check non EN-DC State
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should NOT Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check EN-DC release
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RELEASE_REQUEST | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RELEASE_REQUEST

Check VoLTE present
    Log To Console    check volte prevent SBHO B1-NR measurement activation
    ${ret}     OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "CB007035" | grep -av grep
    Should Contain     ${ret}     NRSBHO B1 will not be activated as active VoLTE/Mission Critical Video bearer is present

Check SBHO triggered
    Log To Console    check trigger SA 5G HO on mrWaitTimer expiry with stored meas reports
    ${ret}     OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "CB007035" | grep -av grep
    Should Contain     ${ret}     trigger SA 5G HO on mrWaitTimer expiry with stored meas reports

Check highest priority SBHO triggered
    Log To Console    check trigger SA 5G HO on mrWaitTimer expiry with stored meas reports
    ${ret}     OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "CB007035" | grep -av grep
    Should Contain     ${ret}     Received measurement with highest priority frequency result

Check selection non ENDC PCI triggered
    Log To Console    check priority stored meas reports
    ${ret}     OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "Adding target PCI 273" | grep -av grep
    Should Contain     ${ret}     to TCL
Check selection ENDC PCI triggered
    Log To Console    check priority stored meas reports
    ${ret}     OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "Adding target PCI 485" | grep -av grep
    Should Contain     ${ret}     to TCL

Check SBHO Not triggered BTS${i}
    Log To Console    check trigger SA 5G HO on mrWaitTimer expiry with stored meas reports
    ${ret}     csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "CB007035" | grep -av grep
    ...    connection=BTS${i}_VM
    Should Not Contain     ${ret}     trigger SA 5G HO on mrWaitTimer expiry with stored meas reports
Check MeasID Stored BTS${i}
    Log To Console    Check MeasID is Stored
    ${ret}     csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "Store Measurement report measId" | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain     ${ret}     397970
    ${meas_id}    Evaluate    re.search(r'*Store Measurement report measId: (\d{2})', '''${ret}''').group(1)    re
    ${ed_line}    Evaluate    re.search(r'.*voLteBearerProtectTimer expired.*', '''${ret}''').group(0)    re
    [Return]    ${meas_id}

Check deactivated NR SBHO B1-NR measurements BTS${i}
    Log To Console    Check deactivated NR SBHO B1-NR measurements
    ${ret}     csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "CB007035" | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain     ${ret}     B1 will not be activated due to mobility measurements
Change Commission To Lock cell
    [Arguments]    @{cell_list}
    FOR   ${cell_i}    IN    @{cell_list}
        BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-${cell_i}    need_verify=yes
    END
Set B1HO RSRP
    [Documentation]    author:sijia
    [Arguments]    ${dist_name2}    ${bts_index}=0
    @{para_list}   Create List   b1ThresholdRsrp
    @{value_list}   Create List   -140
    @{mo_list}   Create List   ${dist_name2}
    ${out}   Parameter Operation    operation=parameter_update   product_type=enb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}

LNHON RSRP change commission
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${dict}=    create dictionary    parameterName=${B1HORSRP}
    ...                              operation=update
    ...                              value=16
    @{parameter_list}    Create List    ${dict}
    coam_admin.perform_object_recommissioning
    ...    dist_name=${dist_name2}
    ...    parameter_delta_list=${parameter_list}    operation=update    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission
Active ANR
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${dict}=    create dictionary    parameterName=actUeBasedAnrNrHo
    ...                              operation=update
    ...                              value=${true}
    @{parameter_list}    Create List    ${dict}
    coam_admin.perform_object_recommissioning
    ...    dist_name=${dist_name}
    ...    parameter_delta_list=${parameter_list}    operation=update    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission

Change Commission To Unlock cell
    [Arguments]    @{cell_list}
    FOR   ${cell_i}    IN    @{cell_list}
        BTS Operation    operation=cell_unlock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-${cell_i}    need_verify=${False}
    END

Start UL Traffic
    [Arguments]    ${tput}=50M    ${tport}=5001    ${server_ip}=${spark_iperf_server}
    Connect All VM
    ADB.Start Traffic    tput_type=UL
    ...    server_ip=${server_ip}
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0
    ...    client_iperf_path=/data/iperf
    ...    tput_port=${tport}
    ...    tput_value=${tput}
    ...    tput_time=300s
    #Sleep    90s

Stop UL Traffic
    Connect All VM
    ADB.Stop Traffic     tput_type=UL
    ...    iperf_port=50002
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0

Send And Cap DL Traffic
    [Arguments]    ${tput}=50.00M
    Connect All VM
    ${ueip}=    AT Operation    get    ue_index=7  item=ueip    intf_name=ims
    gnb_tool.prepare_gnb_tool
    ${dl_server1}    Connect To IperfServer From Appservers
    ${ueip}    Start DL traffic By Iperf    time=6000    traffic=${tput}    dl_server=${dl_server1}
    ...    DL_port=${5001}

Start Capture Emil Log By VM dcap
    [Arguments]    ${bts_index}=${0}    ${product_type}=gnb
    start_dcap_controller_common
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    emil
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    dict_argument=${dict_argument}

Stop Emil Log Collection
    [Arguments]    ${bts_index}=${0}    ${product_type}=gnb
    ${local_file_path}    Log Collection    stop_and_download    emil
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    Log To Console    \nTTI log: ${local_file_path}
    [Return]    ${local_file_path}
Kill sparkexe
    Log To Console    restore sparkUE
    Traffic Uebox Operation    detach    ue_imsi=${all_imsi_list}
    csn.connect_to    10.56.218.7    username=MTU   password=MTU   alias=uebox    port=2222
    ${ret}    csn.execute    command=taskkill /f /im Spark.exe    connection=uebox

Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}
    Run Keyword    AT.Prepare UE
    # Run Keyword And Ignore Error    AT.reboot UE
    Run Keyword And Ignore Error    sleep     10s
Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    sleep     5s
    Run Keyword And Ignore Error    Stop UL Traffic
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${5001}
    Run Keyword And Ignore Error    Init Attenuation All Max    max_value=${PA_MaxValue}
    Run Keyword And Ignore Error    AT Operation    detach    ue_index=5
    Run Keyword And Ignore Error    AT Operation    detach    ue_index=6
    Run Keyword And Ignore Error    AT Operation    detach    ue_index=7
    # Run Keyword And Ignore Error    Kill sparkexe
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    Stop Emil Log Collection    bts_index=${0}
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local

