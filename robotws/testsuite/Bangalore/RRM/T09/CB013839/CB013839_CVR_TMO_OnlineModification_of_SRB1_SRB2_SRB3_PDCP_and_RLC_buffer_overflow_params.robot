*** Settings ***
Documentation
...      author:           Bhabani    bhabani.sankar_rout@nokia.com
...      maintainer:       Bhabani    bhabani.sankar_rout@nokia.com
...     Compared to Focal Point scope, changing the
...     actPdcpRlcBufCongestionMechsm
Library     CB008796.py
Library     UpdateCellSOParameters.py
Library     taf.hw.pdu     WITH NAME   pdu
Library     ute_fsmaccess
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.hw.rf_attenuator.rf_attenuator  WITH NAME  at
Library     String
Library     SSHLibrary
Library     taf.config.scf   WITH NAME    scf
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     ta5g_pm_counters
Library     taf.sw.scout    WITH NAME    scout
Library     testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library     testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library     taf.sw.dcap.rd   WITH NAME   rd
Library     taf.file.pack
Library     taf.collectors.pmcounters    WITH NAME    PM
Library     taf.analyzer.pmcounter    WITH NAME    analyser
Library     testsuite.Bangalore.ORAN.resources.python.ta_ultracaller  WITH NAME  uc
Library     taf.ul.alarms_watchdog   WITH NAME    alarm
Library     Process
Library     taf.transport.ssh
Library     ute_ue
Library     Collections
Library     taf.nms.netact        WITH NAME    netact
Library     DateTime
Library     taf.collectors.core    WITH NAME    core
Library     taf.collectors.btslog  WITH NAME   btslog
Library     OperatingSystem     WITH NAME    os
Library     taf.sw.dcap.rd		WITH NAME	  dcap
Library     taf.collectors.simple    WITH NAME    simple
Library     taf.ue  WITH NAME  ue
Library    taf.converters.emil    WITH NAME    emil
Library    taf.converters.ttitracer    WITH NAME    ttitracer
Library   OperatingSystem
Library   Screenshot
Library   XML
Library   Telnet
Library   taf.sbts.oam.coam.admin    WITH NAME    admin
Library   taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py
Library   taf.selenium.sbts    WITH NAME  Selenium_Sbts
Library   taf.hw.rf_attenuator.attenuator    WITH NAME   attenuator
Resource   testsuite/Bangalore/RRM/5GET_BLR/resources/robot/PM_Counters.robot
Resource  ../resources/robot/Common_keywords_ST.robot
Library     taf.collectors.pmcounters    WITH NAME    collect_pm
Library     taf.analyzer.pmcounter       WITH NAME    check_pm
Resource    Keywords.robot
Library     testsuite/Bangalore/RRM/T05/TMOUS/CB013052/resources/validation.py


*** Variables ***

${folder}                          /home/ute/robotws
@{UE_alias}                        UE1
@{capabilities}                    Legacy_1
@{udpcalltype}=                    UDP
${protocol}=                       UDP
@{direction_dl}=                   dl
${timeout}=                        1800
${Attenuator_ip_addr}              10.43.13.250
${Attenuator_com_port}             3001
@{attenuation_ports}               7    8
#${attenuation_port}                1
${Attenuator_vendor}               TOPYOUNG
${Attenuator_model}                TAS16T16-51-120-1N-DEJS
@{PVA_Port_1_2}    		           7    8
${Counter_MOC_PATH_256}            MRBTS-30311/NRBTS-30311/NRCELL-301
${Counter_MOC_PATH_64}             MRBTS-30311/NRBTS-30311/NRCELL-311
#${ABSTRACT_LIB_CONFIG}=            /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB012464/ST_CRT/UE/ta_ue_config.yaml
${ABSTRACT_LIB_CONFIG}=            /home/ute/UE/Downloads/ta_ue_config_CB013839.yaml
${BTS_ID}                          MRBTS-30311
${BTSLOG} =                        btslog
&{BTS_Details}                     bts_host=192.168.255.129
...                                bts_port=443
...                                username=Nemuadmin
...                                password=nemuuser
...                                use_ssl=True
...                                update_interval=5000
...                                admin_api_log_dir=${EXECDIR}
...                                name=default
...                                bundle_path=${ABSTRACT_LIB_CONFIG}
...                                release=SBTS00
...                                timeout=30

${output_File}=    /home/ute/robotws/testsuite/Bangalore/T09/CB010869/ST_CRT/config/CB010869_CR.xml
${savedSCF_path}=    /home/ute/robotws/testsuite/Bangalore/T09/CB010869/ST_CRT/config
${filename}=    CB010869_CR.xml
${cellSoduration}=    1440
@{Required_bts_status} =   Test    OnAir
@{CellState} =   energySaving    notEnergySaving    reducedEnergySaving
@{ORUState} =   AWAKE    SLEEP
@{EXPECTED_POWER_STATE}=   SLEEP    AWAKE
${Cell_ID1}=    MRBTS-30311/NRBTS-30311/NRCELL-301
${Cell_ID2}=    MRBTS-30311/NRBTS-30311/NRCELL-311
${ORU_ID1}=    MRBTS-30311/EQM-1/APEQM-1/RMOD-1
${DELTA_PATH_80} =                /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB013839/config/SBTS26R1/Delta_80.json
${DELTA_PATH_95} =               /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB013839/config/SBTS26R1/Delta_95.json
${DELTA_reduceE} =                /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB010869/ST_CRT/config/Delta_reduceE.json
${commision_file} =               /home/ute/robotws/testsuite/Bangalore/RRM/T09/CB013839/config/Default_scf.xml
${connection} =                      default

*** Test Cases ***
[1][1.0] CB013839_CVR_TMO_OnlineModification_of_SRB1_SRB2_SRB3_PDCP_and_RLC_buffer_overflow_params
    admin.Connect to    bts_host=${BTS_Details.bts_host}   username=${BTS_Details.username}
    ...    password=${BTS_Details.password}  admin_api_log_dir=${BTS_Details.admin_api_log_dir}   release=${BTS_Details.release}
    Start Syslog
    Perform delta commissioning    ${DELTA_PATH_95}
    Sleep    5 s
    Require ue for ue functions      				 ##Attach Ue to gnb
    initial ue attach via ultracaller
    FTP_dl_data_transfer_with_attenuation
    Stop Syslog
    Validate buffercongdiscard Extract Log 95
    Sleep    100 s
    Validate the PDCP SDUs Buffer discards PM counters

    Perform delta commissioning    ${DELTA_PATH_80}
    Sleep    5 s
    Validate the PDCP SDUs Buffer discards PM counters     #counter value might be high or same as previous one
    uc.stop_data_transfer    ${UE_alias}
    detach ue via ultracaller

    Keywords.Get TcpdumpLogs from Remote machine
    Require ue for ue functions
    initial ue attach via ultracaller
    FTP_dl_data_transfer_with_attenuation
    Sleep    10 s
    Keywords.Stop tshark capture     ${CURDIR}
    ${pdml}    Fetch filtered PDML file from pcap    ${CURDIR}/tcpdump/tcpdump.pcap
    Verificaition of SRB Value     ${CURDIR}/tcpdump/filtered.pdml    1    4


*** Keywords ***
FTP_dl_data_transfer_with_attenuation
    uc.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
    Sleep    10 s

FTP_dl_data_transfer_with_attenuation_high
    uc.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
    Sleep    10 s
    Setup_attenuator_objects    ${PVA_Port_1_2}
    Attenuate the Port Value    attenuation_ports=${PVA_Port_1_2}    set_value=0db
    Sleep    100 s

Attenuate the Port Value
    [Arguments]     ${attenuation_ports}   ${set_value}
    FOR  ${port}  IN  @{attenuation_ports}
    ${port_value}  attenuator.read_attenuation  port=${port}
        Run keyword    Run Keyword If   "${port_value}dB"!="${set_value}"  attenuator.set_attenuation    port=${port}
     ...    value=${set_value}  confirm=${True}   confirmation_delay=5
     ...    ELSE    BuiltIn.Log To console    [ INFO ]: Port Number: ${port} and value: ${port_value}
    END

Validate the PDCP SDUs Buffer discards PM counters
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55320C06009    >1000      DL_SDU_DISC_BUFTH_QOS_GRP_09
    ...     local_moid=MRBTS-30311/NRBTS-30311
     ...     file_path=${pm_counter_file}




