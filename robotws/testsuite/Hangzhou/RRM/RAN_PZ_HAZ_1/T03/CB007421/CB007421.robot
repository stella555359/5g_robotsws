*** Settings ***
Documentation
...   author: anyu
...   contact: anyu
...   this is a robot case about CB007421
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
#...                     CDRT
#...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBL_ABIAB3_FRPA_FRHF_AHEGB_FRHF-ASIBL_ABIL_AEQE
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${93}
${PA_NormalValue}        ${1}
${PA_HoValue}            ${20}
${PA_MinValue}           ${0}
${Handover_MAX_Value}    ${60}
${Handover_MIN_Value}    ${0}
${UE_IP}                 10.108.164.162
&{fault_7300}              faultId=${7300}
@{Ohter_Allow_Alarms}      &{fault_7300}

*** Test Cases ***
Upgrade
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Run Feature Case
    [Teardown]    TL Suite Teardown

CB007421_CB007333_01_Automatic X2 setup for new enbControlled LNADJGNB with IP address retrieval of gNB via S1 interface
    [Documentation]    author:anyu
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB007421_7333
    Start Multi Bts Log
    # Start tcpdump by command For Remote    bts_index=${2}
    Change Delta Commission    connection=COAM_2
    sleep    30s
    # Stop tcpdump And download by command For Remote    bts_index=${2}
    sleep    10s
    # Check MMEConfigurationTransfer
    Check cPlaneIpAddr and x2ToGnbLinkStatus
    [Teardown]    Run Keywords    Case Teardown    AND
    ...    Common MultiBTS Test Teardown For RRM     other_method=Commission Golden SCF For All GNB

CB007421_CB006607_Intra-eNB interFreq ENDC HO success
    [Documentation]    author:anyu
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB007421_6607
    Start Multi Bts Log
    attach to cell32
    Unblock BTS10768 Cell
    AT.UE Attach
    sleep    10s
    Check Handover For BTS2
    Check ENDC For BTS2
    Stop All BTSLog And Download to Local
    [Teardown]    Run Keywords    Case Teardown    AND
    ...    Common MultiBTS Test Teardown For RRM     other_method=Commission Golden SCF For All GNB

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

Check ULCA ADD For BTS${i}
    Log To Console    Check ULCA ADD
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a sCellIdSelectedForUlCa | grep -av grep
    Should Contain    ${ret}    sCellIdSelectedForUlCa

Check EN-DC State For BTS${i}
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check ULCA DLE For BTS${i}
    Log To Console    Check ULCA DLE
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a ScellReconfigurationActionForEndc: ScellDowngrade for SCell | grep -av grep
    Should Contain    ${ret}    ScellReconfigurationActionForEndc: ScellDowngrade for SCell

Stop All Bts Log
    Stop All BTSLog And Download to Local

Change Delta Commission
    [Arguments]    ${connection}
    ${new_dist_name}    Set Variable    MRBTS-${BTS${2}_INFO.MRBTSID}/LNBTS-${BTS${2}_INFO.MRBTSID}/LNADJGNB-1
    ${unlocked_administrativeState}    create dictionary    parameterName=administrativeState
    ...    operation=update    value=unlocked
    ${new_object}    Create List    ${unlocked_administrativeState}
    coam.perform_object_recommissioning    dist_name=${new_dist_name}
    ...    parameter=${new_object}    operation=update
    ...    connection=${connection}

Check MMEConfigurationTransfer
    Log To Console     Check MMEConfigurationTransfer
    Download wireshark log to testvm For Remote    bts_index=${2}
    ${output}    Parse Pcap by expression    input_file=${TEST_LOG_DIRECTORY}/${tcpdump_log_name_${2}}
    ...    filter_expression=s1ap.transportLayerAddressIPv4 == 10.108.231.24
    Log To Console    ${output}

Check cPlaneIpAddr and x2ToGnbLinkStatus
    ${ret}    coam.get parameters   dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1
    ...    connection=COAM_2
    ${dist_name}    Set Variable    ${ret}[currentNp]/SCF-1/MRBTS_A-10768/LNBTS_A-10768/LNADJGNB_A-1
    Set Test Variable    ${dist_name}
    ${val}    coam.get_parameters    dist_name=${dist_name}
    ...    pattern=cPlaneIpAddr
    ...    connection=COAM_2
   Should Be Equal    ${val}[cPlaneIpAddr]    10.108.231.24
    ${val}    coam.get_parameters    dist_name=${dist_name}
    ...    pattern=x2ToGnbLinkStatus
    ...    connection=COAM_2
   Should Be Equal    ${val}[x2ToGnbLinkStatus]    available

Unblock BTS10768 Cell
    Log To Console    Unblock BTS10768 Cell
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${2}    value=${PA_NormalValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${2}    value=${PA_HoValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${2}    value=${PA_HoValue}

Check Handover For BTS${i}
    Log To Console    Check Handover
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "Endc steered handover trigger start by A5 event" | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    Endc steered handover trigger start by A5 event

Check ENDC For BTS${i}
    Log To Console    Check ENDC
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "X2AP_SGNB_RECONFIGURATION_COMPLETE" | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

attach to cell32
    Log To Console    attach to cell32
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${2}    value=${PA_NormalValue}
    AT.Prepare UE
    AT.UE Attach
    sleep    10s
    AT.UE Detach
