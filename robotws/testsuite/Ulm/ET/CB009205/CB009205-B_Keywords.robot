*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB009205-B

Resource    ../resources/SQD65/sqd65_keywords.robot
Resource    CB009205-B_Commissioning.robot

Library     taf.analyzer.pdml    WITH NAME    pdml_analyzer
Library     taf.config.wts       WITH NAME    wts_conf
Library     ta_pcmd

*** Variables ***

${FEATURE}           CB009205-B
${TEST_MODE}         auto
${WTS_CFG_FILE}      basic_setup_${FEATURE}.cfg

@{IP_LIST_eth3_add}  10.0.1.3  10.0.1.4  10.0.1.5  10.0.1.6  10.0.1.7  10.0.1.8
@{IP_LIST_eth4_add}  10.0.2.90  10.0.2.91  10.0.2.92

@{CP_DBG_FLAGS}=     0x10040=1  0x1003F=1
...                  \#cplane log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
...                  \#cp_rt  0x590072=1  \#cp_nrt  0x66001b=1  \#cp_nb  0x890001=1  \#cp_sb  0x890002=1  \#cp_ue  0x890003=1
...                  \#cp_cl  0x890005=1  \#cp_sctp  0x890006=1


@{B_B5_COUNTERs}     M55124C02003  ==  1  NRRCC_MEAS_A1_REC

${UE_CAPA_TDD}       SEPARATOR=
...                  E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E8
...                  19F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0003C000E0541B107582308682041E207032B64C55890E7D813E238F1891C790E7D
...                  473E618F28581C0E1E13FB000000FEC00000078001C0AA3626EB04610D04083A40E0616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B
...                  801FF800E007FE00078001C0A836236B04610D04083C40E0656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000000F
...                  0003801EF0F1340038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400389A0000042C0AC
...                  5C46000E208007104000028581587850001C4D00000C160562E2680071040038500000102C0AC5C4D000E23000711800001058158B850001C41000E
...                  230000020B02B170A0003882001C41000004160562E26800710400388C0000082C0AC5C28000E23000711800001058158B89A001C46000E14000004
...                  0B02B0F11800388C00000C2C0803808D00A2026C0410B42EC1F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C
...                  3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3
...                  C6318C6318C6318C63187FAAAAA826007C005038280381804A00E000C0580080C070500703E09002000000010000020080000000400000802000008
...                  010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C010008120480200
...                  00300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652504000065949410000296524040000E59490100004965240
...                  4000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2AABA55554AA2
...                  E95455058AA0B1541A2A94C55268AA031540A2A93555078A1202F012A05028140A05028140A05028140A05028140A05028003040403006010020042
...                  02004010080100420100200404030060100C018202018030080600C201002004040300601002004402018030080600C020180304040080201002008
...                  6AC7C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05D55555554982D0

${UE_CAPA_TDD_B3_7_Band41}   SEPARATOR=
...                          69A00000446084C00E83626D52B04610D04083E52F55555553D55555542200038002007134000000
...                          009850007FFFC00026006C005038280301884C00C000F01E0A00C03C00000000000008A800000000
...                          00000A8000008010020445

${UE_CAPA_TDD_B3_Band78}     SEPARATOR=
...                          69A00000446084C00E83626D52B04610D04083E52F55555553D55555542200038002007134000000
...                          00989A007FFFC00026006C005038280301884C00C000F01E0A00C03C00000000000008A800000000
...                          00000A8000008010020445

${UE_CAPA_TDD_CNI88822}      SEPARATOR=
...                          69A00000446084C00E83626D52B04610D04083E52F55555553D55555542200038002007134000000
...                          00989A007FFFC00026006C005038280301884C00C000F01E0A00C03C00000000000008A800000000
...                          00000A8000008010020445

&{plmn}=                mcc=311
...                     mnc=489
...                     mncLength=3

*** Keywords ***

Prepare TL
    Sqd65 Common Setup
    Prepare WTS Config
    Update iphy file ca
    Commissioning
    Bring Airphone TL to on Air
    ${SCF}                   gnb.Get SCF From GNB
    Set Suite Variable       ${SCF}

Perform Preconditions of Test Scenario
    Create Testcase Log Directory
    IF    '${PREV_TEST_STATUS}'=='FAIL'     Perform Preconditions of Test Scenario in Case of Previous TC failed
    Start Logging                    pmcounter_enabled=${FALSE}
    Start Tshark for Trace Session   collector=tce_trace
    OperatingSystem.Run    sudo docker stop ondemand_ntracer  # WA to use ta pcmd
    Start PCMD

Perform Preconditions of Test Scenario in Case of Previous TC failed
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone
    Bring Airphone TL to on Air

Perform Postconditions of Test Scenario
    Stop Tshark on Test PC                      collector=tce_trace
    Stop PCMD
    Run Keyword And Ignore Error                UE Deregister
    IF    '${TEST_MODE}'=='auto'    Collect AP Sos Report and Snapshots
    Run Keyword And Warn On Failure             Stop Logging
    Revert Delta Commissioning

Perform Postconditions of Test Scenario CA disabled
    Perform Postconditions of Test Scenario
    IF    '${TEST STATUS}'=='PASS'    Perform Preconditions of Test Scenario in Case of Previous TC failed

Revert Delta Commissioning
    ${log_dir}=                Get Testcase Log Directory
    ${curr_scf}=               Get SCF from gNB  target_dir=${log_dir}
    ${revert_file}=            Set Variable  ${log_dir}/revert.json
    scf.calculate_delta_scf    ${SCF}  ${curr_scf}  ${revert_file}
    Config gNB with delta scf  ${revert_file}

Bring Airphone TL to on Air
    ute_workarounds.Bring Airphone TL to on Air status   force_cu_type=SA  cfg_file=${WTS_CFG_FILE}

Prepare WTS Config
    ${WTS_CFG_FILE}=             Set Variable   ${tl.core.dir_path}/${WTS_CFG_FILE}
    wts_conf.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    Remove ENB from WTS config
    Remove NSA UEs from WTS config
    Add GNB-3 to WTS Config
    wts_conf.Modify              set_cell id=2  nr_arfcn=${NRCELL-2.nrarfcn}:${NRCELL-2.nrarfcn} gscn=${NRCELL-2.gscn}
    wts_conf.Modify              set_ue simulated id=2   cell=1
    wts_conf.Modify              ue_param id=1      ue_nr_capabilities=${UE_CAPA_TDD}
    wts_conf.Modify              ue_param id=2      ue_nr_capabilities=${UE_CAPA_TDD}
    wts_conf.Modify              set_amf id=1       name=simAMF1
    wts_conf.Modify              amf_param id=1     intra5gs_data_forwarding=on
    wts_conf.Save Wts Cfg        ${WTS_CFG_FILE}
    ${ts_conf_dir}=              Get Test Suite Config Directory
    Copy File                    ${WTS_CFG_FILE}  ${ts_conf_dir}

Remove NSA UEs from WTS config
    ${NSA_UE_IDs}=
    ...  Run   bash -c "grep dual_conn=eutra_nr ${tl.core.dir_path}/${tl.core.cfg_filename} | sed -e 's/^.* id=\\\\([0-9]*\\\\) .*$/\\\\1/'"
    @{NSA_UE_ID_LIST}=  Split to lines  ${NSA_UE_IDs}
    FOR  ${nsa_ue_id}  IN   @{NSA_UE_ID_LIST}
        ${present}=  wts_conf.get  set_ue simulated id=${nsa_ue_id}
        IF           '${present}' != 'None'
               wts_conf.delete    set_ue simulated id=${nsa_ue_id}
               wts_conf.delete    ue_param id=${nsa_ue_id}
               wts_conf.delete    set_pdu_gateway id=${nsa_ue_id}
               wts_conf.delete    set_bearer id=2 ue=${nsa_ue_id}
        END
    END

Remove ENB from WTS config
    wts_conf.delete              set_enb id=1
    wts_conf.delete              enb_param id=1
    wts_conf.delete              set_cell id=1 enb=1
    wts_conf.delete              enb_endc_param id=1
    wts_conf.delete              mme_pool_area id=1
    wts_conf.delete              set_mme id=1
    wts_conf.delete              set_sgw id=1
    wts_conf.delete              set_pgw id=1
    wts_conf.delete              trace enb=1 protocol=x2 on
    wts_conf.delete              trace uec=1 protocol=x2 on

Add GNB-3 to WTS Config
    ${gnb3_wts}=          Catenate       SEPARATOR=${SPACE}
    ...                                  type=simulated plmn=311:489 ng=$GNB3_NG_ADDR gnb_id=0x3:22
    ...                                  daemon=$SERVER_IP:$DAEMON_PORT x2_peers=none nssai=0x1:0xd143a5 amf=1
    ...                                  plmnList=311:489
    ${gnbparam3_wts}=     Catenate       SEPARATOR=${SPACE}
    ...                                  xn_listening_socket=1 sa_ho=ng_based sib1_period=160 measEvent=A3 measEvent=A1
    ${cell1_gnb3_wts}=    Catenate       SEPARATOR=${SPACE}
    ...                                  pci=16:0 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER1_IP:9999
    ...                                  nr_arfcn=633372:633372 gscn=7847 mandatory_for_activation=off
    ${cell2_gnb3_wts}=    Catenate       SEPARATOR=${SPACE}
    ...                                  pci=16:1 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER2_IP:9999
    ...                                  nr_arfcn=643332:643332 gscn=7950 mandatory_for_activation=off

    wts_conf.insert                      set GNB3_NG_ADDR="10.0.1.3"              after    set DAEMON_PORT="22222"
    wts_conf.insert                      set PROXY_SERVER1_IP="10.0.2.90"         after    set DAEMON_PORT="22222"
    wts_conf.insert                      set PROXY_SERVER2_IP="10.0.2.91"         after    set DAEMON_PORT="22222"
    wts_conf.insert                      set_gnb id=3 ${gnb3_wts}                 after    set_gnb id=2
    wts_conf.insert                      gnb_param id=3 ${gnbparam3_wts}          after    set_gnb id=3
    wts_conf.insert                      set_cell id=1 gnb=3 ${cell1_gnb3_wts}    after    gnb_param id=3
    wts_conf.insert                      set_cell id=2 gnb=3 ${cell2_gnb3_wts}    after    set_cell id=1 gnb=3

Update iphy file ca
    ${ts_conf_dir}       Get Test Suite Config Directory
    ${ap_alias}          Connect to Airphone Common Unit
    ssh.execute          cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ap_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml        ${ts_conf_dir}/new_iphy.xml           connection=${ap_alias}

    ${contents}          Get File          ${ts_conf_dir}/new_iphy.xml
    ${all_parts}         Split String      ${contents}     </RE>

    ${upd0}              Replace String Using Regexp    ${all_parts}[0]      GSCN>.*<\/GSCN>   GSCN>7880<\/GSCN>
    ${upd1}              Replace String Using Regexp    ${all_parts}[1]      GSCN>.*<\/GSCN>   GSCN>${NRCELL-2.gscn}<\/GSCN>

    ${new contents}      catenate         SEPARATOR=</RE>   ${upd0}  ${upd1}  ${all_parts}[2]  ${all_parts}[3]  ${all_parts}[4]
    Create File          ${ts_conf_dir}/new_iphy_upd.xml    ${new contents}
    ssh.Upload File      ${ts_conf_dir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}

Reload original iphy file
    ${ap_alias}          Connect to Airphone Common Unit
    ssh.execute          cp /ffs/run/simmode/new_iphy_orig.xml /ffs/run/simmode/new_iphy.xml    connection=${ap_alias}

Apply Config for B_B5
    ${dist_name}=            Set Variable               NRBTS-1/NRCELL-1
    ${nrhoif_id}=            Set Variable               2

    ${scf_file}=             Load current SCF
    Add NRHOIF               id=${nrhoif_id}
    Set Element              dist_name=${dist_name}/NRHOIF-${nrhoif_id}    p_name=a4PriorityForHigherPrioFreqHo  value=${prio_ssbFreq_nrhoif-2}
    Set Element              dist_name=${dist_name}/NRHOIF-${nrhoif_id}    p_name=a4MeasHigherPrioFreqEnabled    value=rsrp
    Set Element              dist_name=${dist_name}/NRHOIF-${nrhoif_id}    p_name=ssbFrequency                   value=${ssbFrequency_nrhoif-2}

    ${list_elements}=        Create dictionary          a4HysteresisSsbRsrp             1
    ...                                                 a4ThresholdSsbRsrp              35
    ...                                                 a4TimeToTriggerSsbRsrp          ms64
    Set New List             dist_name=${dist_name}/NRHOIF-${nrhoif_id}    list_name=a4MeasSsbRsrp
    scf.add_item_to_list     dist_name=${dist_name}/NRHOIF-${nrhoif_id}    list_name=a4MeasSsbRsrp               elements=${list_elements}

    Set Element              dist_name=${dist_name}     p_name=a4MeasHigherPrioFreqMaxReactSA     value=${a4MeasHigherPrioFreqMaxReactSA_B5}

    Set New List             dist_name=${dist_name}     list_name=a4PeriodicMeasControlSA
    scf.add_item_to_list     dist_name=${dist_name}     list_name=a4PeriodicMeasControlSA         elements=${a4PeriodicMeasControlSA_B5}

    Apply Delta SCF          ${scf_file}  scf_B_B5

Register UE
    [Arguments]    ${ue_id}=1  ${pdu_id}=1  ${pass_regexp}=Initial Context Setup Successful
    Set Traffic Type             ue_id=${ue_id}  pdu_id=${pdu_id}  trf_type=internal
    UE Register                  ue_id=${ue_id}  ue_nr_capabilities=${UE_CAPA_TDD}
    UE PDU Session Setup         ue_id=${ue_id}     pdu=${pdu_id}    gw=${ue_id}   pass_regexp=${pass_regexp}
    Start data traffic in egate  ue_id=${ue_id}  pdu=${pdu_id}    direction=dl
    Start data traffic in egate  ue_id=${ue_id}  pdu=${pdu_id}    direction=ul
    Send Egate Command and verify output   set_log flush
    Send Egate Command and verify output   state_sim_disp
    Sleep  1

Deregister UE
    UE Deregister
    Sleep  2

Register UE to the simgNB and setup pdu session
    [Arguments]    ${ue_id}=1    ${ue_nr_capabilities}=${None}
    UE Change Location                              id=${ue_id}       enb=3          cell=1
    Register UE to the gNB and setup pdu session    ue_id=${ue_id}    ue_nr_capabilities=${ue_nr_capabilities}

Register UE to the gNB and setup pdu session
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${trf_type}=internal    ${ue_nr_capabilities}=${None}
    IF    """${ue_nr_capabilities}"""=="""${None}"""
    ...                                     UE Register    ue_id=${ue_id}
    ...                             ELSE    UE Register    ue_id=${ue_id}    ue_nr_capabilities=${ue_nr_capabilities}
    Set traffic type                        ue_id=${ue_id}          pdu_id=${pdu_id}      trf_type=${trf_type}
    UE PDU Session Setup                    pdu=${pdu_id}     ue_id=${ue_id}    gw=1
    ...                                     pass_regexp=(Pdu Session.*successfully)|(Initial Context Setup Successful)
    Send Egate Command and verify output    set_log flush

UE Change Location
    [Arguments]    ${id}=1    ${enb}=3    ${cell}=1
    Send Egate Command and verify output    cmd=ue_change_location id=${id} enb=${enb} cell=${cell}
    ...                                     pass_regexp=(location updated to eNB-${enb} cell ${cell})|(already there)
    ...                                     fail_regexp=[Ee]rror.*ENB.*is not configured

UE Param
    [Arguments]    ${id}=1    &{kwargs}
    ${command_args}=    Convert Dictionary to Parameter String    &{kwargs}
    Send Egate Command and verify output    cmd=ue_param id=${id} ${command_args}
    ...                                     fail_regexp=[Ee]rror

UE RRC Reestablish
    [Arguments]   ${ue_id}=1    ${pass_regexp}=rrcReconfigurationComplete    &{kwargs}
    ${command_args}=    Convert Dictionary to Parameter String    &{kwargs}
    Send Egate Command and verify output    cmd=ue_rrc_reestablish id=${ue_id} ${command_args}
    ...                                     pass_regexp=${pass_regexp}

Collect PMCounters
    [Arguments]    ${target_dir}=None
    ${log_dir}=    IF    '${target_dir}'=='None'  testline.Get Testcase Log Directory
    ...                        ELSE  Set Variable   ${target_dir}
    pmcounters.Wait until the current Measurement Period stops
    ${pm_files}=    pmcounters.Collect PM Counter    target_dir=${log_dir}
    Remove Files    ${pm_files}/*.gz                 # WA: PMCounterLogReader._parse_pm_file can not deal with gz files
    RETURN  ${pm_files}

Verify PM Counters
    [Arguments]       ${tc}  ${dn_suffix}=1
    ${pm_files}=      Collect PMCounters
    ${counter_var}=   Get Variable Value   ${${tc}_COUNTERs}
    Verify PM Counter Reference Table  reference_table=${counter_var}  pm_dir=${pm_files}   distname_suffix=${dn_suffix}

a4PeriodicMeasCycles
    [Arguments]      ${ue_id}=1  ${a4PeriodicMeasControl}=${a4PeriodicMeasControlSA}  ${numOfa4PeriodicMeasCycles}=1
    ${numOfCycles}=  Evaluate  ${numOfa4PeriodicMeasCycles} + 1
    FOR  ${_}    IN RANGE  1  ${numOfCycles}
       Send NR Measurement Report    ue_id=${ue_id}  event=A1  # activate a4PeriodicMeasCycle
       a4PeriodicMeasCycle        ue_id=${ue_id}  a4PeriodicMeasControl=${a4PeriodicMeasControl}
    END

a4PeriodicMeasCycle
    [Arguments]      ${ue_id}=1  ${a4PeriodicMeasControl}=${a4PeriodicMeasControlSA}
    ${numOfA4Meas}=  Evaluate  ${a4PeriodicMeasControl['a4MeasMaxNumber']} + 1
    FOR  ${index}   IN RANGE  1  ${numOfA4Meas}
       Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
       Wait For RrcReconfigurationComplete    ue_id=${ue_id}  timeout=${a4PeriodicMeasControl['a4Fr1SupervisionTimer']}   # Fr2 missing !!!
       Verify Measurement ID is absent        A4  carrier_freq=${ssbFrequency_nrhoif-1}
       ${status}=   Run Keyword and Return Status
       ...          Wait For RrcReconfigurationComplete    ue_id=${ue_id}    timeout=${a4PeriodicMeasControl['a4RetryTimer']}
       IF  ${index} < ${a4PeriodicMeasControl['a4MeasMaxNumber']} and not ${status}       Fail  a4PeriodicMeasCycle incomplete
       IF  ${index} == ${a4PeriodicMeasControl['a4MeasMaxNumber']} and ${status}          Fail  a4PeriodicMeasCycle exceeded
    END
    Send Egate Command and verify output   set_log flush

Wait For RrcReconfigurationComplete
    [Arguments]       ${ue_id}=1  ${timeout}=10s
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=rrcReconfigurationComplete  timeout=${timeout}

Verify Measurement Config Values
    [Arguments]       ${meas_cfg_str}  ${ue_id}=1
    Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=${meas_cfg_str}

Verify PCMD Trace
    ${pcmd_file}=            Get PCMD Trace file
    @{pattern_list}=         Create List
    ...                      "ueMeasRecord"
    ...                      "carrierFreq": ${NRCELL-1.nrarfcn_gscn}
    ...                      "triggerType": "a1"
    ...                      "purpose": "trafficSteering"
    ...                      "measResultServingMos":
    ...                      "servCellId": 0
    ...                      "pci": ${physCellId1}
    ...                      "pcell": true
    ...                      "measResultSsbIndexes":
    ...                      "ssbIndex": 0
    Verify Sequence in File  ${pcmd_file}  @{pattern_list}

Remove NRHOIF MO
    ${scf_file}=                         Load current SCF
    scf.remove_mo_with_descendant_mos    NRBTS-1/NRCELL-1/NRHOIF-1
    Apply Delta SCF                      ${scf_file}  scf_B_HRHOIF_removed

Enable Blind CA
    ${scf_file}=       Load current SCF
    Set Element        dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1     p_name=sCellAdditionMethod   value=blind
    Apply Delta SCF    ${scf_file}  scf_blind_CA

Disable A1 based traffic steering to preferred NR layer
    ${scf_file}=       Load current SCF
    Set Element        dist_name=NRBTS-1     p_name=actA1HoPrefNRLayer   value=none
    Apply Delta SCF    ${scf_file}  scf_A1_based_traffic_steering_disabled

Enable A1 based traffic steering to preferred NR layer
    ${scf_file}=       Load current SCF
    Set Element        dist_name=NRBTS-1     p_name=actA1HoPrefNRLayer   value=SA
    Apply Delta SCF    ${scf_file}  scf_A1_based_traffic_steering_enabled

Enable Carrier Aggregation FR1 TDD SA
    ${caSupportList}           Create List          ca_Fr1Tdd_Sa
    Set Carrier Aggregation    ${caSupportList}

Disable Carrier Aggregation
    ${caSupportList}           Create List          none
    Set Carrier Aggregation    ${caSupportList}

Set Carrier Aggregation
    [Arguments]    ${carrierAggregationSupportList}    ${distName}=MRBTS-1/NRBTS-1/NRDU-1    ${gnb_id}=${0}
    ${carrierAggregationSupportDict}     Create Dictionary    parameterName=carrierAggregationSupportList
    ...                                                       operation=update    value=${carrierAggregationSupportList}
    ${carrierAggregationSupportDictL}    Create List          ${carrierAggregationSupportDict}
    ${carrierAggregationSupportMo}       Create Dictionary    operation=update
    ...                                                       distName=${distName}
    ...                                                       parameters=${carrierAggregationSupportDictL}
    ${mo_list}=                          Create List          ${carrierAggregationSupportMo}
    commissioning.Commission Managed Object List              ${mo_list}    gnb_id=${gnb_id}

A1 measurement configuration for steering UE to preferred NR Layer enabled SA
    [Arguments]        ${dist_name}=MRBTS-1/NRBTS-1/NRCELL-1    ${a1MeashoPrefNRLayerEnabledSA}=rsrp
    ${scf_file}=       Load current SCF
    Set Element        dist_name=${dist_name}    p_name=a1MeashoPrefNRLayerEnabledSA    value=${a1MeashoPrefNRLayerEnabledSA}
    Apply Delta SCF    ${scf_file}  scf_A1_based_traffic_steering_meas_cfg

Max Reactivation of A4 Meas for Mobility to higher Prio
    [Arguments]        ${a4MeasHigherPrioFreqMaxReactSA}=1
    ${scf_file}=       Load current SCF
    Set Element        dist_name=NRBTS-1/NRCELL-1     p_name=a4MeasHigherPrioFreqMaxReactSA    value=${a4MeasHigherPrioFreqMaxReactSA}
    Apply Delta SCF    ${scf_file}  scf_max_react_A4_meas

Apply Config for B_62_63
    [Arguments]   ${a1MeashoPrefNRLayerEnabledSA}=rsrp  ${a1HysteresisSsbRsrp}=5   ${a1ThresholdhoSsbRsrq}=63  ${dist_name}=NRBTS-1/NRCELL-1
    ${scf_file}=             Load current SCF

    Set Element              dist_name=${dist_name}     p_name=a1MeashoPrefNRLayerEnabledSA       value=${a1MeashoPrefNRLayerEnabledSA}

    ${list_elements}=        Create dictionary          a1HysteresisSsbRsrp                       ${a1HysteresisSsbRsrp}
    ...                                                 a1ThresholdhoSsbRsrp                      60
    ...                                                 a1TimeToTriggerhoSsbRsrp                  ms480
    Set New List             dist_name=${dist_name}     list_name=a1MeashoPrefNRLayerSsbRsrpSA
    scf.add_item_to_list     dist_name=${dist_name}     list_name=a1MeashoPrefNRLayerSsbRsrpSA    elements=${list_elements}

    ${list_elements}=        Create dictionary          a1HysteresisSsbRsrq                       0
    ...                                                 a1ThresholdhoSsbRsrq                      ${a1ThresholdhoSsbRsrq}
    ...                                                 a1TimeToTriggerhoSsbRsrq                  ms480
    Set New List             dist_name=${dist_name}     list_name=a1MeashoPrefNRLayerSsbRsrqSA
    scf.add_item_to_list     dist_name=${dist_name}     list_name=a1MeashoPrefNRLayerSsbRsrqSA    elements=${list_elements}


    Apply Delta SCF          ${scf_file}  scf_B_B62_63

Wait until a4PeriodicMeasCycle finish
    FOR   ${_}   IN RANGE   ${${a4PeriodicMeasControlSA['a4MeasMaxNumber']} + 1}
        ${status}=   Run Keyword and Return Status   Wait For RrcReconfigurationComplete
        IF   not ${status}   BREAK
    END

Enable Mobility Profile
    [Arguments]   ${a1MeashoPrefNRLayerEnabledSA}=rsrp
    ${scf_file}=              Load current SCF
    Set Element         dist_name=MRBTS-1/NRBTS-1                  p_name=actMobilityProfile               value=true
    Set Element         dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-1      p_name=a1MeashoPrefNRLayerEnabledSA     value=${a1MeashoPrefNRLayerEnabledSA}
    Apply Delta SCF           ${scf_file}  scf_mobprofile

Disable A1 configuration on simgNB
    Send Egate Command and verify output    cmd=gnb_param id=3 xn_listening_socket=1 sa_ho=ng_based sib1_period=160 measEvent=A3

Trigger NG HO from simgNB to realgNB
    Send NR Measurement Report  A3
    ...    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    ...    meas_values=srsrp_nr=19 phycell_id=50 nrsrp_nr=100

Verify a4PeriodicMeasCycle before and after RRE
    [Arguments]      ${ue_id}=1  ${a4PeriodicMeasControl}=${a4PeriodicMeasControlSA}  ${numOfa4PeriodicMeasCycles}=1
    ${numOfCycles}=  Evaluate  ${numOfa4PeriodicMeasCycles} + 2
    FOR  ${cycle}    IN RANGE  1  ${numOfCycles}
       Send NR Measurement Report    ue_id=${ue_id}  event=A1  # Network activates A4 Measurement Cycle
       a4PeriodicMeasCycle before and after RRE    RRE_trigger_cycle=${cycle}  ue_id=${ue_id}  a4PeriodicMeasControl=${a4PeriodicMeasControl}
    END

a4PeriodicMeasCycle before and after RRE
    [Arguments]      ${ue_id}=1  ${a4PeriodicMeasControl}=${a4PeriodicMeasControlSA}  ${RRE_trigger_cycle}=1
    ${numOfA4Meas}=  Evaluate  ${a4PeriodicMeasControl['a4MeasMaxNumber']} + 1
    ${A1_ignore_checker}=  Evaluate  ${RRE_trigger_cycle} + 1
    FOR  ${index}   IN RANGE  1  ${numOfA4Meas}
       Verify Measurement ID is configured    A4  carrier_freq=${ssbFrequency_nrhoif-1}
       Wait For RrcReconfigurationComplete    ue_id=${ue_id}  timeout=${a4PeriodicMeasControl['a4Fr1SupervisionTimer']}
       IF  ${index} == ${RRE_trigger_cycle}    #UE initiates RRC Re-establishment during A4 conf-deconf cycle
       ...            UE RRC Reestablish    ue_id=1    gnb=2  cell=1
       IF  ${index} == ${A1_ignore_checker}     #UE send A1 MR during A4 cycle and NW ignores
       ...            Verify Measurement is ignored          A1  timeout=2s
       Verify Measurement ID is absent        A4  carrier_freq=${ssbFrequency_nrhoif-1}
       ${status}=   Run Keyword and Return Status
       ...          Wait For RrcReconfigurationComplete    ue_id=${ue_id}    timeout=${a4PeriodicMeasControl['a4RetryTimer']}
       IF  ${index} < ${a4PeriodicMeasControl['a4MeasMaxNumber']} and not ${status}       Fail  a4PeriodicMeasCycle incomplete
       IF  ${index} == ${a4PeriodicMeasControl['a4MeasMaxNumber']} and ${status}          Fail  a4PeriodicMeasCycle exceeded
    END
    Verify Measurement ID is absent        A4  carrier_freq=${ssbFrequency_nrhoif-1}    #Verify MeasEvent A4 is absent after conf-deconf cycle
    Send Egate Command and verify output   set_log flush
