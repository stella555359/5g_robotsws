*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Resource         CB008227_Resource.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Prepare TL with all config files
...                 AND     Get and Update BSR SW via gitlab   ${BSR_SW_FILE}
...                 AND     Start Log   btslog
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   2s

Suite Teardown      Run keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Log   btslog    snapshot    sosreport

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This user scenario describes behaviour of NBR IWK with MU MIMO.
...
...
...
...
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_xxxxx



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/TC57_basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${sa_ue_id3}      ${3}
${nwslice_ID}   1

${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID1}     2
${5QI_QFI_ID}  4


${TEST_NAME}     TC42
${CELL_ID}    1

${SCFC}=                        ${CURDIR}/config/TC57_SCFC_UL_MuMIMO_GMC.xml
${AP_XML}=                      ${CURDIR}/config/TC57_IPHY.xml

@{FIELDS_PAIREDUE}    pairedUe   sfn  slot
${BSR_SW_FILE}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip

*** Test Cases ***
[1]CB008227-E#B7_TC57_NBR_interworking_with_MU_MIMO_UL
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    sleep    160s
    Wait until the next Measurement Period starts
    log to console   "SA UE attach with NBR Bearers are trigerring now"
#Step 1. Attach SA UE's with 1 default Bearer and 3 NBR Beareres
    Start Log    cprt
    ${rnti_list}   MultiUE Register should be Successful    ${sa_ue_id1}     ${sa_ue_id3}
    sleep     2s
    Log to console   ${rnti_list}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${5QI_QFI_ID}
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    MultiUE Trigger UL Traffic for SA   ${sa_ue_id1}    ${sa_ue_id1}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=2
    MultiUE Trigger UL Traffic for SA   ${sa_ue_id2}    ${sa_ue_id3}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    sleep   2s
    Set And Activate Srs beam position   ${sa_ue_id1}    ${sa_ue_id3}
    sleep   10s
    Validate UL Traffic For all UEs   42   42   42
#   Validate UL MuMIMO Pairing either in TTI or BIP traces
    Start Log   biptaf
    Sleep   10s
    ${bip_path1}   Stop Log    biptaf    test_scenario=UL_MuMIMO
    Verify UE Pairing     ${bip_path1}[biptaf]/BIP_L1L2.pcap   ${rnti_list}
#Check Counters
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55139C03509  300  SA_DU_DRB_NBR_DL
    ...  M55139C03510  300  SA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id3}
    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Validate UL Traffic For all UEs
    [Arguments]    ${ue1_tput}    ${ue2_tput}    ${ue3_tput}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=${ue1_tput}   pdu_id=1    qfi_id=${QFI_ID1}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id2}     ul_rate=${ue2_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id3}     ul_rate=${ue3_tput}   pdu_id=1    qfi_id=${QFI_ID}

Add new Bearer for Multiple SA UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${pdu_id}      ${qos_id}
     FOR   ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        UE PDU Modfication should be Successful   ${ue_id}      pdu_id=${pdu_id}      qosflows_to_add=${qos_id}
        sleep   5s
     END

Set And Activate Srs beam position
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=2   mode=fixed   init_quad_pos=0   init_sub_quad_pos=3   step=5   trigger_puxch_update=0
    wtsrunner.ue_testmode_set_nr   id=${first_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=2   scell=0
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=3   mode=fixed   init_quad_pos=1   init_sub_quad_pos=3   step=5   trigger_puxch_update=0
    wtsrunner.ue_testmode_set_nr   id=${first_ue_id+1}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=3   scell=0
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=5   mode=fixed   init_quad_pos=0   init_sub_quad_pos=3   step=5   trigger_puxch_update=0
    wtsrunner.ue_testmode_set_nr   id=${last_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=5   scell=0
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=5   mode=fixed   init_quad_pos=1   init_sub_quad_pos=1   step=5   trigger_puxch_update=0
    wtsrunner.ue_testmode_set_nr   id=${last_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=5   scell=0
    wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=5   mode=fixed   init_quad_pos=2   init_sub_quad_pos=3   step=3   trigger_puxch_update=0
    wtsrunner.ue_testmode_set_nr   id=${last_ue_id}   testmode=ul_mimo_srs_beam_pos   action=activate   profile_id=5   scell=0

get matched packet in a list
    [Arguments]                     ${message}          ${pdmlFile}     ${FIELDS_name}
    [Documentation]                 returns a list of packets for matched packet
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             path=${FIELDS_name}
    ...                             startPacket=1
    ...                             endPacket=100
    [return]          @{listpacketMatch}

get matched packet in a list with path list
    [Arguments]                     ${message}          ${pdmlFile}     ${FIELDS_name}
    [Documentation]                 returns a list of packets for matched packet
    @{listpacketMatch}              analyzer.get_match_from_paths
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             pathList=${FIELDS_name}
    ...                             startPacket=1
    ...                             endPacket=100
    [return]          @{listpacketMatch}

Get Value as Dict In Packet Match
    [Documentation]                 Return value of a field retrieved in a packetMatch as Dict
    ...                             if not found, it return an empty string
    [Arguments]                     ${packetMatch}                      ${field}
    ...                             ${kind}=show
    @{paired_ue_list}=      Create List
    @{sfn_slot_list}=       Create List
    @{listPath}                     Get Dictionary Keys                 ${packetMatch.fields}
    FOR    ${path}         IN      @{listPath}
            ${fieldName}            Get Field Name From Path            ${path}
            Run keyword if  '${fieldName}'=='${field}[0]'     Append To List        ${paired_ue_list}  ${packetMatch.fields['${path}'].${kind}}
            Run keyword if  '${fieldName}'=='${field}[1]'     Append To List        ${sfn_slot_list}   ${packetMatch.fields['${path}'].${kind}}
            Run keyword if  '${fieldName}'=='${field}[2]'     Append To List        ${sfn_slot_list}   ${packetMatch.fields['${path}'].${kind}}
    END
    [Return]        ${paired_ue_list}   ${sfn_slot_list}

Verify UE Pairing
    [Arguments]      ${pcapFile}   ${rnti_list}
    @{prev_sfnslot}=    Create List   0   0
    ${loop}=    Set Variable    1
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}         uldata_puschreceivereq
    @{list_of_values}    get matched packet in a list with path list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_PAIREDUE}
    FOR      ${ue_packet}     IN      @{list_of_values}
        ${pairedue_value}    ${cur_sfnslot}           Get Value as Dict In Packet Match
        ...                   packetMatch=${ue_packet}
        ...                   field=${FIELDS_PAIREDUE}
        Log to console    ${pairedue_value}
        Log to console    ${cur_sfnslot}
        Continue For Loop If   '${pairedue_value}[0]'=='0' and '${loop}'=='1'
        Continue For Loop If   '${pairedue_value}[0]'=='0' and '${prev_sfnslot}[0]'=='${cur_sfnslot}[0]' and '${prev_sfnslot}[1]'=='${cur_sfnslot}[1]'
        ${loop}=     Evaluate    ${loop}+1
        Check PairedUe    ${rnti_list}   ${pairedue_value}
        ${prev_sfnslot}=    copy list     ${cur_sfnslot}
    END

Check PairedUe
    [Arguments]     ${rnti_list}    ${pairedue_value}
    ${paired_ue_count}=  Set Variable   ${0}
    FOR  ${element}  IN   @{pairedue_value}
         ${paired_ue_count}=   Check PairedUE List with Rnti List  ${rnti_list}   ${element}   ${paired_ue_count}
    END
    Run Keyword and Continue on Failure    Should Be Equal As Integers     ${paired_ue_count}  ${2}

Check PairedUE List with Rnti List
    [Arguments]     ${rnti_list}  ${pairedue}   ${paired_ue_count}
    FOR   ${rnti_element}   IN   @{rnti_list}
           ${paired_ue_count}=   Set Variable if   ${pairedue}==${rnti_element}   ${paired_ue_count+1}     ${paired_ue_count}
    END
    [Return]   ${paired_ue_count}

