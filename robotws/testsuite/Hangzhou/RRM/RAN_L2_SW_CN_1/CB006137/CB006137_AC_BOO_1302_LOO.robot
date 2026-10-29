*** Settings ***
Documentation    ...
#Resource          ./resources/CB006137_BB_resource.robot
#Resource          ./CB006137_resource.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup 2
#Test Teardown     Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    SBTS22R4    CN1_SG09_SM3    RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}                      1
#${PROFILE_ID}                 1
#${GNB_ID}                     2
#${CELL_ID}                    1
#${BEARER_ID}                  2
#${Egatelog_path}              ${CURDIR}
#${SCF_DIR}                    ${CURDIR}/config
#${gnb_swconfig}               ${SCF_DIR}/swconfig_drx.txt
#${LOCAL_IPHY_DIR}             ${CURDIR}/config
#${6137_AC_1302_SCF}           SCF_5cell_BOO1302.xml
#${WTS_CFG_AC_1302}            basci_setup_BOO_5cell.cfg
#${IPHY_20M_N2_40M_N77_SCF}    iphy_2T3F_LOO.xml
#${6137_AC_1101_SCF}           SCF_5Cell_BOO1101.xml
#${4CC_SCELLS}                 ('1', '50', '71'), ('2', '60', '77'), ('3', '61', '41')
#&{GNB}                        hostname=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu
#
#*** Test Cases ***
#CB006137-ET-AC1302_Verify_Single_UE_bi-directional_intra-band_inter-frequency_HO_between_F+T_UL_CA_(A1_Add_buffer_Act)_and_TDD_non-CA_Cell
#    [Tags]    caseAC1302    trshen    CRT    SG09_SM3
#    [Setup]    Setup TL For Each Case    ${6137_AC_1302_SCF}    ${IPHY_20M_N2_40M_N77_SCF}    ${WTS_CFG_AC_1302}
#    Set WTS UE To Pcell
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_AC_1302}
#    Attach SA UE Do Traffic  UE_ID=1    dl_tp_set=175    ul_tp_set=120    dl_tp_threshold=5    ul_tp_threshold=20
#    Do TDD NonCA Cell HO To F+T UL CA
#    Do F+T UL CA HO To TDD NonCA Cell HO
#    Do TDD NonCA Cell HO To F+T UL CA Twice
#    SA 5G Detach    ue_id=${UE_ID}
#
#CB006137-ET-AC1101_Verify_Single_UE_inter-band_intra-frequency_HO_from_FDD_non-CA_Cell_to_F1+T1_UL_CA_(A1_Add_buffer_Act)
#    [Tags]    caseAC1101    trshen    CRT    SG09_SM3
#    [Setup]    Setup TL For Each Case    ${6137_AC_1101_SCF}    ${IPHY_20M_N2_40M_N77_SCF}    ${WTS_CFG_AC_1302}
#    Set WTS UE To Pcell2
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_AC_1302}
#    Attach SA UE Do Traffic  UE_ID=1    dl_tp_set=175    ul_tp_set=120    dl_tp_threshold=5    ul_tp_threshold=20
#    Do FDD NonCA Cell HO To F+T UL CA
#    SA 5G Detach    ue_id=${UE_ID}
#
#*** Keywords ***
#Attach SA UE Do Traffic
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup CA    ue_id=${UE_ID}
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    Start SA DL Big Traffic Internal    ue_id=${UE_ID}    mbps=500
#    Sleep    10s
#    ${Pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#
#Do TDD NonCA Cell HO To F+T UL CA
#    [Arguments]    ${scells_info}=${4CC_SCELLS}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA2}=    Get MeasID A2
#    Trigger A2 MG Setup    ${UE_ID}   meas_id=${measIdA2}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA3}=    Get MeasID A3 After A2 MG
#    Trigger A3 HO Incoming    ${UE_ID}    meas_id=${measIdA3}
#    Sleep    10s
#    ${FDDpcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA1}=    Get MeasID A1 After HO
#    Trigger A1 Scell Addition    ${UE_ID}    meas_id=${measIdA1}
#    Get And Check Scell Infos    ${scells_info}
#    Sleep    10s
#    Check UL TP On Target    ${UE_ID}    0    3    10
#    Check DL TP On Target    ${UE_ID}    0    1-3    100
#    #${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    #${scell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=1
#
#Do F+T UL CA HO To TDD NonCA Cell HO
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA2}=    Get MeasID A2 After HO
#    Trigger A2 MG Setup    ${UE_ID}   meas_id=${measIdA2}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA3}=    Get MeasID A3 After A2 MG Twice
#    Trigger A3 HO Outcoming    ${UE_ID}    meas_id=${measIdA3}
#    Sleep    10s
#    ${TDDpcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    Should Be True    ${TDDpcell_tp}>40
#
#Do TDD NonCA Cell HO To F+T UL CA Twice
#    [Arguments]    ${scells_info}=${4CC_SCELLS}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA2}=    Get MeasID A2 After HO2
#    Trigger A2 MG Setup    ${UE_ID}   meas_id=${measIdA2}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA3}=    Get MeasID A3 After A2 MG2
#    Trigger A3 HO Incoming    ${UE_ID}    meas_id=${measIdA3}
#    Sleep    10s
#    ${FDDpcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA1}=    Get MeasID A1 After HO2
#    Trigger A1 Scell Addition    ${UE_ID}    meas_id=${measIdA1}
#    Get And Check Scell Infos    ${scells_info}
#    Sleep    10s
#    Check UL TP On Target    ${UE_ID}    0    3    10
#    Check DL TP On Target    ${UE_ID}    0    1-3    100
#    #${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    #${scell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=1
#
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Configure UTE ETH For GNB3
#    Add RD Parameters To GNB Swconfig File    0x58056B=0
#
#Configure UTE ETH For GNB3
#    [Documentation]    This keyword is to configure VM interfaces.
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ip addr add 10.0.3.151/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.3.153/32 dev eth1
#    OperatingSystem.Run    sudo ip addr add 192.168.6.252/32 dev eth4
#
#Set WTS UE To Pcell
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    enb=2 cell=\\d{1,2}
#    @{new_params_list}    Create List    enb=2 cell=12
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Set WTS UE To Pcell2
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    enb=2 cell=\\d{1,2}
#    @{new_params_list}    Create List    enb=2 cell=1
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
#
#Save Egate Log
#    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    OperatingSystem.Run    cp /opt/iphy/latest/egate_console.log ${log_path}
#
#Get MeasID A1 After HO
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d{1,2})[\\s\\S]{1,150}eventId eventA1
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[2]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d{1,2})[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA1}=    Set Variable    @{measId_list}[1]
#    [Return]    ${measIdA1}
#
#Get MeasID A2
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d{1,2})[\\s\\S]{1,150}eventId eventA2
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[0]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d{1,2})[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA2}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA2}
#
#Get MeasID A3 After A2 MG
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d{1,2})[\\s\\S]{1,150}eventId eventA3
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[0]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d{1,2})[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA3}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA3}
#
#Get MeasID A3 After A2 MG Twice
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d{1,2})[\\s\\S]{1,150}eventId eventA3
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[1]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d{1,2})[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA3}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA3}
#
#Get MeasID A2 After HO
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d{1,2})[\\s\\S]{1,150}eventId eventA2
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[1]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d{1,2})[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA2}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA2}
#
#Get MeasID A2 After HO2
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d{1,2})[\\s\\S]{1,150}eventId eventA2
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[3]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d{1,2})[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA2}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA2}
#
#Get MeasID A3 After A2 MG2
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d{1,2})[\\s\\S]{1,150}eventId eventA3
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[2]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d{1,2})[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA3}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA3}
#
#Get MeasID A1 After HO2
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d{1,2})[\\s\\S]{1,150}eventId eventA1
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[6]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d{1,2})[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA1}=    Set Variable    @{measId_list}[1]
#    [Return]    ${measIdA1}
#
#Trigger A2 MG Setup
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
#    ...    pass_regexp=gapUE setup
#    Sleep    5s
#
#Trigger A3 HO Incoming
#    [Arguments]    ${UE_ID}=1    ${meas_id}=1
#    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=10 srsrq_nr=5 ssinr_nr=10
#    ...    phycell_id=52 nrsrp_nr=40 nrsrq_nr=40 nsinr_nr=50
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.12 to EXT_ENB-2.3 performed
#
#Trigger A1 Scell Addition
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=101
#    ...    pass_regexp=SCellIndex 3 activated successfully
#
#Trigger A3 HO Outcoming
#    [Arguments]    ${UE_ID}=1    ${meas_id}=1
#    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=10 srsrq_nr=5 ssinr_nr=10
#    ...    phycell_id=61 nrsrp_nr=40 nrsrq_nr=40 nsinr_nr=50
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.12 performed
#
#
#Do FDD NonCA Cell HO To F+T UL CA
#    [Arguments]    ${scells_info}=${4CC_SCELLS}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA2}=    Get MeasID A2
#    Trigger A2 MG Setup    ${UE_ID}   meas_id=${measIdA2}
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA3}=    Get MeasID A3 After A2 MG
#    Trigger A3 HO Incoming FDD NonCA Cell To F+T UL CA    ${UE_ID}    meas_id=${measIdA3}
#    Sleep    10s
#    ${FDDpcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA1}=    Get MeasID A1 After HO
#    Trigger A1 Scell Addition    ${UE_ID}    meas_id=${measIdA1}
#    Get And Check Scell Infos    ${scells_info}
#    Sleep    10s
#    Check UL TP On Target    ${UE_ID}    0    3    10
#    Check DL TP On Target    ${UE_ID}    0    1-3    100
#    #${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    #${scell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=1
#
#Trigger A3 HO Incoming FDD NonCA Cell To F+T UL CA
#    [Arguments]    ${UE_ID}=1    ${meas_id}=1
#    ${cmd}=    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A3 srsrp_nr=10 srsrq_nr=5 ssinr_nr=10
#    ...    phycell_id=52 nrsrp_nr=40 nrsrq_nr=40 nsinr_nr=50
#    ute_wtssim.Execute Egate Command
#    ...    cmd=${cmd}
#    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed
