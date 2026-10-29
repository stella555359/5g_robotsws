*** Settings ***
Documentation    ...
#Resource    ./5GC002329_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    SBTS22R4    alicchen
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}    ${CURDIR}
#${SCF_PATH}    ${CURDIR}/config
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${2329_scf}    ${LOCAL_WTS_DIR}/SCF_AFB1005_LOO.xml
#${WTS_AP_XML}    Airphone_3cell.xml
#${WTS_CFG}    basic_l1bypass_sa_call_tdd_cmwv_multi_ue.cfg
#${WTS_DIR}    /opt/iphy/latest
#${iphy}    ${LOCAL_WTS_DIR}/iphy_3cell_LOO.xml
#
#*** Test Cases ***
#5GC002329-ET-AFB1005-Verify PCell A2 based PCell change for SA call with actHoOptimizationCa enable and not fulfill A1 MR criteria
#    #${json_file}=    Change Delta XML File To Delta Json File    ${LOCAL_WTS_DIR}/delta_AFB1005.xml
#    #Delta Commission With SCF File    ${json_file}
#    #Reboot TL And Check Configured
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA UE
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA1}=    Get MeasID A1
#    A1 triggered Scell Addition    ${UE_ID}   meas_id=${measIdA1}
#    SA Start DL Traffic
#    A2 triggered Pcell Change
#
#5GC002329-ET-AFB1003-Verify PCell A2 based PCell change for SA call with actHoOptimizationCa disable and FDD cell A1 based scell addition
#    ${json_file}=    Change Delta XML File To Delta Json File    ${LOCAL_WTS_DIR}/delta_AFB1003.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA UE
#    Triggered A1
#    SA Start DL Traffic
#    Triggered A2 Pcell
#
#*** Keywords ***
#Get MeasID A1
#    ${reportConfigIdregex}=    Set Variable    reportConfigId (?P<report_id>\\d)[\\s\\S]{1,150}eventId eventA1
#    ${content}=    OperatingSystem.Get File    ${CURDIR}/egate_console.log
#    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportConfigIdregex}    report_id
#    ${report_id}=    Set Variable    @{report_id_list}[0]
#    ${measIdregex}=    Set Variable    measId (?P<measId>\\d)[\\s\\S]{1,100}reportConfigId ${report_id}
#    ${measId_list}=    String.Get Regexp Matches    ${content}    ${measIdregex}    measId
#    ${measIdA1}=    Set Variable    @{measId_list}[0]
#    [Return]    ${measIdA1}
#
#A1 triggered Scell Addition
#   [Arguments]    ${UE_ID}    ${meas_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=110 phycell_id=50
#    ...    pass_regexp=SCellIndex 1 activated successfully
#
#A2 triggered Pcell Change
#    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A2 srsrp_nr=80 srsrq_nr=66 scell=1 scell_rsrp=115 scell_rsrq=100
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}
#    ...    pass_regexp=SCellIndex 1 activated successfully    timeout=3minute
#
#Triggered A1
#    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=1 event=A1 srsrp_nr=110 phycell_id=50
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
#
#Triggered A2 Pcell
#    ${command}    Set Variable    ue_measurement_send_nr id=${UE_ID} meas_id=3 event=A2 srsrp_nr=80 srsrq_nr=66 scell=1 scell_rsrp=115 scell_rsrq=100
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}
#    ...    pass_regexp=reconfigurationWithSync with physCellId 51 is present in masterCellGroup    timeout=3minutes
#
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    #Send All Config For Testline
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Modify IPHY File And Send to Airphone    ${iphy}
#    Full Commission With SCF File    ${2329_scf}
#    Reboot TL And Check Configured
#    Get All Testline Information And Set Suite Variable
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
#SA Start DL Traffic
#    Log To Console    Start DL Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=2 mbps=175 dir=dl
#    Sleep    5s
#
#Attach SA UE
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
