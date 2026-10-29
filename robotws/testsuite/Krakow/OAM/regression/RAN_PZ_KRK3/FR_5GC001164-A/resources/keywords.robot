*** Settings ***
Documentation    Suite description
...    Author:      Krzysztof Domino
...   Contact:      krzysztof.domino@nokia.com
...   Based on testcases located in: testsuite/Wroclaw/OAM/cOAM1/5GC001164/ writen by Mateusz Swieton<mateusz.swieton@nokia.com>


Library     OperatingSystem
Library     String
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.gnb.oam.coam.admin    WITH NAME  admin
Resource    taf/rfrl/bts/robot/gnb.robot
Library    testsuite/Krakow/OAM/regression/RAN_PZ_KRK3/FR_5GC001164-A/resources/plugin_keywords.py  WITH NAME  plugin

*** Variables ***
${gNB_IP_MPLANE_LOCAL}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_MPLANE_IF_PORT}      443
${fault4278}    RF module unauthorized
${rf_plugin_aeqe_SBTS_dir}    /home/ute/Desktop/RFMPlugin_474750A-102_0002.zip
${rf_plugin_aeqe_SBTS}       http://lterel.es-si-s3-z4.eecloud.nsn-net.net/RFM_PLUGIN/RFMPlugin_474750A-102_0002.zip
${wget_options}              wget -P /home/ute/Desktop

*** Keywords ***
5GC001164_A_RFM_Plug-in_upload_via_Element_Manager
    ${sw_release_name}=    Get gnb sw branch
    Copy original BpfParts file  ${sw_release_name}
    Modify BpfParts file AEQE  ${sw_release_name}
    Remove RF Plugin folder from BTS
    Remove TargetBD_RFM from BTS
    Reset gNB
    wait until keyword succeeds   12 min    5 sec     Check if WebEm is pingable
    Wait until keyword succeeds   10 min    15 sec    Verify Alarm is Active on gNB  ${fault4278}
    Wait until keyword succeeds   15 min     5 min    gnbswupdate.Update Software     ${rf_plugin_aeqe_SBTS_dir}
    log to console                Waiting for OnAir
    wait until keyword succeeds   15 min    1 min    Verify gNB Cell is onAir
    Remove TargetBD_RFM from BTS without Reset Site
    Verify Alarm is not Active on gNB   ${fault4278}
    Restore original BpfParts file  ${sw_release_name}
    Reset gNB
    wait until keyword succeeds   12 min    5 sec     Check if WebEm is pingable
    wait until keyword succeeds   15 min    1 min    Verify gNB Cell is onAir

5GC001164_A_Download_and_activate_Plug-in_modules_using_BTS_Site_Manager
    ${sw_release_name}=    Get gnb sw branch
    Remove TargetBD_RFM from BTS
    Remove RF Plugin folder from BTS
    Wait until keyword succeeds   15 min     5 min    gnbswupdate.Update Software     ${rf_plugin_aeqe_SBTS_dir}
    Remove TargetBD_RFM from BTS without Reset Site
    wait until keyword succeeds   15 min    1 min    Verify gNB Cell is onAir

Check if WebEm is pingable
    ${output}   Run       ping -c 1 -W 10 ${gNB_IP_MPLANE_LOCAL}
    Should contain      ${output}   1 packets transmitted, 1 received

Modify BpfParts file AEQE
    [Arguments]  ${sw_release_name}
    Run Keyword If   '${sw_release_name}' == 'SBTS22R2'  plugin.modify_bpf_AEQE_22R2
    Run Keyword If   '${sw_release_name}' != 'SBTS22R2'  plugin.modify_bpf_AEQE_22R3

Remove TargetBD_RFM from BTS
    ${target_list}=  plugin.list_targetbd_rfm_from_bts
    Run keyword if  '${target_list}' != '0'   Run Keywords
    ...    plugin.remove_targetbd_rfm_from_bts   AND
    ...    Reset gNB  AND
    ...    Sleep  10 sec   AND
    ...    wait until keyword succeeds   20 min    1 min    Verify gNB Cell is onAir

Remove TargetBD_RFM from BTS without Reset Site
    ${terminal}=    plugin.list_targetbd_rfm_from_bts
    ${terminal}=    Fetch from left   ${terminal}  \r\n
    Run keyword if  '${terminal}' != '0'   plugin.remove_targetbd_rfm_from_bts

Download Plugins
    Run    wget ${wget_options} ${rf_plugin_aeqe_SBTS}

Copy original BpfParts file
    [Arguments]  ${sw_release_name}
    Run Keyword If   '${sw_release_name}' == 'SBTS22R2'  plugin.copy_bpf_AEQE_22R2
    Run Keyword If   '${sw_release_name}' != 'SBTS22R2'  plugin.copy_bpf_AEQE_22R3

Restore original BpfParts file
    [Arguments]  ${sw_release_name}
    Run Keyword If   '${sw_release_name}' == 'SBTS22R2'  plugin.restore_bpf_AEQE_22R2
    Run Keyword If   '${sw_release_name}' != 'SBTS22R2'  plugin.restore_bpf_AEQE_22R3

Load Plugin Teardown
    ${sw_release_name}=    Get gnb sw branch
    Remove RF Plugin folder from BTS
    Remove TargetBD_RFM from BTS
    Restore original BpfParts file  ${sw_release_name}
    gnbswupdate.Update Software      ${rf_plugin_aeqe_SBTS_dir}

Get gnb sw branch
     ${gnb_sw_version}=    Get gNB SW version
     @{gNB_branch}=        Split String From Right    ${gnb_sw_version}    _    4
     [Return]    @{gNB_branch}[0]
