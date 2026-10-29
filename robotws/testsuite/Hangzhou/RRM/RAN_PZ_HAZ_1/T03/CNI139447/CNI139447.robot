*** Settings ***
Documentation
...   author: alex.1.wang
...   contact: alex.1.wang@nokia-sbell.com
...   this is a robot case about CNI139447
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CDRT
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIP2_AZHM_AHEGB-ASILR_ABIP2_AZHL_AHEGB
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_TC03_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${93}
${UE_IP}                 10.68.254.181


*** Test Cases ***
CNI-139447_TC02_NSA call handover interaction for EN-DC
    [Documentation]    author:alex.1.wang
    [Tags]    10_5_UTESRAN001T37541    SCF_10_5_UTESRAN001T37541_CNI139447_ENDC_TC02
    AT.UE Detach
    PA_Source_List_Only_Increase_Value
    sleep    10s
    AT.UE attach
    Start Multi Bts Log
    sleep    20s
    Start DL traffic 5QI5
    sleep    20s
    PA_Source_Target_List_Both
    sleep    30s



*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Change Commission To Unlock cell
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

PA_Source_List_Only_Increase_Value
    [Tags]    CRT    TC02
    ${source_pa_port_list}     Create List     1    2    9    10    17    18   25    26
    ${source_pa_value_list}    Create List     10    10    10    10    10    10    10    10
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}    pa_type=16*8
    PA Operation    source=&{source}    target=none

PA_Source_Target_List_Both
    [Tags]    CRT    TC02
    ${source_pa_port_list}     Create List     1    2    9    10    17    18   25    26
    ${source_pa_value_list}    Create List     45    45    45    45    45    45    45    45
    ${target_pa_port_list}     Create List    35    36    43    44
    ${target_pa_value_list}    Create List    10    10   10    10
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}    pa_type=16*8
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${10}    pa_type=16*8
    PA Operation    source=&{source}    target=&{target}

# Set APN by ADB
#     ADB.Prepare UE
#     Log to Console    Start to set apn
#     Sleep    10s
#     Qualcomm.Set APN By Uiauto    apn=mdrb.nokia.com
#     ${ret}=    Qualcomm.Get APN By Uiauto
#     Should Contain    ${ret}    mdrb.nokia.com

AT.UE Detach
    AT Operation    detach    ue_index=1

AT.UE Attach
    AT Operation    attach    ue_index=1

Start DL traffic 5QI5
    Log To Console    Start DL traffic 5QI5
    AT Operation    operation=start_traffic    ue_index=1    IperfOptions=-u -i 1 -t 3600 -b 800M -p 5001 -l 1024
    ...    remote_hostname=10.56.198.156    remote_username=ute    remote_password=UTE.debian12
    ...    direction=dl

Stop DL traffic
    AT Operation    operation=stop_traffic    direction=dl    ue_index=1
    ...    remote_hostname=10.56.198.156    remote_username=ute    remote_password=UTE.debian12

Stop All Bts Log
    Stop All BTSLog And Download to Local

Check SA State For BTS${i}
    Log To Console    Check SA State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'PDU sessions successfully set up' | grep -av grep
    Should Contain    ${ret}    PDU sessions successfully set up

Check IgNBCAAdditionRequestAcknowledge For BTS${i}
    Log To Console    Check IgNBCAAdditionRequestAcknowledge
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'IgNBCAAdditionRequestAcknowledge' | grep -av grep
    Should Contain    ${ret}    IgNBCAAdditionRequestAcknowledge

Check NO IgNBCAAdditionRequestAcknowledge For BTS${i}
    Log To Console    Check NO IgNBCAAdditionRequestAcknowledge
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'IgNBCAAdditionRequestAcknowledge' | grep -av grep
    Should not Contain    ${ret}    IgNBCAAdditionRequestAcknowledge

Check Inter-site Scell add For BTS${i}
    Log To Console    Check Inter-site Scell add
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Rrc Reconfiguration for ScellAddition procedure completed' | grep -av grep
    Should Contain    ${ret}    Rrc Reconfiguration for ScellAddition procedure completed

Check NO Inter-site Scell add For BTS${i}
    Log To Console    Check NO Inter-site Scell add
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Rrc Reconfiguration for ScellAddition procedure completed' | grep -av grep
    Should not Contain    ${ret}    Rrc Reconfiguration for ScellAddition procedure completed


Check Inter-site Scell release For BTS${i}
    Log To Console    Check Inter-site Scell release
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'IgNBCAReleaseRequestAcknowledge' | grep -av grep
    Should Contain    ${ret}    IgNBCAReleaseRequestAcknowledge

Check EN-DC State
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check gNB Scell Add
    Log To Console    Check gNB Scell Add
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a Received TaskDone for ueSCellAdditionTask - OK | grep -av grep
    Should Contain    ${ret}    Received TaskDone for ueSCellAdditionTask - OK

Check Latest PM File Of Counter M55118 in BTS0
    PM_counters_collector    gnb_id=${0}
    ${pi_list}    Create List    M55118C00034    M55118C00035
    ${value1}    Get_PM_counters_values    ${pi_list}    bts_index=${0}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55118C00034
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55118C00035
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}

Change Commission To Lock LNCell_22
    COAM_Admin.lock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-22
    ...    connection=COAM_0

Check New PM Counter of M55118 in BTS0
    [Arguments]    ${starttime}    ${endtime}
    ${counters}    Create List    M55118C00034    M55118C00035
    COAM_Admin.Login    bts_host=10.56.5.134
    ${value1}    Get Pm Counters Of Period    counters=${counters}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    cell_id=NRCELL-111
    Log to console    ${value1}
    ${sum_1_val}    Summary Counter Value of dictionary    ${value1}[M55118C00034]
    ${sum_2_val}    Summary Counter Value of dictionary    ${value1}[M55118C00035]
    Should be true    ${sum_1_val}>=${1}
    Should be true    ${sum_2_val}>=${1}

Check New PM Counter of M55125C00040 in BTS0
    [Arguments]    ${starttime}    ${endtime}
    ${counters}    Create List    M55125C00040
    COAM_Admin.Login    bts_host=10.56.5.134
    ${value1}    Get Pm Counters Of Period    counters=${counters}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    cell_id=NRCELL-111
    Log to console    ${value1}
    ${sum_1_val}    Summary Counter Value of dictionary    ${value1}[M55125C00040]
    Should be true    ${sum_1_val}==${1}

Summary Counter Value of dictionary
    [Arguments]     ${time_value}
    ${S}    Set Variable
    ${value_list}    Get dictionary Values   ${time_value}
    FOR    ${i}    IN    @{value_list}
        ${value}    Convert To Integer     ${i}
        ${S}     evaluate     ${S}+${value}
    END
    [Return]    ${S}

Change Commission To Lock LNCell_2 for BTS1
    COAM_Admin.lock    dist_name=MRBTS-10788/LNBTS-10788/LNCEL-2
    ...    connection=COAM_1

Unblock BTS10788 NRCell_84
    Log To Console    Unblock BTS10788 NRCell_84
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_NormalValue}

Unblock BTS10788 LNCell_2
    Log To Console    Unblock BTS10788 LNCell_2
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_NormalValue}

HO from BTS10788 NRCell_84 to BTS10787 NRCell_111
    Log To Console    HO from BTS10788 NRCell_84 to BTS10787 NRCell_111
    ${increase_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${1}
    ${decrease_port_list}    Get Attenuation port    RU_id=${1}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${9}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    15s

HO from BTS10788 LNCell_2 to BTS10787 NRCell_111
    Log To Console    HO from BTS10788 LNCell_2 to BTS10787 NRCell_111
    ${increase_port_list}    Get Attenuation port    RU_id=${0}    gnb_id=${1}
    ${decrease_port_list}    Get Attenuation port    RU_id=${1}    gnb_id=${0}
    ${increase_value_list}    Create List    ${0}    ${5}     ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}
    ${decrease_value_list}    Create List    ${93}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${9}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    ...    sleep_time=3
    sleep    15s

Check target gNB XN handover For BTS${i}
    Log To Console    Check xnapHandoverRequestAcknowledge For BTS${i}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'xnapHandoverRequestAcknowledge' | grep -av grep
    Should Contain    ${ret}    xnapHandoverRequestAcknowledge

Check target gNB Inter Rat HO For BTS${i}
    Log To Console    Check target gnb inter Rat HO For BTS${i}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'ngapHandoverRequestAcknowledge' | grep -av grep
    Should Contain    ${ret}    ngapHandoverRequestAcknowledge

Check InterRatToNr for BTS${i}
    Log To Console    Check InterRatToNr
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Handover finished with success' | grep -av grep
    Should Contain    ${ret}    Handover finished with success

UE PDU Session Modify
    [Arguments]    ${rule}    ${identifier}=460023100012124
    Core_net.Send Custom Rule    identifier=${identifier}    rule=${rule}

Check intra Scell add For BTS${i}
    Log To Console    Check intra Scell add For BTS${i}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Rrc Reconfiguration for ScellAddition procedure completed' | grep -av grep
    Should Contain    ${ret}    Rrc Reconfiguration for ScellAddition procedure completed

Check no intra Scell add For BTS${i}
    Log To Console    Check no intra Scell add For BTS${i}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'Rrc Reconfiguration for ScellAddition procedure completed' | grep -av grep
    Should not Contain    ${ret}    Rrc Reconfiguration for ScellAddition procedure completed


Restart Bts log
    Stop BTSLite For Btslog On VM0
    Start BTSLite For Btslog On VM    btslog_name=restart.log

Change Commission To Unlock cell
    COAM_Admin.unlock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-22
    ...    connection=COAM_0


