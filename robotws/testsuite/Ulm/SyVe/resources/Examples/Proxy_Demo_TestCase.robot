*** Settings ***
Documentation   This is a Robot Demo Test Suite for feature: 5GC001167
...             Team: 'MN 5G&SC 5G Pz ULM 2 SqdGp63'
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_63@nokia.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.ue

Resource    ../../../resources/Common/testline.robot


Suite Setup    Set Console Output

*** Variables ***
@{list_weights_1}    1
@{list_weights_2}    1
@{analysis_interval_1}       ${40}    ${60}
@{analysis_interval_1_bearer1}       ${30}    ${50}
@{analysis_interval_1_bearer2}       ${20}    ${40}
&{analysis_interval_1_dict}    ${1}=${analysis_interval_1_bearer1}    ${2}=${analysis_interval_1_bearer2}
@{qci_list_1}    9    5    8
${iperf_subdir_last}    iperf_files
${DL_RATE}     500
${UL_RATE}     24
${DL_ALIAS}    DL_01
${UL_ALIAS}    UL_01
${UE_ALIAS_1}  UE_1


*** Test Cases ***
5GC001167_Test_UE_Connectivity
    [Tags]    PROXY_DEBUG
    Log to Console    \n
    Setup UE
    sleep  20s
    Start Data Transfer UL DL
    taf.ue.Await Data Transfer Finish    ${DL_ALIAS}
    taf.ue.Await Data Transfer Finish    ${UL_ALIAS}
    Run Keyword And Continue On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${UL_ALIAS}  tput=${UL_RATE} Mbits/sec  deviation=20%
    Run Keyword And Continue On Failure
    ...    taf.ue.Verify Average Throughput With Deviation    dt_name=${DL_ALIAS}  tput=310 Mbits/sec  deviation=10%
    Record iperf data
    taf.ue.Stop Data Transfer    ${DL_ALIAS}
    taf.ue.Stop Data Transfer    ${UL_ALIAS}
    taf.ue.Detach UE    ${UE_ALIAS_1}
    Sleep    10s    reason=Wait for logging issues

*** Keywords ***
Setup UE
    taf.ue.Require Ue   ${UE_ALIAS_1}  capabilities=UE_1
    sleep    10s
    taf.ue.reboot UE    ${UE_ALIAS_1}
    sleep    10s
    taf.ue.Detach UE    ${UE_ALIAS_1}
    sleep    10s
    taf.ue.Attach UE    ${UE_ALIAS_1}


Start Data Transfer UL DL
    taf.ue.Start Data Transfer    dt_name=${DL_ALIAS}    ue_alias=${UE_ALIAS_1}    direction=dl
    ...    throughput=${DL_RATE} Mbits/sec    protocol=udp    timeout=60
    ...    packet=1330   duration=30s  bearer_alias=UeAutomatic  parallel=1  buffer=50M
    taf.ue.Start Data Transfer    dt_name=${UL_ALIAS}    ue_alias=${UE_ALIAS_1}    direction=ul
    ...    throughput=${UL_RATE} Mbits/sec    protocol=udp    timeout=60
    ...    packet=1330   duration=30s  bearer_alias=UeAutomatic  parallel=1  buffer=50M


Record iperf data
    ${ul_throughput}=    taf.ue.Get Average Throughput  dt_name=${UL_ALIAS}
    set test variable  ${ul_throughput}
    Log to console    Get Average Throughput UL: ${ul_throughput}kbits/sec\n
    ${dl_throughput}=    taf.ue.Get Average Throughput  dt_name=${DL_ALIAS}
    set test variable  ${dl_throughput}
    Log to console    Get Average Throughput DL: ${dl_throughput}kbits/sec\n
