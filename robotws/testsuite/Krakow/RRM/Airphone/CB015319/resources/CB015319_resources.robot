*** Settings ***
Documentation
...        maintainer: arkadiusz.sobejko@nokia.com
...                    michal.obszarny@nokia.com
...        contact:    arkadiusz.sobejko@nokia.com
...                    michal.obszarny@nokia.com
...        author:     arkadiusz.sobejko@nokia.com
...                    michal.obszarny@nokia.com
...        description:  Resources for CB015319

Library     taf.sw.reporting_portal         WITH NAME    reporting_portal
Library     ta5g_tshark
Library     ute_tshark
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     taf.ul.ue.sim.env_setup
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     ../../resources/former_l2_sw1/python/traffic_handling.py
Resource    ../../resources/former_l2_sw1/robot/collectors.robot
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot
Resource    ../../CB012734/resources/CB012734_resources.robot
Library     CB015319_resources.py

*** Keywords ***
Set feature flag ${parameter} to ${value}
    Log to console  Set feature flag ${parameter} to ${value}
    Configure  {'MOC': 'NRBTS', 'ID': '1', '${parameter}': '${value}'}

Set drbIdReallocationThreshold value
    [Arguments]    ${drbIdReallocationThreshold_value}=16
    Configure and wait    {'MOC':'NRBTS', 'ID':'1', 'drbIdReallocationThreshold':${drbIdReallocationThreshold_value}}

Trigger Ue Reauthentication
    [Arguments]  ${UE_ID}  ${NSA}=False
    Run keyword if  ${NSA}==False    Execute Egate Command    cmd=ue_reauth id=${UE_ID} nr_sec_cap=zuc|zuc
    ...    pass_regexp=Reauthentication procedure is complete
    ...    timeout=10
    Run keyword if  ${NSA}==True     Execute Egate Command    cmd=ue_reauth id=${UE_ID}
    ...    pass_regexp=REAUTHENTICATION PROCEDURE IS COMPLETED
    ...    timeout=10

Prepare Inter-gNB Test Environment
    Copy iphy packet lua
    Log To Console    Setup started
    Logcollector start
    Configure VM interfaces
    ${CONFIGURE_ENV}    get variable value    ${configure}    "True"
    Run keyword if  ${CONFIGURE_ENV}=="True"
    ...    Configure suite environment
    Setup egate  egate_port=20000  alias=default
    Setup devices aliases
    Enable internal mirroring for alias  gNB2
    Enable internal mirroring for alias  gNB3
    Teardown emss  bts_id=1
    Setup emss     bts_id=1
    Teardown emss  bts_id=2
    Setup emss     bts_id=2

Configure suite environment
    Add gnb configuration    host_id=1    scfc=${SCF_gnb2_MN}    rad_params=@{enable_CB015319}
    Add gnb configuration    host_id=2    scfc=${SCF_gnb3_SN}    rad_params=@{enable_CB015319}
    Add simulator  sim_type=airphone  config=${AP_XML}
    Add 5gc  config=${egate_config}  edaemon_ports=22222
    Configure environment       rmod_detection_timeout=420s    validate_gnb=False

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.4
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Update AMF Initial Context Setup parameters
    [Arguments]    ${id}=1    ${ue_id}=1    ${indexToRFSP}=1
    Execute Egate Command    cmd=amf_ue_ics_param id=${id} ue=${ue_id} indexToRFSP=${indexToRFSP}

UE${UE_ID} sends A4 measurement for NR-DC PSCell addition for meas_id=${MEAS_ID}
    ${command}    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${MEAS_ID} event=A4 srsrp_nr=19 srsrq_nr=10
    ...                       phycell_id=52 nrsrp_nr=90 nrsrq_nr=32
    Execute egate command
    ...     cmd=${command}
    Sleep    1s    reason=wait after command execution


Start observer for SNodeAddition
    Expect message flow
    ...    gNB3:XNAP_SNodeAdditionRequest
    ...    gNB3:XNAP_SNodeAdditionRequestAcknowledge
    ...    gNB2:E1AP_BearerContextModificationRequest
    ...    gNB2:E1AP_BearerContextModificationResponse
    ...    gNB3:XNAP_XnUAddressIndication
    ...    UE_1:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    UE_1:NR-RRC_RRCReconfigurationComplete
    ...    gNB3:XNAP_SNodeReconfigurationComplete
    ...    alias=NR-DC_flow  overall_timeout=6

Verify NR-DC setup correctly
    Run keyword and continue on failure    Flow occurred as expected  alias=NR-DC_flow
    Verify dc state    ue_id=1    state=ACTIVE

Trigger Max Rlc Retx
    [Arguments]    ${ue_id}=1
    Execute Egate Command And Wait For Data    cmd=ue_dc_rlf ue=${ue_id} failure_type=rlc_max_num_retx
    Sleep    1s    reason=wait after command execution

Trigger RRC SCGFailureInformation By Random Access Problem
    [Arguments]    ${ue_id}=1
    Execute Egate Command   cmd=ue_dc_rlf ue=${ue_id} failure_type=random_access_problem
    Sleep    3s    reason=wait after command execution

Start collecting both gNB BIP logs
    [Documentation]     Collect L1L2 BIP Logs using gnbMirroring.sh script V61
    ...     Script repository: https://gitlabe2.ext.net.nokia.com/juhakang/tools/tree/master/gnbMirroring
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    [Arguments]
    ...     ${alias_gnb1}=L1L2_BIP_Logs_MN
    ...     ${alias_gnb2}=L1L2_BIP_Logs_SN

    ${webservice_mn}=  Create Dictionary
    ...    host=192.168.255.129
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    ${webservice_sn}=  Create Dictionary
    ...    host=10.0.1.4
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443

    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=${alias_gnb1}
    ...  webservice=${webservice_mn}
    ...  timeout=300
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=${alias_gnb2}
    ...  webservice=${webservice_sn}
    ...  timeout=300
    l1l2bip.Set suite alias  ${alias_gnb1}
    l1l2bip.Set suite alias  ${alias_gnb2}
    core.setup_collectors    names=${alias_gnb1}
    core.setup_collectors    names=${alias_gnb2}
    core.start_collectors    names=${alias_gnb1}
    core.start_collectors    names=${alias_gnb2}
    Log to console  BIP logs collecting started

Stop collecting both gNB BIP logs
    [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/${TEST_NAME})
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${alias_gnb1}=L1L2_BIP_Logs_MN
    ...     ${alias_gnb2}=L1L2_BIP_Logs_SN
    ...     ${dir_path}=${OUTPUT_DIR}/${TEST_NAME}
    ...     ${delay}=0
    Sleep  ${delay}    reason=time for BIP collection
    core.stop_collectors  names=${alias_gnb1}
    core.stop_collectors  names=${alias_gnb2}
    core.collect_collectors  names=${alias_gnb1}  target_dir=/tmp
    core.collect_collectors  names=${alias_gnb2}  target_dir=/tmp
    core.teardown_collectors  names=${alias_gnb1}
    core.teardown_collectors  names=${alias_gnb2}
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias_gnb1}/BTS*.pcap -w /tmp/${alias_gnb1}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias_gnb2}/BTS*.pcap -w /tmp/${alias_gnb2}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${alias_gnb1}/tcpdump.pcap    ${dir_path}/${alias_gnb1}/tcpdump.pcap
    Copy File    /tmp/${alias_gnb2}/tcpdump.pcap    ${dir_path}/${alias_gnb2}/tcpdump.pcap
    Create directory    ${dir_path}/${alias_gnb1}_merged
    ${cmd_merged}    Catenate    mergecap ${dir_path}/${alias_gnb1}/tcpdump.pcap ${dir_path}/${alias_gnb2}/tcpdump.pcap
    ...                      -w ${dir_path}/${alias_gnb1}_merged/tcpdump.pcap
    ${rc}=    Run And Return Rc  ${cmd_merged}
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Remove directory    /tmp/${alias_gnb1}    recursive=True
    Remove directory    /tmp/${alias_gnb2}    recursive=True
    Log to console  BIP logs collecting finished

Setup wireshark for pdcp decoding in L1L2 bip
    ${output1}  Run  cp -f ${CURDIR}/../config/preferences /home/ute/.config/wireshark/
    ${output2}  Run  cp -f ${CURDIR}/../config/drb_bearerconfig /home/ute/.config/wireshark/
    Run  chmod 777 /home/ute/.config/wireshark/preferences
    Run  chmod 777 /home/ute/.config/wireshark/drb_bearerconfig
