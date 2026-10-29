*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...   PY27
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00     SBTS23R1    CONFIGURED

Resource         ../CB008379/CB008379_Resource.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Library          ta5g_commissioning
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/common_log_collection.robot
#Resource         ta5g_setups_and_teardowns

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
#...                 AND     Perform SCF Delta Commissioning with basic_setup_2CC_tdd_XnHO_CNI85844_1.json
...                 AND     sleep    10
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...      author:            prakhar.rastogi@nokia.com
...      maintainer:        prakhar.rastogi@nokia.com
...
...      INTRODUCTION:    Use case of the Test case is to verify CFRA procedure success incase the error
...                       occurs for Msg3 Transmission for Contention Free Random Access Procedure.
...      TEST SET NAME:  [1]CNI-85844-1_SA_TDD_MSG3_err_scenario_during_CFRA_procedure
...             TESTING SPLIT:    See CNI85844  testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CNI85844  jira
...             Requirement ID:

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CNI-85844-1_SA_TDD_MSG3_err_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/CNI-85844-1_SA_TDD_MSG3_err_iphy.xml
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_tdd_XnHO_CNI85844.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${1}
${ue_id}        1
${UE_ID}
${pdu_id}       1
${Pdu_session_ID}   1
${nwslice_ID}   1
${gw_ID}     1
${nw_id}        1
${gw_id}        1
${qfi_id}       1
${TRF_ID}       1
${trf_id}       1
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1      2       3                    4             #5QI 2
@{QOS_Prof1_speed_dl}      1      32      amr_wb_18_25         30
@{QOS_Prof1_speed_ul}      1      32      amr_wb_18_25         30
@{QOS_Prof1_unit}          mbps   kbps    rtp_codec            mbps

@{QOS_Prof5}               1
@{QOS_Prof5_speed_dl}      1
@{QOS_Prof5_speed_ul}      1
@{QOS_Prof5_unit}          mbps

*** Test Cases ***

[1]CNI-85844-1_SA_TDD_MSG3_err_scenario_during_CFRA_procedure

    set test variable      ${LOG_PATH}
    Increase Buffer Size for VM and IPHY
#    X2AP Link Should be UP
    Establish Xn Link To gNB3
#    Sleep   3
#    Establish Xn Link To gNB3
    ue location change
    Sleep   10
    log to console   UE attach trigerring now...

    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof5}              ${2}=${QOS_Prof5}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof5_speed_ul}     ${2}=${QOS_Prof5_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof5_speed_dl}     ${2}=${QOS_Prof5_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof5_unit}         ${2}=${QOS_Prof5_unit}
#Step 1. Attach NGBR UE, with PDU session 5QI-6 nonGBR qosflow which is default QOS

    UE Register should be Successful simulated gNB

    ${duration}      Set Variable    20
    ${trf_id}      Set Variable    ${1}
#Step 3. Running traffic on Non-GBR UE

    Trigger DL Traffic for SA       ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=1    pdu_id=1  trf_id=1    qfi_id=1
    Trigger UL Traffic for SA       ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=1    pdu_id=1  trf_id=1    qfi_id=1

    sleep   ${duration}s

    HO SA A3 UE measurements missed_ra_resp
    sleep   ${5}s
    Stop Data Traffic for SA     ue_id=${UE_ID}
    MultiUE PDU Release should be Successful   ${st_ue_id}    ${en_ue_id}

    [Teardown]    Run Keywords    MultiUE Deregister should be Successful     ${st_ue_id}    ${en_ue_id}
    ...           AND        Link SCOUT SCF to Configuration ID for Reporting


** Keywords **
HO SA A3 UE measurements missed_ra_resp
   [Arguments]    ${ue_id}=1
    Log to Console    collect bip logs
    sleep    60s
    wtsrunner.ue_history_information_list_add_ngran     id=${ue_id}     gnb_id=3    cell_type=medium    nrcgi=311:489|0x03  time_ue_stayed_in_cell=100
    wtsrunner.ue_history_information_list   id=${ue_id} action=commit
    wtsrunner.ue_enb_param     id=${ue_id} ue_history_list=1
    wtsrunner.cont_res_testmode_nr     profile_id=1 missed_ra_resp=1
    wtsrunner.ue_testmode_set_nr    id=${ue_id}     testmode=contention_resolution    action=activate    profile_id=1
    wtsrunner.cont_res_testmode_nr     profile_id=1
    wtsrunner.upf_param   id=${ue_id} end_markers_delay=10s
    wtsrunner.ue_measurement_send_nr       id=${ue_id}  meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

