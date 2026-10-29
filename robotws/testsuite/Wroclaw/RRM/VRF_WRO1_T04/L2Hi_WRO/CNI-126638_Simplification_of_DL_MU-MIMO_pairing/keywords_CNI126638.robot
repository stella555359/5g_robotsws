*** Settings ***
Documentation    Keywords for CNI126638

Library     taf.ul.ettf.setups
Library     taf.sbts.oam.coam.admin    WITH NAME   COAM
Library     ta5g_pm_counters
Library     taf.collectors.snapshot      WITH NAME    snapshot
Library     testsuite.Wroclaw.RRM.VRF_WRO1_T04.resources.Tokens
Resource    ../resources_kr/robot/collectors.robot


*** Variables ***
${UE_pos_1}      init_quad_pos=0 init_sub_quad_pos=0 trigger_puxch_update=0
${UE_pos_2}      init_quad_pos=1 init_sub_quad_pos=0 trigger_puxch_update=0
${UE_pos_3}      init_quad_pos=2 init_sub_quad_pos=0 trigger_puxch_update=0
${UE_pos_4}      init_quad_pos=3 init_sub_quad_pos=0 trigger_puxch_update=0
${ARTIFACTORY_ROTTA}      https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local
${download_path}          ${ARTIFACTORY_ROTTA}/waczynsk/BSR/BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
${BSR_FILENAME}    BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip

*** Keywords ***
Attach Multiple Ues
    [Arguments]    ${num_of_ues}=${4}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Set Internal Traffic Type To UEs    ue_id=${ue_id}    pdu_id=1
        Register Ue With Default Pdu Session    ue_id=${ue_id}     pdu_id=1    gw=${ue_id}
    END


Start Udp Traffic 450Mbps In DL For All Ues
    Execute Egate Command    cmd=sim_debug_log level=6
    [Arguments]    ${num_of_ues}=${4}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
    END

Stop Traffic For All Ues
    Execute Egate Command    cmd=sim_debug_log level=6
    [Arguments]    ${num_of_ues}=${4}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl
    END

Check Data Traffic
    [Arguments]    ${num_of_ues}=${4}
    Sleep    ${TRAFFIC_DURATION_SEC}
    FOR    ${ue_id}    IN RANGE    ${1}    ${num_of_ues}+${1}
        Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id}
    END


Prepare Testmode For Ue Position
      Execute Egate Command    cmd=ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed test_type=SRS ${UE_pos_1}
      Execute Egate Command    cmd=ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed test_type=SRS ${UE_pos_2}
      Execute Egate Command    cmd=ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed test_type=SRS ${UE_pos_3}
      Execute Egate Command    cmd=ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed test_type=SRS ${UE_pos_4}

Activate Testmode For Ue Position
      Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
      Execute Egate Command    cmd=ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2
      Execute Egate Command    cmd=ue_testmode_set_nr id=3 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3
      Execute Egate Command    cmd=ue_testmode_set_nr id=4 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4

Moving UE to bad coverage area
    Execute Egate Command    cmd=bler_testmode_nr profile_id=6 target_mcs=1 num_dl_pkts=10000
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=bler action=activate profile_id=1

Change RI to 1
    Execute Egate Command    cmd=csi_override_testmode_nr profile_id=5 cqi=15 ri=0
    Execute Egate Command    cmd=ue_testmode_set_nr id=1-4 testmode=csi_override action=activate profile_id=5 scell=0
    Send Delta Commissioning    input_filepath=${CURDIR}/config/delta_dlMuMimoCorrThd_33.json

Get and Update BSR File
     [Arguments]  ${download_path}=${download_path}    ${bsr_file_path}=${OUTPUTDIR}/${BSR_FILENAME}
     ${token}=   get_ca_ute_artifactory_token
     Run  sudo wget -d --header='Authorization:Bearer ${token}' ${download_path} -O ${bsr_file_path}
     COAM.setup admin
     ${ret}     COAM.Update Software      ${bsr_file_path}
     COAM.teardown admin


Stop and convert TTI trace collection
    [Arguments]  ${directory_name}=${TESTNAME}/TtiTraces  ${conversion_filter}=None  ${format}=excelCsv  ${delay}=5
    Log    Consversion filter=${conversion_filter} and fortmat=${format} are not used in this method.
    ${parent_directory}  Set variable  ${directory_name}
    Set Test Variable  ${parent_directory}
    Stop TTI trace  target_dir=${OUTPUTDIR}/${parent_directory}  delay=${delay}
#    Convert TTI trace pcap
#    ...  input=${OUTPUTDIR}/${parent_directory}/l2stream3/tcpdump/tcpdump.pcap
#    ...  output=${OUTPUTDIR}/${parent_directory}/output
#    ...  conversion_filter=${conversion_filter}
#    ...  format=${format}

Collect L2PS TTI Trace
    [Arguments]  ${directory_name}=TTI
    Start TTI trace
    Stop and convert TTI trace collection      directory_name=${directory_name}

Collect Pm Counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File

Collect snapshot from gNB
    [Documentation]    collect snapshot from gnb
    ...     :param target_dir: directory to save snapshot
    ...     :param gnb_id: (default=0) Id/Number of gNB
    [Arguments]    ${target_dir}=${None}    ${snapshot_name}=gnb_snapshot   ${gnb_id}=${0}

    ${webservice}=  Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...    port=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}
    snapshot.create_sbts_snapshot_collector
    ...    name=${snapshot_name}
    ...    webservice=${webservice}
    ...    coverage=Full
    ...    force=0
    ...    timeout=600
    snapshot.setup_collectors
    ...    names=${snapshot_name}
    snapshot.collect_collectors
    ...    names=${snapshot_name}
    ...    target_dir=${target_dir}
    snapshot.teardown_collectors
    ...    names=${snapshot_name}
