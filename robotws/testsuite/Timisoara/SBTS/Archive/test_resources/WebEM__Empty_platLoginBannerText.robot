*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}    1800  #Time for SBTS to recovery.


*** Keywords ***
TC__WebEM__Empty_platLoginBannerText
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22352
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is created to perform changes on platLoginBannerText parameter.
    ...  Saving current SCF.
    ...  Reset configuration.
    ...  Connecting on VM via SSH.
    ...  Check platLoginBannerText parameter value.
    ...  Perform commissioning with the saved SCF.
    ...  Verify if all cells on SBTS are working.
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22352 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general

    Set Tags    CA-WebEM    OWNER-george.gheban@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS21

    Step1: Change platLoginBannerText parameter


Step1: Change platLoginBannerText parameter
    Log  Step1: Change platLoginBannerText parameter  console=true
    Log  Saving current SCF is ongoing...  console=true
    get_current_scf_file  local_dir_path=${OUTPUT DIR}  file_name=Current_SCF
    Log  Reset configuration will be performed!  console=true
    coam.reset_configuration  timeout=20m
    enable_ssh_access
    Log  Trying to connect on VM via SSH!  console=true
    ssh.connect to  ${PC_IP1}  ute  ute  alias=vm
    ${default_plat_banner_text}  Catenate  SEPARATOR=  \r\nYou are about to access a private system. This system is for t
    ...  he use\r\nof authorized users only. All connections are logged to the extent and\r\nby means acceptable by t
    ...  he local legislation. Any unauthorized access\r\nor access attempts may be punished to the fullest extent po
    ...  ssible\r\nunder the applicable local legislation.\r\n
    ${login_output}  ssh.execute  sshpass -p ${SMOD1}[PASSWORD] ssh 192.168.255.129 -l ${SMOD1}[USERNAME] & sleep 5 ; exit
    ...  connection=vm  timeout=30s
    ${text1}  Fetch From Right  ${login_output}  .\r\r\n
    ${platLoginBannerText}  Fetch From Left  ${text1}  \r\nLast login
    Log  platLoginBannerText parameter value is: ${platLoginBannerText}  console=true
    Should contain  ${platLoginBannerText}  ${default_plat_banner_text}
    coam.connect_to  bts_host=192.168.255.129  bts_port=443  username=Nemuadmin  password=nemuuser
    coam.perform_commissioning  scf_file=${OUTPUT DIR}/Current_SCF  should_activate=true  skip_parameter_relation_errors=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Log  All cells are Enabled!  console=true
    Remove File  ${OUTPUT DIR}/Current_SCF


TC Setup
    Common test setup
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common test teardown
