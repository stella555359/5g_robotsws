*** Settings ***
Documentation
...   author: Nicky Lu
...   contact: nicky.lu@nokia-sbell.com
...   This is a performance testing robot case
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
#...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBR_ABIO_ABIL2_AEHC_AHFIB_AHLOA_AHFIG
...                     SBTS00
#...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}          ${127}
${PA_MinValue}          ${0}
${PA_NormalValue}       ${5}
${PA_NormalValue2}      ${20}
${UE_IP1}               172.250.80.5
${UE_IP2}               172.250.80.148
${Cell1_ID}             14532609
${Cell2_ID}             14532610
${Cell22_ID}            14532630
${Cell25_ID}            14532633
${Cell41_ID}            14532649
${Cell71_ID}            14532679
${1_60M_Value}          40000000
${1_Value}              80000000
${2_Value}              18750000
${22_Value}             18750000
${25_Value}             18750000
${41_Value}             18750000
${71_Value}             12500000

*** Test Cases ***
CB008428-SR_01_EFT-95_UDP_DL
    [Documentation]    Author: Nicky Lu
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_EFT-95
    Start Multi Iperf DL Traffic
    Start Multi Bts Log
    Attach UE To ENB And GNB
    AT Trigger UE Attach
    EFT-95 Tput Check

CB008428-SR_07_EFF-143_UDP_DL
    [Documentation]    Author: Nicky Lu
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_EFF-143
    Block Other Cells
    Start Multi Iperf DL Traffic
    Start Multi Bts Log
    Attach UE To EN-DC
    AT Trigger UE Attach
    EFF-143 Tput Check
    Unblock Other Cells

CB008532-5G_04_D5860_SA-81_SR100
    [Documentation]    Author: Nicky Lu
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_D5860-81
    Start Multi Iperf DL Traffic    ue_ip=${UE_IP2}
    Start Multi Bts Log
    Attach UE To GNB
    AT Trigger UE Attach      index_of_yaml=${1}
    Check CA State
    Run Keyword And Ignore Error    Check 4CC info
    D5860-81 Tput Check

CB008532-5G_12_D5860_SA-75_SR100
    [Documentation]    Author: Nicky Lu
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_D5860-75
    Start Multi Iperf DL Traffic    ue_ip=${UE_IP2}
    Start Multi Bts Log
    Attach UE To GNB
    Attach UE To Additional GNB
    AT Trigger UE Attach      index_of_yaml=${1}
    D5860-75 Tput Check

CB008542-5G_01_EFT-156_UDP_DL
    [Documentation]    Author: Nicky Lu
    [Tags]   10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_EFT-156
    Block Other Cells
    Start Multi Iperf DL Traffic
    Start Multi Bts Log
    Attach UE To EN-DC
    AT Trigger UE Attach
    EFT-156 Tput Check
    Unblock Other Cells

CB008542-5G_12_D5860-57_UDP_SR_100
    [Documentation]    Author: Nicky Lu
    [Tags]   10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_D5860-57
    Start Multi Iperf DL Traffic
    Start Multi Bts Log
    Attach UE To EN-DC    ru_id=${3}
    AT Trigger UE Attach
    D5860-57 Tput Check

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop Multi Iperf Servers
    Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Disconnect All VM

AT Trigger UE Attach
    [Documentation]    send command by AT cmd,will auto find the ue type
    [Arguments]    ${ue_index}=${0}    ${index_of_yaml}=${0}
    Log to console    Attach ue ${index_of_yaml}
    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${UE_TYPE}    ${ue_type}
    run keyword    ${UE_TYPE}.Prepare UE    ue_index=${ue_index}    index_of_yaml=${index_of_yaml}
    Wait Until Keyword Succeeds   3x   1min    ${UE_TYPE}.UE Attach    ue_index=${ue_index}
    ...    index_of_yaml=${index_of_yaml}
    Sleep    40s     msg=wait for ue attach success

Attach UE To ENB And GNB
    Log To Console    Attach UE To ENB And GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_MinValue}

Attach UE To GNB
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PA_NormalValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${5}    gnb_id=${0}    value=${PA_NormalValue}

Attach UE To Additional GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${0}    value=${PA_NormalValue}

Attach UE to EN-DC
    [Arguments]    ${ru_id}=${1}
    Log To Console    Attach UE to EN-DC
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_MinValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${ru_id}    gnb_id=${0}    value=${PA_NormalValue}

Check ENB Attach State
    Log To Console    Check ENB Attach State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a UEC_UEM_INITIAL_CONTEXT_SETUP_ATTACH | grep -av grep
    Should Contain    ${ret}    UEC_UEM_INITIAL_CONTEXT_SETUP_ATTACH

Check EN-DC State
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Block Other Cells
    Log To Console    Block other unused cells
    COAM_Admin.Block_CELL    global_cell_id=25    cell_type=lte    connection=COAM_1
    COAM_Admin.Block_CELL    global_cell_id=25    cell_type=nr    connection=COAM_0
    sleep    20s

Unblock Other Cells
    Log To Console    Unblock other unused cells
    COAM_Admin.unBlock_CELL    global_cell_id=25    cell_type=lte    connection=COAM_1
    COAM_Admin.unBlock_CELL    global_cell_id=25    cell_type=nr    connection=COAM_0
    Sleep    15s

Start Multi Iperf DL Traffic
    [Arguments]    ${ue_ip}=${UE_IP1}
    Log to console    Start Multi Iperf DL Traffic
    ${dl_server1}    Connect To IperfServer From Appservers    #index=${0}
    Start DL traffic By Iperf     DL_port=${tl.appservers[0].iperf_details.port}    traffic=1500.00M
    ...    ue_ip=${ue_ip}    dl_server=${dl_server1}    time=300
    ${dl_server2}    Connect To IperfServer From Appservers    index=${1}
    Start DL traffic By Iperf     DL_port=${tl.appservers[1].iperf_details.port}    traffic=1500.00M
    ...    ue_ip=${ue_ip}    dl_server=${dl_server2}    time=300
    Set Test Variable    ${dl_server1}
    Set Test Variable    ${dl_server2}

Stop Multi Iperf Servers
    Base.__Stop Traffic    client_connection=${dl_server1}
    Base.__Stop Traffic    client_connection=${dl_server1}

Tput Check by DataPdu
    [Arguments]    ${cell_id}    ${tput_value}
    ${datapdu}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "nrCellId ${cell_id} \\[TBS" | grep -av grep
    ${list}    Split String    ${datapdu}    \n
    FOR    ${line}    IN   @{list}
        ${A}    Split String    ${line}    |
        ${B}    Split String    ${A}[-1]    ]
        ${tput_real}    Convert to Integer    ${B}[0]
        ${tput_st}    ${v}    Run Keyword and Ignore Error    Should Be True    ${tput_real}>${tput_value}
        Exit FOR Loop if    "${tput_st}"=="PASS"
    END
    Run Keyword if    "${tput_st}"=="FAIL"    Fail    Target tput not reached

EFT-95 Tput Check
    Log To Console    Tput Check
    Tput Check by DataPdu    ${Cell1_ID}    ${1_60M_Value}

EFF-143 Tput Check
    Log To Console    Tput Check
    Tput Check by DataPdu    ${Cell1_ID}    ${1_60M_Value}
    Tput Check by DataPdu    ${Cell2_ID}    ${2_Value}

D5860-81 Tput Check
    Log To Console    Tput Check
    Tput Check by DataPdu    ${Cell25_ID}    ${25_Value}
    Tput Check by DataPdu    ${Cell41_ID}    ${41_Value}
    Tput Check by DataPdu    ${Cell1_ID}    ${1_Value}
    Tput Check by DataPdu    ${Cell22_ID}    ${22_Value}

D5860-75 Tput Check
    Log To Console    Tput Check
    Tput Check by DataPdu    ${Cell1_ID}    ${1_Value}
    Tput Check by DataPdu    ${Cell22_ID}    ${22_Value}
    Tput Check by DataPdu    ${Cell25_ID}    ${25_Value}
    Tput Check by DataPdu    ${Cell71_ID}    ${71_Value}

EFT-156 Tput Check
    Log To Console    Tput Check
    Tput Check by DataPdu    ${Cell1_ID}    ${1_Value}
    Tput Check by DataPdu    ${Cell2_ID}    ${2_Value}

D5860-57 Tput Check
    Log To Console    Tput Check
    Tput Check by DataPdu    ${Cell1_ID}    ${1_Value}
    Tput Check by DataPdu    ${Cell22_ID}    ${22_Value}

Check CA State
    Log To Console    Check CA State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "ConcreteCaSCellCandidateSelectionProcedure" | grep -av grep
    Should Contain    ${ret}    ConcreteCaSCellCandidateSelectionProcedure

Check 4CC info
    Log To Console    Check 4CC info
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "4CC solution" | grep -av grep
    Should Contain    ${ret}    4CC solution
