*** Settings ***
Documentation
...     [Procedure]             "CNI-110539 Fault Id 10 Supplementary Info"
...     [Author]                "Sahana TC"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 ". . . ."
...     [Feature_ID]            "CNI-110539"
...     [Requirement ID]        ""
...     [Funtion_Hash_Tags]     "Security"
...     [Domain_Hash_Tags]      "Alarm Supplementary Info verification"
...     [Validated_TestLine]    "2011"
...     [Config]                ""
...     [Runtime param]         "bts_id is provided at run time."

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_CNI110539_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***

[1]TC03_CNI-110539_Verify Fault 10 with RU disconnected alarm

    Perform Commissioning       scf_file=${base_scf_TC3}   verify_bts_status=${True}     timeout=1000     alias=default
    Setup Ems  config_device=netact   alias=lab1042_omc_user
    RU was disconnected
    [Teardown]      Teardown Ems        config_device=netact     alias=lab1042_omc_user
