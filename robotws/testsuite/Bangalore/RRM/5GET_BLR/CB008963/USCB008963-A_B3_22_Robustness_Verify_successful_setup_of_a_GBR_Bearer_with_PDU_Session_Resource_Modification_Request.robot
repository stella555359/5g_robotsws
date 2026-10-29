*** Settings ***
Force Tags      5G_SC_TDD    5G_RAN     SBTS00     SBTS25R2    CONFIGURED

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         CB008963_resource.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_pm_counters
Resource         ../../../resources/robot/counter_benchmark_resource.robot
Resource         config/MultiUe_MultiDRB_Wrapper_Keyword.robot

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
...                 AND     Perform SCF Delta Commissioning with TMO_delta.json
...                 AND     Perform SCF Delta Commissioning with RRC_Inactive.json
...                 AND     sleep    100s
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1    4

Documentation
...
...      author:            Sowrabha.SM  sowrabha.s_m@nokia.com
...      maintainer:        Sowrabha.SM  sowrabha.s_m@nokia.com
...
...      INTRODUCTION:    This user scenario describes the successful PDU Session Resource Modification procedure requested
...      by the AMF with establishment of a GBR QoS Flow to an existing PDU Session.
...      TEST SET NAME:  USCB008963-A B3 22 Robustness Verify successful setup of a GBR Bearer with PDU Session Resource Modification Request

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/TMO_8963_basic.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID1}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${TRF_ID}    1
${Q_O_ADD1}    1
${epc_log_path}    /tmp/
${r&d_parameter}    0x890073=0
@{5QI1}     1    12    false
@{5QI2}     2    12    false
@{5QI4}     4    12    false
@{5QI5}     5    18    false
@{5QI6}     6    18    false
@{5QI3}     3    12    false
@{5QI71}     7    12    false
@{5QI72}     8    12    false
@{5QI76}     9    12    false
@{5QI7}     10    18    false
&{flows_ue1_pdu1}    ${2}=${5QI3}    ${3}=${5QI4}
&{flows_ue1_pdu2}    ${2}=${5QI6}    ${3}=${5QI71}    ${4}=${5QI76}    ${5}=${5QI2}
&{flows_ue1_pdu3}    ${2}=${5QI6}    ${3}=${5QI71}    ${4}=${5QI72}    ${5}=${5QI2}
&{flows_ue1_tc2}    ${2}=${5QI2}    ${3}=${5QI3}    ${4}=${5QI4}
&{flows_ue1_pdu2_tc2}    ${2}=${5QI5}    ${3}=${5QI1}
&{flows_ue2_tc2}     ${2}=${5QI2}    ${3}=${5QI3}    ${4}=${5QI4}     ${5}=${5QI7}
${change_Priority_for_5QI_5}     qosflow_modify qos_flow=5 priority=2
${change_Priority_for_5QI_5_15}     qosflow_modify qos_flow=5 priority=15
${change_Priority_for_5QI_1}      qosflow_modify qos_flow=1 priority=1
${change_Priority_for_5QI_1_15}      qosflow_modify qos_flow=1 priority=15
${change_default_5QI_to_7}     qosflow_modify qos_flow=10 priority=2
${change_default_5QI_to_7_15}     qosflow_modify qos_flow=10 priority=15
&{Vonr_qos}       6=6
&{qfi_ids_vonr}        6=2
${target_dir}=    /home/ute/Desktop/
${counter_json_file}=    ${CURDIR}/config/counter_8963_22.json
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${git_path}=   https://gitlabe1.ext.net.nokia.com/BTS_TOOLS/counter_benchmarking/-/blob/main/Bangalore/VRF_BLR1/T09/CB08963_Counter_Benchmking2.xlsx

*** Test Cases ***
[1][1.0] USCB008963-A_B3_22_Robustenss_Verify_successful_setup_of_a_GBR_Bearer_with_PDUSessionResourceModification_Request
       [Tags]    TC01
        ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
        Set Test Variable    ${Validation}    ${True}
        Run USCB008963_A_B3_22_GBR_Bearer_addition_with_PDUSessionResourceModification_Request
        ${tmp}   Set Variable     ${LOG_PATH}
        Set Test Variable    ${Validation}    ${False}
        FOR   ${loop}   IN RANGE   1    10
            ${LOG_PATH}   Set Variable      ${tmp}/[Loop_${loop}]
            set test variable      ${LOG_PATH}
            Create Directory        ${LOG_PATH}
            Run USCB008963_A_B3_22_GBR_Bearer_addition_with_PDUSessionResourceModification_Request
        END
        Start_Fetching_Counter_Values
        MultiUe MultiDBR registration Should Be Successful
        Verify The Counter DL UL    10    5
        Stop_Fetching_Counter_Values
        [Teardown]   Run Keywords    Link SCOUT SCF to Configuration ID for Reporting
         ...         AND      Check resource hanging

[1][1.0] USCB008963_A_B9_16_Verify_Successful_setup_of_5QI-1_QoSFlow_without_the_presence_of_5QI-5_QoS_Flow
        [Tags]    TC02
        ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
        set test variable      ${LOG_PATH}
        Set Test Variable    ${Validation}    ${True}
        Run USCB008963_A_B9_16_Verify_Successful_setup_of_5QI-1_QoSFlow_without_the_presence_of_5QI-5
        Set Test Variable    ${Validation}    ${False}
        Change Default 5QI Value Qos Flow    qos_flow=1  5qi=1   type=gbr   default=on
        Run USCB008963_A_B3_22_GBR_Bearer_addition_with_PDUSessionResourceModification_Request
        [Teardown]   Run Keywords        Link SCOUT SCF to Configuration ID for Reporting
        ...     AND    wts_sim_keywords.MultiUE Deregister should be Successful    2    4
        ...     AND    wts_sim_keywords.Clean edaemon and egate

*** Keywords ***
MultiUe MultiDBR registration Should Be Successful
    Register ALL Ues and Send Low data    Start_ue=200    End_ue=220
    Log to console    Adding Vonr Ues
    QosFlow addition should be Successful     200   202      ${Vonr_qos}     ${qfi_ids_vonr}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    210    212    Traffic_rate=mbps   dl_rate=1   pdu_id=1
    ...    trf_id=1   qfi_id=1
    Sleep   30s
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    210    212    Traffic_rate=mbps   ul_rate=1   pdu_id=1
    ...    trf_id=1   qfi_id=1
    Start Multi UE DL traffic with multiple trafficID     start_ue=213   end_ue=220    Traffic_rate=mbps    dl_trf_id=1    qfi_id=1    dl_rate_DL=50
    Start Multi UE UL traffic with multiple trafficID     start_ue=213   end_ue=220    Traffic_rate=mbps    ul_trf_id=1    qfi_id=1    ul_rate_UL=10

Verify The Counter DL UL
    [Arguments]    ${DL_rate}    ${UL_rate}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${PM_dir1}=      Get Latest Unpacked Full Pm Counters File
    ${DLG_06}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01006    local_moid=NRCELL-1
    ${DLG_01}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C01001    local_moid=NRCELL-1
    ${DLG_06}=   convert to integer    ${DLG_06}
    ${DLG_01}=   convert to integer    ${DLG_01}
    ${DL_Primary}    Evaluate    ${DLG_06}+${DLG_01}
    ${DL_Primary}    Evaluate    ${DL_Primary}*3/300000000
    ${ULG_06}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C03006    local_moid=NRCELL-1
    ${ULG_01}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C03001    local_moid=NRCELL-1
    ${ULG_06}=   convert to integer    ${ULG_06}
    ${ULG_01}=   convert to integer    ${ULG_01}
    ${UL_Primary}    Evaluate    ${ULG_06}+${ULG_01}
    ${UL_Primary}    Evaluate    ${UL_Primary}*3/300000000
    Should be True    ${DL_Primary} > ${DL_rate}
    Should be True    ${UL_Primary} > ${UL_rate}

Run USCB008963_A_B3_22_GBR_Bearer_addition_with_PDUSessionResourceModification_Request
        Register UE with GBR and check default bearer and PDCP length     ue_id=1    default_drb=false   pdcplength=12
        FOR    ${5QI}   IN RANGE    2    4
           Add Qos flow and check PDCP Lenght and Default DRB   ue_id=1   pdu_id=1    flow_dict=${flows_ue1_pdu1}   5QI=${5QI}
        END
        Change Default 5QI Value Qos Flow    qos_flow=5  5qi=5   type=non-gbr   default=on
        Add PDU to UE and send data Check PDCP Lenght and Default DRB    ue_id=1   pdu_id=2    nw_id=1    gw_id=1   default_drb=true    pdcplength=18
        FOR   ${5QI}   IN RANGE    2    6
            Add Qos flow and check PDCP Lenght and Default DRB    ue_id=1   pdu_id=2    flow_dict=${flows_ue1_pdu2}   5QI=${5QI}
        END
        Change Default 5QI Value Qos Flow    qos_flow=9  5qi=76   type=gbr   default=on
        Add PDU to UE and send data Check PDCP Lenght and Default DRB   ue_id=1   pdu_id=3    nw_id=1    gw_id=1   default_drb=true    pdcplength=12
        Change Default 5QI Value Qos Flow    qos_flow=10  5qi=8   type=non-gbr   default=off
        FOR   ${5QI}   IN RANGE    2    6
            Add Qos flow and check PDCP Lenght and Default DRB    ue_id=1   pdu_id=3    flow_dict=${flows_ue1_pdu3}   5QI=${5QI}
        END
        wts_sim_keywords.UE PDU Modification should be Successful for QFI delete    ue_id=1      pdu_id=3     qosflows_to_del=9
        Change Default 5QI Value Qos Flow    qos_flow=1  5qi=1   type=gbr   default=on
        Verify legacy Counters
        wts_sim_keywords.MultiUE Deregister should be Successful    1    1


Run USCB008963_A_B9_16_Verify_Successful_setup_of_5QI-1_QoSFlow_without_the_presence_of_5QI-5
    Register UE with GBR and check default bearer and PDCP length     ue_id=4    default_drb=false    pdcplength=12
    FOR   ${5QI}   IN RANGE    2   5
        Add Qos flow and check PDCP Lenght and Default DRB    ue_id=4    pdu_id=1    flow_dict=${flows_ue1_tc2}    5QI=${5QI}
    END
    Change Default 5QI Value Qos Flow    qos_flow=10  5qi=7   type=non-gbr   default=on
    ute_wtssim.Execute Egate Command   ${change_default_5QI_to_7}    timeout=${EGATE_COMMAND_TIMEOUT}
    Add PDU to UE and send data Check PDCP Lenght and Default DRB    ue_id=4   pdu_id=2    nw_id=1    gw_id=1   default_drb=true    pdcplength=18
    ute_wtssim.Execute Egate Command   ${change_Priority_for_5QI_5}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command   ${change_Priority_for_5QI_1}    timeout=${EGATE_COMMAND_TIMEOUT}
    FOR   ${5QI}   IN RANGE    2   4
        Add Qos flow and check PDCP Lenght and Default DRB   ue_id=4   pdu_id=2    flow_dict=${flows_ue1_pdu2_tc2}   5QI=${5QI}
    END
    Change Default 5QI Value Qos Flow    qos_flow=7  5qi=71   type=gbr   default=on
    ute_wtssim.Execute Egate Command   ${change_default_5QI_to_7_15}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command   ${change_Priority_for_5QI_5_15}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command   ${change_Priority_for_5QI_1_15}    timeout=${EGATE_COMMAND_TIMEOUT}
    Register UE with GBR and check default bearer and PDCP length     ue_id=2    default_drb=true    pdcplength=12
    FOR   ${5QI}   IN RANGE    2   6
        Add Qos flow and check PDCP Lenght and Default DRB    ue_id=2    pdu_id=1    flow_dict=${flows_ue2_tc2}    5QI=${5QI}
    END
    BuiltIn.Log     Enable dlflowcontrolalgo_for 5QI3 in WEBEM
    Perform SCF Delta Commissioning with Delta_Configuration_dlFlowControlAlgo_3gppFlowControl_nrdrb17_5qi3.json
    Change Default 5QI Value Qos Flow    qos_flow=3  5qi=3   type=gbr   default=on
    Register UE with GBR and check default bearer and PDCP length     ue_id=3    default_drb=true    pdcplength=12
    Verify RLC legacy Counters Feature Specific
#    Trigger multiple UE HO to Target Cell  start_ue=1   end_ue=3   meas_id=1   target_cell=51
#    Verify RLC legacy Counters after HO in source NRcell-1
#    Verify RLC legacy Counters after HO to in Target NRcell-2
#    Trigger multiple UE HO to Target Cell  start_ue=1   end_ue=3   meas_id=1   target_cell=50
#    Verify RLC legacy Counters after HO in source NRcell-2
#    Verify RLC legacy Counters after HO to in Target NRcell-1
#    wts_sim_keywords.MultiUE Deregister should be Successful    2     4

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI
