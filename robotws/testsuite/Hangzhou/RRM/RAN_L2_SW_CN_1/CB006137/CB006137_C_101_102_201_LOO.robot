*** Settings ***
Documentation    ...
#Resource          ./CB006137_resource.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup 2
#Test Teardown     Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    SBTS22R4    CN1_SG09_SM3    RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}       ${CURDIR}
#${SCF_DIR}             ${CURDIR}/config
#${gnb_swconfig}        ${SCF_DIR}/swconfig_drx.txt
#${LOCAL_IPHY_DIR}      ${CURDIR}/config
#${SCF_PATH}            ${CURDIR}/config
#${6137_C_SCF}          SCF_5Cell_C.xml
#${6137_C_SCF_201}      SCF_5Cell_C_201.xml
#${WTS_CFG_C}           basci_setup_BOO_5cellc.cfg
#${WTS_CFG_C_6UE}       basic_setup_BOO_5cellc_6UE.cfg
#${iphy_2T3F_C}         iphy_2T3F_LOO.xml
#&{GNB}                 hostname=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu
#
#*** Test Cases ***
#CB006137-ET-C-B101_Verify_Lock_of_FDD_cell_with_Graceful_Cell_Shutdown
#    [Tags]    caseC102    trshen    CRT
#    [Setup]    Setup TL For Each Case    ${6137_C_SCF}    ${iphy_2T3F_C}    ${WTS_CFG_C}
#    Set WTS UE To Pcell
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_C}
#    Attach SA UE Do UL Traffic  UE_ID=1    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Attach SA UE Do UL Traffic  UE_ID=2    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Attach SA UE Do UL Traffic  UE_ID=3    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Attach SA UE Do UL Traffic  UE_ID=4    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Trigger A1 Scell Addition  UE_ID=1  meas_id=2
#    Trigger A1 Scell Addition  UE_ID=2  meas_id=2
#    Set PHR Testmode    profile_id=1    phr_mode=Fixed    phr_start=0    phr_max=23
#    Set PHR Testmode    profile_id=2    phr_mode=Fixed    phr_start=30    phr_max=23
#    Set UE To Center  UE_ID=2
#    Set UE To Center  UE_ID=4
#    Set UE To Edge  UE_ID=1
#    Set UE To Edge  UE_ID=3
#    Trigger A2 MG Setup  UE_ID=1  meas_id=1
#    Trigger A2 MG Setup  UE_ID=2  meas_id=1
#
#CB006137-ET-C-B102_Verify_Lock_of_FDD_cell_without_Graceful_Cell_Shutdown
#    [Tags]    caseC102    trshen    CRT
#    [Setup]    Setup TL For Each Case    ${6137_C_SCF}    ${iphy_2T3F_C}    ${WTS_CFG_C}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_Gracefuldisable.xml
#    Delta Commission With SCF File    ${json_file}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_C}
#    Attach SA UE Do UL Traffic  UE_ID=1    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Attach SA UE Do UL Traffic  UE_ID=2    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Attach SA UE Do UL Traffic  UE_ID=3    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Attach SA UE Do UL Traffic  UE_ID=4    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Trigger A1 Scell Addition  UE_ID=1  meas_id=2
#    Trigger A1 Scell Addition  UE_ID=2  meas_id=2
#    Set PHR Testmode    profile_id=1    phr_mode=Fixed    phr_start=0    phr_max=23
#    Set PHR Testmode    profile_id=2    phr_mode=Fixed    phr_start=30    phr_max=23
#    Set UE To Center  UE_ID=2
#    Set UE To Center  UE_ID=4
#    Set UE To Edge  UE_ID=1
#    Set UE To Edge  UE_ID=3
#    Locl Cell And Check UE Release
#
#CB006137-ET-C-B201_Verify_Lock_of_TDD_FR1_cell_with_Graceful_Cell_Shutdown
#    [Tags]    caseC201    trshen    CRT
#    [Setup]    Setup TL For Each Case    ${6137_C_SCF_201}    ${iphy_2T3F_C}    ${WTS_CFG_C_6UE}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_C_6UE}
#    Attach SA UE Do UL Traffic  UE_ID=1    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Attach SA UE Do UL Traffic  UE_ID=2    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Attach SA UE Do UL Traffic  UE_ID=3    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Attach SA UE Do UL Traffic  UE_ID=4    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Attach SA UE Do UL Traffic  UE_ID=5    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Attach SA UE Do UL Traffic  UE_ID=6    dl_tp_set=175    ul_tp_set=40    dl_tp_threshold=5    ul_tp_threshold=20
#    Trigger A1 Scell Addition  UE_ID=1  meas_id=2
#    Trigger A1 Scell Addition  UE_ID=2  meas_id=2
#    Set PHR Testmode    profile_id=1    phr_mode=Fixed    phr_start=0    phr_max=23
#    Set PHR Testmode    profile_id=2    phr_mode=Fixed    phr_start=30    phr_max=23
#    Set UE To Center  UE_ID=5
#    Set UE To Edge  UE_ID=4
#    Trigger A2 MG Setup  UE_ID=4  meas_id=1
#
#*** Keywords ***
#Attach SA UE Do UL Traffic
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=100    ${ul_tp_threshold}=20
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup CA    ue_id=${UE_ID}
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    Sleep    10s
#    ${TDDpcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#
#Common Suite Setup
#    Suite Setup Update GNB    swconfig_param=0x580591=0;0x58056B=0;0x58067c=0x1    log=${False}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Configure UTE ETH For GNB3
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
#    @{new_params_list}    Create List    enb=2 cell=3
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
#Get MeasID A1
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d{1,2})[\\s\\S]{1,150}eventId eventA1
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[0]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d{1,2})[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA1}=    Set Variable    @{measId_list}[0]
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
#Trigger A2 MG Setup
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
#    ...    pass_regexp=gapUE setup
#    Sleep    5s
#
#Trigger A1 Scell Addition
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=115
#    ...    pass_regexp=SCellIndex 1 activated successfully
#
#Lock Cell
#    [Arguments]    ${cell_name}
#    Log To Console    Cell ${cell_name} Locked
#    Setup Admin
#    Block Cell    dist_name=${cell_name}
#    Sleep    30s    reason=wait for gnb ok
#    Teardown Admin
#
#Set UE To Center
#    [Arguments]    ${UE_ID}=1
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${UE_ID} testmode=phr_override action=activate profile_id=1 scell=0
#
#Set UE To Edge
#    [Arguments]    ${UE_ID}=1
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${UE_ID} testmode=phr_override action=activate profile_id=2 scell=0
#
#Locl Cell And Check UE Release
#    Lock Cell  cell_name=MRBTS-1/NRBTS-1/NRCELL-3
#    Sleep    30s    reason=wait for cell block ok
#    Save Egate Log    log_path=${Egatelog_path}
#    ${UErelease_id_list}=    Get UE Release Message
#    Should Be True    @{UErelease_id_list}[0]==1
#    Should Be True    @{UErelease_id_list}[1]==2
#    Should Be True    @{UErelease_id_list}[2]==3
#    Should Be True    @{UErelease_id_list}[3]==4
#
#Get UE Release Message
#    ${UEreleaseregex}=    Set Variable    UE(?P<release_id>\\d{1,2}): UE\\d: Released PDU session
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${release_id_list}=    String.Get Regexp Matches    ${content}    ${UEreleaseregex}    release_id
#    [Return]    ${release_id_list}
