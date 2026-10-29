*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF}    swconfig_param=${SWCONF}    iphy_file=${IPHYFILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_nilei
#...               SBTS00    CN1_SG06    CB006137
#Resource          ./../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config
#${FULL_SCF}                  CB006137_AC_BO_1301_DL4CC.xml
#${IPHYFILE}                  ${CURDIR}/config/WTS/iphy_2T_3F_LOO.xml
#${SWCONF}                    0x580591=0;
#${WTS_LOCAL}                 ${CURDIR}/config/WTS
#${WTS_DIR}                   /opt/wts/latest/
#${WTS_CFG}                   CB006137_AC_BO_1301.cfg
#${WTS_AP_XML}                airphone.xml
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#${UE_ID}                     4
#${SCELL1_PCI}                50
#${SCELL2_PCI}                60
#${SCELL3_PCI}                61
#${PCELL_ID}                  51
#${EGATELOG_PATH}             ${CURDIR}
#
#*** Test Cases ***
#CB006137_ET_AC1301_BO_Verify_Single_UE_IntraBand_InterFrequency_IntraBB_Unit_HO_From_FT_UL_CA_Blind_Add_Blind_Act_To_FDD_NonCA_Cell
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
#    ...    AND    Common Test Setup
#    ...    AND    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#    SA Attach    ${UE_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL1_PCI}    1
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL2_PCI}    2
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL3_PCI}    3
#    Start SA DLUL Big Traffic Internal For UE
#    Sleep    40s    reason=wait for dl traffic stable
#    #Capture Convert Format Ttitrace With Streaming Mode    2s
#    Check TP On Target 4CC    ${UE_ID}    820    80
#    Do F+T UL CA HO To FDD NonCA Cell
#    Check Egate Log For NewUE And Scell Release
#    Check TP On Target No CA    ${UE_ID}    0    80    35
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    SA 5G Detach    ${UE_ID}
#
#*** Keywords ***
#Start SA DLUL Big Traffic Internal For UE
#    [Documentation]    this keyword is to start all traffic.
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=100    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=900    trf_id=1
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
#    ${measIdA3}=    Set Variable    @{measId_list}[1]
#    [Return]    ${measIdA3}
#
#Do F+T UL CA HO To FDD NonCA Cell
#    Save Egate Log    log_path=${EGATELOG_PATH}
#    ${measIdA2}=    Get MeasID A2
#    A2 Triggered Pcell Change    ${UE_ID}    ${measIdA2}
#    Save Egate Log    log_path=${EGATELOG_PATH}
#    ${measIdA3}=    Get MeasID A3 After A2 MG
#    ${EXT_ENB1}    Set Variable    EXT_ENB-2.3
#    ${EXT_ENB2}    Set Variable    EXT_ENB-2.2
#    A3 Trigger Handover    ${UE_ID}    ${measIdA3}    ${PCELL_ID}    ${EXT_ENB1}    ${EXT_ENB2}
#
#Check Egate Log For NewUE And Scell Release
#    Save Egate Log    ${OUTPUT_DIR}
#    OperatingSystem.Run    mv ${OUTPUT_DIR}/egate_console.log ${OUTPUT_DIR}/egate_console-AC1301.log
#    ${egate_console_file}=    Set Variable    ${OUTPUT_DIR}/egate_console-AC1301.log
#    ${content}=    Grep File    ${egate_console_file}    newUE-Identity
#    Should Contain    ${content}    newUE-Identity
#    ${pattern}=    Set Variable
#    ...    sCellToReleaseList[\\s\\S]*?{[\\s\\S]*?(\\d+),[\\s\\S]*?(\\d+),[\\s\\S]*?(\\d+)[\\s\\S]*?}
#    ${content}=    OperatingSystem.Get File    ${egate_console_file}
#    ${match_list}=    String.Get Regexp Matches    ${content}    ${pattern}    1    2    3
#    Log To Console    sCellToReleaseList is ${match_list}    console=True
#    ${sCellToRelease_id}=    Set Variable    ${match_list}[0]
#    Should Be True    ${sCellToRelease_id}== ('1', '2', '3')
