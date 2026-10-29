*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Aditya M"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "Configuration of 100G Fat pipe with FHGW or switch Network"
...     [Date]      "08-03-2024"
...     [QC_Path]   "Root\Test_Sets\Trunk\BB_TRS_VRF_ET\CRT\NF_Automated_Regression"
...     [QC_ID]     "353201"
...     [Funtion_Hash_Tags] "100G fat pipe"
...     [Feature_ID]            "CB010919-A"
...     [Requirement ID]    "TT_GEN_COMMON_USCR_742"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "trs-cran6_vDU"
...     [Config]    "This testcase requires basic configuration with RANNIC TNL"
...     [scf_file]  "CB010919_basic_scf.xml"


Library           OperatingSystem
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB010919.robot

Suite Setup     Setup Oamops    dut=vdu_10919      alias=default
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_10919      alias=default   AND     Collect Snapshot
...     dut=vdu_10919  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_10919     alias=default



*** Test Cases ***

[1]CB010919-A-TC01 Configuration of 100G Fat pipe with FHGW or switch Network

     Load the basic scf

     Change the service account password

     Enable ssh access from rannic

     Login to RANNIC and enable the R&D flag for 100G fat pipe support

     Enable 100G fat pipe in webEM

     Verify 100G fat pipe is Enabled

     Sleep   100

#     Verify RANNIC sync status is Locked

     Verify F1c link is UP

     Reset vDU 5 times and verify F1c link is UP
