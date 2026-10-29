*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED
...           RAN_5G_TDD    RAN_5G    CIT    SBTS00    SBTS23R1    SBTS22R4    PY310    RF50
...           NoResUsage

Documentation     :author:Anna Szymandera-Bialek
...               :email:anna.szymandera-bialek@nokia.com

Resource          ../CB009789_Keywords_And_Variables.robot

Suite Setup       Run Keywords    Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...           AND             Wait For Next Full Pm Interval

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs      teardown_egate_instances=False

*** Test Cases ***
CB009789_E_B3_Peak_NSA_Counters_Classical
    [Documentation]    This user scenario describes the verification of aggregated PM counter for the higher capacity CU for
    ...                NSA on Classical configuration.
    ...                During test execution there is attach of 5 Ues, than 2 Ues are detached. Counters should be 5. Next
    ...                there is attach of 4 Ues, than 1 Ue is detached. Counters should be 7.
    ...
    ...                Testcase checks if:
    ...                - Counter M55131C00001 PEAK_NUMBER_OF_NSA_USERS_CU is incremented properly.
    ...                Test case covers requirement: 5G_PM_878

    [Setup]    Run Keywords     Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND              Reach Onair    lua_cfg=${CURDIR}/../../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
    ...        AND              Set Counter Collecting Interval To Five Minutes
    ...        AND              Wait For Next Full Pm Interval

    Attach Ue To Enb    ue_id=101
    Start Gnb Addition Procedure       ue=101    target_gnb=2    target_cells=1    bearer=2   dc_type=split_scg
    ...                                pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Attach Ue To Enb    ue_id=102
    Start Gnb Addition Procedure       ue=102    target_gnb=2    target_cells=1    bearer=2   dc_type=split_scg
    ...                                pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Attach Ue To Enb    ue_id=103
    Start Gnb Addition Procedure       ue=103    target_gnb=2    target_cells=1    bearer=2   dc_type=split_scg
    ...                                pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Attach Ue To Enb    ue_id=104
    Start Gnb Addition Procedure       ue=104    target_gnb=2    target_cells=1    bearer=2   dc_type=split_scg
    ...                                pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Attach Ue To Enb    ue_id=105
    Start Gnb Addition Procedure       ue=105    target_gnb=2    target_cells=1    bearer=2   dc_type=split_scg
    ...                                pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Wait For Full Counter Sample
    Detach Ue    ue_id=101
    Detach Ue    ue_id=102

    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55131C00001    5    PEAK_NUMBER_OF_NSA_USERS_CU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

    Attach Ue To Enb    ue_id=107
    Start Gnb Addition Procedure       ue=107    target_gnb=2    target_cells=2    bearer=2   dc_type=split_scg
    ...                                pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    Attach Ue To Enb    ue_id=108
    Start Gnb Addition Procedure       ue=108    target_gnb=2    target_cells=2    bearer=2   dc_type=split_scg
    ...                                pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    Attach Ue To Enb    ue_id=109
    Start Gnb Addition Procedure       ue=109    target_gnb=2    target_cells=2    bearer=2   dc_type=split_scg
    ...                                pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    Attach Ue To Enb    ue_id=121
    Start Gnb Addition Procedure       ue=121    target_gnb=2    target_cells=2    bearer=2   dc_type=split_scg
    ...                                pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    Wait For Full Counter Sample
    Detach Ue    ue_id=107

    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55131C00001    7    PEAK_NUMBER_OF_NSA_USERS_CU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

    [Teardown]     Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...            AND             Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB009789_E_B3_Peak_SA_GBR_Counters_Classical
    [Documentation]    This User Scenario describes the verify of aggregated PM counters for capacity vCU for SA on Classical configuration.
    ...                Test case requires following flags to be added to default config:
    ...                actVonr set to True.
    ...                During test execution there is attach of 5 Ues, than 2 Ues are detached. Counters should be 5. Next
    ...                there is attach of 4 Ues, than 1 Ue is detached. Counters should be 7.
    ...                NGBR counters are collected during estabilishng PDU sessions while GBR during modification one.
    ...                5G_PM_878

    [Setup]       Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    ...           AND             Reach Onair     lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_VoNR.lua
    ...           AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_actvonr_activation.json
    ...           AND             Set Counter Collecting Interval To Five Minutes
    ...           AND             Wait For Next Full Pm Interval

    Attach UE     ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1
    Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2
    Attach UE     ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=1   gw_id=2    nwslice=1
    Execute Egate Command    cmd=ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=2
    Attach UE     ue_id=3
    Establish PDU Session    ue_id=3    pdu_id=1    gw_id=3    nwslice=1
    Execute Egate Command    cmd=ue_pdu_session_modify ue=3 pdu=1 qosflows_to_add=2
    Attach UE     ue_id=4
    Establish PDU Session    ue_id=4    pdu_id=1   gw_id=4    nwslice=1
    Execute Egate Command    cmd=ue_pdu_session_modify ue=4 pdu=1 qosflows_to_add=2
    Attach UE     ue_id=5
    Establish PDU Session    ue_id=5    pdu_id=1   gw_id=5    nwslice=1
    Execute Egate Command    cmd=ue_pdu_session_modify ue=5 pdu=1 qosflows_to_add=2
    Wait For Full Counter Sample
    Deregister UE Without Confirmation    ue_id=1
    Deregister UE Without Confirmation    ue_id=2

    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55140C00001  +5  PEAK_NUMBER_OF_SA_RRC_USERS_CU
    ...    M55140C00501  +5  PEAK_NBR_OF_SA_GBR_USERS_CU
    ...    M55140C00002  +5  PEAK_NBR_OF_SA_NGBR_USERS_CU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True

    Attach UE     ue_id=6
    Establish PDU Session    ue_id=6    pdu_id=1    gw_id=6    nwslice=1
    Execute Egate Command    cmd=ue_pdu_session_modify ue=6 pdu=1 qosflows_to_add=2
    Attach UE     ue_id=7
    Establish PDU Session    ue_id=7    pdu_id=1   gw_id=7    nwslice=1
    Execute Egate Command    cmd=ue_pdu_session_modify ue=7 pdu=1 qosflows_to_add=2
    Attach UE     ue_id=8
    Establish PDU Session    ue_id=8    pdu_id=1    gw_id=8    nwslice=1
    Execute Egate Command    cmd=ue_pdu_session_modify ue=8 pdu=1 qosflows_to_add=2
    Attach UE     ue_id=9
    Establish PDU Session    ue_id=9    pdu_id=1   gw_id=9    nwslice=1
    Execute Egate Command    cmd=ue_pdu_session_modify ue=9 pdu=1 qosflows_to_add=2
    Wait For Full Counter Sample
    Deregister UE Without Confirmation    ue_id=6

    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55140C00001  +7  PEAK_NUMBER_OF_SA_RRC_USERS_CU
    ...    M55140C00501  +7  PEAK_NBR_OF_SA_GBR_USERS_CU
    ...    M55140C00002  +7  PEAK_NBR_OF_SA_NGBR_USERS_CU
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Add Scout External Execution ID To Reporting Portal

    [Teardown]    Run Keywords    Roll Delta Back
    ...                           initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_actvonr_deactivation.json
    ...           AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

