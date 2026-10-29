*** Settings ***
Documentation     author: zhang bo
...                 contact: bo.5.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB005739-AL

Library      OperatingSystem
Library      Collections
Library      taf.transport.ssh    WITH NAME    csn
Library      taf.config.scf    WITH NAME    scf
Library     taf.config.testline    WITH NAME    testline
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library    taf.gnb.oam.commissioning    WITH NAME    commissioning
Library      XML    ${True}    WITH NAME    xmlpath
Library      ../../../../OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py     WITH NAME    lib
#Library      ../../../../../resources/python_libs/Attenuation.py
Library      Attenuation.Attenuation    WITH NAME    atten
Library      taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Variables    ../Resources/__init__.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource     taf/rfrl/common_resources/robot/preconditions.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library     change_parameters.py    WITH NAME    SCF
Resource    ../../libraries/biplog_capture/biplog_capture.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot


*** Variables ***

${gNB_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_SSH_NAME}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_SSH_PWD}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

${eNB_IP}              ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_SSH_NAME}        ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${eNB_SSH_PWD}        ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}

${UTE_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}

${WEBUI_COAM}      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_COAM_4G}      https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${WEBUI_NAME}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${eNB_instance}    ${tl.enbs[0].instance_id}

${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2
${enbx2_para}    administrativeState
${lnrel_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${lnrel_para}    defaultLnRelGnbCellId
${distname}    MRBTS-${enb_instance}/NRBTS-${enb_instance}

${atten_ip}    ${tl.attenuator[0].ip_addr}
${att_port_5}    ${tl.attenuator[0].attenuator_ports[5]}
${att_port_1}    ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2}    ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3}    ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}    ${tl.attenuator[0].attenuator_ports[4]}
${att_port_8}    ${tl.attenuator[0].attenuator_ports[8]}
${att_port_13}    ${tl.attenuator[0].attenuator_ports[9]}
${att_port_14}    ${tl.attenuator[0].attenuator_ports[10]}
${att_port_15}    ${tl.attenuator[0].attenuator_ports[11]}
${att_port_16}    ${tl.attenuator[0].attenuator_ports[12]}
${att_api_port}    ${tl.attenuator[0].port}
${vendor}    ${tl.attenuator[0].vendor}
${max_attenuation_value}    ${127}


${gNBlogname}          ngap.pcap
${eNBlogname}          s1ap.pcap
${BIP_LOG}              BIP.pcap
${tcpdump_path}       /tmp
${BIP_LOG_PATH}         /tmp

${SCF_path}    /opt/workspace/CIT/Master/Scf_files/
${scf_filename}    TL360_ECPRI_AEHC_SA_OK.xml
${scf_filename_354}    TL354_ECPRI_AEQN_SA_OK.xml
${tl_scf_filename_enb}    TL360_enb_SCF.xml
${tl_scf_filename_enb_354}    TL354_enb_SCF.xml
${enb_BTS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${localFilePath}       /opt/workspace/CIT/Master/swconfig/swconfig.txt
${BIP_SCRIPT_PATH}     /ffs/run/config/scripts
${scripts_path}        /opt/workspace/CIT/Master/bip_scripts
${gnbMirror_script}        gnbMirroring.sh
${gnbMirrorconf_script}        gnbMirroringConfig.sh
${gulp}                       gulp

${tshark_path}       /usr/bin/tshark
${luashark_path}      /opt/workspace/CIT/Master/luashark/generated_luashark/luashark.lua
${command_template_with_Y}       {tshark_path} -r {input_file} -Y  \"s1ap\"  -T pdml > {output_file}
${command_template_with_Y_ngap}      {tshark_path} -r {input_file} -Y  \"ngap\"  -T pdml > {output_file}
${command_template_bip}       {tshark_path} -r {input_file} -Y  \"nr-rrc\"  -T pdml > {output_file}

${ALIAS_gNB}       gNB
${ALIAS_eNB}       eNB
${ALIAS_UTE}       ute
${ue_type}    ${tl.ues[0].capabilities[1]}
${enb_pci_id}    1
${eutran_cell_id}    231425
${enb_earfcn}    1805
${biplog_743_3}       tcpdumpL2L1_filtering_off.pcap
${gnb_path}    /tmp/
*** Keywords ***
Prepare env with UE
    power_ue.Prepare UE    ue_type=${ue_type}

Update the swconfig file
    SSH Connect With Timeout    alias=${ALIAS_gNB}
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=${ALIAS_gNB}
    csn.disconnect    connection=${ALIAS_gNB}

5GC00743_feature_precondition
    Log    \n *** Feature related parameters setting    console=yes
    Get mrbtsId and nrbtsId
    Get eNB phyCellId and eutraCelId and earfcnDL
    Modify 743 used gNB parameter    parameters=${PARAMS_TO_MODIFY_SRB_DRB_INACTIVITY_TIMER}
    Modify 743 used gNB parameter    parameters=${PARAMS_TO_MODIFY_743_nrcell}
    Modify 743 used gNB parameter    parameters=${PARAMS_TO_MODIFY_743_nrSYSinfo}
    Modify 743 used gNB parameter    parameters=${PARAMS_TO_MODIFY_743_NRLIM}

5GC00743_feature_precondition_trunk
    Log    \n *** Feature related parameters setting    console=yes
    Get mrbtsId and nrbtsId
    Get eNB phyCellId and eutraCelId and earfcnDL    dist_name=MRBTS-${eNB_instance}/LNBTS-${eNB_instance}/LNCEL-12
    Modify scf file for case    modify_list=${PARAMS_TO_MODIFY}
    Prepare with COAM classical BTS cell onair trunk

Modify scf file for case
    [Arguments]    ${modify_list}    ${tl_scf_file}=${scf_filename_354}
    run keyword and continue on failure     commissioning.Modify Scf    input_scf=${SCF_path}${tl_scf_file}
    ...            output_scf=${epc_log_path}${tl_scf_file}    parameters_lists=${modify_list}

Modify 743 used gNB parameter
    [Arguments]    ${parameters}
    Connect to gnb coam via ssl   bts_host=${gNB_IP}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    [Teardown]    COAM Teardown gnb connections

Perform full commission for COAM enb BTS
    [Arguments]    ${enb_BTS}=${enb_BTS}    ${scf_file_path_enb}=${SCF_path}${tl_scf_filename_enb}
    Connect to gnb coam via ssl    connection=enblte    bts_host=${enb_BTS}
    COAM Commission with scf file    scf_file_path=${scf_file_path_enb}    timeout=600    connection=enblte
    [Teardown]    COAM Teardown gnb connections    connection=enblte

Check the enb cell status onair
    [Arguments]    ${enb_BTS}=${enb_BTS}
    Connect to gnb coam via ssl    connection=enblte    bts_host=${enb_BTS}
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air    connection=enblte
    [Teardown]    COAM Teardown gnb connections    connection=enblte

Prepare with COAM classical BTS cell onair
    Perform full commission for COAM gnb    scf_filename=${scf_filename}
    wait until keyword succeeds    15min   1min    Check the gnb RU status ready
    wait until keyword succeeds    15min   1min    Check the gnb cell status onair

Prepare with COAM classical BTS cell onair trunk
    Perform full commission for COAM gnb trunk    scf_filename=${scf_filename_354}
    wait until keyword succeeds    15min   1min    Check the gnb RU status ready
    wait until keyword succeeds    15min   1min    Check the gnb cell status onair

locked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

Perform full commission for COAM gnb
    [Arguments]    ${scf_filename}=${scf_filename}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${SCF_path}${scf_filename}    is_pdl_checking_needed=${False}
    [Teardown]    COAM Teardown gnb connections

Perform full commission for COAM gnb trunk
    [Arguments]    ${scf_filename}=${scf_filename_354}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${epc_log_path}${scf_filename}    is_pdl_checking_needed=${False}
    [Teardown]    COAM Teardown gnb connections

Check gnb COAM classical start normally for 1514
#    Check Airscale HW module status
    ${res} =    Feature 1514 Enabled
    run keyword if    ${res}==${False}    wait until keyword succeeds    15min   30s    Check the gnb RU status ready

Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check the gnb cell status onair
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

unlocked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Get mrbtsId and nrbtsId
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}   username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${commission_file}    selenium_coam.backup_bts_site_configuration
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    set suite variable     ${mrbtsId}
    set suite variable     ${nrbtsId}
    set suite variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    selenium_coam.logout
    [Teardown]    selenium_coam.disable_virtual_display

Get eNB phyCellId and eutraCelId and earfcnDL
    [Arguments]    ${dist_name}=MRBTS-${eNB_instance}/LNBTS-${eNB_instance}/LNCEL-1
    selenium_coam.enable_virtual_display
    Wait Until Keyword Succeeds    10min    10s    selenium_coam.login    url=${WEBUI_COAM_4G}
    ...    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${enb_pci_id} =    selenium_coam.get_parameter_value    dist_name=${dist_name}
	...   abbr=phyCellId    filter_param=Physical layer cell identity    timeout=40
	${cell_tech}=    selenium_coam.get_parameter_value
    ...    dist_name=${dist_name}
	...    abbr=cellTechnology    filter_param=Cell technology   timeout=40
    ${enb_earfcn_FDD}=    Run keyword if    '${cell_tech}'=='FDD'    selenium_coam.get_parameter_value
    ...    dist_name=${dist_name}/LNCEL_FDD-0
	...    abbr=earfcnDL    filter_param=EARFCN downlink   timeout=40
	${enb_earfcn_TDD}=    Run keyword if    '${cell_tech}'=='TDD'    selenium_coam.get_parameter_value
    ...    dist_name=${dist_name}/LNCEL_TDD-0
	...    abbr=earfcn    filter_param=EARFCN for both Downlink and Uplink (TDD)   timeout=40
    ${enb_earfcn}=    set variable if    '${enb_earfcn_FDD}'=='None'    ${enb_earfcn_TDD}    ${enb_earfcn_FDD}
	${eNB_instance}=    convert to integer    ${eNB_instance}
	${eutran_cell_id}=      Evaluate     ${eNB_instance}*256+1
	set suite variable     ${enb_pci_id}
	set suite variable     ${eutran_cell_id}
    set suite variable     ${enb_earfcn}
    selenium_coam.logout
    [Teardown]    selenium_coam.disable_virtual_display

Set SIB5 sibPeriodicity
    [Arguments]   ${sibPeriodicity}    ${dist_name}=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRSYSINFO_PROFILE-0
    ${commission_file}     Get SCF from WebUI
    modify sibPeriodicity to Scf    scf_name=${commission_file}
    ...    dist_name=${dist_name}
    ...    sibPeriodicity_value=${sibPeriodicity}
    ...    index=3
    Do commission for each gNB    coam_url=${WEBUI_COAM}   scf_name=${commission_file}

Get SCF from WebUI
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}   username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${commission_file}    selenium_coam.backup_bts_site_configuration
    set test variable     ${commission_file}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    [Return]    ${commission_file}

modify sibPeriodicity to Scf
    [Arguments]    ${scf_name}   ${dist_name}   ${sibPeriodicity_value}   ${index}
    scf.Load Scf    file_path=${scf_name}
    scf.modify_scf_element    value=${sibPeriodicity_value}
    ...    dist_name=${dist_name}
    ...    list_name=sibSchedulingList
    ...    p_name=sibPeriodicity
    ...    index=${index}
    scf.Save Scf    file_path=${scf_name}

Do commission for each gNB
    [Arguments]     ${coam_url}    ${scf_name}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${coam_url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_name}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    Run Keyword And Ignore Error   selenium_coam.logout
    [Teardown]    selenium_coam.disable_virtual_display

Check the BTS cell status onair
    [Arguments]     ${coam_url}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${coam_url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${cell_status} =    selenium_coam.get_cell_info
    selenium_coam.logout
    Get info status check     info_status=${cell_status}
    selenium_coam.disable_virtual_display

#BIP log keywords
Start Capture BIPLog
    Log    \n *** Capture BIP Logs    console=yes
    [Arguments]          ${connection}=${ALIAS_gNB}
    SSH Connect With Timeout    alias=${connection}
    csn.Send command    command=mkdir ${BIP_SCRIPT_PATH}        connection=${connection}
    csn.upload_file     local_path=${scripts_path}/${gnbMirror_script}
    ...                 remote_path=${BIP_SCRIPT_PATH}/${gnbMirror_script}
    ...                 connection=${connection}
    csn.upload_file     local_path=${scripts_path}/${gnbMirrorconf_script}
    ...                 remote_path=${BIP_SCRIPT_PATH}/${gnbMirrorconf_script}
    ...                 connection=${connection}
    csn.upload_file     local_path=${scripts_path}/${gulp}
    ...                 remote_path=${BIP_SCRIPT_PATH}/${gulp}
    ...                 connection=${connection}
    sleep  2 sec
    csn.Send command     command=rm ${BIP_LOG_PATH}/${BIP_LOG}    connection=${connection}
    csn.Send command     command=chmod 777 ${BIP_SCRIPT_PATH}/*   connection=${connection}
    ${output}   csn.execute        command=cd ${BIP_SCRIPT_PATH}; ./gnbMirroring.sh     connection=${connection}

Catch Bip log_trunk
    [Arguments]     ${biplog}    ${connection}=ABIL Master    ${gnb_index}=${0}    ${mirror_mode}=local
    ...            ${bip_interface}=ethbp1    ${bip_time}=${3}    ${HW_TYPE}=ASIB    ${hw_slot}=${1}
    Preconfdition for Bip Capture trunk      mirror_mode=${mirror_mode}    HW_TYPE=${HW_TYPE}
    sleep    3s
    Connect to Capacity Unit Master with hostname     gnb_index=${gnb_index}     hw_slot=${hw_slot}
    sleep    3s
    Run keyword if    '${bip_time}'=='infinity'
    ...    csn.Execute    command=tcpdump -i ${bip_interface} -w ${gnb_path}${biplog} -vv
    ...           connection=${connection}
    ...    ELSE    csn.Execute    command=timeout ${bip_time} tcpdump -i ${bip_interface} -w ${gnb_path}${biplog} -vv
    ...         connection=${connection}

Preconfdition for Bip Capture trunk
    [Arguments]     ${mirror_mode}     ${hw_slot}=${1}    ${HW_TYPE}=ASIB
    Connect to Capacity Unit Loner with hostname    alias=ABIL Loner    hw_slot=${hw_slot}
    ${hwindex_asib}=    HW slot for asib capture    hw_slot=${hw_slot}
    detectHwAndStartMirroring    asik_alias=Common Master    loner_alias=ABIL Loner   mirror_mode=${mirror_mode}
    ...    sw_release=${HW_TYPE}    hw_index=${hwindex_asib}

BIP logs download from ASIB to UTE
    [Arguments]    ${logname}     ${gnb_index}=${0}    ${connection}=ABIL Master    ${hw_slot}=${1}
    Connect to Capacity Unit Master with hostname    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    sleep    5s
    csn.download_file   remote_path=${gnb_path}/${logname}   local_path=${epc_log_path}/${logname}   connection=${connection}

Stop and save BIPLog
    Log    \n *** Stop and save BIPLog    console=yes
    [Arguments]    ${logname}=${BIP_LOG}    ${connection}=${ALIAS_gNB}
    ...    ${remote_path}=${BIP_LOG_PATH}/tcpdumpL2L1_filtering_off.pcap0
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${remote_path}    local_path=${LOG_PATH}/${logname}
    ...     connection=${connection}
    sleep    3
    csn.disconnect    connection=${connection}

Check phone attach successfully
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=false

Check no TAU message in tcpdump
       [Arguments]    ${pcap_file_path}
       ${all_packets}=    load_pcap_file  pcap_file=${pcap_file_path}    tshark_path=${tshark_path}
       ...    command_template=${command_template_with_Y}
       ${path}  ${file_name} =   split path   ${pcap_file_path}
       ${file_prefix}  ${file_extension}=  split extension   ${file_name}
       ${msg}=  set variable   NAS EPS Mobility Management Message Type: Tracking area update complete
       ${xpath_prefix}=  set variable    (//field[contains(@showname, '${msg}')]/../../../../..)[1]
       ${matched_tac_elements}=   xmlpath.get_elements   source=${path}/${file_prefix}.pdml
       ...    xpath=${xpath_prefix}/field[contains(@show,'id-TAI')]//field[@name='s1ap.tAC']
       ${number_of_tac_nodes}=    get length   ${matched_tac_elements}
       should be true   ${number_of_tac_nodes}==0   TAU message is found!


Get TAU Message From Tcpdump
       [Arguments]    ${pcap_file_path}
        ${all_packets}=    load_pcap_file   pcap_file=${pcap_file_path}    tshark_path=${tshark_path}
        ...    command_template=${command_template_with_Y}
        ${path}  ${file_name} =   split path   ${pcap_file_path}
        ${file_prefix}  ${file_extension}=  split extension   ${file_name}
        ${msg}=  set variable   NAS EPS Mobility Management Message Type: Tracking area update complete
        ${xpath_prefix}=  set variable    (//field[contains(@showname, '${msg}')]/../../../../..)[1]
        ${matched_tac_elements}=   xmlpath.get_elements   source=${path}/${file_prefix}.pdml
        ...    xpath=${xpath_prefix}/field[contains(@show,'id-TAI')]//field[@name='s1ap.tAC']
        ${number_of_tac_nodes}=    get length   ${matched_tac_elements}
        should be true   ${number_of_tac_nodes}>=1   No tac message is found!
        ${tac}=  set variable if   ${number_of_tac_nodes}>=1   ${matched_tac_elements[0].attrib["value"] }
        ${tac}=  convert to integer   ${tac}   16
        ${matched_cellid_elements}=   xmlpath.get_elements   source=${path}/${file_prefix}.pdml
        ...    xpath=${xpath_prefix}/field[contains(@show,'id-EUTRAN-CGI')]//field[@name='s1ap.CellIdentity']
        ${number_of_cellid_nodes}=    get length   ${matched_cellid_elements}
        should be true   ${number_of_cellid_nodes}>=1   No cell id message is found!
        ${cell_id}=  set variable if   ${number_of_tac_nodes}>=1   ${matched_cellid_elements[0].attrib["show"]}
        ${cell_id}=  convert to integer   ${cell_id}   16
        [Return]     ${tac}   ${cell_id}

Check no Blackcelllist From Tcpdump
        [Arguments]    ${pcap_file_path}
        ${all_packets}=    load_pcap_file    pcap_file=${pcap_file_path}    tshark_path=${tshark_path}
        ...     luashark_path=${luashark_path}
        ...     command_template=${command_template_bip}
        ${filtered_packets}=    filter_packets_by_expression
        ...     filter_expression=nr-rrc.sib_TypeAndInfo_item == 3
        ${Blackcell_start}=   get_field_value_by_xpath    pdml_list=${filtered_packets}
        ...     xpath=.//nr-rrc.eutra_BlackCellList//nr-rrc.start
        ${len}=  get length  ${Blackcell_start}
        should be true   ${len}==0    Blackcelllist is found!

Get Sib 5 Periodicity from BIP
        [Arguments]    ${pcap_file_path}
        ${all_packets}=    load_pcap_file    pcap_file=${pcap_file_path}    tshark_path=${tshark_path}
        ...     luashark_path=${luashark_path}
        ...     command_template=${command_template_bip}
        ${filtered_packets}=    filter_packets_by_expression
        ...     filter_expression=nr-rrc
        ${si_periodicitys}=   get_field_value_by_xpath    pdml_list=${filtered_packets}
        ...     xpath=.//nr-rrc.type[@show='3']/../../../../nr-rrc.si_Periodicity
        ${len}=  get length  ${si_periodicitys}
        should be true   ${len}>=1    No si_periodicity value is found!
        ${si_periodicity}=   set variable    ${si_periodicitys[-1]}
        ${si_periodicity}=  convert to integer    ${si_periodicity}
        [Return]    ${si_periodicity}

adjust the HBTE attenuation value
    [Arguments]      ${value_0}    ${value_1}    ${value_2}    ${value_3}    ${value_4}
    [Documentation]
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_5}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_5}    value=${value_4}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_0}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_3}
    ${value_port_8}    attenuator.read_attenuation    port=${att_port_5}
    should be equal    ${value_port_8}    ${value_4}
    ${value_port_13}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_13}    ${value_0}
    ${value_port_14}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_14}    ${value_1}
    ${value_port_15}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_15}    ${value_2}
    ${value_port_16}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_16}    ${value_3}
    sleep    5s

adjust the HBTE attenuation value trunk
    [Arguments]      ${value_0}    ${value_1}    ${value_2}    ${value_3}    ${value_4}
    [Documentation]
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_8}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_8}    value=${value_0}
    attenuator.set_attenuation     port=${att_port_13}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_14}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_15}    value=${value_3}
    attenuator.set_attenuation     port=${att_port_16}    value=${value_4}
    ${value_port_8}    attenuator.read_attenuation    port=${att_port_8}
    should be equal    ${value_port_8}    ${value_0}
    ${value_port_13}    attenuator.read_attenuation    port=${att_port_13}
    should be equal    ${value_port_13}    ${value_1}
    ${value_port_14}    attenuator.read_attenuation    port=${att_port_14}
    should be equal    ${value_port_14}    ${value_2}
    ${value_port_15}    attenuator.read_attenuation    port=${att_port_15}
    should be equal    ${value_port_15}    ${value_3}
    ${value_port_16}    attenuator.read_attenuation    port=${att_port_16}
    should be equal    ${value_port_16}    ${value_4}
    sleep    5s

#connection
SSH Connect With Timeout
    [Arguments]    ${alias}
    Wait Until Keyword Succeeds    1min    10sec    SSH Connect   alias=${alias}

SSH Connect
    [Arguments]    ${alias}
    Run Keyword If    '${alias}'=='${ALIAS_gNB}'    csn.Connect to    hostname=${gNB_IP}    username=${gNB_SSH_NAME}
    ...     password=${gNB_SSH_PWD}     alias=${ALIAS_gNB}
    ...    ELSE IF    '${alias}'=='${ALIAS_eNB}'  csn.Connect to    hostname=${eNB_IP}    username=${eNB_SSH_NAME}
    ...     password=${gNB_SSH_PWD}     alias=${ALIAS_eNB}
    ...    ELSE IF    '${alias}'=='${ALIAS_UTE}'    csn.Connect to    hostname=${UTE_IP}    username=${UTE_USERNAME}
    ...     password=${UTE_PASSWORD}    alias=${ALIAS_UTE}
    ...    ELSE    Fail    Unknow alias

# start wireshark
Start eNB tcpdump
    [Arguments]    ${tcpdump_path}=${tcpdump_path}   ${eNBlogname}=${eNBlogname}    ${interface}=br1     ${alias}=eNB
    SSH Connect With Timeout    alias=${alias}
    csn.send command    command=tcpdump -s0 -i ${interface} -w ${tcpdump_path}/${eNBlogname} -vv    connection=${alias}

# stop wireshark
Stop and Save eNB tcpdump
    [Arguments]    ${eNBlogname}=${eNBlogname}       ${alias}=eNB
#    SSH Connect With Timeout    alias=${alias}
    Stop and download Logs for 743   logname=${eNBlogname}     connection=${alias}

Stop and download Logs for 743
    [Arguments]    ${logname}    ${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${tcpdump_path}/${logname}   local_path=${LOG_PATH}/${logname}
    ...    connection=${connection}
    sleep    3
    csn.disconnect    connection=${connection}

Close Wireshark on ute
    Conn.ConnectWithTimeout    alias=${ALIAS_UTE}
    csn.execute     command=ps -ef|grep -i wireshark    connection=${ALIAS_UTE}
    csn.send command    command=killall wireshark     connection=${ALIAS_UTE}
    Conn.Disconnect      alias=${ALIAS_UTE}
    sleep  2s

Huawei Mate X20 UE detach
    power_ue.UE Detach    ue_type=${ue_type}
