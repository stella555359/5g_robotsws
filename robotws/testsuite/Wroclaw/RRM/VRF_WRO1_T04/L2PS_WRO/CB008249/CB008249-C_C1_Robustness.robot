*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB008249/CB008249_keywords.robot

*** Keywords ***
CB008249-C_C1_Robustness
    Change Base threshold for NR remote interference detection
    Wait 100s After Delta Recommisioning
    Check Radios Availability
    Change Timer t300
    Wait 100s After Delta Recommisioning
    Check Radios Availability
