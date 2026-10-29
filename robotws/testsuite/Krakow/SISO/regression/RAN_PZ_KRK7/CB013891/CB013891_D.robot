*** Settings ***
Force Tags      ASOG    AHPMDA    AREC    FXED    realUE    7_7_TSPY060

Documentation
...            author:       Marcin Duplaga, marcin.duplaga@nokia.com
...            maintainer:   Marcin Duplaga, marcin.duplaga@nokia.com

Resource     testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/CB013891/resources/CB013891_common.robot
Library      testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/CB013891/resources/CB013891_common.py

Suite Setup      Run Keywords    Common Suite Setup With OnAir Test Line Preparation
...                              swconfig_from_path=${SWCONFIG}    list_of_additional_allowed_alarms=${PREPARATION_ALARMS}
...                       AND    gnbru.Verify All Radio Units Are Online
...                       AND    gnbcell.Wait For All Cells To Be OnAir    timeout=300
Suite Teardown    Common Suite Teardown

Test Setup       Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}
...                       AND    Common Preconditions With Watching Alarms
Test Teardown    Run Keywords    Run Keyword If Test Failed    Upload SCF and Wait For All Cells to Be OnAir
...                       AND    Common Postconditions With Watching Alarms
...                       AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main Bts Metadata To Report


*** Variables ***
@{PREPARATION_ALARMS}       WiFi Configuration Issue

@{CUSTOM_ALLOWED_ALARMS}    Transmission path failure
...                         Cell blocked

@{ENB_ALLOWED_ALARMS}       Service account root access is enabled
...                         Ethernet port security is disabled
...                         SSH enabled
...                         R&D Service Port enabled
...                         LMP access via port 443
...                         @{PREPARATION_ALARMS}

@{ALLOWED_ALARM_SFP_LANE_LOCKED}    BTS configuration error (not enough HW for LCR)
...                                 Transmission path failure
...                                 No connection to unit
...                                 TRX initialization failure
...                                 @{ENB_ALLOWED_ALARMS}

&{actRATResetEnhancement}    actRATResetEnhancement=true
&{actRATResetEnhancement_distname}  MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1=${actRATResetEnhancement}
${SWCONFIG}    testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/CB013891/configs/swconfig.txt

${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_DATA_TRANSFER_DURATION}    120s
${DEFAULT_SEGMENT_SIZE}              1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_TPUT_UL_NR}                100Mbits/sec
${DEFAULT_TPUT_UL_LTE}               10Mbits/sec
${DEFAULT_DEVIATION_UL}              50%
${DEFAULT_TPUT_DL_NR}                380Mbits/sec
${DEFAULT_TPUT_DL_LTE}               60Mbits/sec
${DEFAULT_DEVIATION_DL}              50%
${UE_TYPE}                           quectel

${SEED}    ${None}
@{SFP_list}    1    3    4    8    9    13    14
@{RAT_list}    NR    LTE    GSM
@{L3_CALL_NETWORK_MODE}    NR    LTE

*** Test Cases ***
CB013891_Manual_SiSo_SM_Cell_Block_Unblock
    [Timeout]    2h
    Trigger Blocking and Unblocking All Cells By Frequency Band
    Trigger Blocking and Unblocking All Cells By RAT
    Trigger Blocking and Unblocking All Cells Except Designated L3 Call Cell
    Perform NR L3 Call With Traffic Verification
    Perform LTE L3 Call With Traffic Verification

CB013891_General_SiSo_RAT_Reset
    [Timeout]    2h
    ${shuffled_RAT_list}    ${seed}    Random List Shuffle    ${RAT_list}
    FOR    ${RAT_type}    IN    @{shuffled_RAT_list}
        Trigger CB013891 ${RAT_type} RAT Reset Scenario
    END

CB013891_General_SiSo_RU_module_reset_from_GUI
    [Timeout]    2h
    ${shuffled_L3_CALL_NETWORK_MODE}    ${seed}    Random List Shuffle    ${L3_CALL_NETWORK_MODE}
    Log to Console    Trigger All Radio Units Reset
    gnbru.Reset All Radio Unit From GUI
    Sleep    10s
    gnbcell.Wait For All Cells Statuses    operational_state=disabled    timeout=120
    Sleep    120s
    Log to Console    All Radio Units Reset Performed and Waiting For Them to be Online
    gnbru.Wait For All Radio Units To Be Online    timeout=180
    Log to Console    All Radio Units Online and Waiting For All Cells To Be OnAir
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Log to Console    All Cells are back OnAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{ENB_ALLOWED_ALARMS}
    Perform ${shuffled_L3_CALL_NETWORK_MODE}[0] L3 Call With Traffic Verification
    Perform ${shuffled_L3_CALL_NETWORK_MODE}[1] L3 Call With Traffic Verification

CB013891_Manual_SiSo_SM_BTS_Site_Reset
    [Timeout]    2h
    Repeat keyword    3 times    Trigger CB013891 Site Reset Scenario

CB013891_General_SiSo_SFP_lock_unlock_for_configuration_testing
    [Timeout]    6h
    [Setup]      Run Keywords    Change Custom Allowed Alarms    NEW_CUSTOM_ALLOWED_ALARM_LIST=${ALLOWED_ALARM_SFP_LANE_LOCKED}
    ...                   AND    Common Preconditions With Watching Alarms
    ${shuffled_L3_CALL_NETWORK_MODE}    ${seed}    Random List Shuffle    ${L3_CALL_NETWORK_MODE}
    ${shuffled_SFP_list}    ${seed}    Random List Shuffle    ${SFP_list}
    FOR    ${SFP}    IN    @{shuffled_SFP_list}
        Trigger CB013891 ${SFP} SFP Lock Unlock Operations
    END
    Perform ${shuffled_L3_CALL_NETWORK_MODE}[0] L3 Call With Traffic Verification
    Perform ${shuffled_L3_CALL_NETWORK_MODE}[1] L3 Call With Traffic Verification
