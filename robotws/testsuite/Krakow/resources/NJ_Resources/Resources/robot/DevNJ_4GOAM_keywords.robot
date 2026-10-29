*** Settings ***
Documentation
...    Note: Please DO NOT call functions in this file again, except some special functions. The suggsetion is to call
...          relevant  fuctions in DevNJ_sbts_keywords.py and DevNJ_ASIR_Selenium.py files.
...    Note: Please DO NOT call functions in this file again, except some special functions. The suggsetion is to call
...          relevant  fuctions in DevNJ_sbts_keywords.py and DevNJ_ASIR_Selenium.py files.
...    Note: Please DO NOT call functions in this file again, except some special functions. The suggsetion is to call
...          relevant  fuctions in DevNJ_sbts_keywords.py and DevNJ_ASIR_Selenium.py files.
...    author: Fuzeng Zhu
...    contact: fuzeng.zhu@nokia-sbell.com
...    Generic Robot keywords for 4G OAM.
Library    taf.ul.sc.tl_config.TestLineConfiguration
Library    taf.gnb.oam.coam.admin   WITH NAME  admin
Library    String
Library    OperatingSystem
Library    Collections
Library    DateTime
Library    taf.transport.ssh    WITH NAME    ssh
Library    ../python/DevNJ_eNB_rpc_client.py

Resource    taf/rfrl/common_resources/robot/coam.robot
Resource   ./DevNJ_DSS_keywords.robot
Resource   ./DevNJ_eNB_rpc_keywords.robot

*** Variables ***
${ADDRESS}    ${tl.test_pcs[1].default_ssh_connection_details.addr}
${PORT}       8270

*** Keywords ***

Perform eNB Full Commissioning
    [Documentation]  Perform eNB Full Commissioning
    ...
    ...    Arguments:
    ...    - _scf_file_:  SCF file path to perform
    ...    - _enb_webem_ip_:  eNB WebEM IP
    ...    - _timeout_: timeout for commission finished
    ...
    ...    Examples:
    ...    - Perform eNB Full Commissioning
    ...    | Perform eNB Full Commissioning | enb_webem_ip=172.30.1.10 | scf_file=/tmp/20200918-1011.xml |
    ...    Return value:
    ...    - None
    [Arguments]  ${enb_webem_ip}  ${scf_file}  ${timeout}=300
    Wait Until Keyword Succeeds    6x   5s    admin.Setup admin  bts_host=${enb_webem_ip}
    admin.perform_commissioning
    ...  scf_file=${scf_file}
    ...  skip_parameter_relation_errors=true
    ...  timeout=${timeout}
    [Teardown]  admin.Teardown admin

Perform Delta Commission On eNB
    [Documentation]    Perform Delta Commission On eNB, specifying WebEM IP of eNB,
    ...                a dictionary contains necessary parameters to replace in template file,
    ...                and SCF template file path.
    ...
    ...    Arguments:
    ...    - _enb_webem_ip_: eNB WebEM IP
    ...    - _dict_scf_para_rep_: Dictionary of key/value of the parameter to replace
    ...    - _delta_template_path_: Delta SCF template file path
    ...
    ...    Examples:
    ...    - Configure MOs and activate DSS on eNB
    ...    | ${dict_scf_para_rep} | create Dictionary | gnb_bts_id=3486 | gnb_cell_id=1 | enb_bts_id=34861 | enb_cell_id=2 | nr_cell_id=57114625
    ...    | Perform Delta Commission On eNB | enb_webem_ip=172.30.1.10 | dict_scf_para_rep=${dict_scf_para_rep}
    ...    ...  | delta_template_path=testsuite/OAM/Nanjing/Resources/python/delta_templates/enb_configure_and_activate_dss_template |
    ...
    ...    Return value:
    ...    - None
    [Arguments]    ${enb_webem_ip}  ${dict_scf_para_rep}  ${delta_template_path}
    ${delta_scf_path}  generate_scf_from_template   delta_template_path=${delta_template_path}  dict_scf_para_replace=${dict_scf_para_rep}
    Log To Console  delta xml path:${delta_scf_path}
    Teardown cOAM session
    Log To Console   Connect to eNB ${enb_webem_ip} ...
    Wait Until Keyword Succeeds    6x   5s    coam.connect to   bts_host=${enb_webem_ip}     name=cOAM
    ${convert_status}    coam_parameter.convert_delta_scf_xml_multi_operation  delta_xml_path=${delta_scf_path}
    Log To Console   delta_file:${convert_status['updated']}
    ${res}   coam_parameter.perform_scf_delta_commission  delta_file=${convert_status['updated']}  timeout=900  connection=cOAM
    [Teardown]  Teardown cOAM session

Reset eNB Configuration
    [Documentation]  Reset eNB Configuration, with eNB webem IP and an optional parameter timeout seconds
    ...
    ...    Arguments:
    ...    - _enb_webem_ip_: eNB WebEM IP
    ...    - _timeout_: timeout seconds for reset configuration
    ...
    ...    Examples:
    ...    - Reset eNB Configuration
    ...    | Reset eNB Configuration | enb_webem_ip=172.30.1.10 | timeout=900 |
    ...    Return value:
    ...    - None
    [Arguments]   ${enb_webem_ip}  ${timeout}=900
    Wait Until Keyword Succeeds    6x   5s    admin.Setup admin  bts_host=${enb_webem_ip}
    admin.Reset configuration    timeout=${timeout}
    [Teardown]  admin.Teardown admin

Perform eNB Full Commissioning via RPC
    [Documentation]  Perform eNB Full Commissioning Via RPC
    ...              Need to check test line configuration contains another eNB ute test pc item, eg. _test_pc_lte
    ...              Exmaple, in /home/ute/testline_configuration_5G/Nanjing/7_21_UTE5G035TL091/__init__.py
    ...
    ...              _test_pc = TestPc(default_ssh_connection_details=SshServiceDetails(addr='10.66.31.78',
    ...                                                              username='ute',
    ...                                                              password='ute'))
    ...
    ...             _test_pc_lte = TestPc(default_ssh_connection_details=SshServiceDetails(addr='10.66.31.79',
    ...                                                              username='ute',
    ...                                                              password='ute'))
    ...             _test_pcs = [_test_pc, _test_pc_lte]
    ...
    ...    Arguments:
    ...    - _scf_file_path_:  SCF file path to perform on eNB
    ...    - _timeout_: timeout for commission finished
    ...
    ...    Examples:
    ...    - Perform eNB Full Commissioning via RPC
    ...    | Perform eNB Full Commissioning via RPC | scf_file=/tmp/20200918-1011.xml | timeout=300
    ...    Return value:
    ...    - None
    [Arguments]  ${scf_file_path}  ${timeout}=300
    ${result}=        Run Keyword And Return Status    Variable Should Exist    ${tl.install_rpc}
    Return From Keyword If    ${result}==False

    Install eNB VM RPC Server
    ${prefix}  ${scf_file_name} =  string.Split String From Right  ${scf_file_path}  separator=/  max_split=${1}
    ${cur_datetime}    DateTime.Get Current Date   result_format=%Y_%m_%d_%H_%M_%S

    ${remote_scf_file_path}  set variable  /tmp/${cur_datetime}_${scf_file_name}
    Log To Console  Remote SCF Path: ${remote_scf_file_path}
    ssh.connect to    hostname=${ADDRESS}    username=${tl.test_pcs[1].default_ssh_connection_details.username}
    ...    password=${tl.test_pcs[1].default_ssh_connection_details.password}    alias=eNBRpcServer
    ssh.upload_file   local_path=${scf_file_path}   remote_path=${remote_scf_file_path}    connection=eNBRpcServer
    Wait Until Keyword Succeeds      ${timeout}s    30s    run_rpc_keyword    ${ADDRESS}    perform_enb_commissioning   ${remote_scf_file_path}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=eNBRpcServer
