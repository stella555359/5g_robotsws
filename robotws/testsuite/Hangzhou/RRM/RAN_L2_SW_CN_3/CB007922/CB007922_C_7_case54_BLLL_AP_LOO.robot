*** Settings ***
Documentation    ajwang 20241219 update F
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_zhang
...    AP    CLOUD_5G_I_BLLL_AP_LOO
Resource    ../resources/KISS/robot/common_resource.robot
Resource    ../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${UE_ID}         1
${UE1_ID}        1
${UE2_ID}        2
${PDU_ID}        1
${SCFC_NAME}      SCFC_7922_case54_2AEQE_BLLL_LOO.xml
${AIRPHONE_NAME}    IPHY_2AEQE_case54_LOO.xml
${WTS_NAME}       WTS_case54_2AEQE.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
${ENB_CELL_PARAM1}    enb_cell_param enb\=1 id\=1 allow_endc\=on
${ENDC_CMD}    ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
${FILTER}      dldata_ssblocksendreqloner||dldata_pdschsendreqloner||dldata_csirssendreqloner
@{COLUMN_NAME}   DlData_PdschSendReqLoner.PdschSendReq.sfn    DlData_PdschSendReqLoner.PdschSendReq.slot
...   DlData_SsBlockSendReqLoner.SsBlockSendReq.sfn    DlData_SsBlockSendReqLoner.SsBlockSendReq.slot
...   DlData_CsiRsSendReqLoner.CsiRsSendReq.sfn    DlData_CsiRsSendReqLoner.CsiRsSendReq.slot
@{titles}   3gpp.sfn    3gpp.slot
${STABLETIME}    10s
${bip_tag}    bip
&{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
...    NUMBER_OF_FILES=30

*** Test Cases ***
CB007922_case54_C_7_Multiple_UE_in_SA_different_SSB_configuration
    Prepare gnb onair
    Start capture gnb and ap syslog in 'after_onair' file
    Execute AP Command before attach
    MultiUE SA Register
    Send DL data to UE and check throughput
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti'
    Check ttitrace
    Detach UEs

#    online enable actPdschAtSsbSlots and actPdschRmCsirsForTracking
    MultiUE SA Register
    Send DL data to UE and check throughput again

    Start collect bip log
    Wait for '2s' to stop bip log with name'${bip_tag}'
    Rename_pcaps   ${bip_tag}
    Verify Multi UE PDSCH Schedule In SSB and TRS Slot

    Detach UEs
    Stop capture gnb and ap syslog in 'after_onair' file

*** Keywords ***
Execute AP Command before attach
    airphone_cleanup_egate_console_log

MultiUE SA Register
    FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+2
       Airphone SA Attach    ue_id=${num}
       Airphone Set Traffic Type    ${num}    1    internal
       Airphone Pdu Session Setup    ${num}    1    1    ${num}
       Wait time to stable
    END

Send DL data to UE and check throughput

    FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+2
        Airphone SA Start Data Traffic    ${num}    DL    165M    pdu_id=${PDU_ID}    duration=${3600}    trf_id=1
        Airphone SA Start Data Traffic    ${num}    DL    165M    pdu_id=${PDU_ID}    duration=${3600}    trf_id=2
        Airphone SA Start Data Traffic    ${num}    DL    165M    pdu_id=${PDU_ID}    duration=${3600}    trf_id=3
        Airphone SA Start Data Traffic    ${num}    DL    165M    pdu_id=${PDU_ID}    duration=${3600}    trf_id=4
    END
    Wait time to stable
    Check Throughput

Check Throughput
    FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+2
        Get UE '${num}' throughput
    END

Get UE '${num}' throughput
    ${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
    ${scell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    1    type=pdsch    tput_type=ave
    should be true    ${pcell_tp}>250000
    should be true    ${scell_tp}>230000

Send DL data to UE and check throughput again
    FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+2
        Airphone SA Start Data Traffic    ${num}    DL    165M    pdu_id=${PDU_ID}    duration=${3600}    trf_id=1
        Airphone SA Start Data Traffic    ${num}    DL    165M    pdu_id=${PDU_ID}    duration=${3600}    trf_id=2
        Airphone SA Start Data Traffic    ${num}    DL    165M    pdu_id=${PDU_ID}    duration=${3600}    trf_id=3
        Airphone SA Start Data Traffic    ${num}    DL    165M    pdu_id=${PDU_ID}    duration=${3600}    trf_id=4
    END
    Wait time to stable
    Check throughput again

Check throughput again
    FOR    ${num}    IN RANGE    ${UE_ID}    ${UE_ID}+2
        Get UE '${num}' throughput again
    END

Get UE '${num}' throughput again
    ${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
    ${scell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    1    type=pdsch    tput_type=ave
    should be true    ${pcell_tp}>270000
    should be true    ${scell_tp}>250000
    #should be true    ${pcell_tp}>${scell_tp}

Wait time to stable
    sleep    ${STABLETIME}

online enable actPdschAtSsbSlots and actPdschRmCsirsForTracking
    Log To Console    enable actPdschAtSsbSlots and actPdschRmCsirsForTracking...
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-1    parameter=actPdschAtSsbSlots
    ...    operation=update    value=true    skip_parameter_relation_errors=True    should_activate=True    connection=online
        TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-1    parameter=actPdschRmCsirsForTracking
    ...    operation=update    value=true    skip_parameter_relation_errors=True    should_activate=True    connection=online
    TAF_ADMIN.teardown admin    connection=online
    Wait '50s' for stabible


Check ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Rename_pcaps
    [Arguments]     ${bip_title}
	TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
	TAF_SSH.Execute    cd    connection=bsh
	TAF_SSH.Send Command    cd ${TEST_LOG_DIRECTORY()}/All/${bip_title};mv *0.pcap bip_out.pcap    connection=bsh

Verify Multi UE PDSCH Schedule In SSB and TRS Slot
    Convert BIP To CSV    ${test_log_directory()}/All/${bip_tag}/bip_out.pcap
    ...    ${test_log_directory()}/All/${bip_tag}/bip.csv    ${FILTER}    ${titles}

	Check Log With Au2anlysis    ini_path=${CURDIR}/ini/bip.ini     log_need_to_check=i
	...   save_log_directory=${test_log_directory()}/All/${bip_tag}

Detach UEs
    airphone_sa_detach    ue_id=1    timeout=30
    airphone_sa_detach    ue_id=2    timeout=30

Start collect bip log
    log to console    start collect bip log
    Get BIP Scripts Files    ${test_log_directory()}/bip_config
    ${status}    ${msg}    Run Keyword And Ignore Error    Variable Should Exist    ${GNBMIRRORINGCONFIGS}
    Run Keyword If    '${status}'=='PASS'    Modify File List Paramters
    ...    ${test_log_directory()}/bip_config/gnbMirroringConfig.sh    ${GNBMIRRORINGCONFIGS}
    Start GNB BIP Log    ${test_log_directory()}/bip_config    infinite    true
