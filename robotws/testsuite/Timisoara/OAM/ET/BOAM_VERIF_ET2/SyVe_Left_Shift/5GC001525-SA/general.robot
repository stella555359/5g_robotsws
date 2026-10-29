*** Settings ***
Documentation
...    Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...    Maintainer: sergiu.alecu@nokia.com
...    Test Description: in Test Suite general.robot the following TCs have been approached: 1a, 1b, 1c, 3b, 4, 6, 7
...                      general_1.robot will have the next set of TCs 8, 9, 10, 12d, 13a, 13c, 15, 16
...    The purpose of the test is to verify support common fault management flow mechanism to report
...    faults from SW and HW component of cOAM BTS
...    Group in charge: I_MN_5GSC_PZ_5G_IV7_WRO_5_GMS
...    Review: piotr.zukrowski@nokia.com, damian.muszynski@nokia.com, sylwia.swiatkiewicz@nokia.com
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d /home/ute/logs/
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/SyVe_Left_Shift/5GC001525-SA/general.robot
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_1a_cOAM_BTS_alarm_monitoring_using_cOAM_BTS_Element_Manager_activeAlarms"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_1b_cOAM_BTS_alarm_monitoring_using_cOAM_BTS_Element_Manager_alarmHistory"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_1c_cOAM_BTS_alarm_monitoring_using_cOAM_BTS_Element_Manager_hwStatusView"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_3b_Active_alarms_storage_clearNoActiveAlarmsAfterReset"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_4_Alarm_Id_for_cOAM_BTS_alarms"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_6_Fault_history_in_Black_Box"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_7_Monitor_active_alarms"
...    --dryrun --log NONE --report NONE --output NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/SyVe_Left_Shift/5GC001525-SA/general.robot

Resource    resources/test_case.robot

#Force Tags   STATE_ON_AIR  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN               master_classicalbts_all
#...    SBTS00  SBTS23R1
#...    CLOUD_5G_CLASSICAL_ASIK_ABIL_AEQN_eCPRI      #CLOUD_5G_CLASSICAL_ASIK_ABIL_AEQN_eCPRI
#...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM  #21A_classicalbts  SBTS21B  SBTS22R1   SBTS22R2
# Regression Optimization – part 2 – July 2022

#TC 1525_sa_1a to be dropped due to overlap with ST 21 Nov 2022

Suite Setup       Run Keywords  Suite Preconditions
...               AND           Perform activate service account synchronization to RU devices
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True

*** Test Cases ***
5GC001525_SA_1a_cOAM_BTS_alarm_monitoring_using_cOAM_BTS_Element_Manager_activeAlarms
    [Tags]   CRT   #SBTS00   SBTS22R4   SBTS23R1   #SBTS22R3
    [Timeout]    30 min    # TL 021: 23
    [Setup]    TC Alarm Monitoring Using cOAM BTS Element Manager - Active Alarms Setup
    TC Alarm Monitoring Using cOAM BTS Element Manager - Active Alarms
    [Teardown]    TC Alarm Monitoring Using cOAM BTS Element Manager - Active Alarms Teardown

#5GC001525_SA_1b_cOAM_BTS_alarm_monitoring_using_cOAM_BTS_Element_Manager_alarmHistory
#    [Tags]   CRT  SBTS00  SBTS22R3
#    [Timeout]    35 min    # TL 021: 30
#    [Setup]    TC Alarm Monitoring Using cOAM BTS Element Manager - Alarm History Setup
#    TC Alarm Monitoring Using cOAM BTS Element Manager - Alarm History
#    [Teardown]    TC Alarm Monitoring Using cOAM BTS Element Manager - Alarm History Teardown

#5GC001525_SA_1c_cOAM_BTS_alarm_monitoring_using_cOAM_BTS_Element_Manager_hwStatusView
# Regression Optimization – part 2 – July 2022
#    [Tags]   CRT   #SBTS22R3
#    [Timeout]    35 min    # TL 021: 23
#    [Setup]    TC Alarm Monitoring Using cOAM BTS Element Manager - HW Status View Setup
#    TC Alarm Monitoring Using cOAM BTS Element Manager - HW Status View
#    [Teardown]    TC Alarm Monitoring Using cOAM BTS Element Manager - HW Status View Teardown

#5GC001525_SA_3b_Active_alarms_storage_clearNoActiveAlarmsAfterReset
# Regression Optimization – part 2 – July 2022
#    [Tags]   CRT  #SBTS22R3
#    [Timeout]    50 min    # TL 021: 38
#    [Setup]    TC Active Alarms Storage - Clear No Active Alarms After Reset Setup
#    TC Active Alarms Storage - Clear No Active Alarms After Reset
#    [Teardown]    TC Active Alarms Storage - Clear No Active Alarms After Reset Teardown

#5GC001525_SA_4_Alarm_Id_for_cOAM_BTS_alarms
#    [Tags]   CRT  SBTS00  SBTS22R3
#    [Timeout]    35 min    # TL 021: 30
#    [Setup]    TC Alarm ID Setup
#    TC Alarm ID
#    [Teardown]    TC Alarm ID Teardown

#5GC001525_SA_6_Fault_history_in_Black_Box
# Regression Optimization – part 2 – July 2022
#    [Tags]   CRT  #SBTS22R3
#    [Timeout]    60 min    # TL 019: 40
#    [Setup]    TC Fault History Black Box Setup
#    TC Fault History Black Box
#    [Teardown]    TC Fault History Black Box Teardown

#5GC001525_SA_7_Monitor_active_alarms
#    [Tags]   CRT  SBTS00  SBTS22R3
##    [Timeout]    60 min    # TL 021: 29, TL 019: 25
#    [Setup]    TC Monitor Active Alarms Setup
#    TC Monitor Active Alarms
#    [Teardown]    TC Monitor Active Alarms Teardown
