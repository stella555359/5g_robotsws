*** Settings ***
Force Tags      CRT    OPTION_RELATED_ARTIFACTS_5G    SBTS00       STATE_CONFIGURED
...             CLOUD_5G_I_MP_AP_LOOO    SANSA_FS_ECPRI_CMWV_TDD_GMC    UPGRADE_UTF


Documentation
...   Test suite for regression testing for feature CB014234
...
...   author: Nelsandro Sampaio
...   contact: nelsandro.sampaio@nokia.com


Resource    ./resources/keywords.robot
Resource    ./resources/variables.robot


Suite Setup       Run Keywords
...               Testline Setup    reach_on_air=without_x2_link    wts=${wts_file_ca}    config=${SUITE_CONFIG}
...               skip_confirmation=yes
...               AND      Start X2 Link
...               AND      Sleep    10s    reason=Wait for X2 link to be setup
Suite Teardown    Testline Teardown
#
Test Teardown     Run Keywords
...               Test Case Teardown
...      AND      Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Variables ***
@{IP_ADDR_SIM_GNB}           eth3:10.0.1.3/24    eth3:10.44.76.28/24
${SCF_BASE_CA_n261}          ${CURDIR}/configs/SCF_MP.xml
${iphy_base_ca}              ${CURDIR}/configs/IPHY_4CC_MP.xml
${wts_file_ca}               ${CURDIR}/configs/WTS_4CC_ASIM_ABIP.cfg
${ENABLE_PCMD}               ${CURDIR}/configs/PCMD_ACT_CU.json
&{SUITE_CONFIG}             scf=${SCF_BASE_CA_n261}      iphy=${iphy_base_ca}     ip_addr=${IP_ADDR_SIM_GNB}     rnd_gnb=${RND_FLAGS}
@{DCAP_GNB}                 condor5gSyslog
@{DCAP_BTS}                 ipCapture
&{DCAP_OPTIONS}             gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}           dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
&{RND_FLAGS}          0x1003F=1   # AaSysLogInputLevel
...                   0x10040=1   # AaSysLogOutputLevel
...                   0x10041=1   # ERadCcs_AaSysLogOutputMode
...                   0x590072=1  # CP-RT DEBUG level logs
...                   0x66001b=1  # CP-NRT DEBUG level logs
...                   0x890003=0  # CP-UE TRACE level logs
...                   0x890004=1  # CP-CELL DEBUG level logs
...                   0x890005=1  # CP-IF DEBUG level logs
...                   0x890002=1  # CP-SB DEBUG level logs
...                   0x890006=1  # CP-SB DEBUG level logs
...                   0x5800f4=4
...                   0x58012d=4
...                   0x5900B9=1
...                   0x580001=1
${shell_script}     /opt/wts/latest/sosReport_ASIL/airphone_mirror.sh             # This can be where you have kept the file
${python_script}    /opt/wts/latest/sosReport_ASIL/gnbMirroring.py                # This can be where you have kept the file
&{teardown_cmd}      setup=./airphone_mirror.sh    teardown=./airphone_mirror.sh --stop
&{AP}     Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=Ap


*** Test Cases ***
CB014234-SR-A_1_sgnb_mod_request_handling_for_non_ca_ue_cases
    [Documentation]
    ...     Description:
    ...               The goal of this test case is to verify the SgNB capability to handle
    ...               different Modification Requests for different UEs (including wrong inputs).
    ...               SgNB should be able to handle each request and update PM counters accordingly.
    ...
    [Setup]    Run keywords     Test Case Setup    logs=${LOGS_WITH_DCAP}
    ...        AND              Upload Delta       delta=${ENABLE_PCMD}
    Update UE capability for all UEs
    NSA UE Attach    ue_id=15
    NSA UE Attach    ue_id=16
    NSA UE Attach    ue_id=17
    Set Index and Feature Set Entry Index of Initial AllowedBC-ListMRDC for non-ca UEs
    NSA LTE-NR Dual Connectivity    ue_id=15    target_gnb=2    target_cell=1     fail_regexp=${STD_UE_ATTACH_FAIL_REG}
    NSA LTE-NR Dual Connectivity    ue_id=16    target_gnb=2    target_cell=1     fail_regexp=${STD_UE_ATTACH_FAIL_REG}
    NSA LTE-NR Dual Connectivity    ue_id=17    target_gnb=2    target_cell=1     fail_regexp=${STD_UE_ATTACH_FAIL_REG}
    Start Internal NSA Bidirectional Traffic    ue_id=15   dl_tput=20mbps    ul_tput=10mbps
    Start Internal NSA Bidirectional Traffic    ue_id=16   dl_tput=20mbps    ul_tput=10mbps
    Start Internal NSA Bidirectional Traffic    ue_id=17   dl_tput=20mbps    ul_tput=10mbps
    Set the number of UE SCell allocations for NRCELL-2 to 106
    Set the number of UE SCell allocations for NRCELL-3 to 106
    Set the number of UE SCell allocations for NRCELL-4 to 106
    Verify NSA UE Traffic Using Bearer Stats    ue_id=15     dl_tput=20mbps     ul_tput=10mbps     wait=30s
    Verify NSA UE Traffic Using Bearer Stats    ue_id=16     dl_tput=20mbps     ul_tput=10mbps     wait=30s
    Verify NSA UE Traffic Using Bearer Stats    ue_id=17     dl_tput=20mbps     ul_tput=10mbps     wait=30s
    NSA UE Attach    ue_id=18
    NSA UE Attach    ue_id=19
    NSA UE Attach    ue_id=20
    NSA UE Attach    ue_id=21
    Set Index and Feature Set Entry Index of Initial AllowedBC-ListMRDC for CA UEs
    NSA LTE-NR Dual Connectivity    ue_id=18    target_gnb=2    target_cell=1     fail_regexp=${STD_UE_ATTACH_FAIL_REG}
    NSA LTE-NR Dual Connectivity    ue_id=19    target_gnb=2    target_cell=1     fail_regexp=${STD_UE_ATTACH_FAIL_REG}
    NSA LTE-NR Dual Connectivity    ue_id=20    target_gnb=2    target_cell=1     fail_regexp=${STD_UE_ATTACH_FAIL_REG}
    NSA LTE-NR Dual Connectivity    ue_id=21    target_gnb=2    target_cell=1     fail_regexp=${STD_UE_ATTACH_FAIL_REG}
    Start Internal NSA Bidirectional Traffic    ue_id=18   dl_tput=20mbps    ul_tput=10mbps
    Start Internal NSA Bidirectional Traffic    ue_id=19   dl_tput=20mbps    ul_tput=10mbps
    Start Internal NSA Bidirectional Traffic    ue_id=20   dl_tput=20mbps    ul_tput=10mbps
    Start Internal NSA Bidirectional Traffic    ue_id=21   dl_tput=20mbps    ul_tput=10mbps
    sleep      60s
    Verify NSA UE Traffic Using Bearer Stats    ue_id=18     dl_tput=20mbps     ul_tput=10mbps     wait=5s
    Verify NSA UE Traffic Using Bearer Stats    ue_id=19     dl_tput=20mbps     ul_tput=10mbps     wait=5s
    Verify NSA UE Traffic Using Bearer Stats    ue_id=20     dl_tput=20mbps     ul_tput=10mbps     wait=5s
    Verify NSA UE Traffic Using Bearer Stats    ue_id=21     dl_tput=20mbps     ul_tput=10mbps     wait=5s
    Trigger Lack of Nr-SCG_Response IE During SgNBModification Procedure for UE-21
    Set Index and Feature Set Entry Index of AllowedBC-ListMRDC in Modification Request for all attached UEs
    ta5g_pm_counters.Wait For Next Full Pm Interval
    Trigger SgNB Modification Request Message From MeNB     ue_id=15
    Trigger SgNB Modification Request Message From MeNB     ue_id=16
    Trigger SgNB Modification Request Message From MeNB     ue_id=17
    Trigger SgNB Modification Request Message From MeNB     ue_id=18
    Trigger SgNB Modification Request Message From MeNB     ue_id=19
    Trigger SgNB Modification Request Message From MeNB     ue_id=21
    Trigger 10 multiple consecutive SgNBModificationRequest for UE-20
    ${pm_counter_path}    ta5g_pm_counters.Get Next Unpacked Full Pm Counters File
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    set test variable       ${WIRESHARK_TCPDUMP}       ${TEST_tcpdump_gnb_path}
    Get SgNBModificationRequestAcknowledge messages for all 7 attached UEs
    Get SgNBModificationRequestReject for UE-5
    Verify that Carrier Aggregation was configured for all capable UEs     num_of_ues=7
    Verify that the SgNBModRequestReject was sent for UE
    ...      json_filepath=${TEST_log_dir}/Wireshark/tcpdump_pcap_SgnbModReqRej_UE-5.json
    ...      exp_nr=6
    Verify PM Counters Have Exact Values    filepath=${pm_counter_path}     counters=${NX2CC_COUNTERS}
    Verify PM Counters Have Exact Values    filepath=${pm_counter_path}     counters=${SGNB_DL_SCELL_ADMI_SUCC}
    Verify PM Counters Have Exact Values    filepath=${pm_counter_path}     counters=${SGNB_DL_SCELL_REQ}
    Verify PM Counters Have Exact Values    filepath=${pm_counter_path}     counters=${SGNB_DL_SCELL_SUCC}
    Verify PM Counters Have Exact Values    filepath=${pm_counter_path}     counters=${RRC_RECONF_DL_SUCC}
    Verify PM Counters Have Exact Values    filepath=${pm_counter_path}     counters=${RRC_RECONF_DL_ATT}
    Verify PM Counters Have Exact Values    filepath=${pm_counter_path}     counters=${SUCC_UL_SCELL_RELEASE}
    Verify PM Counters Have Exact Values    filepath=${pm_counter_path}     counters=${SUCC_DL_SCELL_RELEASE}
    Verify PM Counters Have Exact Values    filepath=${pm_counter_path}     counters=${NUM_OF_DL_SCELLS_RELEASED}


*** Keywords ***
Update UE capability for all UEs
    Update UE Parameters
    ...      ue_id=15
    ...      ue_nr_capabilities=$NR_CAP
    ...      ue_eutra_nr_capabilities=$eutra_4cc_bc1
    Update UE Parameters
    ...      ue_id=16
    ...      ue_nr_capabilities=$NR_CAP
    ...      ue_eutra_nr_capabilities=$eutra_4cc_bc1
    Update UE Parameters
    ...      ue_id=17
    ...      ue_nr_capabilities=$NR_CAP
    ...      ue_eutra_nr_capabilities=$eutra_4cc_bc1
    Update UE Parameters
    ...      ue_id=18
    ...      ue_nr_capabilities=$NR_CAP
    ...      ue_eutra_nr_capabilities=$eutra_4cc_bc1
    Update UE Parameters
    ...      ue_id=19
    ...      ue_nr_capabilities=$NR_CAP
    ...      ue_eutra_nr_capabilities=$eutra_4cc_bc1
    Update UE Parameters
    ...      ue_id=20
    ...      ue_nr_capabilities=$NR_CAP
    ...      ue_eutra_nr_capabilities=$eutra_4cc_bc1
    Update UE Parameters
    ...      ue_id=21
    ...      ue_nr_capabilities=$NR_CAP
    ...      ue_eutra_nr_capabilities=$eutra_4cc_bc1

Trigger Lack of Nr-SCG_Response IE During SgNBModification Procedure for UE-${ue_id}
    Execute Egate Command
    ...  cmd=nr_rrc_reconf_ue_param id=${ue_id} if_contains=mrdc_scg_setup action=donot_send_scgNrResponse

Set Index and Feature Set Entry Index of Initial AllowedBC-ListMRDC for non-ca UEs
    Set Indexes And Feature Set Entry Index Of Initial AllowedBC-ListMRDC Configured During SgNB Addition
    ...      ue_id=15
    ...      allowed_bc_list=1:1|2:1
    ...      serving_cell_index_range_scg=7:16
    Set Indexes And Feature Set Entry Index Of Initial AllowedBC-ListMRDC Configured During SgNB Addition
    ...      ue_id=16
    ...      allowed_bc_list=2:1|3:1
    ...      serving_cell_index_range_scg=8:16
    Set Indexes And Feature Set Entry Index Of Initial AllowedBC-ListMRDC Configured During SgNB Addition
    ...      ue_id=17
    ...      allowed_bc_list=3:1|1:1|2:1
    ...      serving_cell_index_range_scg=8:20

Set Index and Feature Set Entry Index of Initial AllowedBC-ListMRDC for CA UEs
    Set Indexes And Feature Set Entry Index Of Initial AllowedBC-ListMRDC Configured During SgNB Addition
    ...      allowed_bc_list=1:1|4:1|6:1
    ...      ue_id=18
    ...      serving_cell_index_range_scg=8:20
    Set Indexes And Feature Set Entry Index Of Initial AllowedBC-ListMRDC Configured During SgNB Addition
    ...      allowed_bc_list=3:1|4:1|6:1
    ...      ue_id=19
    ...      serving_cell_index_range_scg=7:14
    Set Indexes And Feature Set Entry Index Of Initial AllowedBC-ListMRDC Configured During SgNB Addition
    ...      allowed_bc_list=5:1
    ...      ue_id=20
    ...      serving_cell_index_range_scg=8:16
    Set Indexes And Feature Set Entry Index Of Initial AllowedBC-ListMRDC Configured During SgNB Addition
    ...      allowed_bc_list=5:1|1:1|3:1
    ...      ue_id=21
    ...      serving_cell_index_range_scg=8:16

Set Index and Feature Set Entry Index of AllowedBC-ListMRDC in Modification Request for all attached UEs
    Set BC and FSEI indexes in allowedBC-ListMRDC configured during SgNB Modification Request
    ...    ue_id=15
    ...    allowed_bc_list=1:1|50:1|80:1|90:1
    ...    serving_cell_index_range_scg=8:16
    Set BC and FSEI indexes in allowedBC-ListMRDC configured during SgNB Modification Request
    ...    ue_id=16
    ...    allowed_bc_list=5:1|3:1|2:1
    ...    serving_cell_index_range_scg=8:16
    Set BC and FSEI indexes in allowedBC-ListMRDC configured during SgNB Modification Request
    ...    ue_id=17
    ...    allowed_bc_list=2:1|3:1|1:1|5:1|6:1
    ...    serving_cell_index_range_scg=8:8
    Set BC and FSEI indexes in allowedBC-ListMRDC configured during SgNB Modification Request
    ...    ue_id=18
    ...    allowed_bc_list=1:1|4:1|6:1
    ...    serving_cell_index_range_scg=disable
    Set BC and FSEI indexes in allowedBC-ListMRDC configured during SgNB Modification Request
    ...    ue_id=19
    ...    allowed_bc_list=disable
    ...    serving_cell_index_range_scg=disable
    Include NR and EUTRA-NR ue-CapabilityInfo Information Element in the SgNBModificationRequest message for UE
    ...    ue_id=19     nr_ue_capability=$NR_CAP    eutra_nr_ue_capability=$EUTRA_CAP
    Set BC and FSEI indexes in allowedBC-ListMRDC configured during SgNB Modification Request
    ...    ue_id=20
    ...    allowed_bc_list=4:1
    ...    serving_cell_index_range_scg=8:16
    Set BC and FSEI indexes in allowedBC-ListMRDC configured during SgNB Modification Request
    ...    ue_id=21
    ...    allowed_bc_list=5:1
    ...    serving_cell_index_range_scg=8:16


Trigger ${n_iteractions} multiple consecutive SgNBModificationRequest for UE-${ue_id}
    @{BC_LIST}=    generate_specific_number_of_bc_indexes_and_fsei   max_num_iteractions=${n_iteractions}
    ...          even_bc=3:1     odd_bc=2:1
    FOR    ${bc}    IN    @{BC_LIST}
        Set BC and FSEI indexes in allowedBC-ListMRDC configured during SgNB Modification Request
        ...    ue_id=20
        ...    allowed_bc_list=${bc}
        ...    serving_cell_index_range_scg=8:20
        Trigger SgNB Modification Request Message From MeNB     ue_id=${ue_id}
        sleep   1s      reason=Small timeout for the consecutive messages
    END


Get SgNBModificationRequest messages for all ${num_of_ues} attached UEs
    FOR    ${ue_id}    IN RANGE     1    ${num_of_ues}
        Get Items Matching Regexp From PCAP
        ...         pcap_filepath=${WIRESHARK_TCPDUMP}
        ...         pattern=^nr-rrc$|^x2ap$
        ...         filter=x2ap.SgNBModificationRequest_element && x2ap.UE_X2AP_ID == ${ue_id}
        ...         save_to_file=/home/ute/exp/tcpdump_pcap_SgnbModReq_UE-${ue_id}.json
    END

Get SgNBModificationRequestAcknowledge messages for all ${num_of_ues} attached UEs
    FOR    ${ue_id}    IN RANGE     1    ${num_of_ues}+1
        Get Items Matching Regexp From PCAP
        ...         pcap_filepath=${WIRESHARK_TCPDUMP}
        ...         pattern=^nr-rrc$|^x2ap$
        ...         filter=x2ap.SgNBModificationRequestAcknowledge_element && x2ap.UE_X2AP_ID == ${ue_id}
        ...         save_to_file=${TEST_log_dir}/Wireshark/tcpdump_pcap_SgnbModreqAck_UE-${ue_id}.json
    END


Get SgNBModificationRequestReject for UE-${ue_id}
    Get Items Matching Regexp From PCAP
    ...         pcap_filepath=${WIRESHARK_TCPDUMP}
    ...         pattern=^nr-rrc$|^x2ap$
    ...         filter=x2ap.SgNBModificationRequestReject_element && x2ap.UE_X2AP_ID == ${ue_id}
    ...         save_to_file=${TEST_log_dir}/Wireshark/tcpdump_pcap_SgnbModReqRej_UE-${ue_id}.json


Verify that Carrier Aggregation was configured for all capable UEs
    [Arguments]      ${num_of_ues}
    FOR    ${ue_id}     IN RANGE     1     ${num_of_ues}+1
        IF    ${ue_id} not in [3,4,5]
            verify_if_ScellToAddModList_is_present_or_not
            ...     json_file=${TEST_log_dir}/Wireshark/tcpdump_pcap_SgnbModreqAck_UE-${ue_id}.json
            ...     should_be_present=yes
            ...     rrc_reconfig=yes
        END
    END



