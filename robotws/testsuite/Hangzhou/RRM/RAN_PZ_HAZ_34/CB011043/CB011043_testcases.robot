*** Settings ***
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB011043/Resources/CB011043_Common_keywords.robot

Documentation
...   author: Yu lu
...   contact: lu.1.yu@nokia-sbell.com
...   squad group: SG_02

Force Tags    5G_RRM
...    PY36

Suite Setup     SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}


*** Variables ***
${data_transfer_dl}       900M
${data_transfer_ul}      80M
${Expected_Throughput_DL}      800
${Expected_Throughput_UL}      70

*** Test Cases ***
[1]CB011043-SR-C_05_L3call_Loki_based_DU_with_both_UL_and_DL_PRB_muting_active_FDBF
    [Setup]  CB011043 Case Setup
    ${version}     get software version for 11043
    Load Case SCF and Commission SCF for 11043       scf_file=commissionings/HGZ/7_5_UTE5G402T776/${version}_C_05_PRB_muting.xml
    Start DLUL traffic and Caculate Tput and catch IQ data     data_transfer_dl=${data_transfer_dl}
    ...   data_transfer_ul=${data_transfer_ul}
    ...   Expected_Throughput_DL=${Expected_Throughput_DL}
    ...   Expected_Throughput_UL=${Expected_Throughput_UL}
    Catch and check CPRT log
    Catch and check soap log
    [Teardown]  CB011043 Case Teardown
