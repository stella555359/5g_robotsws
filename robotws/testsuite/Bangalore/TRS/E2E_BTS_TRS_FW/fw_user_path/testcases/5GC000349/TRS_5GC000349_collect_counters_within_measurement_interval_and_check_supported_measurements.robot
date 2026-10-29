*** Settings ***
Documentation
...	[Author]     	"Meghana"
...     [Procedure]     "This testcase is verifying VLAN_Statistics counters,(i) at Normal interval, (ii)at different interval"
...     [Feature_ID]    "5GC000349"
...     [Funtion_Hash_Tags] "COUNTERS"
...     [Config]    "This testscript expects Scf with Vlan configurations,vlan statistic interval to be 15 mins"

Force Tags    CLOUD_F    CA_VRF_BLR2    SBTS00    SBTS24R2    SBTS24R3    QCD_MN_RAN    QCP_RAN_VRF    CRT

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/5GC000349_common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

*** Test Cases ***
[1][1.0] TRS_5GC000349_collect_counters_within_measurement_interval_and_check_supported_measurements
    Perform Commissioning       scf_file=${Counters_SCF}   verify_bts_status=False     timeout=400     alias=default
    Sleep	300
    Read vlan from admin
    Read mplane and gateway IP
    Set reference counter values    1..*
    PM Counters Start       analysis=vlan_statistics        counter_analysis_file=${counter_analysis_file_vlan}     alias=default
    ...    pm_interval=15
    Execute command on ENodeB   ping -I '${mplaneIP}' '${gatewayIP}' -c 1000
    Sleep   100
    Verify PM Counters      analysis=vlan_statistics        counter_analysis_file=${counter_analysis_file_vlan}     alias=default
    ...     pm_interval=15
    PM Counters Start       analysis=ethif_ethlk_counters       counter_analysis_file=${counter_analysis_file_name}     alias=default
    ...     pm_interval=15
    Execute command on gnb   ping -I '${mplaneIP}' '${gatewayIP}' -c 1000
    sleep    100
    Verify PM Counters      analysis=ethif_ethlk_counters       counter_analysis_file=${counter_analysis_file_name}     alias=default
    ...      pm_interval=15