*** Settings ***
Documentation
...   author: Adrian Jakobik
...   contact: adrian.jakobik@nokia.com
...   This is the TESTSUITE file to check UE attach and throughput

Library     taf.ue
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Library     testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/adb_utils.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py

Suite Setup      testline_preparation.Prepare Testline


*** Variables ***
${NUMBER_OF_UES} =   3
${MIN_UL_TPUT} =     40Mbits/sec
${MIN_DL_TPUT} =     100Mbits/sec
${UL_TPUT} =         200Mbits/sec
${DL_TPUT} =         200Mbits/sec
${NETWORK_MODE} =    NR_only


*** Test Cases ***
Reboot UEs
    [Documentation]  The purpose of this test case is to reboot UEs
    Reboot UEs

Set Network Mode
    [Documentation]  The purpose of this test case is to set network mode for all UEs
    Set Network Mode   number_of_ues=${NUMBER_OF_UES}   network_mode=${NETWORK_MODE}

Check Ue Attach And Tput
    [Documentation]  The purpose of this test case is to check UE attach and throughput
    Check Ue Attach And Tput   number_of_ues=${NUMBER_OF_UES}   min_ul_tput=${MIN_UL_TPUT}
    ...                        min_dl_tput=${MIN_DL_TPUT}   ul_tput=${UL_TPUT}   dl_tput=${DL_TPUT}
