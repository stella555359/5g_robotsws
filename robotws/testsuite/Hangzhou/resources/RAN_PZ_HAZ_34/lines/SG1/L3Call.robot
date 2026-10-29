*** Settings ***
Documentation
...   author: Hongyan Yuan
...   contact: hongyan.1.yuan@nokia-sbell.com
...   Common KWs related to Classicalbts.
...   Very common operation is put in this file
...   WA and case proccess is put to case file
#TAF LIB            /home/ute/Projects/robotws5g/py2713/lib/python2.7/site-packages/taf
Library             String
Library             OperatingSystem
Library             Collections
Library             BuiltIn
Library             taf.transport.ssh		WITH NAME	ssh
Library             Telnet  WITH NAME   telnet
Library             taf.epcsim    WITH NAME    epc
Library             taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Library             taf.gnb.oam.commissioning    WITH NAME    commissioning
Library             taf.gnb.oam.megazone_client    WITH NAME    megazone_client
Library             taf.config.scf    WITH NAME    scf
Library             taf.ue.tm500.rci       WITH NAME    e500
Library             ute_tshark    WITH NAME    TSK
Library             taf.pdu
Library             DateTime
Library    taf.analyzer.pcap       WITH NAME   pcap
Library             taf.sbts.oam.coam.admin    WITH NAME    coam
#Library             ../../../../../resources/python_libs/HDBDE_upgrade.py
#Library             ../../../../../../../resources/python_libs/HDBDE.py
#Library             taf.rfrl.common_resources.python.HDBDE
#Library             ../../../../../../../resources/python_libs/gnb_classical.py
Library             taf.rfrl.common_resources.python.gnb_classical    WITH NAME   gnb_classical
Library             L3Call.py
Variables           L3CallConfiguration.py
Library             L3CallScript.py
#Library             ../../../../../resources/python_libs/pdu/facom_api.py
Resource            taf/rfrl/common_resources/robot/preconditions.robot
Library             prisma_ipmi.py
Library             prisma_ipmi.prisma   WITH NAME    ipmi
Library             Collections
Library             check_container.py
Library             check_container.demplowment   WITH NAME    DP
Library             taf.collectors.core   WITH NAME   core
Library             taf.collectors.btslog  WITH NAME   btslog
Library             taf.hw.rf_attenuator    WITH NAME    PA_
Library             taf.ul.mobile.ui.android     WITH NAME   android_mobile
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library             taf.sw.dcap.rd		WITH NAME	rd
Library      process_data_in_file.py
Library      process_data_in_file.DcapTrace    WITH NAME   dcap
Library      process_data_in_file.SherpaCsv    WITH NAME   sherpa
Library      process_data_in_file.HtmlParser     WITH NAME    html
Library      process_data_in_file.TextWriter     WITH NAME    text
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
*** Variables ***
#${MRBTS_ID}     MRBTS ID for gnb.eg:MRBTS-12345
#${NRBTS_ID}     NRBTS ID for gnb.eg:NRBTS-12345
#${DIST_NAME}    Combine MRBTS ID and NRBTS ID,easy to us in cases.eg:MRBTS-12345/NRBTS-12345
#${GoldenSCF_PATH}    Golden scf path for each stream.
#                         eg:/opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
#${TLDelta_PATH}     Testline detla file path.
#                       eg:/opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}

${CFGFILE_PATH}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
${GoldenSCF_ON_GIT}     /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
${UPDATE_FILE_PATH}     /home/ute/Download_gNB_Package
# Common variable rarely need modify
${OAM_TYPE}                 coam
${ALIAS_E500_APP}           ALIAS_E500_APP
${ALIAS_E500}               ALIAS_E500
${ALIAS_UTE}                ALIAS_UTE
${E500_ASC_USER}            switch
${E500_ASC_PW}              switch
#${ALIAS_APPSERVER}          appserver

${SHP_IP}                   192.168.129.2
${ASP_1A_IP}                192.168.253.20
${LONER_IP}                 192.168.253.22
${FCT_IP}                   192.168.253.17
${FCT_IP_1}                 192.168.253.33
${PrimaryDefaultIP}         192.168.255.129
${SecondaryDefaultIP}       192.168.255.119
${ASIK_USERNAME}            toor4nsn
${ASIK_PASSWORD}            oZPS0POrRieRtu
${EDAEMON_PORT_IPHY}        10000
${EDAEMON_PORT_EPC_SIM}     10010
${EDAEMON_PORT_L3_SIM}      10020
${EGATE_PROCESS_PORT}       20000
${FileToRecordCurrentVersion}    ${OUTPUT DIR}/../current_version_for_rp.txt

${SCF_FILE_PATH}            /tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19/5gClassicalBTS
${UE_NUM}    1
${link_to_Artifact}      https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/
${link_to_Artifact_WFT}  https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
${link_to_Artifact_SBTS}      https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/
${link_to_Artifact_SBTS_WFT}      https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/
${testline_name}      null
${CONFIGURATION}      null


*** Keywords ***

#------------------------WEBUI/Megazone basic Operation ----------------------------------------------------------------
TTEST
    log to console    L3Call Test
    #COAM_Admin.CommissoneNBbyStream   IP=10.57.251.188

WEBUI.Login
    run   command=killall firefox
    Sleep   10
    selenium_megazone.enable virtual display
    wait until keyword succeeds     5min    1min    selenium_megazone.login
    ...     url=https://${ASIK_IP}    username=Nemuadmin    password=nemuuser
WEBUI.SetParameterValue
    [Arguments]    ${distName}=MRBTS-1900    ${abbr}=btsName    ${value}=TL008
    selenium_megazone.change_text_value    dist_name=${distName}    abbr=${abbr}    new_value=${value}    timeout=40
WEBUI.ValidateAndActiveParameters
    selenium_megazone.validate_changes    timeout=40
    ${error}    selenium_megazone.get_validation_error
    should be empty    ${error}
    selenium_megazone.activate_changes    timeout=40
WEBUI.Logout
    selenium_megazone.logout
    selenium_megazone.disable_virtual_display
    run   command=killall firefox
    run   command=killall Xvfb
WEBUI.ModifyMCS
    [Arguments]    ${mcs}=0
    Run Keyword And Ignore error    WEBUI.SetParameterValue
    ...    MRBTS-1900/NRBTS-1/NRCELL-1    dllaIniMcs    ${mcs}
    Run Keyword And Ignore error    WEBUI.SetParameterValue
    ...    MRBTS-1900/NRBTS-1/NRCELL-1    ullaIniMcs    ${mcs}
    #Run Keyword And Ignore error    WEBUI.ValidateAndActiveParameters
WEBUI.ModifyMCSUL
    [Arguments]    ${mcs}=0
    Run Keyword And Ignore error    WEBUI.SetParameterValue
    ...    MRBTS-1900/NRBTS-1/NRCELL-1    ullaIniMcs    ${mcs}
WEBUI.ModifyMCSDL
    [Arguments]    ${mcs}=0
    Run Keyword And Ignore error    WEBUI.SetParameterValue
    ...    MRBTS-1900/NRBTS-1/NRCELL-1    dllaIniMcs    ${mcs}
WEBUI.ActiveParameterIgnoreError
    Run Keyword And Ignore error    WEBUI.ValidateAndActiveParameters
WEBUI.UpdateSW
    [Arguments]    ${file_path}   ${stream}=5GBTS
    run   command=killall /usr/bin/firefox
    selenium_megazone.enable virtual display
    wait until keyword succeeds     15min    1min    selenium_megazone.login
    ...     url=https://${ASIK_IP}    username=Nemuadmin    password=nemuuser
    Run Keyword And Ignore error    selenium_megazone.add software file    file_path=${file_path}    timeout=120
    sleep   60s
    selenium_megazone.activate after download    #enable=False
    ${result}=  selenium_megazone.check software file version
    should contain    ${result}    ${stream}
    selenium_megazone.start update software
    wait until keyword succeeds     60min    10s    SoftwareUpdate.CheckgNBUpdateStatus    info=Signing files
    sleep   15min
    selenium_megazone.Disable Virtual Display

WEBBUI.BackupSCF
    run   command=killall /usr/bin/firefox
    selenium_megazone.enable_virtual_display
    wait until keyword succeeds     15min    1min    selenium_megazone.login
    ...     url=https://${ASIK_IP}    username=Nemuadmin    password=nemuuser
    ${scffile}    selenium_megazone.backup_configuration
    selenium_megazone.logout
    selenium_megazone.Disable Virtual Display
    [Return]   ${scffile}

Megazone.commission
    [Arguments]   ${scf_file}
    commissioning.wait for oam node port    oam_node_ip=${ASIK_IP}
    #ssh.reset_cache
    commissioning.commission  oam_ip=${ASIK_IP}  scf_xml=${scf_file}  expected_phase=1  oam_reboot_time=120

#---------------------COAM basic operation (COAM_Admin_ indacates backend lib,COAM_WebEM_ indicates frontend lib.-------
COAM_Admin.Login
    [Arguments]   ${bts_host}=${WEBUI_IP}   ${username}=${WEBUI_USERNAME}   ${password}=${WEBUI_PASSWORD}
    ...   ${bts_port}=${443}   ${log_dir}=${OUTPUT_DIR}   ${alias}=COAM

    coam.connect_to
    ...   bts_host=${bts_host}
    ...   bts_port=${bts_port}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${log_dir}
    ...   name=${alias}
    ${BTSInfo}      coam.get_bts_info      connection=${alias}
    ${release}      String.Split String    ${BTSInfo['swInfo']['swVersion']}   _
    ${release}      set variable           ${release}[0]
    coam.teardown   connection=${alias}
    coam.connect_to
    ...   bts_host=${bts_host}
    ...   bts_port=${bts_port}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${log_dir}
    ...   name=${alias}
    ...   release=${release}

COAM_Admin.Logout
    [Arguments]   ${connection}=COAM
    coam.teardown      connection=${connection}

COAM_Admin._InsetChild
    [Arguments]   ${list}    ${child}    ${id}
    ${length}=   Get Length   ${list}
    run keyword if   ${length}==0   run keywords    Insert Into List    ${list}    0    ${child}    AND   Continue For Loop
    ${index}    set variable    ${0}
    FOR  ${item}  IN  @{list}
        run keyword if  ${child['${id}']}<${item['${id}']}    run keywords
        ...        Insert Into List    ${list}    ${index}    ${child}    AND    Exit For Loop
        ${index}    set variable    ${index+1}
    END
    run keyword if     ${index}>=${length}    Insert Into List    ${list}    ${index}    ${child}

COAM_Admin._GetChildMods
    [Arguments]   ${scf}    ${Module}=MRBTS-207/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ${output}    run    grep CABLINK ${scf}
    ${CablinksInfo}    get regexp matches    ${output}     MRBTS-[0-9]+/EQM-[0-9]+/HWTOP-[0-9]+/CABLINK-[0-9]+
    scf.Load Scf          file_path=${scf}
    ${Childs}    create list
    FOR  ${CablinkInfo}  IN  @{CablinksInfo}
        ${fdn}  scf.get_value_from_scf    dist_name=${CablinkInfo}    p_name=firstEndpointDN
        run keyword if     '${fdn}'!='${Module}'     Continue For Loop
        ${portId}  scf.get_value_from_scf    dist_name=${CablinkInfo}    p_name=firstEndpointPortId
        ${name}   scf.get_value_from_scf    dist_name=${CablinkInfo}    p_name=secondEndpointDN
        ${PreId}    ${id}    Split String From Right	 string=${name}   separator=-     max_split=1
        ${child}    create dictionary    id    ${id}    name    ${name}    portId    ${portId}
        COAM_Admin._InsetChild    list=${Childs}    child=${child}    id=portId
    END
    scf.Save Scf          file_path=${scf}
    [Return]   ${Childs}

COAM_Admin._BuildBBMoDsASOE
    [Arguments]    ${scf}    ${BBMODs}    ${BTSInfo}
    ${Childs}    create list
    ${child}    create dictionary    id    ${0}    name    ASOE    portId    ${0}
    ${RMODs}    COAM_Admin._BuildRMODs    scf=${scf}    RMODs=${BBMODs}    BTSInfo=${BTSInfo}
    Set To Dictionary    ${child}    RUs    ${RMODs}
    Append to list    ${Childs}    ${child}
    [Return]   ${Childs}

COAM_Admin._BuildBBMODsDefault
    [Arguments]    ${scf}    ${BBMODs}    ${BTSInfo}
    ${index}    set variable    ${0}
    FOR  ${Item}  IN  @{BBMODs}
        ${RMODs}    COAM_Admin._GetChildMods    scf=${scf}    Module=${Item['name']}
        ${RMODs}    COAM_Admin._BuildRMODs    scf=${scf}    RMODs=${RMODs}    BTSInfo=${BTSInfo}
        Set To Dictionary    ${Item}    RUs    ${RMODs}
        Set List Value    ${BBMODs}    ${index}    ${Item}
        ${index}    set variable    ${index+1}
    END
    [Return]   ${BBMODs}

COAM_Admin._BuildBBMODs
    [Arguments]    ${scf}    ${BBMODs}    ${BTSInfo}    ${SMODTypeString}
    ${BBMODs}    run keyword if    ${SMODTypeString.count('ASOE')}>0
    ...    COAM_Admin._BuildBBMoDsASOE   scf=${scf}    BBMODs=${BBMODs}   BTSInfo=${BTSInfo}
    ...    ELSE    COAM_Admin._BuildBBMODsDefault    scf=${scf}    BBMODs=${BBMODs}   BTSInfo=${BTSInfo}
    [Return]   ${BBMODs}
#    return from keyword if    ${BBMODs.count('RMOD')}>0    ${BBMODsASOE}
#    ${index}    set variable    ${0}
#    FOR  ${Item}  IN  @{BBMODs}
#        ${RMODs}    COAM_Admin._GetChildMods    scf=${scf}    Module=${Item['name']}
#        ${RMODs}    COAM_Admin._BuildRMODs    scf=${scf}    RMODs=${RMODs}    BTSInfo=${BTSInfo}
#        Set To Dictionary    ${Item}    RUs    ${RMODs}
#        Set List Value    ${BBMODs}    ${index}    ${Item}
#        ${index}    set variable    ${index+1}
#    END
#    [Return]   ${BBMODs}

COAM_Admin._BuildRMODs
    [Arguments]    ${scf}    ${RMODs}    ${BTSInfo}
    ${index}    set variable    ${0}
    FOR  ${Item}  IN  @{RMODs}
        ${Cells}    COAM_Admin._BuildCellInfo    scf=${scf}    Module=${Item['name']}    BTSInfo=${BTSInfo}
        Set To Dictionary    ${Item}    Cells    ${Cells}
        Set List Value    ${RMODs}    ${index}    ${Item}
        ${index}    set variable    ${index+1}
    END
    [Return]   ${RMODs}

COAM_Admin._BuildCellInfo
    [Arguments]   ${scf}    ${Module}    ${BTSInfo}
    scf.Load Scf          file_path=${scf}
    ${Childs}    create list
    ${CellsInfo}    set variable    ${BTSInfo['cells']['nr']}
    FOR  ${item}  IN  @{CellsInfo}
#    \    ${rmodlist}  scf.get_value_from_scf    dist_name=${item['id']['configuration']}    list_name=rModDNList
        ${CellUnderRmod}    Basic.CheckContainString    substring=${Module}   string='${item['carrierList']}'
        run keyword if     '${CellUnderRmod}'!='true'     Continue For Loop
        ${child}    create dictionary    id   ${item['globalCellId']}    name    ${item['id']['configuration']}
        COAM_Admin._InsetChild    list=${Childs}    child=${child}    id=id
    END
    scf.Save Scf          file_path=${scf}
    [Return]   ${Childs}

COAM_Admin.GetBTSTopology
    ${scf}     COAM_Admin.BackupSCF
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${SMODs}      create list
    ${modInfo}    set variable    ${BTSInfo['systemModules']}
    FOR  ${mod}  IN  @{modInfo}
        ${BBMODs}    COAM_Admin._GetChildMods    scf=${scf}    Module=${mod['id']['configuration']}
        ${BBMODs}    COAM_Admin._BuildBBMODs     scf=${scf}    BBMODs=${BBMODs}    BTSInfo=${BTSInfo}   SMODTypeString=${mod['productName']}
        ${index}    get regexp matches   ${mod['id']['configuration']}    SMOD-(.)    1
        ${child}     create dictionary    id   ${index[0]}    name    ${mod['id']['configuration']}
        Set To Dictionary    ${child}    BBMODs   ${BBMODs}
        COAM_Admin._InsetChild    list=${SMODs}    child=${child}    id=id
    END
    [Return]   ${SMODs}

COAM_Admin.CheckAllCellsOnair
    [Documentation]   type is lte nr gsm
    [Arguments]   ${type}=nr    ${bts_host}=${WEBUI_IP}
    ${BTSInfo}      COAM_Admin.GetBTSInfo    bts_host=${bts_host}
    ${CellsInfonr}    set variable    ${BTSInfo['cells']['nr']}
    ${CellsInfolte}    set variable    ${BTSInfo['cells']['lte']}
    ${lengthnr}    Get Length    ${CellsInfonr}
    ${lengthlte}    Get Length    ${CellsInfolte}
    ${length}   Evaluate    ${lengthnr}+${lengthlte}
    Should Not Be Equal    ${length}    ${0}
    run keyword if  '${type}'=='nr' or '${type}'=='both'
    ...    COMA_Admin.InternalCheckCellState    CellsInfo=${CellsInfonr}
    run keyword if  '${type}'=='lte' or '${type}'=='both'
    ...    COMA_Admin.InternalCheckCellState    CellsInfo=${CellsInfolte}
#    FOR  ${item}  IN  @{CellsInfonr}
#        Should be equal as strings    ${item['status']['operationalState']}    Enabled    ignore_case=${True}
#        #shou${item['status']}'    Online
#    END
#    FOR  ${item}  IN  @{CellsInfolte}
#        Should be equal as strings    ${item['status']['operationalState']}    Enabled    ignore_case=${True}
#        #shou${item['status']}'    Online
#    END

COMA_Admin.InternalCheckCellState
    [Arguments]   ${CellsInfo}
    FOR  ${item}  IN  @{CellsInfo}
        Should be equal as strings    ${item['status']['operationalState']}    Enabled    ignore_case=${True}
        #shou${item['status']}'    Online
    END
COAM_Admin.GetBTSInfo
    [Arguments]   ${bts_host}=${WEBUI_IP}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    name=GNB_COAM
    ${BTSInfo}=    coam.get_bts_info    connection=GNB_COAM
    coam.teardown      connection=GNB_COAM
    [Return]   ${BTSInfo}

COAM_Admin.GetActiveAlarms
    [Arguments]   ${connection}=COAM
    ${active_alarms}   coam.get_active_alarms   connection=${connection}   timeout=10
    [Return]   ${active_alarms}

COAM_Admin.GetActiveSoftwareVersion
    [Arguments]   ${bts_host}=${WEBUI_IP}
    ${BTSInfo}      COAM_Admin.GetBTSInfo    bts_host=${bts_host}
    ${swVersion}    set variable    ${BTSInfo['swInfo']['swVersion']}
    [Return]        ${swVersion}

COAM_Admin.GetSWVersion
    [Arguments]   ${connection}=COAM
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=10
    ${active_5g_rat_version}   Set Variable   ${sw_info['Active 5G RAT version']}
    ${active_gsm_rat_version}   Set Variable   ${sw_info['Active GSM RAT version']}
    ${active_lte_rat_version}   Set Variable   ${sw_info['Active LTE RAT version']}
    ${active_wcdma_rat_version}   Set Variable   ${sw_info['Active WCDMA RAT version']}
    ${active_sw_version}   Run Keyword If   "${sw_info['Active SW version']}"!="${None}" and "${sw_info['Active SW version']}"!=""
    ...   COAM_Admin.Transfer SW Version   ${sw_info['Active SW version']}
    ...   ELSE   Set Variable   ${None}
    ${passive_sw_version}   Run Keyword If   "${sw_info['Passive SW version']}"!="${None}" and "${sw_info['Passive SW version']}"!=""
    ...   COAM Transfer SW Version   ${sw_info['Passive SW version']}
    ...   ELSE   Set Variable   ${None}
    ${planned_sw_version}   Run Keyword If   "${sw_info['Planned SW version']}"!="${None}" and "${sw_info['Planned SW version']}"!=""
    ...   COAM Transfer SW Version   ${sw_info['Planned SW version']}
    ...   ELSE   Set Variable   ${None}
        COAM_Admin.Logout
    [Return]   ${active_sw_version}

COAM_Admin.TransferSWVersion
    [Arguments]   ${sw_version}
    Run Keyword If   "${sw_version}"=="" or "${sw_version}"=="-"   Fail   Please Enter Correct Parameter!
    @{list}   Split String From Right   string=${sw_version}   separator=_     max_split=3
    ${first}   Set Variable   ${${list[-3]}}
    ${second}   Set Variable   ${${list[-2]}}
    ${third}   Set Variable   ${${list[-1]}}
    ${version}    Set Variable if    ${sw_version.count('SBTS')}>${0}   ${sw_version}    ${first}.${second}.${third}
    [Return]   ${version}

COAM_Admin.BackupSCF
    [Arguments]   ${local_dir}=${OUTPUT_DIR}   ${file_name}=old_commission.xml   ${connection}=COAM
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.get_current_scf_file   local_dir_path=${local_dir}   file_name=${file_name}   connection=${connection}   timeout=10
    ${backupfile}=   Join Path   ${local_dir}   ${file_name}
    COAM_Admin.Logout
    [Return]  ${backupfile}

COAM_Admin.CheckBTSOnAir
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${status}   Set Variable   ${bts_info['status']['proceduralState']}
    Should Contain   ${status}   OnAir

COAM_Admin.UpdateSW
    [Arguments]   ${file_path}   ${activate}=yes   ${connection}=COAM
    Log To Console   Start Software Updating...
    ${should_activate}   Set Variable If   '${activate}'=='yes'   ${True}
    ...   '${activate}'=='no'   ${False}
    coam.update_software   sw_package=${file_path}   should_activate=${True}   timeout=${3600}   connection=${connection}
    Log To Console   Software Update Finished, Waiting For Resetting...
    COAM_Admin.Logout   connection=${connection}
    sleep  10min
    Wait Until Keyword Succeeds   10m   1m   COAM_Admin.Login
    Log To Console   Reset finished!


COAM_Admin.commission
    [Arguments]    ${scf_file}   ${bts_host}=${WEBUI_IP}    ${timeout}=${600}   ${connnection}=COAM
    wait until keyword succeeds   20x   1min    COAM_Admin.Login    bts_host=${bts_host}
    coam.perform_commissioning    scf_file=${scf_file}   skip_parameter_relation_errors=True
    ...    should_activate=${true}    timeout=${timeout}    connection=${connnection}
    COAM_Admin.Logout

COAM_Admin.VerifyCellOnAir
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    wait until keyword succeeds   3x   1min    COAM_Admin.CheckBTSOnAir
    COAM_Admin.Logout

COAM_Admin.ValidateSCF
    [Arguments]   ${scf_file}    ${timeout}=${300}    ${connection}=COAM
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.validate_scf   scf_file=${scf_file}    timeout=${timeout}    connection=${connection}
    COAM_Admin.Logout

COAM_Admin.ResetSite
    [Arguments]  ${timeout}    ${connection}=COAM
    log to console    Start reseting gNB!
    coam.reset_site   timeout=${timeout}  connection=${connection}
    log to console    Finish reseting gNB!

COAM_Admin.GeteNBSCFbyStream
    [Arguments]    ${IP}    ${alias}=COAM_eNB
    COAM_Admin.Login    bts_host=${IP}    alias=${alias}
    ${version}    COAM_Admin.GetActiveSoftwareVersion    bts_host=${IP}
    ${longStreamPrefix}    ${fullVersion}    Basic.GetStreamAndVersion    vstring=${version}
    ${shortStreamPrefix}    Basic.GetSBTSStreamPrefix    vstring=${version}
    ${shortStreamPrefix}    Set Variable If    ${longStreamPrefix.count('ENB_9999')}>0    SBTS00    ${shortStreamPrefix}
    ${filename}    Basic.CheckFilePresent  path=${CFGFILE_PATH}  keyword=TestLineSCFeNB_${shortStreamPrefix}.xml    fullname=true
    ${filename}    set variable if    '${filename}'=='NotPresent'    TestLineSCFeNB.xml    ${filename}
    log to console     ${CFGFILE_PATH}/${filename}
#    coam.perform_commissioning    scf_file=${CFGFILE_PATH}/${filename}
#    ...    skip_parameter_relation_errors=True    should_activate=${true}    timeout=${600}    connection=${alias}
    COAM_Admin.Logout  connection=${alias}
    [Return]       ${CFGFILE_PATH}/${filename}

COAM_WebEM.Login
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]      ${virtual_enable}=${TRUE}    ${url}=${WEBUI_URL}    ${version}=SBTS21B
    run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    url=${url}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}    version=${version}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock
    sleep    15s
    ${res}    selenium_coam.start_up_view_window_exists
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window

COAM_WebEM.Logout
    [Arguments]     ${virtual_disable}=${TRUE}
    ${res}    selenium_coam.start_up_view_window_exists
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window
    selenium_coam.logout
    run keyword if      ${virtual_disable}    selenium_coam.disable_virtual_display

COAM_WebEM.GetParameterValue
    [Arguments]    ${distName}=MRBTS-1969    ${abbr}=BTS name
    ${value}   Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.get_parameter_value    dist_name=${distName}    filter_param=${abbr}
    [Return]       ${value}

COAM_WebEM.SetParameterValue
    [Arguments]    ${distName}=MRBTS-1969    ${abbr}=BTS name    ${value}=TL012    ${Abbreviation}=${None}
    Wait Until Keyword Succeeds    3 times    30s
    ...   selenium_coam.set_parameter_value   dist_name=${distName}   filter_param=${abbr}   new_value=${value}
    ...   abbr=${Abbreviation}

COAM_WebEM.DeleteParameter
    [Arguments]    ${distName}=MRBTS-1969    ${abbr}=BTS name
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.delete_parameter    dist_name=${distName}    filter_param=${abbr}

COAM_WebEM.VerifyCellOnAir
    [Arguments]    ${cell_idx}=ALL
    COAM_WebEM.VerifyAllCellsAreOnline    cell_idx=${cell_idx}
#    COAM_WebEM.Login
#    ${output}    selenium_coam.get_cell_info
#
##    Dictionary Should Contain Value    &{output}[Status]    Unlocked
##    Dictionary Should Contain Value    &{output}[Status]    Online
##    Dictionary Should Contain Value    &{output}[Status]    configured
#    COAM_WebEM.Logout

COAM_WebEM.GetCellStatus
    [Arguments]    ${cell_idx}=0
    COAM_WebEM.Login
    ${output}    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    COAM_WebEM.Logout
    [Return]    ${output}

COAM_WebEM.VerifyAllCellsAreOnline
    [Documentation]   This kw is to check all cells are online in COAM
    [Arguments]     ${cell_idx}=ALL
    COAM_WebEM.Login
    ${CellNum}    selenium_coam.get_number_of_cells
    FOR    ${i}    IN RANGE    ${CellNum}
        ${Idx}    Evaluate     1+${i}
        run keyword if   '${cell_idx}'!='ALL' and '${cell_idx}'!='${Idx}'    Continue For Loop
        ${cell_info}    selenium_coam.get_cell_info    cell_idx=${Idx}
        log    ${cell_info} and ${cell_info['Status']['Availability status']}
        Should be equal as strings
        ...      ${cell_info['Status']['Operational state']}    Enabled    ignore_case=${True}
#        ${res1}  Run Keyword And Return Status  Should be equal as strings
#        ...      ${cell_info['Status']['Availability status']}  Online    ignore_case=${True}
#        should be true  ${res} or ${res1}
    END
    COAM_WebEM.Logout

COAM_VerifyOnAirViaFrontendAndBackend
   ${frontend}    run keyword and return status    COAM_WebEM.VerifyCellOnAir
   ${backend}     run keyword and return status    COAM_Admin.VerifyCellOnAir
   should be true    ${frontend} or ${backend}

COAM_WEBEM.CheckBTSConutersWithTraget
    [Arguments]    ${counter_id}   ${target_value}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be equal    ${values[-1]}  ${target_value}

COAM_WEBEM.LockUnlcokCell
    [Documentation]   Lock Cell if cell is unlocked, UnLock cell if cell is locked.
    [Arguments]   ${cell_idx}=1    ${action}=lock    ${timeout}=60    ${checkstatus}=true
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Unlocked" and '${action}'=='lock'
    ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_idx}    abbr=Administrative state    value=Locked
#    ...    selenium_coam.lock_cell    cell_idx=${cell_idx}    timeout=${timeout}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Locked" and '${action}'=='unlock'
#    ...                selenium_coam.unlock_cell    cell_idx=${cell_idx}    timeout=${timeout}
     ...    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_idx}    abbr=Administrative state    value=Unlocked
    COAM_WebEM.ValidateAndActiveParameters
    return from keyword if    '${checkstatus}'=='false'
    ${status}    set variable if    '${action}'=='lock'    Locked    Unlocked
    Wait Until Keyword Succeeds    3 times    30s    COAM_WEBEM.CheckLockUnlcokCellStatus    cell_idx=${cell_idx}
    ...    status=${status}

COAM_WEBEM.CheckLockUnlcokCellStatus
    [Documentation]   Lock Cell if cell is unlocked, UnLock cell if cell is locked.
    [Arguments]   ${cell_idx}=1    ${status}=Locked    ${timeout}=60
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=='${status}'

COAM_WebEM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    #${error}    selenium_megazone.get_validation_error
    #log    ${error}
    #should be empty    ${error}
    ${result}   Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan
    [Return]   ${result}

COAM_WebEM.ModifyAndActiveParameters
    [Arguments]    ${DistName}=MRBTS-1907/NRBTS-7/NRCELL-1    ${FilterParam}=Timer t301    ${NewValue}=600ms
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${DistName}    filter_param=${FilterParam}    new_value=${NewValue}
    COAM_WebEM.ValidateAndActiveParameters

COAM_WebEM.CheckSoftwareDownloadFinished
    ${result}    selenium_coam.check_software_update_progress
    log to console   ${result}
    ${res}    Basic.CheckContainString    substring=Activating software...    string=${result}[status]
    return from keyword if    '${res}'=='true'    true
    ${res}    Basic.CheckContainString    substring=Activation completed      string=${result}[status]
    return from keyword if    '${res}'=='true'    true
    ${res}    Basic.CheckContainString    substring=Activation completed, require unit reset    string=${result}[status]
    return from keyword if    '${res}'=='true'    true
    ${res}    Basic.CheckContainString    substring=Download failed    string=${result}[status]
    return from keyword if    '${res}'=='true'    false
    Fail    need more check

COAM_WebEM.SoftwareUpdate
    [Arguments]    ${filepath}   ${check_reset}=true     ${check_onair}=false
    Wait until keyword succeeds    15min    30s    COAM_WebEM.Login
    log to console    load software package
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${filepath}
    log to console    ${load_result}
    log to console    start download with active
    selenium_coam.software_update     is_activate=${True}
    wait until keyword succeeds    50min    10s    COAM_WebEM.CheckSoftwareDownloadFinished
    log to console    software download end
    log to console    start check bts reset ${check_reset}
    run keyword if    '${check_reset}'=='true'    Wait until keyword succeeds    20min    10s    gNB.CheckBTSReset
    log to console    start waite bts onair ${check_onair}
    run keyword if    '${check_onair}'=='true'    wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair
    log to console    software update end
    run keyword and ignore error    COAM_WebEM.Logout

COAM_WebEM.CheckX2Status
    [Arguments]    ${dist_name}
     ${X2_result}    selenium_coam.get_parameter_value    dist_name=${distname}    filter_param=X2C link status    abbr=x2LinkStatus
     Run Keyword And Continue On Failure    Should be equal    ${X2_result}    available

COAM_WebEM.CheckX2StatusUntilReady
    [Arguments]  ${X2_distname}=${MRBTS_ID}/${NRBTS_ID}/LTEENB-0
     Run Keyword And Continue On Failure    COAM_WebEM.Login
     Run Keyword And Continue On Failure    Wait until keyword succeeds    10x    1min    COAM_WebEM.CheckX2Status
     ...    dist_name=${X2_distname}
     Run Keyword And Continue On Failure    COAM_WebEM.Logout


gNB.CheckGNBIsDualOrSingle
    ${status}    ssh.Execute    command=ping 192.168.255.119 -c 5    connection=tmpConn_Primary
    ${result}    Run Keyword and Return Status    Should Contain    ${status}      64 bytes from 192.168.255.119: icmp_seq=5
    Run Keyword If     ${result}    Set test variable    ${mode}    Dualcore
    ...    ELSE    Set test variable    ${mode}    Singlecore
    [Return]    ${mode}

gNB.CheckgNBCoreMode
    ${ret}  Run Keyword and Return Status  ssh.Connect to    hostname=${ASIK_IP}    username=${ASIK_username}
    ...                                    password=${ASIK_password}    alias=tmpConn_Primary

    ${mode}    Run Keyword If     ${ret}    KW.CheckGNBIsDualOrSingle
    ...    ELSE    Set Variable    uncommission
    run keyword and ignore error    ssh.disconnect    connection=tmpConn_Primary
    [Return]    ${mode}

COAM_WebEM.CheckCounter
    [Arguments]    ${id}   ${min}=0   ${max}=10000   ${path}=None
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${id}    full_path=${path}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    should be true    ${values[-1]} >= ${min}
    should be true    ${values[-1]} <= ${max}
    [Return]    ${values[-1]}

COAM_WebEM.CheckAlarm
    [Arguments]      ${id}    ${present}=true
    @{alarms}    selenium_coam.get_active_alarm_info    alarm_filter=${id}
    ${length}    Get Length    ${alarms}
    run keyword if    '${present}'=='true'    Should Be True   ${length}>${0}
    ...    ELSE    should be true    ${length}<=${0}
gNB.Connect
    Conn.ConnectWithTimeout    alias=${ALIAS_ASIK}
    ${connection}    gNB.GetSystemModuleType    alias=${ALIAS_ASIK}
    ${res}    Conn.Execute    cmd=ifconfig |grep 192.168.253.32    alias=${ALIAS_ASIK}
    run keyword if     ${res.count('192.168.253.32')}>0      set suite variable    ${FCT_IP}    ${FCT_IP_1}
    run keyword if    '${connection}'=='${ALIAS_ASIK_SLAVE}'    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK_SLAVE}
gNB.Disconnect
    ${connection}    gNB.GetSystemModuleType    alias=${ALIAS_ASIK}
    run keyword if    '${connection}'=='${ALIAS_ASIK_SLAVE}'    Conn.Disconnect  alias=${ALIAS_ASIK_SLAVE}
    Conn.Disconnect  alias=${ALIAS_ASIK}
gNB.CheckHWStatus
    [Arguments]    ${alias}=${ALIAS_ASIK}
    ${fct_status}    ${fsp_status}    check_board_status_on_gnb    connection=${alias}
    log  ${fct_status}
    log  ${fsp_status}
    Should Be Equal    ${fct_status}    ready
    Should Be Equal    ${fsp_status}    ready
gNB.CheckHWStatusUntilReady
   wait until keyword succeeds    10 min    1 min    gNB.CheckHWStatus
gNB.CheckSWStatus
    [Arguments]    ${alias}=${ALIAS_ASIK}   ${alias_slave}=${ALIAS_ASIK_SLAVE}
    #check lxc
    ${output}    get_containers_on_asik    connection=${alias}
#    Should Contain    ${output}    0xe000
#    Should Contain    ${output}    0xe001
    Should Contain    ${output}    0xe002
    Should Contain    ${output}    0xe003
    Should Contain    ${output}    0xe004
#    Should Contain    ${output}    0xe009
    Should Contain    ${output}    0xe00a
#    Should Contain    ${output}    0xe00b
    Should Contain    ${output}    0xe00c
    Should Contain    ${output}    0xe00d
    ${output}    get_containers_on_asik    connection=${alias_slave}
    Should Contain    ${output}    0xe005
    Should Contain    ${output}    0xe007
    Should Contain    ${output}    0xe008
    #check master app
#    ${oam_info}    get_pstree_info_on_asik    ${alias}    oam
#    BuiltIn.log    ${oam_info}
#    Should Contain    ${oam_info}    racoam
#    Should Contain    ${oam_info}    siteoam
    ${cpif_info}    get_pstree_info_on_asik    ${alias}    cp_if
    BuiltIn.log    ${cpif_info}
    Should Not Be Empty    ${cpif_info}
    ${cpcl_info}    get_pstree_info_on_asik    ${alias}    cp_cl
    BuiltIn.log    ${cpcl_info}
    Should Not Be Empty    ${cpcl_info}
    ${cpnb_info}    get_pstree_info_on_asik    ${alias}    cp_nb    5
    BuiltIn.log    ${cpnb_info}
    Should Contain    ${cpnb_info}    cp_nb
    Should Contain    ${cpnb_info}    syscom-proxy
    ${disp_info}    get_pstree_info_on_asik    ${alias}    Disp_
    BuiltIn.log    ${disp_info}
    FOR    ${index}    IN RANGE    5
        Should Contain    ${disp_info}    Disp_${index}
    END
    #slave app
    ${cprt_info}    get_pstree_info_on_asik    ${alias_slave}    Cprt
    BuiltIn.log    ${cprt_info}
    Should Not Be Empty    ${cprt_info}
    ${cpue_info}    get_pstree_info_on_asik    ${alias_slave}    cp_ue    6
    BuiltIn.log    ${cpue_info}
    Should Contain    ${cpue_info}    cp_ue
    Should Contain    ${cpue_info}    syscom-proxy
    ${disp_info}    get_pstree_info_on_asik    ${alias_slave}    Disp_
    BuiltIn.log    ${disp_info}
    FOR    ${index}    IN RANGE    1
        Should Contain    ${disp_info}    Disp_${index}
    END
gNB.CheckSWStatusUntilReady
   wait until keyword succeeds    15 min    1 min    gNB.CheckSWStatus

gNB.CheckCPRIStatus
    [Arguments]    ${alias}=${ALIAS_ASIK}
    ${output}    ssh.execute    cat /tmp/startup_NODEOAM.log |grep "CPRI link state is F"    connection=${alias}
    Should Not Be Empty    ${output}
gNB.CheckCPRIStatusUntilReady
    wait until keyword succeeds    10 min    1 min    gNB.CheckCPRIStatus

gNB.Check info in log or zipped log
    [Arguments]   ${logname}    ${ziplogname}    ${pattern}     ${connection}
    @{logpath}    split path   ${logname}
    ${logfile}    set variable   ${logpath}[-1]
    @{zippath}    split path   ${ziplogname}
	${zipfile}    set variable   ${zippath}[-1]

    ${unzipfolder}    set variable      /tmp/unzipfolder/
    ssh.execute     mkdir ${unzipfolder};cp ${ziplogname} ${unzipfolder}   connection=${connection}
	ssh.execute     xz -d -k ${unzipfolder}${zipfile}    connection=${connection}

    ${output1}    ssh.execute   cat ${logname} |grep ${pattern}    connection=${connection}
    ${output2}    ssh.execute   cat ${unzipfolder}${logfile} |grep ${pattern}    connection=${connection}

    ${by_log}=  run keyword and return status   Should contain    ${output1}   ${pattern}
    ${by_ziplog}=  run keyword and return status   Should contain    ${output2}   ${pattern}
    run keyword  should be true   ${by_log} or ${by_ziplog}

gNB.CheckF1Status
    [Arguments]    ${alias}=${ALIAS_ASIK}    ${pattern}=F1SetupInd
    gNB.Check info in log or zipped log    /tmp/node_0xe004/tmp/startup_cp*.log     /tmp/node_0xe004/tmp/startup_cp*.log
    ...        ${pattern}     ${alias}

gNB.CheckF1StatusUntilReady
    wait until keyword succeeds    30 min    1 min    gNB.CheckF1Status

gNB.CheckX2Status
    [Arguments]    ${alias}=${ALIAS_ASIK}
    ${containerid}    ${node_cmd}     gnb.get_container_id    nodename=CPIF
    ${output}    ssh.execute    command=bsh ${node_cmd} cat /tmp/node_0xe004/tmp/startup_cp*.log |grep "X2 link is available"
    ...          connection=${alias}
    Should Not Be Empty    ${output}
    should contain    ${output}    X2 link is available

gNB.CheckX2Status_1514
    [Arguments]    ${alias}=${ALIAS_ASIK}
    ${containerid}    ${node_cmd}     gnb.get_container_id    nodename=CPIF
    ${output}    ssh.execute    command=bsh ${node_cmd} cat /tmp/node_CPIF00/tmp/startup_cp*.log |grep "CpNbX2LinkInfoUpdateConfirm"
    ...    connection=${alias}
    Should Not Be Empty    ${output}
    should contain    ${output}    CpNbX2LinkInfoUpdateConfirm

gNB.CheckX2StatusUntilReady
    [Arguments]  ${dep_1514}=No    ${alias}=${ALIAS_ASIK}
    #${alias}    gNB.GetSystemModuleType    alias=${ALIAS_ASIK}
    wait until keyword succeeds    10 min    1 min    gNB.CheckX2Status_1514    alias=${ALIAS_ASIK}

gNB.CheckXnStatus
    [Arguments]    ${alias}=${ALIAS_ASIK}
    ${containerid}    ${node_cmd}     gnb.get_container_id    nodename=CPIF
    ${output}    ssh.execute    command=bsh ${node_cmd} cat /tmp/node_CPIF00/tmp/startup_cp*.log |grep "XnService received XnSetupResponse"
    ...    connection=${alias}
    Should Not Be Empty    ${output}
    should contain    ${output}    XnService received XnSetupResponse

gNB.CheckXnStatusUntilReady
    wait until keyword succeeds    5 min    1 min    gNB.CheckXnStatus

gNB.PrepareCommissionFile
    [Arguments]    ${alias}=${ALIAS_ASIK}    ${delta_file}=Delta_SCF.py   ${scf_template}=SBTS5G19_5g_pid12_classical.xml
    [Documentation]  logic:  if delta_file exists, use the content there to modify scf. otherwise, use the content defined
    ...    in init.py of test conf (TL specific), init.py of feature commission folder (feature specific), and variables
    ...    in case (case specific) to modify scf.
    ...    delta_file:  the py file put in UTE VM, where there is scf parameters defined by tester.
    ...    scf_template:  the scf template in the gNB systems. different confs may have different template.
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    commissioning.wait for oam node port    oam_node_ip=${ASIK_IP}

    set test variable    ${local_path}    ${LOG_PATH}/${scf_template}
    set test variable    ${remote_path}    ${SCF_FILE_PATH}/${scf_template}

    ssh.download_file    remote_path=${remote_path}    local_path=${local_path}    connection=${alias}

    ${exist}=    run keyword and return status    File Should Exist     ${CFGFILE_PATH}/${delta_file}
    ${variable_dic}=    get variables    no_decoration=Yes
    ${keys}=    Get Dictionary Keys    ${variable_dic}
    ${variable_for_feature}=    Basic.CheckVariable    PARAMS_TO_MODIFY_FOR_FEATURE    ${keys}
    ${variable_for_case}=    Basic.CheckVariable    PARAMS_TO_MODIFY_FOR_CASE    ${keys}

    run keyword if    ${exist}    run keyword and ignore error    gNB.PrepareScfBasedOnProvidedOption
    ...    delete=${PARAMS_TO_DELETE_USER_DEFINE}    add=${PARAMS_TO_ADD_USER_DEFINE}    modify=${PARAMS_TO_MODIFY_USER_DEFINE}
    ...    ELSE    run keywords
    ...    run keyword and ignore error    gNB.PrepareScfBasedOnProvidedOption
    ...    delete=${PARAMS_TO_DELETE}    add=${PARAMS_TO_ADD}    modify=${PARAMS_TO_MODIFY}
    ...    AND    run keyword if  '${variable_for_feature}'=='true'   run keyword and ignore error  gNB.PrepareScfBasedOnProvidedOption
    ...    delete=${PARAMS_TO_DELETE_FOR_FEATURE}    add=${PARAMS_TO_ADD_FOR_FEATURE}    modify=${PARAMS_TO_MODIFY_FOR_FEATURE}
    ...    AND    run keyword if   '${variable_for_case}'=='true'    run keyword and ignore error  gNB.PrepareScfBasedOnProvidedOption
    ...    delete=${PARAMS_TO_DELETE_FOR_CASE}    add=${PARAMS_TO_ADD_FOR_CASE}    modify=${PARAMS_TO_MODIFY_FOR_CASE}

    [Return]    ${local_path}

gNB.ModifySCFwithNewGNBID
    [Arguments]    ${scf_path}    ${gnbID}=NRBTS-1
    run    command=sed -i 's|NRBTS-1|${gnbID}|g' ${scf_path}

gNB.PrepareScfBasedOnProvidedOption
    [Arguments]    ${delete}    ${add}    ${modify}

    run keyword and ignore error    gNB.Remove MO From Scf  input_scf=${local_path}  output_scf=${local_path}
    ...    parameters_lists=${delete[0]}
    run keyword and ignore error    gNB.Remove Lists From Scf  input_scf=${local_path}  output_scf=${local_path}
    ...    parameters_lists=${delete[1]}
    run keyword and ignore error    gNB.Remove Elements From Scf  input_scf=${local_path}  output_scf=${local_path}
    ...    parameters_lists=${delete[2]}

    run keyword and ignore error    gNB.Add objects to scf  input_scf=${local_path}  output_scf=${local_path}
    ...    parameters_lists=${add[0]}
    run keyword and ignore error    gNB.Add elements to object  input_scf=${local_path}  output_scf=${local_path}
    ...    parameters_lists=${add[1]}
    run keyword and ignore error    gNB.Add lists to object  input_scf=${local_path}  output_scf=${local_path}
    ...    parameters_lists=${add[2]}
    run keyword and ignore error    gNB.Add items to list  input_scf=${local_path}  output_scf=${local_path}
    ...    parameters_lists=${add[3]}
    run keyword and ignore error    gNB.Add elements to list  input_scf=${local_path}  output_scf=${local_path}
    ...    parameters_lists=${add[4]}

#    run keyword and ignore error    gNB.Modify MO Attributes  input_scf=${local_path}  output_scf=${local_path}
#    ...    parameters_lists=${modify[0]}
#    run keyword and ignore error    commissioning.modify_scf  input_scf=${local_path}  output_scf=${local_path}
#    ...    parameters_lists=${modify[1]}
    run keyword and ignore error    gNB.Modify SCF Elements   input_scf=${local_path}  output_scf=${local_path}
    ...    parameters_lists=${modify[1]}

gNB.ModifySCFAndCommission
    [Documentation]   1. Modify SCF
    ...                2. Commission Modified SCF
    [Arguments]        ${InputFile}
        ...            ${OutputFile}
        ...            ${ParamterToModify}='NULL'
        ...            ${ParamterToDelete}='NULL'

    run keyword if  not ${ParamterToModify}=='NULL'    Run keywords    gNB.Modify SCF Elements    input_scf=${InputFile}
    ...           output_scf=${OutputFile}    parameters_lists=${ParamterToModify}
        ...           AND     set test variable    ${InputFile}    ${OutputFile}
    run keyword if  not ${ParamterToDelete}=='NULL'    gNB.Remove Elements From Scf  input_scf=${InputFile}  output_scf=${OutputFile}
    ...    parameters_lists=${ParamterToDelete}
    gNB.CommissionWithRetry    scf_file=${OutputFile}

gNB.ModifySCFAndCommissionAndCheckOnair
    [Documentation]   1. Modify SCF
    ...                2. Commission Modified SCF
    ...                3. Wait gNB start and verify gNB is On Air until timeout.
    [Arguments]        ${InputFile}
        ...            ${OutputFile}
        ...            ${ParamterToModify}='NULL'
        ...            ${ParamterToDelete}='NULL'

    run keyword if  not ${ParamterToModify}=='NULL'    Run keywords    gNB.Modify SCF Elements    input_scf=${InputFile}
    ...           output_scf=${OutputFile}    parameters_lists=${ParamterToModify}
    ...           AND     set test variable    ${InputFile}    ${OutputFile}
    run keyword if  not ${ParamterToDelete}=='NULL'    gNB.Remove Elements From Scf  input_scf=${InputFile}  output_scf=${OutputFile}
    ...    parameters_lists=${ParamterToDelete}
    gNB.CommissionWithRetry    scf_file=${OutputFile}
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady

gNB.CommissionWithRetry
    [Arguments]    ${scf_file}    ${model}=FACOM   ${RUmodel}=${model}
    ${status}   Run Keyword And Return Status   gNB.Commission    scf_file=${scf_file}    timeout=${1800}
    Run keyword if    '${status}'=='False'    gNB.Power.ResetAndCommission    scf_file=${scf_file}     model=${model}  RUmodel=${RUmodel}

gNB.Power.ResetAndCommission
    [Arguments]    ${scf_file}    ${model}=FACOM    ${RUmodel}=${model}
    Power.Reset5GRU    model=${RUmodel}
    Power.ResetgNB     model=${model}
    Sleep    10min
    wait until keyword succeeds    15min    1min    gNB.VerifyOnAirViaOAMUntilReady
    gNB.Commission    scf_file=${scf_file}    timeout=${2400}

#--------
gNB.CollectSnapshot
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    ${PATHONLY}   ${SNAPSHOTNAME}   Split String From Right    string=${snapshot_file}   separator=/     max_split=1
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}/.
    Run Keyword And Ignore Error    run    command=rm ${snapshot_file}
    [Return]    ${LOG_PATH}/${SNAPSHOTNAME}

gNB.SetLoggingSeverity
    [Arguments]    ${LoggingSeverity}=trace
    Conn.ConnectWithTimeout    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /ffs/run/ && echo [control] >cp_runtime.ini && echo LoggingSeverity=${LoggingSeverity} >>cp_runtime.ini
    ...             alias=${ALIAS_ASIK}
    Conn.Disconnect    alias=${ALIAS_ASIK}

gNB.FormatBTSID
    [Arguments]      ${MRBTSID}=${MRBTS_ID}    ${NRBTSID}=${NRBTS_ID}      ${lte}=false
    ${MRBTSID}    Evaluate    str('${MRBTSID}')
    ${NRBTSID}    Evaluate    str('${NRBTSID}')
    ${MRBTSID}    Fetch From Right    ${MRBTSID}   MRBTS-
    ${NRBTSID}    Fetch From Right    ${NRBTSID}   NRBTS-
    ${NRBTSID}    Fetch From Right    ${NRBTSID}   LNBTS-
    ${MRBTSID}    set variable    MRBTS-${MRBTSID}
    ${NRBTSID}    run keyword if    '${lte}'=='false'    set variable    NRBTS-${NRBTSID}
     ...    ELSE    set variable    LNBTS-${NRBTSID}
    ${CELLPREVFIX}    run keyword if    '${lte}'=='false'    set variable    NRCELL
     ...    ELSE    set variable    LNCEL
    set suite variable    ${MRBTS_ID}    ${MRBTSID}
    set suite variable    ${NRBTS_ID}    ${NRBTSID}
    set suite variable    ${CELLPREVFIX}    ${CELLPREVFIX}
    [Return]      ${MRBTS_ID}    ${NRBTS_ID}

gNB.ReplaceDeltaID
    [Arguments]       ${DeltaPath}='NULL'    ${MRBTSID}=${MRBTS_ID}    ${NRBTSID}=${NRBTS_ID}
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=timestamp
    ${timestamp}    robot.libraries.DateTime.convert date    ${timestamp}    epoch
    ${timestamp}    evaluate    int(round(${timestamp} * 1000))
    ${MRBTSID}    Evaluate    str('${MRBTSID}')
    ${NRBTSID}    Evaluate    str('${NRBTSID}')
    ${MRBTSID}    Fetch From Right    ${MRBTSID}   MRBTS-
    ${NRBTSID}    Fetch From Right    ${NRBTSID}   NRBTS-

    ${MRBTSID}    set variable    MRBTS-${MRBTSID}
    ${NRBTSID}    set variable    NRBTS-${NRBTSID}
    run    cp ${DeltaPath} ${LOG_PATH}/Delta_${MRBTS_ID}_${timestamp}.py
    run    sed -i 's/MRBTS-[0-9]\\{0,10\\}/${MRBTSID}/g' ${LOG_PATH}/Delta_${MRBTS_ID}_${timestamp}.py
    run    sed -i 's/NRBTS-[0-9]\\{0,10\\}/${NRBTSID}/g' ${LOG_PATH}/Delta_${MRBTS_ID}_${timestamp}.py
    run keyword if  not '${DeltaPath}'=='NULL'       Import Variables        ${LOG_PATH}/Delta_${MRBTS_ID}_${timestamp}.py
    #Sleep    2s

gNB.ReplaceSCFBTSID
    [Arguments]    ${SCFFilePath}     ${MRBTSID}=${MRBTS_ID}    ${NRBTSID}=${NRBTS_ID}
   ${MRBTSID}    Evaluate    str('${MRBTSID}')
    ${NRBTSID}    Evaluate    str('${NRBTSID}')
    ${MRBTSID}    Fetch From Right    ${MRBTSID}   MRBTS-
    ${NRBTSID}    Fetch From Right    ${NRBTSID}   NRBTS-

    ${MRBTSID}    set variable    MRBTS-${MRBTSID}
    ${NRBTSID}    set variable    NRBTS-${NRBTSID}
    run    sed -i 's/MRBTS-[0-9]\\{0,10\\}/${MRBTSID}/g' ${SCFFilePath}
    run    sed -i 's/NRBTS-[0-9]\\{0,10\\}/${NRBTSID}/g' ${SCFFilePath}

gNB.Generate TL SCF
    [Documentation]
    ...             download GoldenSCF.xml and TLDelta.py to ${LOG_PATH}
    ...             replace GoldenSCF.xml's and TLDelta.py's MRBTS-id and NRBTS-id
    ...             GoldenSCF.xml + TLDelta.py -> TestlineSCFxcell.xml
    [Arguments]     ${GoldenSCF_PATH}    ${TLDelta_PATH}
    ...            ${TestLineSCF_cell_num}=${1}   ${cell_type}=Both
    ...            ${MRBTSID}=MRBTS-12345    ${NRBTSID}=NRBTS-12345
    run    cp ${GoldenSCF_PATH} ${LOG_PATH}/GoldenSCF.xml
    ${MRBTSID}    Evaluate    str('${MRBTSID}')
    ${NRBTSID}    Evaluate    str('${NRBTSID}')
    ${MRBTSID}    Fetch From Right    ${MRBTSID}   MRBTS-
    ${NRBTSID}    Fetch From Right    ${NRBTSID}   NRBTS-

    ${MRBTSID}    set variable    MRBTS-${MRBTSID}
    ${NRBTSID}    set variable    NRBTS-${NRBTSID}
    ${Pfix}    Get Substring      ${TLDelta_PATH}    -3
    ${TLDelta_PATH}    Set Variable If   '${Pfix}'=='.py'    ${TLDelta_PATH}    ${TLDelta_PATH}/TLDelta.py

    gNB.ReplaceSCFBTSID    SCFFilePath=${LOG_PATH}/GoldenSCF.xml
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    gNB.ReplaceDeltaID     DeltaPath=${TLDelta_PATH}
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    gNB.ModifySCF     InputFile=${LOG_PATH}/GoldenSCF.xml
    ...               OutputFile=${LOG_PATH}/TestLineSCF${TestLineSCF_cell_num}Cell_${cell_type}.xml
    ...               ParameterToDelete=${TL_PARAMS_TO_DELETE_${TestLineSCF_cell_num}CELL}
    ...               MOsToAdd=${TL_ADD_MOS_${TestLineSCF_cell_num}CELL}
    ...               ParamterToModify=${TL_PARAMS_TO_MODIFY_${TestLineSCF_cell_num}CELL}
    ...               ListParamterToModify=${TL_LIST_PARAMS_TO_MODIFY_${TestLineSCF_cell_num}CELL}
    ...               ListToAdd=${TL_LIST_TO_ADD_${TestLineSCF_cell_num}CELL}
    [Return]     ${LOG_PATH}/TestLineSCF${TestLineSCF_cell_num}Cell_${cell_type}.xml

gNB.ReplaceIDandGenerateTLSCFs
    [Arguments]     ${InputSCF_PATH}     ${TLDelta_PATH}    ${TLDeltaForce}
    run    cp ${InputSCF_PATH} ${LOG_PATH}/GoldenSCF.xml
    ${Pfix}    Get Substring      ${TLDelta_PATH}    -3
    ${TLDelta_PATH}    Set Variable If   '${Pfix}'=='.py'    ${TLDelta_PATH}    ${TLDelta_PATH}/TLSCFDelta.py
    gNB.ReplaceSCFBTSID    SCFFilePath=${LOG_PATH}/GoldenSCF.xml
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    gNB.ReplaceDeltaID     DeltaPath=${TLDelta_PATH}
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    run keyword if    '${TLDeltaForce}'!='NotPresent'    gNB.ReplaceDeltaID     DeltaPath=${CFGFILE_PATH}${TLDeltaForce}
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    ${length}    Get Length    ${TLSCF_CELL_NUMs}
    FOR    ${i}    IN RANGE    0    ${length}
        gNB.ModifySCF          InputFile=${LOG_PATH}/GoldenSCF.xml
        ...                    OutputFile=${LOG_PATH}/TestLineSCF${TLSCF_CELL_NUMs[${i}]}Cell.xml
        ...                    ParameterToDelete=${TL_PARAMS_TO_DELETE_${TLSCF_CELL_NUMs[${i}]}CELL}
        ...                    MOsToAdd=${TL_ADD_MOS_${TLSCF_CELL_NUMs[${i}]}CELL}
        ...                    ParamterToModify=${TL_PARAMS_TO_MODIFY_${TLSCF_CELL_NUMs[${i}]}CELL}
        ...                    ListParamterToModify=${TL_LIST_PARAMS_TO_MODIFY_${TLSCF_CELL_NUMs[${i}]}CELL}
        ...                    ListToAdd=${TL_LIST_TO_ADD_${TLSCF_CELL_NUMs[${i}]}CELL}
        gNB.UpdateTLSCFwithTLDeltaForce    InputSCF_PATH=${LOG_PATH}/TestLineSCF${TLSCF_CELL_NUMs[${i}]}Cell.xml
        ...                    TLDeltaForce=${TLDeltaForce}    i=${i}
    END
    [Return]     ${LOG_PATH}/TestLineSCF${TLSCF_CELL_NUMs[${i}]}Cell.xml

gNB.UpdateTLSCFwithTLDeltaForce
    [Arguments]     ${InputSCF_PATH}     ${TLDeltaForce}      ${i}
    return from keyword if    '${TLDeltaForce}'=='NotPresent'
    gNB.ModifySCF          InputFile=${InputSCF_PATH}
    ...                    OutputFile=${InputSCF_PATH}
    ...                    ParameterToDelete=${TL_PARAMS_TO_DELETE_${TLSCF_CELL_NUMs[${i}]}CELL_FORCE}
    ...                    MOsToAdd=${TL_ADD_MOS_${TLSCF_CELL_NUMs[${i}]}CELL_FORCE}
    ...                    ParamterToModify=${TL_PARAMS_TO_MODIFY_${TLSCF_CELL_NUMs[${i}]}CELL_FORCE}
    ...                    ListParamterToModify=${TL_LIST_PARAMS_TO_MODIFY_${TLSCF_CELL_NUMs[${i}]}CELL_FORCE}
    ...                    ListToAdd=${TL_LIST_TO_ADD_${TLSCF_CELL_NUMs[${i}]}CELL_FORCE}

gNB.GenerateTestLineSCFs
    [Documentation]      If keyword return successfully, TLSCF will present under ${LOG_PATH} with name TestLineSCFxCell.xml
    ...    If TLSCFDelta with StreamPrefix present, it will be used , otherwhise TLSCFDelta.py will be used.
    ${StreamInfo}        Basic.GetStreamInfo    StreamInfoName=STREAM_INFOs
    ${StreamPrefix}      set variable    ${StreamInfo['StreamPrefix']}
    ${GoldenSCF}         set variable    ${GoldenSCF_ON_GIT}${StreamInfo['GoldenSCF']}
    ${TLSCFDelta}        Basic.CheckFilePresent    path=${CFGFILE_PATH}    keyword=TLSCFDelta.py    fullname=true
    ${TLSCFDeltaPrefix}  Basic.CheckFilePresent    path=${CFGFILE_PATH}    keyword=TLSCFDelta_${StreamPrefix}.py    fullname=true
    ${TLSCFDeltaForce}   Basic.CheckFilePresent     path=${CFGFILE_PATH}    keyword=TLSCFDelta_Force.py    fullname=true
    ${TLSCFDelta}        set variable if  '${TLSCFDeltaPrefix}'=='NotPresent'  ${CFGFILE_PATH}${TLSCFDelta}  ${CFGFILE_PATH}${TLSCFDeltaPrefix}
    ${NewScf}    gNB.ReplaceIDandGenerateTLSCFs    InputSCF_PATH=${GoldenSCF}    TLDelta_PATH=${TLSCFDelta}    TLDeltaForce=${TLSCFDeltaForce}
    [Return]    ${NewScf}

gNB.AppendCaseSCFDelta
    [Documentation]   Use string name as input instead of variable, ignore if no such type parameters
    ...               ResourceFolder should be $CURDIR,CaseSCFDelta should present under the folder with Caller
    ...               SCF Paramteres are strings eg: PARAMS_TO_DELETE_876_D_018 instead of $var
    ...               CaseSCF=TLSCF+CaseSCFelta.py+CaseSCFDelta_StreamPrefix.py+TLCaseSCFDelta
    [Arguments]       ${InputFile}
    ...               ${OutputFile}
    ...               ${ResourceFolder}
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
    ${StreamInfo}          Basic.GetStreamInfo    StreamInfoName=STREAM_INFOs
    ${StreamPrefix}        set variable    ${StreamInfo['StreamPrefix']}
    run   rm ${OutputFile} -rf
    ${CaseSCFDelta}        Basic.CheckFilePresent    path=${ResourceFolder}    keyword=CaseSCFDelta.py    fullname=true
    ${CaseSCFDeltaPrefix}  Basic.CheckFilePresent    path=${ResourceFolder}    keyword=CaseSCFDelta_${StreamPrefix}.py    fullname=true
    return from keyword if    '${CaseSCFDelta}'=='NotPresent'    ${InputFile}
    log to console    -----------------${CaseSCFDelta} used
    set suite variable    ${${ParameterToDelete}}    'NULL'
    set suite variable    ${${MOsToAdd}}    'NULL'
    set suite variable    ${${ParamterToModify}}    'NULL'
    set suite variable    ${${ListParamterToModify}}    'NULL'
    set suite variable    ${${ListToAdd}}    'NULL'
    gNB.ReplaceDeltaID     DeltaPath=${ResourceFolder}/${CaseSCFDelta}
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    GNB.ModifySCF    InputFile=${InputFile}
    ...              OutputFile=${OutputFile}
    ...              ParameterToDelete=${${ParameterToDelete}}
    ...              MOsToAdd=${${MOsToAdd}}
    ...              ParamterToModify=${${ParamterToModify}}
    ...              ListParamterToModify=${${ListParamterToModify}}
    ...              ListToAdd=${${ListToAdd}}
    return from keyword if    '${CaseSCFDeltaPrefix}'=='NotPresent'    ${OutputFile}
    log to console    -----------------${CaseSCFDeltaPrefix} used
    set suite variable    ${${ParameterToDelete}}    'NULL'
    set suite variable    ${${MOsToAdd}}    'NULL'
    set suite variable    ${${ParamterToModify}}    'NULL'
    set suite variable    ${${ListParamterToModify}}    'NULL'
    set suite variable    ${${ListToAdd}}    'NULL'
    gNB.ReplaceDeltaID     DeltaPath=${ResourceFolder}/${CaseSCFDeltaPrefix}
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    GNB.ModifySCF    InputFile=${OutputFile}
    ...              OutputFile=${OutputFile}
    ...              ParameterToDelete=${${ParameterToDelete}}
    ...              MOsToAdd=${${MOsToAdd}}
    ...              ParamterToModify=${${ParamterToModify}}
    ...              ListParamterToModify=${${ListParamterToModify}}
    ...              ListToAdd=${${ListToAdd}}
    [Return]    ${OutputFile}

gNB.AppendTLCaseSCFDelta
    [Documentation]      Generate new with TLCaseSCFDelta base on input scf file
    ...    If TLCaseSCFDelta with StreamPrefix present, it will be used , otherwhise TLCaseSCFDelta.py will be used.
    [Arguments]       ${InputFile}
    ...               ${OutputFile}
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
    ${StreamInfo}          Basic.GetStreamInfo    StreamInfoName=STREAM_INFOs
    ${StreamPrefix}        set variable    ${StreamInfo['StreamPrefix']}
    ${TLCaseSCFDelta}        Basic.CheckFilePresent    path=${CFGFILE_PATH}    keyword=TLCaseSCFDelta.py    fullname=true
    ${TLCaseSCFDeltaPrefix}  Basic.CheckFilePresent    path=${CFGFILE_PATH}    keyword=TLCaseSCFDelta_${StreamPrefix}.py    fullname=true
    ${TLCaseSCFDelta}  set variable if  '${TLCaseSCFDeltaPrefix}'=='NotPresent'
    ...            ${TLCaseSCFDelta}  ${TLCaseSCFDeltaPrefix}
    return from keyword if    '${TLCaseSCFDelta}'=='NotPresent'
    log to console    -----------------${TLCaseSCFDelta} used
    set suite variable    ${${ParameterToDelete}}    'NULL'
    set suite variable    ${${MOsToAdd}}    'NULL'
    set suite variable    ${${ParamterToModify}}    'NULL'
    set suite variable    ${${ListParamterToModify}}    'NULL'
    set suite variable    ${${ListToAdd}}    'NULL'
    gNB.ReplaceDeltaID     DeltaPath=${CFGFILE_PATH}${TLCaseSCFDelta}
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    GNB.ModifySCF    InputFile=${InputFile}
    ...              OutputFile=${OutputFile}
    ...              ParameterToDelete=${${ParameterToDelete}}
    ...              MOsToAdd=${${MOsToAdd}}
    ...              ParamterToModify=${${ParamterToModify}}
    ...              ListParamterToModify=${${ListParamterToModify}}
    ...              ListToAdd=${${ListToAdd}}

#    gNB.GenerateCaseSCF    InputFile=${LOG_PATH}/TestLineSCF1Cell.xml
#    ...    OutputFile=${LOG_PATH}/CaseSCF_876_D_018.xml
#    ...    ResourceFolder=${CURDIR}
#    ...    ParameterToDelete=PARAMS_TO_DELETE_876_D_018    ParamterToModify=PARAMS_TO_MODIFY_876_D_018
gNB.GenerateCaseSCF
    [Arguments]       ${InputFile}
    ...               ${OutputFile}
    ...               ${ResourceFolder}
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
    ${modifiedSCF}    gNB.AppendCaseSCFDelta
    ...    InputFile=${InputFile}
    ...    OutputFile=${OutputFile}
    ...    ResourceFolder=${ResourceFolder}
    ...    ParameterToDelete=${ParameterToDelete}
    ...    MOsToAdd=${MOsToAdd}
    ...    ParamterToModify=${ParamterToModify}
    ...    ListParamterToModify=${ListParamterToModify}
    ...    ListToAdd=${ListToAdd}
    gNB.AppendTLCaseSCFDelta
     ...    InputFile=${modifiedSCF}
    ...    OutputFile=${OutputFile}
    ...    ParameterToDelete=${ParameterToDelete}
    ...    MOsToAdd=${MOsToAdd}
    ...    ParamterToModify=${ParamterToModify}
    ...    ListParamterToModify=${ListParamterToModify}
    ...    ListToAdd=${ListToAdd}
#PARAMS_TO_DELETE_496_C_013 = [
#    #can be Mo, Element, list and so on.
#	dict(dist_name='MRBTS-207', p_name='btsName'),
#	dict(dist_name='MRBTS-207', list_name='snssaiDNListSSS')
#]
#MOs_TO_ADD_496_C_013=[
#	dict(class_name='com.nokia.srbts.nrbts:SNSSAI', dist_name='MRBTS-207/NRBTS-207/SNSSAI-2', version='NRBTSCL5G20A_2003_200'),
#	#element, Lists under Mos can be add by ParamterToModify & ListToAdd
#	dict(class_name='com.nokia.srbts.nrbts:TRACKINGAREA', dist_name='MRBTS-207/NRBTS-207/TRACKINGAREA-220', version='NRBTSCL5G20A_2003_200')
#]
#PARAMS_TO_MODIFY_496_C_013= [
#    #modify Element under Mo, will add if not present.
#    dict(value='BTS_496_C_013', dist_name='MRBTS-207', p_name='btsName'),
#	dict(value='BTS_496_C_013', dist_name='MRBTS-207', p_name='ADDDDDD')
#]
#LIST_PARAMS_TO_MODIFY_496_C_013= [
#    #modify List->items Element by Pname with index.
#    dict(dist_name='MRBTS-207/NRBTS-207/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1', list_name='searchSpaceCommon',
#elements=[dict(p_name='coresetId',value='000', index=0),dict(p_name='coresetId',value='111', index=1)])
#]
#LIST_TO_ADD_496_C_013 = [
#    #Add list Element and List Items.
#	dict(dist_name='MRBTS-207', list_name='uacAcCatList', elements=['MRBTS-207/NRBTS-207/SNSSAI-1']),
#	dict(dist_name='MRBTS-207', list_name='uacAcCatList',
#		elements=dict(accessCategory='1',uacBarringInfoSetIndex='1')),
#	dict(dist_name='MRBTS-207', list_name='uacAcCatList',
#		elements=dict(accessCategory2='2',uacBarringInfoSetIndex2='2')),
#	dict(dist_name='MRBTS-207', list_name='snssaiDNList', elements=['MRBTS-207/NRBTS-207/SNSSAI-1'])
#]
gNB.ModifySCF
    [Documentation]   Delete the parameters in SCF if ParameterToDelete present, Can be MO,List,and Element with P Name
    ...               Add Mos to SCF, can be used with ParamterToModify and ListToAdd to add element and list.
    ...               Modify the element by P Name if ParamterToModify present. Element under MOs, Add if element not present
    ...               Modify List element by P Name if ListParamterToModify present. Element under List/Items match by index
    ...               Add specify List element and items if ListToAdd present. Delete list first by ParameterToDelete
    ...               You can refer to the parameters defined above.
    [Arguments]       ${InputFile}
    ...               ${OutputFile}
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
    scf.Load Scf          file_path=${InputFile}
    run keyword if  not ${ParameterToDelete}=='NULL'     gNB._DeleteObjects    parameters_lists=${ParameterToDelete}
    run keyword if  not ${MOsToAdd}=='NULL'     gNB._AddMOs    parameters_lists=${MOsToAdd}
    run keyword if  not ${ParamterToModify}=='NULL'     gNB._ModifyElementsByPName    parameters_lists=${ParamterToModify}
    run keyword if  not ${ListParamterToModify}=='NULL'     gNB._ModifyListElementsByPName    parameters_lists=${ListParamterToModify}
    run keyword if  not ${ListToAdd}=='NULL'     gNB._AddLists    parameters_lists=${ListToAdd}
    scf.Save Scf          file_path=${OutputFile}

#    run keyword unless    ${ParamterToDelete}=='NULL'    gNB.Remove Elements From Scf  input_scf=${InputFile}  output_scf=${OutputFile}
#    ...    parameters_lists=${ParamterToDelete}
gNB._AddMOs
    [Documentation]   Add Mos
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${item}[version]
    END
gNB._ModifyElementsByPName
    [Documentation]   1. Modify Element , add if not present.
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_element_in_object    dist_name=${item}[dist_name]    p_name=${item}[p_name]
#   \    ${res_list_name}=    Run Keyword And Ignore error    set test variable    ${list_name_to_delete}   &{item}[list_name]
        Run Keyword If    '${res}'=='True'     scf.modify_scf_element    value=${item}[value]   &{item}
        ...      ELSE                          scf.add element to scf
        ...          value=${item}[value]   dist_name=${item}[dist_name]    p_name=${item}[p_name]
    END

gNB._ModifyListElementsByPName
    [Documentation]   Modify List element. report error If not present
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'=='True'  gNB._ModifyListElements    dist_name=${item}[dist_name]  list_name=${item}[list_name]
        ...        elements=${item}[elements]
    END

gNB._ModifyListElements
    [Arguments]   ${dist_name}    ${list_name}    ${elements}
    FOR    ${item}   IN    @{elements}
        scf.modify_scf_element    value=${item}[value]   dist_name=${dist_name}  list_name=${list_name}
        ...    p_name=${item}[p_name]    index=${item}[index]
    END

gNB._AddLists
    [Documentation]   add List items and elements, if you don't know if items present or not, remove it first.
    [Arguments]    ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
#    \    Run Keyword If    '${res}'=='True'    scf.remove list from scf     dist_name=&{item}[dist_name]    list_name=&{item}[list_name]
        Run Keyword If    '${res}'!='True'     scf.add_list_to_scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        ${res}=    Run Keyword And Ignore error    scf.add item to list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
        Run keyword if    ${res} != ('PASS', None)    scf.add_elements_to_list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END

gNB._DeleteObjects
    [Documentation]   Remove object , Mo, List, Element with p_name.
    [Arguments]     ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res_dist_name}=    Run Keyword And Ignore error    set suite variable    ${dist_name_to_delete}   ${item}[dist_name]
        ${res_list_name}=    Run Keyword And Ignore error    set suite variable    ${list_name_to_delete}   ${item}[list_name]
        ${res_p_name}=    Run Keyword And Ignore error    set suite variable    ${p_name_to_delete}   ${item}[p_name]
        Run Keyword If   ${res_p_name}== ('PASS', None)
        ...              Run Keyword And Ignore error    scf.Remove Element From Scf    &{item}
        Run Keyword If   ${res_list_name}== ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_list_from_scf    dist_name=${item}[dist_name]   list_name=${item}[list_name]
        Run Keyword If   ${res_list_name}!= ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END

#--------
gNB.Modify SCF Elements
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load Scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.modify_scf_element    value=${item}[value]   dist_name=${item}[dist_name]  p_name=${item}[p_name]
    END
    scf.Save Scf    ${output_scf}

gNB.Remove MO From Scf
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load Scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END
    scf.Save Scf    ${output_scf}

gNB.Remove Lists From Scf
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load Scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.remove_list_from_scf    dist_name=${item}[dist_name]   list_name=${item}[list_name]
    END
    scf.Save Scf    ${output_scf}

gNB.Remove Elements From Scf
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load Scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.Remove Element From Scf    &{item}
    END
    scf.Save Scf    ${output_scf}

gNB.Add objects to scf
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${item}[version]
    END
    scf.Save scf    ${output_scf}

gNB.Add elements to object
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add element to scf  dist_name=${item}[dist_name]    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${output_scf}

gNB.Add lists to object
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add list to scf  dist_name=${item}[dist_name]   list_name=${item}[list_name]
    END
    scf.Save scf    ${output_scf}

gNB.Add items to list
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add item to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    scf.Save scf    ${output_scf}

gNB.Add elements to list
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    ${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add elements to list  dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END
    scf.Save scf    ${output_scf}

gNB.Commission
    [Arguments]    ${scf_file}    ${oam_type}=${OAM_TYPE}     ${timeout}=${600}
    run keyword if  '${oam_type}'=='megazone'    Megazone.commission   scf_file=${scf_file}
    ...   ELSE    COAM_Admin.commission   scf_file=${scf_file}   timeout=${timeout}

gNB.SwconfigUpdate
    [Documentation]  download swconfig from QT gitlab.
    ...     Precondition:  Tag set on case, Above6GHz or Blow6GHz(default), UE_Prisma or UE_Cobham(default).
    ...     Step 1: Backup old swconfig.
    ...     Step 2: Download file with specified ${GIT_TAG} tag.
    ...     Step 3: if not find specified tag, will down trunk tag.
    ...     Step 4: if not find any file. will rollback use the backup file by Step1.
    ...     NOTE: Only few tag and stream on gitlab, need more support by QT team.
    [Arguments]  ${GIT_TAG}=5.1835.123
    ...      ${STREAM}=5.1835
    @{time}    Get Time    year month day hour min sec
    ${time_stamp}=    Set Variable    ${EMPTY}
    FOR    ${item}    IN    @{time}
        ${time_stamp}    Catenate    SEPARATOR=    ${time_stamp}    ${item}
    END
    ${backup file}=   Catenate    SEPARATOR=_Backup_    swconfig.txt    ${time_stamp}
    run   mv ${CFGFILE_PATH}/swconfig.txt ${CFGFILE_PATH}/${backup file}
    ${blow6G}=    Set Variable If    'Blow6GHz' in ${TEST TAGS}    below6G
    ...           'Above6GHz' in ${TEST TAGS}    above6G
    ...           below6G
    ${ue}=    Set Variable If     'UE_Prisma' in ${TEST TAGS}    prisma
    ...           'UE_Cobham' in ${TEST TAGS}    viavi
    ...           viavi
    ${ulr}=   set Variable   https://gitlabe1.ext.net.nokia.com/5GRAN_HZ/gnb_configuration/raw
    FOR    ${TAG}   IN    ${GIT_TAG}    master
        log many      download Tag:   ${TAG}
        ${FILE_URL}=  Set Variable  ${ulr}/${TAG}/${STREAM}/${blow6G}/${ue}/swconfig.txt?private_token=P4rj-r7_NZZmRJZZaBTk
        ${output}=  run  wget ${FILE_URL} -O ${CFGFILE_PATH}/swconfig.txt
        ${status}=  Run Keyword And Return Status    Should Not Contain    ${output}   ERROR
        Exit For Loop IF    ${status}
    END
    Run keyword if     ${status}==False     run   cp ${CFGFILE_PATH}/${backup file} ${CFGFILE_PATH}/swconfig.txt
gNB.SwconfigModify
    [Documentation]  modify swconfig with modify list.
    ...     Delete operation: set item to empty.  0x46010d=
    ...     Modify and add operation: find item firstly, modify value if find, or add the item.
    ...     Example: @{list}=  Create list   0x460017=2    0x46010d=   0x4600bf=1111
    ...     gNB.SwconfigModify    ${list}
    [Arguments]  ${item list}    ${filename}=${CFGFILE_PATH}/swconfig.txt
    log  ${item list}
    ${length}=   Get Length   ${item list}
    FOR  ${item}  IN    @{item list}
        ${item name}  ${value}    Split String   ${item}    separator==
        log many   ${item name}  ${value}
        Basic.SedReplaceLine  matchValue=${item name}    newValue=${item}    file=${filename}    force=true
        run    cat ${filename}
    END
gNB.ReplaceSwconfig
    [Documentation]  replace swconfig to asik.
    ...     Precondition:  define the ${CFGFILE_PATH}.
    ...     Note: if not need download swconfig. just use this keyword with manual put swconfig into ${CFGFILE_PATH}.
    [Arguments]     ${Path}=${CFGFILE_PATH}    ${filename}=swconfig.txt
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.UploadFile    local_path=${Path}/${filename}    remote_path=/ffs/run/swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /ffs/run/ && crasign swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

gNB.GetSwconfigFile
    [Arguments]     ${Path}=${LOG_PATH}
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    ${res}  run keyword and ignore error  Conn.DownloadFile  local_path=${Path}/swconfig.txt  remote_path=/ffs/run/swconfig.txt  alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}
    return from keyword if    '${res[0]}'!='PASS'    None
    [Return]    ${Path}/swconfig.txt

gNB.ReplaceSWconfigByRules
    [Documentation]  Should be called after SoftwareUpdate.Check_AirScaleGNB_Version
    ${stream}   ${subversion}   Split String From Right    string=${build_version}   separator=.     max_split=1
    ${result}=   run    ls ${CFGFILE_PATH}/swconfig.txt
    ${result}=	 Remove String    ${result}    '
    Run Keyword If     '${result}'=='${CFGFILE_PATH}/swconfig.txt'
    ...    gNB.ReplaceSwconfig
    ...  ELSE    Run Keywords    gNB.SwconfigUpdate   ${build_version}    ${stream}
    ...  AND    gNB.SwconfigModify   ${SWconfig_items}
    ...  AND    gNB.ReplaceSwconfig
gNB.CheckgNBVersion
    [Arguments]     ${alias}=asik
    wait until keyword succeeds     15min    30sec       ssh.Connect to    ${ASIK_IP}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    ...                alias=${alias}
    ${Target File}=  ssh.execute  command=cd /ffs/run && ls TargetBD_*.xml  connection=${alias}
    #${Target File}=  Remove String   ${Target File}   .xml
    ${Target File}  ${xml}    Split String    ${Target File}    separator=.
    @{output}    Split String    ${Target File}    separator=_
    @{output}    Get Substring   ${output}    -3
    ${Target Version}=   Set Variable    5G19
    FOR    ${item}    IN    @{output}
        ${item string}=  Remove String Using Regexp   ${item}   ^(0)*
        ${item string}=    set variable if   '${item}'=='0000'    0    ${item string}
        ${Target Version}    Catenate    SEPARATOR=.    ${Target Version}    ${item string}
	END
    ${Target Version}   Remove String   ${Target Version}   5G19.
    [return]    ${Target Version}
#put files into sdm_n
gNB.CollectLog
    [Arguments]    ${logName}=gNB.log
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.Execute  cmd=rm -rf /tmp/gNB.log   alias=${ALIAS_ASIK}
    Conn.Execute  cmd=rm -rf /tmp/${logName}.tgz   alias=${ALIAS_ASIK}
    Conn.Execute  cmd=/user/toor4nsn/wa/classicalbts_log_collector.sh -o /tmp/gNB.log   alias=${ALIAS_ASIK}
    Conn.Execute  cmd=tar czvf /tmp/${logName}.tgz /tmp/gNB.log/  alias=${ALIAS_ASIK}
    Conn.DownloadFile  local_path=${LOG_PATH}/${logName}.tgz  remote_path=/tmp/${logName}.tgz   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}

gNB.VerifyOnAir
#    ${output}    ssh.execute   #not valid when E1 interface is introduced, eg, 0.835.582
#    ...    cat /tmp/node_0xe002/tmp/startup_cp_cl.log | grep "CuConfigurationUpdateAck"    connection=${ALIAS_ASIK}
#    #Should Contain    ${output}    CuConfigurationUpdateAck
#    Should Not Be Empty    ${output}
    gNB.Connect
    ${output}    ssh.execute    cat /ram/node_0xe000/opt/nokia/SS_MzOam/cloud-racoam/logs/startup_RACOAM.log | grep CPCM_CELL_STATUS_IND_MSG
    ...    connection=${ALIAS_ASIK}
    Should Not Be Empty    ${output}

    ${output}    ssh.execute    cat /ram/node_0xe000/opt/nokia/SS_MzOam/cloud-racoam/logs/startup_RACOAM.log |grep "BTS on air"
    ...    connection=${ALIAS_ASIK}
    Should Not Be Empty    ${output}

gNB.VerifyOnAirUntilReadyViaLog
    wait until keyword succeeds    15min    1min    gNB.VerifyOnAir

gNB.VerifyOnAirUntilReadyViaWebUI
    [Documentation]    this KW is to check the all the cell status is online in WEBUI
    selenium_megazone.enable_virtual_display
    Wait Until Keyword Succeeds    5min    5s     selenium_megazone.login
    ...     url=https://${ASIK_IP}    username=Nemuadmin    password=nemuuser
    sleep    2s
    Wait Until Keyword Succeeds    15min    5s     gNB.VerifyOnAirViaWebUI
    selenium_megazone.logout
    selenium_megazone.disable_virtual_display

gNB.VerifyOnAirViaWebUI
    ${output}    selenium_megazone.get_cell_status_from_site_management_page
    should be equal      ${output['availability_status']}    online
    should be equal      ${output['procedural_status']}    configured
    should be equal      ${output['operational_state']}    enabled

gNB.BackupSCF
    [Arguments]   ${oam_type}=${OAM_TYPE}
    ${bakupfolder}    set variable    backups
    run   command=mkdir ${LOG_PATH}/${bakupfolder}
    set global variable    ${BACKUP_DIR}    ${LOG_PATH}/${bakupfolder}
    ${scffile}=    run keyword if    '${oam_type}'=='megazone'   WEBBUI.BackupSCF
    ...    ELSE     COAM_Admin.BackupSCF
    ${scf_file_path}    ${scf_file_name}    OperatingSystem.split path    ${scffile}
    sleep    3s
    OperatingSystem.Copy File    ${scffile}    ${BACKUP_DIR}
    set global variable    ${BACKUP_SCF}    ${BACKUP_DIR}/${scf_file_name}

gNB.PingOAMUntilSuccess
   Wait until keyword succeeds     2min    5sec  gNB.PingOAM

gNB.CheckBTSReset
    ${status}    Run Keyword And Return Status    gNB.PingOAM
    Should Be True    '${status}'=='False'

gNB.PingOAM
    ${result}  run   command=ping ${ASIK_IP} -c 10
    should contain    ${result}    64 bytes from ${ASIK_IP}

gNB.GetDLThroughput
    [Arguments]    ${ALIAS_ASP_1A}=ASP_1A    ${duration}=30    ${location}=${17}
    ${duration}    set variable if     ${duration}<30    30    ${duration}
    ${DL_TP}   Get_And_Calculate_DL_throughput    alias=${ALIAS_ASP_1A}    duration=${duration}    location=${location}
    [Return]    ${DL_TP}
gNB.GetULThroughput
    [Arguments]    ${ALIAS_ASP_1A}=ASP_1A    ${duration}=30
    ${duration}    set variable if     ${duration}<30    30    ${duration}
    ${UL_TP}   Get_And_Calculate_UL_throughput    ${ALIAS_ASP_1A}    ${duration}
    [Return]    ${UL_TP}
gNB.GetULBlerAndThroughput
    [Arguments]    ${ALIAS_LONER}=LONER    ${ALIAS_ASP_1A}=ASP_1A    ${duration}=30
    Conn.Execute    cmd=/sbin/devmem 0xDF50C154 32 0x100   alias=${ALIAS_LONER}
    ${pre_crc}    Conn.Execute    cmd=/sbin/devmem 0xDF50C150 32   alias=${ALIAS_LONER}
    ${pre_tp}     Conn.Execute    cmd=/sbin/devmem 0xDF50C14C 32   alias=${ALIAS_LONER}
    Conn.Execute    cmd=/sbin/devmem 0xDF50C154 32 0x0   alias=${ALIAS_LONER}
    Conn.ExecuteUnblock  cmd=journalctl -f | grep L2_LO_UL    timeout=${duration}    alias=${ALIAS_ASP_1A}
    Sleep    ${duration}
    ${reply}    Conn.ReceiveReply  size=3000    alias=${ALIAS_ASP_1A}
    ${UL_TP}    Calculate_UL_throughput    ${reply}
    Conn.Execute    cmd=/sbin/devmem 0xDF50C154 32 0x100   alias=${ALIAS_LONER}
    ${cur_crc}    Conn.Execute    cmd=/sbin/devmem 0xDF50C150 32   alias=${ALIAS_LONER}
    ${cur_tp}     Conn.Execute    cmd=/sbin/devmem 0xDF50C14C 32   alias=${ALIAS_LONER}
    Conn.Execute    cmd=/sbin/devmem 0xDF50C154 32 0x0   alias=${ALIAS_LONER}
    ${crc}    Evaluate    ${cur_crc.strip()}-${pre_crc.strip()}
    ${tp}     Evaluate    ${cur_tp.strip()}-${pre_tp.strip()}
    ${bler}    Run Keyword If    ${tp} > 0    Evaluate    float(${crc})*100/${tp}
    ...    ELSE    set variable    100
    [Return]   ${UL_TP}    ${bler}

gNB.VerifyOnAirViaOAMUntilReady
    [Arguments]   ${oam_type}=${OAM_TYPE}
    ${status}=    run keyword if   '${oam_type}'=='megazone'
    ...    run keyword and return status    gNB.VerifyOnAirUntilReadyViaWebUI
    ...    ELSE    run keyword and return status    COAM_VerifyOnAirViaFrontendAndBackend
    should be true    ${status}

gNB.EnableCplaneDebugLog
   [Arguments]    ${Connection}=${ALIAS_ASIK}
   Conn.Execute  cmd=/user/toor4nsn/wa/cplaneClassicalDebugsOn.sh    alias=${Connection}
   Conn.Execute  cmd=cd /ffs/run;rm HashContainer*    alias=${Connection}
   Conn.Execute  cmd=cd /ffs/run;cp swconfig.txt swconfig.txt.bak   alias=${Connection}
   @{log_flags}   create list    0x1003F=1    0x10040=1   0x100025=1
   gNB.SwconfigModify    ${log_flags}
   gNB.ReplaceSwconfig
   gNB.Connect
   Conn.Execute  cmd=reboot    alias=${Connection}

gNB.GetBackhaulName
    [Documentation]    Return ALIAS_ASIK Means ASIB else ASIK
    [Arguments]   ${alias}=${ALIAS_ASIK}
    ${resp}    ssh.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0    connection=${alias}
    ${BackhaulName}      set variable      fp0
    ${BackhaulName}      set variable if     ${resp.count("ASIB")} > 0     br1    ${BackhaulName}
    ${BackhaulName}      set variable if     ${resp.count("ASIL")} > 0     br0    ${BackhaulName}
    ${BackhaulName}      set variable if     ${resp.count("ASOE")} > 0     br0    ${BackhaulName}
    [Return]   ${BackhaulName}

gNB.GetSystemModuleName
    [Documentation]    Return ALIAS_ASIK Means ASIB else ASIK
    [Arguments]   ${alias}=${ALIAS_ASIK}
    ${resp}      ssh.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0    connection=${alias}
    ${Name}      set variable      ASIK
    ${Name}      set variable if     ${resp.count("ASIB")} > 0     ASIB    ${Name}
    ${Name}      set variable if     ${resp.count("ASIL")} > 0     ASIL    ${Name}
    ${Name}      set variable if     ${resp.count("ASOE")} > 0     ASOE    ${Name}
    [Return]   ${Name}

gNB.GetSystemModuleType
    [Documentation]    Return ALIAS_ASIK Means ASIB else ASIK
    [Arguments]   ${alias}=${ALIAS_ASIK}
    ${resp}      ssh.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0    connection=${alias}
    ${connection}      set variable      ${ALIAS_ASIK_SLAVE}
    ${connection}      set variable if     ${resp.count("ASIB")} > 0     ${ALIAS_ASIK}    ${connection}
    ${connection}      set variable if     ${resp.count("ASIL")} > 0     ${ALIAS_ASIK}    ${connection}
    [Return]   ${connection}
#    [Return]   ${ALIAS_ASIK}

gNB.ModifySSHDConfig
    [Documentation]    This is a WA for YAFT. When YAFT failed with "Incompatible xxx" error, you can use this WA.
    gNB.Connect
    ${newvalue}=  Catenate    SEPARATOR=   KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,
    ...     ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1,
    ...     diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1
    Basic.SedReplaceLine  matchValue=MACs  newValue=${SPACE}  file=/etc/ssh/sshd_config  alias=${ALIAS_ASIK}
    Basic.SedReplaceLine  matchValue=KexAlgorithms  newValue=${newvalue}  file=/etc/ssh/sshd_config  alias=${ALIAS_ASIK}  force=true
    Conn.Execute    cmd=cat /etc/ssh/sshd_config    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=systemctl restart sshd      alias=${ALIAS_ASIK}
    sleep  10s
    run keyword and ignore error    gNB.Disconnect

gNB.IsPrimaryCoreInLeftSubrack
#    gNB.Connect
    ${value}    ssh.Execute     hostname    connection=${ALIAS_ASIK}
    ${hostname}=    Remove String    ${value}    \r\n
    ${IsPrimaryCoreInLeftSubrack}    set variable    ${True}
    ${IsPrimaryCoreInLeftSubrack}    set variable if    '${hostname}'=='fct-4a'    ${False}    ${IsPrimaryCoreInLeftSubrack}
    ${IsPrimaryCoreInLeftSubrack}    set variable if    '${hostname}'=='fct-0a'    ${True}    ${IsPrimaryCoreInLeftSubrack}

#    gNB.Disconnect
    [Return]  ${IsPrimaryCoreInLeftSubrack}

gNB.GetCellIDbyIndex
    [Arguments]   ${cell_index_list}
    COAM_WebEM.Login
    ${list_of_cell_ids}    Create list
    FOR    ${cell_idx}    IN    @{cell_index_list}
        ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
        Append to list   ${list_of_cell_ids}    ${cell_info['NR cell ID']}
    END
    COAM_WebEM.Logout
    [Return]    ${list_of_cell_ids}

gNB.GetPCIbyIndex
    [Arguments]   ${cell_index_list}
    COAM_WebEM.Login
    ${list_of_cell_pcis}    Create list
    FOR    ${cell_idx}    IN    @{cell_index_list}
        ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
        Append to list   ${list_of_cell_pcis}    ${cell_info['Physical layer cell ID']}
    END
    COAM_WebEM.Logout
    [Return]    ${list_of_cell_pcis}

gNB.get_container_id
    [Arguments]    ${nodename}    ${gnbip}=${ASIK_IP}    ${targetNode}=None
    ${isPrimaryCoreInLeftSubrack}    gNB.IsPrimaryCoreInLeftSubrack
    Run keyword If  '${targetNode}'=='secondary'   DP.setup    gnbip=${gnbip}
    ...              isPrimaryCoreInLeftSubrack=${isPrimaryCoreInLeftSubrack}  targetNode=${targetNode}
    ...              ELSE  DP.setup    gnbip=${gnbip}  isPrimaryCoreInLeftSubrack=${isPrimaryCoreInLeftSubrack}
    ${dpname}    ${dpip}    ${nodeid}    ${nodename}    ${nodepath}    DP.get_container    nodename=${nodename}
    [Return]    ${nodeid}    ${dpip}

UTE.CleanFirefox
    Log to Console    CleanFirefox
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver

WA.VerifyOnAirUntilReady
    [Documentation]  pass either checking in log or WebUI
    [Arguments]   ${oam_type}=${OAM_TYPE}
    ${SA}=    run keyword and return status    File Should Exist     ${CFGFILE_PATH}/SA.txt
    ${by_log}=    run keyword and return status    gNB.VerifyOnAirUntilReadyViaLog
    ${by_webui}=    run keyword if   '${oam_type}'=='megazone'
    ...    run keyword and return status    gNB.VerifyOnAirUntilReadyViaWebUI
    ...    ELSE    run keyword and return status    COAM_Admin.VerifyCellOnAir
    run keyword if    ${SA}    should be true    ${by_log} or ${by_webui}

WA.ReplaceOamIPToLmpIP
  [Documentation]  triggered only if gNB OAM IP is not pingable after SW upgrade with NIDD changed.
  ${pingable}    run keyword and return status    gNB.PingOAMUntilSuccess
  run keyword if  not ${pingable}    run keywords    set test variable    ${ASIK_IP}    ${ASIK_LMP_IP}
  ...   AND    Log    EIF port (OAM) is not reachable, connect via ${ASIK_IP} instead.

5GC.DeleteIMSI
    [Documentation]   1.Connect to AMF  2.delete IMSI  3.Check IMSI is delete successfully
    [Arguments]    ${imsi}  ${AMF_IP}   ${AMF_USERNAME}   ${AMF_PASSWORD}   ${alias}=${ALIAS_AMF}
    Conn.ConnectToAMF    AMF_IP=${AMF_IP}  AMF_USERNAME=${AMF_USERNAME}  AMF_PASSWORD=${AMF_PASSWORD}  alias=${alias}
    ${output}   ssh.execute   command=cmm subscriber delete --imsi ${imsi}    connection=${alias}
    SLEEP    60s
    ${output}   ssh.execute   command=cmm subscriber show --imsi ${imsi}      connection=${alias}
    Should not Be Empty    ${output}
    run keyword and ignore error    Conn.Disconnect  alias=${alias}
#---------------------L3sim Specific-----------------------------------------------------------------------------------
L3sim.gNBAddition
    FOR    ${UE_Item}    IN RANGE    0   ${UE_NUM}
        Run Keyword And Ignore error    taf.epcsim.Execute egate command    cmd=l3_ue_script ue=${UE_Item} name=dc.lua entry=DoX2GnbAddition(50,5)
        ...                                    timeout=60
        ...                                    pass_regexp=Script is finished
        ...                                    alias=EGATE
        sleep   5s
    END
L3sim.CollectLog
    [Arguments]    ${logName}=egate_console.log
    #taf.epcsim.Execute egate command    cmd=sim_log_set flush
    #...                                        alias=EGATE
    #sleep    5s
    run    cp ${WTS_FILE_PATH}/egate_console.log ${LOG_PATH}/${logName}.log

MultiUE._L3CallBuildParameters
    [Arguments]    ${power_reset}=false    ${ue_mode}=SA    ${apn}=wap1nokiacom    ${iperf_port}=default
    ...    ${multidrb_QoS_dest}=null   ${check_tput_on_ue}=false    ${target_avg_percent}=0.8
    ...    ${target_min_percent}=0.5    ${check_throughput_duration}=120    ${call_loop}=1
    ...    ${cell_index_list}=1    ${dl_target_throughput}=5    ${ul_target_throughput}=5
    ...    ${ue_index}=0    ${detach_request}=true    ${protocol}=udp
    ${UECONFIG}=  Catenate     SEPARATOR=${SPACE}
    ...                   {"ue_index_for_call":[${ue_index}],
    ...                          "${ue_index}":{
    ...                                        "detach_request":${detach_request},
    ...                                        "power_reset":"${power_reset}",
    ...                                        "ue_mode":"${ue_mode}",
    ...                                        "apn":"${apn}",
    ...                                        "iperf_port":"${iperf_port}",
    ...                                        "protocol":"${protocol}",
    ...                                        "multidrb_QoS_dest":${multidrb_QoS_dest},
    ...                                        "check_tput_on_ue":"${check_tput_on_ue}",
    ...                                        "target_avg_percent":"${target_avg_percent}",
    ...                                        "target_min_percent":"${target_min_percent}",
    ...                                        "check_throughput_duration":"${check_throughput_duration}",
    ...                                        "call_loop": ${call_loop},
    ...                                        "cell_index_list":[${cell_index_list}],
    ...                                        "dl":{"target_throughput":"${dl_target_throughput}"},
    ...                                        "ul":{"target_throughput":"${ul_target_throughput}"}
    ...                                         }
    ...                   }
    ${UECONFIG}    Evaluate        json.loads('''${UECONFIG}''')                   json
    log to console    ${UECONFIG}
    [Return]    ${UECONFIG}

MultiUE._GetUECallMaxLoop
    [Documentation]   Get max call loop for multi UE Call, default 1
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    return from keyword if    "${UECFG}"=="NULL"    1
    ${maxloop}    set variable    ${0}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['call_loop']                        default_value=1
        log    ${UECFG}
        log    ${UECFG['${ue_index}']['call_loop']}
        ${loop}    Evaluate    ${UECFG['${ue_index}']['call_loop']}+0
        ${maxloop}    set variable if    ${loop}>${maxloop}     ${loop}    ${maxloop}
    END
    [Return]    ${maxloop}

MultiUE._ResetCounter
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        set suite variable    ${MultiUEL3Call_${ue_index}_loop_internal_use}    0
    END

MultiUE.L3Call
    [Documentation]   Do call loop for multi ue. if no ${UECFG} defined, other parameters list is used
    ...    Otherwise, UEs and configuration in ${UECFG} is used.
    ...    And you can also use multiUE keyword seperately in your case.
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    ...    ${power_reset}=false    ${ue_mode}=SA    ${apn}=wap1nokiacom    ${iperf_port}=default
    ...    ${multidrb_QoS_dest}=null   ${check_tput_on_ue}=false    ${target_avg_percent}=0.8
    ...    ${target_min_percent}=0.5    ${check_throughput_duration}=120    ${call_loop}=1
    ...    ${cell_index_list}=1    ${dl_target_throughput}=5    ${ul_target_throughput}=5
    ...    ${ue_index}=0    ${detach_request}=true    ${protocol}=udp
    ${UECFG}=    run keyword if     "${UECFG}"=="NULL"   MultiUE._L3CallBuildParameters
    ...    power_reset=${power_reset}    ue_mode=${ue_mode}    apn=${apn}    iperf_port=${iperf_port}
    ...    multidrb_QoS_dest=${multidrb_QoS_dest}   check_tput_on_ue=${check_tput_on_ue}    target_avg_percent=${target_avg_percent}
    ...    target_min_percent=${target_min_percent}    check_throughput_duration=${check_throughput_duration}    call_loop=${call_loop}
    ...    cell_index_list=${cell_index_list}    dl_target_throughput=${dl_target_throughput}    ul_target_throughput=${ul_target_throughput}
    ...    ue_index=${ue_index}    detach_request=${detach_request}    protocol=${protocol}
    ...    ELSE    set variable    ${UECFG}
    set suite variable    ${UECFG}    ${UECFG}
    ${maxloop}    MultiUE._GetUECallMaxLoop    UECFG=${UECFG}    default_ue_index=${default_ue_index}
    log     ${default_ue_index}
    FOR  ${i}    IN RANGE    ${maxloop}
#        run keyword and ignore error           MultiUE.ClearUEInfoFromAMF   UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.PrepareUE
        ...    UECFG=${UECFG}    default_ue_index=${default_ue_index}       singel_loop=${maxloop}
        Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        sleep    5
        Run Keyword And Continue On Failure    MultiUE.StartDLTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StartULTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        #MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
        Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
        #log     ttt${default_ue_index}
    END
    log     ${default_ue_index}
    MultiUE._ResetCounter    UECFG=${UECFG}    default_ue_index=${default_ue_index}

MultiUE.ClearUEInfoFromAMF
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    set suite variable    ${UECFG}    ${UECFG}
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        Basic.CheckVariableValid    var=MultiUEL3Call_${ue_index}_disable_call                    default_value=false
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword and ignore error   AMF.ClearUEInfoFromAMF    ue_imsi=${tl.ues[${ue_index}].imsi}
        ...    hostname=${tl.core.default_ssh_connection_details.addr}
        ...    username=${tl.core.default_ssh_connection_details.username}
        ...    password=${tl.core.default_ssh_connection_details.password}
    END

MultiUE.PrepareUE
    [Documentation]    PrepareUE accouding loop count, if loop reached, disable UE until current multiUE finished.
    ...    If current multiUE finished, MultiUE keyword is disalbed unless this keyword is called again.
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0    ${singel_loop}=true
    set suite variable    ${UECFG}    ${UECFG}
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    @{default_cell_index_list}    create list    1
    set suite variable    ${MultiUEL3Call_LoopDisabled}    true
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        Basic.CheckVariableValid    var=MultiUEL3Call_${ue_index}_Result               default_value=Failed
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['detach_request']         default_value=${true}
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['power_reset']            default_value=false
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['apn']                    default_value=wap1nokiacom
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['ue_mode']                default_value=SA
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['iperf_port']             default_value=default
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['iperf_type']             default_value=via_app
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['protocol']               default_value=udp
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['multidrb_QoS_dest']      default_value=${None}
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['cell_index_list']        default_value=@{default_cell_index_list}
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['dl']['target_throughput']          default_value=5
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['ul']['target_throughput']          default_value=5
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['check_throughput_duration']        default_value=120
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['check_tput_on_ue']                 default_value=false
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['target_min_percent']               default_value=0.8
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['target_avg_percent']               default_value=0.5
        Basic.CheckVariableValid    var=UECFG['${ue_index}']['call_loop']                        default_value=1
        Basic.CheckVariableValid    var=MultiUEL3Call_${ue_index}_loop_internal_use              default_value=0
        Basic.CheckVariableValid    var=MultiUEL3Call_${ue_index}_disable_call                   default_value=false
        ${loop}    Evaluate    ${UECFG['${ue_index}']['call_loop']}+${MultiUEL3Call_${ue_index}_loop_internal_use}
        run keyword if    ${loop}<=0    set suite variable    ${MultiUEL3Call_${ue_index}_disable_call}    true
        ...    ELSE    set suite variable    ${MultiUEL3Call_${ue_index}_disable_call}    false
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        set suite variable    ${MultiUEL3Call_LoopDisabled}    false
        ${loop}    Evaluate    ${MultiUEL3Call_${ue_index}_loop_internal_use}-1
        set suite variable    ${MultiUEL3Call_${ue_index}_loop_internal_use}    ${loop}
        ${cell_id_list}    run keyword if    '${UECFG['${ue_index}']['check_tput_on_ue']}'=='false'    gNB.GetCellIDbyIndex
        ...    cell_index_list=${UECFG['${ue_index}']['cell_index_list']}
        set suite variable     ${UECFG['${ue_index}']['cell_id_list']}    ${cell_id_list}
        ${res}  run keyword and ignore error   power_ue.Prepare UE
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
        ...    detach_request=${UECFG['${ue_index}']['detach_request']}
        ...    power_reset=${UECFG['${ue_index}']['power_reset']}
        run keyword if    '${res[0]}'=='PASS'    set suite variable    ${MultiUEL3Call_${ue_index}_Result}    Pass
        ...    ELSE    Run Keyword And Continue On Failure    Basic.ThroughExceptionWithMsg    msg=Prepare UE_${ue_index} Failed
#        Run Keyword And Continue On Failure   power_ue.UE Detach
#        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
#        ...    power_reset=${UECFG['${ue_index}']['power_reset']}
    END
    run keyword if    '${singel_loop}'=='1'    MultiUE._ResetCounter
    ...        UECFG=${UECFG}    default_ue_index=${default_ue_index}

MultiUE.Attach
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        ${res}  run keyword and ignore error   power_ue.UE Attach
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
        ...    power_reset=${UECFG['${ue_index}']['power_reset']}
        log    ${res}
        run keyword if    '${res[0]}'!='PASS'   run keywords    set suite variable    ${MultiUEL3Call_${ue_index}_Result}    Failed
        ...    AND    Run Keyword And Continue On Failure    Basic.ThroughExceptionWithMsg    msg=Attach UE_${ue_index} Failed
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        sleep    5s
        ${res}  run keyword and ignore error   power_ue.Verify attach
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    4G_check=False    5Grach_ed=${res[1]}
        run keyword if    '${res[0]}'!='PASS'   run keywords    set suite variable    ${MultiUEL3Call_${ue_index}_Result}    Failed
        ...    AND    Run Keyword And Continue On Failure    Basic.ThroughExceptionWithMsg    msg=Check Attach UE_${ue_index} Failed
    END
    log to console   UE attach completed

MultiUE.StartDLTraffic
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    log to console   DL traffic start ...
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    ${UEnum}    Get Length    ${UECFG['ue_index_for_call']}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        run keyword if  '${UECFG['${ue_index}']['dl']['target_throughput']}'=='0'   Continue For Loop
        ${duration}    Evaluate    ${UECFG['${ue_index}']['check_throughput_duration']}+${UEnum}*600
        ${throughput for DL}=    Run Keyword If   '${tl.ues[${ue_index}].capabilities[-1].count('spark')}'=='0'
        ...    Set Variable if    '${tl.ues[${ue_index}].capabilities[-1].count('lte')}'=='0'
        ...    ${UECFG['${ue_index}']['dl']['target_throughput']}M    ${UECFG['${ue_index}']['dl']['target_throughput']}
        ...    ELSE
        ...    Set Variable    ${UECFG['${ue_index}']['dl']['target_throughput']}Mbps/sec
        Run Keyword And Continue On Failure   power_ue.Start traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
        ...    throughput=${throughput for DL}
        ...    duration=${duration}
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}
        ...    multidrb_QoS_dest=${UECFG['${ue_index}']['multidrb_QoS_dest']}
        ...    iperf_type=${UECFG['${ue_index}']['iperf_type']}
        ...    protocol=${UECFG['${ue_index}']['protocol']}
    END

MultiUE.StartULTraffic
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    log to console   UL traffic start ...
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    ${UEnum}    Get Length    ${UECFG['ue_index_for_call']}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        run keyword if  '${UECFG['${ue_index}']['ul']['target_throughput']}'=='0'   Continue For Loop
        ${duration}    Evaluate    ${UECFG['${ue_index}']['check_throughput_duration']}+${UEnum}*600
        ${throughput for UL}    Set Variable if  ${tl.ues[${ue_index}].capabilities[-1].count('lte')}==0
        ...   ${UECFG['${ue_index}']['ul']['target_throughput']}Mbps/sec   ${UECFG['${ue_index}']['ul']['target_throughput']}
        Run Keyword And Continue On Failure   power_ue.Start traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=ul
        ...    throughput=${throughput for UL}
        ...    duration=${duration}
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}
        ...    multidrb_QoS_dest=${UECFG['${ue_index}']['multidrb_QoS_dest']}
        ...    iperf_type=${UECFG['${ue_index}']['iperf_type']}
    END

MultiUE._CheckOneUEThoughput
    [Arguments]    ${UECFG}=NULL   ${check_tput_on_ue}=false    ${ue_index}=0
    ${tput_log}    power_ue.Collect Tput
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}
    ...    duration=${UECFG['${ue_index}']['check_throughput_duration']}
    ...    ue_index=${ue_index}
    ...    ue_alias=UE_${ue_index}
    ${output}=    run keyword if     '${check_tput_on_ue}'=='true'   Power_ue.Check Bi Tput
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    log=${tput_log}
    ...    cells=UE_${ue_index}
    ...    ultarget_throughput=${UECFG['${ue_index}']['ul']['target_throughput']}
    ...    dltarget_throughput=${UECFG['${ue_index}']['dl']['target_throughput']}
    ...    target_avg_percent=${UECFG['${ue_index}']['target_avg_percent']}
    ...    min_percent=${UECFG['${ue_index}']['target_min_percent']}
    ...    ue_index=${ue_index}
    ...    ELSE    Power_ue.Check Bi Tput
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    log=${tput_log}
    ...    cells=${UECFG['${ue_index}']['cell_id_list']}
    ...    ultarget_throughput=${UECFG['${ue_index}']['ul']['target_throughput']}
    ...    dltarget_throughput=${UECFG['${ue_index}']['dl']['target_throughput']}
    ...    target_avg_percent=${UECFG['${ue_index}']['target_avg_percent']}
    ...    min_percent=${UECFG['${ue_index}']['target_min_percent']}
    ...    ue_index=${ue_index}
    ${result}=    Convert To String    ${output}
    Should Not Contain    ${result}    False

MultiUE.CheckThoughput
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    log to console     start to check traffic ...
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        log to console     start to check UE_${ue_index}'s traffic ...
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        run keyword if  '${UECFG['${ue_index}']['dl']['target_throughput']}'=='0' and '${UECFG['${ue_index}']['ul']['target_throughput']}'=='0'
        ...    Continue For Loop
        Run Keyword And Continue On Failure    MultiUE._CheckOneUEThoughput
        ...    UECFG=${UECFG}
        ...    ue_index=${ue_index}
        ...    check_tput_on_ue=${UECFG['${ue_index}']['check_tput_on_ue']}
    END
    log to console     traffic check completed...
MultiUE.StopDLTraffic
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        Run Keyword And Continue On Failure   power_ue.Stop traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}
    END

MultiUE.StopULTraffic
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        Run Keyword And Continue On Failure   power_ue.Stop traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=ul
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}
    END

MultiUE.Detach
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0
    Basic.CheckVariableValid    var=MultiUEL3Call_LoopDisabled          default_value=false
    return from keyword if    '${MultiUEL3Call_LoopDisabled}'=='true'
    @{default_ue_index_list}    Split String    ${default_ue_index.replace(" ", "")}    separator=,
    Basic.CheckVariableValid    var=UECFG['ue_index_for_call']       default_value=@{default_ue_index_list}
    FOR   ${ue_index}   IN   @{UECFG['ue_index_for_call']}
        run keyword if    '${MultiUEL3Call_${ue_index}_disable_call}'=='true'    Continue For Loop
        run keyword if    '${MultiUEL3Call_${ue_index}_Result}'=='Failed'    Continue For Loop
        Run Keyword And Continue On Failure   power_ue.UE Detach
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
        ...   power_reset=${UECFG['${ue_index}']['power_reset']}
    END

UE.One_UE_Call_with_traffic
    [Arguments]   ${ue_type}=${UE_TYPE}   ${ue_index}=${0}       ${Traffic_hold}=False  ${imsi}=${IMSI}
    ...           ${attach_mode}=5G_SA    ${ue_mode}=SA          ${power_reset}=True    ${apn_address}=wap1nokiacom
    ...           ${duration_dl}=600      ${duration_ul}=600     ${detach_request}=${true}
    ...           ${throughput_dl}=10MKbits/sec     ${throughput_ul}=5MKbits/sec        ${iperf_port}=default
    ...           ${check_throughput_dl}=5          ${check_throughput_ul}=2            ${start_offset}=${0}
    ...           ${4G5G_check}=true    ${cell_idx}=1   ${check_avg_percent}=0.95    ${min_percent}=0.85
    [Documentation]  Main test Steps:

    ################################## STEP1: Prepare UE for L3 call #####################
    log to console    STEP1: Prepare UE for L3 call
    run keyword and ignore error    5GC.DeleteIMSI
    ...    imsi=${imsi}  AMF_IP=${5GC_IP}  AMF_USERNAME=${5GC_USERNAME}  AMF_PASSWORD=${5GC_PASSWORD}  alias=${ALIAS_5GC}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}     detach_request=${detach_request}    power_reset=${power_reset}
    Run Keyword And Ignore Error    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
    sleep     10s
    ################################## STEP2: UE ATTACH ##################################
    log to console    STEP2: UE ATTACH
    ${Spark}=  set variable if   "${ue_type}"=="huawei_sigspark" or "${ue_type}"=="askey_sigspark"    True   Flase
    ${5Grach_ed}=   run keyword if    "${attach_mode}"=="5G_NSA" and "${Spark}"=="True" and "${4G5G_check}"=="true"
    ...      UE.Spark_One_UE_attach
    ...         ue_type=${ue_type}    ue_index=${ue_index}   attach_mode=${attach_mode}
    ...    ELSE
    ...      power_ue.UE Attach
    ...         ue_type=${ue_type}    ue_index=${ue_index}   power_reset=${power_reset}   attach_mode=${attach_mode}
    log to console    UE ATTACH success
    ################################## STEP2.1: VERIFY ATTACH ############################
    log to console    STEP2.1: VERIFY ATTACH
    power_ue.Verify attach    ue_type=${ue_type}   ue_index=${ue_index}    4G_check=False    5Grach_ed=${5Grach_ed}
    run keyword if    "${attach_mode}"=="5G_NSA" and "${Spark}"=="True"     run keyword
    ...        Should be Equal as Strings   ${5Grach_ed}    0
    log to console    VERIFY ATTACH success
    ################################## STEP3: START DATA TRANSFER ########################
    log to console    STEP3: START DATA TRANSFER
    power_ue.Start traffic     ue_type=${ue_type}   direction=dl
    ...        throughput=${throughput_dl}     duration=${duration_dl}    ue_index=${ue_index}
    ...        apn_address=${apn_address}      ue_mode=${ue_mode}         iperf_port=${iperf_port}
    power_ue.Start traffic     ue_type=${ue_type}   direction=ul
    ...        throughput=${throughput_ul}     duration=${duration_ul}    ue_index=${ue_index}
    ...        apn_address=${apn_address}      ue_mode=${ue_mode}         iperf_port=${iperf_port}
    sleep  60s
    log to console    START DATA TRANSFER success
    ################################## STEP4: CHECK THROUGHPUT ###########################
    log to console    STEP4: CHECK THROUGHPUT
    #Run Keyword If    "${ue_type}"=="huawei"     process.check_honor_throughput    ue_type=${ue_type}
    #...    ultarget_throughput=${check_throughput_honor_ul}    dltarget_throughput=${check_throughput_honor_dl}
    #...    cell_idx=${cell_idx}    target_avg_percent=${check_avg_percent}   min_percent=${min_percent}
    #...    ELSE    run keywords
    #...    power_ue.Check throughput    ue_type=${ue_type}      direction=dl      throughput=${check_throughput_dl}
    #...                          ue_index=${ue_index}    start_offset=${start_offset}
    #...    AND    power_ue.Check throughput    ue_type=${ue_type}      direction=ul      throughput=${check_throughput_ul}
    #...                          ue_index=${ue_index}    start_offset=${start_offset}
    process.check_Bi_throughput    ue_type=${ue_type}     ue_index=${ue_index}
    ...    ultarget_throughput=${check_throughput_ul}    dltarget_throughput=${check_throughput_dl}
    ...    cell_idx=${cell_idx}    target_avg_percent=${check_avg_percent}   min_percent=${min_percent}
    log to console    CHECK THROUGHPUT START DATA TRANSFER success

    run keyword if    "${Traffic_hold}"=="False"        run keywords
    ...   log to console           STEP5: STOP DATA TRANSFER
    ...   AND    UE.One_UE_Stop_traffic_and_Detach
    ...               ue_type=${ue_type}            ue_index=${ue_index}          ue_mode=${ue_mode}
    ...               apn_address=${apn_address}    iperf_port=${iperf_port}      power_reset=${power_reset}

process.check_Bi_throughput
    [Documentation]  check Bi throughput
    [Arguments]   ${ue_type}    ${ultarget_throughput}    ${dltarget_throughput}    ${ue_index}=${0}
    ...            ${target_avg_percent}=0.95  ${min_percent}=0.85  ${cell_idx}=1   ${actCarrierAggregation}=${False}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    ue_index=${ue_index}    duration=120
    COAM_WebEM.Login
    ${cell_info}=    selenium_coam.get_cell_info     cell_idx=${cell_idx}
    ${list_of_cell_ids}    Create list   ${cell_info['NR cell ID']}
    Power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}

process.check_Huawei_throughput
    [Documentation]  Huawei check Bi throughput
    [Arguments]   ${ue_type}    ${ultarget_throughput}    ${dltarget_throughput}   ${target_avg_percent}=0.95
    ...           ${min_percent}=0.85  ${cell_idx}=1   ${actCarrierAggregation}=${False}    ${ue_index}=${0}
    ...           ${ue_alias}=UE_${ue_index}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=120    ue_index=${ue_index}    ue_alias=${ue_alias}
    Power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${ue_alias}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}

UE.Spark_One_UE_attach
    [Arguments]   ${ue_type}=${UE_TYPE}   ${ue_index}=${0}     ${attach_mode}=5G_NSA
    [Documentation]  Main test Steps: power on ue, detach ue, attach ue and get returen value,
    ...              one step in keyword UE.One_UE_Call_with_traffic
    power_ue.UE Attach     ue_type=${ue_type}    ue_index=${ue_index}   power_reset=True    attach_mode=${attach_mode}
    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}   power_reset=Flase
    ${5Grach_ed}   power_ue.UE Attach
    ...                    ue_type=${ue_type}    ue_index=${ue_index}   power_reset=Flase   attach_mode=${attach_mode}
    [Return]    ${5Grach_ed}

UE.One_UE_Stop_traffic_and_Detach
    [Arguments]   ${ue_type}=${UE_TYPE}   ${ue_index}=${0}       ${ue_mode}=SA          ${apn_address}=wap1nokiacom
    ...           ${iperf_port}=default   ${power_reset}=true
    [Documentation]  Main test Steps:
    ...   1) STOP UL DATA TRANSFER
    ...   2) STOP DL DATA TRANSFER
    ...   3) UE Detach
    ...  :param  ue_type: The type of target UE, given in lowercase. only considered huawei/huawei_sigspark/askey_sigspark
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for call and traffic.
    ...  :param  power_reset: If do power_reset for spark attach.
    ...  :param  apn_address: APN for traffic use.
    ...  :param  iperf_port: port number used for traffic start via iperf.
    log to console           STOP DATA TRANSFER AND DETACH
    power_ue.Stop traffic    ue_type=${ue_type}            direction=dl                 ue_index=${ue_index}
    ...                      apn_address=${apn_address}    ue_mode=${ue_mode}           iperf_port=${iperf_port}
    power_ue.Stop traffic    ue_type=${ue_type}            direction=ul                 ue_index=${ue_index}
    ...                      apn_address=${apn_address}    ue_mode=${ue_mode}           iperf_port=${iperf_port}
    power_ue.UE Detach       ue_type=${ue_type}            power_reset=${power_reset}   ue_index=${ue_index}
    log to console           STOP DATA TRANSFER  AND DETACH SUCCESS

#PowerUE.ReserveUE
#    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
#    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${capatibility_index}=${0}
#    ...            ${reset_sol}=none    ${detach_request}=${true}
#    [Timeout]      10min
#    power_ue.Prepare UE   ue_type=${UE_TYPE}   ue_index=${ue_index}    ue_alias=${ue_alias}    capatibility_index=${capatibility_index}
#    ...            reset_sol=${reset_sol}   detach_request=${detach_request}
#PowerUE.AttachUE
#    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE.
#    ...    4G_check to be specified in case.
#    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${power_reset}=False
#    ...    ${ue_alias}=UE_${ue_index}   ${abil_index}=${1}    ${4G_check}=True    ${5Grach_ed}=${0}    ${5Gstatus}=PASS
#    power_ue.UE Attach    ue_type=${ue_type}   ue_index=${ue_index}  gnb_index=${gnb_index}  hwcheck_index=${hwcheck_index}
#    ...    ue_alias=${ue_alias}    abil_index=${abil_index}    power_reset=${power_reset}
#    run keyword if     '${4G_check}'=='True'    power_ue.Verify attach    ue_type=${ue_type}   ue_index=${ue_index}    gnb_index=${gnb_index}
#    ...    abil_index=${abil_index}   4G_check=${4G_check}   5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}
#PowerUE.DetachUE
#    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
#    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${power_reset}=False
#    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}    ue_alias=${ue_alias}    power_reset=${power_reset}
#PowerUE.StartDLTraffic
#    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
#    ...    dt_name to be specified in case.
#    [Arguments]    ${ue_type}=${UE_TYPE}     ${direction}=dl   ${throughput}=10MKbits/sec
#    ...            ${duration}=600   ${protocol}=udp    ${ue_index}=${0}
#    ...            ${cap_index}=${0}   ${dt_index}=${0}    ${iperf_port}=default
#    ...            ${interval}=1    ${buffer_size}=1024B    ${dt_name}=DT_1
#    ...            ${ue_alias}=UE_${ue_index}    ${multidrb_QoS_dest}=${None}
#    ...            ${apn_address}=wap1nokiacom    ${ue_mode}=SA
#    power_ue.Start traffic   ue_type=${ue_type}    direction=${direction}   throughput=${throughput}
#    ...            duration=${duration}   protocol=${protocol}    ue_index=${ue_index}
#    ...            cap_index=${cap_index}   dt_index=${dt_index}    iperf_port=${iperf_port}
#    ...            interval=${interval}    buffer_size=${buffer_size}    dt_name=${dt_name}
#    ...            ue_alias=${ue_alias}    multidrb_QoS_dest=${multidrb_QoS_dest}
#    ...            apn_address=${apn_address}    ue_mode=${ue_mode}
#PowerUE.StartULTraffic
#    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
#    ...    dt_name to be specified in case.
#    [Arguments]    ${ue_type}=${UE_TYPE}     ${direction}=ul   ${throughput}=3MKbits/sec
#    ...            ${duration}=600   ${protocol}=udp    ${ue_index}=${0}
#    ...            ${cap_index}=${0}   ${dt_index}=${0}    ${iperf_port}=default
#    ...            ${interval}=1    ${buffer_size}=1024B    ${dt_name}=DT_2
#    ...            ${ue_alias}=UE_${ue_index}    ${multidrb_QoS_dest}=${None}
#    ...            ${apn_address}=wap1nokiacom    ${ue_mode}=SA
#    power_ue.Start traffic   ue_type=${ue_type}    direction=${direction}   throughput=${throughput}
#    ...            duration=${duration}   protocol=${protocol}    ue_index=${ue_index}
#    ...            cap_index=${cap_index}   dt_index=${dt_index}    iperf_port=${iperf_port}
#    ...            interval=${interval}    buffer_size=${buffer_size}    dt_name=${dt_name}
#    ...            ue_alias=${ue_alias}    multidrb_QoS_dest=${multidrb_QoS_dest}
#    ...            apn_address=${apn_address}    ue_mode=${ue_mode}
#PowerUE.StopDLTraffic
#    [Arguments]    ${ue_type}=${UE_TYPE}    ${direction}=dl    ${ue_index}=${0}    ${dt_index}=${0}
#    ...            ${dt_name}=DT_1    ${ue_alias}=UE_${ue_index}    ${iperf_port}=default
#    ...            ${apn_address}=wap1nokiacom    ${ue_mode}=SA
#    power_ue.Stop traffic     ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}   dt_index=${dt_index}
#    ...            dt_name=${dt_name}    ue_alias=${ue_alias}   iperf_port=${iperf_port}
#    ...            apn_address=${apn_address}    ue_mode=${ue_mode}
#PowerUE.StopULTraffic
#    [Arguments]    ${ue_type}=${UE_TYPE}    ${direction}=ul    ${ue_index}=${0}    ${dt_index}=${0}
#    ...            ${dt_name}=DT_2    ${ue_alias}=UE_${ue_index}    ${iperf_port}=default
#    ...            ${apn_address}=wap1nokiacom    ${ue_mode}=SA
#    power_ue.Stop traffic     ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}   dt_index=${dt_index}
#    ...            dt_name=${dt_name}    ue_alias=${ue_alias}   iperf_port=${iperf_port}
#    ...            apn_address=${apn_address}    ue_mode=${ue_mode}
#PowerUE.CheckULThroughput
#    [Arguments]    ${ue_type}=${UE_TYPE}   ${direction}=ul    ${throughput}=1    ${deviation}=80
#    ...            ${ue_index}=${0}    ${dt_index}=${0}    ${ue_alias}=UE_${ue_index}    ${du_index}=${0}
#    ...            ${hw_slot}=${1}    ${sample}=${10}    ${start_offset}=${3}    ${sleep_time}=${5}    ${cellid}=${EMPTY}
#    power_ue.Check throughput     ue_type=${ue_type}   direction=${direction}   throughput=${throughput}    deviation=${deviation}
#    ...            ue_index=${ue_index}    dt_index=${dt_index}    ue_alias=${ue_alias}    du_index=${du_index}
#    ...            hw_slot=${hw_slot}    sample=${sample}    start_offset=${start_offset}    sleep_time=${sleep_time}   cellid=${cellid}
#PowerUE.CheckDLThroughput
#    [Arguments]    ${ue_type}=${UE_TYPE}   ${direction}=dl    ${throughput}=2    ${deviation}=80
#    ...            ${ue_index}=${0}    ${dt_index}=${0}    ${ue_alias}=UE_${ue_index}    ${du_index}=${0}
#    ...            ${hw_slot}=${1}    ${sample}=${10}    ${start_offset}=${3}    ${sleep_time}=${5}    ${cellid}=${EMPTY}
#    power_ue.Check throughput     ue_type=${ue_type}   direction=${direction}   throughput=${throughput}    deviation=${deviation}
#    ...            ue_index=${ue_index}    dt_index=${dt_index}    ue_alias=${ue_alias}    du_index=${du_index}
#    ...            hw_slot=${hw_slot}    sample=${sample}    start_offset=${start_offset}    sleep_time=${sleep_time}   cellid=${cellid}

#---------------------TM500/Cobham/Viavi Specific ------------------------------------------------------------------------------------
E500.PowerCycle
    [Arguments]    ${username}=test2    ${group}=test2    ${IP}=${E500_IP}    ${port}=${E500_ASC_PORT}
    ${asccon}  ${ascch}    E500ASCConnectAndInvokeShell    ${IP}    ${E500_ASC_USER}    ${E500_ASC_PW}    ${port}
    ${result}    E500ASCExecuteCommand   ${ascch}    username ${username}\n
    should contain    "${result}"    Ok
    sleep    5s
    ${result}    E500ASCExecuteCommand   ${ascch}    setpower off ${group}\n
    should contain    "${result}"    Ok
    sleep    5s
    ${result}    E500ASCExecuteCommand   ${ascch}    unlockgroup ${group}\n
    should contain    "${result}"    Ok
    sleep    5s
    ${result}    E500ASCExecuteCommand   ${ascch}    lockgroup ${group}\n
    should contain    "${result}"    Ok
    sleep    5s
    ${result}    E500ASCExecuteCommand   ${ascch}    setpower on ${group}\n
    should contain    "${result}"    Ok
    sleep    5s
    E500ASCDisconnect   ${asccon}
E500.StartAllWithSSH
    [Arguments]     ${tma_alias}=tma  ${alias}=${ALIAS_E500_APP}
    Log    ${AF_PATH}
    ${E500_PORT}=     RemoveZeroString   ${E500_PORT}
    Conn.ConnectWithTimeout  alias=${ALIAS_E500}
    ssh.send_command   "${E500_TMA_PATH}" /u "Default User" /p ${E500_PORT} /c y /a y    connection=${ALIAS_E500}
    sleep  60s
    ${TMAPPID}  Conn.Execute  cmd=ps -ef|grep TmaApplication|awk '{{print $2}}'|head -n 1  alias=${ALIAS_E500}
    e500.Connect to  ip=${E500_IP}  command_port=${E500_PORT}  alias=${alias}
    Conn.Disconnect    alias=${ALIAS_E500}
    sleep  10s
E500.ConnectCellSearchAndAttachWithRetry
    [Arguments]     ${username}    ${group}    ${retry_times}=3
    FOR    ${i}    IN RANGE    ${retry_times}
        ${res}=    Run Keyword And Ignore error    E500.ConnectCellSearchAndAttach
        Run keyword if    ${res} == ('PASS', None)    Exit For Loop
        ...   ELSE IF     ${res} != ('PASS', None)     Run Keywords    E500.ReInitForRetry    ${username}    ${group}
        ...   AND   Continue For Loop
    END
    Run keyword if    ${res} != ('PASS', None)     Fail   ConnectCellSearchAndAttach Failed with Retry
    Log    Power reset E500 ${i + 1} times.
E500.ReInitForRetry
    [Arguments]    ${username}    ${group}
    Run Keyword And Ignore error    E500.StopAllWithSSH
    E500.PowerCycle    ${username}    ${group}
    Sleep  120s
    E500.StartAllWithSSH
    Sleep  60s
E500.ConnectCellSearchAndAttach
    [Arguments]   ${alias}=${ALIAS_E500_APP}
    [Timeout]    5 minutes
    ${blow6GHz}=    Basic.CheckTag  tag=Blow6GHz
    ${MultiUE}=    Basic.CheckTag  tag=MultiUE
    ${3GPPDEC}=    Basic.CheckTag  tag=3GPPDEC
    log  ${blow6GHz}
    log  ${MultiUE}
    ${Prefix}=    Run Keyword If    '${blow6GHz}'=='false'
    ...    Set Variable if    '${MultiUE}'=='true'    _Above6G_MultiUE${UE_NUM}.txt    _Above6G.txt
    ...    ELSE
    ...    Set Variable if    '${MultiUE}'=='true'    _MultiUE${UE_NUM}.txt    .txt
    ${Prefix}=    Set Variable if    '${3GPPDEC}'=='true'   _Dec${Prefix}    ${Prefix}
    ${response}=  e500.send script  ${E500_SCRIPT_DIR}Init_Config${Prefix}  alias=${alias}
    Should Not Contain    ${response}    failure
    Should Not Contain    ${response}    Failure
    sleep   30s
    ${response}=  e500.send script  ${E500_SCRIPT_DIR}Cell_Search${Prefix}  alias=${alias}
    Should Not Contain    ${response}    failure
    Should Not Contain    ${response}    Failure
    sleep   10s
    ${response}=  e500.send script  ${E500_SCRIPT_DIR}UE_Attach${Prefix}  alias=${alias}
    Should Contain    ${response}    Random Access Complete
    sleep   5s
E500.Connect
    [Arguments]   ${alias}=${ALIAS_E500_APP}
    [Timeout]    5 minutes
    ${blow6GHz}=    Basic.CheckTag  tag=Blow6GHz
    ${MultiUE}=    Basic.CheckTag  tag=MultiUE
    ${3GPPDEC}=    Basic.CheckTag  tag=3GPPDEC
    log  ${blow6GHz}
    log  ${MultiUE}
    ${Prefix}=    Run Keyword If    '${blow6GHz}'=='false'
    ...    Set Variable if    '${MultiUE}'=='true'    _Above6G_MultiUE${UE_NUM}.txt    _Above6G.txt
    ...    ELSE
    ...    Set Variable if    '${MultiUE}'=='true'    _MultiUE${UE_NUM}.txt    .txt
    ${Prefix}=    Set Variable if    '${3GPPDEC}'=='true'   _Dec${Prefix}    ${Prefix}
    ${response}=  e500.send script  ${E500_SCRIPT_DIR}Init_Config${Prefix}  alias=${alias}
    Should Not Contain    ${response}    failure
    Should Not Contain    ${response}    Failure
    sleep   5s
E500.CellSearch
    [Arguments]   ${alias}=${ALIAS_E500_APP}
    [Timeout]    5 minutes
    ${blow6GHz}=    Basic.CheckTag  tag=Blow6GHz
    ${MultiUE}=    Basic.CheckTag  tag=MultiUE
    ${3GPPDEC}=    Basic.CheckTag  tag=3GPPDEC
    log  ${blow6GHz}
    log  ${MultiUE}
    ${Prefix}=    Run Keyword If    '${blow6GHz}'=='false'
    ...    Set Variable if    '${MultiUE}'=='true'    _Above6G_MultiUE${UE_NUM}.txt    _Above6G.txt
    ...    ELSE
    ...    Set Variable if    '${MultiUE}'=='true'    _MultiUE${UE_NUM}.txt    .txt
    ${Prefix}=    Set Variable if    '${3GPPDEC}'=='true'   _Dec${Prefix}    ${Prefix}
    ${response}=  e500.send script  ${E500_SCRIPT_DIR}Cell_Search${Prefix}  alias=${alias}
    Should Not Contain    ${response}    failure
    Should Not Contain    ${response}    Failure
    sleep   5s
E500.NSAAttach
    [Arguments]   ${alias}=${ALIAS_E500_APP}
    [Timeout]    5 minutes
    ${blow6GHz}=    Basic.CheckTag  tag=Blow6GHz
    ${MultiUE}=    Basic.CheckTag  tag=MultiUE
    ${3GPPDEC}=    Basic.CheckTag  tag=3GPPDEC
    log  ${blow6GHz}
    log  ${MultiUE}
    ${Prefix}=    Run Keyword If    '${blow6GHz}'=='false'
    ...    Set Variable if    '${MultiUE}'=='true'    _Above6G_MultiUE${UE_NUM}.txt    _Above6G.txt
    ...    ELSE
    ...    Set Variable if    '${MultiUE}'=='true'    _MultiUE${UE_NUM}.txt    .txt
    ${Prefix}=    Set Variable if    '${3GPPDEC}'=='true'   _Dec${Prefix}    ${Prefix}
    ${response}=  e500.send script  ${E500_SCRIPT_DIR}UE_Attach${Prefix}  alias=${alias}
    #Should Contain    ${response}    Random Access Complete
    FOR    ${index}    IN RANGE    10
        sleep    10
        ${response_t}=  e500.send script  ${E500_SCRIPT_DIR}CheckThroughput.txt  alias=${alias}
        ${response}=     Set Variable     ${response}${response_t}
        ${res}=    Run Keyword And Ignore error    Should Contain    ${response}    NR-RRCReconfigurationComplete
        Run Keyword If    ${res} == ('PASS', None)    Exit For Loop
    END
    Run keyword if    ${res} != ('PASS', None)    Fail    Attach Failed
    #Should Contain    ${response}    L2 Random Access Complete
    #Should Not Contain    ${response}    No PDCP entity found for radio bearer
E500.GetThroughput
    [Arguments]   ${alias}=${ALIAS_E500_APP}
    [Timeout]    5 minutes
    ${response}=  e500.send script  ${E500_SCRIPT_DIR}CheckThroughput.txt  alias=${alias}
    #Should Contain    ${response}    NR-RRCReconfigurationComplete
    Should Not Contain    ${response}    No PDCP entity found for radio bearer
    sleep   5s
E500.EvaluateThroughputDL
    [Arguments]   ${DLThroughput}=22  ${Percentage}=80  ${alias}=${ALIAS_E500_APP}
    [Timeout]    5 minutes
    ${response}=  e500.send script  ${E500_SCRIPT_DIR}CheckThroughput.txt  alias=${alias}
    Should Contain    ${response}    DL RB
    Should Not Contain    ${response}    No PDCP entity found for radio bearer
    run   rm ${LOG_PATH}/cobham.log
    run   echo '${response}' > ${LOG_PATH}/cobham.log
    ${DL}=  run  cat ${LOG_PATH}/cobham.log |grep -a -A 1 "DL RB" |grep Throughput|awk '{{print $4}}'|tail -n 1
    log  ${DL}
    ${DL}=   RemoveZeroString  ${DL}
    ${DLPercent}  Evaluate    ${DL}*${100}/${DLThroughput}
    Run Keyword And Ignore Error  record_throughput_to_file  ${TEST NAME}  ${TP_FILE}  ${DLPercent}  ${DL}
    Should be true  ${DLPercent}>${Percentage}
E500.Detach
    [Documentation]  Detach TM500. Allows to provide custom scripts for detach
    ...  and it this case user is responsible for setting proper variables
    ...  in script. If detach_script_path was not provided default value is used.
    [Arguments]   ${alias}=${ALIAS_E500_APP}
    ${MultiUE}=    Basic.CheckTag  tag=MultiUE
    ${Prefix}=    Set Variable if    '${MultiUE}'=='true'   _MultiUE${UE_NUM}.txt    .txt
    e500.send script  ${E500_SCRIPT_DIR}UE_Detach${Prefix}  alias=${alias}
E500.StopAllWithSSH
    [Arguments]     ${tma_alias}=tma  ${alias}=${ALIAS_E500_APP}
    sleep  5s
    Run Keyword And Ignore error    e500.disconnect  alias=${alias}
    Conn.ConnectWithTimeout  alias=${ALIAS_E500}
#    ${TMAPPID}  Conn.Execute  cmd=ps -ef|grep TmaApplication|awk '{{print $2}}'|head -n 1  alias=${ALIAS_E500}
#    Conn.Execute  cmd=kill -9 ${TMAPPID.strip()}  alias=${ALIAS_E500}
    ${TMAPPID}  Conn.Execute  cmd=ps -Wef|grep TmaApplication|awk '{{print $2}}'|head -n 1  alias=${ALIAS_E500}
    Conn.Execute  cmd=/bin/kill -f ${TMAPPID.strip()}  alias=${ALIAS_E500}
    Conn.Disconnect    alias=${ALIAS_E500}
E500.ModifyScript
    [Arguments]     ${gain}=-28
    ${blow6GHz}=    Basic.CheckTag  tag=Blow6GHz
    ${MultiUE}=    Basic.CheckTag  tag=MultiUE
    ${3GPPDEC}=    Basic.CheckTag  tag=3GPPDEC
    log  ${blow6GHz}
    log  ${MultiUE}
    ${Prefix}=    Run Keyword If    '${blow6GHz}'=='false'
    ...    Set Variable if    '${MultiUE}'=='true'    _Above6G_MultiUE${UE_NUM}.txt    _Above6G.txt
    ...    ELSE
    ...    Set Variable if    '${MultiUE}'=='true'    _MultiUE${UE_NUM}.txt    .txt
    ${Prefix}=    Set Variable if    '${3GPPDEC}'=='true'   _Dec${Prefix}    ${Prefix}
    Basic.SedReplaceLine
    ...   SETRFRXGAIN
    ...   FORW L1 SETRFRXGAIN 0 ${gain}
    ...   ${E500_SCRIPT_DIR}Cell_Search${Prefix}
    ...   NULL
    ...   false
    run  cat ${E500_SCRIPT_DIR}Cell_Search${Prefix}
Iperf.StopAll
    [Arguments]  ${dl_alias}=${ALIAS_UTE}    ${ul_alias}=${ALIAS_E500}
    Iperf.Connect   dl_alias=${dl_alias}    ul_alias=${ul_alias}
    ${DLPID}  Conn.Execute  cmd=ps -ef|grep iperf|awk '{{print $2}}'|head -n 1  alias=${dl_alias}
    Conn.Execute  cmd=kill -9 ${DLPID.strip()}  alias=${dl_alias}
    Conn.Execute  cmd=killall iperf  alias=${dl_alias}
    ${ULPID}  Conn.Execute  cmd=ps -ef|grep iperf|awk '{{print $2}}'|head -n 1  alias=${ul_alias}
    Conn.Execute  cmd=kill -9 ${ULPID.strip()}  alias=${ul_alias}
    Iperf.Disconnect    dl_alias=${dl_alias}    ul_alias=${ul_alias}
Iperf.Connect
    [Arguments]  ${dl_alias}=${ALIAS_UTE}    ${ul_alias}=${ALIAS_E500}
    Conn.ConnectWithTimeout  alias=${dl_alias}
    Conn.ConnectWithTimeout  alias=${ul_alias}
Iperf.Disconnect
    [Arguments]  ${dl_alias}=${ALIAS_UTE}    ${ul_alias}=${ALIAS_E500}
    Conn.Disconnect  alias=${dl_alias}
    Conn.Disconnect  alias=${ul_alias}
Iperf.StartULTrafficClientWithUnblockMode
    [Arguments]  ${UL_Throughput}=5M    ${iperf}=/home/tester/iperf    ${host}=192.168.10.71   ${alias}=${ALIAS_E500}
    FOR    ${port}    IN RANGE    5410    5410 + 2 * ${UE_NUM}    2
        Run Keyword And Ignore error    ssh.send_command
        ...  command=${iperf} -c ${host} -u -t 360000 -i 1 -p ${port} -P 1 -f m -b ${UL_Throughput} -l 1024B -T 64
        ...  connection=${alias}
    END

ViVi.Prepare UE
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0
    Run Keyword And Ignore error    ViVi.DialClose    dial_connection=${UECFG['${ue_index}']["dial_connection"]}    ue_index=${ue_index}
    Run Keyword And Ignore error    e500.disconnect  alias=${ALIAS_E500_APP}_${ue_index}
    Run Keyword And Ignore error    Conn.Disconnect    alias=${ALIAS_E500}_${ue_index}
    wait until keyword succeeds   5x   30s   Conn.ConnectToDev  IP=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    USERNAME=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    PASSWORD=${tl.ues[${ue_index}].ssh_connection_details.password}   alias=${ALIAS_E500}_${ue_index}
    ${TMAPPID}    Conn.Execute  cmd=ps -Wef|grep TmaApplication|awk '{{print $2}}'|xargs /bin/kill -f  alias=${ALIAS_E500}_${ue_index}
    #Run Keyword And Ignore error    Conn.Execute  cmd=/bin/kill -f ${TMAPPID.strip()}  alias=${ALIAS_E500}_${ue_index}
    ${TMAPPID}    Conn.Execute  cmd=ps -Wef|grep TmaApplication|awk '{{print $2}}'|head -n 1  alias=${ALIAS_E500}_${ue_index}
    Should be empty    ${TMAPPID.strip()}
    #Run Keyword And Ignore error    Conn.Disconnect    alias=${ALIAS_E500}_${ue_index}
#    ViVi.Power Cycle   vivi_ip=${UECFG['${ue_index}']['internal_ip']}
#    ...    power_cycle_script_path=${UECFG['${ue_index}']['power_cycle_script_path']}
#    ...    ue_index=${ue_index}
    Sleep  5s
    E500.PowerCycle     username=tm500     group=Units-1    IP=${tl.ues[${ue_index}].ssh_connection_details.addr}    port=10000
    Sleep  120s
#    Conn.ConnectToDev  IP=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...    USERNAME=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    PASSWORD=${tl.ues[${ue_index}].ssh_connection_details.password}   alias=${ALIAS_E500}_${ue_index}
    Conn.Execute  cmd="${UECFG['${ue_index}']['app_path']}" /u "Default User" /p ${UECFG['${ue_index}']['app_ta_port']} /c y /a y
    ...           alias=${ALIAS_E500}_${ue_index}
    sleep  60s
    #${TMAPPID}  Conn.Execute  cmd=ps -Wef|grep TmaApplication|awk '{{print $2}}'|head -n 1  alias=${ALIAS_E500}_${ue_index}
    #Should not be empty    ${TMAPPID.strip()}    msg=TMA app is not started
    e500.Connect to  ip=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    command_port=${UECFG['${ue_index}']['app_ta_port']}  alias=${ALIAS_E500_APP}_${ue_index}
    #Conn.Disconnect    alias=${ALIAS_E500}_${ue_index}
    sleep  10s

    ${response}=  e500.send script  filename=${TLDATA_PATH}/${UECFG['${ue_index}']['script_path']}/Connect.txt
    ...    alias=${ALIAS_E500_APP}_${ue_index}      timeout=5 minutes
    Should Not Contain    ${response}    failure
    Should Not Contain    ${response}    Failure
    sleep  10s

    ${response}=  e500.send script  filename=${TLDATA_PATH}/${UECFG['${ue_index}']['script_path']}/Initial.txt
    ...    alias=${ALIAS_E500_APP}_${ue_index}
    Should Not Contain    ${response}    failure
    Should Not Contain    ${response}    Failure
#    Should Contain    ${response}    FORW 0x00 Ok MTE ENABLETESTFEATURE: RETURN CODE:0 SUCCESSED
    sleep   10s

    ${response}=  e500.send script  ${TLDATA_PATH}/${UECFG['${ue_index}']['script_path']}/CellConfigure.txt
    ...    alias=${ALIAS_E500_APP}_${ue_index}
    Should Not Contain    ${response}    failure
    Should Not Contain    ${response}    Failure
    Should Contain    ${response}    FORW 0x00 Ok MTE ACTIVATE CNF: RETURN CODE:0
    sleep  10s

ViVi.UE Attach
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0
    ${response}=  e500.send script  filename=${TLDATA_PATH}/${UECFG['${ue_index}']['script_path']}/Attach_UE.txt
    ...    alias=${ALIAS_E500_APP}_${ue_index}
    sleep    15s
    Run Keyword And Ignore error    Should Not Contain    ${response}    failure
    Run Keyword And Ignore error    Should Not Contain    ${response}    Failure

    ${response}    ViVi.SendScript    script_path=${TLDATA_PATH}/${UECFG['${ue_index}']['script_path']}/GetInformation.txt
    Should Contain    ${response}    Random Access Complete

    ${ue_ip}    run   echo '${response}' | grep -a -A 1 "IPv4 Address"|awk '{{print $3}}'|head -n 1
    Should Contain    ${ue_ip}    .
    wait until keyword succeeds   5x   20s    ViVi.DialUp    UECFG=${UECFG}    ue_index=${ue_index}
    set suite variable    ${UE_IP_${ue_index}}     ${ue_ip}
    [Return]   ${ue_ip}

ViVi.DialUp
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0
    ${dial_connection}    set variable    ${UECFG['${ue_index}']["dial_connection"]}
    ${dial_username}      set variable    ${UECFG['${ue_index}']["dial_username"]}
    ${dial_password}      set variable    ${UECFG['${ue_index}']["dial_password"]}
    ${script_path}        set variable    ${TLDATA_PATH}/${UECFG['${ue_index}']['script_path']}
#    Conn.ConnectToDev  IP=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...    USERNAME=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    PASSWORD=${tl.ues[${ue_index}].ssh_connection_details.password}   alias=${ALIAS_E500}_${ue_index}
    ${output}    ssh.execute    command=rasdial "${dial_connection}" ${dial_username} ${dial_password}
    ...                         connection=${ALIAS_E500}_${ue_index}
    #ssh.disconnect    connection=${ALIAS_E500}_${ue_index}
    sleep    5s
    ${checkStr}    Catenate    SEPARATOR=${SPACE}    connected to    ${dial_connection}
    Should Contain    ${output}    ${checkStr}

    ${response}    ViVi.SendScript    script_path=${script_path}/GetInformation.txt
    Should Contain    ${response}    PPPOE CONNECTION

ViVi.Start traffic
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}   ${ue_index}=0   ${direction}=both   ${protocal}=UDP
    ...    ${iperf_port}=5001  ${options}=${EMPTY}
    Run Keyword If    '${direction}'=='dl' or '${direction}'=='both'   ViVi.Start DL traffic
    ...    UECFG=${UECFG}    ue_index=${ue_index}    protocal=${protocal}    iperf_port=${iperf_port}   options=${EMPTY}

    Run Keyword If    '${direction}'=='ul' or '${direction}'=='both'   ViVi.Start UL traffic
    ...    UECFG=${UECFG}    ue_index=${ue_index}    protocal=${protocal}    iperf_port=${iperf_port}   options=${EMPTY}

ViVi.Start UL traffic
    [Arguments]  ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0    ${protocal}=UDP    ${iperf_port}=5001    ${options}=${EMPTY}
#    Conn.ConnectToDev  IP=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...    USERNAME=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    PASSWORD=${tl.ues[${ue_index}].ssh_connection_details.password}   alias=${ALIAS_E500}_${ue_index}
    ${iperf_c_host}    set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ${tp}    set variable     ${UECFG['${ue_index}']['ul']['target_throughput']}
    ${dur}    set variable    ${UECFG['${ue_index}']['ul']['duration']}
    ${tcp_port}    Run Keyword If    '${protocal}'=='TCP'    Evaluate    ${iperf_port}+1
    ${appserver_ip}        Run Keyword If    '${protocal}'=='TCP'    set variable
    ...   ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ${appserver_username}    Run Keyword If    '${protocal}'=='TCP'    set variable
    ...   ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ${appserver_password}    Run Keyword If    '${protocal}'=='TCP'    set variable
    ...   ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    Run Keyword If    '${protocal}'=='UDP'   ssh.send_command
    ...    iperf -c ${iperf_c_host} -u -p ${iperf_port} -t ${dur} -b ${tp} -f m -i 1 -l 1024B -T 64 -P 1 ${options}
    ...    connection=${ALIAS_E500}_${ue_index}
    ...    ELSE    run keywords
    ...    ssh.send_command    iperf -s -p ${tcp_port} -i 1    connection=${ALIAS_E500}_${ue_index}
    ...    AND    sleep   5s
    ...    AND    ssh.Connect to    ${appserver_ip}    ${appserver_username}    ${appserver_password}    alias=appser_${ue_index}
    ...    AND    ssh.send_command    iperf -c ${UE_IP_${ue_index}} -p ${tcp_port} -t ${dur} -P 1 -w 400K -M 512 -R
    ...    connection=appser_${ue_index}
    sleep  15
    #Conn.Disconnect  alias=${ALIAS_E500}_${ue_index}
    Run Keyword If    '${protocal}'=='TCP'    ssh.disconnect    connection=appser_${ue_index}

ViVi.Start DL traffic
    [Arguments]  ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0    ${protocal}=UDP    ${iperf_port}=5001    ${options}=${EMPTY}
    ${iperf_s_host}        set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ${iperf_s_username}    set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ${iperf_s_password}    set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ${tp}    set variable     ${UECFG['${ue_index}']['dl']['target_throughput']}
    ${dur}    set variable    ${UECFG['${ue_index}']['dl']['duration']}
    ssh.Connect to    ${iperf_s_host}    ${iperf_s_username}    ${iperf_s_password}
    ...                alias=appserver_${ue_index}
    Run Keyword If    '${protocal}'=='UDP'    ssh.send_command
    ...    iperf -c ${UE_IP_${ue_index}} -u -p ${iperf_port} -t ${dur} -b ${tp} -f m -i 1 -l 1024B -T 64 -P 1 ${options}
    ...    connection=appserver_${ue_index}
    ...    ELSE    run keywords
    ...    ssh.send_command    iperf -s -p ${iperf_port} -i 1    connection=${ALIAS_E500}_${ue_index}
    ...    AND    sleep    5s
    ...    AND    ssh.send_command    iperf -c ${UE_IP_${ue_index}} -p ${iperf_port} -t ${dur} -P 1 -w 400K -M 1024
    ...    connection=appserver_${ue_index}
    ssh.disconnect    connection=appserver_${ue_index}

ViVi.Check throughput
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0   ${direction}=both
    sleep  15
    ${response}=  e500.send script  ${TLDATA_PATH}/${UECFG['${ue_index}']['script_path']}/CheckThroughput.txt
    ...    alias=${ALIAS_E500_APP}_${ue_index}
    Should Contain    ${response}    DL RB
    Should Contain    ${response}    UL RB
    Should Not Contain    ${response}    No PDCP entity found for radio bearer
    run   echo '${response}' > ${LOG_PATH}/cobham.log
    Run Keyword If    '${direction}'=='dl' or '${direction}'=='both'    Run Keyword
    ...    ViVi.Check DL throughput    DLThroughput=${UECFG['${ue_index}']['dl']['target_throughput']}
    ...    Percentage=${UECFG['${ue_index}']['target_avg_percent']}
    Run Keyword If    '${direction}'=='ul' or '${direction}'=='both'    Run Keyword
    ...    ViVi.Check UL throughput    ULThroughput=${UECFG['${ue_index}']['ul']['target_throughput']}
    ...    Percentage=${UECFG['${ue_index}']['target_avg_percent']}

ViVi.Check UL throughput
    [Arguments]   ${ULThroughput}=22    ${Percentage}=80
    ${UL}=  run  cat ${LOG_PATH}/cobham.log |grep -a -A 1 "UL RB" |grep Throughput|awk '{{print $4}}'|tail -n 1
    log  ${UL}
    ${UL}=   RemoveZeroString  ${UL}
    ${tp}    get regexp matches    ${ULThroughput}    [0-9]+
    ${ULPercent}  Evaluate    ${UL}/(${tp[0]}*${1024}*${1024})
    Should be true  ${ULPercent}>${Percentage}

ViVi.Check DL throughput
    [Arguments]   ${DLThroughput}=22    ${Percentage}=80
    ${DL}=  run  cat ${LOG_PATH}/cobham.log |grep -a -A 1 "DL RB" |grep Throughput|awk '{{print $4}}'|tail -n 1
    log  ${DL}
    ${DL}=   RemoveZeroString  ${DL}
    ${tp}    get regexp matches    ${DLThroughput}    [0-9]+
    ${DLPercent}  Evaluate    ${DL}/(${tp[0]}*${1024}*${1024})
    Should be true  ${DLPercent}>${Percentage}

ViVi.Stop traffic
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0   ${direction}=both    ${iperf_port}=5001    ${protocal}=UDP
    Run Keyword If    '${protocal}'=='TCP'    Run Keyword And Return
     ...    ViVi.Stop TCP traffic    UECFG=${UECFG}    ue_index=${ue_index}
     ...    direction=${direction}    iperf_port=${iperf_port}
#    Conn.ConnectToDev  IP=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...    USERNAME=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    PASSWORD=${tl.ues[${ue_index}].ssh_connection_details.password}   alias=${ALIAS_E500}_${ue_index}
    ${iperf_s_host}        set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ${iperf_s_username}    set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ${iperf_s_password}    set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ssh.Connect to    ${iperf_s_host}    ${iperf_s_username}    ${iperf_s_password}
    ...               alias=appserver_${ue_index}

    Run Keyword If    '${direction}'=='dl' or '${direction}'=='both'    run keyword and continue on failure
    ...    ssh.send_command    "ps aux | grep iperf | grep ${UE_IP_${ue_index}} | grep ${iperf_port} | awk '{print $2}' | xargs kill -9
    ...    connection=appserver_${ue_index}
    Run Keyword If    '${direction}'=='ul' or '${direction}'=='both'    run keyword and continue on failure
    ...    ssh.send_command    "ps auxW | grep iperf | grep ${iperf_s_host} | grep ${iperf_port} | awk '{print $2}' | xargs kill -9
    ...    connection=${ALIAS_E500}_${ue_index}
    #Conn.Disconnect  alias=${ALIAS_E500}_${ue_index}
    ssh.disconnect    connection=appserver_${ue_index}
ViVi.Stop TCP traffic
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0   ${direction}=both    ${iperf_port}=5001
    ssh.Connect to    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${tl.ues[${ue_index}].ssh_connection_details.password}   alias=${ALIAS_E500}_${ue_index}
    ${appserver_host}        set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ${appserver_username}    set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ${appserver_password}    set variable     ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ssh.Connect to    ${appserver_host}    ${appserver_username}    ${appserver_password}
    ...               alias=appserver_${ue_index}
    ${tcp_ul_port}    Evaluate    ${iperf_port}+1

    Run Keyword If    '${direction}'=='dl' or '${direction}'=='both'    run keywords
    ...    run keyword and continue on failure    ssh.send_command
    ...    "ps aux | grep iperf | grep ${UE_IP_${ue_index}} | grep ${iperf_port} | awk '{print $2}' | xargs kill -9
    ...    connection=appserver_${ue_index}
    ...    AND    run keyword and continue on failure    ssh.send_command
    ...    ps -auxW | grep iperf | grep ${iperf_port} | awk '{{print $2}}'| xargs kill -9
    ...    connection=${ALIAS_E500}_${ue_index}
    Run Keyword If    '${direction}'=='ul' or '${direction}'=='both'    run keywords
    ...    run keyword and continue on failure    ssh.send_command
    ...    "ps aux | grep iperf | grep ${UE_IP_${ue_index}} | grep ${tcp_ul_port} | awk '{print $2}' | xargs kill -9
    ...    connection=appserver_${ue_index}
    ...    AND    run keyword and continue on failure    ssh.send_command
    ...    "ps auxW | grep iperf | grep ${tcp_ul_port} | awk '{print $2}' | xargs kill -9
    ...    connection=${ALIAS_E500}_${ue_index}
    Conn.Disconnect  alias=${ALIAS_E500}_${ue_index}
    ssh.disconnect    connection=appserver_${ue_index}

ViVi.UE Detach
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0
    ${response}=   e500.send script  ${TLDATA_PATH}/${UECFG['${ue_index}']['script_path']}/Detach_UE.txt  alias=${ALIAS_E500_APP}_${ue_index}
    Should Not Contain    ${response}    failure
    Should Not Contain    ${response}    Failure

ViVi.DialClose
    [Arguments]    ${dial_connection}    ${ue_index}=0
#    Conn.ConnectToDev  IP=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...    USERNAME=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    PASSWORD=${tl.ues[${ue_index}].ssh_connection_details.password}
#    ...    alias=${ALIAS_E500}_${ue_index}
    ${output}    ssh.execute    command=rasdial "${dial_connection}" /DISCONNECT
    ...                         connection=${ALIAS_E500}_${ue_index}
    sleep    15s
    Should Contain    ${output}    Command completed successfully
    #ssh.disconnect    connection=${ALIAS_E500}_${ue_index}

ViVi.Disconnect
    [Arguments]    ${UECFG}=${TLCommonConfig["MultiUECFG"]}    ${ue_index}=0
    ${response}=   e500.send script  ${TLDATA_PATH}/${UECFG['${ue_index}']['script_path']}/Disconnect.txt
    ...    alias=${ALIAS_E500_APP}_${ue_index}
    Should Not Contain    ${response}    failure
    Should Not Contain    ${response}    Failure

    Run Keyword And Ignore error    ViVi.DialClose    dial_connection=${UECFG['${ue_index}']["dial_connection"]}    ue_index=${ue_index}
    Run Keyword And Ignore error    e500.disconnect  alias=${ALIAS_E500_APP}_${ue_index}
#    Run Keyword And Ignore error    Conn.ConnectToDev  IP=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...    USERNAME=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    PASSWORD=${tl.ues[${ue_index}].ssh_connection_details.password}   alias=${ALIAS_E500}_${ue_index}
    ${TMAPPID}    Conn.Execute  cmd=ps -Wef|grep TmaApplication|awk '{{print $2}}'|head -n 1  alias=${ALIAS_E500}_${ue_index}
    Run Keyword And Ignore error    Conn.Execute  cmd=/bin/kill -f ${TMAPPID.strip()}  alias=${ALIAS_E500}_${ue_index}
    Run Keyword And Ignore error    Conn.Disconnect    alias=${ALIAS_E500}_${ue_index}

ViVi.SendScript
    [Arguments]  ${script_path}    ${ue_index}=0
    ${response}=  e500.send script  filename=${script_path}  alias=${ALIAS_E500_APP}_${ue_index}
    [Return]  ${response}

ViVi.Power Cycle
    [Arguments]    ${vivi_ip}    ${power_cycle_script_path}    ${ue_index}=0
#    Conn.ConnectToDev  IP=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...    USERNAME=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    PASSWORD=${tl.ues[${ue_index}].ssh_connection_details.password}   alias=${ALIAS_E500}_${ue_index}
    ${output}   ssh.execute   command=python ${power_cycle_script_path} "${vivi_ip}"     connection=${ALIAS_E500}_${ue_index}
    ${res}    Should Not Contain    ${output}    execute failed
    #ssh.disconnect    connection=${ALIAS_E500}_${ue_index}

Conn.ConnectWithTimeout
    [Arguments]    ${alias}
    Wait Until Keyword Succeeds    10min    30sec    Conn.Connect   alias=${alias}
Conn.Connect
    [Arguments]    ${alias}
    Run Keyword If    '${alias}'=='${ALIAS_ASIK}'    ssh.Connect to    ${ASIK_IP}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    ...                alias=${ALIAS_ASIK}
    ...    ELSE IF    '${alias}'=='${ALIAS_ASIK_SLAVE}'  ssh.Connect to  ${FCT_IP}  ${ASIK_USERNAME}  ${ASIK_PASSWORD}
    ...                alias=${ALIAS_ASIK_SLAVE}  proxy=${ALIAS_ASIK}
    ...    ELSE IF    '${alias}'=='${ALIAS_UTE}'    ssh.Connect to    ${UTE_IP}    ${UTE_USERNAME}    ${UTE_PASSWORD}
    ...                alias=${ALIAS_UTE}
    ...    ELSE IF    '${alias}'=='${ALIAS_ENBCTLPC}'    ssh.Connect to  ${ENBCTLPC_IP}  ${ENBCTLPC_USERNAME}  ${ENBCTLPC_PASSWORD}
    ...                alias=${ALIAS_ENBCTLPC}
    ...    ELSE IF    '${alias}'=='${ALIAS_SHP}'    ssh.Connect to  ${SHP_IP}  ${ASIK_USERNAME}  ${ASIK_PASSWORD}
    ...                alias=${ALIAS_SHP}
    ...    ELSE IF    '${alias}'=='${ALIAS_E500}'    ssh.Connect to  ${E500_IP}  ${E500_USERNAME_DOMAIN}  ${E500_PASSWORD}
    ...                alias=${ALIAS_E500}
    ...    ELSE IF    '${alias}'=='${ALIAS_PRISMA}'    ssh.Connect to  ${PRISMA_IP}  ${PRISMA_USERNAME}  ${PRISMA_PASSWORD}
    ...                alias=${ALIAS_PRISMA}
    ...    ELSE IF    '${alias}'=='${ALIAS_QC}'    ssh.Connect to  ${QC_IP}  ${QC_USERNAME}  ${QC_PASSWORD}
    ...                alias=${ALIAS_QC}
    ...    ELSE    Fail    Unknow alias

Conn.ConnectDevWithTimeout
    [Arguments]    ${IP}   ${USERNAME}   ${PASSWORD}   ${alias}
    Wait Until Keyword Succeeds    1min    30sec    Conn.ConnectToDev
    ...   IP=${IP}   USERNAME=${USERNAME}   PASSWORD=${PASSWORD}
    ...   alias=${alias}

Conn.ConnectToDev
   [Arguments]     ${IP}   ${USERNAME}   ${PASSWORD}   ${alias}=AliasConn
   ssh.Connect to  hostname=${IP}    username=${USERNAME}    password=${PASSWORD}    alias=${alias}

Conn.ConnectToLoner
    [Arguments]    ${alias}=LONER
    ssh.Connect to  ${LONER_IP}  ${ASIK_USERNAME}  ${ASIK_PASSWORD}
    ...                alias=${alias}  proxy=${ALIAS_ASIK}
Conn.ConnectToAsp1a
    [Arguments]    ${alias}=ASP_1A
    ssh.Connect to  ${ASP_1A_IP}  ${ASIK_USERNAME}  ${ASIK_PASSWORD}
    ...                alias=${alias}  proxy=${ALIAS_ASIK}
Conn.ConnectToAMF
     [Arguments]    ${AMF_IP}   ${AMF_USERNAME}   ${AMF_PASSWORD}   ${alias}=${ALIAS_AMF}
     Wait Until Keyword Succeeds   3x    1min    ssh.Connect to
     ...    hostname=${AMF_IP}    username=${AMF_USERNAME}    password=${AMF_PASSWORD}    alias=${alias}
Conn.Execute
    [Arguments]     ${cmd}    ${alias}
    ${result}    ssh.execute    command=${cmd}    connection=${alias}
    [Return]    ${result}

Conn.ExecuteUnblock
    [Arguments]     ${cmd}    ${timeout}    ${alias}
    ${result}    ssh.send_command    command=${cmd}    timeout=${timeout}    connection=${alias}
    [Return]    ${result}
Conn.ReceiveReply
    [Arguments]    ${size}=10000    ${alias}=${ALIAS_ASIK}
    ${result}    ssh.read_output    size=${size}   connection=${alias}
    [Return]    ${result}

Conn.UploadFile
    [Arguments]     ${local_path}    ${remote_path}    ${alias}
    ${result}     ssh.upload_file    local_path=${local_path}    remote_path=${remote_path}    connection=${alias}
    [Return]    ${result}
Conn.DownloadFile
    [Arguments]     ${local_path}    ${remote_path}    ${alias}
    ${result}     ssh.download_file    remote_path=${remote_path}    local_path=${local_path}    connection=${alias}
    [Return]    ${result}
Conn.ExecuteLocal
    [Arguments]     ${cmd}
    ${result}    run    command=${cmd}
    [Return]    ${result}
Conn.ResetCache
    ssh.reset_cache
Conn.Disconnect
    [Arguments]    ${alias}
    ssh.disconnect    connection=${alias}
#---------------------Power Class TL Specify----------------------------------------------------------------
facom.PowerOnOff
    [Arguments]    ${pdu_ip}    ${Port_Number}    ${Action}=power_off    ${model}=FACOM
    taf.pdu.Setup Pdu    host=${pdu_ip}    model=${model}
    Run Keyword If    '${Action}'=='power_off'    taf.pdu.power_off    port=${Port_Number}
    ...    ELSE    taf.pdu.power_on    port=${Port_Number}
    sleep   15s
#    ${state}    taf.pdu.get_port_status    port=${Port_Number}
#    Run Keyword If    '${Action}'=='power_off'    should be equal    ${state}    off
#    ...    ELSE    should be equal    ${state}    on
Power.OnOff
    [Arguments]    ${pdu_ip}    ${Port_Number}    ${Action}=power_off    ${model}=FACOM
    taf.pdu.Setup Pdu    host=${pdu_ip}    model=${model}
    ${state}    taf.pdu.get_port_status    port=${Port_Number}
    Return From Keyword if   '${state}'=='off' and '${Action}'=='power_off'
    Return From Keyword if   '${state}'=='on' and '${Action}'=='power_on'
    Run Keyword If    '${Action}'=='power_off'    taf.pdu.power_off    port=${Port_Number}
    ...    ELSE    taf.pdu.power_on    port=${Port_Number}
Power.ResetgNB
    [Arguments]  ${pdu_ip}=${PB_ASIK_IP}    ${Port_Number}=${PB_ASIK_PORT}    ${model}=FACOM
    facom.PowerOnOff    pdu_ip=${pdu_ip}    Port_Number=${Port_Number}     Action=power_off   model=${model}
    facom.PowerOnOff    pdu_ip=${pdu_ip}    Port_Number=${Port_Number}     Action=power_on   model=${model}
Power.Reset5GRU
    [Arguments]   ${pdu_ip}=${PB_5GRU_IP}    ${Port_Number}=${PB_5GRU_PORT}    ${model}=FACOM
    facom.PowerOnOff    pdu_ip=${pdu_ip}    Port_Number=${Port_Number}     Action=power_off   model=${model}
    facom.PowerOnOff    pdu_ip=${pdu_ip}    Port_Number=${Port_Number}     Action=power_on   model=${model}
Power.ResetWMPeNB
    [Arguments]  ${model}=FACOM
    facom.PowerOnOff    pdu_ip=${PB_WMPeNB_IP}    Port_Number=${PB_WMPeNB_PORT}     Action=power_off   model=${model}
    facom.PowerOnOff    pdu_ip=${PB_WMPeNB_IP}    Port_Number=${PB_WMPeNB_PORT}     Action=power_on   model=${model}

SoftwareUpdate.DownloadPackageFromWFT
    [Arguments]    ${build_version}    ${wftlink}=false
    ${res}    run keyword and ignore error   SoftwareUpdate._DownloadPackageFromWFTInternal
    ...    build_version=${build_version}    wftlink=false
    return from keyword if   '${res[0]}'=='PASS'    ${res[1]}
    SoftwareUpdate._DownloadPackageFromWFTInternal
    ...    build_version=${build_version}    wftlink=true
    [Return]    ${res[1]}

SoftwareUpdate._DownloadPackageFromWFTInternal
    [Arguments]    ${build_version}    ${wftlink}=false
    ${StreamPrefix}    Basic.GetSBTSStreamPrefix    vstring=${build_version}
    ${wft_url}         Set Variable if    ${build_version.count('SBTS')}>0    ${link_to_Artifact_SBTS}    ${link_to_Artifact}
    ${wft_url}         Set Variable if  '${wftlink}'=='true' and ${build_version.count('SBTS')}>0  ${link_to_Artifact_SBTS_WFT}  ${wft_url}
    ${wft_url}         Set Variable if  '${wftlink}'=='true' and ${build_version.count('SBTS')}==0  ${link_to_Artifact_WFT}  ${wft_url}
    ${ago}             Set Variable if    ${build_version.count('SBTS')}>0    sha256    md5
    ${package_name}    Set Variable if    ${build_version.count('SBTS')}>0    ${build_version}_release_BTSSM_downloadable_A54.zip
    ...    AirScale-${build_version}.zip
    ${StreamFolder}    Set Variable if    ${build_version.count('SBTS')}>0    ${StreamPrefix}_packages/    ${EMPTY}
    ${StreamFolder}    Set Variable if    '${wftlink}'=='true' and ${build_version.count('SBTS')}>0    ${StreamPrefix}/    ${StreamFolder}
    ${result}=   run    rm -rf ${UPDATE_FILE_PATH}/${package_name}
    ${result}=   run    rm -rf ${UPDATE_FILE_PATH}/${package_name}.${ago}
    run keyword if    '${wftlink}'!='true'    run    wget ${wft_url}${StreamFolder}${build_version}/${package_name} -P ${UPDATE_FILE_PATH}
    run keyword if    '${wftlink}'=='true' and ${build_version.count('SBTS')}>0    run
    ...    wget ${wft_url}${StreamFolder}${package_name} -P ${UPDATE_FILE_PATH}
    run keyword if    '${wftlink}'=='true' and ${build_version.count('SBTS')}==0    run
    ...     wget ${wft_url}${StreamFolder}${build_version}/${package_name} -P ${UPDATE_FILE_PATH}
    run keyword if    '${wftlink}'!='true'    run    wget ${wft_url}${StreamFolder}${build_version}/${package_name}.${ago} -P ${UPDATE_FILE_PATH}
    ${ago_src}    run keyword if    '${wftlink}'!='true'    run     ${ago}sum ${UPDATE_FILE_PATH}/${package_name}
    ${ago_dec}    run keyword if    '${wftlink}'!='true'    run     cat ${UPDATE_FILE_PATH}/${package_name}.${ago}
    ${status}    run keyword if    '${wftlink}'!='true'    Run Keyword And Return Status    should contain    ${ago_src}    ${ago_dec}
    run keyword if    '${status}'=='False'    Fail    download from HGZ
    ${return_path}   Set Variable if    '${status}'=='False'     False    ${UPDATE_FILE_PATH}/${package_name}
    [Return]    ${return_path}

SoftwareUpdate.SoftwareUpdateFromWebUI
    [Arguments]    ${filepath}   ${check_reset}=true     ${check_onair}=false
    COAM_WebEM.SoftwareUpdate    filepath=${filepath}    check_reset=${check_reset}     check_onair=${check_onair}

#SoftwareUpdate.SoftwareUpdateByYAFT
#    [Arguments]    ${filepath}
#    log to console    YAFT Started
#    COAM_WebEM.TryEnableSSH
#    SoftwareUpdate.YAFT    filepath=${filepath}
#    ${version_Target}    COAM_Admin.GetSWVersion
#    FOR    ${i}    IN RANGE    ${20}
#        ${res}    wait until keyword succeeds    30min    60s    KW.CheckRUAlarmOrOnair
#        run keyword if     '${res}'=='YES'        KW.UpGradeForRU    filename=${filename}
#        ...    ELSE    Exit For Loop
#    END
##    gNB.Connect
##    gNB.CheckHWStatusUntilReady
##    gNB.Disconnect
##    COAM_Admin.commission    scf_file=${SCFFile}    bts_host=${5G_WEBUI_IP}
#    KW.TryEnableSSH

SoftwareUpdate.YAFT
    [Arguments]    ${filepath}=AS__*.zip    ${YAFT_PATH}=/opt/ute/YAFT
    log   ${filepath}
    run    command=rm -rf ${YAFT_PATH}/YAFT_IMAGE/*
    gNB.Connect
    ${BOARD}    gNB.GetSystemModuleName
    gNB.Disconnect
    ${yaft_command}    Set Variable If   '${BOARD}'=='ASIL'
    ...    cd ${YAFT_PATH} &&python ./yaft.py -i ${ASIK_IP} -z ${filepath} -K --ignore_FSPs
    ...    cd ${YAFT_PATH} &&python ./yaft.py -i ${ASIK_IP} -z ${filepath} -K --ignore_FSPs
    log  ${yaft_command}
    run  rm -rf ${YAFT_PATH}/YAFT_IMAGE
    ${result}  run  ${yaft_command}
    Should Contain Any   ${result}   Flashing done    Cannot establish SSH session with FCT    Waiting for FC* after reboot

SoftwareUpdate.SoftwareUpdate
    [Arguments]    ${stream_version}=0.835    ${oam_type}=${OAM_TYPE}
    # consider to take this statement out, so that ${enable} canbe used by softwareupdate, commisioning and swconfig
    ${version}=   run   cat ${CFGFILE_PATH}/force_version.txt
    ${status}=  Run Keyword And Return Status   Should Contain X Times     ${version}      .    2
    ${stream_version}   ${subversion}=   Run Keyword if   ${status}
    ...   Split String From Right    string=${version}   separator=.     max_split=1
    ...   ELSE    Set Variable   ${stream_version}    0
    ${enable}=   SoftwareUpdate.Check_AirScaleGNB_Version    stream_version=${stream_version}  oam_type=${oam_type}
    gNB.ReplaceSWconfigByRules
    Return From Keyword if   '${enable}'=='False'
    ${stream}   ${subversion}   Split String From Right    string=${build_version}   separator=.     max_split=1
#    Run Keyword if    '${stream}'=='4.1833'    SoftwareUpdate.SoftwareUpdate19Stream   ${stream}
#    Run Keyword if    '${stream}'=='5.1835'    SoftwareUpdate.SoftwareUpdate19Stream   ${stream}
#    Run Keyword if    '${stream}'=='0.835'     SoftwareUpdate.SoftwareUpdate19Stream   ${stream}
    Run Keyword if    '${stream}'=='4.8350'    SoftwareUpdate.SoftwareUpdate18ADStream
    ...    ELSE    SoftwareUpdate.SoftwareUpdate19Stream   stream_version=${stream}   oam_type=${oam_type}
SoftwareUpdate.SoftwareUpdate19Stream
    [Arguments]    ${stream_version}=5.1835    ${oam_type}=${OAM_TYPE}
    SoftwareUpdate.Download_AirScaleGNB
    ${enable}=  SoftwareUpdate.checkgNBcapacity
    Run Keyword if   ${enable}    SoftwareUpdate.cleangNBninja
    Run Keyword if   ${enable}    SoftwareUpdate.checkgNBcapacity
    ${filename}=    set variable    AirScale-${build_version}.zip
    SoftwareUpdate.UpdategNBViaOAM     filename=${filename}   oam_type=${oam_type}

SoftwareUpdate.SoftwareUpdate18ADStream
    SoftwareUpdate.Prepare18ADPackageWithDownload
    #*****WA for user prepared SDATA file.***
    SoftwareUpdate.PrepareSDATAFileForHDBDE
    #*****END WA*****************************
    ${result}=  SoftwareUpdate.CheckTargetVersionIsEqualWithTheOneOnASIK
    Run Keyword If    '${result}'=='false'    SoftwareUpdate.UpdategNBViaOAM
    SoftwareUpdate.UpdategNBViaOAM    stream=5G_
    SoftwareUpdate.UpdateHDBDE

SoftwareUpdate.Prepare18ADPackageWithDownload
    #[Arguments]    ${version}=None
    ${url}    Set Variable    https://hzisoj70.china.nsn-net.net/artifactory/DCM-18AD-package-local
    ${version}=   run   cat ${CFGFILE_PATH}/force_version.txt
    #${result}=   run    ls ${UPDATE_FILE_PATH}/5G18AD_${version}.tar
    #${result}=	 Remove String    ${result}    '
    #Return From Keyword if     '${result}'=='${UPDATE_FILE_PATH}/5G18AD_${version}.tar'
    run    command=rm -rf ${UPDATE_FILE_PATH}
    run    command=mkdir ${UPDATE_FILE_PATH}
    #run    cp /opt/ute/5G18AD/4.8350.422/5G18AD_4.8350.422.tar ${UPDATE_FILE_PATH}
    #run    cp /opt/ute/5G18AD/4.8350.422/5G18AD_4.8350.422_sdata_tools.zip ${UPDATE_FILE_PATH}
    run    wget ${URL}/${version}/5G18AD_${version}.tar -P ${UPDATE_FILE_PATH}
    run    wget ${URL}/${version}/5G18AD_${version}.tar.md5 -P ${UPDATE_FILE_PATH}
    run    wget ${URL}/${version}/5G18AD_${version}_sdata_tools.zip -P ${UPDATE_FILE_PATH}
    run    wget ${URL}/${version}/5G18AD_${version}_sdata_tools.zip.md5 -P ${UPDATE_FILE_PATH}
    ${md5_src}=    run     md5sum ${UPDATE_FILE_PATH}/5G18AD_${version}.tar
    ${md5_dec}=    run     cat ${UPDATE_FILE_PATH}/5G18AD_${version}.tar.md5
    should contain    ${md5_src}    ${md5_dec}
    ${md5_src}=    run     md5sum ${UPDATE_FILE_PATH}/5G18AD_${version}_sdata_tools.zip
    ${md5_dec}=    run     cat ${UPDATE_FILE_PATH}/5G18AD_${version}_sdata_tools.zip.md5
    should contain    ${md5_src}    ${md5_dec}
    run    command=tar xvf ${UPDATE_FILE_PATH}/5G18AD_${version}.tar -C ${UPDATE_FILE_PATH}
    run    command=cd ${UPDATE_FILE_PATH}&&unzip ${UPDATE_FILE_PATH}/5G18AD_${version}_sdata_tools.zip
    run    command=cd ${UPDATE_FILE_PATH}&&unzip sdata_tool_4g.zip
    run    command=mv ${UPDATE_FILE_PATH}/LRC_PSN_MW/* ${UPDATE_FILE_PATH}
    ${gNBSoftwareFile}=  run  ls ${UPDATE_FILE_PATH}/AS__*.zip
    Should Not Be Empty   ${gNBSoftwareFile}
    log   ${gNBSoftwareFile}
    run    command=rm -rf ${UPDATE_FILE_PATH}/bts_sw/
    run   command=cd ${UPDATE_FILE_PATH} && unzip ${gNBSoftwareFile}
SoftwareUpdate.CheckTargetVersionIsEqualWithTheOneOnASIK
    [Arguments]    ${alias}=${ALIAS_ASIK}
    ${TargetVersion}=  run  cd ${UPDATE_FILE_PATH}/bts_sw/ && ls TargetBD_5G*.xml
    Conn.ConnectWithTimeout  alias=${alias}
    ${SourceVersion}=  Conn.Execute  cmd=cd /ffs/run/ && ls TargetBD_5G*.xml  alias=${alias}
    log    ${SourceVersion}
    Conn.Disconnect  alias=${alias}
    ${result}=  Set Variable if  '${TargetVersion.strip()}'=='${SourceVersion.strip()}'    true    false
    [Return]    ${result}
SoftwareUpdate.Check_AirScaleGNB_Version
    [Arguments]    ${stream_version}=5.1835    ${oam_type}=${OAM_TYPE}
    run   python -m com.interface.wft query-package --stream_version=${stream_version} --output=version.txt
    ${version}=  run    cat version.txt
    log many     QT recommend version from wft:   ${version}
    ${wft status}=  Run Keyword And Return Status   Should Match Regexp     ${version}      ${stream_version}
    Run Keyword if   ${wft status}     Set Global Variable     ${build_version}    ${version}
    ${force version}=   run   cat ${CFGFILE_PATH}/force_version.txt
    log many     Force install version from env:   ${force version}
    ${force status}=  Run Keyword And Return Status   Should Match Regexp     ${force version}      ${stream_version}
    Run Keyword if   ${force status}     Set Global Variable     ${build_version}    ${force version}
    ${status}=  Run Keyword And Return Status   Should Match Regexp     ${force version}      .000
    Run Keyword if   ${status} and ${wft status}      Set Global Variable     ${build_version}    ${version}
    log many     Final install version from env:   ${build_version}
#    ${current_version}=    run keyword if   '${oam_type}'=='megazone'    WEBUI.GetActiveVersion
#    ...    ELSE   COAM_Admin.GetSWVersion
    ${current_version}=    gNB.CheckgNBVersion
    ${enable status}=  Run Keyword And Return Status   Should not be Equal   ${current_version}  ${build_version}
    ${status}=  Run Keyword And Return Status   Should Match Regexp     ${build_version}      .000
    ${enable status}=  Set Variable if    ${status}      False      ${enable status}
    ${enable status}=  Set Variable if    ${wft status}==False and ${force status}==False     False      ${enable status}
    log many     Need update or not:   ${enable status}
    run keyword if    ${enable status}==False    run    echo ${current_version}>${FileToRecordCurrentVersion}
    [Return]    ${enable status}

SoftwareUpdate.Download_AirScaleGNB
    ${result}=   run    ls ${UPDATE_FILE_PATH}/AirScale-${build_version}.zip
    ${result}=	 Remove String    ${result}    '
    Run Keyword If     '${result}'=='${UPDATE_FILE_PATH}/AirScale-${build_version}.zip'
    ...    Run Keywords    run    command=rm -rf ${UPDATE_FILE_PATH}/bts_sw/    AND
    ...    run    command=cd ${UPDATE_FILE_PATH} && unzip AirScale-${build_version}.zip
    Return From Keyword if     '${result}'=='${UPDATE_FILE_PATH}/AirScale-${build_version}.zip'
    run    wget ${link_to_Artifact}${build_version}/AirScale-${build_version}.zip -P ${UPDATE_FILE_PATH}
    run    wget ${link_to_Artifact}${build_version}/AirScale-${build_version}.zip.md5 -P ${UPDATE_FILE_PATH}
    ${md5_src}=    run     md5sum ${UPDATE_FILE_PATH}/AirScale-${build_version}.zip
    ${md5_dec}=    run     cat ${UPDATE_FILE_PATH}/AirScale-${build_version}.zip.md5
    should contain    ${md5_src}    ${md5_dec}
    run    command=rm -rf ${UPDATE_FILE_PATH}/bts_sw/
    run    command=cd ${UPDATE_FILE_PATH} && unzip AirScale-${build_version}.zip
    run    command=chmod -R 777 ${UPDATE_FILE_PATH}/bts_sw/

SoftwareUpdate.UpdategNBViaOAM
    [Arguments]    ${filename}=AS__*.zip    ${oam_type}=${OAM_TYPE}
    [Timeout]    120 minutes
    ${gNBSoftwareFile}=  run  ls ${UPDATE_FILE_PATH}/${filename}
    Should Not Be Empty   ${gNBSoftwareFile}
    log   ${gNBSoftwareFile}
    run keyword if   '${oam_type}'=='megazone'    WEBUI.UpdateSW   file_path=${gNBSoftwareFile}  stream=5G
    ...    ELSE    run keywords    COAM_Admin.Login
    ...    AND    COAM_Admin.UpdateSW   file_path=${gNBSoftwareFile}
#    ...    AND    COAM_Admin.ResetSite  timeout=20min
    ...    AND    COAM_Admin.Logout
    WA.ReplaceOamIPToLmpIP
    Conn.ResetCache
    ${result}=  SoftwareUpdate.CheckTargetVersionIsEqualWithTheOneOnASIK
    Run Keyword If    '${result}'=='false'    Fail    Update SW failed
    ...   ELSE    Run Keywords    Log    Update SW successful
    ...   AND    run    echo ${build_version}>${FileToRecordCurrentVersion}

SoftwareUpdate.CheckgNBUpdateStatus
    [Arguments]    ${info}=Signing files
    ${res}=  selenium_megazone.check software update progress
    Should Contain     ${res}    ${info}
SoftwareUpdate.checkgNBcapacity
    wait until keyword succeeds     15min    1min   ssh.Connect to
    ...			${ASIK_IP}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}   alias=asik
    ${Passive File}=  ssh.execute  command=ls -al /ffs/stb | awk '{print $11}'  connection=asik
    ${Passive File}=  Strip String  ${Passive File}  mode=right
    ${Passive Avail}=  ssh.execute  command=df -BM ${Passive File}|awk '{print $4}' | tail -1   connection=asik
    ${Passive Avail}=  Remove String  ${Passive Avail}   M
    ${Packet File}=  run  ls -al --block-size=M ${UPDATE_FILE_PATH}/AirScale-${build_version}.zip|awk '{print $5}'
    ${Packet File}=    Remove String  ${Packet File}   M
    ${Passive Size}=  Convert To Integer  ${Passive Avail}
    ${Packet Size}=  Convert To Integer  ${Packet File}
    #Should be True   ${Passive Size} > ${Packet Size}
    Run Keyword if   ${Passive Size} < ${Packet Size}       Run keywords
    ...  Log  Note:${Passive File} space is not enough(Packet size:${Packet Size}M Stb space:${Passive Size}M)!!!  level=WARN   AND
    ...  Return From Keyword    True
    [return]   False
SoftwareUpdate.cleangNBninja
    wait until keyword succeeds     15min    1min   ssh.Connect to
    ...     ${ASIK_IP}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}   alias=asik
    ssh.execute  command=rm -rf /ffs/run/logs/*     connection=asik
    ssh.execute  command=cd /ffs/run/config/toor4nsn/wa;ls|grep -v '.sh'|grep -v '.py'|xargs rm -rf    connection=asik
    ${Passive File}=  ssh.execute  command=ls -al /ffs/stb | awk '{print $11}'  connection=asik
    ${Passive File}=  Strip String  ${Passive File}  mode=right
    ssh.execute   command=mount -o rw,remount ${Passive File}   connection=asik
    #${status}=  Run Keyword And Return Status     Should Exist    ${Passive File}/config/toor4nsn/wa
    ${result}=   ssh.execute   command=ls -d ${Passive File}/config/toor4nsn/wa   connection=asik
    ${result}=   Remove String    ${result}    '
    ${result}=   Strip String  ${result}  mode=right
    Run Keyword If     '${result}'=='${Passive File}/config/toor4nsn/wa'    ssh.execute
    ...  command=cd ${Passive File}/config/toor4nsn/wa;ls|grep -v '.sh'|grep -v '.py'|xargs rm -rf   connection=asik
SoftwareUpdate.PrepareSDATAFileForHDBDE
    run    command=cd ${UPDATE_FILE_PATH}&& rm SDATA*.SEP && rm SDATA_HD*_3G*.SAP
    run    command=cp ${CFGFILE_PATH}/SDATA* ${UPDATE_FILE_PATH}
SoftwareUpdate.UpdateHDBDE
    [Arguments]    ${filepath}=${UPDATE_FILE_PATH}
    Conn.ConnectWithTimeout  alias=${ALIAS_SHP}
#check file exist
     FOR    ${file}    IN    @{sdm_a_list}
        ${thefile}=    Run    command=cd ${filepath}/&& ls|grep ${file}
        Should Not Be Empty   ${thefile}
     END

     FOR    ${file}    IN    @{sdm_n_list}
        ${thefile}=    Run    command=cd ${filepath}/&& ls|grep ${file}
        Should Not Be Empty   ${thefile}
     END

     FOR    ${file}    IN    @{vendor_conf}
        ${thefile}=    Run    command=cd ${filepath}/&& ls|grep ${file}
        Should Not Be Empty   ${thefile}
     END

#put files into sdm_a
     FOR    ${file}    IN    @{sdm_a_list}
        Conn.Execute    cmd=rm /pns/sdm_a/${file}    alias=${ALIAS_SHP}
        ${thefile}=    Run    command=cd ${filepath}&& ls|grep ${file}
        Conn.UploadFile    local_path=${filepath}/${thefile}    remote_path=/pns/sdm_a/${thefile}    alias=${ALIAS_SHP}
     END
#put files into sdm_n
     FOR    ${file}    IN    @{sdm_n_list}
        Conn.Execute    cmd=rm /pns/sdm_n/${file}    alias=${ALIAS_SHP}
        ${thefile}=    Run    command=cd ${filepath}&& ls|grep ${file}
        Conn.UploadFile    local_path=${filepath}/${thefile}    remote_path=/pns/sdm_n/${thefile}    alias=${ALIAS_SHP}
     END
#put files into vendorFM_conf
     FOR    ${file}    IN    @{vendor_conf}
        Conn.Execute    cmd=rm /pns/vendorFM/conf/${file}    alias=${ALIAS_SHP}
        ${thefile}=    Run    command=cd ${filepath}&& ls|grep ${file}
        Conn.UploadFile  local_path=${filepath}/${thefile}  remote_path=/pns/vendorFM/conf/${thefile}  alias=${ALIAS_SHP}
     END
#sync in SHP
    ssh.execute    command=sync&&sync&&sync    connection=${ALIAS_SHP}
    Conn.Disconnect  alias=${ALIAS_SHP}

#-------------------Wireshark---------------------------------------------------------------------------------
Wireshark.StartCaptureLog
    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${connection}
    ssh.send command    tcpdump -s 0 -n -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &    connection=${connection}

Wireshark.StopCapturinglog
    [Arguments]    ${listen_port}=fp0   ${connection}=${ALIAS_ASIK}
#    ${resp}    ssh.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0    connection=${connection}
#    ${connection}      set variable if     ${resp.count("ASIB")} > 0     ${ALIAS_ASIK}    ${ALIAS_ASIK_SLAVE}
    ssh.execute    command=ps -ef|grep -i tcpdump     connection=${connection}
    ssh.send command    command=ps -ef|grep tcpdump|grep -v grep|grep ${listen_port}|awk '{print $2}'|xargs kill -2    connection=${connection}
    sleep   2s
    ssh.execute    command=ps -ef|grep -i tcpdump     connection=${connection}

Wireshark.StartCaptureNGLog
    [Arguments]   ${filename}    ${log_dir}=/tmp
    ${connection}    gNB.GetSystemModuleType    alias=${ALIAS_ASIK}
    ${ethport}    gNB.GetBackhaulName
    #${ethport}   Set variable if     '${connection}'=='${ALIAS_ASIK_SLAVE}'    fp0    br1
    Wireshark.StartCaptureLog    listen_port=${ethport}    log_dir=${log_dir}    filename=${filename}    connection=${ALIAS_ASIK}

Wireshark.StopCaptureNGLog
    ${connection}    gNB.GetSystemModuleType    alias=${ALIAS_ASIK}
    #${ethport}   Set variable if     '${connection}'=='${ALIAS_ASIK_SLAVE}'    fp0    br1
    ${ethport}    gNB.GetBackhaulName
    ssh.execute    command=ps -ef|grep -i tcpdump     connection=${connection}
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep ${ethport}|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
    sleep    2s
    ssh.execute        command=ps -ef|grep -i tcpdump     connection=${ALIAS_ASIK}

Wireshark.StartCaptureBIPLog
    [Arguments]    ${filename}    ${log_dir}=/tmp
    ssh.send command    bsh 1:2 fpga_rw wa 0xDF1D039C 0x1003000A    connection=${ALIAS_ASIK}
    ssh.send command    dbgrrc mirror sport 25 dport 2 enable both    connection=${ALIAS_ASIK}
    Wireshark.StartCaptureLog    listen_port=etha01    log_dir=${log_dir}     filename=${filename}    connection=${ALIAS_ASIK}
    ssh.execute        command=ps -ef|grep -i tcpdump     connection=${ALIAS_ASIK}

Wireshark.StartCaptureLogFromContainer
    [Arguments]   ${filename}    ${container}=0xe004    ${listen_port}=any     ${log_dir}=/tmp
    ...    ${connection}=${ALIAS_ASIK}    ${nodename}=${None}
    ${conn}    gNB.GetSystemModuleType    alias=${ALIAS_ASIK}
    run keyword if    '${conn}'=='asik_slave'    Conn.ConnectWithTimeout    alias=${ALIAS_ASIK_SLAVE}
    ${containerid}    ${node_cmd}     run keyword if     "${nodename}"!="${None}"    gnb.get_container_id    nodename=${nodename}
    ${container}      set variable if     "${containerid}"!="${None}"    ${containerid}    ${container}
    ssh.send command
    ...    command=bsh ${node_cmd} lxc-attach -n ${container} -- tcpdump -n -i ${listen_port} sctp -w ${log_dir}/${filename} &>/dev/null &
    ...       connection=${conn}

Wireshark.StopCapturinglogFromContainer
    [Arguments]    ${container}=0xe004    ${connection}=${ALIAS_ASIK}    ${nodename}=${None}
    ${conn}    gNB.GetSystemModuleType    alias=${ALIAS_ASIK}
    run keyword if    '${conn}'=='asik_slave'    Conn.ConnectWithTimeout    alias=${ALIAS_ASIK_SLAVE}
    ${containerid}    ${node_cmd}    run keyword if     "${nodename}"!="${None}"    gnb.get_container_id    nodename=${nodename}
    ${container}      set variable if     "${containerid}"!="${None}"    ${containerid}    ${container}
    ${pid}  ssh.execute   command=bsh ${node_cmd} lxc-attach -n ${container} -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'
    ...     connection=${conn}
    ${pid}    Fetch From Right    ${pid}   invalid format\r\r\n
    ${pid}    Fetch From Left     ${pid}   \r\n
    log to console    ${pid}
    ssh.execute   command=bsh ${node_cmd} lxc-attach -n ${container} -- kill -2 ${pid.replace('\r\n','')}   connection=${conn}
    sleep   2s
    ssh.execute    command=bsh ${node_cmd} lxc-attach -n ${container} -- ps -ef|grep -i tcpdump|grep -v grep    connection=${conn}

wireshark.DownloadLogToUTEFromContainer
    [Arguments]    ${filename}    ${nodename}    ${localpath}=${LOG_PATH}    ${gnbip}=${ASIK_IP}
    DP.setup    gnbip=${gnbip}
    DP.download_file_from_container     filename=${filename}    nodename=${nodename}    localpath=${localpath}
    [Return]    ${localpath}/${filename}

Wireshark.DownloadLogToUTE
    [Arguments]    ${filename}   ${log_dir}=/tmp    ${connection}=${ALIAS_ASIK}    ${localname}=${filename}
    [Timeout]    5min
    ssh.download_file   local_path=${LOG_PATH}/${localname}    remote_path=${log_dir}/${filename}   connection=${connection}
    sleep    20s
    ssh.execute    rm -f ${log_dir}/${filename}    connection=${connection}
    [Return]    ${LOG_PATH}/${localname}

Wirshark.DowloadLuaScript
    [Documentation]   Download the SW-version specific luascript if not exsit, and retun the path of the script.
    [Arguments]    ${output_dir}=/home/ute
    ${stream_version}    ${build_version}    Basic.GetStreamAndVersion
    ${stream}=    Fetch from left    ${stream_version}   _
    ${LUA_PATH}  set variable   ${output_dir}/${build_version}/generated_luashark/luashark.lua
    set test variable    ${LUA_PATH}
    ${script_presence}    Run Keyword And Return Status   File Should Exist   ${LUA_PATH}
    Return From Keyword If      ${script_presence}
    ${luashark_url}   set variable   ${link_to_Artifact_SBTS_WFT}${stream}/${build_version}_luashark.zip
    run    command=wget -P ${output_dir} ${luashark_url}
    run    command=unzip -d ${output_dir}/${build_version} ${output_dir}/${build_version}_luashark.zip
    [Return]    ${LUA_PATH}

Wirshark.DowloadAndInstallMCshark
    [Documentation]   Remove existing MCshark, download the SW-version specific MCshark, and retun the path of it
    [Arguments]    ${wirshark_plugin_dir}=/usr/lib/x86_64-linux-gnu/wireshark/plugins/3.4/epan
    ${stream_version}    ${build_version}    Basic.GetStreamAndVersion
    ${stream}=    Fetch from left    ${stream_version}   _
    Wireshark.clear_mcshark
#   ${link_to_Artifact_MCshark}/${build_version}/mcshark-3.4-1.10.0-SBTS00_ENB_9999_211101_000014+buster.so
    ${mcshark_name}   html.get_download_link_by_ext    url=${link_to_Artifact_MCshark}/${build_version}   ext=so
    ${mcshark_download_link}=    set variable   ${link_to_Artifact_MCshark}/${build_version}/${mcshark_name}[0]
    run    command=sudo wget -P ${wirshark_plugin_dir} ${mcshark_download_link}
    ${MCSHARK_PATH}    set variable    ${wirshark_plugin_dir}/${mcshark_name}
    set test variable    ${MCSHARK_PATH}
    [Return]    ${MCSHARK_PATH}

Wireshark.clear_mcshark
    [Documentation]  Remove the existing mcsharks. as there can't be more than one mcshark if mcshark has to be used, and it
    ...  has to be removed if luascript is used.
    [Arguments]    ${wirshark_plugin_dir}=/usr/lib/x86_64-linux-gnu/wireshark/plugins/3.4/epan
    @{files} =	List Files In Directory    path=${wirshark_plugin_dir}    pattern=mcshark*
    ${count}=    Get Length    ${files}
    run keyword if  ${count}>=${1}   run    command=sudo rm -f mcshark*

Wireshark.CreatePersonalConfProfile
    [Documentation]  Create personal configuraetion profile for special pcap analysing.
    ...    :param pref_items  a list hoding all preference items to use other than the defaults. Make sure each item is written exactly
    ...    the same as what dislay in GUI of wireshark.
    ...    :Param profie_path  the path of profile folders where preference file locates.
    ...    :Param profile_name  the personal profile name, which is presented as a foler in profie_path.
    ...    :Param filename   it can be preference or decode_as_entries
    [Arguments]    ${pref_items}   ${profie_path}=/home/ute/.config/wireshark/profiles
    ...    ${profile_name}=customized_profile   ${filename}=preference
    text.write_lines_to_file    file_path=${profie_path}/${profile_name}   file_name=${filename}    lines=${pref_items}
    [Return]  ${profile_name}

Wireshark.ReadLog
    [Documentation]  Read pcapfie, convert it to pdml file, then read and return all entries of the pdml file.
    ...    Warning: Luashark and mcshark can't be used simuteneously.
    ...    :param filter  display filter to be passed to -Y of tshark.
    ...    :Param luashark_path:  optional, only needed for BIP analysing.
    ...    :Param profile_name:  for DCI items, mcshark is required.
    ...    :param override_preference_setting:  override preference setting.
    ...     e.g {" esp.enable_null_encryption_decode_heuristic": true, "esp.enable_encryption_decode": true}
    ...    :type override_preference_setting: dictionary
    ...    :param disable_all_name_resolutions: disable all name resolutions (default: True).
    ...    :type disable_all_name_resolutions: bool
    ...    :param flush_standard_output: flush standard output after each packet (default: True).
    ...    :type flush_standard_output: bool
    ...    :param tshark_path: specified tshark path.
    ...    :type tshark_path: str
    ...    :param alias: pcap parser alias name.
    ...    :type alias: str
    ...    :return: pcap_parser instance.
    ...    :rtype: PcapParse

    [Arguments]    ${filename}    ${filepath}=${LOG_PATH}   ${filter}=${None}   ${luashark_path}=${None}   ${profile_name}=${None}
    ...    ${override_preference_setting}=${None}    ${disable_all_name_resolutions}=${None}
    ...    ${flush_standard_output}=${None}    ${tshark_path}=${None}    ${alias}=PcapParser0

    run keyword if    '${luashark_path}'!='${None}'    run keywords    Wireshark.clear_mcshark
    ${extension}   run keyword if    '${luashark_path}'!='${None}'    set variable     lua_script:${luashark_path}

    pcap.setup    infile=${filepath}/${filename}    display_filter=${filter}
    ...    extension=${extension}    override_preference_setting=${override_preference_setting}
    ...    disable_all_name_resolutions=${disable_all_name_resolutions}
    ...    flush_standard_output=${flush_standard_output    tshark_path=${tshark_path}    alias=${alias}


Wireshark.CheckExpression
    [Documentation]  Get filtered packet instances.
    ...    :param expression: Wireshark filter expression.
    ...    :type expression: str
    ...    :param pcap_parser: pcap parser alias name.
    ...    :type pcap_parser: str
    ...    :return: packets list
    ...    :rtype: list
    [Arguments]    ${expression}    ${pcap_parser}=PcapParser0    ${present}=true
    ${Res}    pcap.get_packets    filter=${expression}    pcap_parser=${pcap_parser}
    run keyword if    '${present}'=='true'    Should not be empty    ${Res}
    ...    ELSE     Should be empty    ${Res}


Wireshark.GetElementValue
    [Documentation]  Get specified field's values from filtered packets.
    ...    :param check_param: Wireshark field expression.
    ...    :type check_param: str
    ...    :param fmt: return value format, default is "show" e.g "show", "value" and "showname".
    ...    :type fmt: str
    ...    :param condition_expression: Wireshark filter expression.
    ...    :type condition_expression: str
    ...    :param pcap_parser: pcap parser alias name.
    ...    :type pcap_parser: str
    ...    :return: field value list of filtered packets.
    ...        e.g if field "PCMD_5G.pcap" has 3 fields in one packet, the return list will be like under:
    ...        [['111', '248', '203'],  # 2 field values belong to a packet
    ...        ['111', '207', '214'],
    ...         ['10', '9', '18'],
    ...         ['111', '207', '5'],
    ...         ['10', '9', '207'],
    ...         ['10', '9', '18']]
    ...    :rtype: list
    ...    :params element_idx and default_value are not used anymore, only kept for backward compatiblity.
    [Arguments]    ${check_param}   ${element_idx}=${0}    ${default_value}=${True}    ${condition_expression}=${None}
    ...    ${fmt}=show    ${pcap_parser}=PcapParser0
    ${values}=      pcap.get_field_value      field_name=${check_param}    fmt=${fmt}
    ...    filter=${condition_expression}     pcap_parser=${pcap_parser}
    [Return]    ${values}

Wireshark.GetElementValueAndCompareWithDesiredValue
    [Arguments]    ${check_param}    ${compare_value}   ${element_idx}=${0}    ${default_value}=${True}    ${condition_expression}=${None}
    ...    ${fmt}=${None}    ${pcap_parser}=PcapParser0
    ${values}=     run keyword if   '${fmt}'=='${None}'   Wireshark.GetAllTypesOfElementValues   check_param=${check_param}
    ...    condition_expression=${condition_expression}        pcap_parser=${pcap_parser}
    ...    ELSE    pcap.get_field_value    field_name=${check_param}    fmt=${fmt}
    ...    filter=${condition_expression}     pcap_parser=${pcap_parser}

    ${value_prefix}    Get Substring    ${compare_value}    0    2
    ${value_remainder}   Get Substring    ${compare_value}    2
    ${field_value}    run keyword if   "${value_prefix}"=="0x"    set variable    ${value_remainder}
    ...    ELSE    set variable    ${compare_value}

     FOR    ${item}    IN    @{values}
         ${res}    run keyword and return status    List Should Contain Value    ${item}   ${field_value}
         Exit For Loop If    ${res}
     END
    should be true    ${res}

Wireshark.GetAllTypesOfElementValues
    [Arguments]    ${check_param}     ${condition_expression}=${None}    ${pcap_parser}=PcapParser0
    ${show_values}=      pcap.get_field_value      field_name=${check_param}    fmt=show
    ...    filter=${condition_expression}     pcap_parser=${pcap_parser}
    ${showname_values}=      pcap.get_field_value      field_name=${check_param}    fmt=showname
    ...    filter=${condition_expression}     pcap_parser=${pcap_parser}
    ${hex_values}=      pcap.get_field_value      field_name=${check_param}    fmt=value
    ...    filter=${condition_expression}     pcap_parser=${pcap_parser}
    ${all_values}    combine lists    ${show_values}    ${showname_values}    ${hex_values}
    [Return]    ${all_values}

#-------------------Test Suit Funciton----------------------------------------------------------------------------------
Basic.GetStreamAndVersion
    [Arguments]    ${vstring}=${AF_PATH}
    ${version}    run keyword if    ${vstring.count('SBTS')}>${0}    get regexp matches    ${vstring}    SBTS[0-9A-Z]+_[0-9A-Z]+_[0-9]+_[0-9]+_[0-9]+
    ...    ELSE    get regexp matches    ${vstring}     [0-9]+.[0-9]+.[0-9]+
    ${stream}    run keyword if    ${vstring.count('SBTS')}>${0}    get regexp matches    ${vstring}    SBTS[0-9A-Z]+_[0-9A-Z]+_[0-9]+
    ...    ELSE    get regexp matches    ${vstring}     [0-9]+.[0-9]+
    [Return]    ${stream[0]}    ${version[0]}

Basic.GetSBTSStreamPrefix
    [Arguments]    ${vstring}=${AF_PATH}
    ${stream_prefix}    run keyword if    ${vstring.count('SBTS')}>${0}    get regexp matches    ${vstring}    SBTS[0-9A-Z]+
    ...    ELSE    get regexp matches    ${vstring}     [0-9]+.[0-9]+
    [Return]    ${stream_prefix[0]}

Basic.AdjustBTSVersion
    [Arguments]   ${sw_version}    ${stream}=SBTS00_ENB_9999
    return from keyword if     ${sw_version.count('SBTS')}<=${0}    ${sw_version}
    Run Keyword If   "${sw_version}"=="" or "${sw_version}"=="-"   Fail   Please Enter Correct Parameter!
    @{list}   Split String From Right   string=${sw_version}   separator=_     max_split=3
    ${version}    Set Variable if    ${sw_version.count('SBTS')}>${0}   ${stream}_${list[-2]}_${list[-1]}    ${sw_version}
    [Return]   ${version}

Basic.GetStreamInfo
    [Arguments]    ${vstring}=${AF_PATH}    ${StreamInfoName}=STREAM_INFO
    #Basic.CheckVariableValid      var=${StreamInfoName}    default_value=${STREAM_INFOs}
    ${key}    run keyword if    ${vstring.count('SBTS')}>${0}    get regexp matches    ${vstring}    SBTS[0-9A-Z]+_[0-9A-Z]+_[0-9]+
    ...    ELSE    get regexp matches    ${vstring}     [0-9]+.[0-9]+
#    ${key}          get regexp matches    ${vstring}     [0-9]+.[0-9]+
    ${res}    run keyword and ignore error   log to console    ${${StreamInfoName}}
    return from keyword if   '${res[0]}'=='FAIL'   None
    ${res}   run keyword and ignore error    Get From Dictionary    ${${StreamInfoName}}    ${key[0]}
    return from keyword if   '${res[0]}'=='FAIL'   None
    [Return]    ${res[1]}

Basic.CheckTag
    [Arguments]    ${tag}
    ${result}=    Set Variable If    '${tag}' in ${TEST TAGS}    true    false
    [Return]    ${result}

Basic.CheckVariable
    [Arguments]    ${variable_name}   ${variable_list}
    ${result}=    set variable if     '${variable_name}' in ${variable_list}   true    false
    [Return]    ${result}

Basic.CheckVariableValid
    [Arguments]    ${var}    ${default_value}    ${is_digit}=False
    ${res}    run keyword and ignore error   log    ${${var}}
    Run Keyword If   '${res[0]}'=='FAIL'   set suite variable    ${${var}}    ${default_value}
    ${NewValue}    Run Keyword If   '${is_digit}'=='True'    Evaluate  ${${var}}+0
    Run Keyword If   '${is_digit}'=='True'    set suite variable    ${${var}}    ${NewValue}

Basic.CheckContainString
    [Arguments]    ${substring}   ${string}
    ${value}    Run Keyword And Ignore error    Should Contain    ${string}    ${substring}
    ${result}    set variable If   '${value[0]}'=='PASS'   true     false
    [Return]    ${result}

Basic.SedReplaceLine
    [Arguments]    ${matchValue}=NOKIA    ${newValue}=NOKIA    ${file}=NULL    ${alias}=NULL    ${force}=false
    ${cmd}    Set Variable if   '${force}'=='true'
    ...    grep -q ${matchValue} ${file} && sed -i 's/^.*${matchValue}.*$/${newValue}/g' ${file} ||echo ${newValue} >> ${file}
    ...    sed -i 's/^.*${matchValue}.*$/${newValue}/g' ${file}
    Run Keyword If    '${alias}'!='NULL'    Conn.Execute  cmd=${cmd}    alias=${alias}
    ...    ELSE    Conn.ExecuteLocal  cmd=${cmd}

Basic.SedReplaceString
    [Arguments]    ${matchValue}=NOKIA    ${newValue}=NOKIA    ${file}=NULL    ${alias}=NULL    ${force}=false
    ${cmd}    Set Variable if   '${force}'=='true'
    ...    grep -q ${matchValue} ${file} && sed -i 's/${matchValue}/${newValue}/g' ${file} ||echo ${newValue} >> ${file}
    ...    sed -i 's/${matchValue}/${newValue}/g' ${file}
    Run Keyword If    '${alias}'!='NULL'    Conn.Execute  cmd=${cmd}    alias=${alias}
    ...    ELSE    Conn.ExecuteLocal  cmd=${cmd}

Basic.CheckFilePresent
    [Arguments]     ${path}    ${keyword}   ${fullname}=false    ${alias}=NULL
    ${cmd}    set variable if    '${fullname}'=='true'    ls ${path} |grep ^${keyword}$     ls ${path} |grep ${keyword}
    ${result}    run keyword if    '${alias}'!='NULL'    Conn.Execute    cmd=${cmd}    alias=${alias}
    ...    ELSE    Conn.ExecuteLocal    cmd=${cmd}
    ${filename}    set variable if     ${result.count('${keyword}')}>${0}    ${result.replace('\r\n',' ')}    NotPresent
    #log to console    ${filename}
    [Return]    ${filename}

Basic.CheckFilePresentAndRemove
    [Arguments]     ${path}    ${keyword}    ${alias}=NULL
    ${filename}   Basic.CheckFilePresent    path=${path}    keyword=${keyword}    alias=${alias}
    Conn.Execute   cmd=cd ${path} && rm -rf ${filename}    alias=${alias}
    [Return]    ${filename}

Basic.ThroughExceptionWithMsg
    [Arguments]     ${msg}
    Fail    ${msg}

Timer.Start
    ${current_time}        Get Current Date
    ${current_time}        convert date    ${current_time}    epoch
    set suite variable     ${timer_temp_timestart}    ${current_time}

Timer.Stop
    ${current_time}         Get Current Date
    ${current_time}         convert date    ${current_time}     epoch
    ${duration}             Evaluate    ${current_time}-${timer_temp_timestart}
    [Return]       ${duration}

Config.GetValue
    [Arguments]    ${file}   ${section}   ${option}
    ${value}    GetConfigIni   ${file}   ${section}   ${option}
    [Return]    ${value}
TestSuite.Start
    TestSuilt.Start
TestSuite.Stop
    TestSuilt.Stop
TestSuilt.Start
    Log to Console   TestSuiltStart
    Create Log Directories
    run    rm ${LOG_PATH}/* -rf
    run keyword and ignore error    UTECloud.AdaptCommissionFiles
    GNB.FormatBTSID

    ${L3CallLogConf}=  Catenate     SEPARATOR=${SPACE}
    ...                   {"snapshot":{"enabled":"false"},
    ...                    "lmilog":{"enabled":"false","lmiconfig":""},
    ...                    "btslog":{"enabled":"false"},
    ...                    "wireshark":{"enabled":"false","type":["none"]},
    ...                    "dcap":{"enabled":"false","host":"dcap","port":"100","type":["none"]},
    ...                    "rulog":{"enabled":"false","mode":"","position":"","ruIndex":"","ruUsr":"","ruPwd":""}
    ...                   }
    ${L3CallLogConf}    Evaluate        json.loads('''${L3CallLogConf}''')                   json
    Set Suite Variable    ${L3CallLogConf}

    ${keyword_logInit}     Create Dictionary  btslog=BtsLogInit    wireshark=WiresharkLogInit
    ...                                       dcap=DcapLogInit     snapshot=SnapshotInit
    ...                                       rulog=RuLogInit      lmilog=LMIlogInit
    set suite variable    ${keyword_logInit}
    ${keyword_logCollect}  Create Dictionary  btslog=BtsLogCollect    wireshark=WiresharkLogCollect
    ...                                       dcap=DcapLogCollect     snapshot=SnapshotCollect
    ...                                       rulog=RuLogCollect      lmilog=LMIlogCollect
    set suite variable    ${keyword_logCollect}

#    Log.Init    snapshot=true
    #run keyword and ignore error    Import Variables       ${CFGFILE_PATH}TLDelta.py
    #run keyword and ignore error    Import Variables       ${CFGFILE_PATH}TLSCFDelta.py
    run keyword and ignore error    gNB.ReplaceDeltaID     DeltaPath=${CFGFILE_PATH}TLDelta.py
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    run keyword and ignore error    gNB.ReplaceDeltaID     DeltaPath=${CFGFILE_PATH}TLSCFDelta.py
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    run keyword and ignore error    gNB.ReplaceDeltaID     DeltaPath=${CFGFILE_PATH}TLConfiguration.py
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
    run keyword and ignore error    gNB.ReplaceDeltaID     DeltaPath=${TLDATA_PATH}TLConfiguration.py
    ...                    MRBTSID=${MRBTSID}
    ...                    NRBTSID=${NRBTSID}
TestSuilt.Stop
    Log to Console   TestSuiltStop
TestCase.Start
    CI_interface.Common Case Setup
TestCase.Stop
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

TestCase.CommonStart
    [Documentation]    start with capture log
    TestCase.Start
    Run Keyword And Ignore Error    BtsLog.StartBTSlogCollection
    log to console     Case Start

TestCase.CommonStop
    [Documentation]    1.stop with stop log
    ...                2.kill processes
    gNB.Connect
    Run Keyword And Ignore Error     ssh.execute   command=killall -2 tcpdump   connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error     ssh.execute   command=killall -2 tcpdump   connection=${ALIAS_ASIK_SLAVE}
    Run Keyword And Ignore Error     run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error     BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore error     selenium_coam.disable_virtual_display
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver
    Conn.ResetCache
    TestCase.Stop

TestSuite.CommonSuiteStart
    [Documentation]    1.set log level
    ...                2.generate TL scf
    TestSuite.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    gNB.SetLoggingSeverity    LoggingSeverity=debug
#    gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${DIST_NAME}   ${MRBTS_ID}/${NRBTS_ID}
#    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_PATH}/${Golden_SCF}    TLDelta_PATH=${TLDelta_PATH}
#    ...            TestLineSCF_cell_num=1   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
#    ${StreamInfo}    convert to string    ${info}
#    ${TL_S1_base_SCF}    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${Golden_SCF}    TLDelta_PATH=${CFGFILE_PATH}
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ...    ELSE    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}
#    ...            TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
     gNB.GenerateTestLineSCFs
    [Return]     ${LOG_PATH}/TestLineSCF1Cell.xml

TestSuite.CommonSuiteStop
    TestSuite.Stop

TestSuilt.UseUserLogPath
    ${tm}    Get Current Date
    ${tm}=	 Remove String    ${tm.replace(' ','-')}    .  :
    set global variable    ${LOG_PATH}    ${USER_LOG_DIR}/${tm}
    Create Directory    ${LOG_PATH}

BtsLog.StartBTSlogCollection
    [Documentation]    collect syslogs from ute VM.
    run keyword and ignore error    run    command=rm /tmp/btslog2/* -rf
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

BtsLog.StopBTSlogCollectionandGetlog
    core.teardown_collectors      names=btslog
    ${time}    Get Time    epoch
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    #run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${filename}_SYSLOG_${time}.tgz SYSLOG_*.LOG
    run    command=cp /tmp/${filename}_SYSLOG_${time}.tgz ${LOG_PATH}/.
    [Return]    ${LOG_PATH}/${filename}_SYSLOG_${time}.tgz

PA.Adjust ${RU} Attenuation to ${value}
    ${value}    RemoveZeroString     ${value}
    PA.AdjustTheAttenuationValue    ports=${5G${RU}_ANT1}    value=${value}
    PA.AdjustTheAttenuationValue    ports=${5G${RU}_ANT2}    value=${value}

PA.AdjustTheAttenuationValue
    [Arguments]    ${ports}    ${value}    ${attenuator}=${PA_INFO}
    ${value}    Evaluate    ${value}+0
    PA_.setup_attenuator    attenuator=${attenuator}
    PA_.set_attenuation     port=${ports}    value=${value}
    PA_.read_attenuation    port=${ports}

PA.AdjustAttenuationValueByGroup
    [Documentation]    set value to a PA group. if ${value} not defined, default_value will be used.
    [Arguments]    ${PAGroup}=${TLCommonConfig['PAGroups']['1']}   ${value}=NULL    ${attenuator}=${PA_INFO}
    PA.setup_attenuator    attenuator=${PA_INFO}
    ${newValue}    run keyword if    '${value}'!='NULL'    Evaluate    ${value}+0
    FOR    ${port}   IN    @{PAGroup['ports']}
        ${defaultValue}    Evaluate    ${port['default_value']}+0
        ${newvalue}    set variable if    '${value}'=='NULL'    ${defaultValue}    ${newValue}
        log    set PA port ${port['port_id']} to ${newvalue}
        PA_.set_attenuation     port=${port['port_id']}    value=${newValue}
        PA_.read_attenuation    port=${port['port_id']}
    END

PA.AdjustAttenuationValueByGroups
    [Documentation]    set value to all PA groups. if ${value} not defined, default_value will be used.
    [Arguments]    ${PAGroups}=${TLCommonConfig['PAGroups']}   ${value}=NULL    ${attenuator}=${PA_INFO}
    ${PAGroupList}     Get Dictionary Keys    dictionary=${PAGroups}
    FOR    ${key}   IN    @{PAGroupList}
        PA.AdjustAttenuationValueByGroup    PAGroup=${PAGroups['${key}']}    value=${value}    attenuator=${attenuator}
    END

AMF.ClearUEInfoFromAMF
   [Arguments]    ${ue_imsi}=${IMSI1}    ${hostname}=${5GC_IP}     ${username}=${5GC_USERNAME}     ${password}=${5GC_PASSWORD}
   ssh.connect to    hostname=${hostname}   username=${username}    password=${password}    alias=ALIAS_5GC
   ${imsi_presence}=    ssh.execute   command=cmm subscriber show --imsi ${ue_imsi} 2> /dev/null| head -n 7 | grep GENERALINFO
   ...    connection=ALIAS_5GC
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    ssh.execute   command=cmm subscriber delete --imsi ${ue_imsi}    connection=ALIAS_5GC
   ssh.disconnect    connection=ALIAS_5GC
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    sleep   60    # WA, make IMSI clear opeation is done completely.
eNB.Commission
    [Arguments]    ${file_path}=enb.xml    ${bts_host}=${ENB_WEBUI_IP}    ${username}=${WEBUI_USERNAME}    ${password}=${WEBUI_PASSWORD}
    ...    ${timeout}=${600}
    #ENB_Admin.Commission    scf_file=${file_path}    bts_host=${bts_host}    username=${username}    password=${password}
    #sleep    3min
    wait until keyword succeeds    3x    1min    eNB_COAM.Login   bts_host=${bts_host}    username=${username}
    ...    password=${password}    alias=ENB
    coam.perform_commissioning    scf_file=${file_path}    skip_parameter_relation_errors=True    should_activate=${true}    timeout=${timeout}
    ...    connection=ENB
    eNB_COAM.Logout

eNB_COAM.Login
    [Arguments]    ${bts_host}=${ENB_WEBUI_IP}    ${username}=${WEBUI_USERNAME}    ${password}=${WEBUI_PASSWORD}    ${bts_port}=${443}
    ...    ${log_dir}=${OUTPUT_DIR}    ${alias}=ENB
    coam.connect_to    bts_host=${bts_host}    bts_port=${bts_port}    username=${username}    password=${password}    use_ssl=${True}
    ...    update_interval=${5000}    admin_api_log_dir=${log_dir}    name=${alias}

eNB_COAM.Logout
    [Arguments]    ${connection}=ENB
    coam.teardown    connection=${connection}

UTECloud.AdaptCommissionFiles
    #${SCF_PATH}     Get Substring  ${CURDIR}  0  -57
    return from keyword if    '${testline_name}'!='null'
    run keyword and ignore error     set suite variable     ${AF_PATH}    ${ENB_BUILD}
    ${SCF_PATH}    Fetch From Left    ${CURDIR}   testsuite
    log to console     ${SCF_PATH}
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_${TLNAME}[0]
    set suite variable    ${testlinename}    ${testlinename}
    set suite variable    ${CFGFILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/
    set suite variable    ${GoldenScf_PATH}    ${SCF_PATH}/commissionings/HGZ/GoldenSCF/
    set suite variable    ${TLDATA_PATH}      ${SCF_PATH}/testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testlinename}/

    run keyword and ignore error     CI_interface.Common Suite Setup

UTECloud.ForceAdaptCommissionFiles
    #${SCF_PATH}     Get Substring  ${CURDIR}  0  -57
    #return from keyword if    '${testline_name}'!='null'
    ${SCF_PATH}    Fetch From Left    ${CURDIR}   testsuite
    log to console     ${SCF_PATH}
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_${TLNAME}[0]
    set suite variable    ${testlinename}    ${testlinename}
    set suite variable    ${CFGFILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/
    set suite variable    ${GoldenScf_PATH}    ${SCF_PATH}/commissionings/HGZ/GoldenSCF/
    set suite variable    ${TLDATA_PATH}      ${SCF_PATH}/testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testlinename}/
    #Import Variables      ${CFGFILE_PATH}TLConfiguration.py


UTECloud.AdaptCommissionFilesToCiInterface
    return from keyword if    '${testline_name}'!='null'
    set suite variable    ${cell_type}    ${CASE_INPUT_5GC002273['5GC002273']['cell_type']}
    set suite variable    ${testline}    ${CASE_INPUT_5GC002273['5GC002273']['testline']}
    set suite variable    ${stream}    ${CASE_INPUT_5GC002273['5GC002273']['stream']}
    run   cp ${LOG_PATH}/TestLineSCF1Cell_${cell_type}.xml ${scf_relative_dir}/${testline}/SCF_${stream}.xml

Android.SwitchApn
    [Arguments]    ${host}=${Control_PC_hostname}    ${username}=${Control_PC_username}    ${password}=${Control_PC_password}
    ...    ${ui_version}=${ui_version}    ${serial_number}=NULL    ${apn_name}=wap1
    run keyword if    '${serial_number}'=='NULL'
    ...    android_mobile.setup    ui_version=${ui_version}    host=${Control_PC_hostname}    username=${Control_PC_username}
    ...                            password=${Control_PC_password}    port=22   alias=${UE_alias}
    ...    ELSE    android_mobile.setup
    ...               ui_version=${ui_version}    host=${Control_PC_hostname}    username=${Control_PC_username}
    ...               password=${Control_PC_password}    port=22     serial_number=${serial_number}    alias=${UE_alias}
    android_mobile.switch_apn       apn_name=${apn_name}   mobile=${UE_alias}
    android_mobile.teardown       mobile=${UE_alias}

AMTU.Connect
    [Arguments]    ${host}=${Control_PC_hostname}    ${username}=${Control_PC_username}    ${password}=${Control_PC_password}
    Conn.ConnectToDev  IP=${host}   USERNAME=${username}    PASSWORD=${password}    alias=AMTU_PC

AMTU.SetCellInfo
    [Documentation]    CellIdx [0 means all cell, 1 2 3 4 means cell index , offset = true mean increace base on current value
    [Arguments]    ${CellIdx}=0    ${Value}=60    ${offset}=false
    ...    ${path}=/cygdrive/c/'Program Files (x86)'/Spark/Bin
    ${output}  Conn.Execute    cmd=${path}/AMTUConsole.exe SetCell ${CellIdx} ${Value} ${offset}    alias=AMTU_PC
    ${output}    Remove String    ${output}    \x1b[6n
    ${output}    Evaluate        json.loads('''${output}''')                   json
    [Return]   ${output}

AMTU.SetToDefault
    [Documentation]    CellIdx [0 means all cell, 1 2 3 4 means cell index
    [Arguments]    ${CellIdx}=0    ${path}=/cygdrive/c/'Program Files (x86)'/Spark/Bin
    ${output}  Conn.Execute    cmd=${path}/AMTUConsole.exe SetToDefault ${CellIdx}    alias=AMTU_PC
    ${output}    Remove String    ${output}    \x1b[6n
    ${output}    Evaluate        json.loads('''${output}''')                   json
    [Return]   ${output}

AMTU.SetDeviation
    [Documentation]    CellIdx [0 means all cell, 1 2 3 4 means cell index
    [Arguments]    ${CellIdx}=1     ${Channel}=1     ${value}=0   ${path}=/cygdrive/c/'Program Files (x86)'/Spark/Bin
    ${output}  Conn.Execute    cmd=${path}/AMTUConsole.exe SetDeviation ${CellIdx}  ${Channel}  ${value}   alias=AMTU_PC
    ${output}    Remove String    ${output}    \x1b[6n
    #${output}    Evaluate        json.loads('''${output}''')                   json
    #[Return]   ${output}

AMTU.Disconnect
    Conn.Disconnect  alias=AMTU_PC

####DCAP operations####
DCAP.Start_Collect_Trace
    [Arguments]  ${traces}   ${host}=${dcap_ip}   ${port}=${dcap_port}    ${rd_version}=dcapv3
    [Documentation]  connect to dcap server, then start tracing.
    ...     traces: a list holding all trace you want to capture, eg. ["L2Ps_Sherpa"], or ["L2Ps_Sherpa", "scf"]
    Log to console   Start collecting dcap log.
#    @{traces}    create list   L2Ps_Sherpa
    &{bts_info}   Create Dictionary    host=${WEBUI_IP}    username=${WEBUI_USERNAME}
    ...                                password=${WEBUI_PASSWORD}    port=443
    rd.connect_to    host=${host}
    ...              port=${port}
    ...              secure=True
    ...              rd_version=${rd_version}
    DCAP.Delete_Bts_if_Exist
    rd.create_bts    host=${WEBUI_IP}
    rd.start_trace    bts=&{bts_info}    gnb_custom_profile=${traces}
    sleep    30s

DCAP.Delete_Bts_if_Exist
    ${bts_list}    rd.get_all_bts_info
    ${bts_count}   Get Length    ${bts_list}
    return from keyword if     ${bts_count}==0
    FOR  ${item}  IN  @{bts_list}
        ${bts_id}    set variable if  "${item['host']}"=="${WEBUI_IP}"    ${item['id']}    ${None}
    END
    run keyword if  not '${bts_id}'=='${None}'    rd.delete_bts    ${bts_id}

DCAP.Stop_Collect_Trace_and_Get_Result
    [Documentation]  Stop tracing, delete to traces to save server space, then remove the bts from the dcapserver.
    ...     return: path of downloaded trace file in zip format, and the content in the zip file.
    Log to console   Stop collecting dcap log.
    rd.stop_trace
    sleep    2min
    ${trace_file_path}    rd.get_results
    ${trace_result_content}    rd.get_result_file_contents
    ${PATHONLY}   ${SNAPSHOTNAME}   Split String From Right    string=${trace_file_path}   separator=/     max_split=1
    ${PATHONLY}   ${SNAPSHOTNAMEContent}   Split String From Right    string=${trace_result_content}   separator=/     max_split=1
    run    mv ${trace_file_path} ${LOG_PATH}/.
    run    mv ${trace_result_content} ${LOG_PATH}/.
    set test variable   ${trace_file_path}    ${LOG_PATH}/${SNAPSHOTNAME}
    set test variable   ${trace_result_content}    ${LOG_PATH}/${SNAPSHOTNAMEContent}
    rd.delete_trace
    rd.delete_bts
    [Return]  ${trace_file_path}  ${trace_result_content}

DCAP.Extract_out_Log_Files
    [Arguments]   ${tracer}=udptracer    ${trace_file_path}=${trace_file_path}
    ...    ${trace_result_content}=${trace_result_content}
    [Documentation]  Download trace zip file and extract needed logs fies to case log folder for later use.
    ...    tracer: str, tracer name that used to capture the needed logs, eg, udptracer for sherpa logs, flowtracer
    ...    for CP/emil log.
    ...    trace_file_path: str, the path of trace file in zip format, which is downdloaded from dcap
    ...    return: a list holding the path of each single log file.
    @{time}    Get Time    year month day hour min sec
    ${time_stamp}=    Set Variable    ${EMPTY}
    FOR    ${item}    IN    @{time}
        ${time_stamp}    Catenate    SEPARATOR=    ${time_stamp}    ${item}
    END
    create directory     ${LOG_PATH}/dcaplogs_${time_stamp}
    set test variable    ${extract_log_path}    ${LOG_PATH}/dcaplogs_${time_stamp}
    run  command=unzip -o ${trace_file_path} -d ${extract_log_path} && rm -f ${trace_file_path}
    ${all_log_file_paths}   dcap.get_all_log_files  json_file=${trace_result_content}  target_key=${tracer}
    set test variable    ${all_log_file_paths}
    [Return]  ${all_log_file_paths}

DCAP.Decode_Sherpa_Logs
    [Arguments]    ${delimiter}=%    ${log_files}=${all_log_file_paths}    ${log_path}=${extract_log_path}
    [Documentation]  Decode each sherpa .pcap file to .csv files stored in seperate folders.
    ...   ute env requirement:  linux version Sherpa must be installed on ute, and license is installed.
    ...   return: a list holding all paths of decoded logs.
    ${sherpa}  set variable     /opt/Nokia/Sherpa_5G_18/Sherpa.run
    ${folders_for_decoded_sherpa_logs}    create list
    FOR    ${item}    IN     @{log_files}
        ${index} =	Get Index From List	${log_files}	${item}
        create directory    ${log_path}/output_${index}
        ${output_dir}   set variable   ${log_path}/output_${index}
        ${file_path}	${originalfile_name} 	Split String From Right	${item} 	/	1
        ${short_file_name}    Fetch From Left       ${originalfile_name}  _
        run  command=cd ${log_path}/${file_path} && mv ${originalfile_name} ${short_file_name}.pcap
        run  ${sherpa} -o ${output_dir} -d 0 -s ${delimiter} -p Sherpa ${log_path}/${file_path}/${short_file_name}.pcap
        run  sed -i 's/${delimiter}/,/g' ${output_dir}/Sherpa_Csi.csv
        run  sed -i 's/${delimiter}/\t/g' ${output_dir}/Sherpa_l1l2Trace.csv
        run  sed -i 's/,/;/g' ${output_dir}/Sherpa_l1l2Trace.csv
        run  sed -i 's/\t/,/g' ${output_dir}/Sherpa_l1l2Trace.csv
#        KW.Check_Sherpa_log_ACSI    csv_filepath=${LOG_PATH}/dcaplogs/output_${index}
#        KW.Check PCI in Sherpa_CSI   csv_filepath=${LOG_PATH}/dcaplogs/output_${index}
        Append To List    ${folders_for_decoded_sherpa_logs}   ${output_dir}
    END
    set test variable    ${folders_for_decoded_sherpa_logs}
    [Return]  ${folders_for_decoded_sherpa_logs}

DCAP.Sherpa_Verify_DL_UL_Schedule
    [Arguments]    ${file_paths}=${folders_for_decoded_sherpa_logs}
    ${result}    set variable    ${False}
    FOR    ${item}   IN   @{file_paths}
        ${DL_PDCCH}   ${UL_PDCCH}   ${DL_PDSCH}  ${DL_PDSCH_Error}  sherpa.verify_ul_dl_schedule   file_path=${item}/Sherpa_l1l2Trace.csv
        ${result}    run keyword if    ${DL_PDCCH}==${UL_PDCCH}>=1 and ${DL_PDSCH}>=1 and ${DL_PDSCH_Error}==0
        ...    set variable   ${True}
        ...    ELSE    set variable   ${False}
        Exit For Loop If    ${DL_PDCCH}==${UL_PDCCH}>=1 and ${DL_PDSCH}>=1 and ${DL_PDSCH_Error}==0
    END
    should be true    ${result}

Log.EnableBtsLogWithTags
    [Documentation]    Enable bts log to 192.168.255.126 port 51000, if special tag needed, you can set in parameter tags
    ...    eg:  Log.EnableBtsLogWithTags    tags=0xAAAA=AAAA,0xBBBB=BBBB
    ...    original swconfig.txt used by this keyword defined as blow, with prority from high to low :
    ...    swconfigFile from argument > swconfig.txt from current BTS > creat one.
    [Arguments]     ${tags}=None    ${swconfigFile}=None
    ${logtags}      create list    0x1003F=1    0x10040=1    0x10041=5    0x10042=0xC0A8FF7E    0x10043=51000
    #${logtags}      create list    0x1003F=1    0x10040=1    0x10041=5    0x10042=0x0A399B68    0x10043=51000
    @{userTags}     run keyword if    '${tags}'!='None'    Split String    ${tags}    separator=,
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=timestamp
    ${timestamp}    robot.libraries.DateTime.convert date    ${timestamp}    epoch
    ${timestamp}    evaluate    int(round(${timestamp} * 1000))
    ${downloadSwconfig}    gNB.GetSwconfigFile
    run keyword if    '${swconfigFile}'!='None'    run    cp ${swconfigFile} ${LOG_PATH}/swconfig_${timestamp}.txt
    ...    ELSE IF    '${downloadSwconfig}'!='None'  run    cp ${downloadSwconfig} ${LOG_PATH}/swconfig_${timestamp}.txt
    ...    ELSE    run    touch ${LOG_PATH}/swconfig_${timestamp}.txt
    run    echo "\n" >>${LOG_PATH}/swconfig_${timestamp}.txt
    gNB.SwconfigModify    item list=${logtags}    filename=${LOG_PATH}/swconfig_${timestamp}.txt
    run keyword if    '${tags}'!='None'    gNB.SwconfigModify    item list=${userTags}    filename=${LOG_PATH}/swconfig_${timestamp}.txt
    gNB.ReplaceSwconfig  Path=${LOG_PATH}    filename=swconfig_${timestamp}.txt

Log.SetLoggingSeverity
    [Arguments]    ${LoggingSeverity}=trace
    gNB.SetLoggingSeverity    LoggingSeverity=${LoggingSeverity}

Log.CaptureRuLog
    ${mode}        set variable    ${L3CallLogConf['rulog']['mode']}
    ${position}    set variable    ${L3CallLogConf['rulog']['position']}
    ${ruIndex}     set variable    ${L3CallLogConf['rulog']['ruIndex']}
    ${ruUsr}       set variable    ${L3CallLogConf['rulog']['ruUsr']}
    ${ruPwd}       set variable    ${L3CallLogConf['rulog']['ruPwd']}

    gNB.Connect
    ${isPrimaryCoreInLeftSubrack}    set variable    ${False}
    ${isPrimaryCoreInLeftSubrack}    Run Keyword If    '${mode}'=='dualcore'        gNB.IsPrimaryCoreInLeftSubrack

    Run Keyword If  '${isPrimaryCoreInLeftSubrack}'=='${True}' and '${position}'=='secondary'
    ...              ssh.Connect to    fct4s0icom.local    ${ASIK_USERNAME}  ${ASIK_PASSWORD}
    ...              alias=asik_secondary  proxy=${ALIAS_ASIK}
    ...              ELSE IF    '${isPrimaryCoreInLeftSubrack}'=='${False}' and '${position}'=='secondary'
    ...              ssh.Connect to    fct0s0icom.local    ${ASIK_USERNAME}  ${ASIK_PASSWORD}
    ...              alias=asik_secondary  proxy=${ALIAS_ASIK}

    ${conn}    set variable if    '${position}'=='secondary'    asik_secondary    ${ALIAS_ASIK}

    COAM_Admin.Login
    Connect to RU With Allocated IP    ru_index=${ruIndex}    asik_alias=${conn}    connection=COAM
    ...                                ru_username=${ruUsr}    ru_password=${ruPwd}    ru_alias=RU_${ruIndex}
    Conn.Execute    cmd=ccsShell.sh log -a -c full -z RU_${ruIndex}_logs.zip     alias=RU_${ruIndex}

    ssh.download_file   local_path=${LOG_PATH}/RU_${ruIndex}_logs.zip    remote_path=/ram/RU_${ruIndex}_logs.zip   connection=RU_${ruIndex}
    sleep    30s
    Conn.Execute    cmd=rm -f /ram/RU_${ruIndex}_logs.zip      alias=RU_${ruIndex}
    [Return]  ${LOG_PATH}/RU_${ruIndex}_logs.zip

Log.BtsLogInit
    [Arguments]   ${btslog}=false
    return from keyword if    '${btslog}'=='false'
    Set To Dictionary    ${L3CallLogConf['btslog']}    enabled    true
    BtsLog.StartBTSlogCollection

Log.BtsLogCollect
    return from keyword if    '${L3CallLogConf['btslog']['enabled']}'=='false'        None
    ${log}   BtsLog.StopBTSlogCollectionandGetlog
    [Return]    ${log}

Log.WiresharkLogInit
    [Arguments]   ${wireshark}
    ${wiresharkobj}    Evaluate        json.loads('''${wireshark}''')                   json

#    @{userTags}     run keyword if    '${wireshark}'!='false'    Split String    ${wireshark.replace(" ", "")}    separator=,

    Set To Dictionary    ${L3CallLogConf['wireshark']}    enabled    true
    Set To Dictionary    ${L3CallLogConf['wireshark']}    type    ${wiresharkobj['type']}
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    gNB.Connect
    FOR   ${type}    IN    @{L3CallLogConf['wireshark']['type']}
        log    ${type}
        run keyword if   '${type}'=='CPIF'    Wireshark.StartCaptureLogFromContainer
        ...    nodename=CPIF   filename=${filename}_CPIF.pcap
        run keyword if   '${type}'=='NG'    Wireshark.StartCaptureNGLog
        ...    filename=${filename}_NG.pcap
    END

Log.WiresharkLogCollect
    return from keyword if    '${L3CallLogConf['wireshark']['enabled']}'=='false'        None    None
    ${filename}   set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    ${CPIFLog}    set variable    None
    ${NGLog}      set variable    None
    FOR   ${type}    IN    @{L3CallLogConf['wireshark']['type']}
        log    ${type}
        run keyword if   '${type}'=='CPIF'    Wireshark.StopCapturinglogFromContainer    nodename=CPIF
        ${conn}    gNB.GetSystemModuleType    alias=${ALIAS_ASIK}
        ${CPIFLog}    run keyword if   '${type}'=='CPIF'      Wireshark.DownloadLogToUTE  filename=${filename}_CPIF.pcap
        ...    log_dir=/tmp/node_CPIF00/tmp    connection=${conn}
        ...    ELSE    Set Variable    ${CPIFLog}

#        ${CPIFLog}    run keyword if   '${type}'=='CPIF'    wireshark.DownloadLogToUTEFromContainer
#        ...    filename=${filename}_CPIF.pcap    nodename=CPIF
#        ...    ELSE    Set Variable    ${CPIFLog}
        run keyword if   '${type}'=='NG'      Wireshark.StopCaptureNGLog
        ${NGLog}    run keyword if   '${type}'=='NG'      Wireshark.DownloadLogToUTE  filename=${filename}_NG.pcap
        ...    ELSE    Set Variable    ${NGLog}
    END
    [Return]    ${CPIFLog}    ${NGLog}

Log.DcapLogInit
    [Arguments]   ${dcap}
    ${dcapobj}    Evaluate        json.loads('''${dcap}''')                   json
    ${host}    set variable if    ${dcap.count('host')}>0    ${dcapobj['host']}    10.101.60.29
    ${port}    set variable if    ${dcap.count('port')}>0    ${dcapobj['port']}    443
    Set To Dictionary    ${L3CallLogConf['dcap']}    enabled    true
    Set To Dictionary    ${L3CallLogConf['dcap']}    host   ${host}
    Set To Dictionary    ${L3CallLogConf['dcap']}    port   ${port}
    Set To Dictionary    ${L3CallLogConf['dcap']}    type    ${dcapobj['type']}
    log    ${dcapobj['type']}
    DCAP.Start_Collect_Trace    host=${L3CallLogConf['dcap']['host']}    port=${L3CallLogConf['dcap']['port']}
    ...    traces=${dcapobj['type']}

Log.DcapLogCollect
    return from keyword if    '${L3CallLogConf['dcap']['enabled']}'=='false'        None    None
    ${dcaplog}   ${jsonContent}    DCAP.Stop_Collect_Trace_and_Get_Result
    [Return]    ${dcaplog}   ${jsonContent}

Log.RuLogInit
    [Arguments]   ${rulog}
    ${ruobj}    Evaluate        json.loads('''${rulog}''')                   json

    gNB.Connect
    ${status}    ssh.Execute    command=ping 192.168.255.119 -c 5    connection=${ALIAS_ASIK}
    ${result}    Run Keyword and Return Status    Should Contain    ${status}      64 bytes from 192.168.255.119: icmp_seq=5
    gNB.Disconnect
    ${mode}    Set variable If    ${result}        dualcore    singlecore

    Set To Dictionary    ${L3CallLogConf['rulog']}    enabled    true
    Set To Dictionary    ${L3CallLogConf['rulog']}    mode     ${mode}
    Set To Dictionary    ${L3CallLogConf['rulog']}    ruUsr    ${TLCommonConfig['rus']['${ruobj['ru']}']['ru_username']}
    Set To Dictionary    ${L3CallLogConf['rulog']}    ruPwd    ${TLCommonConfig['rus']['${ruobj['ru']}']['ru_password']}
    Set To Dictionary    ${L3CallLogConf['rulog']}    ruIndex    ${TLCommonConfig['rus']['${ruobj['ru']}']['ru_index']}
    Set To Dictionary    ${L3CallLogConf['rulog']}    position    ${TLCommonConfig['rus']['${ruobj['ru']}']['position']}

Log.RuLogCollect
    return from keyword if    '${L3CallLogConf['rulog']['enabled']}'=='false'
    ${rulog}    Log.CaptureRuLog
    [Return]   ${rulog}

Log.LMIlogInit
    [Arguments]   ${lmilog}
    ${lmiobj}    Evaluate        json.loads('''${lmilog}''')                   json

    Set To Dictionary    ${L3CallLogConf['lmilog']}    enabled    true
    Set To Dictionary    ${L3CallLogConf['lmilog']}    lmiconfig     ${TLCommonConfig['rus']['${lmiobj['ru']}']}
    Log.LMIConsoleLogInit    lmi=${L3CallLogConf['lmilog']['lmiconfig']}
    Log.LMIBtsLogInit        lmi=${L3CallLogConf['lmilog']['lmiconfig']}

Log.LMIlogCollect
    return from keyword if    '${L3CallLogConf['lmilog']['enabled']}'=='false'
    Log.LMIEnableLMIOn
    ${lmi_rulog}         Log.LMIRULogCollect    lmi=${L3CallLogConf['lmilog']['lmiconfig']}
    sleep    5
    ${lmi_ru_console}    Log.LMIConsoleLogCollect    lmi=${L3CallLogConf['lmilog']['lmiconfig']}
    ${lmi_ru_btslog}     Log.LMIBtsLogCollect        lmi=${L3CallLogConf['lmilog']['lmiconfig']}
    [Return]  ${lmi_ru_console}    ${lmi_ru_btslog}    ${lmi_rulog}

Log.SnapshotInit
    [Arguments]  ${snapshot}
    Set To Dictionary    ${L3CallLogConf['snapshot']}    enabled    true

Log.SnapshotCollect
    return from keyword if    '${L3CallLogConf['snapshot']['enabled']}'=='false'
    ${snapshotlog}    gNB.CollectSnapshot
    [Return]   ${snapshotlog}

Log.LMIConsoleLogInit
    [Arguments]    ${lmi}=${TLCommonConfig['rus']['0']}
    log to console   setup putty console log, clear putty log
    return from keyword if    '${lmi['host']}'==''
    ssh.Connect to  hostname=${lmi['host']}  username=${lmi['username']}  password=${lmi['password']}  alias=rutestpc
    run keyword and ignore error   ssh.execute   command=cat /dev/null > /tmp/putty.txt  connection=rutestpc
    run keyword and ignore error   ssh.execute   command=echo ------start----- > /tmp/putty.txt  connection=rutestpc
    run keyword and ignore error   ssh.disconnect    connection=rutestpc

Log.LMIConsoleLogCollect
    [Arguments]    ${lmi}=${TLCommonConfig['rus']['0']}    ${loop}=0
    return from keyword if    '${lmi['host']}'==''
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    ssh.Connect to  hostname=${lmi['host']}  username=${lmi['username']}  password=${lmi['password']}  alias=rutestpc
    conn.downloadfile  local_path=${LOG_PATH}/lmi_ru_console_${filename}_${loop}.log    remote_path=/tmp/putty.txt    alias=rutestpc
    run keyword and ignore error   ssh.disconnect    connection=rutestpc
    [Return]  ${LOG_PATH}/lmi_ru_console_${filename}_${loop}.log

Log.LMIRULogCollect
    [Arguments]    ${lmi}=${TLCommonConfig['rus']['0']}    ${loop}=0
    return from keyword if    '${lmi['host']}'==''
    ssh.Connect to  hostname=${lmi['host']}  username=${lmi['username']}  password=${lmi['password']}  alias=rutestpc
    ssh.Connect to  hostname=${lmi['ru_ip']}  username=${lmi['ru_username']}  password=${lmi['ru_password']}
    ...    proxy=rutestpc    alias=alias_ru
    ${res}  conn.execute  cmd=ccsShell.sh log -a -c full -z ru_logs.zip    alias=alias_ru
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    conn.downloadfile  local_path=${LOG_PATH}/lmi_ru_logs_${filename}_${loop}.zip    remote_path=/ram/ru_logs.zip    alias=alias_ru
    run keyword and ignore error    conn.disconnect  alias=alias_ru
    run keyword and ignore error    conn.disconnect  alias=rutestpc
    [Return]  ${LOG_PATH}/lmi_ru_logs_${filename}_${loop}.zip

Log.PrivateLMIBtsLogStartWithExecutor
    [Documentation]    collect syslogs from ute VM.
    [Arguments]    ${lmi}=${TLCommonConfig['rus']['0']}
    &{executor}=    create dictionary    host=${lmi['host']}
    ...                                  user=${lmi['username']}
    ...                                  password=${lmi['password']}
    btslog.create_btslog_collector       name=LMIbtslog         btslog_path=/opt/btslog/btslog
    ...                                  btslog_launcher_path=/opt/btslog/btslog_launcher
    ...                                  executor=${executor}    log_dir=/tmp/btslog2
    btslog.Set Suite Alias               LMIbtslog
    core.setup_collectors                names=LMIbtslog
    core.start_collectors                names=LMIbtslog

Log.LMIBtsLogInit
    [Arguments]    ${lmi}=${TLCommonConfig['rus']['0']}
    return from keyword if    '${lmi['host']}'==''
    ssh.Connect to  hostname=${lmi['host']}  username=${lmi['username']}  password=${lmi['password']}  alias=rutestpc
    ssh.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -NOGUI'   timeout=60   connection=rutestpc
    ssh.Execute   command=rm -rf /tmp/btslog2/*   timeout=60    connection=rutestpc
    ssh.Execute   command=rm -rf /tmp/BTSLogCommandsLocalServer   timeout=60    connection=rutestpc

    Log.PrivateLMIBtsLogStartWithExecutor  lmi=${lmi}
    ${res}   ssh.Execute   command=ps -ef|grep bts   timeout=60    connection=rutestpc
    log to console    ${res}
    run keyword and ignore error    conn.disconnect  alias=rutestpc
#    ${status}   run keyword and return status   Log.PrivateLMIBtsLogStartWithExecutor  lmi=${lmi}
#    run keyword unless  ${status}   log   start btslog collection failed

Log.LMIBtsLogCollect
    [Arguments]    ${lmi}=${TLCommonConfig['rus']['0']}    ${loop}=0
    #core.collect_collectors    names=LMIbtslog
    return from keyword if    '${lmi['host']}'==''
    core.teardown_collectors   names=LMIbtslog
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    ssh.Connect to  hostname=${lmi['host']}  username=${lmi['username']}  password=${lmi['password']}  alias=rutestpc
    ssh.Execute    command=cd /tmp/btslog2;tar -cvf btslog_${lmi['host']}.tar SYSLOG*   timeout=60   connection=rutestpc
    ssh.Download File    remote_path=/tmp/btslog2/btslog_${lmi['host']}.tar
    ...    local_path=${LOG_PATH}/lmi_btslog_${lmi['host']}_${filename}_${loop}.tar   connection=rutestpc
    run keyword and ignore error    conn.disconnect  alias=rutestpc
    [Return]  ${LOG_PATH}/lmi_btslog_${lmi['host']}_${filename}_${loop}.tar

Log.LMIEnableLMIOn
    [Arguments]    ${lmi}=${TLCommonConfig['rus']['0']}
    return from keyword if    '${lmi['host']}'==''
    FOR  ${i}    IN RANGE    ${6}
        ${status}    LMI_Enable_SSH   ip=${lmi['host']}  username=${lmi['username']}   password=${lmi['password']}
        ...    ru_ip=${lmi['ru_ip']}    ru_username=${lmi['ru_username']}    ru_password=${lmi['ru_password']}
        return from keyword if    '${status}'=='True'
        Sleep   10s
    END
    Fail    enable lmi on failed

Log.Init
    [Arguments]    ${logtype}=None
    [Documentation]    Configurable log collection , if set argument to false , corresponding log will not be collected
    ...    else, log will be collected according to the parameters. For detail , refer to blow defination.
    ...    Arguments:
    ...        snapshot: true or false
    ...        btslog:   true or false
    ...        wirshark: {"type":["NG", "CPIF"]}
    ...        dcap:     {'host':'optional','port':'optional','type':[mandatory]}
    ...                  type: ["L2Ps_Sherpa"], or ["L2Ps_Sherpa", "scf"]
    ...        rulog:   {'ruIndex':'0'}   ruIndex: ru index in TL TLConfiguration.py
    ...        lmilog:  {'ruIndex':'0'}   ruIndex: ru index in TL TLConfiguration.py
    ${types}    Get Dictionary Keys    ${logtype}
    FOR   ${type}    IN    @{types}
        log    ${type}
        run keyword and continue on failure    Log.${keyword_logInit['${type}']}    ${type}=${logtype['${type}']}
    END

Log.Collect
    [Arguments]   ${logtype}=None
    [Documentation]   After collect, you can get the log by return value, eg ${returnValue['btslog']}
    ...     and so on for btslog,CPIFlog,NGlog,dcaplog

    ${logs}    run keyword if    '${logtype}'=='None'    Log.CollectAllEnabledLog
    ...        ELSE    Log.CollectCertainLog    logtype=${logtype}

    log    ${logs}
    log    ${L3CallLogConf}
    [Return]    ${logs}

Log.CollectAllEnabledLog
    ${snapshotlog}                 run keyword and continue on failure   Log.SnapshotCollect
    ${btslog}                      run keyword and continue on failure   Log.BtsLogCollect
    ${CPIFlogandNGlog}             run keyword and continue on failure   Log.WiresharkLogCollect
    ${dcaplog}                     run keyword and continue on failure   Log.DcapLogCollect
    ${rulmilog}                    run keyword and continue on failure   Log.LMIlogCollect
    ${rulog}                       run keyword and continue on failure   Log.RuLogCollect

    &{logs}   Create Dictionary    snapshot=${snapshotlog}       btslog=${btslog}
    ...                            CPIFlog=${CPIFlogandNGlog}    rulog=${rulog}
    ...                            dcaplog=${dcaplog}            lmilog=${rulmilog}

    Set To Dictionary    ${L3CallLogConf['snapshot']}      enabled    true
    Set To Dictionary    ${L3CallLogConf['rulog']}         enabled    false
    Set To Dictionary    ${L3CallLogConf['btslog']}        enabled    false
    Set To Dictionary    ${L3CallLogConf['wireshark']}     enabled    false
    Set To Dictionary    ${L3CallLogConf['dcap']}          enabled    false
    Set To Dictionary    ${L3CallLogConf['lmilog']}        enabled    false
    [Return]  ${logs}

Log.CollectCertainLog
    [Arguments]  ${logtype}
    ${logtype}     run keyword     Split String    ${logtype.replace(" ", "")}    separator=,
    ${len}    Get Length    ${logtype}
    &{logs}    create dictionary

    FOR   ${i}    IN RANGE    ${len}
        log    ${logtype[${i}]}
        ${log}    run keyword and continue on failure    Log.${keyword_logCollect['${logtype[${i}]}']}
        Set To Dictionary    ${logs}          ${logtype[${i}]}    ${log}
    END

    FOR   ${i}    IN RANGE    ${len}
        run keyword if    '${logtype[${i}]}'=='snapshot'    Set To Dictionary    ${L3CallLogConf['${logtype[${i}]}']}      enabled    true
        ...   ELSE    Set To Dictionary    ${L3CallLogConf['${logtype[${i}]}']}      enabled    false
    END
    [return]  ${logs}
