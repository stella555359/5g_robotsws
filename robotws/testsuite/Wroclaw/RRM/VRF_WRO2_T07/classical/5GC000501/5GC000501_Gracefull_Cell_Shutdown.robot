*** Settings ***
Documentation
...   author:       Mateusz Cieciura
...   contact:      mateusz.cieciura@nokia.com
...   maintainer:   mateusz.cieciura@nokia.com
...   Description:  This feature describes and verify graceful shutdown procedure according to 5GC000501 feauture

Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000501/resources/keywords_501.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.robot
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py  WITH NAME  wro_6_btslog
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/common.py

Suite Setup     Run keywords
...             Prepare Attenuator                             AND
...             Require Ue  ${UE_ALIAS}  capabilities=REAL_UE

Test Setup      Run Keywords
...             Start syslog capture

Test Teardown   Run Keywords
...             Detach Ue  ${UE_ALIAS}                         AND
...             stop_data_transfer_if_active                   AND
...             AdminUtils.unlock_all_cells                    AND
...             Stop syslog capture                            AND
...             AdminUtils.collect_snapshot

Suite Teardown  Stop Using Ue  ${UE_ALIAS}


*** Variables ***
# TODO: NEW VARIABLES (USE FOR EDA)
${GCS_CELL_ID}            1
${CALL_FLAG}              call   #call/no_call
&{START_UE}               call=Start call   no_call=Attach
&{STOP_UE}                call=Stop call    no_call=Detach
${CHECK_TYPE}             NAA    #NAA/ANTL
&{BEFORE_CHECK}           NAA=Measure RX power on UE before shutdown  ANTL=Start Power Measurement in Webem
&{WHILE_CHECK}            NAA=Measure RX power on UE while shutdown   ANTL=Stop Power Measurement in Webem
${DEPLOYMENT_MODE}        SA     #SA/NSA
&{RSRP_KEY_MAP}           NSA=nrDbm  SA=dbm
&{JSON_KEY_TL_MAP}        50078=(NRCell1)  50096=(51997-01)  41810=(AHPMDB1)  55200=(55200-00)
# TODO: ANTL MEASUREMENT IS THE MOST STABLE WHEN ${SHUTDOWN_WINDOW}/${SHUTDOWN_STEP_AMOUNT} equals 10 (IT MUST BE AT LEAST 10)
${SHUTDOWN_WINDOW}        ${180}  #(6, 12, 18…, 180 sec)
${SHUTDOWN_STEP_AMOUNT}   ${6}    #(1,2,3….16)
${DEVIATION}              ${1}    #deviation for every shutdown step [dB] (3dB +- deviation)


*** Test Cases ***
5GC000501_A_24_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_release_handling
    [Tags]  REG  CRT
    [1.0] 5GC000501_A_24_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_release_handling


5GC000501_A_23_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_handovers_handling
    [Documentation]  This test describes automation part for feature 5GC000501 which concerns parameters verification and handovers handling.
    ...              This test covers following operations realated to the Graceful cell shutdown feature like:
    ...              1) Check of neccessary precondition parameters,
    ...              2) Check feature activation parameter,
    ...              3) Check feature proper working according to feature's parameters values,
    ...              4) Check 'Intra gnB intra frequency' handover,
    ...              5) Check proper feauture deactivation working according to feature's parameters values.
    [1.0] 5GC000501_A_23_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_parameters_check_and_UE_handovers_handling


5GC000501_A_22_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_invalid_parameters_values_handling
    [Documentation]  This test describes automation part for feature 5GC000501 which concerns validation and handling
    ...              of invalid values for parameters.
    ...              This test covers following operations realated to the Gracefull cell shutdown feature like:
    ...              1) Check if test fail for out of range parameters values
    ...              2) Check if feauture activation fail becouse of invalid parameters
    [1][1.0] 5GC000501_A_22_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_invalid_parameters_values_handling


5GC000501_A_21_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_operators_parameters_check
    [Documentation]  This test describes automation part for feature 5GC000501 which concerns operator's parameters check.
    ...              This test covers following operations realated to the Gracefull cell shutdown feature like:
    ...              Check operator's parameters after graceful cell shutdown
    [1][1.0] 5GC000501_A_21_Graceful_Cell_shutdown_for_concurrent_mode_NSA_and_SA_configuration_operators_parameters_check
