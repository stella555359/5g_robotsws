*** Settings ***
Documentation
...            Main file to import as resource for vran deployment
...            Keywords for suite and test setup
...            author:       Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...            maintainer:   Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...
...            Supported user flags for tests execution:
...            -v skip:config      Skipping configuration upload in Suite/Test setup
...            -v skip:snapshot    Skipping Snapshot collection in Test teardown
...
...            Mandatory keywords to run in test suite:
...            Suite Setup       Testline Setup
...            Suite Teardown    Testline Teardown
...            Test Setup        Test Case Setup
...            Test Teardown     Test Case Teardown

Library     taf.gnb.oam.coam.vdu.interface.vdu  WITH NAME  vdu
Library     taf.gnb.oam.coam.cu.interface.cu  WITH NAME  vcu
Library    taf.gnb.oam.coam.vdu       WITH NAME    coam_vdu
Library    taf.gnb.oam.coam.cu        WITH NAME    coam_vcu
Library    ute_fsmaccess
Library    ute_async
Resource   taf/rfrl/cbts/interfaces.robot

*** Keywords ***
Import additional VRAN variables
    Set suite variable  ${NAMESPACE_CU}  ${tl.cloud_hostings[0].namespace}
    Set suite variable  ${NAMESPACE_DU}  ${tl.cloud_hostings[1].namespace}
    Set suite variable  &{MASTER_CU}
    ...  hostname=${tl.cloud_hostings[0].master_node.ssh_connection_details.addr}
    ...  username=${tl.cloud_hostings[0].master_node.ssh_connection_details.username}
    ...  password=${tl.cloud_hostings[0].master_node.ssh_connection_details.password}
    ...  alias=cu_master
    Set suite variable  &{MASTER_DU}
    ...  hostname=${tl.cloud_hostings[1].master_node.ssh_connection_details.addr}
    ...  username=${tl.cloud_hostings[1].master_node.ssh_connection_details.username}
    ...  password=${tl.cloud_hostings[1].master_node.ssh_connection_details.password}
    ...  alias=du_master
    Set suite variable  &{OAM_CU}
    ...  host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...  secure=${True}
    ...  alias=cu_admin
    Set suite variable  &{OAM_DU}
    ...  host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...  port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...  username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...  secure=${True}
    ...  connection_name=du_admin
    Set suite variable  ${RRH_VLAN}  ${tl.ues[0].preferred_vlan_id}
    Set suite variable    ${AP_IP}    192.168.200.1
    ${FHUC_VLANS}=  Get variable value  ${tl.gnbs[0].dus[0].fhuc_vlans}  ${None}
    Set suite variable  ${FHUC_VLANS}
    Set suite variable  ${VCU_MASTER_IP}   ${OAM_CU}[host]
    Set suite variable  ${VDU_MASTER_IP}   ${OAM_DU}[host]

Create Suite Scope Variables
    [Documentation]    Creates default suite scope variables.
    ...                Prepare vCU, vDU and ap available suite variables:
    ...                VCU_MASTER_IP - 192.168.100.129, VDU_MASTER_IP - 192.168.255.129
    ...                NAMESPACE_CU and NAMESPACE_DU
    ...                Arguments:
    ...                - ``log_dir``: Directory for suite logs, Default: ``$\{OUTPUT DIR\}/Logs/Run_[date]_[time]/``
    [Arguments]    ${log_dir}=${Empty}
    Run Keyword If    '${log_dir}' == ''
    ...    Set Suite Variable    ${SUITE_log_dir}    ${OUTPUT DIR}/Logs/
    ...    ELSE    Set Suite Variable    ${SUITE_log_dir}    ${log_dir}
    ${tl_var_exists}    Run Keyword And Return Status    Variable Should Exist    ${tl}
    Import additional VRAN variables
    @{collectors}    Create List
    Set Suite Variable    ${SUITE_TAF_collectors}    ${collectors}
