*** Settings ***
Force Tags       CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G_TDD    RAN_5G
...              CRT    SBTS00    SBTS23R1    PY36
...              NoResUsage

Documentation    :copyright: Nokia
...              :author: Kamil Wos
...              :contact: kamil.wos@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000752_Y_Variables.robot

Suite Setup     Run Keywords    Start Default Logging And Reach Onair
    ...                         output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    ...                         lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...         AND             Find Scfc And Send Delta Commissioning    scfc_filename=${DELTA_DEFAULT}
    ...         AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown   Run Keywords   Find Scfc And Send Delta Commissioning    scfc_filename=${DELTA_DEFAULT}
    ...          AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
5GC000752-Y_1_Online_parameter_modification_handling_BTS_restart_not_needed_drbMacDefProf
    Attach UE And Establish PDU Session And Verify UE Ctx Setup Response    ue_id=1    pdu_id=1    gw_id=1    packet_filter=${DRBMACDEFPROF_BEFORE}
    Find Scfc And Send Delta Commissioning    scfc_filename=${DELTA_DRBMACDEFPROF}
    Attach UE And Establish PDU Session And Verify UE Ctx Setup Response    ue_id=2    pdu_id=1    gw_id=2    packet_filter=${DRBMACDEFPROF_AFTER}

5GC000752-Y_3_Online_parameter_modification_handling_BTS_restart_not_needed_drbRlcAmDefProf
    Attach UE And Establish PDU Session And Verify UE Ctx Setup Response    ue_id=3    pdu_id=1    gw_id=3    packet_filter=${DRBRLCAMDEFPROF_BEFORE}
    Find Scfc And Send Delta Commissioning    scfc_filename=${DELTA_DRBRLCAMDEFPROF}
    Attach UE And Establish PDU Session And Verify UE Ctx Setup Response    ue_id=4    pdu_id=1    gw_id=4    packet_filter=${DRBRLCAMDEFPROF_AFTER}

*** Keywords ***
Attach UE And Establish PDU Session And Verify UE Ctx Setup Response
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${packet_filter}
    Attach UE    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Verify Tcpdump Log    packet_filter=${packet_filter}


