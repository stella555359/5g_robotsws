*** Settings ***
Documentation    author: Liu Tiffany
...               contact: tiffany.liu@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC000723-Z


*** Keywords ***

start DL traffic
    no operation

COAM_Admin.CheckBTSConterWithTraget
    [Arguments]    ${counter_id}    ${target_value}=1
    ${date}   Get Current Date   exclude_millis=True
    ${res}  selenium_coam.get_bts_counters_info   counter_id=${counter_id}    timeout=960
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true    ${values[-1]}>${target_value}




Check Cell On Air Via WEBUI
    wait until keyword succeeds    5x    1min    COAM_Admin.Login
    wait until keyword succeeds    20min    1min    COAM_Admin.CheckBTSOnAir



Process.UE Attach
    [Arguments]    ${yml_path_alias}=${yml_path_with_pdu}    ${scenario_alias}=${scenario}
    Prisma setup    ${yml_path_alias}    ${tl.ues}
    prisma.stop_tstm    node_name=lsu_tstmuu
    prisma.stop_lsu    node_name=lsu_uu
    Prisma start lsu uu
    Create Cell and Verify Cell Sync
	Prisma start tstm uu
    Prisma attach to gNB    ${scenario_alias}

Prisma attach to gNB
    [Arguments]    ${scenario_alias}=${scenario}
    Start airmosaic
    sleep   1min
    Perform UE attach on prisma    ${sid_file_name}    ${scenario_alias}
    Wait until keyword succeeds    20 s    2 sec    Check Random access    ${ra_times}
    Check scenario status
    Sleep    10s


Perform UE attach on prisma
    [Arguments]    ${sid_file_name}    ${scenario}
    prisma.prepare_test    ${sid_file_name}    ${scenario}    300
    ${output}=     prisma.get_scenario_status
	sleep    40s
    prisma.ue_attach
    ${output}=      prisma.get_scenario_status


Wireshark.Download_Pcap
    [Arguments]  ${case_pcap}
    gNB.Connect
    Wireshark.StopCapturinglog
    Wireshark.DownloadLogToUTE    ${case_pcap}
    gNB.Disconnect


Create Cell and Verify Cell Sync
    prisma.create_5g_cell    ${lsu_uu}
    sleep    10s
    wait until keyword succeeds    5 min    20 sec    Check the NRcell sync

AMF.Connect
     [Arguments]      ${AMF_USERNAME}=cmm    ${AMF_PASSWORD}=Nokia@2019!  ${alias}=${ALIAS_AMF}
     run keyword and ignore error  ssh.Connect to    ${AMF_IP}    ${AMF_USERNAME}    ${AMF_PASSWORD}  alias=${alias}


AMF.Disconnect
    [Arguments]    ${alias}=${ALIAS_AMF}
    run keyword and ignore error  Conn.Disconnect    ${alias}


Setup suite
    Create Log Directories
    set suite variable    ${Log_PATH_Artifactory}    ${CFGFILE_PATH}
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache


