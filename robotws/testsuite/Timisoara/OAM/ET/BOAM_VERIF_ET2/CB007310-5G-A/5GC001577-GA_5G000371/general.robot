*** Settings ***
Documentation
...    Author: Nicolae Bulata
...    Maintainer: Nicolae Bulata
...    Test Description: 5GC001577-GA 5GC000371 5G Node B Testability 5G Node B Unit recovery log collecting
...       and 5G NodeB supportability study
...    Execution: pybot -v CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d /opt/ute/logs/
...        testsuite/WMP/SOAM3/5G/CB007310-5G-A/5GC001577-GA_5G000371/general.robot
...    Dryrun: pybot -t "[TC_01]Collect logs after FCT critical process crash happens" --dryrun --log NONE
...        --report NONE --output NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE
...        testsuite/WMP/SOAM3/5G/CB007310-5G-A/5GC001577-GA_5G000371/general.robot
...    AC/REQ: LTE_OPR_AC_2809 / LTE_OPR_REQ_8155
...    NA in OSSEMS TRUNK

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN    SBTS22R4
...    CLOUD_5G_CLASSICAL_FULLRACK_ASILL_ABIOB1B3_AEQN_ECPRI_ASILR_ABIOB4B6_ENB
...    CA_BTS_OAM_VERIF    master_classicalbts_all   #SBTS22R2  SBTS22R3


Resource    ./resources/5GC001577-GA.robot
#Resource    ../resources/general.robot
Resource    ../../resources/pretest_posttest.robot


Suite Setup       Run Keywords       UTE TL Preparation
...                                 AND    Suite Preconditions
#Suite Teardown    Suite Postconditions
#Test Setup        Test Preconditions
#Test Teardown     Test Postconditions

*** Variables ***
${flag_present}=  0

*** Test Cases ***
[1.0] 5GC001577-GA_5GC000371-Collect logs after FCT critical process crash hapens
#    [Tags]  CRT  CA_BTS_OAM_FMRECOV  QCP_BTS_OAM  QCD_MN_BTS_OAM  QC_2722879
    5GC001577_GA-Collect logs after FCT critical process crash happens



