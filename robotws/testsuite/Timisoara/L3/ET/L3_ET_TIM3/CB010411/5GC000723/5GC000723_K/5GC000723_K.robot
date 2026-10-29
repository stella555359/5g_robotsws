*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           CRT    RAN_5G_FDD    RAN_5G    GQC_PLAN:DESIGNER:sukl    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Radu Turcu
...              :contact: radu.turcu@nokia.com

Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      ../../../resourcesKRK/krk3_common/aic/aic_common_resources.robot
Library      ta5g_tshark
#Library      ta5g_setups_and_teardowns
#Variables    ta5g_global_var
Library      ta5g_ue_mobility
Library      ute_tshark
Variables    ta5g_global_var
Library      ta5g_pm_counters
Library       ute_reporting_portal

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes

*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
${basic_config723H}     ${CURDIR}/configs/basic_setup723H.cfg
${delta_maxNumOfRrcSA_to_1}       ${CURDIR}/configs/delta_maxNumOfRrcSA_to_1.json

${NGAP_INITIAL_UE_MESSAGE}=                     ngap.InitialUEMessage_element
${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER}=        f1ap.InitialULRRCMessageTransfer_element
${RRC_SETUP}=               nr-rrc.rrcSetup_element
${RRC_SETUP_COMPLETE}=      nr-rrc.rrcSetupComplete_element

@{PM_OBJECTS_LIST_VCU}           NRRCC    NPDCC
@{PM_OBJECTS_LIST_VDU}           NHRLC    NMSDU     NLRLC   NRACH

*** Test Cases ***
5GC002333_K_PM_Counters
    [Setup]    Test Case Setup    reach_on_air=without_x2_link    wts=${basic_config723H}   reboot_after_config=no
    Log to console     start test
    Upload delta vdu    ${delta_maxNumOfRrcSA_to_1}
    Upload delta vcu    ${delta_maxNumOfRrcSA_to_1}
    Wait for Next vRAN PM Counters Interval
    sleep    10s
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    1s
    ta5g_ue_mobility.Attach Ue    ue_id=1
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_INITIAL_UE_MESSAGE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    1s
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    1s
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${RRC_SETUP}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    1s
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${RRC_SETUP_COMPLETE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    1s


    Attach UE With Cause    ue_id=2    cause=emergency
    Attach UE With Cause    ue_id=3    cause=highPriorityAccess
    Attach UE With Cause    ue_id=4    cause=mcs-PriorityAccess
    Attach UE With Cause    ue_id=5    cause=mo-Data
    Attach UE With Cause    ue_id=6    cause=spare1
    Attach UE With Cause    ue_id=7    cause=mo-Signalling
    Attach UE With Cause    ue_id=8    cause=mo-SMS
    Attach UE With Cause    ue_id=9    cause=mo-VideoCall
    Attach UE With Cause    ue_id=10    cause=mo-VoiceCall
    Attach UE With Cause    ue_id=11    cause=mps-PriorityAccess
    Attach UE With Cause    ue_id=12    cause=mt-Access

    ${dirpath}  Set Variable   ${OUTPUT DIR}/Logs/${TEST NAME}/
    Create Directory    ${dirpath}/vcu
    Create Directory    ${dirpath}/vdu
    &{pm_files_dict}    get_next_vran_unpacked_full_pm_counters_files    output_dirpath=${dirpath}     timeout=3600      expected_interval=5

    verify last counters in file
    ...    M55124C01024  1  NRRCC_RRC_STPREJ_EMERGENCY
    ...    M55124C01025  1  NRRCC_RRC_STPREJ_HIPRIO_ACCESS
    ...    M55124C01030  1  NRRCC_RRC_STPREJ_MCS
    ...    M55124C01022  >1  NRRCC_RRC_STPREJ_MO_DATA
    ...    M55124C01021  1  NRRCC_RRC_STPREJ_MO_SIGNALLING
    ...    M55124C01028  1  NRRCC_RRC_STPREJ_MO_SMS
    ...    M55124C01027  1  NRRCC_RRC_STPREJ_MO_VIDEOCALL
    ...    M55124C01026  1  NRRCC_RRC_STPREJ_MO_VOICECALL
    ...    M55124C01029  1  NRRCC_RRC_STPREJ_MPS
    ...    M55124C01023  1  NRRCC_RRC_STPREJ_MT_ACCESS
    ...    M55124C01031  1  NRRCC_RRC_STPSUCC_TOT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NRRCC

    verify last counters in file
    ...  M55317C04001     >3       UL_PDCP_SDU_RX_SRB1
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NPDCC

    verify last counters in file
    ...    M55309C05001  72  UL_MAC_SDU_VOL_CCCH_SRB0
    ...    M55309C10001    >0    UL_MAC_SDU_DCCH_SRB1
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vdu}
    ...  measurement_type=NMSDU

    verify last counters in file
    ...    M55306C00001  >9  RA_ATT_CONT_A_PRMBL_SSB_00
    ...    M55306C03001  >9  RA_COMP_CONT_A_PRMBL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vdu}
    ...  measurement_type=NRACH

    verify last counters in file
    ...    M55310C12001    >0    UL_RLC_PDU_RX_L_SRB1
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vdu}
    ...  measurement_type=NLRLC

    verify last counters in file
    ...    M55311C25001    >3    UL_RLC_SDU_RX_H_SRB1
    ...    M55311C29001     0    UL_RLC_PDU_RETX_H_SRB1
    ...    M55311C31001    >1    UL_RLC_DELAY_H_SRB1
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...  file_path=${pm_files_dict.vdu}
    ...  measurement_type=NHRLC

    stop tcpdump on remote interface

	Report pm counter    M55124C01024  1           Passed
	Report pm counter    M55124C01025  1           Passed
	Report pm counter    M55124C01030  1           Passed
	Report pm counter    M55124C01022  2           Passed
	Report pm counter    M55124C01021  1           Passed
	Report pm counter    M55124C01028  1           Passed
	Report pm counter    M55124C01027  1           Passed
	Report pm counter    M55124C01026  1           Passed
	Report pm counter    M55124C01029  1           Passed
	Report pm counter    M55124C01023  1           Passed
	Report pm counter    M55124C01031  1           Passed
	Report pm counter    M55317C04001  4           Passed
	Report pm counter    M55309C05001  72          Passed
	Report pm counter    M55309C10001  8           Passed
	Report pm counter    M55306C00001  12          Passed
	Report pm counter    M55306C03001  12          Passed
	Report pm counter    M55310C12001  4           Passed
	Report pm counter    M55311C25001  4           Passed
	Report pm counter    M55311C29001  0           Passed
	Report pm counter    M55311C31001  1379        Passed

	Execute Egate Command    cmd=ue_deregister id=all by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s

*** Keywords ***
Attach UE With Cause
    [Arguments]  ${ue_id}    ${cause}
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}
    ta5g_ue_mobility.Attach Ue Without Confirmation    ue_id=${ue_id}
    Sleep    5s
