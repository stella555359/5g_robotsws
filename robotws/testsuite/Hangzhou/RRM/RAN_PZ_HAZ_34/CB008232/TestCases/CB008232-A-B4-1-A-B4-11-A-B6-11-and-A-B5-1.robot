*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB008232


Suite Setup         Run keywords
...    robot_common_operations.Common Suite Setup    AND
...    8232 Suite Setup

Suite Teardown      Run keywords
...    robot_common_operations.Common Suite Teardown    AND
...    Run Keyword And Ignore Error       Common Suite Teardown for COAM


Resource         ../Resources/CB008232_keywords.robot


*** Variables ***
@{dlexpect_tp}           70    80    65
${dlexpect_tp_UE0}       45
${dlexpect_tp_UE1}       40
${dlexpect_tp_UE2}       45
${dlexpect_tp_UE0_UE1}       80
${dlexpect_tp_UE0_UE1_UE2}       120
${MO_sig}                mo-Signalling
${MPS}                   mps-PriorityAccess
${HPA}                   highPriorityAccess
${pre-emption}           release-due-to-pre-emption
${wiresharklog_01}        wiresharklog_01
${wiresharklog_02}        wiresharklog_02
${wiresharklog_03}        wiresharklog_03
${wiresharklog_04}        wiresharklog_04
${wiresharklog_05}        wiresharklog_05
${wiresharklog_06}        wiresharklog_06
${wiresharklog_07}        wiresharklog_07
${wiresharklog_08}        wiresharklog_08
${APN2}                   wap1.nokia.com
@{hpa_value}        ${1}    ${1}    ${1}    ${1}
@{mps_value}        ${1}    ${1}    ${1}    ${1}
@{ICS_mps}          ${1}    ${1}
@{ICS_hpa}          ${1}    ${1}
${ra_P_MPS+MCS}     c0
${ra_P_MPS}         80
${ra_P_MCS}         40
#${options}          -i any sctp -s 0
${HO_failure_expect}    no-radio-resources-available-in-target-cell
@{gnb_ips_h}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${APN1_trunk}       wap1
${APN1_23R1}        wap2
@{gnb2_cell1_pa_trunk}      10    45
@{gnb2_cell1_pa_23R1}       0     30
@{gnb1_cell1_pa_trunk}      0    20    127
@{gnb1_cell1_pa_23R1}       0    30    127

*** Test Cases ***
[1]CB008232_A_030_Intra_gNB_success_with_UE_context_above_maxNumOfRrcSA_without_preemption_candidate
    [Documentation]
    ...    A-030 describes Intra-gNB HO success scenario with UE Context resource shortage when at lease one QoS flow from the request has ARP
    ...          priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max but without UE context preemption candidate
    ...    A-032 describes Intra-gNB HO success scenario with DRB resource shortage when at lease one QoS flow from the request has ARP priority
    ...          from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max range
    ...    A-036 describes Xn Inter-gNB handover failure scenario with UE Context resource shortage when none of the QoS flow from the request has
    ...          ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max but without UE context preemption candidate
    ...    A-048 describes inter-gNB Xn HO where UE have multiple QoS flows but DRBs resource is shortage at target cell
    ...    A-050 describes inter-gNB NG based HO where UE have multiple QoS flows but DRBs resource is shortage at target cell and S-NSSAI of
    ...          one PDU session is not supported in the cell
    ...    A-056 describes Xn Inter-gNB handover failure scenario with maximumNumberOfDRBsPerDU DRB resource shortage when none of the QoS flow
    ...          from the request has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max range
    ...    A-059 describes Intra-gNB HO success scenario with DRB resource shortage when at lease one QoS flow from the request has ARP priority
    ...          from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max range when source gNB or target gNB disable 8232
    ...    D-011 describes verification of SIB1 content when handover happens
    ...    RRC--applyPriorityAccess=HPA+MPS; ICS--HPA is PA
    ...    UE0----normal,wap1-NOT preemptable
    ...    UE1----HPA,Not preemptible
    ...    UE2----MPS/MCS,Not preemptible
    [Tags]     CRT_TRUNK
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Set suite variable for 8232_A_030
    step1 prepare the envrionment
    step2 test procedures and case check point
#    step3 case check point
    [Teardown]    Run Keyword    Case TearDown
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Case TearDown


*** Keywords ***
step1 prepare the envrionment
    [Arguments]
    Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
    ...                           Modify_Para_Online=${A_030_Modify_Online}
    ...                           ModifySCF_Beforecommission_GNB2=True
    ...                           golden_scf_name_gnb2=${${GNB2_GSC}}
    ...                           ParamterToModify_gnb2=${A_030_MODIFY_GNB2}
    Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
    ...    Add_Para_Online=${A_030_ADD_Para}    Delete_Para_Online=${A_030_Delete_Para_Online_CA}    Modify_Para_Online=${A_030_Modify_Para_Online_CA}
    Comment    20240929:modify gnb1 NIA AND NEA due to migration rule
    Online modify parmeters     gnb_index=${0}    parameters_to_update=${PARAM_8232_gnb1_A_030}    skip_parameter_relation_errors=False
    Online modify parmeters     gnb_index=${1}    parameters_to_update=${PARAM_8232_gnb2_A_030}    skip_parameter_relation_errors=False
#    NRCellid Set suit varaible    cellid=${${cellid}}
    ${nrcellid}=             COAM Get nrcellid with lcrid     lcrid=${${cellid}}
    ${NRCellidgnb1cell2}=    COAM Get nrcellid with lcrid     lcrid=${2}
    ${NRCellidgnb2cell1}=    COAM Get nrcellid with lcrid     lcrid=${1}    gnb_index=${1}
    set suite variable    ${nrcellid}    ${nrcellid}
    set suite variable    ${NRCellidgnb1cell2}    ${NRCellidgnb1cell2}
    set suite variable    ${NRCellidgnb2cell1}    ${NRCellidgnb2cell1}
    Log To Console    \n***gnb1cell PA=0,other PA=127db***\n
    Adjust the GNB1CELL1 HBTE attenuation value
    Adjust the GNB1CELL2 HBTE attenuation value
    Adjust the GNB2CELL1 HBTE attenuation value
    Adjust the ENB1CELL1 HBTE attenuation value
    Adjust the ENB2CELL1 HBTE attenuation value
#    Switch APN to Test_need_APN    target_APN=${${target_APN1}}
    Switch APN to Test_need_APN    ue_index=${0}    target_APN=${${target_APN1}}   ui_version=S24UI5.1    APN_ui_version=one ui 5.1
#    Switch APN to Test_need_APN    ue_index=${1}    ui_version=S21UI4.0    target_APN=mdrb

step2 test procedures and case check point
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Log To Console    \n***UE0 ATTACH and detach GNB1 CELL1-PA=0***\n
    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${0}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    Sleep    2s
    Log To Console    \n***UE1 ATTACH and detach GNB1 CELL2-PA=0***\n
    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${127}
    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${0}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
    Sleep    2s
    Log To Console    \n***UE2 ATTACH and detach GNB2 CELL1-PA=0***\n
    Adjust the GNB2CELL1 HBTE attenuation value    gnb2_cell1_value=${0}
    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${127}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${1}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}
    Adjust the GNB2CELL1 HBTE attenuation value    gnb2_cell1_value=${127}
    Sleep    2s
    Log To Console    \n***UE0 ATTACH GNB1 CELL1-PA=0 and check UE0 traffic 45M ***\n
    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${0}
    ${cpif_log_01}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_01}    ue_index=${0}    DL_PORT=${DL_PORT_1}
    BuiltIn.Set Test Variable    ${cpif_log_01}

    DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp_UE0}   duration=1m    ue_type=${ue_type}
    Comment    set  GNB1 CELL1 PA to add 25db
    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${25}
    Log To Console    \n*** set GNB1 CELL2 PA to add 0db and attach gnb1cell2 and check UE1 traffic 45M ***\n
    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${0}
    ${cpif_log_02}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_02}    ue_index=${1}    ui_version=S21UI4.0    DL_PORT=${DL_PORT_2}
    BuiltIn.Set Test Variable    ${cpif_log_02}
    Check 5QI9 exist    file_path=${cpif_log_02}

    sleep    10s
    DL Tput collect and check with nrcellid    cellid=${NRCellidgnb1cell2}    dlexpect_tp=${dlexpect_tp_UE1}   duration=1m    ue_type=${ue_type}
    ...    min_percent=0.3
    sleep    15s
    Log To Console    \n***UE1 Handover from GNB1CELL2 TO GNB1CELL1 -- SUCCESS ***\n
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_03}    gnb_index=${0}
    sleep    5s
    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${0}
    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${20}
    sleep    10s
    ${cpif_log_03}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_03}    target_dir=${epc_log_path}
    BuiltIn.Set Test Variable    ${cpif_log_03}
    Check measID is A3_measreport    file_path=${cpif_log_03}    A3_measID_value=4
    Check nRCellIdentity is nrcellid    file_path=${cpif_log_03}    nrcellid=${nrcellid}
    Check ra_Prio from RRCReconfiguration_SIB1    file_path=${cpif_log_03}    ra_Prio_value=${ra_P_MPS+MCS}
    Check one DRB_released after handover    file_path=${cpif_log_03}

    sleep   10s
    Log To Console    \n***check gnb1cell1 UE0+UE1 traffic 80M ***\n
    DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp_UE0_UE1}    duration=1m    ue_type=${ue_type}
    Log To Console    \n***set gnb1 cell2 PA to 127db and gnb1 cell1 PA to add 25db and gnb2cell1 PA to 0db***\n
    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${127}
    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${25}
    Adjust the GNB2CELL1 HBTE attenuation value    gnb2_cell1_value=${0}
    Log To Console    \n***set gnb2 cell1 PA to 0db and check traffic 45db***\n
    ${cpif_log_06}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_06}    ue_index=${2}    ui_version=S21UI4.0    DL_PORT=${DL_PORT_3}
    ...                                           gnb_index=${1}
    BuiltIn.Set Test Variable    ${cpif_log_06}

    sleep   10s
    DL Tput collect and check with nrcellid    cellid=${NRCellidgnb2cell1}    dlexpect_tp=${dlexpect_tp_UE2}   duration=1m
    ...                                        ue_type=${ue_type}    gnb_index=${1}
    Log To Console    \n***UE2 Handover from GNB2CELL1 TO GNB1CELL1--FAIL ***\n
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_05}    gnb_index=${1}
    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${0}
    Adjust the GNB2CELL1 HBTE attenuation value    gnb2_cell1_value=${30}
    sleep    5s
    ${cpif_log_05}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_05}    target_dir=${epc_log_path}
    BuiltIn.Set Test Variable    ${cpif_log_05}
    Check measID is A3_measreport    file_path=${cpif_log_05}    A3_measID_value=5
    Check HO_failure_reason is expect    file_path=${cpif_log_05}    HO_failure_expect=${HO_failure_expect}

    Comment    recovery PA before HO: gnb1cell1 0db,gnb2cell1 30db
    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${30}
    Adjust the GNB2CELL1 HBTE attenuation value    gnb2_cell1_value=${0}
    Sleep    5s
    Log To Console    \n***modify gnb1cell1 parameter to make UE2 HO success ***\n
    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${A_030_Change_PRAM}
    Sleep    15s
    Log To Console    \n***UE2 Handover from GNB2CELL1 TO GNB1CELL1--SUCCESS ***\n
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_07}    gnb_index=${1}
    Sleep    3s
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_08}    gnb_index=${0}
    Sleep    3s
    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${0}
    Adjust the GNB2CELL1 HBTE attenuation value    gnb2_cell1_value=${30}
    Sleep    15s
    ${cpif_log_07}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_07}    target_dir=${epc_log_path}
    ${cpif_log_08}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_08}    target_dir=${epc_log_path}
    BuiltIn.Set Test Variable    ${cpif_log_07}
    BuiltIn.Set Test Variable    ${cpif_log_08}
    Check measID is A3_measreport    file_path=${cpif_log_07}    A3_measID_value=${intergnb_ho_measid}
    Check inter-Gnb HO success in Targetcell    file_path=${cpif_log_08}
    Log To Console    \n***check gnb1cell1 UE0+UE1+UE2 traffic ***\n
    DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp_UE0_UE1_UE2}    duration=1m    ue_type=${ue_type}
    Stop capture syslog via btslog on ute

#Comment    20241015 re-write test procedures and checkpoint
#    Adjust the GNB2CELL1 HBTE attenuation value    gnb2_cell1_value=${${${gnb2_cell1_pa}}[0]}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${${${gnb1_cell1_pa}}[2]}
#    ${cpif_log_06}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_06}    ue_index=${2}    ui_version=S21UI4.0    DL_PORT=${DL_PORT_3}
#    ...                                           gnb_index=${1}
#    Common Case TestLine Setup    ModifySCF_Aftercommission_for_GNB2=True
#    ...                           Modify_Para_Online_GNB2=${GNB2CELL1_Barred}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${${${gnb1_cell1_pa}}[0]}
#    ${cpif_log_01}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_01}    ue_index=${0}    DL_PORT=${DL_PORT_1}
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                           Modify_Para_Online=${GNB1CELL1_Barred}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${20}
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${0}
#    ${cpif_log_02}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_02}    ue_index=${1}    ui_version=S21UI4.0    DL_PORT=${DL_PORT_2}
#    sleep    15s
#   #    Common Case TestLine Setup    ModifySCF_Aftercommission=True
##    ...                           Modify_Para_Online=${GNB1CELL2_Barred}
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                           Modify_Para_Online=${GNB1CELL1_notBarred}
#    sleep    10s
#    Comment    UE1 Handover from GNB1CELL2 TO GNB1CELL1 -- SUCCESS
##    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_03}    options=${options}    gnb_index=${0}
#    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_03}    gnb_index=${0}
#    sleep    5s
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${${${gnb1_cell1_pa}}[0]}
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${20}
#    sleep    10s
#    ${cpif_log_03}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_03}    target_dir=${epc_log_path}
#    sleep   60s
#    DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[2]    duration=1m    ue_type=${ue_type}
#    Adjust the GNB1CELL2 HBTE attenuation value    gnb1_cell2_value=${127}
#    Comment    UE2 Handover from GNB2CELL1 TO GNB1CELL1--FAIL
#    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_05}    gnb_index=${1}
#    Adjust the GNB2CELL1 HBTE attenuation value    gnb2_cell1_value=${${${gnb2_cell1_pa}}[1]}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${${${gnb1_cell1_pa}}[0]}
#    sleep    5s
#    DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[1]    duration=1m    ue_type=${ue_type}
#    ${cpif_log_05}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_05}    target_dir=${epc_log_path}
#    Comment    UE2 Handover from GNB2CELL1 TO GNB1CELL1--SUCCESS
#    Comment    recovery PA before HO: gnb1cell1 0db,gnb2cell1 30db
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${${${gnb1_cell1_pa}}[1]}
#    Adjust the GNB2CELL1 HBTE attenuation value    gnb2_cell1_value=${${${gnb2_cell1_pa}}[0]}
#    Sleep    5s
#    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_07}    gnb_index=${1}
#    Sleep    3s
#    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_08}    gnb_index=${0}
#    Sleep    3s
#    Comment   modify gnb1cell1 parameter to make UE2 HO success
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                           Modify_Para_Online=${A_030_Change_PRAM}
#    Sleep    30s
#    Adjust the GNB2CELL1 HBTE attenuation value    gnb2_cell1_value=${${${gnb2_cell1_pa}}[1]}
#    Adjust the GNB1CELL1 HBTE attenuation value    gnb1_cell1_value=${${${gnb1_cell1_pa}}[0]}
#    Sleep    15s
#    ${cpif_log_07}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_07}    target_dir=${epc_log_path}
#    ${cpif_log_08}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_08}    target_dir=${epc_log_path}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#    BuiltIn.Set Test Variable    ${cpif_log_02}
#    BuiltIn.Set Test Variable    ${cpif_log_03}
#    BuiltIn.Set Test Variable    ${cpif_log_05}
#    BuiltIn.Set Test Variable    ${cpif_log_06}
#    BuiltIn.Set Test Variable    ${cpif_log_07}
#    BuiltIn.Set Test Variable    ${cpif_log_08}
#    DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[0]    duration=1m    ue_type=${ue_type}
    [Teardown]    Run keywords
    ...    Stop Traffic for 3UES with Power UE    AND
    ...    Run Keyword And Ignore Error    UE Detach With Power UE for 3UES    AND
    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute



step3 case check point
    Check measID is A3_measreport    file_path=${cpif_log_03}    A3_measID_value=4
    Check nRCellIdentity is nrcellid    file_path=${cpif_log_03}    nrcellid=${nrcellid}
    Check measID is A3_measreport    file_path=${cpif_log_05}    A3_measID_value=5
    Check HO_failure_reason is expect    file_path=${cpif_log_05}    HO_failure_expect=${HO_failure_expect}
    Check ra_Prio from RRCReconfiguration_SIB1    file_path=${cpif_log_03}    ra_Prio_value=${ra_P_MPS+MCS}
    Check measID is A3_measreport    file_path=${cpif_log_07}    A3_measID_value=${intergnb_ho_measid}
    Check inter-Gnb HO success in Targetcell    file_path=${cpif_log_08}
    Check 5QI9 exist    file_path=${cpif_log_02}
    Check one DRB_released after handover    file_path=${cpif_log_03}



Case TearDown
    8232 Case TearDown
#    Run Keyword And Ignore Error     Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                                                            Modify_Para_Online=${GNB1CELL2_notBarred}
#    ...                                                            ModifySCF_Aftercommission_for_GNB2=True
#    ...                                                            Modify_Para_Online_GNB2=${GNB2CELL1_notBarred}
