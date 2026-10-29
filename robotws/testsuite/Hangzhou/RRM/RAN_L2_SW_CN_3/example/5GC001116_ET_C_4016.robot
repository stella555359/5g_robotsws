*** Settings ***
Documentation    Author: leo.y.wang@nokia-sbell.com
#...              \n example case for RAN HZ L2 SW5. test step description in QC as below:
#...    QC case full name: 5GC001116_C_4016_Single_UE_Scheduling_In_Digital_BF_System
#...    _With_BeamSet_1_Without_Carrier_Aggregation_With_Prach_B4_And_Mcs0
#...    1)Preconditions
#...    BTS state is configured and RRU is online
#...    Releated parameters is set correctly
#...    Cell is up
#...    2)Postconditions
#...    UE can attach successfully to 5G cell
#...    DL and UL data is normal
#...    3)Check Points
#...    Check there is print 'Cell Setup Completed' in airphone /tmp/APL3.log
#...    Check there is print 'SmUserUeConnectionEstablishedIndMessageHandler' in airphone /tmp/APL3.log
#...    Check there is print 'reported successful RA' in egate window.
#...    Check DL and UL data are stable in egate window
#...    Check Slottype For 1116 C 4016
#Suite Setup       1116 C 4016 Suite Setup
#Suite Teardown    1116 C 4016 Suite Teardown
#Test Setup        1116 C 4016 Case Setup
#Test Teardown     1116 C 4016 Case Teardown
#Force Tags        CLOUD_5G_I_KL_AP_KL_NSA_FS_CPRI_CMWV_TDD    CLOUD_5G_I_BL_AP_KL_NSA_FS_CPRI_CMWV_TDD    5G_RAN_TDD
#...               FR1    Owner_liyawang    QCD_MN_RAN    QCP_RAN_ET    CDRT
#Library           ute_fsmaccess
#Resource          ../resources/KISS/robot/common_resource.robot
#
#*** Variables ***
#${SCF_DIR_PATH}         ${CURDIR}/config
#${DELTA_FILE}       Delta_Conf_5GC001116_C_4016.json
#${UE_ID}            1
#${MAX_REBOOT_TL_TIME}    1
#@{LOG_NAME_LIST}    btslog    ap_syslog    gnb_snapshot    sosreport    tshark    bip    ap_bip    egatelog
#@{SLOTTYPE_B4_C4016}
#...                     Slot\\D+0\\D+SLOT_TYPE_SSBURST    Slot\\D+1\\D+SLOT_TYPE_41    Slot\\D+2\\D+SLOT_TYPE_B0
#...                     Slot\\D+3\\D+SLOT_TYPE_B0    Slot\\D+4\\D+SLOT_TYPE_B0    Slot\\D+5\\D+SLOT_TYPE_B0
#...                     Slot\\D+6\\D+SLOT_TYPE_B4    Slot\\D+7\\D+SLOT_TYPE_41    Slot\\D+8\\D+SLOT_TYPE_C5
#...                     Slot\\D+9\\D+SLOT_TYPE_C5    Slot\\D+10\\D+SLOT_TYPE_B0    Slot\\D+11\\D+SLOT_TYPE_B0
#...                     Slot\\D+12\\D+SLOT_TYPE_B0    Slot\\D+13\\D+SLOT_TYPE_B0    Slot\\D+14\\D+SLOT_TYPE_B0
#...                     Slot\\D+15\\D+SLOT_TYPE_B0    Slot\\D+16\\D+SLOT_TYPE_B4    Slot\\D+17\\D+SLOT_TYPE_41
#...                     Slot\\D+18\\D+SLOT_TYPE_C5    Slot\\D+19\\D+SLOT_TYPE_PRACH    Slot\\D+0\\D+SLOT_TYPE_SSBURST
#...                     Slot\\D+1\\D+SLOT_TYPE_B0    Slot\\D+2\\D+SLOT_TYPE_B0
#...                     Slot\\D+3\\D+SLOT_TYPE_B0    Slot\\D+4\\D+SLOT_TYPE_B0    Slot\\D+5\\D+SLOT_TYPE_B0
#...                     Slot\\D+6\\D+SLOT_TYPE_B4    Slot\\D+7\\D+SLOT_TYPE_41    Slot\\D+8\\D+SLOT_TYPE_C5
#...                     Slot\\D+9\\D+SLOT_TYPE_C5    Slot\\D+10\\D+SLOT_TYPE_B0    Slot\\D+11\\D+SLOT_TYPE_B0
#...                     Slot\\D+12\\D+SLOT_TYPE_B0    Slot\\D+13\\D+SLOT_TYPE_B0    Slot\\D+14\\D+SLOT_TYPE_B0
#...                     Slot\\D+15\\D+SLOT_TYPE_B0    Slot\\D+16\\D+SLOT_TYPE_B4    Slot\\D+17\\D+SLOT_TYPE_41
#...                     Slot\\D+18\\D+SLOT_TYPE_C5    Slot\\D+19\\D+SLOT_TYPE_PRACH
#
#*** Test Cases ***
#Single_UE_Scheduling_In_Digital_BF_System_With_BeamSet_1_Without_CA_With_Prach_B4_And_Mcs0
#    BTS state is configured and RRU is online
#    Releated parameters is set correctly
#    Cell is up
#    UE can attach successfully to 5G cell
#    DL and UL data is normal
#    Check Slottype For 1116 C 4016
#
#*** Keywords ***
#1116 C 4016 Suite Setup
#    Common Suite Setup
#
#1116 C 4016 Suite Teardown
#    Common Suite Teardown
#
#1116 C 4016 Case Setup
#    Common Test Setup
#
#1116 C 4016 Case Teardown
#    Common Test Teardown
#
#BTS state is configured and RRU is online
#    Reboot TestLine And Make Sure GNB is Configured
#
#Releated parameters is set correctly
#    Delta Commission With SCF File    ${SCF_DIR_PATH}${/}${SW_BRANCH}${/}SCF${/}${DELTA_FILE}
#    Backup Scf    ${TEST_LOG_DIRECTORY()}    after_commission_scf.xml
#    Download All Common Config Files From Golden Server
#    Find Match WTS CFG Files And Copy To WorkSpace    scfc_file=${TEST_LOG_DIRECTORY()}/after_commission_scf.xml
#
#Cell is up
#    Modify TL VM And AP SCTP Configuration
#    Start WTS And Wait BTS Until Onair    ${WTS_CFG_FULL_PATH}
#
#UE can attach successfully to 5G cell
#    Airphone NSA Attach    ${UE_ID}
#
#DL and UL data is normal
#    Airphone NSA Start Data Traffic    ${UE_ID}     DL    100M
#    Airphone NSA Start Data Traffic    ${UE_ID}     UL    50M
#    Wait Throughput Timer    10s
#    ${nsa_dl_tput}=    Airphone NSA Get Throughput        ${UE_ID}     DL
#    ${nsa_ul_tput}=    Airphone NSA Get Throughput        ${UE_ID}     UL
#    Airphone NSA Stop Data Traffic     ${UE_ID}     DL
#    Airphone NSA Stop Data Traffic     ${UE_ID}     UL
#    ${dl_assert_status}=    Evaluate    100*1000*0.5<int(${nsa_dl_tput})
#    ${ul_assert_status}=    Evaluate    50*1000*0.5<int(${nsa_ul_tput})
#    Should Be True    ${dl_assert_status}
#    Should Be True    ${ul_assert_status}
#
#Check Slottype For 1116 C 4016
#    ${file_path}    ${line}    Download ASP 124A Startup Log
#    :FOR    ${sub}    IN    @{SLOTTYPE_B4_C4016}
#    \    ${line.strip()}    Evaluate    ${line.strip()}+1
#    \    ${content}    OperatingSystem.Run    sed -n '${line.strip()}p' ${file_path}
#    \    ${match_result}    Should Match Regexp    ${content}    ${sub}
#
#Download ASP 124A Startup Log
#    Setup Enb Fsm Access
#    Execute Command On Enb   mkdir /tmp/1116
#    Wait Until Keyword Succeeds    3 min    15 sec    Get 1116 Log
#    Execute Command On Enb   unzip -o -d /tmp/1116 /tmp/1116/ASP-*startup.zip
#    OperatingSystem.Run    scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/tmp/1116/ASP-*startup.log ${test_log_directory()}
#    ${file_path}    Set Variable    ${test_log_directory()}${/}ASP-*startup.log
#    ${cmd}=    Set Variable    awk '/Msg2ToMsg3OffsetCalculator: ulDlDataSlotRatio\=RATIO2_8/ {print NR;exit}' ${file_path}
#    ${line}=    OperatingSystem.Run    ${cmd}
#    Should Be True    ${line.strip()}!=''
#    [Return]    ${file_path}    ${line}
#    [Teardown]    Teardown Enb Fsm Access
#
#Get 1116 Log
#    Setup Enb Fsm Access    alias=116_log
#    Run Keyword And Ignore Error    Execute Command On Enb
#    ...   bget 1:1 /tmp/node_L2RT20/tmp/ASP-1740_startup.zip /tmp/1116 ASP-1740_startup.zip    alias=116_log
#    Run Keyword And Ignore Error    Execute Command On Enb
#    ...   bget 1:1 /tmp/ASP-124A_startup.zip /tmp/1116 ASP-124A_startup.zip    alias=116_log
#    Run Keyword And Ignore Error    Execute Command On Enb
#    ...    bget 1:1 /tmp/node_L2RT20/tmp/ASP-1740_startup.log /tmp/1116 ASP-1740_startup.log    alias=116_log
#    Run Keyword And Ignore Error    Execute Command On Enb
#    ...    bget 1:1 /tmp/ASP-124A_startup.log /tmp/1116 ASP-124A_startup.log    alias=116_log
#    ${output}    Execute Command On Enb    ls /tmp/1116 | grep _startup    alias=116_log
#    Should Contain Any    ${output}    startup.zip    startup.log
#    [Teardown]    Teardown Enb Fsm Access    alias=116_log