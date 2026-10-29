*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
#Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
#Resource      ${BASIC_PATH_5G}/BTS/General_SiSo_RAT_Block_Unblock.robot
Resource      ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...
...    Feature CB012169-SR Dual Boost FR1 TDD ABIP/ABIQ concurrent mode in 26R1 LL program:
...        CB012169-A Concurrent between NR TDD eCPRI7-2e and NR FDD (CPRI/OBSAI) normal cells
...        CB012169-B Concurrent between NR TDD eCPRI7-2e and LTE FDD (CPRI/OBSAI)
...        CB012169-F Tri-mode concurrent between NR TDD eCPRI7-2e and NR/LTE FDD (CPRI/OBSAI)
...        CB012169-G Concurrent between NR TDD eCPRI7-2e and NR FDD eCPRI7-2a (NCY)
...        CB012169-H Concurrent between NR TDD eCPRI7-2e and LTE FDD eCPRI7-2a (NCY)
...        CB012169-I Interworking with CB008369 upgrading from eCPRI7-2a to eCPRI7-2e
...        CB012169-J Interworking with eCPRI7-2e CA/RF split/RF sharing

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Test Cases ***
[1]CB012169-A-UC01_Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    5S-CB012169-A_NRFDD_NRTDD    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB012169-F-UC01_General_SiSo_RAT_Reset
   [Tags]    5S-CB012169-F_LTEFDD_and_NRFDD_NRTDD    CRT_TRUNK
   [Setup]    SISO Coam Test Setup
#    ${fault_list}    Create List    4614
#    Allowed Watchdog additional alarms    fault_list=${fault_list}
#    General_SiSo_RAT_Block_Unblock    with_call=${False}
    Manual_SiSo_SM_NR_RAT_reset    with_call=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB012169-J-03_General_SiSo_RAT_Reset_IWK02_RF-split
   [Tags]    4S-CB012169-J_RF-split    CRT_TRUNK
   [Setup]    SISO Coam Test Setup
#    ${fault_list}    Create List    4614
#    Allowed Watchdog additional alarms    fault_list=${fault_list}
#    General_SiSo_RAT_Block_Unblock    with_call=${False}
    Manual_SiSo_SM_NR_RAT_reset    with_call=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown
