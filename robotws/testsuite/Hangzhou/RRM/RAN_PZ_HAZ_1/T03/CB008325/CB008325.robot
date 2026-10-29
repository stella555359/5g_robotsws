*** Settings ***
Documentation
...   author: Jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB008325
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
#...                     CDRT
#...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_ASIL_ABIP2_AZHM_AHEGB-ASILR_ABIP2_AZHL_AHEGB
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${120}
${PA_NormalValue}        ${1}
${PA_HoValue}            ${25}
${PA_MinValue}           ${0}
${Handover_MAX_Value}    ${60}
${Handover_MIN_Value}    ${0}
${Gnb2_id}               ${10788}
${UE_IP}                 10.70.214.155
&{fault_7300}              faultId=${7300}
&{fault_6331}              faultId=${6331}
@{Ohter_Allow_Alarms}      &{fault_7300}    &{fault_6331}
${scf_for_reload}          10_5_UTESRAN001T10787_CB008325_07_2
# ${DEBUG_MODE}              ${True}


*** Test Cases ***
# Upgrade
#     [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
#     Run Feature Case
#     [Teardown]    TL Suite Teardown

# CB008325_07_CB007333_Automatic X2 setup for new enbControlled LNADJGNB with IP address retrieval of gNB via S1 interface
#     [Documentation]    author:Jiahao.chen
#     [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB008325_07_2
#     Start Multi Bts Log
#     Unblock source Cell

CB008325_07_CB007333_Automatic X2 setup for new enbControlled LNADJGNB with IP address retrieval of gNB via S1 interface
    [Documentation]    author:Jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB008325_07
    Start Multi Bts Log
    Connect To FCT    host=${BTS0_INFO.IP}    username=${BTS0_INFO.USERNAME}
    ...    password=${BTS0_INFO.PASSWORD}    alias=BTS0_LOCAL_Conn
    # Start tcpdump by command For Remote    bts_index=${0}
    Change Delta Commission    connection=COAM_0
    sleep    60s
    # Stop tcpdump And download by command For Remote    bts_index=${0}
    # Check MMEConfigurationTransfer
    Check cPlaneIpAddr and x2ToGnbLinkStatus

    Reload SCF For Current BTS

CB008325_03_ABIP_ENDC mobility_inter_eNB x2 handover
    [Documentation]    author:Jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB008325_03
    Start Multi Bts Log
    AT.Prepare UE
    # Change Commission To Lock cell NRcell111
    # Change Commission To Lock cell NRcell84
    Unblock source Cell
    AT.UE Attach
    sleep    20s
    Unblock target Cell
    sleep    10s
    block source cell
    sleep    20s
    Stop All BTSLog And Download to Local
    Check Handover For BTS0
    Check ENDC For BTS0
    # [Teardown]    Run Keywords    Case Teardown    AND
    # ...    Common MultiBTS Test Teardown For RRM     other_method=Commission Golden SCF For All GNB

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local

Change Delta Commission
    [Arguments]    ${connection}
    ${new_dist_name}    Set Variable    MRBTS-${BTS${0}_INFO.MRBTSID}/LNBTS-${BTS${0}_INFO.MRBTSID}/LNADJGNB-1
    ${unlocked_administrativeState}    create dictionary    parameterName=administrativeState
    ...    operation=update    value=unlocked
    ${new_object}    Create List    ${unlocked_administrativeState}
    coam.perform_object_recommissioning    dist_name=${new_dist_name}
    ...    parameter=${new_object}    operation=update
    ...    connection=${connection}

Check MMEConfigurationTransfer
    Log To Console     Check MMEConfigurationTransfer
    Download wireshark log to testvm For Remote    bts_index=${0}
    ${output}    Parse Pcap by expression    input_file=${TEST_LOG_DIRECTORY}/${tcpdump_log_name_${0}}
    ...    filter_expression=s1ap.transportLayerAddressIPv4 == 10.69.221.14
    Log To Console    ${output}

Check cPlaneIpAddr and x2ToGnbLinkStatus
    ${ret}    coam.get parameters   dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1
    ...    connection=COAM_0
    ${dist_name}    Set Variable    ${ret}[currentNp]/SCF-1/MRBTS_A-10787/LNBTS_A-10787/LNADJGNB_A-1
    Set Test Variable    ${dist_name}
    ${val}    coam.get_parameters    dist_name=${dist_name}
    ...    pattern=cPlaneIpAddr
    ...    connection=COAM_0
   Should Be Equal    ${val}[cPlaneIpAddr]    10.69.221.14
    ${val}    coam.get_parameters    dist_name=${dist_name}
    ...    pattern=x2ToGnbLinkStatus
    ...    connection=COAM_0
   Should Be Equal    ${val}[x2ToGnbLinkStatus]    available

Change Commission To Lock cell NRcell111
    COAM_Admin.lock    dist_name=MRBTS-${MRBTSID}/NRBTS-11436/NRCELL-111
    ...    connection=COAM_0

Change Commission To Lock cell NRcell84
    COAM_Admin.lock    dist_name=MRBTS-${Gnb2_id}/NRBTS-11437/NRCELL-84
    ...    connection=COAM_1

Unblock source Cell
    Log To Console    Unblock source Cell
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_NormalValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${1}    value=${PA_NormalValue}
Unblock target Cell
    Log To Console    Unblock target Cell
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_NormalValue}

block source cell
    Log To Console    Unblock target Cell
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_HoValue}

Check Handover For BTS${i}
    Log To Console    Check Handover
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "X2AP_HANDOVER_REQUEST_ACKNOWLEDGE" | grep -av grep
    Should Contain    ${ret}    X2AP_HANDOVER_REQUEST_ACKNOWLEDGE

Check ENDC For BTS${i}
    Log To Console    Check ENDC
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "X2AP_SGNB_RECONFIGURATION_COMPLETE" | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Reload SCF For Current BTS
    ${TestLine_Name_without_localtion}    Split String    ${TestLine_Name}
    Log      ${TestLine_Name_without_localtion}
    ${scf_file_path}    Join Path    ${SCF_DIR_PATH}    ${TestLine_Name_without_localtion[-1]}    ${scf_for_reload}.xml
    Log      ${scf_file_path}
    ${is_exist}    Run Keyword And Return Status    File Should Exist    path=${scf_file_path}
    Should Be True      ${is_exist}
    Commission Golden SCF For One GNB      timeout=${600}    bts_index=${0}    scf_file_path=${scf_file_path}
    Wait All GNB Status    expect_status=OnAir
