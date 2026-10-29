*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    CONFIGURED    CRT
...           PY36    RAN_5G_TDD    RAN_5G
...           NoResUsage


Documentation      :author: Ilona Kondel
...                :email: ilona.kondel@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_pm_counters
Library      ta5g_delta
Library      ta5g_enb

Suite Setup       Run Keywords    Start Default Logging And Reach Onair
    ...                               lua_cfg_filepath=${CURDIR}/egate_2c_tdd_2c_fdd_sansa.lua
    ...                               output_dirpath=${OUTPUT_DIR}
    ...          AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...          AND             Set Counter Collecting Interval To Five Minutes
    ...           AND             Wait For Next Full Pm Interval

Suite Teardown    Run Keywords   Roll Delta Back
    ...                          initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                          delta_scf_filename=delta_maxNumOfRrcSA_to_1.json
    ...           AND            Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
5GC002333_K_PM_Counters
    [Documentation]    This test case covers rejection of ue attach in case of different establishment causes for each ue
    ...                when parameter MaxNumOfRrcSa is set to 1 and check that each counter connected to specific
    ...                establishment cause has been incremented. Covered:
    ...                5GC000723_B_1_Check_U-Plane_Counters_RA
    ...                5GC000723_D_6_Check_SRB_1_Counters
    ...                5GC002333_K_1_Check_Incrementation_Of_Nrrc_Rrc_Stpsucc_Tot_Pm_Counter_Upon_Successful_Rrc
    ...                5GC000723_G_1_Sukcess_RRC_Idle_to_Connected_Transition
    ...                5GC000723_G_4_Test_4_Checking_receiving_of_NGAP_INITIAL_UE_MESSAGE
    ...                Requirement ID: 5G_RAN_USR_12769, 5G_RAN_USR_4523, 5G_RAN_USR_12798

    Find Scfc and Send Delta Commissioning    scfc_filename=delta_maxNumOfRrcSA_to_1.json
    Wait For Next Full Pm Interval
    Attach UE    ue_id=1
    Verify Ngap Messages    ${NGAP_INITIAL_UE_MESSAGE}
    Verify Tcpdump Log    ${F1AP_INITIAL_UL_RRC_MESSAGE_TRANSFER}
    Verify Tcpdump Log    ${RRC_SETUP}
    Verify Tcpdump Log    ${RRC_SETUP_COMPLETE}
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

    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55124C01024  +1  NRRCC_RRC_STPREJ_EMERGENCY
    ...    M55124C01025  +1  NRRCC_RRC_STPREJ_HIPRIO_ACCESS
    ...    M55124C01030  +1  NRRCC_RRC_STPREJ_MCS
    ...    M55124C01022  +2  NRRCC_RRC_STPREJ_MO_DATA
    ...    M55124C01021  +1  NRRCC_RRC_STPREJ_MO_SIGNALLING
    ...    M55124C01028  +1  NRRCC_RRC_STPREJ_MO_SMS
    ...    M55124C01027  +1  NRRCC_RRC_STPREJ_MO_VIDEOCALL
    ...    M55124C01026  +1  NRRCC_RRC_STPREJ_MO_VOICECALL
    ...    M55124C01029  +1  NRRCC_RRC_STPREJ_MPS
    ...    M55124C01023  +1  NRRCC_RRC_STPREJ_MT_ACCESS
    ...    M55309C05001  +72  UL_MAC_SDU_VOL_CCCH_SRB0
    ...    M55306C00001  +12  RA_ATT_CONT_A_PRMBL_SSB_00
    ...    M55306C03001  +12  RA_COMP_CONT_A_PRMBL
    ...    M55124C01031    1    NRRCC_RRC_STPSUCC_TOT
    ...    M55310C12001    >0    UL_RLC_PDU_RX_L_SRB1
    ...    M55309C10001    >0    UL_MAC_SDU_DCCH_SRB1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55317C04001    +4    UL_PDCP_SDU_RX_SRB1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55311C25001    +4    UL_RLC_SDU_RX_H_SRB1
    ...    M55311C29001    +0    UL_RLC_PDU_RETX_H_SRB1
    ...    M55311C31001    >1    UL_RLC_DELAY_H_SRB1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...    file_path=${pm_counter_file}


*** Keywords ***
Attach UE With Cause
    [Arguments]  ${ue_id}    ${cause}
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}
    Attach Ue Without Confirmation    ue_id=${ue_id}
    Sleep    5s
