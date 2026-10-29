*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE, CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1     CONFIGURED

Resource         ./8955_new_resources.robot
Resource          ./resources/common/common_setup_teardown.robot
Library          ./resources/python/read_csv.py
Library    taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords     Suite setup from scratch
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
#...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_hightolow_gbr_8955_updated.json
...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_high2low_8955.json
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation    :copyright: Nokia
...              :author: Navin
...              :contact: navin_kumar.ray@nokia.com@nokia.com
...         The aim of the CB008955 feature is to to increase overall throughput performance in the cluster of cells.
...         By limiting the interference level experienced by high performing UEs.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         This test case scenario is check the GBR call with 4 UE when DL interference avoidence feature is enable.

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_tdd_gbr_multi_ue_8955.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${Pdu_session_ID_1}       2
${QFI_ID_1}      5
${TRF_ID_1}     2
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${3}
${st_ue_id_1}    ${3}
${en_ue_id_1}    ${3}

*** Test Cases ***
[1]UE-allocation_with_rbg_limit_and_DL_threshold_chnages

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Make MultiUE 5qi1 call with varying cqi and collect ttitrace
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Make MultiUE 5qi1 call with varying cqi and collect ttitrace
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    Sleep   2s
    Set fixed cqi for multiple UEs    ${st_ue_id_1}    ${en_ue_id_1}    15

    MultiUE PDU Addition should be Successful        ${st_ue_id_1}    ${en_ue_id_1}    nw_id=1    pdu_id=2
    MultiUE PDU Modfication should be Successful     ${st_ue_id_1}    ${en_ue_id_1}    pdu_id=2   qosflows_to_add=5
    Sleep   2s
    MultiUE Trigger DL Traffic for SA    1  1   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    1  1   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    2  2   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    2  2   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA_8955    3  3   Traffic_rate=mbps     dl_rate=130       pdu_id=2    trf_id=2      qfi_id=1
    MultiUE Trigger UL Traffic for SA_8955    3  3   Traffic_rate=mbps     ul_rate=25        pdu_id=2     trf_id=2     qfi_id=1
    sleep    30s
    Start Ttitrace With Streaming Mode
    sleep      5s
    Stop Ttitrace
    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
    sleep    300s
    8955_new_resources.Collect PM Counters
    Run Keyword And Ignore Error    Get 8955 counters and validate  M55308C10008  M55308C00019
    Convert Ttitrace From Pcap To Excelcsv    ${LOG_PATH}/ttitrace
    Convert Tti To Csv Mode         ${LOG_PATH}/ttitrace
    sleep   10s
    Wait until the current Measurement Period stops  additional_time=${0}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_type}=gnb
    ${tl_name_only}      Get Hostname
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}

