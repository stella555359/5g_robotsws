*** Settings ***
Documentation
...   author: Mateusz Bury
...   contact: mateusz.bury@nokia.com

Resource    ./resources/keywords_13438_TC_06.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py

*** Keywords ***
TC06_CB013438-A-A1-A3_Online_modification_of_scheduling_weight_with_extended_range_with_RAT1_and_parameter_Reinit_Prohibit_Timer_on_cloud
    Set Default Values On Attenuator For 13438
    #STEP 0
    Vdu Reconfiguration
    Vcu Reconfiguration
    Show Text On Console   Prepare UEs
    Require UEs

    #STEP 1
    Show Text On Console   Attach 2 UEs to NR SA cell
    Attach UEs To Preferred Cell  UE_1  UE_2

    #STEP 2
    Show Text On Console   TCP Tput send to 2 UEs
    Start Data Transfer In Both Directions      UE_1  UE_2
    Verify Average Tput in Next Few Seconds     UE_1  UE_2

    #STEP 3
    Show Text On Console    BTS reconfiguration 5QI=7,8,9: schedulWeight = ${NRDRB5QI7},${NRDRB5QI8},${NRDRB5QI9}
    Show Text On Console    actExtSchedWeightAndPrefWrrAlg=ExtendedRange_EnhancedWrr
    Vdu Reconfiguration     ${NRDRB5QI7}    ${NRDRB5QI8}    ${NRDRB5QI9}    algo=ExtendedRange_EnhancedWrr
    Vcu Reconfiguration     ${NRDRB5QI7}    ${NRDRB5QI8}    ${NRDRB5QI9}    algo=ExtendedRange_EnhancedWrr

    #STEP 4
    Show Text On Console   Attach UE_3 to NR SA cell
    Update Schedulweight For UEs    UE_3=${100}

    Attach UEs To Preferred Cell   UE_3

    #STEP 5
    Show Text On Console   TCP Tput send to recently attached UE
    Start Data Transfer In Both Directions  UE_3

    #STEP 6
    Show Text On Console   Compare DL and UL data transmission of 3 UEs with schedulWeight set in 5QI
    Verify Average Tput In Next Few Seconds     @{ue_list}

    #STEP 7
    Show Text On Console   Detach 3 UEs from NR SA cell.
    Detach UEs and stop data transfer

    #STEP 8
    Show Text On Console   Attach 3 UEs to NR SA cell.
    Attach UEs To Preferred Cell  @{ue_list}
    Update Schedulweight For UEs    UE_1=${NRDRB5QI7}    UE_2=${NRDRB5QI8}    UE_3=${NRDRB5QI9}

    #STEP 9
    Show Text On Console   TCP Tput send to 3 UEs
    Start Data Transfer In Both Directions      @{ue_list}

    #STEP 10
    Show Text On Console   Compare DL and UL data transmission of 3 UEs with schedulWeight set in 5QI
    Verify Average Tput in Next Few Seconds     @{ue_list}

    #STEP 11
    Show Text On Console   Set MRBTS/NRBTS/NRCELL.avgDataRateReinitProhibitTimer to 1 msec value
    Vdu Reinitprohibittimer Reconfiguration     1

    #STEP 12
    Show Text On Console   Compare DL and UL data transmission of 3 UEs with schedulWeight set in 5QI
    Verify Average Tput in Next Few Seconds     @{ue_list}

    #STEP 13
    Show Text On Console   Set MRBTS/NRBTS/NRCELL.avgDataRateReinitProhibitTimer to 1000 msec value
    Vdu Reinitprohibittimer Reconfiguration     1000

    #STEP 14
    Show Text On Console   Compare DL and UL data transmission of 3 UEs with schedulWeight set in 5QI
    Verify Average Tput in Next Few Seconds     @{ue_list}

    [Teardown]      Run keywords
    ...     Detach UEs and stop data transfer
    ...     AND     Vcu Reconfiguration
    ...     AND     Vdu Reconfiguration
    ...     AND     Vdu Reinitprohibittimer Reconfiguration
