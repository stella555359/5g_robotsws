*** Settings ***
Documentation   Keyword for CB013684

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_pm_counters
Library          ute_syslog
Resource         ../CB008474/MultiUe_MultiDRB_Wrapper_Keyword.robot
Resource         ../../../resources/robot/counter_benchmark_resource.robot

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}     1
${TRF_ID}    1
${Q_O_ADD1}    1
${epc_log_path}    /tmp/
@{5QI1}     2    12    false
&{flows_ue1_pdu1}    ${2}=${5QI1}
${SCFC}=                  ${CURDIR}/config/SCF_D_1.xml
${AP_XML}=                ${CURDIR}/config/iphy_new.xml
@{crnti_list}
&{Vonr_qos}       2=5    3=1
&{qfi_ids_vonr}        5=2    1=3
&{GBR_qos}        4=2
&{qfi_ids_gbr}    2=2
${target_dir}=    /home/ute/Desktop/
${counter_json_file}=    ${CURDIR}/config/counter_D.json
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${git_pa}  https://gitlabe1.ext.net.nokia.com/BTS_TOOLS/counter_benchmarking/-/blob/main/Bangalore/VRF_BLR1/T09/CB013684_Counter_Benchmking_D1.xlsx
*** Keywords ***
Run_CB013684_D_1_NSA
        [Arguments]    ${Iter}
        Create Beam Profiles
        Attach Ues with Defferent Beam Profiles
        Create Contnesion Resolution Profile
        Trigger Contension Resultion
        Run Keyword And Ignore Error    Start Log    btslog
        Start_Fetching_Counter_Values
        MultiUe MultiDBR registration Should Be Successfull
        Verify The Counter DL UL cell2  500    120
        Stop_Fetching_Counter_Values
        Run Keyword And Continue On Failure    Collect_Counter_Logs      ${host}     ${user}      ${password}
	    ...     ${target_dir}    ${counter_json_file}         ${git_pa}
        wts_sim_keywords.MultiUE Register should be Successful    1    4
        wts_sim_keywords.MultiUE Register with RAR timer Expiry    5    6
        wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    4   mbps    10
        Attach All NSA Ues and fetch RNTI
        MultiUE Trigger DL Traffic for NSA    11    20   mbps    150
        Trigger Beam switch to all Ues
        sleep    60s
        Validate the Counter after beam switch
        wts_sim_keywords.MultiUE Deregister should be Successful    1    4
        wts_sim_keywords.NSA Multi UE Detach should be Successful    11    20
        Ue RRC Inactive state should be successful    38    40    311    489
        Wait For Next Full Pm Interval
        Run Keyword And Ignore Error    Stop Log    btslog    test_scenario=${Iter}_syslog

Create Beam Profiles
    ute_wtssim.Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=2,0,1,3,4,5,6,7 ssbeam_bestbeam=2 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-90
        ute_wtssim.Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5,6,7 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-90
        ute_wtssim.Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=3,0,1,2,4,5,6,7 ssbeam_bestbeam=3 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-90
    ute_wtssim.Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=0,1,2,3,4,5,6,7 ssbeam_bestbeam=0 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-90
    sleep    2s
    ute_wtssim.Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2

Attach Ues with Defferent Beam Profiles
     Attach Ues to the Beam Profile    11    14     1
     Attach Ues to the Beam Profile    15    17     2
     Attach Ues to the Beam Profile    18    20     3
     Attach Ues to the Beam Profile    1   2     2
     Attach Ues to the Beam Profile    3   4     4
     Attach Ues to the Beam Profile    5   6     2

Attach Ues to the Beam Profile
     [Arguments]     ${Start_Ueid}  ${End_Ueid}   ${beamprofile}
     FOR   ${Ueid}   IN RANGE   ${Start_Ueid}    ${End_Ueid}+1
         ute_wtssim.Execute Egate Command
         ...    cmd=ue_testmode_set_nr id=${Ueid} testmode=beam_control action=activate profile_id=${beamprofile} beamaction=attach
     END

Attach Ues with Different Neighbour Profiles
     Crete NR neighbour Cells   11    14     2
     Crete NR neighbour Cells    15    17     1
     Crete NR neighbour Cells   18    20     3
     sleep    2s
     ute_wtssim.Execute Egate Command    cmd=enb_endc_param id=1 include_candidate_cell_info_list_mn=on
     sleep    2s

MultiUe MultiDBR registration Should Be Successfull
    Register ALL Ues and Send Low data    Start_ue=21    End_ue=37
    Log to console    Adding Vonr Ues
    QosFlow addition should be Successful     21   23      ${Vonr_qos}     ${qfi_ids_vonr}
    QosFlow addition should be Successful     24   30       ${GBR_qos}     ${qfi_ids_gbr}
    Trigger Multiue Data

Crete NR neighbour Cells
   [Arguments]     ${Start_Ueid}  ${End_Ueid}   ${profile}
   FOR   ${Ueid}   IN RANGE   ${Start_Ueid}    ${End_Ueid}+1
       ute_wtssim.Execute Egate Command
       ...   cmd=ue_meas_param id=${Ueid} nr_neigh_cell=non_cfgd:50 nr_rsrp=127 nr_rsrq=127 rs_result_index=${profile} rs_result=126:124:125
   END

Verify The Counter DL UL cell2
    [Arguments]    ${DL_rate}    ${UL_rate}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${PM_dir1}=      Get Latest Unpacked Full Pm Counters File
    ${DLG_06}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01006    local_moid=NRCELL-2
    ${DLG_01}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C01001    local_moid=NRCELL-2
    ${DLG_04}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C01002    local_moid=NRCELL-2
    ${DLG_06}=   convert to integer    ${DLG_06}
    ${DLG_01}=   convert to integer    ${DLG_01}
    ${DLG_04}=   convert to integer    ${DLG_04}
    ${DL_Primary}    Evaluate    ${DLG_04}+${DLG_06}+${DLG_01}
    ${DL_Primary}    Evaluate    ${DL_Primary}*8/300000000
    ${ULG_06}    Get Latest Pm Counter Value   filepath=${PM_dir1}    counter_id=M55310C03006    local_moid=NRCELL-2
    ${ULG_01}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C03001    local_moid=NRCELL-2
    ${ULG_04}    Get Latest Pm Counter Value    filepath=${PM_dir1}    counter_id=M55310C03002    local_moid=NRCELL-2
    ${ULG_06}=   convert to integer    ${ULG_06}
    ${ULG_01}=   convert to integer    ${ULG_01}
    ${ULG_04}=   convert to integer    ${ULG_04}
    ${UL_Primary}    Evaluate    ${ULG_04}+${ULG_06}+${ULG_01}
    ${UL_Primary}    Evaluate    ${UL_Primary}*8/300000000
    Should be True    ${DL_Primary} > ${DL_rate}
    Should be True    ${UL_Primary} > ${UL_rate}

Trigger Beam switch to all Ues
     Trigger Beam switch    11    14     2
     Trigger Beam switch    15    17     1
     Trigger Beam switch    18    20     1
     sleep    2s

Trigger Beam switch
   [Arguments]     ${Start_Ueid}  ${End_Ueid}   ${profile}
   FOR   ${Ueid}   IN RANGE   ${Start_Ueid}    ${End_Ueid}+1
       ute_wtssim.Execute Egate Command
       ...   cmd=ue_testmode_set_nr id=${Ueid} testmode=beam_control action=activate profile_id=${profile} beamaction=switch scell=8
   END

Trigger Multiue Data
     wts_sim_keywords.MultiUE Trigger DL Traffic for SA    31    33    Traffic_rate=mbps   dl_rate=1   pdu_id=1
    ...    trf_id=1   qfi_id=1
    Sleep   30s
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    31    33    Traffic_rate=mbps   ul_rate=1   pdu_id=1
    ...    trf_id=1   qfi_id=1
    MultiUe_MultiDRB_Wrapper_Keyword.Start Multi UE DL traffic with multiple trafficID     start_ue=34   end_ue=37    Traffic_rate=mbps
	...    dl_trf_id=3    qfi_id=1    dl_rate_DL=150
    MultiUe_MultiDRB_Wrapper_Keyword.Start Multi UE UL traffic with multiple trafficID     start_ue=34   end_ue=37    Traffic_rate=mbps
	...    ul_trf_id=1    qfi_id=1    ul_rate_UL=50

Create Contnesion Resolution Profile
    ute_wtssim.Execute Egate Command    cmd=cont_res_testmode_nr profile_id=4 msg3_retx=5
    ute_wtssim.Execute Egate Command    cmd=cont_res_testmode_nr profile_id=2 missed_ra_resp=200

Trigger Contension Resultion
   Activate Contention Resolution Profile     3    4    4
   Activate Contention Resolution Profile     5    6    2

Activate Contention Resolution Profile
   [Arguments]     ${Start_Ueid}  ${End_Ueid}   ${profile}
   FOR   ${Ueid}   IN RANGE   ${Start_Ueid}    ${End_Ueid}+1
       ute_wtssim.Execute Egate Command
       ...    cmd=ue_testmode_set_nr id=${Ueid} action=activate testmode=contention_resolution profile_id=${profile}
   END

Validate the Counter after beam switch
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55306C05001    10     RA_COMP_DED_PRMBL
    ...     M55306C02002    3     RA_ATT_DED_PRMBL_SSB_01
    ...     M55306C02003    4     RA_ATT_DED_PRMBL_SSB_02
    ...     M55306C02004    3     RA_ATT_DED_PRMBL_SSB_03
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    ${CFRA_ATT_DED_PRMBL_SSBPM}  ta5g_pm_counters.get_pm_counter_value   M55202C00001   PLMN-PLMN/SSBPM-1   ${pm_counter_file}
    Should be Equal  ${CFRA_ATT_DED_PRMBL_SSBPM}[0]   ${3}
    Log to Console    SSBPM-1 CFRA_ATT_DED_PRMBL_SSBPM -->${CFRA_ATT_DED_PRMBL_SSBPM}[0]
    ${CFRA_COMP_SSBPM}  ta5g_pm_counters.get_pm_counter_value   M55202C00002   PLMN-PLMN/SSBPM-1   ${pm_counter_file}
    Should be Equal   ${CFRA_COMP_SSBPM}[0]    ${3}
    Log to Console    SSBPM-1 CFRA_COMP_SSBPM -->${CFRA_COMP_SSBPM}[0]
    Verify Last Counters In File
    ...     M55202C00001    4     CFRA_ATT_DED_PRMBL_SSBPM
    ...     M55202C00002    4     CFRA_COMP_SSBPM
    ...     local_moid=PLMN-PLMN/SSBPM-2
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55202C00001    3     CFRA_ATT_DED_PRMBL_SSBPM
    ...     M55202C00002    3     CFRA_COMP_SSBPM
    ...     local_moid=PLMN-PLMN/SSBPM-3
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55306C00001    4-30     RA_ATT_CONT_A_PRMBL_SSB_00
    ...     M55306C00002    15-30     RA_ATT_CONT_A_PRMBL_SSB_01
    ...     M55306C06001    4-25     RA_MSG3_RECEP
    ...     M55306C10005    15-25     RA_CBRA_INI_MSG3_DTX
    ...     M55306C10006    5-15    RA_CBRA_UL_GRANT_MSG3_RETX
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-2
    ...     file_path=${pm_counter_file}
    ${CBRA_ATT_SSBPM}  ta5g_pm_counters.get_pm_counter_value   M55202C00003  MRBTS-1/NRBTS-1/NRCELL-2   ${pm_counter_file}
    Should be Equal    ${CBRA_ATT_SSBPM}[0]   ${4}
    Should be Equal    ${CBRA_ATT_SSBPM}[1]   ${22}
    ${CBRA_INI_MSG3_DTX_SSBPM}  ta5g_pm_counters.get_pm_counter_value   M55202C00004   MRBTS-1/NRBTS-1/NRCELL-2   ${pm_counter_file}
    Should be Equal   ${CBRA_INI_MSG3_DTX_SSBPM}[0]    ${2}
    Should be Equal   ${CBRA_INI_MSG3_DTX_SSBPM}[1]    ${2}

Attach All NSA Ues and fetch RNTI
        FOR   ${UE}    IN RANGE    11    21
            ${rnti}    NSA LTE Attach should be Successful    ${UE}
            Append To List  ${crnti_list}    ${rnti}
        END
        Attach Ues with Different Neighbour Profiles
        FOR   ${UE}    IN RANGE    11    21
            NSA UE Attach should be Successful CFRA    ${UE}    1
        END

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI
