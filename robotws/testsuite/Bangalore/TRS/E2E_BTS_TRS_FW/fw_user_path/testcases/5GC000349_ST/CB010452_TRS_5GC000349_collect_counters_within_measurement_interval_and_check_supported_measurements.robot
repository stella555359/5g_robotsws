*** Settings ***
Documentation
...     [Documentation]
...     [Procedure] "This testcase is verifying VLAN_Statistics counters,(i) at Normal interval, (ii)at different interval"
...		[Author]     	"Kiruthika"
...     [Feature_ID]            "5GC000349"
...     [Requirement ID]
...     [Funtion_Hash_Tags] "COUNTERS"

...     [Validated_TestLine]    "TBU"
...     [Config]    "This testscript expects Scf with Vlan configurations,vlan statistic interval to be 15 mins"
...     [Runtime param]   "bts_id is provided at run time."


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot



Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown



*** Test Cases ***
[1]CB010452_TRS_5GC000349_collect_counters_within_measurement_interval_and_check_supported_measurements

    Perform Commissioning       scf_file=${primary_154_scf}        verify_bts_status=False     alias=default       timeout=300
    sleep       180
    Perform Recommissioning     type=param      rat=common     param_path=${vlan_statistics_interval}       operation=update    value=5min
    ...           timeout=300     alias=default
    Call Setup      5g=device_1:data  parallel=${False}  verify_attach=${False}     attach=${False}  ipv4_or_6=ipv4     timeout=60
    Sleep   40
    Set reference counter values    1..*
    PM Counters Start       analysis=vlan_statistics        counter_analysis_file=${counter_analysis_file_vlan}     alias=default
    ...    pm_interval=15
    Execute command on ENodeB   ping -I '${gatewayIP}' '${mplaneIP}' -c 100
    Sleep   30
    Verify PM Counters      analysis=vlan_statistics        counter_analysis_file=${counter_analysis_file_vlan}     alias=default
    ...     pm_interval=15


***Keywords***

Set reference counter values
        [Arguments]     ${Class1}
        Set Suite Variable      ${Class1}       ${Class1}

