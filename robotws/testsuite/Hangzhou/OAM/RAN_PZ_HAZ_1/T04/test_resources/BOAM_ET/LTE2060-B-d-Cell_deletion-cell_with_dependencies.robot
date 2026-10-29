*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx
Resource    ../../resources/BOAM_ET/pretest_posttest.robot
Resource    ../../resources/hran_frame_taf_oam.robot

*** Variables ***

@{FLAGS_LIST_01}    0x300001=1

${FORCED_PLAN_FILE_ACTIVATION}          /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*
${VALIDATE_PLAN_AGAINST_DETECTED_HW}    /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/MNL_A-*

${CELL_M}                               /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-
${LNCEL_L}                              /MRBTS-1/RAT-1/LTS-*/LNBTS_L-*/LNCEL_L-

&{cell_drops}    cell_id_1=no_drop
${expected_number_of_cells}    1
${delete_cell_id}    2

${LTE2060-B-d_delta_deleteCell24}    /home/ute/testline_configuration/10_5_UTESRAN1905/testdata/BOAM_ET/LTE2060-B-d_delta_deleteCell24.yaml

${LTE2060-B-d_base_CA4and24}   /home/ute/testline_configuration/10_5_UTESRAN1905/testdata/BOAM_ET/LTE2060-B-d_base_CA4and24.xml
${BACKUP_COMMISSIONING_PATH}    /home/ute/testline_configuration/10_5_UTESRAN1905/commissioning/SCF_01_SBTS18.xml

*** Keywords ***
[TC_04]TE2060-B-d-Cell_deletion-cell_with_dependencies
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...    Author: emilia.borczyk@nokia.com
    ...    Maintainer: dawid.sikorski@nokia.com
    ...    Test Description: Cell addition/deletion/parameter change & Faults handling and recovery (DSP/FSP)
    ...    FT in charge: FTTW22 - I_MANO_SOAM1_FTTW22_GMS <I_MANO_SOAM1_FTTW22@internal.nsn.com>
    ...    References: doors://esdooapv51.emea.nsn-net.net:36655/?version=2&prodID=0&view=00000001&urn=urn:telelogic:
    ...    3bc410a8-fe2a-11e5-9f3e-03f6157c9a7b:1-4017b9fe29051a61-M-0001ff47
    ...    QualityCenter: tds://fdd_lte.mn_lte.qc12-prod.int.net.nokia.com/qcbin/TestLabModule-000000003649890581?EntityType=ITestSet&EntityID=304583
    ...    Confluence link:
    ...    Review: http://biedronka.emea.nsn-net.net/r/25470/
    ...    AC/REQ: LTE_OPR_REQ_5605 LTE_OPR_REQ_5367 LTE_OPR_REQ_5594
    LTE2060-B-d-Cell_deletion-cell_with_dependencies

LTE2060-B-d-Cell_deletion-cell_with_dependencies
    ADMIN Perform Commissioning
    ...                        bts_id=${MRBTS_ID}
    ...                        scf_file=${LTE2060-B-d_base_CA4and24}
    ...                        skip_parameter_relation_errors=True
    ADMIN Assert All Cells Are In OnAirDone State    timeout=600
    ADMIN Assert All Cells Are In Expected Operational State    expected_state=enabled    class_name=GNCEL    timeout=600
    ADMIN Assert All Cells Are In Expected Operational State    expected_state=enabled    class_name=WNCEL    timeout=600
    ADMIN Perform Delta Recommissioning    delta_file=${LTE2060-B-d_delta_deleteCell24}    skip_parameter_relation_errors=${True}
    ADMIN Assert All Cells Are In OnAirDone State
    ADMIN Assert All Cells Are In Expected Operational State    expected_state=enabled    class_name=GNCEL
    ADMIN Assert All Cells Are In Expected Operational State    expected_state=enabled    class_name=WNCEL
    LTE2060 Check Cell Drops In Infomodel History    &{cell_drops}
    LTE2060 Check If Cell Was Deleted Successfully    cell_number=${delete_cell_id}
    LTE2060 Validate Number Of Cells    number_of_cells=${expected_number_of_cells}
    ADMIN INFOMODEL Validate Number Of Resets    number_of_expected_resets=1

LTE2060 Test Preconditions
    Log    \n+ LTE2060 Test Preconditions started    console=yes
    ADMIN Setup Admin
    Log Variables
    ADMIN INFOMODEL Start Logging
    Log    \n+ LTE2060 Test Preconditions finished    console=yes
    LTE2060 Add Flags To Swconfig    flags_list=${FLAGS_LIST_01}

LTE2060 Test Postconditions
    Log    \n+ LTE2060 Test Postconditions started    console=yes
    ADMIN Perform Commissioning
    ...                        bts_id=${MRBTS_ID}
    ...                        scf_file=${BACKUP_COMMISSIONING_PATH}
    ...                        skip_parameter_relation_errors=True
    ADMIN Assert All Cells Are In OnAirDone State    timeout=600
    ADMIN Assert All Cells Are In Expected Operational State    expected_state=enabled    class_name=NRCEL    timeout=600
    ADMIN Assert All Cells Are In Expected Operational State    expected_state=enabled    class_name=GNCEL    timeout=600
    ADMIN Assert All Cells Are In Expected Operational State    expected_state=enabled    class_name=WNCEL    timeout=600
    Run Keyword And Ignore Error    Run Keyword If Test Failed
    ...    ADMIN Collect Snapshot    snapshot_name=${OUTPUT DIR}/Snapshot.zip
    PREPOST Collect Scf File    file_name=SCF_Posttest.xml
    ...                         alias=suite
    Move Files    ${OUTPUT DIR}/*tshark*
    ...           ${OUTPUT DIR}/Snapshot.zip
    ...           ${OUTPUT DIR}/SCF_Pretest.xml
    ...           ${OUTPUT DIR}/SCF_Posttest.xml
    ...           ${OUTPUT DIR}/${TEST_NAME}/
    Copy Files    ${OUTPUT DIR}/admin_api_*
    ...           ${OUTPUT DIR}/${TEST_NAME}/
    ADMIN INFOMODEL Teardown Infomodel
    ADMIN Teardown Admin
    Run Keyword And Ignore Error    ADMIN Setup Admin    alias=default
    Run Keyword And Ignore Error    Run Keyword If Test Passed    Report To Rep With SCF Id
    Run Keyword And Ignore Error    ADMIN Teardown Admin    alias=default
    Log    \n+ LTE2060 Test Postconditions finished    console=yes

LTE2060 Check Onair Cell Drops In Infomodel History
    [Arguments]    ${cell_number}
    ...            ${filename}=infomodel_tmp.ims2
    ...            ${log_dir}=${OUTPUT_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    Log    ${alias}
    Initialize Ims2 Validator    ${log_dir}/${filename}
    Add Expected Ims2 Event Sequence    event1=${CELL_M}${cell_number} [stateInfo.proceduralState: *->OnAirDone]
    ...                                 event2=${CELL_M}${cell_number} [stateInfo.proceduralState: OnAirDone->*]
    ...                                 event3=${CELL_M}${cell_number} [stateInfo.proceduralState: *->OnAirDone]
    ...                                 event4=${CELL_M}${cell_number} [stateInfo.proceduralState: OnAirDone->!OnAirDone] times=0
    Validate Ims2

LTE2060 Check Onair Cell Availability In Infomodel History
    [Arguments]    ${cell_number}
    ...            ${log_dir}=${OUTPUT_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ...            ${filename}=infomodel_tmp.ims2
    Log    ${alias}
    Initialize Ims2 Validator    ${log_dir}/${filename}
    Add Expected Ims2 Event Sequence    event1=${CELL_M}${cell_number} [stateInfo.proceduralState: *->OnAirDone]
    ...                                 event2=${CELL_M}${cell_number} [stateInfo.proceduralState: OnAirDone->!OnAirDone] times=0
    Validate Ims2

LTE2060 Add Flags To Swconfig
    [Arguments]    ${flags_list}
    SYSTEM Open SSH Connection To Enb
    FOR    ${flag_value}    IN    @{flags_list}
        ${flag}=    Fetch From Left    string=${flag_value}
        ...    marker==
        ${value}=    Fetch From Right    string=${flag_value}
        ...     marker==
        SYSTEM Swconfig Add Flag    flag=${flag}
        ...     value=${value}
    END
    SYSTEM Close SSH Connection To Enb

LTE2060 Check Modified Cell Bandwidth
    [Arguments]    ${cell_number}
    ...            ${chBw_before_delta}
    ...            ${chBw_after_delta}
    ...            ${filename}=infomodel_tmp.ims2
    ...            ${log_dir}=${OUTPUT_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    Log    ${alias}
    Initialize Ims2 Validator    ${log_dir}/${filename}
    Add Expected Ims2 Event    change ${LNCEL_L}${cell_number} [dlChBw: ${chBw_before_delta}->${chBw_after_delta}] times=1
    Validate Ims2

LTE2060 Check Modified Cell Earfcn
    [Arguments]    ${cell_number}
    ...            ${cell_id}
    ...            ${filename}=infomodel_tmp.ims2
    ...            ${log_dir}=${OUTPUT_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    Log    ${alias}
    Initialize Ims2 Validator    ${log_dir}/${filename}
    Add Expected Ims2 Event    change ${CELL_M}${cell_number}/LNCEL_M-${cell_id} [earfcnDl: 1300->1700] times=1
    Validate Ims2

LTE2060 Check If Cell Was Deleted Successfully
    [Arguments]    ${cell_number}
    ...            ${log_dir}=${OUTPUT_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ...            ${filename}=infomodel_tmp.ims2
    Log    ${alias}
    Initialize Ims2 Validator    ${log_dir}/${filename}
    Add Expected Ims2 Event Sequence    event1=${CELL_M}${cell_number} [stateInfo.proceduralState: *->OnAirDone]
    ...                                 event2=${CELL_M}${cell_number}
    Validate Ims2

LTE2060 Validate Number Of Cells
    [Arguments]    ${number_of_cells}
    ${OUT_LNCELS_IDS_LIST}=    ADMIN Get Ids For All LNCEL
    Set Test Variable    ${OUT_LNCELS_IDS_LIST}
    ...                  ${out_lncels_ids_list}
    PREPOST Get Amount Of Lncels In Admin
    Should Be True    ${OUT_ADMIN_LNCELS_AMOUNT}==${number_of_cells}

LTE2060 Check Cell Drops In Infomodel History
    [Arguments]    &{cell_drops}
    FOR    ${cell_number}    IN    @{cell_drops.keys()}
        ${cell_number}=    Fetch From Right    string=${cell_number}
        ...    marker=_
        ADMIN INFOMODEL Query Infomodel    dist_name=${CELL_M}${cell_number}
        ...     parameter=stateInfo.proceduralState=OnAirDone
        ...    timeout=60
    END
    ADMIN INFOMODEL Save Log    log_dir=${OUTPUT_DIR}
    ...                         filename=infomodel_tmp.ims2
    FOR    ${cell_number}    IN    @{cell_drops.keys()}
        ${cell_state}=    Get From Dictionary    dictionary=${cell_drops}
        ...    key=${cell_number}
        ${cell_number}=    Fetch From Right    string=${cell_number}
        ...    marker=_
        Run Keyword If    '${cell_state}'=='no_drop'    LTE2060 Check Onair Cell Availability In Infomodel History    cell_number=${cell_number}
        ...    ELSE IF    '${cell_state}'=='drop'    LTE2060 Check Onair Cell Drops In Infomodel History    cell_number=${cell_number}
    END