*** Settings ***
Force Tags      CLOUD_5G_O_H_AP_LOO    OPTION_RELATED_ARTIFACTS_5G   SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_FDD   5G_RAN_FDD   CRT

Documentation    :copyright: Nokia
...              :author: Noble
...              :contact: noble.iyeswariyam_edison@nokia.com
...         The aim of the CB009842 feature is to enhance UL NR E-CID positioning method
...         to provide the Timing advanced (Tadv) measurments to help improving UE positioning accuracy.
...         Tadv can be provided to LMF in addition to the SS-RSRP/RSRQ measurements introduced by CB008281 feature.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library     taf.sbts.oam.coam.admin
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     sleep    300s
...                 AND     Verify NR of Downlink Symbols      ${wts_cfg_file}
...                 AND     ADMIN Setup Admin       alias=admin

#Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run keywords    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${wts_cfg_file}     ${CURDIR}/config/basic_setup_10784.cfg
${BTS_ADDRESS}    192.168.255.1
${BTS_PORT}       443
${USE_SSL}        True
${SCF_Path}    SCF_DU_Setup.xml
${SCFC}=        ${CURDIR}/config/SCF/CB010784_prach_148_addExtDelay_1_4DL2UL.xml
${AP_XML}=      ${CURDIR}/config/SCF/AQQL_iphy.xml
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2

*** Test Cases ***
[1][1.0] CB009842_19_Successful_ECID_Measurement_Reporting_for_UEs_in_RingCelldeployment_without_any_3rdpartyDAS_with_addExtDelayCompensation_1

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    btslog    cprt    biptaf
    Verify Guard Period Lengh    expected_value=2Symbols
    wtsrunner.ue_ta_nr  profile_id=1    ue_p_delay_initial=100
    wtsrunner.ue_testmode_set_nr    id=1    testmode=ta    action=activate    profile_id=1
    UE Register should be Successful     ue_id=${UE_ID}
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=${TRF_ID}
    Trigger UL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=100       trf_id=${TRF_ID2}
    Sleep    30s
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=100     qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=100     qfi_id=${QFI_ID}
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=1    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    ${attach}    Stop Log    btslog    cprt    biptaf    test_scenario=attach
    log to console   checking for TA value...
    CheckTAValue    ${attach}[cprt]/NODECPRT_GNB.pcap      116
    Trigger RLF failure and Verify TAdv
    Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}

*** Keywords ***

Trigger RLF failure and Verify TAdv
    Start Log    cprt      biptaf
    wtsrunner.ue_ta_nr  profile_id=1    ue_p_delay_initial=80
    wtsrunner.ue_rrc_reestablish     id=1    gnb=2    cell=1    cause=reconfigurationFailure
    sleep   15s
    wtsrunner.lmf_send_ecid_meas_req    id=1    ue=1    nrppa_transaction_id=1    lmf_ue_measurement_id=1
    ...     report_characteristics=OnDemand     meas_qty=NR_Timing_Advance
    ${delay}    Stop Log    cprt   biptaf      test_scenario=delay
    log to console   checking for TA value...
    CheckTAValue    ${delay}[cprt]/NODECPRT_GNB.pcap      96

CheckTAValue
    [Arguments]    ${file_path}    ${value}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=nrppa.NR_TADV
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=nrppa.MeasuredResultsValue   attrib_name=show     attrib_value=5
    @{attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.NR_TADV  attrib_name=showname
    should be equal    ${attrib_values}[0]    NR-TADV: ${value}

Verify NR of Downlink Symbols
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                      file=${wts_cfg_file}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=cell 1: SystemInformationBlockType1\-NR updated   timeout=120
    should contain    ${output}    nrofDownlinkSymbols   10
    sleep    120s

Verify Guard Period Lengh
    [Arguments]    ${expected_value}
    ${out}    Check guardPeriodLength Value For Cell      cell_id=1
    Should Contain   ${out}    ${expected_value}

ADMIN Setup Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Setup Admin
    ...    alias=${alias}

ADMIN Teardown Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Teardown Admin
    ...    connection=${alias}

ADMIN Get Managed Objects With Parameters
    [Documentation]    Get managed objects with parameters
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.get_managed_objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    [Return]    ${out_list_of_objects_parameters_dict}

ADMIN Get Object Distname And Id List
    [Documentation]    Get object dist name (im path) and separetly list of object's ids
    ...    usage example: for class_name=NRCELL_A keyword returns full distname without id (output example below):
    ...    out_object_distName: /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-15/SCF-1/MRBTS_A-50370/NRBTS_A-50370/NRCELL_A
    ...    and list of object's ids (output example below):
    ...    out_object_id_list: [u'2', u'1']
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${alias}=${ADMIN_ALIAS}
    ${object_parameters}    ADMIN Get Managed Objects With Parameters
    ...    class_name=${class_name}
    ...    alias=${alias}
    ${out_object_id_list}    Create List
    FOR    ${element}    IN    @{object_parameters}
        ${distName}    Get From Dictionary    ${element}    distName
        ${out_object_distName}    ${id}    Split String From Right    ${distName}    -    1
        Append To List    ${out_object_id_list}    ${id}
    END
    [Return]    ${out_object_distName}    ${out_object_id_list}

ADMIN Get Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=10
    ...            ${connection}=${ADMIN_ALIAS}
    ${out_parameters}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]    ${out_parameters}

Check guardPeriodLength Value For Cell
    [Arguments]    ${cell_id}
    ${nrcell_a_distname}    ${id_list}    ADMIN Get Object Distname And Id List
    ...    alias=admin
    ...    class_name=NRCELL_A
    ${parameter}    ADMIN Get Parameter
    ...    dist_name=${nrcell_a_distname}-${cell_id}
    ...    parameter=guardPeriodLength
    ...    connection=admin
    [Return]    ${parameter['tddFrameStructure']['guardPeriodLength']}
