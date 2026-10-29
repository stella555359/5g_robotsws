*** Settings ***
Documentation
...     [Procedure]     "verification of the counters related to Ethernet link and Ethernet interface"
...		[Author]     	"Naresh"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     ". . . ."
...     [Feature_ID]            "5GC000349"
...     [Requirement ID]   "5G_RAN_USR_1815, 5G_RAN_TRS_68, 5G_RAN_TRS_64"
...     [Funtion_Hash_Tags] "COUNTERS"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

*** Test Cases ***
[1][1.0] TRS_5GC000349_PMCounters_Ethernet_Interface_Statistics
    Set reference counter values    1..*
    PM Counters Start       analysis=ethif_ethlk_counters       counter_analysis_file=${counter_analysis_file_name}     alias=default
    ...     pm_interval=15
    Execute command on ENodeB   ping -I '${mplaneIP}' '${gatewayIP}' -c 1000
    sleep    100
    Verify PM Counters      analysis=ethif_ethlk_counters       counter_analysis_file=${counter_analysis_file_name}     alias=default
    ...      pm_interval=15

***Keywords***
Read mplane and gateway IP
        ${mplaneIP}=     Get Parameter   param_path=${mplane_ipv4_moc}
        Set Suite Variable          ${mplaneIP}
        ${gatewayIP} =            Get Parameter       rat=5g      param_path=${GWIP_moc}
        Set Suite Variable         ${gatewayIP}

Set reference counter values
        [Arguments]     ${Class1}
        Set Suite Variable      ${Class1}       ${Class1}