*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: MiŁosz Komarczewski

Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       CB009884_keywords.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/logging.robot
Resource       ../../WRO_2/CB008933/feature_keywords.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Resource       ../../resources/airphone/5G_SW_WRO_Keywords.robot

Library        ta5g_file_system
Library        ta5g_commissioning
Library        ta5g_enb
Library        ta5g_iphy
Library        ute_fsmaccess
Library        ta5g_pm_counters
Library        testsuite/Wroclaw/RRM/resources/scout_report.py


Suite Setup        Run Keywords
...                Update And Put Iphy Xml    input_filepath=${IPHY}
...    AND         Set VM Ethernet Interfaces for Simulated Core Network

Suite Teardown    Compress Test Logs

*** Variables ***
${IPHY}=                     ${CURDIR}/config/CB009884_C1_iphy.xml
${SCFC_1}=                   scfc_C_C1.xml
${SCFC_2}=                   scfc_H.xml
${DELTA_VONR_DEACT}=         delta_disable_vonr.json
${DELTA_VONR_ACT}=           delta_enable_vonr_limit_GBR.json
${basic_setup_1}=            ${CURDIR}/config/inactive_60UEs.cfg
${basic_setup_2}=            ${CURDIR}/config/CB009884_fallback.cfg
${PLMN_1}=                   MCC-311/MNC-489
${PLMN_2}=                   MCC-311/MNC-402
${PLMN_3}=                   MCC-311/MNC-403
@{moid_NRCELLS_PLMN}=        1/MCC-311/MNC-489    1/MCC-311/MNC-402    2/MCC-311/MNC-402    2/MCC-311/MNC-403
...    3/MCC-311/MNC-489    3/MCC-311/MNC-403    4/MCC-311/MNC-489    6/MCC-311/MNC-402
@{moid_NRCELLS_PLMN_step2}=    1/MCC-311/MNC-489    1/MCC-311/MNC-402     2/MCC-311/MNC-402    2/MCC-311/MNC-403
...    3/MCC-311/MNC-489    4/MCC-311/MNC-489     6/MCC-311/MNC-402
@{local_moid_NRCELLS_all}=              1    2    3    4    5    6
@{local_moid_NRCELLS_unused}=           2    4    5    6
@{local_moid_NRCELLS_used}=             1    3

*** Test Cases ***
CB009884_C1_Counters_for_average_maximum_number_of_UEs_in_RRC_Inactive_state_inactivity_based
    [Setup]        Run Keywords    Enable C-Plane Debug Logs      with_reboot=${false}
    ...    AND         Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC_1}
    ...    AND         Reset Wts
    ...    AND         Check Radios Availability
    ...    AND         Start Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Reach Onair    lua_cfg=${basic_setup_1}
    ...    AND         Activate And Check If X2 Link is active
    Verify Pm Counters Values Before Test Starts
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=1     ALL_UES=6     AMF_ID=1    TAC_ID=200    SELECTED_PLMN=311:489
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=6     ALL_UES=11    AMF_ID=1    TAC_ID=202    SELECTED_PLMN=311:489
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=11    ALL_UES=21    AMF_ID=1    TAC_ID=203    SELECTED_PLMN=311:489
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=21    ALL_UES=26    AMF_ID=1    TAC_ID=200    SELECTED_PLMN=311:402
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=26    ALL_UES=31    AMF_ID=1    TAC_ID=201    SELECTED_PLMN=311:402
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=31    ALL_UES=41    AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:402
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=41    ALL_UES=46    AMF_ID=1    TAC_ID=201    SELECTED_PLMN=311:403
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=46    ALL_UES=61    AMF_ID=1    TAC_ID=202    SELECTED_PLMN=311:403
    Stop Data Traffic For Multiple UEs     UE_ID=1     ALL_UES=16
    Stop Data Traffic For Multiple UEs     UE_ID=21    ALL_UES=36
    Stop Data Traffic For Multiple UEs     UE_ID=41    ALL_UES=56
    Verify Pm Counters Values After Step 2
    Verify Pm Counters Values After Step 3
    [Teardown]     Run Keywords
    ...                Add Scout Scf Id To Test Data
    ...    AND         Find Errors
    ...    AND         Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Collect Selected Debug Files
    ...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                omit_collectors=sos_report

CB009884_H1_Unsuccessful_setup_of_Emergency_voice_call_with_fallback_to_LTE_RRC_release_with_redirect_after_detected_and_aborted_RLF
    [Setup]        Run Keywords    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC_2}
    ...    AND         Reset Wts
    ...    AND         Check Radios Availability
    ...    AND         Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Reach Onair    lua_cfg=${basic_setup_2}
    ...    AND         Activate And Check If X2 Link is active
    Verify Pm Counters For Voice Fallback Values Before Test Starts
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=1      ALL_UES=4   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=311:489
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=21     ALL_UES=24  AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:402
    Modify PDU Session For Multiple UEs    UE_ID=1    ALL_UES=4    QOS_TO_ADD=2
    Modify PDU Session For Multiple UEs    UE_ID=21   ALL_UES=24   QOS_TO_ADD=2
    Prepare UE Testmode For RLF Triggering Configuration     PROFILE_ID=7
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=4      ALL_UES=8   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=311:489
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=24     ALL_UES=28  AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:402
    Trigger PDU Session Setup with 5QI-1 while RLF detected     UE_ID=4       ALL_UES=8      PDU_ID=2     SLICE_ID=1
    Trigger PDU Session Setup with 5QI-1 while RLF detected     UE_ID=24      ALL_UES=28     PDU_ID=2     SLICE_ID=1
    Disable Additional QoSFlow Addition during PDU Session Setup
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=8      ALL_UES=11   AMF_ID=1    TAC_ID=200    SELECTED_PLMN=311:489
    Register Inactive UEs To gNB To Selected PLMN And Setup PDU Session    UE_ID=28     ALL_UES=31   AMF_ID=1    TAC_ID=788    SELECTED_PLMN=311:402
    Deactivate VoNR in Cell#1 and Cell#3
    Modify PDU Session For Multiple UEs    UE_ID=8     ALL_UES=11    QOS_TO_ADD=2
    Modify PDU Session For Multiple UEs    UE_ID=28    ALL_UES=31    QOS_TO_ADD=2
    Activate VoNR in Cell#1 and Cell#3 and Limit GBR Bearers
    Enable Additional QoSFlow Addition during PDU Session Setup    QOS_ID=2
    Register UEs To Selected PLMN And Setup PDU Session Without Confirmation    UE_ID=14      ALL_UES=17    SELECTED_PLMN=311:489     PDU_ID=1
    ...    SLICE_ID=1     GW_ID=1
    Register UEs To Selected PLMN And Setup PDU Session Without Confirmation    UE_ID=34      ALL_UES=37    SELECTED_PLMN=311:402    PDU_ID=1
    ...    SLICE_ID=1     GW_ID=1
    Verify Pm Counters For Voice Fallback After Test
    [Teardown]     Run Keywords
    ...                Add Scout Scf Id To Test Data
    ...    AND         Find Errors
    ...    AND         Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Collect Selected Debug Files
    ...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                omit_collectors=sos_report

*** Keywords ***
Verify Pm Counters Values Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN}
        Verify Any Counters In File
            ...    M55145C04032    0      AVE_NUM_OF_RRC_INACT_NOM_PLMN
            ...    M55201C00001    0      PEAK_NUM_OF_RRC_INACT_UE_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

Verify Pm Counters Values After Step 2
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_step2}
        Verify Any Counters In File
            ...    M55201C00001    5      PEAK_NUM_OF_RRC_INACT_UE_PLMN
            ...    M55145C04033    300    AVG_NUM_UE_DENOM_PLMN
            ...    M55145C04032    >0     AVE_NUM_OF_RRC_INACT_NOM_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    Verify Any Counters In File
        ...    M55201C00001    10      PEAK_NUM_OF_RRC_INACT_UE_PLMN
        ...    M55145C04033    300     AVG_NUM_UE_DENOM_PLMN
        ...    M55145C04032    >0     AVE_NUM_OF_RRC_INACT_NOM_PLMN

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3/MCC-311/MNC-403
        ...    file_path=${pm_counter_file}

Verify Pm Counters Values After Step 3
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{moid_NRCELLS_PLMN_step2}
        Verify Any Counters In File
            ...    M55201C00001    5      PEAK_NUM_OF_RRC_INACT_UE_PLMN
            ...    M55145C04033    300    AVG_NUM_UE_DENOM_PLMN
            ...    M55145C04032    1500   AVE_NUM_OF_RRC_INACT_NOM_PLMN

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    Verify Any Counters In File
        ...    M55201C00001    10      PEAK_NUM_OF_RRC_INACT_UE_PLMN
        ...    M55145C04033    300     AVG_NUM_UE_DENOM_PLMN
        ...    M55145C04032    3000   AVE_NUM_OF_RRC_INACT_NOM_PLMN

        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3/MCC-311/MNC-403
        ...    file_path=${pm_counter_file}

Verify Pm Counters For Voice Fallback Values Before Test Starts
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_all}
        Verify Any Counters In File
            ...    M55125C13067    0      NG_FLOW_STP_FAIL_FB_UE_CAP
            ...    M55125C13068    0      NG_FLOW_STP_FB_5QI1_UE_CAP
            ...    M55125C13069    0      NG_FLOW_STP_RAC_FAIL_FB
            ...    M55125C13070    0      NG_FLOW_STP_RAC_FAIL_FB_5QI1
            ...    M55125C13073    0      NG_FLOW_STP_FAIL_FB_VNR_DSBL
            ...    M55125C13074    0      NG_FLOW_STP_FB_5QI1_VNR_DSBL
            ...    M55125C13075    0      NG_FLOW_STP_FB_CONCURRENCY
            ...    M55125C13076    0      NG_FLOW_STP_FB_5QI1_CONCURRNCY
            ...    M55125C09008    0      NG_FLOW_SETUP_FAIL_FALLBACK
            ...    M55125C09519    0      NG_FLOW_STP_FAIL_FALBACK_5QI1

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END


    FOR    ${CELL_ID}    IN    @{local_moid_NRCELLS_all}
        ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
        ${result}=    verify counters list increased

            ...    M55163C03010        1-6       ==0            NG_FLOW_STP_FB_PMQP_UE_CAP
            ...    M55163C03011        1-6       ==0            NG_FLOW_STP_RAC_FAIL_FB_PMQP
            ...    M55163C03013        1-6       ==0            NG_FLOW_STP_FB_PMQP_VNR_DSBL
            ...    M55163C03014        1-6       ==0            NG_FLOW_STP_FB_PMQP_CONCURRNCY
            ...    M55163C00501        1-6       ==0            NG_FLOW_STP_FAIL_FALBACK_PMQAP

            ...    pm_counter_file=${pm_counter_file}
            ...    cell_id=${CELL_ID}

        Run Keyword If   not ${result}
            ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>
    END

Verify Pm Counters For Voice Fallback After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_unused}
        Verify Any Counters In File
            ...    M55125C13067    0      NG_FLOW_STP_FAIL_FB_UE_CAP
            ...    M55125C13068    0      NG_FLOW_STP_FB_5QI1_UE_CAP
            ...    M55125C13069    0      NG_FLOW_STP_RAC_FAIL_FB
            ...    M55125C13070    0      NG_FLOW_STP_RAC_FAIL_FB_5QI1
            ...    M55125C13073    0      NG_FLOW_STP_FAIL_FB_VNR_DSBL
            ...    M55125C13074    0      NG_FLOW_STP_FB_5QI1_VNR_DSBL
            ...    M55125C13075    0      NG_FLOW_STP_FB_CONCURRENCY
            ...    M55125C13076    0      NG_FLOW_STP_FB_5QI1_CONCURRNCY
            ...    M55125C09008    0      NG_FLOW_SETUP_FAIL_FALLBACK
            ...    M55125C09519    0      NG_FLOW_STP_FAIL_FALBACK_5QI1

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END

    FOR    ${CELL_ID}    IN    @{local_moid_NRCELLS_unused}
        ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
        ${result}=    verify counters list increased

            ...    M55163C03010        1-6       ==0            NG_FLOW_STP_FB_PMQP_UE_CAP
            ...    M55163C03011        1-6       ==0            NG_FLOW_STP_RAC_FAIL_FB_PMQP
            ...    M55163C03013        1-6       ==0            NG_FLOW_STP_FB_PMQP_VNR_DSBL
            ...    M55163C03014        1-6       ==0            NG_FLOW_STP_FB_PMQP_CONCURRNCY
            ...    M55163C00501        1-6       ==0            NG_FLOW_STP_FAIL_FALBACK_PMQAP

            ...    pm_counter_file=${pm_counter_file}
            ...    cell_id=${CELL_ID}

        Run Keyword If   not ${result}
            ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>
    END

    FOR    ${local_moid}    IN    @{local_moid_NRCELLS_used}
        Verify Any Counters In File
            ...    M55125C13067    3       NG_FLOW_STP_FAIL_FB_UE_CAP
            ...    M55125C13068    3       NG_FLOW_STP_FB_5QI1_UE_CAP
            ...    M55125C13069    6       NG_FLOW_STP_RAC_FAIL_FB
            ...    M55125C13070    3       NG_FLOW_STP_RAC_FAIL_FB_5QI1
            ...    M55125C13073    3       NG_FLOW_STP_FAIL_FB_VNR_DSBL
            ...    M55125C13074    3       NG_FLOW_STP_FB_5QI1_VNR_DSBL
            ...    M55125C13075    8       NG_FLOW_STP_FB_CONCURRENCY
            ...    M55125C13076    4       NG_FLOW_STP_FB_5QI1_CONCURRNCY
            ...    M55125C09008    20      NG_FLOW_SETUP_FAIL_FALLBACK
            ...    M55125C09519    13      NG_FLOW_STP_FAIL_FALBACK_5QI1

            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${local_moid}
            ...    file_path=${pm_counter_file}
    END


    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    ${result}=    verify counters list increased

        ...    M55163C03010        1,3         ==3            NG_FLOW_STP_FB_PMQP_UE_CAP
        ...    M55163C03010        2,4-6       ==0            NG_FLOW_STP_FB_PMQP_UE_CAP
        ...    M55163C03011        1,3         ==6            NG_FLOW_STP_RAC_FAIL_FB_PMQP
        ...    M55163C03011        2,4-6       ==0            NG_FLOW_STP_RAC_FAIL_FB_PMQP
        ...    M55163C03013        1,3         ==3            NG_FLOW_STP_FB_PMQP_VNR_DSBL
        ...    M55163C03013        2,4-6       ==0            NG_FLOW_STP_FB_PMQP_VNR_DSBL
        ...    M55163C03014        1,3         ==8            NG_FLOW_STP_FB_PMQP_CONCURRNCY
        ...    M55163C03014        2,4-6       ==0            NG_FLOW_STP_FB_PMQP_CONCURRNCY
        ...    M55163C00501        1,3         ==20           NG_FLOW_STP_FAIL_FALBACK_PMQAP
        ...    M55163C00501        2,4-6       ==0            NG_FLOW_STP_FAIL_FALBACK_PMQAP

        ...    pm_counter_file=${pm_counter_file}
        ...    cell_id=1

    Run Keyword If   not ${result}
       ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>

    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    ${result}=    verify counters list increased

        ...    M55163C03010        2,3         ==3            NG_FLOW_STP_FB_PMQP_UE_CAP
        ...    M55163C03010        1,4-6       ==0            NG_FLOW_STP_FB_PMQP_UE_CAP
        ...    M55163C03011        2,3         ==6            NG_FLOW_STP_RAC_FAIL_FB_PMQP
        ...    M55163C03011        1,4-6       ==0            NG_FLOW_STP_RAC_FAIL_FB_PMQP
        ...    M55163C03013        2,3         ==3            NG_FLOW_STP_FB_PMQP_VNR_DSBL
        ...    M55163C03013        1,4-6       ==0            NG_FLOW_STP_FB_PMQP_VNR_DSBL
        ...    M55163C03014        2,3         ==8            NG_FLOW_STP_FB_PMQP_CONCURRNCY
        ...    M55163C03014        1,4-6       ==0            NG_FLOW_STP_FB_PMQP_CONCURRNCY
        ...    M55163C00501        2,3         ==20           NG_FLOW_STP_FAIL_FALBACK_PMQAP
        ...    M55163C00501        1,4-6       ==0            NG_FLOW_STP_FAIL_FALBACK_PMQAP

        ...    pm_counter_file=${pm_counter_file}
        ...    cell_id=3

    Run Keyword If   not ${result}
       ...    Fail    msg=*HTML*<p style="color:red; font-size:16px; font-weight: bold;">Counters verification failed. Please check table </p>

Deactivate VoNR in Cell#1 and Cell#3
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${DELTA_VONR_DEACT}

Activate VoNR in Cell#1 and Cell#3 and Limit GBR Bearers
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${DELTA_VONR_ACT}
