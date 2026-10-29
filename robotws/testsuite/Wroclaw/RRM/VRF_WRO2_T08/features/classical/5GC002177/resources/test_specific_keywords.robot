*** Settings ***
Library        ./test_specific_keywords_2177.py
Library        testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library        taf.gnb.oam.coam.admin
Library        ute_ue
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaStore.py
Library        ta_attenuator
Resource       testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource       testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
Resource       testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot
Resource       taf/rfrl/common_resources/common_step/interface.robot

Documentation  Set of keywords for feature 5GC002177 execution

*** Variables ***
${ABSTRACT_LIB_CONFIG}     /home/ute/testline_configuration/7_16_UTE5GCLOUDT196/ue_conf.yaml
${UE_ALIAS}                UE_1
${IS_TL_CONCURRENT}        True
${GNB_CELL_1}              GNB_1_CELL_50
${GNB_CELL_2}              GNB_1_CELL_51
${GNB_CELL_3}              GNB_1_CELL_52

*** Keywords ***
[1]5GC002177_FA_1_5GC002177_FA_001_Feature_deactivated_actA2SgnbRelease
    [Documentation]  This test case checks if the gNB doesnt't report eventA2 in measConfig of
    ...              SgNBAdditionRequestAcknowledge object when actA2SgNBRelease=false and a2MeasReleaseEnabled=/=none
    @{setup}=     Create List                        ${ACTA2SGNBRELEASE_FALSE}
    @{teardown}=  Create List                        ${ACTA2SGNBRELEASE_TRUE}
    Change Parameters                                delta_setup  @{setup}
    Start Tcpdump On LTE                             filename=${test_name}_attach.pcap
    ute_ue.Attach UE                                        ${UE_ALIAS}
    Sleep                                            10s  reason=wait for attach
    Stop Tcpdump On LTE And Get Logs                 filename=${test_name}_attach.pcap
    Verify Lack Of Object In Addition Request Ack    ${LOG_PATH}/${test_name}_attach.pcap  object=eventA2
    [Teardown]  Run Keywords  ute_ue.Detach UE  ${UE_ALIAS}  AND  Change Parameters  delta_setup  @{teardown}


[1]5GC002177_FA_2_5GC002177_FA_002_Measurement_configuration_for_A2_configuration_disabled
    [Documentation]  This test case checks if the gNB doesnt't report measConfig at all in
    ...              SgNBAdditionRequestAcknowledge object when actA2SgNBRelease=false and a2MeasReleaseEnabled=none
    @{setup}=     Create List                          ${ACTA2SGNBRELEASE_FALSE}  ${A2MEASRELEASEENABLED_NONE}
    @{teardown}=  Create List                          ${ACTA2SGNBRELEASE_TRUE}   ${A2MEASRELEASEENABLED_RSRP}
    Change Parameters                                  delta_setup  @{setup}
    Start Tcpdump On LTE                               filename=${test_name}_attach.pcap
    ute_ue.Attach UE                                          ${UE_ALIAS}
    Sleep                                              10s  reason=wait for attach
    Stop Tcpdump On LTE And Get Logs                   filename=${test_name}_attach.pcap
    Verify Lack Of Object In Addition Request Ack      ${LOG_PATH}/${test_name}_attach.pcap  object=measConfig
    [Teardown]  Run Keywords  ute_ue.Detach UE  ${UE_ALIAS}  AND  Change Parameters  delta_setup  @{teardown}


[1]5GC002177_FA_3_5GC002177_FA_003_SgNB_release_based_on_A2_based_on_RSRP_without_SRB3
    [Documentation]  This test case checks proper handling of eventA2 based on rsrp measurements.
    ...              Also covers counter Test Cases FA_16 and FA_17
    @{counters}=       Create List                     M55112C05001  M55112C05002
    ${THRESHOLD}=      Create Dictionary               rsrp=65
    ${HYSTERESIS}=     Create Dictionary               rsrp=2
    ${TIMETOTRIGGER}=  Create Dictionary               rsrp=ms480
    Log To Console                                     Waiting for the counters to reset and new collection period start...
    Wait Until Keyword Succeeds  15x  60s              Check Counters  @{counters}  expected_value=0
    Start Tcpdump On LTE                               filename=${test_name}_attach.pcap
    BTSLOG Start Btslog On Local Machine
    ute_ue.Attach UE                                          ${UE_ALIAS}
    ute_ue.Start Data Transfer
    ...                                                dt_name=DT_UL
    ...                                                ue_alias=${UE_ALIAS}
    ...                                                direction=UL
    ...                                                duration=380s
    ...                                                throughput=200Mbits/sec
    ...                                                protocol=udp
    ...                                                packet_size=1200
    Execute Single Cell Fading Scenario                cell_alias=${GNB_CELL_1}
    ...                                                fading_step=10db
    ...                                                fading_interval=1s
    ...                                                fading_min=0dB
    ...                                                fading_max=90dB
    ute_ue.Stop Data Transfer                          DT_UL
    BTSLOG Collect Btslog
    Stop Tcpdump On LTE And Get Logs                   filename=${test_name}_attach.pcap
    Verify A2 Event Values                             pcap_file=${LOG_PATH}/${test_name}_attach.pcap
                       ...                             threshold=${THRESHOLD}
                       ...                             hysteresis=${HYSTERESIS}
                       ...                             time_to_trigger=${TIMETOTRIGGER}
    Find Rrc Transfer                                  ${LOG_PATH}/${test_name}_attach.pcap
    Find Sgnbrelease Cause In Pcap                     pcap_file=${LOG_PATH}/${test_name}_attach.pcap
    Log To Console                                     Verification passed! Checking Counters...
    Wait Until Keyword Succeeds  15x  60s              Check Counters  @{counters}


[1]5GC002177_FA_5_5GC002177_FA_005_SgNB_release_based_on_A2_NIDD_checking
    [Documentation]  This test case checks proper handling of eventA2 when both rsrp and rsrq measurements are enabled.
    ${THRESHOLD}=      Create Dictionary                  rsrq=67     rsrp=66
    ${HYSTERESIS}=     Create Dictionary                  rsrq=3      rsrp=2
    ${TIMETOTRIGGER}=  Create Dictionary                  rsrq=ms512  rsrp=ms480
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=66  a2TimeToTriggerReleaseSsbRsrp=ms480
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  a2MeasReleaseEnabled=rsrpAndRsrq
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=  taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown                       ${admin_alias}

    Start Tcpdump On LTE                                  filename=${test_name}_attach.pcap
    BTSLOG Start Btslog On Local Machine
    ute_ue.Attach UE                                             ${UE_ALIAS}
    ute_ue.Start Data Transfer
    ...                                                   dt_name=DT_UL
    ...                                                   ue_alias=${UE_ALIAS}
    ...                                                   direction=UL
    ...                                                   duration=380s
    ...                                                   throughput=200Mbits/sec
    ...                                                   protocol=udp
    ...                                                   packet_size=1200
    Execute Single Cell Fading Scenario                   cell_alias=${GNB_CELL_1}
    ...                                                   fading_step=2db
    ...                                                   fading_interval=1s
    ...                                                   fading_min=0dB
    ...                                                   fading_max=90dB
    ute_ue.Stop Data Transfer                                    DT_UL
    BTSLOG Collect Btslog
    Stop Tcpdump On LTE And Get Logs                      filename=${test_name}_attach.pcap

    Verify A2 Event Values                                pcap_file=${LOG_PATH}/${test_name}_attach.pcap
    ...                                                   threshold=${THRESHOLD}
    ...                                                   hysteresis=${HYSTERESIS}
    ...                                                   time_to_trigger=${TIMETOTRIGGER}
    Find Rrc Transfer                                     pcap_file=${LOG_PATH}/${test_name}_attach.pcap
    Find Sgnbrelease Cause In Pcap                        pcap_file=${LOG_PATH}/${test_name}_attach.pcap
    Find Ue Release Cause In Syslog                       ${LOG_PATH}/${test_name}_bts_log.tgz
    [Teardown]  Test 5 Teardown


[1]5GC002177_FA_8_5GC002177_FA_008_Intra_gNB_PSCell_change_A5_enable_and_configured_A2_RSRP_RSRQ
    [Documentation]  This test case checks proper handling of eventA5 handover based on rsrp measurements with eventA2
    ...              also being configured on the cell.
    Delete Delta If Already Present                       name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=rsrp
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=57  a2TimeToTriggerReleaseSsbRsrp=ms480
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-3  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=rsrp  a5MeasEnabled=rsrp
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-2  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=rsrp  a5MeasEnabled=rsrp
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}  actIntraFreqIntraGnbMobilityNSA=true
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=  taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown                       ${admin_alias}
    Start tcpdump On LTE                                  filename=${test_name}_attach.pcap
    BTSLOG Start Btslog On Local Machine
    ute_ue.Attach UE                                      ${UE_ALIAS}
    Set Attenuation                                       ${GNB_CELL_2}  4dB
    Execute Single Cell Fading Scenario                   cell_alias=${GNB_CELL_1}
    ...                                                   fading_step=2db
    ...                                                   fading_interval=1s
    ...                                                   fading_min=0dB
    ...                                                   fading_max=90dB
    Sleep                                                 10s  reason=handover handling
    ute_ue.Start Data Transfer
    ...                                                   dt_name=DT_UL
    ...                                                   ue_alias=${UE_ALIAS}
    ...                                                   direction=UL
    ...                                                   duration=380s
    ...                                                   throughput=200Mbits/sec
    ...                                                   protocol=udp
    ...                                                   packet_size=1200
    ute_ue.Stop Data Transfer                                    DT_UL
    BTSLOG Collect Btslog
    Stop Tcpdump On LTE And Get Logs                      filename=${test_name}_attach.pcap
    Find Rrc Transfer                                     pcap_file=${LOG_PATH}/${test_name}_attach.pcap
    Find Sgnbrelease Cause In Pcap                        pcap_file=${LOG_PATH}/${test_name}_attach.pcap  event_nr=eventA5
    Verify Successful Handover                            pcap_file=${LOG_PATH}/${test_name}_attach.pcap
    ...                                                   syslog_dir=${LOG_PATH}/${test_name}_bts_log.tgz
    ...                                                   phy_cell_id=51


Check Counters
    [Arguments]  @{counters}  ${expected_value}=1
    Collect Counters
    ${updated_counter_values}    Get Last Counter Values    @{counters}
    Cleanup All Downloaded Counter Files
    Check If Counters Increased  ${updated_counter_values}  cell_id=1  expected_value=${expected_value}


Reboot UE
    [Documentation]    Perform adb reboot command
    [Arguments]    ${alias}=UEPC
    ssh.Connect To    hostname=${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...               username=${tl.test_pcs[0].default_ssh_connection_details.username}
    ...               password=${tl.test_pcs[0].default_ssh_connection_details.password}
    ...               alias=${alias}
    RETURN      ${alias}
    ssh.Execute    command=adb reboot   connection=${alias}
    Sleep    50s


Change Parameters
    [Arguments]  ${delta}  @{params}
    taf.gnb.oam.coam.admin.Create Delta                   ${delta}
    ${len}=  Get Length                                   ${params}
    FOR  ${ind}  IN RANGE  0  ${len}
        &{parameter_to_change}=  Set Variable  @{params}[${ind}]
        Append Parameter Update To Delta  dist_name=&{parameter_to_change}[dist_name]  parameter=&{parameter_to_change}[parameter]
        ...                               value=&{parameter_to_change}[value]  delta_id=${delta}
    END
    ${delta_filled}=  taf.gnb.oam.coam.admin.Get Delta    ${delta}
    ${admin_alias}=  taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_filled}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown                       ${admin_alias}
    [Teardown]  taf.gnb.oam.coam.admin.Remove Delta       ${delta}


Test Case 03 Teardown
    Make Snapshot In Case Of Error
    Run Keyword And Ignore Error    ute_ue.Detach UE      ${UE_ALIAS}
    Set Attenuation     ${GNB_CELL_1}  0dB
    Run Keyword And Ignore Error    interface.Common Step Trigger


Test 5 Teardown
    Run Keyword And Ignore Error                          ute_ue.Detach UE      ${UE_ALIAS}
    Set Attenuation                                       ${GNB_CELL_1}  0dB
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=65  a2TimeToTriggerReleaseSsbRsrp=ms512
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  a2MeasReleaseEnabled=rsrp
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=  taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.teardown  ${admin_alias}
    Run Keyword And Ignore Error    interface.Common Step Trigger


Test Case 08 Teardown
    Make Snapshot In Case Of Error
    Run Keyword And Ignore Error                          ute_ue.Detach UE      ${UE_ALIAS}
    Set Attenuation                                       ${GNB_CELL_1}  0dB
    Set Attenuation                                       ${GNB_CELL_2}  90dB
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=65  a2TimeToTriggerReleaseSsbRsrp=ms480
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-2  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-3  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}  actIntraFreqIntraGnbMobilityNSA=false
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=  taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown                       ${admin_alias}
    Run Keyword And Ignore Error    interface.Common Step Trigger

Teardown
    Set attenuation for all cells    0db
    Release attenuator cell    ${cell_list}
    ${lte_pc}=   Connect to LTE BTS
    ssh.execute  command=rm [1]5GC002177*  connection=${lte_pc}
    Run Keyword And Ignore Error    interface.Common Step Trigger

Setup
    Set Global Variables
    Prepare Testline
    Set Dictionaries
    Testsuite Setup Recommissioning
    ${cell_list}=  Create List                            ${GNB_CELL_1}     ${GNB_CELL_2}     ${GNB_CELL_3}
    Set global variable   ${cell_list}
    Load Attenuation Config                               ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of                           ${cell_list}
    Set Attenuation                                       ${GNB_CELL_1}     0dB
    Set Attenuation                                       ${GNB_CELL_2}     90dB
    Set Attenuation                                       ${GNB_CELL_3}     90dB
    ute_ue.Require UE                                     ${UE_ALIAS}       capabilities=REAL_ANDROID_UE
    Reboot UE
    Run Keyword And Ignore Error                          ute_ue.Detach UE  ${UE_ALIAS}


Testsuite Setup Recommissioning
    Delete Delta If Already Present    name=default
    Initialise Delta_ Store
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=65  a2TimeToTriggerReleaseSsbRsrp=ms480
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-2  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=57  a2TimeToTriggerReleaseSsbRsrp=ms480
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  list_name=a2MeasReleaseSsbRsrq
    ...                           a2HysteresisReleaseSsbRsrq=6  a2ThresholdReleaseSsbRsrq=67  a2TimeToTriggerReleaseSsbRsrq=ms512
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  list_name=a3MeasSsbRsrp
    ...                           a3HysteresisSsbRsrp=0  a3OffsetSsbRsrp=8  a3TimeToTriggerSsbRsrp=ms512
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-2  list_name=a5MeasSsbRsrp
    ...                           a5HysteresisSsbRsrp=2  a5Threshold1SsbRsrp=66  a5Threshold2SsbRsrp=68  a5TimeToTriggerSsbRsrp=ms512
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-3  list_name=a5MeasSsbRsrp
    ...                           a5HysteresisSsbRsrp=8  a5Threshold1SsbRsrp=52  a5Threshold2SsbRsrp=56  a5TimeToTriggerSsbRsrp=ms512
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  list_name=a5MeasSsbRsrp
    ...                           a5HysteresisSsbRsrp=8  a5Threshold1SsbRsrp=68  a5Threshold2SsbRsrp=71  a5TimeToTriggerSsbRsrp=ms512
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-2  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-3  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}  srb3SupportEnabled=false  actIntraFreqIntraGnbMobilityNSA=false
    ...                           actIntraFreqIntraGnbMobilityNSA=false  actA2SgnbRelease=true
    Add List Parameters To Delta  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-3  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=47  a2TimeToTriggerReleaseSsbRsrp=ms480
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=  taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown                       ${admin_alias}


Set Dictionaries
    Set Suite Variable  &{ACTA2SGNBRELEASE_FALSE}         dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...                                                   parameter=actA2SgnbRelease        value=false
    Set Suite Variable  &{ACTA2SGNBRELEASE_TRUE}          dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...                                                   parameter=actA2SgnbRelease        value=true
    Set Suite Variable  &{A2MEASRELEASEENABLED_NONE}      dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                                   parameter=a2MeasReleaseEnabled    value=none
    Set Suite Variable  &{A2MEASRELEASEENABLED_RSRP}      dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...                                                   parameter=a2MeasReleaseEnabled    value=rsrp


Prepare Nrrel To Another Cell
    [Arguments]  ${cell_number}  ${rel_cell_number}
    ${lcrId}=       Get Parameter Value From Scf  parameter_dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${rel_cell_number}
    ...                                           parameter_abbreviation=lcrId
    ${mnc}=         Get Parameter Value From Scf  parameter_dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...                                           parameter_abbreviation=mnc
    ${mncLength}=   Get Parameter Value From Scf  parameter_dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...                                           parameter_abbreviation=mncLength
    ${mcc}=         Get Parameter Value From Scf  parameter_dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...                                           parameter_abbreviation=mcc
    ${nrbts_id_str}=  Convert To String    ${nrbts_id}
    ${nrrel_exists}=  Verify Nrrel In Scf  ${ORIGINAL_SCF}  ${cell_number}
    Delete Delta If Already Present         name=default
    Initialise Delta Store
    IF  ${nrrel_exists}
        Add Parameters To Delta
        ...                                dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_number}/NRREL-0
        ...                                cellIndividualSsbRsrpOffset=0dB  cellIndividualSsbRsrqOffset=0dB
        ...                                gNbId=${nrbts_id_str}  gNbIdLength=22  lcrId=${lcrId}
    ELSE
        Add Managed Object And Parameter To Delta
        ...                                dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_number}/NRREL-0
        ...                                cellIndividualSsbRsrpOffset=0dB  cellIndividualSsbRsrqOffset=0dB
        ...                                gNbId=${nrbts_id_str}  gNbIdLength=22  lcrId=${lcrId}
    END
    Add List Parameters To Delta           dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_number}/NRREL-0
    ...                                    list_name=gnbPlmn  mnc=${mnc}  mncLength=${mncLength}  mcc=${mcc}
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=  taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown                       ${admin_alias}

