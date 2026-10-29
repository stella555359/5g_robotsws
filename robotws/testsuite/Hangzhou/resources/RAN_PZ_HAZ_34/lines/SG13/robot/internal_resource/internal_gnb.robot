*** Settings ***
Documentation    :copyright: Nokia
...              :contact: I_NSB_MN_RAN_RD_VRF_HAZ4_13@internal.nsn.com

*** Variables ***
${GNB_SWCONFIG_QUAL_NAME}    qual_swconfig.txt
${GNB_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${GNB_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${GNB_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

*** Keywords ***
Prepare gnb onair
    [Arguments]    ${custom_error}=${None}
    Check GPS status enable
    ${status0}    ${msg0}    Run Keyword And Ignore Error    Variable Should Exist    ${GNB_SWCONFIG_NAME}
    ${status1}    ${msg1}    Run Keyword And Ignore Error    Variable Should Exist    ${AP_SWCONFIG_NAME}
    Run Keyword If    '${status0}'=='PASS'    Put swconfig file to gnb    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_NAME}
#    ...    ELSE    Modify Swconfig for gnb
    Run Keyword If    '${status1}'=='PASS'    Airphone Upload Swconfig    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${AP_SWCONFIG_NAME}
    ...    ELSE    Modify Swconfig for AP
    Start capture gnb and ap syslog in 'before_onair' file
    Change iphy rru version    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${AIRPHONE_NAME}
    ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}
#    ${cfg_path}    Run Keyword If    '${FCT_BOARD_TYPE}' == 'ASIB'    Set variable    ${CURDIR}/../../KISS/cfg/${ABIO_CFG}
#    ...    ELSE    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
    ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
    ${ret}    Evaluate Xml Xpath    ${scfc_path}    count(//*[@name\='carrierAggregationSupportList']/p)
    ${type}    Run Keyword If    ${ret} == 1    Read Xml     ${scfc_path}    text|//*[@name\='carrierAggregationSupportList']/p
    ...    ELSE    Get carrierAggregation value    ${ret}    ${scfc_path}
#    Run Keyword If    'Nsa' in '${type}'    Configure NSA TL VM ETH
    Configure TL VM ETH
    Perform Full Commission And Reach Onair     ${scfc_path}    ${cfg_path}    2000    False    800    800
    Run Keyword If    'Nsa' in '${type}' and 'ABIL' in ${ASP_BOARD_TYPE}   Establish enb x2 link
    Stop capture gnb and ap syslog in 'before_onair' file '${custom_error}'
    Log To Console    BTS is onAir now
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump

Modify Swconfig for AP
    Modify AP swconfig    0x10041:5

Modify Swconfig for gnb
    Add GNB swconfig    0x340000:3

Get carrierAggregation value
    [Arguments]    ${ret}    ${scfc_path}
    ${len}    evaluate     int(${ret})+1
    ${type_list}    Create list
    FOR    ${i}     IN RANGE      1    ${len}
	    ${ca_value}    read_xml    ${scfc_path}     text|//*[@name\='carrierAggregationSupportList']/p[${i}]
	    Append to list    ${type_list}    ${ca_value}
    END
	${type}    catenate    ${type_list}[0]    ${type_list}[1]
    [Return]     ${type}

Qualcomm prepare gnb onair
    Copy Files    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}    ${test_log_directory()}
    ${scfc_path}    Set variable    ${test_log_directory()}${SCFC_NAME}
    Log To Console    ${test_log_directory()}
    ${status}    ${msg}    Run Keyword And Ignore Error    Variable Should Exist    ${AMFIPADDRESS}
    Run Keyword If    '${status}'=='PASS'    Modify scfc before commission    ${scfc_path}
    Start capture only gnb syslog in 'before_onair' file
#    Put swconfig file to gnb    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME}
    Do Full Commissioning    ${scfc_path}
    Wait '100s' for stable
    Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Stop capture only gnb syslog in 'before_onair' file
    Log To Console    BTS is onAir now
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump

Modify Vendor and Qualcomm prepare gnb onair
    Copy Files    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}    ${test_log_directory()}/
    ${scfc_path}    Set variable    ${test_log_directory()}/${SCFC_NAME}
    ${status}    ${msg}    Run Keyword And Ignore Error    Variable Should Exist    ${AMFIPADDRESS}
    Run Keyword If    '${status}'=='PASS'    Modify scfc before commission    ${scfc_path}
    TAF_ADMIN.Setup Admin
    ${vendor_path}    Set Variable    ${test_log_directory()}/vendor_ini.xml
    TAF_ADMIN.Download Vendor File    ${vendor_path}
    Modify Vendor XML File    ${vendor_path}
    TAF_ADMIN.Set Vendor File    ${vendor_path}
    Start capture only gnb syslog in 'before_onair' file
#    Do Full Commissioning    ${scfc_path}
    ${connission_status}    Run Keyword And Return Status    TAF_ADMIN.Perform Commissioning
    ...    bts_id=${GNB_IP}
    ...    scf_file=${scfc_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    Log to console    Full Commissioning is ${connission_status}
    TAF_ADMIN.teardown admin
#    Put swconfig file to gnb    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_QUAL_NAME}
    Wait '100s' for stable
    Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Stop capture only gnb syslog in 'before_onair' file
    Log To Console    BTS is onAir now
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump

Modify scfc before commission
    [Arguments]    ${scfc_path}
    ${modify_list}    create list    text|${AMFIPADDRESS}|//*[@name\="amfIPAddress"]
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}

Qualcomm prepare gnb onair to another gnb
    [Arguments]    ${s1_ip}    ${scfc_name}
    Start capture only gnb syslog in 'before_onair_4g' file
    Perform full commissioning to another gnb    ${s1_ip}    ${scfc_name}
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
    Stop capture only gnb syslog in 'before_onair_4g' file
    Log To Console    BTS is onAir now

Perform full commissioning to another gnb
    [Arguments]    ${s1_ip}    ${scfc}
    ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${scfc}
    ${btsName}    read_xml    ${scfc_path}    text|//*[@name\='btsName']
    TAF_ADMIN.connect to    bts_host=${s1_ip}    bts_port=443    use_ssl=True    name=perform
    TAF_ADMIN.Perform Commissioning    ${btsName}    ${scfc_path}    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=1800    connection=perform
    TAF_ADMIN.teardown admin    connection=perform

Put swconfig file to gnb
    [Arguments]     ${sw_path}
    Setup eNB Fsm Access    alias=putswconfig
    Put Enb Swconfig File    ${sw_path}    alias=putswconfig
    Execute Command On Enb    crasign /ffs/run/swconfig.txt    alias=putswconfig
    Teardown Enb Fsm Access    alias=putswconfig

Perform online change value
    [Arguments]    ${dist_name}    ${parameter}    ${value}    ${alias}
    TAF_ADMIN.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}    operation=update    value=${value}
    ...    skip_parameter_relation_errors=True    should_activate=True    connection=${alias}

Establish enb x2 link
    Airphone Execute Egate Command    enb_x2_link_up enb\=1 target\=2

Configure TL VM ETH
    Log To Console    Configure NSA VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.139/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.141/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.142/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.143/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.127/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.106/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.102/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3

Unblock one 4G cell
    [Arguments]    ${phy_cell_id}    ${bts_id}=192.168.255.129    ${alias}=block
    TAF_ADMIN.connect to    bts_host=${bts_id}    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}    TAF_ADMIN.Get Parameters For All    LNCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.blockingState}'=='Unblocked'    TAF_ADMIN.block cell    ${nrcel.id}    timeout=60    connection=${alias}
    END
    Wait '5s' for stable
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.phyCellId}'=='${phy_cell_id}'    TAF_ADMIN.unblock cell    ${nrcel.id}    timeout=60    connection=${alias}
    END
    TAF_ADMIN.teardown    connection=${alias}

BlockingState block cell
    [Arguments]    ${phy_cell_id}    ${alias}
    log to console   block Cell${phy_cell_id}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='Unblocked'
    ...    Run Keywords    TAF_ADMIN.block cell    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

BlockingState unblock cell
    [Arguments]    ${phy_cell_id}    ${alias}
    log to console   unblock Cell${phy_cell_id}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.blockingState}'=='Blocked'
    ...    Run Keywords    TAF_ADMIN.unblock cell    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

AdministrativeState lock cell
    [Arguments]    ${phy_cell_id}    ${alias}
    log to console   block Cell${phy_cell_id}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'
    ...    Run Keywords    TAF_ADMIN.lock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

AdministrativeState unlock cell
    [Arguments]    ${phy_cell_id}    ${alias}
    log to console   unblock Cell${phy_cell_id}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Locked'
    ...    Run Keywords    TAF_ADMIN.unlock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

Perform Full Commission And Reach Onair penny
    [Arguments]     ${scfc}      ${wts_config}    ${wait_onair_timeout}    ${reset_after_commission}
    ...             ${wait_bts_timeout}    ${wait_rru_timeout}
    Log to console    Perform Full Commissioning And Reach Onair start.
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc}    ${test_log_directory()}/full_commission/
    ${connission_status}    Run Keyword And Return Status    Perform Full Commission     ${new_scfc}
    Log to console    Full Commissioning is ${connission_status}
    Wait '100s' for stable
    Run Keyword If    '${connission_status}' == 'False'    Hard reboot env
    Run Keyword If    '${connission_status}' == 'True' and '${reset_after_commission}'=='True'     Reboot gnb and ap via ssh
    FOR    ${loop}    IN RANGE    3
        ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
        Run Keyword If    '${bts_status}' == 'False' and ${loop} < 1    Reboot gnb and ap via ssh
        Continue For Loop If    '${bts_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${bts_status}' == 'False' and ${loop} == 1    Hard reboot env
        Continue For Loop If    '${bts_status}' == 'False' and ${loop} == 1
        Run Keyword If    '${bts_status}' == 'False' and ${loop} > 1    Fail
        ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
        Run Keyword If    '${rru_status}' == 'False' and ${loop} < 1    Reboot gnb and ap via ssh
        Continue For Loop If    '${rru_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${rru_status}' == 'False' and ${loop} == 1    Hard reboot env
        Continue For Loop If    '${rru_status}' == 'False' and ${loop} == 1
        Run Keyword If    '${rru_status}' == 'False' and ${loop} > 1    Fail
        Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
        ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${wts_config}
        ...    timeout=${wait_onair_timeout}
        Return From Keyword If    '${onair_status}' == 'True'
        Run Keyword If    '${onair_status}' == 'False' and ${loop} < 1    Reboot gnb and ap via ssh
        Run Keyword If    '${onair_status}' == 'False' and ${loop} == 1    Hard reboot env
        Run Keyword If    '${onair_status}' == 'False' and ${loop} > 1    Fail
    END

Hard reboot env
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump
    hard_reboot
    Wait '100s' for stable
    Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump

Check GPS status enable
    Wait Until Keyword Succeeds    30min    2min    Get GPS status on coam

Get GPS status on coam
    TAF_ADMIN.connect_to    bts_host=${GNB_IP}    name=gps
    ${gps_status}    TAF_ADMIN.get_gnsses_statuses    timeout=120    connection=gps
    should be equal    ${gps_status['GNSSE_R-1']['administrativeState']}    Unlocked
    ${enabled}    Convert To Lowercase    ${gps_status['GNSSE_R-1']['operationalState']}
    should be equal    ${enabled}    enabled
    Log To Console    gps status is '${gps_status['GNSSE_R-1']['operationalState']}'
    [Teardown]  run keyword and ignore error  TAF_ADMIN.teardown   connection=gps

Reboot gnb and ap via ssh
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump
    Log To Console    -------- Reboot testline via ssh --------
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} 'reboot'
    Wait Until Keyword Succeeds    60s    2s    check ping is disabled    ${GNB_ASIK.ip}
    Wait Until Keyword Succeeds    240s    5s    check ping is enabled    ${AP_ASIK.ip}
    Wait Until Keyword Succeeds    240s    5s    check ping is enabled    ${GNB_ASIK.ip}
    Wait '100s' for stable
    Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
    
Modify AP swconfig
    [Arguments]    @{Rdparameter}
    Backup AP Swconfig File    ${CURDIR}    ap_swconfig.txt
    setup_txt    src_file=${CURDIR}/ap_swconfig.txt    save_path=${CURDIR}/ap_swconfig_modify.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        modify txt node        ${parameter}
    END
    teardown txt
    Airphone Upload Swconfig    ${CURDIR}/ap_swconfig_modify.txt

Add AP swconfig
    [Arguments]    @{Rdparameter}
    Backup AP Swconfig File    ${CURDIR}    ap_swconfig.txt
    setup_txt    src_file=${CURDIR}/ap_swconfig.txt    save_path=${CURDIR}/ap_swconfig_modify.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        ${key}    ${value}    Split String    ${parameter}    :
        run keyword and ignore error    delete txt node    ${key}
        add txt node        ${parameter}
    END
    teardown txt
    Airphone Upload Swconfig    ${CURDIR}/ap_swconfig_modify.txt

Modify GNB swconfig
    [Arguments]    @{Rdparameter}
    Backup Swconfig    ${CURDIR}     gnb_swconfig.txt
    setup_txt    src_file=${CURDIR}/gnb_swconfig.txt    save_path=${CURDIR}/gnb_swconfig_modify.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        modify txt node        ${parameter}
    END
    teardown txt
    GNB Upload Swconfig    ${CURDIR}/gnb_swconfig_modify.txt

Add GNB swconfig
    [Arguments]    @{Rdparameter}
    Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
    setup_txt    src_file=${CURDIR}/gnb_swconfig.txt    save_path=${CURDIR}/gnb_swconfig_modify.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        ${key}    ${value}    Split String    ${parameter}    :
        run keyword and ignore error    delete txt node    ${key}
        add txt node    ${parameter}
    END
    teardown txt
    GNB Upload Swconfig    ${CURDIR}/gnb_swconfig_modify.txt

Download original airphone l1bypass
    TAF_SSH.connect to    ${AP_ASIK_IP}   ${GNB_USERNAME}    ${GNB_PASSWORD}   alias=iphy
    TAF_SSH.connect to    192.168.253.85    ${GNB_USERNAME}    ${GNB_PASSWORD}    alias=bsh    proxy=iphy
    ${ret}    TAF_SSH.execute    ls /tmp    connection=bsh
    TAF_SSH.download file    /tmp/L1ByPTestModeConfiguration.xml    ${test_log_directory()}/L1ByPTestModeConfiguration.xml    connection=bsh
    TAF_SSH.download file    /tmp/L1ByPTestModeConfiguration.xml    ${test_log_directory()}/L1ByPTestModeConfiguration_back.xml    connection=bsh

Upload airphone l1bypass to iphy
    TAF_SSH.connect to    ${AP_ASIK_IP}    ${GNB_USERNAME}    ${GNB_PASSWORD}    alias=iphy
    TAF_SSH.upload file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${L1BYP_XML}    /ffs/run/logs/L1ByPTestModeConfiguration.xml   connection=iphy
    ${ret}    TAF_SSH.execute    ls /ffs/run/logs    connection=iphy

Modify 8247 Swconfig
    Add GNB swconfig    0x580264:0x1F
    Add GNB swconfig    0x580477:1
    Add GNB swconfig    0x590105:1
    Add GNB swconfig    0x590104:0
    Add GNB swconfig    0x580434:0

Active GNB L2 feature debug traces
    [Arguments]    ${position}=5
    TAF_SSH.connect to    ${GNB_IP}   ${GNB_USERNAME}    ${GNB_PASSWORD}   alias=bsh
    ${vpath}    Set Variable    /ffs/run/swpool/L2RT/addons
    ${ret}    TAF_SSH.execute    rm -rf /ffs/run/boardcfg/${position}/A/mcu-aspd/addons/trace.tgz    connection=bsh
    ${ret}    TAF_SSH.execute    rm -rf /ffs/run/boardcfg/${position}/A/mcu-aspd/addons/trace.tgz.p7    connection=bsh
    ${ret}    TAF_SSH.execute    rm -rf ${vpath}/.*    connection=bsh
    ${ret}    TAF_SSH.execute    mkdir -p ${vpath}    connection=bsh
    ${local_path}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/feature_log_activation.txt
    OperatingSystem.Run    mkdir -p ${test_log_directory()}/var/preserve/
    OperatingSystem.Run    cp ${local_path} ${test_log_directory()}/var/preserve/
    OperatingSystem.Run    cd ${test_log_directory()};tar czf trace.tgz var/preserve/feature_log_activation.txt
    ${cmd}=    Set Variable    sshpass -p ${GNB_PASSWORD} scp ${test_log_directory()}/trace.tgz ${GNB_USERNAME}@${GNB_IP}:${vpath}
    OperatingSystem.Run    ${cmd}
    ${ret}    TAF_SSH.execute    crasign ${vpath}/trace.tgz    connection=bsh
    ${ret}    TAF_SSH.execute    ln ${vpath}/trace.tgz /ffs/run/boardcfg/${position}/A/mcu-aspd/addons/trace.tgz    connection=bsh
    ${ret}    TAF_SSH.execute    ln ${vpath}/trace.tgz.p7 /ffs/run/boardcfg/${position}/A/mcu-aspd/addons/trace.tgz.p7    connection=bsh
    ${ret}    TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh

Modify vendor file and full commission for onair
    [Arguments]    ${wait_bts_timeout}=2000    ${wait_rru_timeout}=800    ${wait_onair_timeout}=800
    Modify Swconfig for AP
    Start capture gnb and ap syslog in 'before_onair' file
    Change iphy rru version    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${AIRPHONE_NAME}
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
    Wait '10s' for stable
    ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}
    ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc_path}    ${test_log_directory()}/full_commission/
    Configure TL VM ETH
    TAF_ADMIN.Setup Admin
    ${vendor_path}    Set Variable    ${test_log_directory()}/vendor_ini.xml
    TAF_ADMIN.Download Vendor File    ${vendor_path} 
    Modify Vendor XML File    ${vendor_path}
    TAF_ADMIN.Set Vendor File    ${vendor_path}
    ${connission_status}    Run Keyword And Return Status    TAF_ADMIN.Perform Commissioning
    ...    bts_id=${GNB_IP}
    ...    scf_file=${new_scfc}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300     
    Log to console    Full Commissioning is ${connission_status}
    TAF_ADMIN.teardown admin
    Wait '120s' for stable
    Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
    ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
    ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
    ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${cfg_path}
    ...    timeout=${wait_onair_timeout}
    Stop capture gnb and ap syslog in 'before_onair' file
    Log To Console    BTS is onAir now
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump
    Establish enb x2 link


Modify Vendor XML File 
    [Arguments]    ${vendor_path} 
    ${vendor_list32}    create list    ${EMPTY}
    ${vendor_list64}    create list    ${EMPTY}
    ${status0}    ${msg0}    Run Keyword And Ignore Error    Variable Should Exist    ${VENDOR_PARAMETER_C32}
    ${status1}    ${msg1}    Run Keyword And Ignore Error    Variable Should Exist    ${VENDOR_PARAMETER_C64}
    ${vendor_list32}    Run Keyword If    '${status0}'=='PASS'    Modify vendor C32    ${vendor_list32}
    ${vendor_list64}    Run Keyword If    '${status0}'=='PASS'    Modify vendor C64    ${vendor_list64}
    ${modify_list}    Combine Lists    ${vendor_list32}    ${vendor_list64}
    Modify Xml    ${vendor_path}    ${vendor_path}    ${modify_list}

Modify vendor C64
    [Arguments]    ${vendor_list64}
    FOR    ${parameter}    IN    @{VENDOR_PARAMETER_C64}
        ${key}    ${val}    Split String    ${parameter}    :
        ${element}    Set Variable    text|${val}|//*[@name\='bbL1SpPrbInitCapacity']/item[5]/*[@name\='${key}']
        Append To List    ${vendor_list64}    ${element}
    END
    [Return]    ${vendor_list64}

Modify vendor C32
    [Arguments]    ${vendor_list32}
    FOR    ${parameter}    IN    @{VENDOR_PARAMETER_C32}
        ${key}    ${val}    Split String    ${parameter}    :
        ${element}    Set Variable    text|${val}|//*[@name\='bbL1SpPrbInitCapacity']/item[1]/*[@name\='${key}']
        Append To List    ${vendor_list32}    ${element}
    END
    [Return]    ${vendor_list32}

online act CB08322 debug flag
	Execute Aashell Command    rad -mw 0x58057f 0x10000		#rdFeatureFlagBitmap4_bit16:L2.L2_PS.DL.SUBBAND_BEAMFORMING
	Execute Aashell Command    rad -mw 0x58057a 0x4			#rdFeatureFlagBitmapLevel:4:debug

Add RD for CB009496
    Add GNB swconfig     0x5901E8:1        #CPRT rdActCB009496 (enable pattern id allocation and rtBeamConfig validation.)
    Add GNB swconfig     0x600013:1        #BOAM_RAT_ADAPT ()
    Add GNB swconfig     0x19040F:1        #BOAM_FRONTHAUL
    Add GNB swconfig     0x42008E:1        #BOAM DCS
    Add GNB swconfig     0x88004B:0        #L1 FH, rdEnableSktMvp
    Add GNB swconfig     0x880031:14       #L1 FH, rdBwvTxOpportunities (symbols/slot for sending BWV)
    Add GNB swconfig     0x580556:65535    #rdStartPatternId  (default 5000 for SKT MVP, 65535 for 9496)

Perform Full Commission And Reach Onair With Log
    [Arguments]     ${scfc}      ${wts_config}    ${wait_onair_timeout}=1500    ${reset_after_commission}=${False}
    ...             ${wait_bts_timeout}=600    ${wait_rru_timeout}=600    ${L1b}=False
    [Documentation]    This keyword will use ${scfc} to do full commission, and use ${wts_config} to start wts process and check onair
    ...    | Input Parameters | Man. | Description |
    ...    | scfc | Yes | SCF file path. |
    ...    | wts_config | Yes | WTS config file |
    ...    | wait_onair_timeout | No | timeout to check onair. Default is 1500 |
    ...    | reset_after_commission | No | Will reset bts after commission.Default is False |
    ...    Examples:
    ...    | Perform Full Commission And Reach Onair | scfc.xml |  wts_config.xml |
    Log to console    Perform Full Commissioning And Reach Onair start.
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc}    ${test_log_directory()}/full_commission/
    Perform Full Commission     ${new_scfc}
    Run Keyword If    '${reset_after_commission}'=='True'     Reset Testline
    FOR    ${loop}    IN RANGE    2
        ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
        Run Keyword If    '${bts_status}' == 'False' and ${loop} < 1    Reset Testline
        Continue For Loop If    '${bts_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${bts_status}' == 'False' and ${loop} >= 1    Fail
        ${remote info}     Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
        run keyword and ignore error    Start Tcpdump    cellSetup${loop}    -i any    ${remote info}
        ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
        Run Keyword If    '${rru_status}' == 'False' and ${loop} < 1    Reset Testline
        Continue For Loop If    '${rru_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${rru_status}' == 'False' and ${loop} >= 1    Fail
        Run Keyword If    '${L1b}' == 'True'
        ...    Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
        ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${wts_config}
        ...    timeout=${wait_onair_timeout}
        Run Keyword If    '${onair_status}' == 'True'    Stop Tcpdump       cellSetup${loop}     ${test_log_directory()}
        OperatingSystem.Run    mv ${test_log_directory()}/cellSetup*.pcap ${test_log_directory()}/cellSetup0.pcap
        Return From Keyword If    '${onair_status}' == 'True'
        Run Keyword If    '${onair_status}' == 'False' and ${loop} < 1    Reset Testline
        Run Keyword If    '${onair_status}' == 'False' and ${loop} >= 1    Fail
    END
