*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R3    SBTS23R2    SBTS23R1    CONFIGURED

Documentation    :copyright: Nokia
...              :authors:Prasanta
...         CB008954 feature testing scenarios

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
#...                 AND     update_gscn    ${IPHY_FILE}    50     7859
...                 AND     update_gscn    ${IPHY_FILE}    51     6510
#...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}    frag=${1}
...                 AND     Modify IPHY File And Send to Airphone    ${IPHY_FILE}
...                 AND     Add RD Parameters To GNB Swconfig File     ${RD_PARAM_8124}
#...                 AND     Find Scfc And Fix And Send Full Commissioning
#...                         scfc_filename=both_edge_blank.xml
...                 AND    Perform SCF Delta Commissioning with 20_40_60_100_prb_blank_10.json
...                 AND     sleep    180s
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    180s
...                 AND     Load CFG Config     ${wts_cfg_file}
...                 AND     Check gNB Bulid


Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
#${wts_cfg_file}      ${CURDIR}/config/wts/basic_setup_APoABIO_32_UEs_60_80_100.cfg
#${wts_cfg_file}      ${CURDIR}/config/wts/xx.cfg
${wts_cfg_file}      ${CURDIR}/config/wts/60-80-100_copy.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${largebwp_id}   1
${smallbwp_id}   2
${psbwp_id}     3
${epc_log_path}    /tmp/
${TEST_NAME}            Cell_setup
${IPHY_FILE}                    ${CURDIR}/config/wts/iphy_tmo.xml
*** Test Cases ***
[1]CB008954_C_IWK_7_2_Activation_of_3_BWPs_aligned_at_the_bottom_of_the_5G_cell_with_PRB_blanking_CB009915_CB006878_5GC00937_CB008941_enabled
    [Documentation]   This scenario is to verify the cell setup with 3 dedicated BWPS 80,90,100 MHZ

    ${prbs}    Create List    79    79    160    216
#    Read Dynamic PUSCH     ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    set test variable      ${LOG_PATH}

    Increase Buffer Size for VM and IPHY
    ${small_bwp_rnti}    MultiUE Register should be Successful     ${1}    ${7}
    MultiUE Trigger UL Traffic for SA    ${1}  ${7}  Traffic_rate=mbps     ul_rate=5   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${7}  Traffic_rate=mbps     dl_rate=5   pdu_id=1   trf_id=1   qfi_id=1
    sleep    60s

    Validate UL Traffic For MultiUE for SA    1  7     5
    Validate DL Traffic For MultiUE for SA    1  7     5

    ${second_bwp_rnti}    MultiUE Register should be Successful     ${8}    ${15}
    MultiUE Trigger UL Traffic for SA    ${8}  ${15}  Traffic_rate=mbps     ul_rate=5   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${8}  ${15}  Traffic_rate=mbps     dl_rate=5   pdu_id=1   trf_id=1   qfi_id=1

    sleep    60s
    Validate UL Traffic For MultiUE for SA    1    15     5
    Validate DL Traffic For MultiUE for SA    1    15     5


    ${large_bwp_rnti}    MultiUE Register should be Successful     ${16}    ${23}
    MultiUE Trigger UL Traffic for SA    ${16}  ${23}  Traffic_rate=mbps     ul_rate=5   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${16}  ${23}  Traffic_rate=mbps     dl_rate=5   pdu_id=1   trf_id=1   qfi_id=1

    sleep    60s
    Validate UL Traffic For MultiUE for SA    16     23     5
    Validate DL Traffic For MultiUE for SA    16     23     5

    sleep    60s
#    Start Log         ttitrace                         #ADD
    Start TTI_TRACE custom     ${51}

#    sleep     2s
    sleep    1s
    ${scen3}     Stop Log     ttitrace         test_scenario=mix
    Decode TTI Trace   mix
#    ${small_bwp_id}    Set variable    ${3}
#    ${second_bwp_id}   Set Variable    ${2}    # make it invalid
#    ${large_bwp_id}   Set Variable    ${1}
#    ${ps_bwp_id}       Set Variable    ${4}
#    ${small_bwp_size}    Set Variable    ${162}
#    ${second_bwp_size}    Set Variable    ${217}
#    ${large_bwp_size}    Set Variable    ${273}
#    ${blanked_prb_lower}    Set Variable    ${25}
#    ${blanked_prb_upper}    Set Variable    ${30}
    ${small_bwp_id}    Set variable    ${2}
    ${second_bwp_id}   Set Variable    ${3}    # make it invalid
    ${large_bwp_id}   Set Variable    ${4}
    ${ps_bwp_id}       Set Variable    ${1}
    ${small_bwp_size}    Set Variable    ${106}
    ${second_bwp_size}    Set Variable    ${162}
    ${large_bwp_size}    Set Variable    ${273}
    ${blanked_prb_lower}    Set Variable    ${10}
    ${blanked_prb_upper}    Set Variable    ${10}

    ${ret}    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}
    ...     large_bwp_ues=${large_bwp_rnti}
    ...     second_bwp_ues=${second_bwp_rnti}   small_bwp_ues=${small_bwp_rnti}   lower_blanked=${blanked_prb_lower}
    ...     upper_blanked=${blanked_prb_upper}
    should contain    ${ret}     pass
    MultiUE Trigger UL Traffic for SA    ${1}  ${7}  Traffic_rate=kbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${7}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1

    MultiUE Trigger UL Traffic for SA    ${8}  ${15}  Traffic_rate=kbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${8}  ${15}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1

    MultiUE Trigger UL Traffic for SA    ${16}  ${23}  Traffic_rate=kbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${16}  ${23}  Traffic_rate=kbps     dl_rate=10   pdu_id=1   trf_id=1   qfi_id=1
    # All UE should swicth to PS BWP RNTIs
    ${ps_bwp_rntis}   Combine Lists     ${small_bwp_rnti}    ${second_bwp_rnti}
    ...     ${large_bwp_rnti}
    sleep    60s

    Validate UL Traffic For MultiUE for SA    1    15     0.010
    Validate DL Traffic For MultiUE for SA    1    15     0.010
#    Start Log         ttitrace      #ADD
    Start TTI_TRACE custom     ${51}
    sleep    1s
    ${switch}     Stop Log     ttitrace         test_scenario=psbwp
    Decode TTI Trace   psbwp
    ${ret}    validate_bwps    ${switch}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${ps_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${106}    ${second_bwp_size}    ${large_bwp_size}
    ...      small_bwp_ues=${ps_bwp_rntis}
    should contain    ${ret}     pass



    MultiUE Trigger UL Traffic for SA    ${1}  ${7}  Traffic_rate=mbps     ul_rate=4   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${1}  ${7}  Traffic_rate=mbps     dl_rate=5   pdu_id=1   trf_id=1   qfi_id=1

    MultiUE Trigger UL Traffic for SA    ${8}  ${15}  Traffic_rate=mbps     ul_rate=4   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${8}  ${15}  Traffic_rate=mbps     dl_rate=5   pdu_id=1   trf_id=1   qfi_id=1

    MultiUE Trigger UL Traffic for SA    ${16}  ${23}  Traffic_rate=mbps     ul_rate=4   pdu_id=1   trf_id=1   qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${16}  ${23}  Traffic_rate=mbps     dl_rate=5   pdu_id=1   trf_id=1   qfi_id=1
#
    sleep    60s


    Validate UL Traffic For MultiUE for SA    1    23     4
    Validate DL Traffic For MultiUE for SA    1    23     5


#    Start Log         ttitrace       #VDD
    Start TTI_TRACE custom     ${51}
    sleep    1s
    ${switch1}     Stop Log     ttitrace         test_scenario=psbwp_out
    Decode TTI Trace   psbwp_out

    ${ret}    validate_bwps    ${switch1}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_size}
    ...     large_bwp_ues=${large_bwp_rnti}
    ...     second_bwp_ues=${second_bwp_rnti}   small_bwp_ues=${small_bwp_rnti}   lower_blanked=${blanked_prb_lower}
    ...     upper_blanked=${blanked_prb_upper}
    should contain    ${ret}     pass


*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Start TTI_TRACE custom
    [Arguments]    ${cell_id}=${51}
    Common Start Ttitrace With Streaming Mode_3 custom        pysical_cell_ids=${cell_id}

Common Start Ttitrace With Streaming Mode_3 custom
    [Arguments]    ${pysical_cell_ids}=51    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
#    ${nr_phy_cell_ids}=    Common Get PhysCellId Of GNB Runtime
    ${nr_phy_cell_ids}    Create List    ${pysical_cell_ids}
    ${nr_phy_cell_ids}=    Evaluate  map(int, $nr_phy_cell_ids)
    Log Many    ${pysical_cell_ids}       ${nr_phy_cell_ids}
#    ${localIpAddr}=    Get localIpAddr Of GNB
#10.0.1.2 for ute
    ${localIpAddr}=    set variable    10.0.1.2
#    ${web_card}    ${dest_ip}=    Get EIF Info Of Control PC
    ${web_card}    ${dest_ip}=    Common Get EIF Info Of Control PC
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${names}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}
