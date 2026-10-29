*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB005825TMO
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_ASIL_ABIO2_AHFIB2_AHLOB2_AEHC_AQQL
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${60}
${PA_NormalValue}        ${30}
${PA_HoValue}            ${50}
${PA_MinValue}           ${0}

&{fault_4527}              faultId=${4527}
&{fault_4602}              faultId=${4602}
&{fault_4741}              faultId=${4741}
&{fault_6327}              faultId=${6327}
&{fault_6915}              faultId=${6915}
&{fault_61618}             faultId=${61618}
&{fault_4001}              faultId=${4001}
&{fault_6331}              faultId=${6331}
&{fault_4153}              faultId=${4153}
@{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}
...    &{fault_6327}    &{fault_6915}    &{fault_4001}    &{fault_6331}    &{fault_4153}

# ${DEBUG_MODE}         ${True}

*** Test Cases ***
CB005825_17_PLMN selection for NR handover
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB005825_TMO_Case17
    AT.Prepare UE
    Start Multi Bts Log
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    sleep    20s
    Check HO type for BTS1
    Check InterRatToNr for BTS1

CB005825_02_NR neighbor creation when number of unknown B2-NR MRs has crossed threshold no confusion detected
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB005825_TMO_Case02
    AT.Prepare UE
    Start Multi Bts Log
    Unblock LNCell_21
    AT.UE Attach
    Sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    10s
    # Check nrAnrHoPciCounter For BTS1
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    10s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    10s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    10s
    # Check nbrPciHoCounters = 4 For BTS1
    Block NRCell_5

    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    Unblock NRCell_5
    sleep    300s
    Check LNRELN ADD For BTS1

CB005825_03_NR neighbor creation when number of unknown B2-NR MRs has crossed threshold B1-NR MR already reported
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB005825_TMO_Case03
    AT.Prepare UE
    Start Multi Bts Log
    Unblock LNCell_21
    AT.UE Attach
    Sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    20s
    # Check nrAnrHoPciCounter For BTS1
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    15s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    15s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    20s
    # Check nbrPciHoCounters = 4 For BTS1
    Block NRCell_5

    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    Unblock NRCell_5
    sleep    300s
    Check LNRELN ADD For BTS1

CB005825_05_LNRELN removal due to insufficient frequency of reports
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB005825_TMO_Case06
    AT.Prepare UE
    Start Multi Bts Log
    Unblock LNCell_21
    AT.UE Attach
    Sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    20s
    # Check nrAnrHoPciCounter For BTS1
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    15s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    15s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    20s
    # Check nbrPciHoCounters = 4 For BTS1
    Block NRCell_5
    Sleep    420s
    Check LNADJN_LNADJNL DEL For BTS1
    Check LNRELN_1 of LNCell21 DEL For BTS1

CB005825_06_Periodic LNADJN and LNADJNL removal due to no matching LNRELN found
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB005825_TMO_Case06
    AT.Prepare UE
    Start Multi Bts Log
    Unblock LNCell_21
    AT.UE Attach
    Sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    20s
    # Check nrAnrHoPciCounter For BTS1
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    15s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    15s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    20s
    # Check nbrPciHoCounters = 4 For BTS1
    Block NRCell_5
    Sleep    420s
    Check LNADJN_LNADJNL DEL For BTS1
    Check LNRELN_1 of LNCell21 DEL For BTS1

CB005825_07_NR handover neighbor re-validation when anrNrNbrHoRelVerifyPeriod has elapsed
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB005825_TMO_Case07
    AT.Prepare UE
    Start Multi Bts Log
    Unblock LNCell_21
    AT.UE Attach
    Sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    20s
    # Check nrAnrHoPciCounter For BTS1
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    15s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    15s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    20s
    # Check nbrPciHoCounters = 4 For BTS1
    Block NRCell_5

    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    Unblock NRCell_5
    sleep    300s
    Check LNRELN ADD For BTS1

    AT.UE Detach
    Block NRCell_5
    sleep    250s
    # Stop BTSLite For Btslog On VM1
    # Start BTSLite For Btslog On VM    1
    AT.UE Attach
    Sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    Check HO type for BTS1
    Check LNRELN relation to_be_verified For BTS1

    # AT.UE Detach
    # Block NRCell_5
    # Sleep    15s
    # Unblock LNCell_21
    # AT.UE Attach
    # sleep    15s
    # Unblock NRCell_5
    # sleep    300s
    # AT.UE Detach
    # Block NRCell_5
    # Sleep    15s
    # Check LNRELN relation verified_2 For BTS1


CB005825_16_CGI report to be used for both CB007334 and CB005825
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB005825_TMO_Case16
    AT.Prepare UE
    Start Multi Bts Log
    Unblock LNCell_21
    AT.UE Attach
    sleep    8s
    # Unblock NRCell_5
    # Sleep    20s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5 for case16
    AT.UE Detach
    sleep    10s
    # Check nrAnrHoPciCounter For BTS1
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    8s
    # Unblock NRCell_5
    # sleep    20s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5 for case16
    AT.UE Detach
    sleep    10s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    8s
    # Unblock NRCell_5
    # sleep    20s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5 for case16
    AT.UE Detach
    sleep    10s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    8s
    # Unblock NRCell_5
    # sleep    20s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5 for case16
    AT.UE Detach
    sleep    10s
    # Check nbrPciHoCounters = 4 For BTS1
    Block NRCell_5

    Unblock LNCell_21
    AT.UE Attach
    sleep    10s
    Unblock NRCell_5
    sleep    300s
    Check LNRELN ADD For BTS1
    Check LNRELGNBCELL ADD For BTS1

CB005825_13_Verify fault reporting when LNADJL exceeds limit
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB005825_TMO_Case13
    AT.Prepare UE
    Start Multi Bts Log
    Unblock LNCell_21
    AT.UE Attach
    Sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    20s
    # Check nrAnrHoPciCounter For BTS1
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    15s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    15s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    20s
    # Check nbrPciHoCounters = 4 For BTS1
    Block NRCell_5

    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    Unblock NRCell_5
    sleep    300s
    Check NO LNRELN ADD For BTS1
    Check alarm 5513 raised For BTS1

CB005825_19_Activation and configuration of ANR for LTE-5G Standalone
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB005825_TMO_Case19
    AT.Prepare UE
    Start Multi Bts Log
    Online change parameters actUeBasedAnrNrHo to true
    sleep    20s
    Unblock LNCell_21
    AT.UE Attach
    Sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    10s
    # Check nrAnrHoPciCounter For BTS1
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    10s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    10s
    Block NRCell_5
    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    AT.UE Detach
    sleep    10s
    # Check nbrPciHoCounters = 4 For BTS1
    Block NRCell_5

    Unblock LNCell_21
    AT.UE Attach
    sleep    15s
    Unblock NRCell_5
    sleep    300s
    Check LNRELN ADD For BTS1

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    Change Commission To Unlock cell
    # Run Keyword And Ignore Error    Restore APN by ADB
    Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    # Run Keyword If Test Passed     Collect Coam Snapshot For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Change Commission To Unlock cell
    COAM_Admin.unlock    dist_name=MRBTS-${MRBTSID}/NRBTS-${NRBTSID}/NRCELL-2
    ...    connection=COAM_0
    COAM_Admin.unlock    dist_name=MRBTS-${MRBTSID}/NRBTS-${NRBTSID}/NRCELL-5
    ...    connection=COAM_0
    COAM_Admin.unlock    dist_name=MRBTS-${MRBTSID}/NRBTS-${NRBTSID}/NRCELL-6
    ...    connection=COAM_0

Stop All Bts Log
    Stop All BTSLog And Download to Local

Set APN by ADB
    ADB.Prepare UE
    Log to Console    Start to set apn
    Sleep    10s
    Qualcomm.Set APN By Uiauto    apn=mdrb.nokia.com
    ${ret}=    Qualcomm.Get APN By Uiauto
    Should Contain    ${ret}    mdrb.nokia.com

Restore APN by ADB
    ADB.Prepare UE
    Log to Console    Start to set apn
    Sleep    10s
    Qualcomm.Set APN By Uiauto    apn=stdata1
    ${ret}=    Qualcomm.Get APN By Uiauto
    Should Contain    ${ret}    stdata1

Unblock LNCell_21
    Log To Console    Unblock LNCell_21
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MinValue}

Unblock NRCell_4
    Log To Console    Unblock NRCell_4
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PA_MinValue}

Block NRCell_4
    Log To Console    Block NRCell_4
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PA_MaxValue}

Unblock NRCell_5
    Log To Console    Unblock NRCell_4
    Modify Attenuation For One RRU Of One Site    ru_id=${10}    gnb_id=${0}    value=${PA_MinValue}

Block NRCell_5
    Log To Console    Block NRCell_4
    Modify Attenuation For One RRU Of One Site    ru_id=${10}    gnb_id=${0}    value=${PA_MaxValue}

HO from BTS11221 LNCell_21 to BTS11688 NRCell_4
    Log To Console    HO from BTS11221 LNCell_21 to BTS11688 NRCell_4
    ${increase_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${0}
    ${decrease_port_list}    Get Attenuation port    RU_id=${8}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}    ${45}
    ${decrease_value_list}    Create List    ${60}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${10}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    15s

HO from BTS11221 LNCell_21 to BTS11688 NRCell_5
    Log To Console    HO from BTS11221 LNCell_21 to BTS11688 NRCell_4
    ${increase_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${0}
    ${decrease_port_list}    Get Attenuation port    RU_id=${10}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}    ${45}
    ${decrease_value_list}    Create List    ${60}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${10}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    15s

HO from BTS11221 LNCell_21 to BTS11688 NRCell_5 for case16
    Log To Console    HO from BTS11221 LNCell_21 to BTS11688 NRCell_4
    ${increase_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${0}
    ${decrease_port_list}    Get Attenuation port    RU_id=${10}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}    ${45}
    ${decrease_value_list}    Create List    ${60}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${10}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    5s

Check nrAnrHoPciCounter For BTS${i}
    Log To Console    Check nrAnrHoPciCounter
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a nrAnrHoPciCounter | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    nrAnrHoPciCounter

Check nbrPciHoCounters = 4 For BTS${i}
    Log To Console    Check nrAnrHoPciCounter = 4
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'nrAnrHoPciCounter: 4' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    nrAnrHoPciCounter: 4

Check LNRELN ADD For BTS${i}
    Log To Console    Check NRRELN ADD
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'operation: Create : LNBTS-11221/LNCEL-21/LNRELN-255' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    operation: Create : LNBTS-11221/LNCEL-21/LNRELN-255

Check LNRELGNBCELL ADD For BTS${i}
    Log To Console    Check LNRELGNBCELL ADD
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'operation: Create : LNBTS-11221/LNCEL-21/LNRELGNBCELL-255' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    operation: Create : LNBTS-11221/LNCEL-21/LNRELGNBCELL-255

Check LNADJN_LNADJNL DEL For BTS${i}
    Log To Console    Check LNADJN_LNADJNL DEL
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'LNBTS-11221/LNADJN-0 : EModifier_Online:Delete' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    LNBTS-11221/LNADJN-0 : EModifier_Online:Delete

Check LNRELN_1 of LNCell21 DEL For BTS${i}
    Log To Console    Check LNRELN_1 of Cell22 DEL
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Export operation: Delete : LNBTS-11221/LNCEL-21/LNRELN-0' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    Export operation: Delete : LNBTS-11221/LNCEL-21/LNRELN-0

Check HO type for BTS${i}
    Log To Console    Check HO type
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a EHandoverType_InterRatToNr | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    EHandoverType_InterRatToNr

Check InterRatToNr for BTS${i}
    Log To Console    Check InterRatToNr
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Handover finished with success' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    Handover finished with success

Check LNRELN relation to_be_verified For BTS${i}
    Log To Console    Check LNRELN relation to_be_verified
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'InRelation ToBeVerified' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    InRelation ToBeVerified

Check LNRELN relation verified_2 For BTS${i}
    Log To Console    Check LNRELN relation verified_2
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'current profile status: Verified' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    current profile status: Verified

Check NO LNRELN ADD For BTS${i}
    Log To Console    Check NO LNRELN ADD
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'operation: Create : LNBTS-11221/LNCEL-21/LNRELN-255' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Not Contain    ${ret}    operation: Create : LNBTS-11221/LNCEL-21/LNRELN-255

Check alarm 5513 raised For BTS${i}
    Log To Console    Check alarm 5513 raised
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'active 5513' | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    active 5513

Online change parameters actUeBasedAnrNrHo to true
    Log To Console    Online change parameters actUeBasedAnrNrHo to true
    @{para_list}      Create List    actUeBasedAnrNrHo
    @{mo_list}        Create List    MRBTS-11221/LNBTS-11221
    @{value_list}     Create List    true
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb    bts_index=1
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}