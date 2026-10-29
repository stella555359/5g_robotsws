*** Settings ***

Documentation

...        [Procedure]        "[1]CNI-120767 Check Alarms are reported for ethernet Physical Link layer Lost"
...        [Date]             "24-07-2024"
...        [Author]           "Chiranjeevi vempalle"
...        [Feature_ID]       "SCNI-120767"
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



Suite Setup         Setup Oamops
Suite Teardown          Teardown oamops



***Test Cases***
[1][1.0] CNI_120767_Enable Auto Negotiation on EIF 4 Interface
##    Perform Commissioning       scf_file=${ASIM_Basic}        verify_bts_status=False     timeout=600
##    sleep  300
    Perform Recommissioning and enable EIF4 interface and speed and duplex
    sleep   90
    Verify Alarm     faultid=61029    should_exist=${True}
#    Verify Bts Status   req_rat=all    should_be_onair=${True}
    Verify Bts Status   req_rat=all    should_be_onair=${False}
    Perform Recommissioning and change EIF4 speed and duplex to AutoDetect
    Sleep   60
    Verify Alarm     faultid=61607    should_exist=${True}
    Configure Switch    device=l2_eif_switch    command_profile=switch_ports_EIF4_100Mbit
    sleep   120
#    Verify Bts Status   req_rat=all    should_be_onair=${True}
    Verify Bts Status   req_rat=all    should_be_onair=${False}
    Verify Alarm     faultid=61029    should_exist=${True}
    Verify Alarm     faultid=61607    should_exist=${False}
    ${detected_speedandDuplex} =     Query Admin Infomodel    query=get param ${ETHLK_DN_path}
    Perform Recommissioning     type=param  param_path=${ethlk_path}    value=${ethlk_state_lock}    operation=update
    sleep   120
    Verify Bts Status   req_rat=all    should_be_onair=${False}
    Verify Alarm     faultid=61029    should_exist=${False}
    Verify Alarm     faultid=61607    should_exist=${False}
    Perform Recommissioning     type=param  param_path=${ethlk_path}    value=${ethlk_state_unlock}    operation=update
    sleep   120
#    Verify Bts Status   req_rat=all    should_be_onair=${True}
    Verify Bts Status   req_rat=all    should_be_onair=${False}
    Verify Alarm     faultid=61029    should_exist=${True}
    Verify Alarm     faultid=61607    should_exist=${False}


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
