*** Settings ***
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/5GC002177/resources/test_specific_keywords_2177.py
Library        testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library        taf.gnb.oam.coam.admin
Library        taf.ue
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaStore.py
Library        ta_attenuator
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/bts_log.py
Library        testsuite/Wroclaw/RRM/resources/scout_report.py
Resource       testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource       testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource       taf/rfrl/common_resources/common_step/interface.robot

Documentation  Set of keywords for feature 5GC002481 execution


*** Variables ***
${ABSTRACT_LIB_CONFIG}     /home/ute/testline_configuration/7_16_UTE5GCLOUDT304/hmd_conf.yaml
${UE_ALIAS}                UE_1
${IS_TL_CONCURRENT}        True
${GNB_CELL_1}              GNB_1_CELL_0
${GNB_CELL_2}              GNB_1_CELL_7
${GNB_CELL_3}              GNB_1_CELL_3


*** Keywords ***
[1]5GC002177_TC03_5GC002481_FA_003_SgNB_release_based_on_A2_based_on_RSRP_without_SRB3
    [Documentation]  This test case checks proper handling of eventA2 based on rsrp measurements.
    ...              Also covers counter Test Cases FA_16 and FA_17

    @{counters}=       Create List                     M55112C05001  M55112C05002
    ${THRESHOLD}=      Create Dictionary               rsrp=67
    ${HYSTERESIS}=     Create Dictionary               rsrp=2
    ${TIMETOTRIGGER}=  Create Dictionary               rsrp=ms480

    Start tcpdump On LTE                               filename=${test_name}_attach.pcap
    Start Bts Log                                      btslog
    Attach UE                                          ${UE_ALIAS}
    Start Data Transfer
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
    Stop Data Transfer                                 DT_UL
    Stop And Collect Btslog                            btslog  ${LOG_PATH}/${test_name}
    Stop Tcpdump On LTE And Get Logs                   filename=${test_name}_attach.pcap
    Verify A2 Event Values                             pcap_file=${LOG_PATH}/${test_name}_attach.pcap
                       ...                             threshold=${THRESHOLD}
                       ...                             hysteresis=${HYSTERESIS}
                       ...                             time_to_trigger=${TIMETOTRIGGER}
    Find Rrc Transfer                                  ${LOG_PATH}/${test_name}_attach.pcap
    Find Sgnbrelease Cause In Pcap                     pcap_file=${LOG_PATH}/${test_name}_attach.pcap
    Wait Until Keyword Succeeds  15x  60s              Check Counters  @{counters}


[1]5GC002177_TC08_5GC002481_FA_008_Intra_gNB_PSCell_change_A5_enable_and_configured_A2_RSRP_RSRQ
    [Documentation]  This test case checks proper handling of eventA5 handover based on rsrp measurements with eventA2
    ...              also being configured on the cell.
    Delete Delta If Already Present                       name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=rsrp
    Add List Parameters To Delta  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=57  a2TimeToTriggerReleaseSsbRsrp=ms480
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=rsrp  a5MeasEnabled=rsrp
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=rsrp  a5MeasEnabled=rsrp
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  actIntraFreqIntraGnbMobilityNSA=true
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=  taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown  ${admin_alias}
    Start Tcpdump On LTE                                  filename=${test_name}_attach.pcap
    Start Bts Log                                         btslog
    Attach UE                                             ${UE_ALIAS}
    Set Attenuation                                       ${GNB_CELL_2}  0dB
    Start Data Transfer
    ...                                                   dt_name=DT_UL
    ...                                                   ue_alias=${UE_ALIAS}
    ...                                                   direction=UL
    ...                                                   duration=380s
    ...                                                   throughput=200Mbits/sec
    ...                                                   protocol=udp
    ...                                                   packet_size=1200
    Stop Data Transfer                                    DT_UL
    Execute Single Cell Fading Scenario                   cell_alias=${GNB_CELL_1}
    ...                                                   fading_step=2db
    ...                                                   fading_interval=1s
    ...                                                   fading_min=0dB
    ...                                                   fading_max=90dB
    Sleep                                                 30s  reason=handover handling
    ${syslogs}=  Stop And Collect Btslog                  btslog  ${LOG_PATH}/${test_name}
    Stop Tcpdump On LTE And Get Logs                      filename=${test_name}_attach.pcap
    Find Rrc Transfer                                     pcap_file=${LOG_PATH}/${test_name}_attach.pcap
    Find Sgnbrelease Cause In Pcap                        pcap_file=${LOG_PATH}/${test_name}_attach.pcap  event_nr=eventA5
    Verify Successful Handover                            pcap_file=${LOG_PATH}/${test_name}_attach.pcap
    ...                                                   syslog_dir=${syslogs}
    ...                                                   phy_cell_id=7

Check Counters
    [Arguments]  @{counters}
    Collect Counters
    ${updated_counter_values}    Get Last Counter Values    @{counters}
    Cleanup All Downloaded Counter Files
    Check If Counters Increased  ${updated_counter_values}  cell_id=1

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
    ${admin_alias}=   taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_filled}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown                       ${admin_alias}
    [Teardown]  taf.gnb.oam.coam.admin.Remove Delta       ${delta}


Test Case 03 Teardown
    Make Snapshot In Case Of Error
    Add Scout Scf Id To Test Data
    Run Keyword And Ignore Error    Detach UE      ${UE_ALIAS}
    Set Attenuation                 ${GNB_CELL_1}  0dB
    Run Keyword And Ignore Error    interface.Common Step Trigger


Test Case 08 Teardown
    Make Snapshot In Case Of Error
    Add Scout Scf Id To Test Data
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add List Parameters To Delta  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=65  a2TimeToTriggerReleaseSsbRsrp=ms480
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  actIntraFreqIntraGnbMobilityNSA=false
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=  taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown                       ${admin_alias}
    Run Keyword And Ignore Error                          Detach UE      ${UE_ALIAS}
    Set Attenuation                                       ${GNB_CELL_1}  0dB
    Set Attenuation                                       ${GNB_CELL_2}  90dB
    Run Keyword And Ignore Error    interface.Common Step Trigger

Teardown
    Change NR Carrier Freq for LTE          368410
    Set Attenuation                         ${GNB_CELL_1}  90dB
    Set Attenuation                         ${GNB_CELL_2}  90dB
    ${lte_pc}=   Connect To LTE BTS
    ssh.Execute  command=rm [1]5GC002177*  connection=${lte_pc}


Setup
    Set Global Variable    ${MRBTS_ID}     ${tl.gnbs[0].instance_id}
    Set Global Variable    ${NRBTS_ID}     ${tl.gnbs[0].global_bts_id}
    Testsuite Setup Recommissioning

    ${cell_list}=  Create List                            ${GNB_CELL_1}  ${GNB_CELL_2}  ${GNB_CELL_3}
    Load Attenuation Config                               ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of                           ${cell_list}
    Set Attenuation                                       ${GNB_CELL_1}  0dB
    Set Attenuation                                       ${GNB_CELL_2}  90dB
    Set Attenuation                                       ${GNB_CELL_3}  90dB
    Require UE                                            ${UE_ALIAS}           capabilities=REAL_ANDROID_UE
    Run Keyword And Ignore Error                          Detach UE      ${UE_ALIAS}


Testsuite Setup Recommissioning
    Change NR Carrier Freq for LTE    365790
    Delete Delta If Already Present    name=default
    Initialise Delta Store
    Add List Parameters To Delta  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=67  a2TimeToTriggerReleaseSsbRsrp=ms480
    Add List Parameters To Delta  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=57  a2TimeToTriggerReleaseSsbRsrp=ms480
    Add List Parameters To Delta  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1  list_name=a2MeasReleaseSsbRsrq
    ...                           a2HysteresisReleaseSsbRsrq=2  a2ThresholdReleaseSsbRsrq=57  a2TimeToTriggerReleaseSsbRsrq=ms480
    Add List Parameters To Delta  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1  list_name=a3MeasSsbRsrp
    ...                           a3HysteresisSsbRsrp=0  a3OffsetSsbRsrp=8  a3TimeToTriggerSsbRsrp=ms512
    Add List Parameters To Delta  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2  list_name=a5MeasSsbRsrp
    ...                           a5HysteresisSsbRsrp=2  a5Threshold1SsbRsrp=66  a5Threshold2SsbRsrp=68  a5TimeToTriggerSsbRsrp=ms512
    Add List Parameters To Delta  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3  list_name=a5MeasSsbRsrp
    ...                           a5HysteresisSsbRsrp=8  a5Threshold1SsbRsrp=52  a5Threshold2SsbRsrp=56  a5TimeToTriggerSsbRsrp=ms512
    Add List Parameters To Delta  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1  list_name=a5MeasSsbRsrp
    ...                           a5HysteresisSsbRsrp=8  a5Threshold1SsbRsrp=68  a5Threshold2SsbRsrp=71  a5TimeToTriggerSsbRsrp=ms512
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3  a2MeasReleaseEnabled=rsrp
    ...                           a3MeasEnabled=none  a5MeasEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  srb3SupportEnabled=false  actIntraFreqIntraGnbMobilityNSA=false
    ...                           actIntraFreqIntraGnbMobilityNSA=false  actA2SgnbRelease=true
    Add List Parameters To Delta  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3  list_name=a2MeasReleaseSsbRsrp
    ...                           a2HysteresisReleaseSsbRsrp=4  a2ThresholdReleaseSsbRsrp=47  a2TimeToTriggerReleaseSsbRsrp=ms480
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=  taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown                       ${admin_alias}

Change NR Carrier Freq for LTE
    [Arguments]  ${value}
    Delete Delta If Already Present    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-40824/LNBTS-40824/NRDCDPR-0/ENDCDMEASCONF-0  carrierFreqNrCell=${value}
    ${delta_store}=  Collect Delta Store
    ${lte_alias}=  taf.gnb.oam.coam.admin.Connect To  bts_host=10.44.225.139
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${lte_alias}
    taf.gnb.oam.coam.admin.Teardown  connection=${lte_alias}

Prepare Nrrel To Another Cell
    [Arguments]  ${cell_number}  ${rel_cell_number}
    ${lcrId}=       Get Parameter Value From Scf  parameter_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${rel_cell_number}
    ...                                           parameter_abbreviation=lcrId
    ${mnc}=         Get Parameter Value From Scf  parameter_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                                           parameter_abbreviation=mnc
    ${mncLength}=   Get Parameter Value From Scf  parameter_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                                           parameter_abbreviation=mncLength
    ${mcc}=         Get Parameter Value From Scf  parameter_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                                           parameter_abbreviation=mcc

    ${nrbts_id_str}=  Convert To String    ${NRBTS_ID}
    ${nrrel_exists}=  Verify Nrrel In Scf  ${ORIGINAL_SCF}  ${cell_number}
    Delete Delta If Already Present         name=default
    Initialise Delta Store
    IF  ${nrrel_exists}
        Add Parameters To Delta
        ...                                dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_number}/NRREL-0
        ...                                cellIndividualSsbRsrpOffset=0dB  cellIndividualSsbRsrqOffset=0dB
        ...                                gNbId=${nrbts_id_str}  gNbIdLength=22  lcrId=${lcrId}
    ELSE
        Add Managed Object And Parameter To Delta
        ...                                dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_number}/NRREL-0
        ...                                cellIndividualSsbRsrpOffset=0dB  cellIndividualSsbRsrqOffset=0dB
        ...                                gNbId=${nrbts_id_str}  gNbIdLength=22  lcrId=${lcrId}
    END
    Add List Parameters To Delta           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_number}/NRREL-0
    ...                                    list_name=gnbPlmn  mnc=${mnc}  mncLength=${mncLength}  mcc=${mcc}
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=  taf.gnb.oam.coam.admin.Connect To
    taf.gnb.oam.coam.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                                   should_activate=True  timeout=300s  connection=${admin_alias}
    taf.gnb.oam.coam.admin.Teardown                       ${admin_alias}
