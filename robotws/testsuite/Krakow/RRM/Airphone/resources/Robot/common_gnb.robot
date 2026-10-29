*** Settings ***

Documentation
...   author: Mateusz Pajor
...   contact: mateusz.pajor@nokia.com
...   description:  Common Robot keywords for gNB

Library    taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.collectors.snapshot  WITH NAME    snapshot
Library    taf.collectors.core      WITH NAME    core
Library    taf.transport.ssh        WITH NAME    ssh
Library    testsuite.Krakow.RRM.Airphone.resources.Python.common_gnb  WITH NAME  common_gnb
Library    testsuite.Krakow.RRM.Airphone.resources.Python.sw_config_modifier.SwConfigModifier


*** Keywords ***
Collect Coam Snapshot
    [Arguments]        ${gnb_id}=0    ${name}=gnb_coam_snapshot     ${coverage}=Full    ${force}=0     ${timeout}=180
    ...                ${port}=443    ${target_dir}=${OUTPUT_DIR}
    [Documentation]    Collects the snapshot files to OUTPUT_DIR
    ...                Creation Date: 18.01.2021
    ...                Modified Date:
    ...                Last Modified by: mateusz.pajor@nokia.com

    ${webservice}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...  port=${port}
    snapshot.Create SBTS Snapshot Collector
    ...  name=${name}    webservice=${webservice}    coverage=${coverage}
    ...  force=${force}    timeout=${timeout}
    core.setup collectors    names=${name}
    core.collect collectors    names=${name}    target_dir=${target_dir}
    core.teardown collectors    names=${name}

Collect Swconfig From Module
    [Arguments]    ${host}=${GNB_IP}    ${user}=${NOKIA_LOGIN}    ${pass}=${NOKIA_PASS}    ${file_name}=swconfig.txt
    ssh.Connect To    ${host}    ${user}    ${pass}
    ssh.Download file    /rom/swconfig.txt    ${OUTPUT_DIR}/${TEST NAME}/${file_name}
    ssh.Disconnect

Add IPs On VM
    common_gnb.Add Ip Addr On Vm    ip_addr=10.0.1.1/24      interface=eth3
    common_gnb.Add Ip Addr On Vm    ip_addr=10.0.1.131/24    interface=eth3
    common_gnb.Add Ip Addr On Vm    ip_addr=10.0.1.132/24    interface=eth3
    common_gnb.Add Ip Addr On Vm    ip_addr=10.0.1.133/24    interface=eth3
    common_gnb.Add Ip Addr On Vm    ip_addr=10.0.1.134/24    interface=eth3
    common_gnb.Add Ip Addr On Vm    ip_addr=10.0.1.135/24    interface=eth3
    common_gnb.Add Ip Addr On Vm    ip_addr=10.0.1.136/24    interface=eth3
    common_gnb.Add Ip Addr On Vm    ip_addr=10.0.1.137/24    interface=eth3

Get Default SCF For UTE TL
    [Arguments]    ${local_dir_path}=${OUTPUT_DIR}/${SUITE_LOGS_DIR}
    ...            ${file_name}=${SCF_UTE_CLOUD_BASIC_FILE}
    [Documentation]      Download default UTE cloud SCF
    ...                  Set as global variable
    ...                  Creation Date: 14.05.2021
    ...                  Modified Date: 15.11.2021
    ...                  Last Modified by: szymon.lange@nokia.com

    admin.Connect To
    admin.Get Current Scf File
    ...    local_dir_path=${local_dir_path}
    ...    file_name=${file_name}
    set global variable    ${FULL_PATH_TO_DEFAULT_SCF}
    ...    ${OUTPUT_DIR}/${SUITE_LOGS_DIR}/${SCF_UTE_CLOUD_BASIC_FILE}
    [Teardown]    admin.Teardown

Reset Testline And Wait For Rmods
    ta5g_testline_management.Reset Testline
    ta5g_iphy.Check Radios Availability

Enable CP_UE logging
    [Arguments]    ${reboot}=${False}
    Add Flags To Swconfig
    ...    flags=${SW_CONFIG_ADDITIONAL}
    ...    filepath=GNB
    ...    host=${GNB_IP}
    ...    nokia_login=${NOKIA_LOGIN}
    ...    nokia_pass=${NOKIA_PASS}
    ...    reboot=${False}
    SSHLibrary.open connection    ${GNB_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    echo "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    run keyword if    ${reboot}    SSHLibrary.execute command     sync; reboot
    SSHLibrary.close connection
