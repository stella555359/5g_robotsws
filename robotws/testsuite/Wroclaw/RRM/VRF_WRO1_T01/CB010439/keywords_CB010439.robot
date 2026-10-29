*** Settings ***
Documentation    Keywords for CB010439

Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     taf.sbts.oam.coam.admin    WITH NAME   COAM
Library     taf.ul.ettf.setups

*** Variables ***
${ARTIFACTORY_ROTTA}      https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local
${download_path}          ${ARTIFACTORY_ROTTA}/zapatyla/BSR_AQQL_6_H6_ALN60_ARP60_P12_COVERAGE_00808_00002.zip
${BSR_FILENAME}           BSR_AQQL_6_H6_ALN60_ARP60_P12_COVERAGE_00808_00002.zip
${token}                  cmVmdGtuOjAxOjAwMDAwMDAwMDA6dVpkdTMwRjNMMW40VmNRRzd4NjltdlVOQjZh

*** Keywords ***
Proceed With DSS Activation Script
    Log to console  \n*** DSS activation script started ***
    Execute Egate Command    cmd=script file=${CURDIR}/../resources/config/dss_start.cfg
    ...   fail_regexp=DSS_SETUP_FAILURE Not matching cell Ids - NR DSS Setup Req not received yet   timeout=120
    Log to console  \n*** DSS activation script completed ***

Activate XP Link
    Execute egate command    cmd=sim_trace enb=1 protocol=xp
    Sleep  2s
    Execute egate command    cmd=enb_xp_param id=1 xp_listening_socket=on ignore_xp=off
    Sleep  2s
    Execute egate command    cmd=enb_xp_param id=1 xp_peers=2
    Sleep  2s
    Execute egate command    cmd=enb_xp_link_up enb=1 target=2
    Sleep  200s

Get and Update BSR File
     [Arguments]  ${download_path}=${download_path}    ${token}=${token}     ${bsr_file_path}=${OUTPUTDIR}/${BSR_FILENAME}
     Run  sudo wget -d --header='Authorization:Bearer ${token}' ${download_path} -O ${bsr_file_path}
     COAM.setup admin
     ${ret}     COAM.Update Software      ${bsr_file_path}
     COAM.teardown admin

Register Ue With Pdu Session
    [Arguments]    ${ue_id}=1     ${pdu_id}=1
    Execute Egate Command And Wait For Data    cmd=ue_register id=${ue_id}
    ...                      pass_regexp=UE${ue_id}: UE performed Registration type INITIAL_REGISTRATION
    ...                      timeout=10
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id}
    ...                      pass_regexp=UE-${ue_id} PDU SESSION ID-${pdu_id} setup/reestablishment complete
    ...                      timeout=10
