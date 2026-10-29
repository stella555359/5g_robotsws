*** Settings ***

Documentation
...    author: VRF ULM T01 01 and VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 1' and 'MN RAN RD VRF ULM 4'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_1_53028392@internal.nsn.com'
...    Description: Keywords for CB009267-A,-B and -D

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library     taf.config.wts        WITH NAME    wts_conf

Resource    ../resources/SQD65/sqd65_keywords.robot
Resource    ../resources/SQD65/sqd65_commissioning.robot
Resource    ./CB009267_Commissioning.robot
Resource    ./CB009267_PM.robot

*** Variables ***

@{IP_LIST_eth3_add}         10.0.1.3  10.0.1.4  10.0.1.5  10.0.1.6  10.0.1.140  10.0.1.141
@{IP_LIST_eth4_add}         10.0.2.90

#This UE Capability supports 5CC/2CC with DL: PCell band: 41 (Cell 1), SCell band: 41, 77, 71, 25 and UL: PCell band: 41 (Cell 1), SCell band: 71
${UE_CAPAB_5CC_2CC}          SEPARATOR=
...                          F5A03C0047D4FFBEFFFFBAF0A40003C170101E0935F3FFFB7C00B004D9E71FF9863CA160106E0601F8E02145F063FE6F28EF
...                          215FFFFFF96596884400416CCB6C06FCFBFFFEBFFF7CFB3FFFFE014FFD3FF28BE20FFCDE51DE42BFFFFFF2CB2D10880082D996D80DF9F7FFFD7FFEF
...                          9F67FFFFC029FFA7FE517C46FF9BCA210AFFFFFFCB2CB44220020B665B6037FFDFFFF5FFFBE7D9FFFFF00A7FE9FF945F0A3FE6F288600FFFFFFCB2C
...                          B640880082D996D80DFFF7FFFD7FFEF9F67FFFFC02DFFFFEDFFFFE517C4CFF9BCA21803FFFFFF2CB2D8022001EB625B80DFFF3FFFD7FFEF9F677FFF
...                          C37FFFFB7FFFF81A89C46000E1400060A00C0C0184C00003FCFFFFFFFFFA898180385000182803082061300002FF3FFFFFFFFEA260600E1400060A0
...                          0C2081C46000004FF3FFFFFFFFE01200C4041808D00A20260EA0002B01C48D0206FF3EDC48D0206FF3EDC4811A06FF3ED8070318C7FFFF000118001
...                          F00140E0A00E062138038003C00301D00382803018000100001804800C07C04B24000002B24000008B24000010B24000018B2400002001182958195
...                          9535953595340464000004B292320000225949190000212CA48C8000189652464000104B292008A0B1540E6A954552A9AA55343C0084013C9380F24
...                          E03C9280F24A03C9280000440100200404018030100600C04008010100600C80200400808030060200C01808010020200C019004008010100600C04
...                          018030100200404008010AC188

#This UE Capability supports 1CC/1CC with DL: PCell band: 41 (Cell 1) and UL: PCell band: 41 (Cell 1), SCells bands 71, 66 (Cell-4 and Cell-5)
# not supported
${UE_CAPAB_1CC_1CC_NO_CA}    SEPARATOR=
...                          E9A09000575F5A13160003C6200005824C5C00670F434009B20C39F30C7942C0E098140188E02F71B0A303582308682041D213000DAD931563439F1
...                          1C7A067D813E31238F21CFA8E7CC31E50B0381C3C17003FF001C0017C001F00000381506C41D608C21A08107884C0032B64C55890E7D813E238F189
...                          1C790E7D473E618F28581C0E1E13FB000000FEC000000F800001C0AA3626EB04050D012CB28989800616C10109070E238F11C7A067D813EF1C39061
...                          C00103278F82B800FF800E003FE000F10000EDC000200000001C0002000000000A836236B04610D04083C42600195B262AC4873E238F604F8C48E3C
...                          873EA39F30C7942C0E070F09FFF000007FFC000007C00000E0541B063582308682041E213000CAD931562439F11C7B027C62471E439F51CF9863CA1
...                          607038784FFF800003FFE000003E00000702A8D899AC1184341020E909800616C98AA221CF88E3C471E819F604F8C73E618F28581C0E1E0B801FF80
...                          0E007FE000F800001C0015038500000002C0805808D00A2026C0418031013095000006806044D8E7C302808CF4270001E00140E0A00E06012803800
...                          30120020301F04801000000008000010040000000200000401000004008000030040000200200001401000802008020000180100000E00800400000
...                          0100001000800009004000018020000280100001600800409024010000180672A6F2A2B2A6B2A2B296B292B286B282B266B262B036B016F2A681C08
...                          00004B29202000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA4A0800044B29202000132CA4A080005
...                          4B29202000172CA480800064B29202000062CA48080006CB2CA81BA55174AAAA954552AAAA53154A6AA9445528AAA4D1549AAA81C55028AA03174AA
...                          A898000E0014000000080A00E3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828725A9440000840

${DU-to-CU-RRCInfo}          100200c0000100c1400302000e00c240020100
${ExtDu-to-PrimeDu-RrcInfo}  SEPARATOR=
...                          0044002880a360631078d167cb80042cdb40000019b193e8a81d29c028806b010a02190a20860c23286d9220064401b90018000080b29020251003c
...                          0200240400498118140d484362194088512f08e54140188aa88008c00609d5000708879400e0402188001c221e38005c0c045100038443c7000b820
...                          0862000708878e08170501144000e110f1c1020800000286181018202c0e0ba000e5000000001002000c04803305c003008000000280059f1008232
...                          0400000000002800554d80800800000013d0050a51451e52853253c5463857ffc

${IGNB_CA_ADDITION_PARAM}
...                          a2_event_type=rsrp a2_event_report_amount=eventA2ReportAmount_r1 a2_event_report_interval=EventA2ReportInterval_ms120
...                          a2Hysteresis_SCell_Rel_SsbRsrp=0 a2Threshold_SCell_RelSsbRsrp=23 a2TimeTo_Trigger_SCell_RelSsbRsrp=TimeToTrigger_ms2560

${GNB_PARAM}
...                          bwp_profile_id=54 bwp_profile_type=dedicated act_multiple_dedicated_bwps=no location_bw_ul=1:0 location_bw_dl=1:1
...                          Inter_gNB_CA_Allowed=yes CellLoadReportingPeriodicity=000

${GNB_CELL_PARAM}            Cell_BWP_List=3,4,5,6 cell_Available=yes weightForSCellSelection=50 lteNrDssMode=lteNrDssModeNone

${EGATE_CONSOLE_LOG}         /opt/iphy/latest/egate_console.log
${EXT_GNB_UE_ID}             1
${EXT_GNB_ID}                4
${UE_ID_IGNB_CA}             10
${UE_ID_NSA_MOBILITY_CA}     14

${2cc_dl_1cc_ul_nsa_ca}      SEPARATOR=ue_nr_capabilities=39F30C7942C0E070F09FD8000007F60000007400001C0A83E236B04610D04083C4220032B64C55890E7D813E2
...                          38F1891C790E7D473E618F28581C0E1E13F8000000FE0000000E800003800AA0711810000048150705007118000008481587850001846000104815
...                          8385010000C041D61E1400060A00008020E00602340281D80007205813B639F0E14E9DB1CF870A24ED8E7C38113639F0E1449DB1CF8600A0583D08
...                          C000F000A070500703009401C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A0080040100
...                          40100000C0080000700400200000008000080040000480200100C030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD6
...                          52D64CD602D606D6025604560ED0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040001E59
...                          4901000089652404000265949010000A96524040002E5949410000C96524040000C594900C52AABA55554AA2E95455058AA071541A2A94C55268AA0
...                          31540A2A93555078A1E005E02540A05028140A05028140A05028140A05028140A05000400080F00C101002000040300608080100402018000004060
...                          0208080100402004000D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A08350

${ue_eutra_nr_capabilities}  SEPARATOR=A11FF82382C0C0388C00000004440B84C0C030500711800000848881709818061300E23000002091102E130300E23000606000061222
...                          04024046805101320208182100001B41214E9DBFFFB7127449DBFFFB7127449DBFFFB7127449DBFFFB602006100008040403006100004020200400
...                          0080600C2000080404008000100C01840001008080600C02018000

*** Keywords ***

Prepare TL for CB009267
    Sqd65 Common Setup
    Fetch Nidd Version From SCF File
    Activating CB009267 Feature Flag
    Bring Airphone TL to on Air status     cfg_file=basic_setup.cfg
    Setup X2 Links
    ${SW_BRANCH}=       testline.Get gNB SW Branch
    Set Suite Variable  ${SW_BRANCH}
    Prepare Inter gNB CA

Reconfigure TL for CB009267-A_EI_B101_2
    Create Testcase Log Directory
    ${log_dir}=                Get Testcase Log Directory
    ${SCF_TC_Setup}=    Get SCF from gNB  target_dir=${log_dir}  scf_name=before.xml
    Set Suite Variable  ${SCF_TC_Setup}
    Prepare WTS Config
    Update iphy file for A_EI_B101_2
    Apply Configs for A_EI_B101_2    test_instance=A_EI_B101_2
    Bring Airphone TL to on Air status    cfg_file=basic_setup_9267-A_EI_B101_2.cfg
    Start Logging    pmcounter_enabled=${FALSE}

Perform Preconditions of Test Scenario
    Create Testcase Log Directory
    IF      '${PREV_TEST_STATUS}'=='FAIL'
    ...                 Perform Preconditions of Test Scenario in Case of Previous TC failed
    Start Logging       pmcounter_enabled=${FALSE}
    ${log_dir}=         Get Testcase Log Directory
    ${SCF_TC_Setup}=    Get SCF from gNB  target_dir=${log_dir}  scf_name=before.xml
    Set Suite Variable  ${SCF_TC_Setup}
    Smf Param Reset

Perform Preconditions of Test Scenario in Case of Previous TC failed
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone
    Bring Airphone TL to on Air status
    Set Suite Variable  ${EXT_GNB_UE_ID}  1
    Setup X2 Links
    Prepare Inter gNB CA

Perform Postconditions of Test Case
    run_keyword_and_warn_on_failure    Stop logging
    Run Keyword and Ignore Error       Stop Data transfer and Deregister UE  ue_id=${UE_ID_IGNB_CA}
    Run Keyword and Ignore Error       Detach UE from LTE                    ue_id=${UE_ID_NSA_MOBILITY_CA}
    IF  '${TEST_MODE}' == 'auto' and '${TEST_STATUS}' == 'FAIL'
        Collect AP Sos Report and Snapshots
    END
    Revert Delta Commissioning

Reconfigure TL back to Default Config for CB009267-A_EI_B101_2
    run_keyword_and_warn_on_failure    Stop logging
    IF  '${TEST_MODE}' == 'auto'
        Collect AP Sos Report and Snapshots
    END
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone
    Reload original iphy file
    Revert Delta Commissioning
    Bring Airphone TL to on Air status

Revert Delta Commissioning
    ${log_dir}=                Get Testcase Log Directory
    ${curr_scf}=               Get SCF from gNB  target_dir=${log_dir}  scf_name=after.xml
    ${revert_file}=            Set Variable  ${log_dir}/revert.json
    scf.calculate_delta_scf    ${SCF_TC_Setup}  ${curr_scf}  ${revert_file}
    Config gNB with delta scf  ${revert_file}

Setup for CB009267-D_EI_B3
    [Documentation]    Change location of UE2 to UE6 to camp on Cell-1
    Perform Preconditions of Test Scenario
    FOR    ${ue_id}    IN RANGE    2   7
        Relocate UE to different cell   ue_id=${ue_id}  cell_id=1
    END

Teardown for CB009267-D_EI_B3
    [Documentation]    Change location of UE2 to UE6 to camp on Cell-2 to Cell-6, respectively
    Perform Postconditions of Test Case
    FOR    ${ue_id}    IN RANGE    2   7
        Relocate UE to different cell   ue_id=${ue_id}  cell_id=${ue_id}
    END

Fetch Nidd Version From SCF File
    [Documentation]    This keyword fetches the NIDD version of NRBTS from current SCF file and create a suite variable with this NIDD version
    [Arguments]
    ${scf_file}=         Get File    ${P_ORIG_SCF}
    ${nrbts_nidd_ver}=	 Get Lines Containing String       ${scf_file}	    com.nokia.srbts.nrbts:NRBTS
    ${nrbts_nidd_list}   Split String      ${nrbts_nidd_ver}     "
    ${NIDD_VERSION}=     Evaluate    "${nrbts_nidd_list}[5]".replace("'", "")
    Set Suite Variable   ${NIDD_VERSION}

Attach UEs to LTE and Trigger LTE-NR Dual connectivity
    [Documentation]    Attach UEs to LTE and trigger dual connectivity
    [Arguments]    ${ue_1}   ${ue_2}
    ${ue_list}=   Create List   ${ue_1}   ${ue_2}
    FOR  ${ue}   IN   @{ue_list}
        Attach UE to LTE  ue_id=${ue}
        Trigger LTE-NR dual connectivity for bearers    ue_id=${ue}  target_cells=4
    END

Register and Establish PDU Session
    [Documentation]    Register and establish PDU Session
    [Arguments]    ${ue_id}  ${pass_regexp}=Initial Context Setup Successful
    UE Register  ue_id=${ue_id}
    Set traffic type  ue_id=${ue_id}  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=${ue_id}  pdu=1  gw=${ue_id}  pass_regexp=${pass_regexp}
    Sleep  5s

Register and Establish PDU Session with modified UE Capability
    [Documentation]    Register and establish PDU Session with modified UE Capability
    [Arguments]    ${ue_id}   ${ue_nr_capabilities}
    UE Register  ue_id=${ue_id}  ue_nr_capabilities=${ue_nr_capabilities}
    Set traffic type  ue_id=${ue_id}  pdu_id=1  trf_type=internal
    UE PDU Session Setup  ue_id=${ue_id}  pdu=1  gw=${ue_id}

Register and Establish PDU Session and calculate UE CA Configuration time
    [Documentation]    Register and establish PDU Session and calculate UE CA Configuration time
    [Arguments]    ${ue_id}
    Register and Establish PDU Session  ue_id=${ue_id}
    Calculating UE CA Configuration time  ue_id=${ue_id}

Register and Establish PDU Session with modified UE Capability and calculate UE CA Configuration time
    [Documentation]    Register and establish PDU Session with modified UE Capability and calculate UE CA Configuration time
    [Arguments]    ${ue_id}   ${ue_nr_capabilities}
    Register and Establish PDU Session with modified UE Capability  ue_id=${ue_id}  ue_nr_capabilities=${ue_nr_capabilities}
    Calculating UE CA Configuration time  ue_id=${ue_id}

Deregister the UE and calculate UE CA active duration
    [Documentation]    Deregister the UE and calculate the UE CA active druation.
    [Arguments]    ${ue_id}
    UE Deregister  ue_id=${ue_id}
    Calculating UE CA Release time  ue_id=${ue_id}
    Calculating UE CA active duration  ue_id=${ue_id}

Calculating UE CA Configuration time
    [Documentation]    Calculating UE CA configuration time in PDU session setup.
    [Arguments]    ${ue_id}
    ${current_time}   Builtin.Get Time  format=epoch
    Set Test Variable    ${UE${ue_id}_CA_CONFIGURATION_TIME}    ${current_time}

Calculating UE CA Release time
    [Documentation]    Calculating UE CA release time in UE deregistration/UE context release.
    [Arguments]    ${ue_id}
    ${current_time}   Builtin.Get Time  format=epoch
    Set Test Variable    ${UE${ue_id}_CA_RELEASE_TIME}    ${current_time}

Calculating UE CA active duration
    [Documentation]    Calculating UE CA active duration in seconds.
    [Arguments]    ${ue_id}
    ${duration_seconds}=  Evaluate  ${UE${ue_id}_CA_RELEASE_TIME}-${UE${ue_id}_CA_CONFIGURATION_TIME}
    Set Test Variable    ${UE${ue_id}_CA_ACTIVE_DURATION}    ${duration_seconds}

Relocate UE to different cell
    [Documentation]    Change location of UE to camp on a different cell
    [Arguments]  ${ue_id}=1  ${cell_id}=1
    Send Egate Command and verify output   cmd=ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    ...                                    pass_regexp=(location updated to eNB-2 cell ${cell_id})|(already there)

Start SA Data Traffic in egate on multiple UEs and Traffic IDs
    [Documentation]   Starting SA Data Traffic in Egate on multiple UEs and traffic IDs
    [Arguments]   ${ue_id_range_min}   ${ue_id_range_max}  ${trf_id_range_min}  ${trf_id_range_max}  ${direction}  ${mbps}=175  ${qfi}=1  ${pdu}=1
    FOR    ${ue_id}    IN RANGE    ${ue_id_range_min}   ${${ue_id_range_max}+1}
           Start SA Data Traffic in Egate on multiple Traffic IDs   ue_id=${ue_id}   mbps=${mbps}  qfi=${qfi}  pdu=${pdu}  direction=${direction}
           ...   trf_id_range_min=${trf_id_range_min}   trf_id_range_max=${trf_id_range_max}
    END

Start SA Data Traffic in Egate on multiple Traffic IDs
    [Documentation]   Starting SA Data Traffic in Egate on multiple traffic IDs
    [Arguments]      ${ue_id}  ${trf_id_range_min}  ${trf_id_range_max}  ${direction}  ${mbps}=50  ${qfi}=1  ${pdu}=1
    FOR    ${trf_id}    IN RANGE    ${trf_id_range_min}   ${${trf_id_range_max}+1}
           Start data traffic in egate   ue_id=${ue_id}  direction=${direction}  mbps=${mbps}  trf_id=${trf_id}  pdu=${pdu}  qfi=${qfi}
    END

Start NSA Data Traffic in egate on multiple UEs and Traffic IDs
    [Documentation]   Starting NSA Data Traffic in Egate on multiple UEs and traffic IDs
    [Arguments]       ${ue_id_range_min}   ${ue_id_range_max}  ${trf_id_range_min}  ${trf_id_range_max}  ${direction}  ${mbps}=175  ${id}=2
    FOR    ${ue_id}    IN RANGE    ${ue_id_range_min}   ${${ue_id_range_max}+1}
           Start NSA Data Traffic in Egate on multiple Traffic IDs   ue_id=${ue_id}   mbps=${mbps}  id=${id}  direction=${direction}
           ...   trf_id_range_min=${trf_id_range_min}   trf_id_range_max=${trf_id_range_max}
    END

Start NSA Data Traffic in Egate on multiple Traffic IDs
    [Documentation]   Starting NSA Data Traffic in Egate on multiple traffic IDs
    [Arguments]      ${ue_id}  ${trf_id_range_min}  ${trf_id_range_max}  ${direction}  ${mbps}=175  ${id}=2
    FOR    ${trf_id}    IN RANGE    ${trf_id_range_min}   ${${trf_id_range_max}+1}
           Start data traffic in egate   ue_id=${ue_id}  direction=${direction}  mbps=${mbps}  trf_id=${trf_id}  id=${id}
    END

Collect and Verify PM Counters for NSA
    [Arguments]   ${test_instance}  ${pm_collector_alias}=gnb_pm_counters  ${dual_delta_commissioning}=${EMPTY}  ${pscell}=4
    ${pm_files}=   Collect PM Counters  collector_alias=${pm_collector_alias}${dual_delta_commissioning}
    PM Counter Verification  PM_dir=${pm_files}  pcell_list=${${test_instance}_PM_PSCELL${dual_delta_commissioning}}  pcell=${pscell}

Collect and Verify PM Counters for SA
    [Arguments]   ${test_instance}  ${pm_collector_alias}=gnb_pm_counters  ${dual_delta_commissioning}=${EMPTY}  ${pcell}=1
    ${pm_files}=   Collect PM Counters  collector_alias=${pm_collector_alias}${dual_delta_commissioning}
    PM Counter Verification  PM_dir=${pm_files}  pcell_list=${${test_instance}_PM_PCELL${dual_delta_commissioning}}  pcell=${pcell}

Collect PM counters
    [Arguments]    ${collector_alias}
    ${log_dir}=    testline.Get Testcase Log Directory
    pmcounters.Wait until the current Measurement Period stops
    ${pm_files}=    pmcounters.Collect PM Counter    target_dir=${log_dir}    collector_alias=${collector_alias}
    RETURN  ${pm_files}

PM Counter Verification
    [Documentation]    Verifying PM counters values
    [Arguments]    ${PM_dir}  ${pcell_list}   ${pcell}
    Verify PM Counter Reference Table  reference_table=${pcell_list}   pm_dir=${PM_dir}   distname_suffix=${pcell}

Perform NG Handover and calculate UE CA active duration
    [Arguments]   ${ue_id}  ${pass_regexp}=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Send Measurement Report                meas_id=1 event=A3 srsrp_nr=19 phycell_id=48 nrsrp_nr=100        pass_regexp=${pass_regexp}
    Calculating UE CA Release time  ue_id=${ue_id}
    Calculating UE CA active duration  ue_id=${ue_id}

Send Measurement Report
    [Arguments]    ${measurement}   ${ue_id}=1  ${pass_regexp}=EGATE>
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   cmd=ue_measurement_send_nr ${measurement} id=${ue_id}
    ...                                    pass_regexp=${pass_regexp}
    Sleep   1
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}
    ...                                    pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   set_log flush

Change UE location back to source gNB
    [Arguments]  ${ue_id}=1
    Send Egate Command and verify output   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    ...                                    pass_regexp=(location updated to eNB-2 cell 1)|(already there)

Verify A1 Measurement Event Configured and Confirm that UE is Configured with CA after Sending A1 MR
    [Documentation]    Check whether UE is configured with A1 measurement, then send A1 MR and verify SCell and A1 measurement event configured
    [Arguments]    ${ue_id}
    Verify Measurement ID is configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-4.arfcnSsbPbch}
    Send NR Measurement Report   event=A1  meas_values=srsrp_nr=55  ue_id=${ue_id}  carrier_freq=${NRCELL-4.arfcnSsbPbch}
    Verify Measurement ID is absent   event=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-6.arfcnSsbPbch}
    Set Suite Variable    @{MSG_SEQ_DLUL}   @{MSG_SEQ_DLUL_1}
    Verify SCELL Addition for UE in RRC Reconfiguration  DLUL_CA_cell_configuration=2CC DL CA with Cell-6 as SCell and 2CC UL CA with Cell-6 as SCell
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=${ue_id}  trf_id_range_min=1  trf_id_range_max=3  direction=dl  mbps=175
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=${ue_id}  trf_id_range_min=4  trf_id_range_max=6  direction=ul
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids

Verify A1 Measurement Event Configured and Confirm that SCell Change was Successul at UE after Sending A1 MR
    [Documentation]    Send A1 MR and verify whether SCell change is successful
    [Arguments]    ${ue_id}
    Verify Measurement ID is configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-4.arfcnSsbPbch}
    Send NR Measurement Report   event=A1  meas_values=srsrp_nr=65  ue_id=${ue_id}  carrier_freq=${NRCELL-4.arfcnSsbPbch}
    Verify Measurement ID is absent   event=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-3.arfcnSsbPbch}
    Set Suite Variable    @{MSG_SEQ_DLUL}   @{MSG_SEQ_DLUL_2}
    Verify SCELL Addition for UE in RRC Reconfiguration  DLUL_CA_cell_configuration=2CC DL CA with Cell-3 as SCell and 2CC UL CA with Cell-3 as SCell

Verify A1 Measurement Event Configured and Confirm that UE is Configured with CA & A6 Meas Event after Sending A1 MR
    [Documentation]    Check whether UE is configured with A1 measurement event, then send MR and verify SCell and A6 measurement event configured
    [Arguments]    ${ue_id}
    Verify Measurement ID is configured  event_type=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-4.arfcnSsbPbch}
    Send NR Measurement Report   event=A1  meas_values=srsrp_nr=55  ue_id=${ue_id}  carrier_freq=${NRCELL-4.arfcnSsbPbch}
    Verify Measurement ID is absent   event=A1  ue_id=${ue_id}  carrier_freq=${NRCELL-4.arfcnSsbPbch}
    Set Suite Variable    @{MSG_SEQ_DLUL}   @{MSG_SEQ_DLUL_3}
    Verify SCELL Addition for UE in RRC Reconfiguration  DLUL_CA_cell_configuration=2CC DL CA with Cell-1 as SCell and 2CC UL CA with Cell-1 as SCell
    Verify Measurement ID is configured  event_type=A6  ue_id=${ue_id}  carrier_freq=${NRCELL-1.arfcnSsbPbch}
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=${ue_id}  trf_id_range_min=1  trf_id_range_max=3  direction=dl  mbps=175
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=${ue_id}  trf_id_range_min=4  trf_id_range_max=6  direction=ul
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids

Send A6 MR and Verify that SCell Swap was Successful at UE
    [Documentation]    Send A6 MR and verify whether SCell Swap is successful and UE is configured with A6 again
    [Arguments]    ${ue_id}  ${scell_index}  ${phycell_id}  ${Cell_Id}
    Send NR Measurement Report   event=A6  ue_id=${ue_id}   carrier_freq=${NRCELL-1.arfcnSsbPbch}
    ...   meas_values=scell=${scell_index} scell_rsrp=55 phycell_id=${phycell_id} nrsrp_nr=57
    IF  '${Cell_Id}' == 'Cell-2'
    ...   Set Suite Variable    @{MSG_SEQ_DLUL}   @{MSG_SEQ_DLUL_4}
    ...   ELSE
    ...   Set Suite Variable    @{MSG_SEQ_DLUL}   @{MSG_SEQ_DLUL_5}
    Verify SCELL Addition for UE in RRC Reconfiguration
    ...   DLUL_CA_cell_configuration=2CC DL CA with ${Cell_Id} as SCell and 2CC UL CA with ${Cell_Id} as SCell
    Verify Measurement ID is configured  event_type=A6  ue_id=${ue_id}  carrier_freq=${NRCELL-1.arfcnSsbPbch}

Verify A2 Measurement Event Configured and Confirm that SCell Release was Successul at UE after Sending A2 MR
    [Documentation]    Send A2 MR and verify whether SCell release is successful
    [Arguments]    ${ue_id}  ${carrier_freq}=${NRCELL-3.arfcnSsbPbch}  ${scell_index}=2
    Verify Measurement ID is configured  event_type=A2  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    Send NR Measurement Report   event=A2  meas_values=scell=${scell_index} scell_rsrp=30  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    send egate command and verify output    set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{MSG_SEQ_DLUL_RELEASE}

Verify SCELL Addition for UE in RRC Reconfiguration
    [Documentation]    To verify if Scell Additions are configured by gNB for the UE during RRC Reconfiguration.
    [Arguments]    ${DLUL_CA_cell_configuration}
    Verify DL and UL SCELL Addition  DLUL_CA_cell_configuration=${DLUL_CA_cell_configuration}

Verify DL and UL SCELL Addition
    [Documentation]    List @{MSG_SEQ_DLUL} must be defined in subfeature suite variable.
    [Arguments]    ${DLUL_CA_cell_configuration}
    send egate command and verify output    set_log flush
    Verify sequence in Egate file  ${EGATE_CONSOLE_LOG}  @{MSG_SEQ_DLUL}
    Log    The gNB configures the UE with ${DLUL_CA_cell_configuration}.
    ...        console=${P_console}

Stop Data transfer and Deregister UE
    [Documentation]    Common keyword to stop data transfer and deregister UEs
    [Arguments]    ${ue_id}
    FOR  ${trf_id}   IN   1  2  3
        Stop data traffic in egate  ue_id=${ue_id}  direction=dl  trf_id=${trf_id}
    END
    FOR  ${trf_id}   IN   4  5  6
        Stop data traffic in egate  ue_id=${ue_id}  direction=ul  trf_id=${trf_id}
    END
    UE Deregister  ue_id=${ue_id}  ue_deregister_type=switch_off

Prepare WTS Config
    [Documentation]    Reconfigure basic_setup.cfg file to change the ARFCN and GSCN of Cell_2 to match the frequency of Cell_1 only for the test
    ...   instance A_EI_B101_2
    ${WTS_CFG_FILE}=             Set Variable   ${tl.core.dir_path}/basic_setup_9267-A_EI_B101_2.cfg
    wts_conf.load_wts_cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_conf.modify              command=set_cell id=2     modification=nr_arfcn=519000:519000 gscn=6486
    wts_conf.save_wts_cfg        ${WTS_CFG_FILE}
    ${tc_conf_dir}               testline.Get Testcase Log Directory
    Copy File                    ${WTS_CFG_FILE}  ${tc_conf_dir}

Update iphy file for A_EI_B101_2
    [Documentation]    Reconfigure iphy.xml file to change the GSCN of Cell_2 to match the GSCN of Cell_1 only for the test instance A_EI_B101_2
    ${tc_conf_dir}       testline.Get Testcase Log Directory
    ${ap_alias}          Connect to Airphone Common Unit
    ssh.execute          cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ap_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml        ${tc_conf_dir}/new_iphy.xml           connection=${ap_alias}
    ${contents}          Get File          ${tc_conf_dir}/new_iphy.xml
    ${all_parts}         Split String      ${contents}     </vcell>
    ${update}            Replace String Using Regexp    ${all_parts}[1]      GSCN>.*<\/GSCN>   GSCN>6486<\/GSCN>
    ${new contents}      catenate         SEPARATOR=</vcell>   ${all_parts}[0]  ${update}  ${all_parts}[2]  ${all_parts}[3]  ${all_parts}[4]
    ...   ${all_parts}[5]  ${all_parts}[6]
    Create File          ${tc_conf_dir}/new_iphy_A_EI_B101_2.xml    ${new contents}
    ssh.Upload File      ${tc_conf_dir}/new_iphy_A_EI_B101_2.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}

Reload original iphy file
    [Documentation]    Reconfigure iphy.xml file to revert the GSCN of Cell_2 which was changed for the test instance A_EI_B101_2
    ${ap_alias}          Connect to Airphone Common Unit
    ssh.execute          cp /ffs/run/simmode/new_iphy_orig.xml /ffs/run/simmode/new_iphy.xml    connection=${ap_alias}

Send UE Assistance for overheating Egate command and verify SCells release in seperate RRC Reconfiguration message
    [Documentation]    UE triggers overheating assistance procedure, then gNB suspends/deactivates the data at all SCells for duration configured for
    ...                sCellInactivityReleaseTimer(10s), then gNB releases all SCells in seperate RRC recinfiguration messages.
    [Arguments]    ${ue_id}
    Send Egate Command and verify output   cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=0
    Sleep   12s  reason=wait for the sCellInactivityReleaseTimer(10s) to expire
    send egate command and verify output    set_log flush
    Sleep   1s  reason=waiting before fetching the log file, else missing some contents in the log file
    ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
    ${pattern_scell1}=          Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+1\\n\\s+}\\n
    ${pattern_scell2}=          Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+2\\n\\s+}\\n
    ${scell_rel_oh_pattern}=    Set Variable  .*overheatingAssistanceConfig release : NULL
    ${scell1_release}=          Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_scell1}
    ${scell2_release}=          Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_scell2}
    ${scell_release_oh}=        Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${scell_rel_oh_pattern}
    IF   ${scell_release_oh} and ${scell1_release} and ${scell2_release}
    ...    Log    The gNB Released both SCells due to overheating at UE in seperate RRC Reconfiguration messages.
    ...    ELSE   Fail   The gNB does not release both SCells due to overheating at UE in seperate RRC Reconfiguration messages.

Verify SCELL Addition for UE in RRC Reconfiguration after the expiry of CA backoff timer for UE overheating
    [Documentation]    After the SCells release is triggered due to UE overheating, and after the expriration of caBackoffTimerUeOh=60s, verify that
    ...                gNB again activates both the SCells in UE with CA in a RRC Reconfiguration message.
    [Arguments]    ${DLUL_CA_cell_configuration}
    Sleep   60s  reason=wait for the caBackoffTimerUeOh(60s) to expire
    Verify SCELL Addition for UE in RRC Reconfiguration     DLUL_CA_cell_configuration=${DLUL_CA_cell_configuration}

Modify UE PDU Session to add Incompatible DRB and verify SCells release in one RRC Reconfiguration message
    [Documentation]    UE PDU Session is modified to add Incompatible DRB (NRDRB-13), then gNB releases all SCells in one RRC reconfiguration
    ...                message.
    [Arguments]    ${ue_id}
    UE PDU Session Modify   ue_id=${ue_id}  pdu=1  qos_flow_list=@{pdu_qos_list_A_EI_B201-2_1}  by=amf
    send egate command and verify output    set_log flush
    Sleep   1s  reason=waiting before fetching the log file, else missing some contents in the log file
    ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
    ${pattern_both_scells}=     Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+1,\\n\\s+2\\n\\s+}\\n
    ${both_scells_release}=     Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_both_scells}
    IF   ${both_scells_release}
    ...    Log    The gNB Released both SCells due to Incompatible DRB in one RRC Reconfiguration message.
    ...    ELSE   Fail   The gNB does not release both SCells due to Incompatible DRB in one RRC Reconfiguration message.

Modify UE PDU Session to delete default FR1 CA eligible DRB and verify SCells release in one RRC Reconfiguration message
    [Documentation]    UE PDU Session is modified to delete default FR1 CA eligible DRB (NRDRB-11), then gNB releases all SCells in one
    ...                RRC reconfiguration message due to one Non Eligible DRB remaining.
    [Arguments]    ${ue_id}
    Deleting QOS Flow in PDU Session   ue_id=${ue_id}  pdu=1  qosflows_to_del=2  by=amf  pass_regexp=Pdu Session Resource Modify.*successfully
    send egate command and verify output    set_log flush
    Sleep   1s  reason=waiting before fetching the log file, else missing some contents in the log file
    ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
    ${pattern_both_scells}=     Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+1,\\n\\s+2\\n\\s+}\\n
    ${both_scells_release}=     Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_both_scells}
    IF   ${both_scells_release}
    ...    Log    The gNB Released both SCells due to releasing the last CA-eligible DRB in one RRC Reconfiguration message.
    ...    ELSE   Fail   The gNB does not release both SCells due to releasing the last CA-eligible DRB in one RRC Reconfiguration message.

Modify UE PDU Session to add two HR DRBs and verify SCells release in one RRC Reconfiguration message
    [Documentation]    UE PDU Session is modified to add two HR nonGBR DRBs (NRDRB-12 and NRDRB-14), then gNB releases all SCells in one RRC
    ...                reconfiguration message since High-Reliability functionality isn't active in one SCell (Cell-5).
    [Arguments]    ${ue_id}
    UE PDU Session Modify   ue_id=${ue_id}  pdu=1  qos_flow_list=@{pdu_qos_list_A_EI_B201-3}  by=amf
    send egate command and verify output    set_log flush
    Sleep   1s  reason=waiting before fetching the log file, else missing some contents in the log file
    ${log_content}=    Get File    ${EGATE_CONSOLE_LOG}
    ${pattern_both_scells}=     Set Variable  sCellToReleaseList\\s\\n\\s+{\\n\\s+1,\\n\\s+2\\n\\s+}\\n
    ${both_scells_release}=     Run Keyword And Return Status   Should Match Regexp     ${log_content}      ${pattern_both_scells}
    IF   ${both_scells_release}
    ...    Log    The gNB Released both SCells due to HR DRB in one RRC Reconfiguration message.
    ...    ELSE   Fail   The gNB does not release both SCells due to HR DRB in one RRC Reconfiguration message.

Add Additional QOS Flows to Activate
    [Documentation]    Add additional qos flows to activate in addition to default qosflow
    [Arguments]    ${id}  ${additional_qosflows}
    Send Egate Command and verify output
    ...   cmd=smf_param id=${id} additional_qosflows_to_activate=${additional_qosflows}
    Log   Additional QOS flows-${additional_qosflows} added to activate in addition to default qosflow    console=${P_console}

Smf Param Reset
    [Documentation]    Reseting smf parameters to default values
    Send Egate Command and verify output
    ...   cmd=smf_param id=1 reset

Deleting QOS Flow in PDU Session
    [Documentation]    Deleting previous qos flow in pdu session of a UE.
    [Arguments]    ${ue_id}  ${pdu}  ${qosflows_to_del}  ${by}  ${pass_regexp}=${None}
    Send Egate Command and verify output
    ...   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows_to_del} by=${by}   pass_regexp=${pass_regexp}
    Log   ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows_to_del} by=${by}
    ...   console=${P_console}

Prepare Inter gNB CA
    ${IgNBCAProtocolVersions}              Get IgNBCAProtocolVersions
    Send Egate Command And Verify Output   cmd=enb_xp_param xp_peers=2 id=${EXT_GNB_ID}   pass_regexp=XpAP Link with GNB-2 .* is up  timeout=5min
    Send Egate Command And Verify Output   cmd=uec_param id=1 srb_reordering_enabled=on
    Send Egate Command And Verify Output   cmd=gnb_cell_param gnb=${EXT_GNB_ID} id=11 ${GNB_CELL_PARAM}
    Send Egate Command And Verify Output   cmd=gnb_cell_param gnb=${EXT_GNB_ID} id=12 ${GNB_CELL_PARAM}
    Send Egate Command And Verify Output   cmd=gnb_param id=${EXT_GNB_ID} ${GNB_PARAM} ${IgNBCAProtocolVersions}
    Send Egate Command And Verify Output   cmd=ignb_ca_configuration_update_indication_send id=${EXT_GNB_ID} target=2

Get IgNBCAProtocolVersions
    IF  '${SW_BRANCH}' == 'SBTS25R2'
      ${IgNBCAXpProtocolVersion}           Set Variable  43
      ${IgNBCAXgUProtocolVersion}          Set Variable  1
    ELSE IF  '${SW_BRANCH}' == 'SBTS25R3'
      ${IgNBCAXpProtocolVersion}           Set Variable  48
      ${IgNBCAXgUProtocolVersion}          Set Variable  2
    ELSE IF  '${SW_BRANCH}' == 'SBTS26R1'
      ${IgNBCAXpProtocolVersion}           Set Variable  55
      ${IgNBCAXgUProtocolVersion}          Set Variable  2
    ELSE
      ${IgNBCAXpProtocolVersion}           Set Variable  56
      ${IgNBCAXgUProtocolVersion}          Set Variable  2
    END
    RETURN  IgNBCAXgUProtocolVersion=${IgNBCAXgUProtocolVersion} IgNBCAXpProtocolVersion=${IgNBCAXpProtocolVersion}

Inter gNB CA Release
    [Arguments]    ${cause}=unspecified  ${ue_id}=${UE_ID_IGNB_CA}
    IF  '${cause}' == 'A2'
       Send NR Measurement Report             ue_id=${ue_id}  event=A2  meas_values=scell=1  carrier_freq=367970  # gnb_4 cell_1
    ELSE
       Send Egate Command and verify output
       ...              cmd=ignb_ca_release_reqd extGnbId=${EXT_GNB_ID} primeGnbId=2 cause=${cause} ext_gnb_ue_id=${EXT_GNB_UE_ID}
       ...              pass_regexp=rrcReconfigurationComplete
    END
    ${EXT_GNB_UE_ID}                          Evaluate   ${EXT_GNB_UE_ID} + 1
    Set Suite Variable                        ${EXT_GNB_UE_ID}

Set Counter Value
    [Arguments]     ${ref_table}=${A_EI_B202_PM_PCELL}  ${counter}=M55118C11100  ${value}=0
    ${index}=       Get Index From List       ${ref_table}        ${counter}
    Set List Value  ${ref_table}              ${index+2}          ${value}

Register UE and trigger inter gNB CA
    Register and Establish PDU Session     ue_id=${UE_ID_IGNB_CA}
    Start data traffic in egate            ue_id=${UE_ID_IGNB_CA}  direction=dl  mbps=1  trf_id=1  pdu=1  qfi=1
    Sleep                                  5s
    Send NR Measurement Report             ue_id=${UE_ID_IGNB_CA}   event=A1  meas_values=srsrq_nr=70 srsrp_nr=90
    ...                                    carrier_freq=${NRCELL-3.arfcnSsbPbch}
    Sleep                                  5s

Init CA Counters
    [Arguments]    ${table}
    FOR  ${counter}  IN  @{table}
       ${passed}                  Run Keyword and Return Status  Should Start With  ${counter}  M55
       IF  ${passed}  Set Counter Value   ref_table=${table}  counter=${counter}  value=0
    END

Set Counter Values for cfg failures on XDU
    [Arguments]    ${failure_counter}
    Set Counter Value                 ref_table=${A_EI_B3_PM_PCELL}       counter=${failure_counter}  value=1
    Set Counter Value                 ref_table=${SCELL_1_SA}             counter=M55118C11061        value=1  # GNB_DL_SCELL_1_CONFIG_SUCC_SA
    Set Counter Value                 ref_table=${SCELL_2_SA}             counter=M55138C03511        value=1  # GNB_DL_SCELL_2_ADMI_REQ_SA
    Set Counter Value                 ref_table=${SCELL_2_SA}             counter=M55139C05503        value=1  # GNB_DU_DL_SCELL_2_ADMI_REQ_SA
    Set Counter Value                 ref_table=${SCELL_2_SA}             counter=M55138C03518        value=1  # GNB_DL_SCELL_2_ADMI_SUCC_SA
    Set Counter Value                 ref_table=${SCELL_2_SA}             counter=M55118C11052        value=1  # GNB_DL_SCELL_2_CONFIG_REQ_SA

Perform Preconditions for Inter gNB CA
    [Arguments]    ${scenario}=scell_release
    IF  '${scenario}' == 'scell_config_failure'
       Init CA Counters      ${SCELL_1_SA}
    ELSE  # scell_release
       Apply Config for measurement-based Inter gNB CA
    END
    Init CA Counters      ${SCELL_2_SA}
    Init CA Counters      ${A_EI_B202_PM_PCELL}
    Init CA Counters      ${A_EI_B3_PM_PCELL}
    Wait until the next Measurement Period starts

Preconditions for NSA CA Config Failure (NSA Mobility)
    Set MaxNumOfUsersPerCell  num=0  lcrId=1
    Set MaxNumOfUsersPerCell  num=0  lcrId=2

Inter gNB CA Addition Params
    [Arguments]    ${cause}=cell_not_available
    Send Egate Command and verify output   cmd=ignb_ca_addition_param gnb_id=${EXT_GNB_ID} reset
    Send Egate Command and verify output
    ...  cmd=ignb_ca_addition_param gnb_id=${EXT_GNB_ID} DU-to-CU-RRCInfo=${DU-to-CU-RRCInfo} ExtDu-to-PrimeDu-RrcInfo=${ExtDu-to-PrimeDu-RrcInfo}
    Send Egate Command and verify output   cmd=ignb_ca_addition_param gnb_id=${EXT_GNB_ID} ${IGNB_CA_ADDITION_PARAM}
    Send Egate Command and verify output   cmd=ignb_ca_addition_param gnb_id=${EXT_GNB_ID} scell_failed_to_setup=12 scell_failed_cause=${cause}
    Send Egate Command and verify output   cmd=ignb_ca_configuration_update_indication_send id=${EXT_GNB_ID} target=2

Inter gNB CA Counter Verification
    Wait Until The Current Measurement Period Stops
    ${pm_files}=                           Collect PM Counter
    Verify PM Counter Reference Table      reference_table=${SCELL_1_SA}           pm_dir=${pm_files}   distname_suffix=3  # PCell inter gNB CA
    Verify PM Counter Reference Table      reference_table=${SCELL_2_SA}           pm_dir=${pm_files}   distname_suffix=3  # PCell inter gNB CA
    Verify PM Counter Reference Table      reference_table=${A_EI_B202_PM_PCELL}   pm_dir=${pm_files}   distname_suffix=3  # PCell inter gNB CA
    Verify PM Counter Reference Table      reference_table=${A_EI_B3_PM_PCELL}     pm_dir=${pm_files}   distname_suffix=3  # PCell inter gNB CA

Set MaxNumOfCaUsersNRCell
    [Arguments]    ${num}=250  ${lcrid}=3
    ${scf_file}=          Load current SCF
    Set Element           dist_name=MRBTS-1/NRBTS-1/NRCELL-${lcrid}    p_name=maxNumOfCaUsersNRCell       value=${num}
    Apply Delta SCF       ${scf_file}  scf_maxNumOfCaUsers

Set MaxNumOfUsersPerCell
    [Arguments]    ${num}=275  ${lcrId}=3
    ${scf_file}=          Load current SCF
    Set Element           dist_name=MRBTS-1/NRBTS-1/NRCELL-${lcrId}    p_name=maxNumOfUsersPerCell       value=${num}
    Apply Delta SCF       ${scf_file}  scf_maxNumOfUsers

Set FreqBandIndicatorNR
    [Arguments]    ${freqBandIndicatorNR}=4
    ${scf_file}=          Load current SCF
    Set Element           dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-2    p_name=freqBandIndicatorNR       value=${freqBandIndicatorNR}
    Set Element           dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-3    p_name=freqBandIndicatorNR       value=${freqBandIndicatorNR}
    Apply Delta SCF       ${scf_file}  scf_freqBandIndicatorNR

Intra SgNB Triggered HO
    [Arguments]  ${ue_id}=${UE_ID_NSA_MOBILITY_CA}
    Send Egate Command and verify output   cmd=ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    Sleep  2s
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}   pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2
    ...                                    pass_regexp=SgNBModificationConfirm
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}   pass_regexp=NR MEASUREMENT IDENTITIES:
    Sleep  2s
    Send Egate Command and verify output
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=3 event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=53 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=SgNBModificationConfirm
    Send Egate Command and verify output   cmd=ue_disp id=${ue_id}

Inter SgNB Mobility
    [Arguments]  ${ue_id}=${UE_ID_NSA_MOBILITY_CA}
    Sleep  2s
    Send Egate Command and verify output   cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=NR MEASUREMENT IDENTITIES:
    Send Egate Command and verify output
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=13 event=A3 srsrp_nr=50 phycell_id=53 nrsrp_nr=70
    ...    pass_regexp=Inter Sgnb Handover is successful
    Send Egate Command and verify output   cmd=ue_disp id=${ue_id}

Intra MeNB Handover
    [Arguments]  ${ue_id}=${UE_ID_NSA_MOBILITY_CA}
    Send Egate Command and verify output   cmd=enb_endc_param id=1 include_cgi_in_candidate_cell_info=on
    Sleep  1s
    Send Egate Command and verify output   cmd=enb_endc_param id=1 allowed_bc_list_mrdc=1:1|2:1
    Sleep  1s
    Send Egate Command and verify output   cmd=enb_cell_param enb=1 id=2 allow_endc=on
    Sleep  1s
    Send Egate Command and verify output   cmd=ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=0926DA802190
    Sleep  1s
    Send Egate Command and verify output   cmd=ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=1 cell=2
    ...                                    pass_regexp=Intra-eNB handover from ENB-1.1 to ENB-1.2 performed

Setup X2 Links
   Send Egate Command and verify output    cmd=enb_x2_link_up enb=1 target=2   pass_regexp=X2AP Link .* is up
   Send Egate Command and verify output    cmd=enb_x2_link_up enb=1 target=3   pass_regexp=X2AP Link .* is up

NSA CA Config Failure (NSA Mobility) Counter Verification
    Wait Until The Current Measurement Period Stops
    ${pm_files}=                           Collect PM Counter
    Verify PM Counter Reference Table      reference_table=${SCELL_1_NSA}    pm_dir=${pm_files}   distname_suffix=4  # PCell NSA Mobility

Set Counter Value for 9267-D
    [Documentation]    Changing the upper limit: 'value' of PM Counter: 'counter' in the reference table: 'ref_table'.
    [Arguments]      ${ref_table}  ${counter}  ${value}
    ${index1}=       Get Index From List       ${ref_table}        ${counter}
    ${index2}=       Get Index From List       ${ref_table}        ${counter}       start=${index1+1}
    Set List Value   ${ref_table}              ${index2+2}         ${value}

Set Counter Values for 9267-D_EI_B3_1
    ${M55114C01563_upper_limit}=    Evaluate  ${UE9_CA_ACTIVE_DURATION} + 6
    Set Counter Value for 9267-D    ref_table=${D_EI_B3_1_PM_PCELL}   counter=M55114C01563     value=${M55114C01563_upper_limit}
    ${M55114C01564_upper_limit}=    Evaluate  ${UE8_CA_ACTIVE_DURATION} + 6
    Set Counter Value for 9267-D    ref_table=${D_EI_B3_1_PM_PCELL}   counter=M55114C01564   value=${M55114C01564_upper_limit}
    ${M55114C01567_upper_limit}=    Evaluate  ${UE1_CA_ACTIVE_DURATION} + ${UE2_CA_ACTIVE_DURATION} + 12
    Set Counter Value for 9267-D    ref_table=${D_EI_B3_1_PM_PCELL}   counter=M55114C01567   value=${M55114C01567_upper_limit}
    ${M55114C01571_upper_limit}=    Evaluate  ${UE8_CA_ACTIVE_DURATION} + ${UE9_CA_ACTIVE_DURATION} + 12
    Set Counter Value for 9267-D    ref_table=${D_EI_B3_1_PM_PCELL}   counter=M55114C01571   value=${M55114C01571_upper_limit}
    ${M55114C01572_upper_limit}=    Evaluate  ${UE1_CA_ACTIVE_DURATION} + ${UE2_CA_ACTIVE_DURATION} + 12
    Set Counter Value for 9267-D    ref_table=${D_EI_B3_1_PM_PCELL}   counter=M55114C01572   value=${M55114C01572_upper_limit}

Set Counter Values for 9267-D_EI_B2_1
    ${M55118C00090_upper_limit}=    Evaluate  ${UE1_CA_ACTIVE_DURATION} + 5 + 2  # 5s sleep in pdu session setup KW, 2s for processing egate ouput
    Set Counter Value for 9267-D    ref_table=${D_EI_B2_1_PM_PCELL}   counter=M55118C00090     value=${M55118C00090_upper_limit}
    ${M55118C00094_upper_limit}=    Evaluate  ${UE1_CA_ACTIVE_DURATION} + 5 + 2
    Set Counter Value for 9267-D    ref_table=${D_EI_B2_1_PM_PCELL}   counter=M55118C00094     value=${M55118C00094_upper_limit}

Set Counter Values for 9267-D_EI_B2_4
    ${M55118C00090_upper_limit}=    Evaluate  ${UE1_CA_ACTIVE_DURATION} + 6
    Set Counter Value for 9267-D    ref_table=${D_EI_B2_4_PM_PCELL}   counter=M55118C00090     value=${M55118C00090_upper_limit}
    ${M55118C00094_upper_limit}=    Evaluate  ${UE1_CA_ACTIVE_DURATION} + 6
    Set Counter Value for 9267-D    ref_table=${D_EI_B2_4_PM_PCELL}   counter=M55118C00094     value=${M55118C00094_upper_limit}
