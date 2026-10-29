*** Settings ***
#Force Tags       CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_TDD
#...             CRT    5G_RAN_FDD    SBTS00    RAN_5G    5G_RAN    CONFIGURED


Documentation    :copyright: Nokia
...              :authors: Chaithanya H S
...              :contact: chaithanya.h_s@nokia.com
...   In this feature FD scheduler will randomly allocate RBGs throughout the entire bandwidth.
...   When CB008955 is enabled the High Performance (HP) UEs will be allocated RBGs in the HP portion of the bandwidth
...   per the CB008955 algorithms and the non-HP UEs shall be allocated RBGs per the RBG random allocation order in the
...	  non-HP portion of the bandwidth.In this scenario there is only one BWP that covers the full bandwidth.
...   Requirement ID - 5G_RAN_USR_RRM_16851.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         resource/resource_9426_8955.resource
#Resource         ../CB008955_CRT/8955_new_resources.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/counter_benchmark_resource.robot
Resource         ../CB008474/MultiUe_MultiDRB_Wrapper_Keyword.robot
Library          ta5g_pm_counters
Resource         ../../../resources/robot/PM_Counters.robot

*** Variables ***
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${epc_log_path}        /tmp/
@{pysical_cell_ids}    51
&{Vonr_qos}       2=5    3=1
&{qfi_ids_vonr}        5=2    1=3
${target_dir}=    /home/ute/Desktop/
${counter_json_file}=    ${CURDIR}/config/counter_cni9426.json
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${git_path}=   https://gitlabe1.ext.net.nokia.com/BTS_TOOLS/counter_benchmarking/-/blob/main/Bangalore/VRF_BLR1/T09/CNi9426_enable_Counter.xlsx
${git_path_1}=   https://gitlabe1.ext.net.nokia.com/BTS_TOOLS/counter_benchmarking/-/blob/main/Bangalore/VRF_BLR1/T09/CNi9426_diable_Counter.xlsx

*** Keywords ***
Run CB009426_C_1_Verify_Randomized_RBG_allocations_in_one_BWP_with_CB009426_and_CB008955_enabled_TDD
    Start_Fetching_Counter_Values
    MultiUe MultiDBR registration Should Be Successful cell1   1    20    5    8    9    18
    NSA Ue Attach Should Be Successful cell    37    38    1    2
    Verify The Counter DL    500    NRCELL-1
    Stop_Fetching_Counter_Values
    Collect_Counter_Logs      ${host}     ${user}      ${password}
	...     ${target_dir}    ${counter_json_file}         ${git_path}
    Verify 8955 counter
    Capture TTI trace and verify RBG Randomization    50    ${LOG_PATH}     initial    ${crnti_list_1}
	MultiUe_MultiDRB_Wrapper_Keyword.Deregister Multiple Ues    1    20
	NSA Multi UE Detach should be Successful    37    38

	resource_9426_8955.Perform SCF Delta Commissioning with Delta_Configuration_celllock.json
    Sleep   120s
    resource_9426_8955.Perform SCF Delta Commissioning with Delta_Configuration_cellunlock.json
    Sleep   120s

    MultiUe MultiDBR registration Should Be Successful cell2    21    34    21    24    25    34
    Verify The Counter DL    500    NRCELL-2
    NSA Ue Attach Should Be Successful cell    39    40    1    2
    Capture TTI trace and verify RBG Randomization    51    ${LOG_PATH}     initial    ${crnti_list_2}
	MultiUe_MultiDRB_Wrapper_Keyword.Deregister Multiple Ues    21    34
	NSA Multi UE Detach should be Successful    39    40

    resource_9426_8955.Perform SCF Delta Commissioning with Delta_Conf_disable_Random.json
	Start_Fetching_Counter_Values
	MultiUe MultiDBR registration Should Be Successful cell1    1    20    5    8    9    18
    NSA Ue Attach Should Be Successful cell    37    38    1    2
	Verify The Counter DL    500    NRCELL-1
    Stop_Fetching_Counter_Values
    Collect_Counter_Logs      ${host}     ${user}      ${password}
	...     ${target_dir}    ${counter_json_file}         ${git_path_1}
    Verify 8955 counter
    Capture TTI trace and verify RBG Randomization    50    ${LOG_PATH}     initial    ${crnti_list_1}
	MultiUe_MultiDRB_Wrapper_Keyword.Deregister Multiple Ues    1    20
    NSA Multi UE Detach should be Successful    37    38
	MultiUe_MultiDRB_Wrapper_Keyword.Ue RRC Inactive state should be successful    35    36    311    489

*** Keywords ***
NonVONR 5qi-6 traffic should be Successful
    [Arguments]    ${Start_ue_nvonr}    ${End_ue_nvonr}
    log to console   NonVONR-2UEs Cell1 Attach trigerring now
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA   ${Start_ue_nvonr}    ${End_ue_nvonr}    Traffic_rate=mbps   dl_rate=50
	...    pdu_id=1   trf_id=1   qfi_id=1
    Sleep   30s
    Run Keyword And Continue on Failure    wts_sim_keywords.Validate DL Traffic For MultiUE SA   ${Start_ue_nvonr}    ${End_ue_nvonr}
	...    dl_rate=50   pdu_id=1   qfi_id=1

Verify 8955 counter
    Wait until the next Measurement Period starts
    Collect PM Counters
    Run Keyword And Continue on Failure    Get 8955 counters and validate  M55308C10008  M55308C00019

Register ALL Ues and Send Low data cell1
    [Arguments]     ${Start_ue}    ${End_ue}
    ${crnti_list}     Create List
    FOR    ${ue_id}    IN RANGE    ${Start_ue}   ${End_ue}+1
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ${ue_id}
    Append to list   ${crnti_list}    ${rnti}
    wts_sim_keywords.Trigger DL Data Traffic for SA   ue_id=${ue_id}    Traffic_rate=kbps     dl_rate=15    pdu_id=1    trf_id=1
    END
    [Return]  ${crnti_list}

Register ALL Ues and Send Low data cell2
    [Arguments]     ${Start_ue}    ${End_ue}
    ${crnti_list_cell2}     Create List
    FOR    ${ue_id}    IN RANGE    ${Start_ue}   ${End_ue}+1
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ${ue_id}
    Append to list   ${crnti_list_cell2}    ${rnti}
    wts_sim_keywords.Trigger DL Data Traffic for SA   ue_id=${ue_id}    Traffic_rate=kbps     dl_rate=15    pdu_id=1    trf_id=1
    END
    [Return]  ${crnti_list_cell2}

NSA Ue Attach Should Be Successful cell
    [Arguments]     ${Start_ue_nsa}    ${End_ue_nsa}    ${enb_is}    ${target_id}
    ute_wtssim.Execute Egate Command    cmd=enb_x2_link_up enb=${enb_is} target=${target_id}
    sleep    5s
    FOR   ${UE}    IN RANGE    ${Start_ue_nsa}    ${End_ue_nsa}+1
    wts_sim_keywords.NSA LTE Attach should be Successful    ${UE}
    END
    FOR   ${UE}    IN RANGE    ${Start_ue_nsa}    ${End_ue_nsa}+1
    wts_sim_keywords.NSA UE Attach should be Successful    ${UE}    1
    END
Collect PM Counters
    ${pm_counters_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC
    Set Suite variable  ${pm_counters_dir}

MultiUe MultiDBR registration Should Be Successful cell1
    [Arguments]     ${Start_ue}    ${End_ue}    ${Start_ue_vonr}    ${End_ue_vonr}    ${Start_ue_nvonr}    ${End_ue_nvonr}
    ${crnti_list_1}=    Register ALL Ues and Send Low data cell1    ${Start_ue}    ${End_ue}
    set test variable    ${crnti_list_1}
    Log to console    Adding Vonr Ues
    MultiUe_MultiDRB_Wrapper_Keyword.QosFlow addition should be Successful    ${Start_ue_vonr}    ${End_ue_vonr}    ${Vonr_qos}     ${qfi_ids_vonr}
    NonVONR 5qi-6 traffic should be Successful    ${Start_ue_nvonr}    ${End_ue_nvonr}

MultiUe MultiDBR registration Should Be Successful cell2
    [Arguments]     ${Start_ue}    ${End_ue}    ${Start_ue_vonr}    ${End_ue_vonr}    ${Start_ue_nvonr}    ${End_ue_nvonr}
    ${crnti_list_2}=    Register ALL Ues and Send Low data cell2    ${Start_ue}    ${End_ue}
    set test variable    ${crnti_list_2}
    Log to console    Adding Vonr Ues
    MultiUe_MultiDRB_Wrapper_Keyword.QosFlow addition should be Successful    ${Start_ue_vonr}    ${End_ue_vonr}    ${Vonr_qos}     ${qfi_ids_vonr}
    NonVONR 5qi-6 traffic should be Successful    ${Start_ue_nvonr}    ${End_ue_nvonr}

Verify The Counter DL
    [Arguments]    ${DL_rate}    ${moc}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${PM_dir1}=      Get Latest Unpacked Full Pm Counters File
    ${DLG_06}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01006    local_moid=${moc}
    ${DLG_01}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C01001    local_moid=${moc}
    ${DLG_06}=   convert to integer    ${DLG_06}
    ${DLG_01}=   convert to integer    ${DLG_01}
    ${DL_Primary}    Evaluate    ${DLG_06}+${DLG_01}
    ${DL_Primary}    Evaluate    ${DL_Primary}*8/300000000
    Should be True    ${DL_Primary} > ${DL_rate}
