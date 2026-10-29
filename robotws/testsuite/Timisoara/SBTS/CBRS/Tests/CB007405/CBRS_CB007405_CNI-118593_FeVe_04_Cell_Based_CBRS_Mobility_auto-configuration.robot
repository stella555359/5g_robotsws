*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Katarzyna Olszewska
...    Justyna Durak
...    Jakub Klein
...    Piotr Lukaszewicz
...    Aleksandra Chudzik
...    = Review location =
...    http://reviews.emea.nsn-net.net/r/57275/


*** Keywords ***
CBRS_CB007405_CNI-118593_FeVe_04_Cell_Based_CBRS_Mobility_auto-configuration
    [Documentation]     Requirement: OM_GEN_SFS_CBRS.340; OM_GEN_SFS_CBRS.341; OAM_REQ_CBRS_85; OAM_REQ_CBRS_87
    ...                 Purpose: Verify whether neighbor eNB does CBRS band EARFCN auto adaption
    ...                 in TDD/FDD cells with LNBTS::actCbrsMobEnh feature flag activated.
    ...                 eNB shall execute Cell Based CBRS Mobility auto-configuration scenario triggered by multiple cells reconfiguration.
    ...                 This scenario covers simultaneous reconfiguration of two CBRS Cells.
    ...                 This automated testcase is designed only for double eNB setup (CBRS_3)
    ...                 From CNI-118593: actCbrsMobEnh parmeter is inactive on eNB_1 - parameter is no longer dependent on actCbrs parameter.

#Variables setup
    ${enb1_id}  Set Variable  ${testlines.${testline_id}.enb_id}
    ${enb2_id}  Set Variable  ${testlines.${testline_id}.node2.enb_id}
    ${cplane_addr_enb2}  Set Variable  ${testlines.${testline_id}.node2.cplane_ip_addr}
    &{expected_alarm}  Create Dictionary  fault_id=6823  fault_name=SAS Grant Termination Revocation Failure  severity=Critical
    ${expected_alarm_object}  Create Watchdog Alarm List  ${expected_alarm}

#Make sure there is no active legacy SAS connection
    Kill All SAS Processes
    Check If Cells Are Disabled  ${enb1_id}

#Activate CBRS feature on eNB1 and eNB2
    Enable CBRS Feature On eNB  alias=RAT_1ST
    Enable CBRS Feature On eNB  alias=RAT_2ND  target_enb=${testlines.${testline_id}.node2.enb_id}

#Start a new SAS instance
    ${sas_pid}  ${sas_logs_dir}  Start SAS Process
    ...  config=/home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/CBRS/CNI_NIDD/Tests/CB007405/Data/Feve04/SAS_Sim.conf
    Wait For All Cells To Be OnAir  alias=RAT_1ST
    Wait For All Cells To Be OnAir  alias=RAT_2ND
    Start Watchdog Alarm Detection  expected_alarms=${expected_alarm_object}

#Create LNADJ between eNB1 and eNB2 so they can exchange information
    Replace Variables In File  ${CURDIR}/Data/Feve04/Feve04_LNADJ_update.json
    ...  ${OUTPUT_DIR}/Feve04_LNADJ_update.json
    ...  ENB_ID=${enb1_id}
    ...  NEIGHBOUR_ID=${enb2_id}
    ...  C_PLANE=${cplane_addr_enb2}
    Wait Until Keyword Succeeds  20x  3s  Check If BTS Is Not Busy
    Run Keyword And Ignore Error  Perform Delta Recommissioning
    ...  ${OUTPUT_DIR}/Feve04_LNADJ_update.json
    ...  connection=RAT_1ST
    Wait Until Keyword Succeeds  3x  30s  ute_admin_infomodel.Query Infomodel
    ...  alias=RAT_2ND  query=check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNADJ_A-* is [adjEnbId=${enb1_id}]

    Enable CRBS Mobility enhancement Feature On eNB  alias=RAT_2ND  enb_id=${enb2_id}

#CNI-118593 changes: actCbrsMobEnh and actCbrs parameters separation
    Disable CRBS Mobility enhancement Feature On eNB

#Pick random cells on eNB1 and get their EARFCN as termination candidates
    ${cbsd_1st}  Get Random Cbsd Object  alias=RAT_1ST
    ${enb1_cbsd_assigned_id}  Set Variable  ${cbsd_1st["assignedCbsdId"]}
    ${first_termination_candidate_cell_id}  Get Random Cell From Cbsd Object  cbsd_object=${cbsd_1st}  alias=RAT_1ST
    FOR  ${i}  IN RANGE  999    #do-while loop to make sure we pick two different cells
        ${second_termination_candidate_cell_id}  Get Random Cell From Cbsd Object  cbsd_object=${cbsd_1st}  alias=RAT_1ST
        Exit For Loop If  '${second_termination_candidate_cell_id}'!='${first_termination_candidate_cell_id}'
    END
    ${first_termination_candidate_earfcn}  Get Earfcn Value By Cell Id  cell_id=${first_termination_candidate_cell_id}  alias=RAT_1ST
    ${second_termination_candidate_earfcn}  Get Earfcn Value By Cell Id  cell_id=${second_termination_candidate_cell_id}  alias=RAT_1ST
    ${first_termination_candidate_grant_id}  Get Grant Value By Cell Id  cell_id=${first_termination_candidate_cell_id}  alias=RAT_1ST
    ${second_termination_candidate_grant_id}  Get Grant Value By Cell Id  cell_id=${second_termination_candidate_cell_id}  alias=RAT_1ST

#On eNB2 create mobility objects that point at eNB1 termination candidates
    Replace Variables In File  ${CURDIR}/Data/Feve04/Feve04_mobility_objects.json
    ...  ${OUTPUT_DIR}/Feve04_mobility_objects.json
    ...  ENB_ID=${enb2_id}
    ...  ADJ_ENB_ID=${enb1_id}
    ...  ADJ_LNCEL_ID_1=${first_termination_candidate_cell_id}
    ...  ADJ_LNCEL_ID_2=${second_termination_candidate_cell_id}

    Wait Until BTS Is Not Busy  alias=RAT_2ND
    Perform Delta Recommissioning  delta_file=${OUTPUT_DIR}/Feve04_mobility_objects.json
    ...  connection=RAT_2ND

#Terminate candidates on eNB1 and wait for the reconfiguration
    ${timestamp_before_termination}  Get Time
    ${timestamp_before_termination}  Subtract Time From Date  ${timestamp_before_termination}  00:00:05  exclude_millis=True
    Terminate Two Grants And Confirm Cells Drop  cbsd_id_1=${enb1_cbsd_assigned_id}  grant_id_1= ${first_termination_candidate_grant_id}
    ...  cbsd_id_2=${enb1_cbsd_assigned_id}  grant_id_2=${second_termination_candidate_grant_id}
    Wait For All Cells To Be OnAir  alias=RAT_1ST
    ${timestamp_after_termination}  Get Time
    Check If Grant Terminate Message Appeared In Sas Log  sas_log_name=${sas_logs_dir}
    ...  start_timestamp=${timestamp_before_termination}  stop_timestamp=${timestamp_after_termination}
    ...  grant_id=${first_termination_candidate_grant_id}
    Check If Grant Terminate Message Appeared In Sas Log  sas_log_name=${sas_logs_dir}
    ...  start_timestamp=${timestamp_before_termination}  stop_timestamp=${timestamp_after_termination}
    ...  grant_id=${second_termination_candidate_grant_id}
    Wait For All Cells To Be OnAir  alias=RAT_1ST

#Get updated EARFCN of terminated cells
    ${first_cell_updated_earfcn}  Get Earfcn Value By Cell Id  ${first_termination_candidate_cell_id}  alias=RAT_1ST
    ${second_cell_updated_earfcn}  Get Earfcn Value By Cell Id  ${second_termination_candidate_cell_id}  alias=RAT_1ST

#On eNB2 check if Mobility objects (AMPLER, IRFIM, LNHOIF, REDRT) have updated the EARFCN
    Verify Update of Cell Based Mobility Objects  alias=RAT_2ND
    ...  first_cell_updated_earfcn=${first_cell_updated_earfcn}
    ...  second_cell_updated_earfcn=${second_cell_updated_earfcn}

    [Teardown]  Run Keywords  Get SAS Logs To Logs Dir  alias=default  AND
    ...  Stop Watchdog Alarm Detection And Check For Failures  AND
    ...  Remove Mobility Objects From eNB  enb_id=${enb2_id}  AND
    ...  Enable CRBS Mobility enhancement Feature On eNB  AND
    ...  Disable CBRS Feature On eNB  alias=RAT_1ST  AND
    ...  Disable CBRS Feature On eNB  alias=RAT_2ND  target_enb=${testlines.${testline_id}.node2.enb_id}    AND
    ...  Kill All SAS Processes


Remove Mobility Objects From eNB
    [Documentation]   Removes mobility objects (LNREL, AMPLER, IRFIM, LNHOIF, REDRT) created for test purpose
    [Arguments]  ${enb_id}

    Replace Variables In File  ${CURDIR}/Data/Feve04/Feve04_mobility_objects_removal.json
    ...  ${OUTPUT_DIR}/Feve04_mobility_objects_removal.json  ENB_ID=${enb_id}
    Wait Until Keyword Succeeds  6x  30s  Run Keywords
    ...  Wait Until BTS Is Not Busy  AND
    ...  Run Keyword And Ignore Error  Perform Delta Recommissioning
    ...  ${OUTPUT_DIR}/Feve04_mobility_objects_removal.json  connection=RAT_2ND


Verify Update of Cell Based Mobility Objects
    [Documentation]  Checks whether AMPLER, IRFIM, LNHOIF, REDRT objects have updated their EARFCN values according to the reconfiguration
    [Arguments]  ${alias}  ${first_cell_updated_earfcn}  ${second_cell_updated_earfcn}

    ${query_LNBTS}  Set Variable  /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*
    #Verification of TDD cell (Cell-1)
    Query Infomodel  alias=${alias}  timeout=700
    ...  query=check ${query_LNBTS}/LNCEL_A-1/AMLEPR_A-0 is [targetCarrierFreq=${first_cell_updated_earfcn}]
    Query Infomodel  alias=${alias}  timeout=30
    ...  query=check ${query_LNBTS}/LNCEL_A-1/IRFIM_A-5 is [dlCarFrqEut=${first_cell_updated_earfcn}]
    Query Infomodel  alias=${alias}  timeout=30
    ...  query=check ${query_LNBTS}/LNCEL_A-1/LNHOIF_A-5 is [eutraCarrierInfo=${first_cell_updated_earfcn}]
    Query Infomodel  alias=${alias}  timeout=30
    ...  query=check ${query_LNBTS}/LNCEL_A-1/REDRT_A-5 is [redirFreqEutra=${first_cell_updated_earfcn}]

    #Verification of FDD cell (Cell-5)
    Query Infomodel  alias=${alias}  timeout=700
    ...  query=check ${query_LNBTS}/LNCEL_A-5/AMLEPR_A-0 is [targetCarrierFreq=${second_cell_updated_earfcn}]
    Query Infomodel  alias=${alias}  timeout=30
    ...  query=check ${query_LNBTS}/LNCEL_A-5/IRFIM_A-5 is [dlCarFrqEut=${second_cell_updated_earfcn}]
    Query Infomodel  alias=${alias}  timeout=30
    ...  query=check ${query_LNBTS}/LNCEL_A-5/LNHOIF_A-5 is [eutraCarrierInfo=${second_cell_updated_earfcn}]
    Query Infomodel  alias=${alias}  timeout=30
    ...  query=check ${query_LNBTS}/LNCEL_A-5/REDRT_A-5 is [redirFreqEutra=${second_cell_updated_earfcn}]
