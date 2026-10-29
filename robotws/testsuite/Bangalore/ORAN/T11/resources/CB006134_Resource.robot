** Settings ***
Documentation    Author :
...              Squad group : SG_06
...              Feature : CB006134
Library         testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller

*** Variables ***
${FILTER}                        dldata_ssblocksendreq||dldata_pdschsendreq||dldata_csirssendreq
${FILTER_DL}                     dldata_pdschsendreq
${FILTER_UL}                     uldata_puschreceiveresplo
@{COLUMN_NAME_DL}                   DlData_PdschSendReq.PdschSendReq.sfn    DlData_PdschSendReq.PdschSendReq.slot

@{COLUMN_NAME_UL}                  UlData_PuschReceiveRespLo.PuschReceiveRespLo.sfn    UlData_PuschReceiveRespLo.PuschReceiveRespLo.slot
...                                 UlData_PuschReceiveRespLo.PuschReceiveRespLo.rnti

${CHECK_PDSCH_IN_SSB_REGEXP}     SEPARATOR=    DlData_SsBlockSendReq.*?(?P<sfn>0x\\w+).*?(?P<slot>0x\\w+)\\".*?
...                              \\n(?:.*?DlData_PdschSendReq.*?(?P=sfn).*?(?P=slot).*?\\n){1}
${CHECK_2PDSCH_IN_SSB_REGEXP}    SEPARATOR=    DlData_SsBlockSendReq.*?(?P<sfn>0x\\w+).*?(?P<slot>0x\\w+)\\".*?
...                              \\n(?:.*?DlData_PdschSendReq.*?(?P=sfn).*?(?P=slot).*?\\n){2}
${CHECK_PDSCH_IN_TRS_REGEXP}     SEPARATOR=    DlData_CsiRsSendReq.*?(?P<sfn>0x\\w+).*?(?P<slot>0x\\w+)\\".*?
...                              \\n(?:.*?DlData_PdschSendReq.*?(?P=sfn).*?(?P=slot).*?\\n){1}
${CHECK_2PDSCH_IN_TRS_REGEXP}    SEPARATOR=    DlData_CsiRsSendReq.*?(?P<sfn>0x\\w+).*?(?P<slot>0x\\w+)\\".*?
...                              \\n(?:.*?DlData_PdschSendReq.*?(?P=sfn).*?(?P=slot).*?\\n){2}

${CHECK_4PDSCH_IN_SINGLE_SLOT_REGEXP}    SEPARATOR=    DlData_PdschSendReq.*?(?P<sfn>0x\\w+).*?(?P<slot>0x\\w+)\\".*?
...                              \\n(?:.*?DlData_PdschSendReq.*?(?P=sfn).*?(?P=slot).*?\\n){1}
${CHECK_5PDSCH_IN_SINGLE_SLOT_REGEXP}    SEPARATOR=    DlData_PdschSendReq.*?(?P<sfn>0x\\w+).*?(?P<slot>0x\\w+)\\".*?
...                              \\n(?:.*?DlData_PdschSendReq.*?(?P=sfn).*?(?P=slot).*?\\n){4}


${CHECK_4PUSCH_IN_SINGLE_SLOT_REGEXP}    SEPARATOR=    UlData_PuschReceiveRespLo.*?(?P<sfn>0x\\w+).*?(?P<slot>0x\\w+)\\".*?
...                                     \\n(?:.*?UlData_PuschReceiveRespLo.*?(?P=sfn).*?(?P=slot).*?\\n){1}

${CHECK_5PUSCH_IN_SINGLE_SLOT_REGEXP}    SEPARATOR=    UlData_PuschReceiveRespLo.*?(?P<sfn>0x\\w+).*?(?P<slot>0x\\w+)\\".*?
...                              \\n(?:.*?UlData_PuschReceiveRespLo.*?(?P=sfn).*?(?P=slot).*?\\n){4}



${FIX_SUBFRAMES}    1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001
*** Keywords ***
Set PDSCH Test Mode
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_decode_muxphychan decode_mux_phy_chan\=decode_PDSCH

Covert BIP To Csv for DL
    ${bip_name}    Set Variable    ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap
    ${BIP_CSV_LOG}    Convert BIP Log Pcap To Csv    bip_log=${bip_name}    filter=${FILTER_DL}    column_name=${COLUMN_NAME_DL}
    ...    csv_name_tag=ssbtrs
    Set Suite Variable    ${BIP_CSV_LOG}

Covert BIP To Csv for UL
    ${bip_name}    Set Variable    ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap
    ${BIP_CSV_LOG}    Convert BIP Log Pcap To Csv    bip_log=${bip_name}    filter=${FILTER_UL}    column_name=${COLUMN_NAME_UL}
    ...    csv_name_tag=ssbtrs
    Set Suite Variable    ${BIP_CSV_LOG}

Verify Single UE PDSCH Schedule In SSB Slot
    ${matches}    Get Match List From BIP Csv File    ${BIP_CSV_LOG}    ${CHECK_PDSCH_IN_SSB_REGEXP}
    Should Not Be Empty    ${matches}

Verify UE PDSCH Schedule Not In SSB Slot
    ${matches}    Get Match List From BIP Csv File    ${BIP_CSV_LOG}    ${CHECK_PDSCH_IN_SSB_REGEXP}
    Should Be Empty    ${matches}

Verify Multi UE PDSCH Schedule In SSB Slot
    ${matches}    Get Match List From BIP Csv File    ${BIP_CSV_LOG}    ${CHECK_2PDSCH_IN_SSB_REGEXP}
    Should Not Be Empty    ${matches}

Verify Single UE PDSCH Schedule In TRS Slot
    ${matches}    Get Match List From BIP Csv File    ${BIP_CSV_LOG}    ${CHECK_PDSCH_IN_TRS_REGEXP}
    Should Not Be Empty    ${matches}

Verify Multi UE PDSCH Schedule In TRS Slot
    ${matches}    Get Match List From BIP Csv File    ${BIP_CSV_LOG}    ${CHECK_2PDSCH_IN_TRS_REGEXP}
    Should Not Be Empty    ${matches}

Verify Multi UE PDSCH Schedule In Same SFN and Slot
    @{group_list}    String.Get Regexp Matches    ${CHECK_4PDSCH_IN_SINGLE_SLOT_REGEXP}    \\(\\?P\\<(\\w+)\\>    1
    Log List    ${group_list}
    ${csv_content}    OperatingSystem.Get File    ${BIP_CSV_LOG}
#    @{group_list}    sfn	slot
    @{match_list}    String.Get Regexp Matches    ${csv_content}    ${CHECK_4PDSCH_IN_SINGLE_SLOT_REGEXP}    @{group_list}
    Log List    ${match_list}
    Should Not Be Empty    ${match_list}
    @{unmatch_list}    String.Get Regexp Matches    ${csv_content}    ${CHECK_5PDSCH_IN_SINGLE_SLOT_REGEXP}    @{group_list}
    Log List    ${unmatch_list}
    Should Be Empty    ${unmatch_list}  msg=Check whether all the UEs data transfer was successfull.

Verify Multi UE PUSCH Schedule In Same SFN and Slot
    @{group_list}    String.Get Regexp Matches    ${CHECK_4PUSCH_IN_SINGLE_SLOT_REGEXP}    \\(\\?P\\<(\\w+)\\>    1
    Log List    ${group_list}
    ${csv_content}    OperatingSystem.Get File    ${BIP_CSV_LOG}
#    @{group_list}    sfn	slot
    @{match_list}    String.Get Regexp Matches    ${csv_content}    ${CHECK_4PUSCH_IN_SINGLE_SLOT_REGEXP}    @{group_list}
    Log List    ${match_list}
    Should Not Be Empty    ${match_list}
    @{unmatch_list}    String.Get Regexp Matches    ${csv_content}    ${CHECK_5PUSCH_IN_SINGLE_SLOT_REGEXP}    @{group_list}
    Log List    ${unmatch_list}
    Should Be Empty    ${unmatch_list}  msg=Check whether all the UEs data transfer was successfull.

Start Multiue Register
    Log To Console    Start UE register for multi UEs...
    ${command}    Catenate    script file=multi_ue_sa_script.lua entry=start_multiue_call(1,2,2,internal)
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${command}    pass_regexp=UE2: Established PDU session ID=1 using PDU Gateway ID=2    timeout=2minutes
Config TL And Start Egate
    [Arguments]    ${delta_file}    ${cfg_file}
    Configure Airphone
    Configure Gnb    ${delta_file}
    Verify Coam Site Is Ready
    Online Configure Srb And Drb InactivityTimer
    Download And Unzip Lua File    ${SW_VERSION_TOTAL}
    Start UTE WTS FOR DSS
    Set Suite Variable    ${WTS_CFG}    ${cfg_file}
    Log To Console    ${WTS_CFG}
    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
    Load Cfg File    ${WTS_CFG}
Prepare Test Env
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Backup Gnb Sw Coniguration
    Modify Gnb Sw Coniguration
    Backup AP Config File
    Configure Airphone
    Set Config Path
    Adjust Network Configuration For Different Branch

Set Config Path
    Set Suite Variable    ${JSON_PATH}    ${CURDIR}/resources/config/${SW_BRANCH}
    Log To Console    ${JSON_PATH}

Adjust Network Configuration For Different Branch
    ${localIpAddr}    Run    awk -F "[<|\>]" '/name=\\"localIpAddr\\"/{print $3}' ${OUTPUT_DIR}/SCF_before_suite.xml
    Set Suite Variable    ${localIpAddr}
    Log To Console    ${localIpAddr}
    Run Keyword If    '${localIpAddr}' != '10.0.1.2'
    ...    Modify IP Configuration
    ...    ELSE
    ...    Log To Console    Don't Need adjust network configuration for Trunk.\n

Modify IP Configuration
    Run    sed -i 's/10.0.1.2/${localIpAddr}/g' ${LOCAL_WTS_DIR}/${WTS_CFG_10M}
    Run    sed -i 's/10.0.1.2/${localIpAddr}/g' ${LOCAL_WTS_DIR}/${WTS_CFG_20M}
Recover Network Configuration For Different Branch
    Run Keyword If    '${localIpAddr}' != '10.0.1.2'
    ...    Recover IP Configuration
    ...    ELSE
    ...    Log To Console    Don't need recover network configuration.\n
Recover IP Configuration
    Run    sed -i 's/${localIpAddr}/10.0.1.2/g' ${LOCAL_WTS_DIR}/${WTS_CFG_10M}
    Run    sed -i 's/${localIpAddr}/10.0.1.2/g' ${LOCAL_WTS_DIR}/${WTS_CFG_20M}

SA Attach And Traffic For MultiUE
    [Arguments]    ${ue_num}
    Log To Console    start 5G SA attach for multiUE...
    ${pattern}    Set Variable    Script End
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=script file\=${MULTIUE_SCRIPT} entry\=\attach_traffic_detach\(1,${ue_num},180,5,yes,yes,yes\)
    ...    pass_regexp=${pattern}    timeout=6min
    Log To Console    ${output}
Recover TL Configuration
    Recover Network Configuration For Different Branch
    Wait Until Keyword Succeeds    10 min    5s    Recover Gnb Sw Coniguration
    Recover AP Config File
    Teardown All Connections
    Hard Reboot GNB
Recover TL
    Recover Config
    Clean Edaemon And Egate

Configure Gnb
    [Arguments]    ${delta_file}
    Delta Commission Json File With Admin    delta_json=${delta_file}

Configure Airphone
    SSH.Execute    sed -i "s|<GSCN>[0-9]*<\/GSCN>|<GSCN>${GSCN}<\/GSCN>|" /ffs/run/simmode/iphy.xml    connection=${AP_ASIK.connection}
    SSH.Execute    sed -i "s|<cell>[0-9].[0-9]</cell>|<cell>1.1</cell>|" /ffs/run/simmode/iphy.xml    connection=${AP_ASIK.connection}

Backup Gnb Sw Coniguration
    ${cmd}    Set Variable    cd /ffs/run/;cp ./swconfig.txt ./swconfig-TA.txt
    SSH.Execute    command=${cmd}    connection=${GNB_ASIK.connection}
Modify Gnb Sw Coniguration
    SSH.Execute    command=echo "0x59005D=1">>/ffs/run/swconfig.txt    connection=${GNB_ASIK.connection}
    SSH.Execute    command=crasign /ffs/run/swconfig.txt    connection=${GNB_ASIK.connection}

Recover Gnb Sw Coniguration
    ${cmd}    Set Variable    cd /ffs/run/;rm -rf ./swconfig.txt;mv swconfig-TA.txt swconfig.txt;crasign swconfig.txt
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} '${cmd}'
Recover Config
    ${bts_id}    Get BTS Id
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    Log To Console    recover gnb configuratio...
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${OUTPUT_DIR}/SCF_before_suite.xml
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    Run Keyword And Ignore Error    COAM.Teardown
Setup SA L3 Call
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_decode_muxphychan decode_mux_phy_chan=decode_PDSCH
    Log To Console    SA Attach...
    SA Register UE    ${UE_ID}    ${PROFILE_ID}
    SA 5G PDU Session Setup    ${UE_ID}
    Log To Console    SA Traffic...
    SA Start DL Traffic    ${DL_MBPS}    ${DURATION}
Load Cfg File
    [Arguments]    ${cfg_file}
    Log To Console    ${cfg_file}
    ute_wtssim.Execute Egate Command    cfg file\=${cfg_file}    pass_regexp=NG link is Up    timeout=360

Setup XP
    [Arguments]    ${nor_subframe}    ${prb_list}    ${min_dss_ratio}    ${max_dss_ratio}    ${min_prb_ratio}=50    ${max_prb_ratio}=50
    Setup XP LINK
    Set LTE NR DSS Mode
    Setup DSS Link
    Set DL RESOURCE Cell Reservation    ${min_dss_ratio}    ${max_dss_ratio}
    Cell Resource Coordination
    UL Resource Cell Reservation    ${min_prb_ratio}    ${max_prb_ratio}
    Cell Allocation    nor_subframe=${nor_subframe}    prb_list=${prb_list}

Clean Edaemon And Egate
    ute_wtssim.Teardown Edaemon    alias=edaemon
    ute_wtssim.Teardown Egate
Backup AP Config File
    ${cmd}    Set Variable    cd /ffs/run/simmode/;cp ./iphy.xml ./iphy-bak-TA.xml
    SSH.Execute    command=${cmd}    connection=${AP_ASIK.connection}

Recover AP Config File
    ${cmd}    Set Variable    cd /ffs/run/simmode/;rm -rf ./iphy.xml;mv iphy-bak-TA.xml iphy.xml
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} '${cmd}'

Modify Delta File
    Run    sed -i 's/10.0.1.1/10.0.1.121/g' ${JSON_PATH}/SCF/${DELTA_PATH_10M}
Recover Delta File
    Run    sed -i 's/10.0.1.121/10.0.1.1/g' ${JSON_PATH}/SCF/${DELTA_PATH_10M}

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}    ${timeout}
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log	  ${a}
	log    passed value of timeout - ${timeout}
#    ute_ue.Reboot UE    ${UE_alias}    timeout=${timeout}

Attach ue and run throughput
    [Arguments]     ${UE_alias}    ${dt_name}    ${direction}    ${throughput}     ${deviation}   ${timeout}
	log    passed value of timeout - ${timeout}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep     10
    ta_ultracaller.start_data_transfer	${UE_alias}	    ${dt_name}	direction=${direction}
#    Start Gnb BIP Log
    BuiltIn.Sleep   60s     reason=Capturing BIP logs
#    Stop Gnb BIP Log    ${OUTPUT_DIR}
#    Run Keyword And Continue On Failure     Collect eGEN Logs
#    EgenCollection
#    Run Keyword And Continue On Failure     Collect eGEN Logs
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    BuiltIn.Sleep   20s     reason=Gathering UE throughput logs from UC
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
    ...    direction=${direction}   thrughtput=${throughput}    deviation=${deviation}

EgenCollection
	SSH.Connect To    10.53.188.152    inbabtslabuser   BT5l@bus3rl0g1n   alias=egen
    Log to Console      SSH successful to egen setup
	SSH.Execute     sudo su     connection=egen
    Log to Console      super user changed to root
    SSH.Execute      cd /root/eGen/release/     connection=egen
    Log to Console      changed directory to release
	${contents}=    Execute      ethtool ens1f1    connection=egen
	log	   ${contents}
	SSH.Execute     ./egen --cores 1-8 --port 0000:03:00.1 --port 0000:03:00.0 --capture FJTTest_eGen.pcap --save-n-and-quit 100000
	...    connection=egen
	sleep    40
	Download File    /root/eGen/release/FJTTest_eGen.pcap    ${OUTPUT_DIR}/FJTTest_eGen.pcap    connection=egen



Collect eGEN Logs
    SSH.Connect To    10.53.188.154    inbabtslabuser    BT5l@bus3rl0g1n    alias=egen
    Log to console   --\n ssh DONE\n--
    ssh.Send Command    sudo su    connection=egen
    Log to console   --\n ssh DONE-2\n--
    ssh.Execute      cd /root/eGen/release    connection=egen
    Log to console   --\n ssh DONE-3\n--
	${contents}=    ssh.Execute      /root/eGen/release/ethtool ens1f1    connection=egen
	log	   ${contents}
    Log to console   --\n ru START EGEN LOGS\n--
    ssh.Execute     sudo /root/eGen/release/egen --cores 1-8 --port 0000:03:00.1 --port 0000:03:00.0 --capture FJTTest_2.pcap --save-n-and-quit 50000
    ...    connection=egen
	sleep    300
    ssh.Download File    /home/inbabtslabuser/FJTTest_2.pcap    ${OUTPUT_DIR}/FJTTest_2.pcap   connection=egen
#    #	[Arguments]		${TEST_VM_IP}		${TEST_VM_USERNAME}		${TEST_VM_PASSWORD}
#	sshlib.Open Connection		${EGEN_SERVER_IP}  	alias=egen
#    Log to console      SSH connection opened.
#	sshlib.Login		${EGEN_USERNAME}		${EGEN_PASSWORD}		delay=3
#    Log to console      Login successful
#    Sleep   5s      reason=sleeping for welcome message
#	sshlib.Execute Command		sudo su
#    Log to console      super user to eGen
#	sshlib.Execute Command		cd /root/eGen/release/
#    Log to console      change directory xto release
#	sshlib.Execute Command		rm -rf FJTTest*
#    Log to console      clearing release folder
#	sshlib.Execute Command		./egen --cores 1-8 --port 0000:03:00.1 --port 0000:03:00.0 --capture FJTTest_eGen.pcap --save-n-and-quit 100000
#	Sleep	5s      reason=sleeping for eGen
#	Execute Command		scp -r FJTTest_eGen.pcap ${TEST_VM_USERNAME}@${TEST_VM_IP}:${OUTPUT_DIR}/FJTTest_eGen.pcap
#	sshlib.Get File	/root/eGen/release/FJTTest_eGen.pcap		${OUTPUT_DIR}
#    Log to console      copying eGen logs to output_dir
#	sshlib.Close Connection
#    Log to console      Closing connection
