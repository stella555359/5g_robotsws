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
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/SyVe_Left_Shift/5GC001525-SA/general_1.robot
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_8_Monitor_fault_history"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_9_Faults_updated_real-time"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_10_Display_faults_in_local_Time"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_12d_Filters_in_Element_Manager_Alarm_View_configurationObject"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_13a_Highlight_faulty_object_in_Hardware_&_Service_Status_View_faultyCell"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_13c_Highlight_faulty_object_in_Hardware_&_Service_Status_View_noAffectedCells"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_16_A_Fault_management-Recovery_actions_mechanism_verification"
...    Dryrun: /opt/ute/python/bin/robot -t "5GC001525_SA_15_Alarm_correlation"
...    --dryrun --log NONE --report NONE --output NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/SyVe_Left_Shift/5GC001525-SA/general_1.robot

Resource    resources/test_case.robot

#Force Tags   STATE_ON_AIR  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN           master_classicalbts_all
#...   
#...    CLOUD_5G_CLASSICAL_ASIK_ABIL_AEQN_eCPRI    #21A_classicalbts
#...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM   #SBTS21B  SBTS22R1  SBTS22R2

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
5GC001525_SA_8_Monitor_fault_history
    [Tags]   CRT      #SBTS22R3
    [Timeout]    60 min
    [Setup]    TC Monitor Fault History Setup
    TC Monitor Fault History
    [Teardown]    TC Monitor Fault History Teardown

5GC001525_SA_9_Faults_updated_real-time
    [Tags]   CRT    SBTS00   SBTS22R4   SBTS23R1    #SBTS22R3
    [Timeout]    25 min
    [Setup]    TC Fault Update In Real Time Setup
    TC Fault Update In Real Time
    [Teardown]    TC Fault Update In Real Time Teardown

#5GC001525_SA_10_Display_faults_in_local_Time
#    [Tags]   CRT
#    [Timeout]    60 min    # TL 021: 38, TL 019: 50
#    [Setup]    TC Local Time Faults Display And Day Saving Time Setup
#    TC Local Time Faults Display And Day Saving Time
#    [Teardown]    TC Local Time Faults Display And Day Saving Time Teardown

#5GC001525_SA_12d_Filters_in_Element_Manager_Alarm_View_configurationObject
#    [Tags]   CRT
#    [Timeout]    25 min
#    [Setup]   TC Filter In WebEM Alarm View - Configuration Object Setup
#    TC Filter In WebEM Alarm View - Configuration Object
#    [Teardown]    TC Filter In WebEM Alarm View - Configuration Object Teardown

5GC001525_SA_13a_Highlight_faulty_object_in_Hardware_&_Service_Status_View_faultyCell
    [Tags]   CRT     #SBTS22R3
    [Timeout]    25 min
    [Setup]    TC Highlight Faulty Object In HW Service Status View - Faulty Cell Setup
    TC Highlight Faulty Object In HW Service Status View - Faulty Cell
    [Teardown]    TC Highlight Faulty Object In HW Service Status View - Faulty Cell Teardown

#5GC001525_SA_13c_Highlight_faulty_object_in_Hardware_&_Service_Status_View_noAffectedCells
#    [Tags]   CRT
#    [Setup]    TC Highlight Faulty Object In HW Service Status View - No Affected Cells Setup
#    TC Highlight Faulty Object In HW Service Status View - No Affected Cells
#    [Teardown]    TC Highlight Faulty Object In HW Service Status View - No Affected Cells Teardown

5GC001525_SA_16_A_Fault_management-Recovery_actions_mechanism_verification
    [Tags]   CRT    SBTS00   SBTS22R4   SBTS23R1    #SBTS22R3
    [Setup]    TC Recovery Actions Mechanism Verification Setup
    TC Recovery Actions Mechanism Verification
    [Teardown]    TC Recovery Actions Mechanism Verification Teardown

5GC001525_SA_15_Alarm_correlation
    [Documentation]
    ...    Correlation is tested by triggering two correlated faults.
    ...    Expected result is that 2nd fault will cause overshadowing 1st. When 2nd fault is cancelled, 1st is again raised.
    [Tags]   CRT    SBTS00   SBTS22R4   SBTS23R1     #SBTS22R3
    [Timeout]    28 min    # TL 021: 28
    [Setup]    TC WebEM Alarms Correlation Setup
    TC WebEM Alarms Correlation
    [Teardown]    TC WebEM Alarms Correlation Teardown
