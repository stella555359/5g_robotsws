*** Settings ***
Documentation
...   Author: Rong Nie
...   Contact: rong.nie@nokia-sbell.com
...   Description: An operator-initiated SW rollback to pre-listed unwanted SW versions is blocked.
...   In case of rollback the BTS sends an alarm in addition to the existing change notification to the NMS SW Manager.


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK

#Test Timeout    60 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../../Resources/Common/AIC_UE.robot
#Resource  ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
#Resource    ../Resources/RRM2_Resource.robot
#Resource  ../../../../resources/RAN_PZ_HAZ_1/Module/Parameter_Operation.robot
#Resource  ../../../../resources/RAN_PZ_HAZ_1/Module/Alarm_Operation.robot

*** Variables ***
${scf_path}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/New_Feature_TA/CB012487/config
${ue_index}    0
${iperf_port}    ${tl.ues[0].iperf_details.port}
*** Test Cases ***

[1][1.0] CB013664_A_B1_one_4Tx4Rx_N_type_cell_from_two_RRH_two_pipes_Radio_path_failure
    [Tags]    QC_251221      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664.
    ${scfinfo}=    evaluate    '${RELEASE}'.split('SBTS')[1]    sys
    ${scf_build}=    Set Variable If    '${RELEASE}'=='SBTS00'    SBTS00    ${scfinfo}
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...                             scf_path=${scf_path}/SCF_${scf_build}.xml
    Log To Console    full commission result: ${out_}
    wait until keyword succeeds    15 min    60 sec    BTS Operation    operation=verify   product_type=gnb
    ...                            distname_id=NRCELL-ALL           verify_status=CELL_ONAIR
    Prepare UE
    Check data transfer
    ${out_}   Parameter Operation    operation=full_commission   product_type=gnb
    ...                             scf_path=${scf_path}/SCF_${scf_build}_original.xml
    Log To Console    full commission result: ${out}
    wait until keyword succeeds    15 min    60 sec    BTS Operation    operation=verify   product_type=gnb
    ...                            distname_id=NRCELL-ALL           verify_status=CELL_ONAIR
    Check data transfer
    Log To Console    CB013664
    [Teardown]    TC01 Teardown


[1][1.0] CB013664_A_B1_one_4Tx4Rx_N_type_cell_from_two_RRH_two_pipes_NR_full_rack
    [Tags]    QC_251224      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664.

    Log To Console    CB013664
    [Teardown]    TC01 Teardown

[1][1.0] CB013664_A_B1_one_4Tx4Rx_N_type_cell_from_two_RRH_two_pipes_LTE_half_rack
    [Tags]    QC_251225      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664.

    Log To Console    CB013664

    [Teardown]    TC01 Teardown

*** Keywords ***
TC01 Teardown
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False
Prepare UE
    Qualcomm.Prepare UE
Check data transfer
    [Arguments]    ${throughput}=200M    ${duration}=360    ${direction}=dl    ${dl_expect}=40    ${cell_id}=5816323
    Log To Console    Start prepare UE and check data transfer
    Qualcomm.UE Attach
    Qualcomm.Start traffic    iperf_port=${iperf_port}    throughput=${throughput}    duration=${duration}
    sleep   60s
    Run Keyword And Ignore Error   Check throughput     direction=${direction}    dl_expect=${dl_expect}    cell_id=${cell_id}
    Log To Console     stop traffic
    Qualcomm.Stop traffic    iperf_port=${iperf_port}
    Qualcomm.Teardown UE
    sleep   20s
Connect to APPserversim
    Connect to APPserver