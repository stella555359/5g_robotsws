*** Settings ***

Documentation

...        [Procedure]        "[1]CNI_120767_Alarm with automatic link-speed down-shift for Electrical Ethernet interfaces"
...        [Date]             "24-07-2024"
...        [Author]           "Chiranjeevi vempalle"
...        [Feature_ID]       "CNI-120767"
...        [Maintenance]      "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "EIF4 ASIM testing"
...        [DELTA_FILE_DEPENDENCY]  ""
...        [Validated_TestLine]     "3807"
...        [Config_Comments]         "3 RAT CONFIGURATION WITH ASIL verified with 1G and 10G"
...        [Precondition]             "3 SFPs ARE CONNECTED WITH EIF1-25G, EIF2-10G, EIF3-1G"


variables       ta_e2e_bts_trs_fw
#Resource        setup/framework.robot
#Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource         ${CURDIR}/../resources/common_keywords.robot
#Resource        /home/ute/fw_user_path/testcases/resources/Admin_Common_Library.robot
#Resource         ${CURDIR}/../resources/common_keywords.robot
#Resource         ${CURDIR}/../resources/ncdr_common_keywords.robot



#Suite Setup         Setup Oamops
#Suite Teardown          Teardown oamops


Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops




***Test Cases***
[1][1.0] CNI_120767_Alarm with automatic link-speed down-shift for Electrical Ethernet interfaces
    Perform Commissioning       scf_file=${ASIM_Basic}        verify_bts_status=False     timeout=600
    sleep  600
    Perform Recommissioning and enable EIF4 interface and speed and duplex
    sleep   90
    Verify Alarm     faultid=61029    should_exist=${false}
    Verify Bts Status   req_rat=all    should_be_onair=${False}
#    Verify Bts Status   req_rat=all    should_be_onair=${True}
	Configure Switch    device=l2_eif_switch        command_profile=shutdown_switch_ports_EIF4
	sleep  90
	Verify Alarm     faultid=61029    should_exist=${true}
	Verify Bts Status   req_rat=all    should_be_onair=${False}
    Configure Switch    device=l2_eif_switch	command_profile=no_shutdown_switch_ports_EIF4
    sleep  90
	Verify Alarm     faultid=61029    should_exist=${false}
#    Verify Bts Status   req_rat=all    should_be_onair=${True}
    Verify Bts Status   req_rat=all    should_be_onair=${False}
    Perform Recommissioning and change EIF4 speed and duplex to AutoDetect
    Configure Switch    device=l2_eif_switch    command_profile=switch_ports_EIF4_AutoDetect
    sleep   90
	Verify Alarm     faultid=61607    should_exist=${true}
    Verify Bts Status   req_rat=all    should_be_onair=${False}
#    Verify Bts Status   req_rat=all    should_be_onair=${True}
    Perform Recommissioning and change EIF4 speed and duplex to 100Mbit
    Configure Switch    device=l2_eif_switch    command_profile=switch_ports_EIF4_100Mbit
    sleep   90
    Verify Alarm     faultid=61607    should_exist=${false}
	Verify Bts Status   req_rat=all    should_be_onair=${False}
#    Verify Bts Status   req_rat=all    should_be_onair=${True}
	[Teardown]


***Keywords***

Perform Recommissioning and enable EIF4 interface and speed and duplex
    Perform Recommissioning     type=delta      delta_file=${Enable_EIF4}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    Sleep   30


Perform Recommissioning and change EIF4 speed and duplex to AutoDetect
    Perform Recommissioning     type=delta      delta_file=${EIF4_Autodetect}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    Sleep   30


Perform Recommissioning and change EIF4 speed and duplex to 100Mbit
    Perform Recommissioning     type=delta      delta_file=${EIF4_100Mbit}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    Sleep   30
