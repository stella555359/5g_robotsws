*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Nethra"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "RINLINE2 Fronthaul Ethernet counters for 10G or 25G and 100G fat pipe"
...     [Date]      "11-03-2024"
...     [QC_Path]   "Root\Test_Sets\24R2\Regression\VRF_BLR2\BB_TRS_VRF_ET\CRT\NF_Automated_Regression"
...     [QC_ID]     "357576"
...     [Funtion_Hash_Tags] "Ethlk counters"
...     [Feature_ID]            "CB010919-B"
...     [Requirement ID]    "TT_GEN_COMMON_USCR_746"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "10919"
...     [Config]    "This testcase requires basic configuration with RANNIC TNL"


Library           OperatingSystem

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB010919.robot

Suite Setup     Setup Oamops    dut=vdu_10919      alias=default
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_10919      alias=default   AND     Collect Snapshot
...     dut=vdu_10919  operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_10919     alias=default

*** Test Cases ***
[1]CB010919-B TC01 RINLINE2 Fronthaul Ethernet counters for 10G or 25G and 100G fat pipe

     Setup Oamops    dut=vdu_10919    alias=default

     Verify 100G fat pipe is Enabled

     Get RANNIC TNL number from the webem

     Log   ${TNL}

     Set Suite Variable    ${TNL}

     Verify Pm Counters    dut=vdu_10919    analysis=verify_RANNIC_TNL_${TNL}_vDU    counter_analysis_file=${json_file}     pm_interval=1
     ...    alias=default

     Teardown Oamops     dut=vdu_10919     alias=default



[1]CB010919-B TC02 RINLINE2 Fronthaul Ethernet counters for 10G or 25G and 100G fat pipe Robustness and exploratory cases
     FOR   ${num}    IN RANGE   3
         Setup Oamops    dut=vdu_10919    alias=defaul
         Perform vDU reset
         Sleep    250
         Verify Pm Counters    dut=vdu_10919    analysis=verify_RANNIC_TNL_${TNL}_vDU    counter_analysis_file=${json_file}     pm_interval=1
         ...       alias=default
         Teardown Oamops     dut=vdu_10919     alias=default
     END
