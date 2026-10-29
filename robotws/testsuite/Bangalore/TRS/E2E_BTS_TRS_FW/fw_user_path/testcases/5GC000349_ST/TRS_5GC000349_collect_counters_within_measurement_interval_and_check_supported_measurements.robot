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
[1]TRS_5GC000349_collect_counters_within_measurement_interval_and_check_supported_measurements
    Perform Recommissioning     type=param      rat=common     param_path=${vlan_statistics_interval}       operation=update    value=5min
    ...           timeout=300     alias=default
    Set reference counter values    1..*
    Call Setup      5g=kbk_plain:data  parallel=${False}  verify_attach=${False}    attach=${False}  ipv4_or_6=ipv4     timeout=60
    Sleep   90
    Verify Bts Status   should_be_onair=${True}
    Configure UE    5g=kbk_plain:data    command=set_pdu_param      ue=1     pdu=1   trf_type=internal
    Sleep   5
    Configure UE    5g=kbk_plain:data    command=ue_register    id=1    profile=1
    Sleep   2
    Configure UE    5g=kbk_plain:data    command=ue_pdu_session_setup       pdu=1   gw=1    ue=1     nwslice=1
    Sleep   3
    Configure UE    5g=kbk_plain:data    command=trf_data_start     ue=1     pdu=1   qfi=1   dir=dl  trf_id=1    protocol=udp    mbps=75
    Sleep   3
    Configure UE    5g=kbk_plain:data    command=trf_data_start     ue=1     pdu=1   qfi=1   dir=ul  trf_id=1    protocol=udp    mbps=175
    Sleep   30
    Configure UE    5g=kbk_plain:data    command=ue_pdu_session_release  ue=1    pdu=1
    Sleep   30
    Configure UE    5g=kbk_plain:data    command=ue_deregister   id=1    ue_deregister_type=switch_off
    PM Counters Start       analysis=vlan_statistics        counter_analysis_file=${counter_analysis_file_vlan}     alias=default
    ...    pm_interval=15
    Execute command on ENodeB   ping -I '${gatewayIP}' '${mplaneIP}' -c 60
    Sleep   30
    Verify PM Counters      analysis=vlan_statistics        counter_analysis_file=${counter_analysis_file_vlan}     alias=default
    ...     pm_interval=15

***Keywords***
Set reference counter values
        [Arguments]     ${Class1}
        Set Suite Variable      ${Class1}       ${Class1}