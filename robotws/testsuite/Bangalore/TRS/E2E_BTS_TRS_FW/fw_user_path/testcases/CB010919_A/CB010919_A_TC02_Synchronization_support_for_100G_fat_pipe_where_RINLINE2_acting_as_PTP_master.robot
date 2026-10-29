*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Aditya M"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "Synchronization support for 100G fat pipe where RINLINE2 acting as PTP master"
...     [Date]      "08-03-2024"
...     [QC_Path]   "Root\Test_Sets\Trunk\BB_TRS_VRF_ET\CRT\NF_Automated_Regression"
...     [QC_ID]     "353202"
...     [Funtion_Hash_Tags] "100G fat pipe"
...     [Feature_ID]            "CB010919-A"
...     [Requirement ID]    "TT_GEN_SFS_SYNC.3954"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "10919"
...     [Config]    "This testcase requires basic configuration with GNSS sync module"
...     [scf_file]  "CB010919_basic_scf.xml"


Library           OperatingSystem
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB010919.robot

Suite Setup     Setup Oamops    dut=vdu_10919      alias=default
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_10919      alias=default   AND     Collect Snapshot
...     dut=vdu_10919  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_10919     alias=default

*** Test Cases ***

[1]CB010919-A-TC02 Synchronization support for 100G fat pipe where RINLINE2 acting as PTP master

     Change RANNIC sync source to GNSS via delta plan

     Reset the vDU to apply the sync changes

     Change the sync input in FHGW as TOPP

     Sleep   300

     Verify 100G fat pipe is Enabled

#     Verify RANNIC sync status is Locked

#     Verify ocp sync status is Locked

     Verify F1c link is UP
