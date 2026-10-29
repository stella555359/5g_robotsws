*** Settings ***
Documentation
...    Author: Guo Qianqian
...    Contact: qianqian.guo@nokia-sbell.com
...    this file is for CB007292 case10 of 25R1.
...    Please do not modify the file without notification to author

Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot

*** Variables ***
${TL11073_basic_wts}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC/APCFG/wts_TL11073_basic.cfg
${MRL_cmd}    amf_mobility_restriction_list_param id=1 fa_plmn=311:489  forbidden_tacs=200 sa_plmn=311:489
...                allowed_tacs=280 not_allowed_tacs=200 restricted_plmn=311:489 restricted_rat=both

*** Test Cases ***
Upgrade_airphone_and_wts_build
    [Tags]    upgrade_airphone
    Config Iphy Ip For Local Env_250_25R1
    [Teardown]    Case Postcondition


[1.0] CB007292-D_B1_intra_RAT_intra_gNB_intra_DU_inter_freq_Emergency_call_handover_Ignore_MRL
    [Tags]    CB007292    CRT    RAN_PZ_HAZ_1    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
    [Documentation]
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition T13-1
    Start Counter For CB007292_T13-1
    Log to Console		\n Start wireshark capture for CP traffic\n
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
	#Enter Egate
    Log to Console		\n add MRL to AMF\n
    #Send AP Command    cmd=amf_mobility_restriction_list_param id=1 fa_plmn=311:489  forbidden_tacs=200 sa_plmn=311:489
    #...                allowed_tacs=280 not_allowed_tacs=200 restricted_plmn=311:489 restricted_rat=both
    Send AP Command    cmd=${MRL_cmd}
    ...                pass_regexp=${None}
    ...                timeout=100s
    Log to Console		\n Check MRL to AMF\n
    Send AP Command    cmd=amf_mobility_restriction_list_param id=1
    ...                pass_regexp=311:489
    ...                timeout=100s
    Log to Console		\n add MRL to UE1\n
    Send AP Command    cmd=amf_ue_ics_param id=1 ue=1 mobility_restriction_list_id=1
    ...                pass_regexp=${None}
    ...                timeout=100s
    Log to Console		\n Registering UE1 and start DL/UL traffic\n
    #Send AP Command    cmd=ue_deregister id=1 by=ue ue_deregister_type=switch_off
    #...                pass_regexp=${None}
    #...                timeout=100s
    Send AP Command    cmd=ue_register id=1
    ...                pass_regexp=UE now in NG RM Registered state
    ...                timeout=100s
    Start DL and UL Traffic In UE1
    Log to Console		\n UE1 Trigger emergency call on 5QI-1\n
    Send AP Command    cmd=smf_param additional_qosflows_to_activate=2 id=1
    ...                pass_regexp=${None}
    ...                timeout=100s
    Send AP Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=1 request_type=initial-emergency-request
    ...                pass_regexp=${None}
    ...                timeout=100s
    Log to Console		\n Trigger HO from cell1(physCellId50) to cell2(physCellId51)\n
    #Send AP Command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=30 srsrq_nr=30
    #...                pass_regexp=${None}
    #...                timeout=200s
    Send AP Command    cmd=ue_measurement_send_nr id=1 meas_id=2 event=A3 srsrp_nr=11 phycell_id=51 nrsrp_nr=60
    ...                pass_regexp=${None}
    ...                timeout=100s
    Log to Console		\n Stop wireshark capture for CP traffic\n
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Log to Console		\n Sleep 7mins to wait counter update\n
    sleep    7min
    Log to Console		\n De-Registering UE1\n
    Send AP Command    cmd=ue_deregister id=1 by=ue ue_deregister_type=switch_off
	...                pass_regexp=${None}
    ...                timeout=100s
    Send AP Command    cmd=ue_change_location id=1 enb=2 cell
	...                pass_regexp=${None}
    ...                timeout=100s
    Log to Console		\n check CU counter update for HO\n
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition T13-1

*** Keywords ***
Config Iphy Ip For Local Env_250_25R1
    ${ap_version}    Get AP Build Name From UTE Cloud
    Log To Console  \n===upgrade AP ===
    ${cmd}  Catenate  python /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/library/airphone_worker/sw_update_local.py
    OperatingSystem.Run    ${cmd} -a ${ap_version}
    Log To Console  \n===configure eth0 ===
    OperatingSystem.Run    sudo ip addr add 10.97.65.238/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.239/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.240/32 dev eth0
    Log To Console  \n===configure eth3 ===
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/32 dev eth3
    Log To Console  \n===Open SCTP port on VM to allow SCTP traffic between WTS and gNB ===
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 38412 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 38422 -j ACCEPT
    OperatingSystem.Run    sudo iptables -I INPUT -i eth0 -p sctp -m sctp --dport 36422 -j ACCEPT
    Log To Console  \n===Save changes ===
    OperatingSystem.Run    sudo sh -c 'iptables-save > /etc/iptables/rules.v4'
    Log To Console  \n===Copy TL11073 basic wts cfg file to /opw/wts/latest/ ===
    OperatingSystem.Run    cp ${TL11073_basic_wts} /opt/wts/latest/basic_setup.cfg
    Case Precondition For AP    tag=TL11073_basic_25R1    product_type=vdu    operation=env_setup_sa
    Log To Console  \n===configure done ===

Case Precondition
    Case Precondition For AP    tag=${none}    product_type=vdu    operation=env_setup_sa
    Common Test Setup For AIC
    Log To Console  \n===Case Precondition Finished===

Case Postcondition
    Case Postcondition For AP
    Log To Console  \n===Case Postcondition Finished===

Case Precondition T13-1
    Case Precondition For AP    tag=CB007292_T13-1_25R1    product_type=vdu    operation=env_setup_sa
    Log To Console  \n===Case Precondition Finished===

Case Postcondition T13-1
    Case Postcondition For AP
    Log To Console  \n===Case Postcondition Finished===

Start Counter For CB007292_T13-1
    ${rule1}    Catenate
#        ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
		...         Distname: MRBTS-11073/NRBTS-11073/NRCELL-1;
        ...         Counter: M55147C00501,M55147C00503;
        ...         Counter rule: max(M55147C00501)==1 and max(M55147C00503)==1;
#    ${rule2}    Catenate
#        ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3;
#		...         Distname: MRBTS-11073/NRBTS-11073/NRCELL-3;
#        ...         Counter: M55125C05501,M55125C05502;
#        ...         Counter rule: max(M55125C05501)==1 and max(M55125C05502)==1;
#    ${rule_list}    Create List    ${rule1}    ${rule2}
    ${rule_list}    Create List    ${rule1}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=0

Start DL and UL Traffic In UE1
    Send AP Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    ...                pass_regexp=${None}
    ...                timeout=100s
    Send AP Command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    ...                pass_regexp=rrcReconfigurationComplete
    ...                timeout=100s
    Send AP Command    cmd=trf_data_start ue=1 pdu=1 dir=dl trf_id=1 mbps=50 seconds=6000s
    ...                pass_regexp=Started Downlink Internal traffic
    ...                timeout=100s
    Send AP Command    cmd=trf_data_start ue=1 pdu=1 dir=ul trf_id=1 mbps=10 seconds=6000s
    ...                pass_regexp=Started Uplink Internal traffic
    ...                timeout=100s
    Send AP Command    cmd=ue_stats_nr id=1
    ...                pass_regexp=${None}
    ...                timeout=100s

Enter Egate
	Airphone Operation    operation=edaemon_egate_setup
	...                   product_type=${None}
	...                   traffic_info_dic=${None}
	...                   tag=${None}
	...                   cmd=${None}
	...                   pass_regexp=${None}
	...                   timeout=100s