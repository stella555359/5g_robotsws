# *** Settings ***
# Documentation
# ...               author: Steven Liu
# ...               contact: steven.liu@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Force Tags        SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    	CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABILB1_AWEUA_ENB    STATE_SW_UPLOADED
# ...    PY36
# Suite Setup       CI_interface.Common Suite Setup
# Suite Teardown
# 
# Library    taf.analyzer.pcap    WITH NAME    cap
# #Library           taf.sbts.oam.coam.admin         WITH NAME      coam
# Library           taf.transport.ssh         WITH NAME    ssh
# Library           ./resource/unzip_RU_LOG.py
# Library           ./resource/7597_common_keyword.py
# Resource          ./resource/CB007597_common_keyword.robot
# Resource          taf/rfrl/common_resources/robot/coam.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library           taf.config.scf    WITH NAME    cscf
# Library           OperatingSystem
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
# #Library    taf.analyzer.pcap    WITH NAME   cap
# 
# 
# *** Test Cases ***
# [1]CB007597-5G-A_002-AWEUA_Generic startup of synchronization functions_configuration with PTP
#     [Documentation]    This case is strong dependence on these three shell scripts,if change env,the scripts must be modified.
#     ...    these three scripts PTP.sh start_tcp.sh SYNCE_PTP.sh
#     ...    should exist on /home/ute/robotws5g/testsuite/SISO/Hangzhou/CB007597-A-AWEUA/ on UTE 10.57.155.74
#     ...    if not exist , you can find them on git the same path with this robot case file
#     [Tags]
#     [Setup]
#     wait until keyword succeeds    5min    10s    Check cell on air
#     set actEcpriRuPtpOnlysync value    actEcpriRuPtpOnlysync_value=${true}
#     wait until keyword succeeds    5min    10s    Check cell on air
#     Start RU tcpdump
#     Check sync mode    PTP    sync_mode: PTP
#     check lockState and syncStatus on WebEM    Locked    Locked
#     Read Log and check    tcpdump_log=${filename}
#     log to console    \n\tcheck frame info
#     ${check_result}    Check_frame_info    req_fl=${output_log}/Req.txt    resp_fl=${output_log}/Resp.txt
#     Should Be Equal As Strings    ${check_result}    True
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB007597-5G-A_006-AWEUA_PTP Failure - configuration with PTP only
#     [Documentation]    This case is strong dependence on these three shell scripts,if change env,the scripts must be modified.
#     ...    these three scripts PTP.sh start_tcp.sh SYNCE_PTP.sh
#     ...    should exist on /home/ute/robotws5g/testsuite/SISO/Hangzhou/CB007597-A-AWEUA/ on UTE 10.57.155.74
#     ...    if not exist , you can find them on git the same path with this robot case file
#     [Tags]
#     [Setup]
#     wait until keyword succeeds    5min    10s    Check cell on air
#     set actEcpriRuPtpOnlysync value    actEcpriRuPtpOnlysync_value=${true}
#     wait until keyword succeeds    5min    10s    Check cell on air
#     Check sync mode    PTP    sync_mode: PTP
#     Get and check Tuning mode    Normal tuning
#     Change para Glonass only    LNAvalue=${False}    holdover_time=${holdover_time_200000}
#     Check Clockclass on WEBEM    value=7
#     Get and check Tuning mode    Adaptive holdover
#     sleep    2min
#     check lockState and syncStatus on WebEM    OutOfLock    Freerun
#     Check fault
#     Change para GPS Beidou    LNAvalue=${True}    holdover_time=${holdover_time_1325}
#     Check sync mode    PTP    sync_mode: PTP
#     check lockState and syncStatus on WebEM    Locked    Locked
#     [Teardown]    Case Teardown
# 
# [1]CB007597-5G-B-AWEUA_001_trigger_holdover_when_error_within_spec_(below_threshold)_topology_A
#     [Documentation]    This case is strong dependence on these three shell scripts,if change env,the scripts must be modified
#     ...    these two scripts start_tcp_lna_false.sh start_tcp_lna_true.sh
#     ...    should exist on /home/ute/robotws5g/testsuite/SISO/Hangzhou/CB007597-B-AWEUA/ on UTE 10.57.155.74
#     ...    if not exist , you can find them on git the same path with this robot case file
#     [Tags]
#     [Setup]
#     Check cell on air
#     Change para Glonass only    LNAvalue=${False}    holdover_time=${holdover_time_200000}
#     Start RU tcpdump for LNApower    script_name=start_tcp_lna_false.sh    dir_name=CB007597-B
# #    Check fault
#     Get and check Tuning mode    Adaptive holdover
#     Check wireshark log data equal value    command=grep grandmasterClockClass |cut -d ':' -f 2|awk 'END {print}'
#     ...    pacp_filename=${filename}    txt_filename=tcpdump_ru.txt    check=7    filter='ptp.v2.an.grandmasterclockclass'
# #    Read Wireshark Log    clockclass_value=07
#     Check Clockclass on WEBEM    value=7
#     Change para GPS Beidou    LNAvalue=${True}    holdover_time=${holdover_time_1325}
#     wait until keyword succeeds    20min    20s    Check cell on air
#     Start RU tcpdump for LNApower    script_name=start_tcp_lna_true.sh    dir_name=CB007597-B
#     Check wireshark log data equal value    command=grep grandmasterClockClass |cut -d ':' -f 2|awk 'END {print}'
#     ...    pacp_filename=${filename}    txt_filename=tcpdump_ru.txt    check=6    filter='ptp.v2.an.grandmasterclockclass'
# #    Read Wireshark Log    clockclass_value=06
#     run keyword and expect error    *    Check wireshark log data equal value
#     ...    command=grep grandmasterClockClass |cut -d ':' -f 2|awk 'END {print}'
#     ...    pacp_filename=${filename}    txt_filename=tcpdump_ru.txt    check=7    filter='ptp.v2.an.grandmasterclockclass'
#     run keyword and expect error    *    Check wireshark log data equal value
#     ...    command=grep grandmasterClockClass |cut -d ':' -f 2|awk 'END {print}'
#     ...    pacp_filename=${filename}    txt_filename=tcpdump_ru.txt    check=150    filter='ptp.v2.an.grandmasterclockclass'
#     Check Clockclass on WEBEM    value=6
#     [Teardown]    Case Teardown
# 
# CB007597-5G-C_002-AWEUA_Reconfiguration_of_timing_offset_values_during_run-time
#     [Tags]
#     Modify scf file    value1=19489585    value2=360    value3=true
#     Check BTS is in On Air
#     read the RU log
#     check the RU log    search_string=<alpha>2394880</alpha><beta>360</beta>
#     Adjust Enb    index=0
#     make the call
#     Adjust Enb    index=5
#     make the call
#     Modify scf file    value1=99999995    value2=32767    value3=true
#     Check BTS is in On Air
#     read the RU log
#     check the RU log    search_string=<alpha>12287999</alpha><beta>32767</beta>
#     Adjust Enb    index=0
#     make the call
#     Adjust Enb    index=5
#     make the call
#     Modify scf file    value1=0    value2=-32768    value3=true
#     Check BTS is in On Air
#     read the RU log
#     check the RU log    search_string=<alpha>0</alpha><beta>-32768</beta>
#     Adjust Enb    index=0
#     make the call
#     Adjust Enb    index=5
#     make the call
#     [Teardown]    Case samsung detach And Teardown
# 
# 
# 
# 
# 
# 
# 
# 
# 
