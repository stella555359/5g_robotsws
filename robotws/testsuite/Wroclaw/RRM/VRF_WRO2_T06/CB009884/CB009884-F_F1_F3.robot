
*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO
...     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
Documentation   :copyright: Nokia
...             :authors: Miłosz Komarczewski


Resource       ../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       CB009884_keywords.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/logging.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Library        ta5g_file_system
Library        ta5g_pm_counters
Library        ute_fsmaccess
Library        testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Setup        Run Keywords
...                Set VM Ethernet Interfaces for Simulated Core Network
...    AND         Find Scfc and Send Delta Commissioning   scfc_filename=delta_CB009884_F.json
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Reach Onair    lua_cfg=${basic_setup}
...    AND         Activate And Check If X2 Link is active

Suite Teardown    Compress Test Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging And Collect Debug Files    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${basic_setup}=            ${CURDIR}/config/cfg_CB009884_F.cfg
@{local_moid_NRCELLS}=     MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-2     MRBTS-1/NRBTS-1/NRCELL-3    MRBTS-1/NRBTS-1/NRCELL-4

*** Test Cases ***
CB009884_F3_Counters_for_msg3_retransmission_unsuccessful
    Verify Pm Counters Values For MSG3 Retransmission Before Test Starts
    Prepare UE Testmode For MSG3 Configuration     PROFILE_ID=4    TESTMODE_ACTION=msg3_retx     NUMBER_OF_ACTIONS=5
    Register UEs with Testmode For MSG3 Configuration Activated    UE_ID=1     ALL_UES=21     ACTION_DESIRED=activate    PROFILE_ID=4
    Verify Pm Counters Values For MSG3 Unsuccessful Retransmission After Test
    [Teardown]    Run Keywords
    ...            Deregister UE    ue_id=1-20
    ...    AND     Find Errors
    ...    AND     Add Scout Scf Id To Test Data
    ...    AND     Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND     Collect Selected Debug Files
    ...            output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            omit_collectors=sos_report

CB009884_F1_Counters_for_msg3_dtx_detection
    Verify Pm Counters Values For MSG3 DTX Before Test Starts
    Prepare UE Testmode For MSG3 Configuration     PROFILE_ID=5    TESTMODE_ACTION=missed_ra_resp     NUMBER_OF_ACTIONS=200
    Register UEs with Testmode For MSG3 Configuration Activated    UE_ID=21     ALL_UES=31     ACTION_DESIRED=activate    PROFILE_ID=5
    Register UEs with No Testmode Activated    UE_ID=31     ALL_UES=41
    Verify Pm Counters Values For MSG3 DTX After Test
    [Teardown]    Run Keywords
    ...            Deregister UE    ue_id=21-40
    ...    AND     Find Errors
    ...    AND     Add Scout Scf Id To Test Data
    ...    AND     Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND     Collect Selected Debug Files
    ...            output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            omit_collectors=sos_report

*** Keywords ***
Verify Pm Counters Values For MSG3 Retransmission Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS}
        Verify Any Counters In File
            ...    M55306C03001    0      RA_COMP_CONT_A_PRMBL
            ...    M55306C10006    0      RA_CBRA_UL_GRANT_MSG3_RETX
            ...    M55306C10004    0      RA_CBRA_MSG3_RECV_DECODE_FAIL
            ...    M55306C10005    0      RA_CBRA_INI_MSG3_DTX
            ...    M55306C00001    0      RA_ATT_CONT_A_PRMBL_SSB_00

            ...    local_moid=${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For MSG3 Unsuccessful Retransmission After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS}
    Verify Any Counters In File
            ...    M55306C03001    10      RA_COMP_CONT_A_PRMBL
            ...    M55306C10006    20      RA_CBRA_UL_GRANT_MSG3_RETX
            ...    M55306C10004    5       RA_CBRA_MSG3_RECV_DECODE_FAIL
            ...    M55306C10005    0       RA_CBRA_INI_MSG3_DTX
            ...    M55306C00001    10      RA_ATT_CONT_A_PRMBL_SSB_00

        ...    local_moid=${local_moid}
        ...    file_path=${pm_counter_file}

    END

Verify Pm Counters Values For MSG3 DTX Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS}
        Verify Any Counters In File
            ...    M55306C03001    0      RA_COMP_CONT_A_PRMBL
            ...    M55306C10005    0      RA_CBRA_INI_MSG3_DTX
            ...    M55306C00001    0      RA_ATT_CONT_A_PRMBL_SSB_00
            ...    M55306C06001    0      RA_MSG3_RECEP

            ...    local_moid=${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values For MSG3 DTX After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
            ...    M55306C03001    55      RA_COMP_CONT_A_PRMBL
            ...    M55306C10005    50      RA_CBRA_INI_MSG3_DTX
            ...    M55306C00001    55      RA_ATT_CONT_A_PRMBL_SSB_00
            ...    M55306C06001    5       RA_MSG3_RECEP

        ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
            ...    M55306C03001    55      RA_COMP_CONT_A_PRMBL
            ...    M55306C10005    50      RA_CBRA_INI_MSG3_DTX
            ...    M55306C00001    55      RA_ATT_CONT_A_PRMBL_SSB_00
            ...    M55306C06001    5       RA_MSG3_RECEP

        ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-3
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
            ...    M55306C03001    0       RA_COMP_CONT_A_PRMBL
            ...    M55306C10005    0       RA_CBRA_INI_MSG3_DTX
            ...    M55306C00001    0       RA_ATT_CONT_A_PRMBL_SSB_00
            ...    M55306C06001    0       RA_MSG3_RECEP

        ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-2
        ...    file_path=${pm_counter_file}

    Verify Any Counters In File
            ...    M55306C03001    0       RA_COMP_CONT_A_PRMBL
            ...    M55306C10005    0       RA_CBRA_INI_MSG3_DTX
            ...    M55306C00001    0       RA_ATT_CONT_A_PRMBL_SSB_00
            ...    M55306C06001    0       RA_MSG3_RECEP

        ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-4
        ...    file_path=${pm_counter_file}


