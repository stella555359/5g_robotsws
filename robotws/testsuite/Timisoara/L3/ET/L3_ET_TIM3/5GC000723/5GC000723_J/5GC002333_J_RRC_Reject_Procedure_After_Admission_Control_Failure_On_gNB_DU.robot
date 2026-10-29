*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    CONFIGURED    CRT
...           PY36    RAN_5G_TDD    RAN_5G
...           NoResUsage


Documentation      :authors: M. Nadolska, Ilona Kondel
...                :email: marta.nadolska@nokia.com, ilona.kondel@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_tshark
Library      ta5g_delta
Library      ta5g_enb

Suite Setup     Run Keywords     Start Default Logging And Reach Onair
    ...                          lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...                          output_dirpath=${OUTPUT_DIR}
    ...           AND            Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml

Suite Teardown    Run Keywords   Roll Delta Back
    ...                          initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                          delta_scf_filename=delta_maxNumOfRrcSA_to_1.json
    ...           AND            Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${RRC_REJECTION_FOR_UE2}=                 nr-rrc.c1 == 0 && f1ap.protocolIEs == 5 && f1ap.SRBID == 0
${F1AP_UE_2_CONTEXT_RELEASE_COMPLETE}=      f1ap.F1AP_PDU == 1 && ${F1AP_UE_CONTEXT_RELEASE_COMPLETE}

*** Test Cases ***
5GC00723-J_RRC_Reject_Procedure_After_Admission_Control_Failure_On_gNB_DU
    [Documentation]    This test case covers rejection of ue attach and cleaning its Context when there are two users
    ...                trying to attach but parameter MaxNumOfRrcSa is set to 1 and there are no resources fot the
    ...                second UE. Covered
    ...                5GC000723_D_7_Check_RRC_Rejection_On_DU
    ...                Requirement ID: 5G_RAN_USR_6472

    Find Scfc and Send Delta Commissioning    scfc_filename=delta_maxNumOfRrcSA_to_1.json
    Attach UE                         ue_id=1
    Attach Ue Without Confirmation    ue_id=2
    Verify Tcpdump Log    packet_filter=${RRC_REJECTION_FOR_UE2}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_2_CONTEXT_RELEASE_COMPLETE}


