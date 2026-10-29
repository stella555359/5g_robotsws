*** Settings ***
Documentation    This contains basic ute related keywords which are needed to run the Airphone TC from UTE.
...              :author Ashok Santhanam
Library    OperatingSystem
Library    taf.transport.ssh     WITH NAME    ssh

*** Variables ***
${NOKIA_PASS}              oZPS0POrRieRtu
${EGATE_CONFIG_DIR}        /airphone_cfg
${SETUP_CFG_DEF_FILE}      ${EGATE_CONFIG_DIR}/${SETUP_CFG_NAME}
${AP_XML_DEF_FILE}         ${EGATE_CONFIG_DIR}/${AP_XML_NAME}
${SETUP_CFG_CUST_FILE}     ${WTS_CFG_PATH}/${SETUP_CFG_NAME}
${AP_XML_CUST_FILE}        ${WTS_CFG_PATH}/${AP_XML_NAME}
@{HO_eth3_VM_interfaces}        10.0.1.99    10.0.1.107    10.0.1.108    10.0.1.109    10.0.1.110    10.0.1.111
...                             10.0.1.112    10.0.1.114    10.0.1.116    10.0.1.115    10.0.1.118    10.0.1.119
...                             10.0.1.120    10.0.1.121    10.0.1.122    10.0.1.123    10.0.1.124    10.0.1.125
...                             10.0.1.126    10.0.1.127     10.0.1.128    10.0.1.129    10.0.1.130    10.0.1.131
...                             10.0.1.132    10.0.1.133    10.0.1.134    10.0.1.135    10.0.1.136    10.0.1.137
...                             10.0.1.138
@{HO_eth4_VM_interfaces}        10.0.2.3      10.0.2.4      10.0.2.5      10.0.2.6    10.0.2.7    10.0.2.8
@{HO_eth3_InterRatHO_interfaces}  10.0.1.139    10.0.1.140    10.0.1.141    10.0.1.142    10.0.1.138
@{HO_eth4_InterRatHO_interfaces}   10.0.2.2    10.0.2.9    10.0.2.10
@{HO_eth3_VM_LOKI_interfaces}    10.0.1.139    10.0.1.140    10.0.1.141    10.0.1.61    10.0.1.142
${bsr_path}                /home/ute/workspace/bsr_package

*** Keywords ***
Configure VM interfaces
    Run and return rc and output     sudo ip addr add 10.0.1.131/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.132/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.133/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.134/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.135/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.136/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.99/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.121/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.1.137/24 dev eth3

Modify UTE SCTP Timeout
    [Arguments]    ${AP_IP}    ${AP_Username}    ${AP_Password}    ${AP_Update_Flag}=True
    [Documentation]    The sack timeout in the WTS VM and AP ASIK must be
    ...                configured before cell setup. This aims to prevent delayed messaging between AirPhone
    ...                and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    Run and return rc and output     sudo sysctl -w net.sctp.sack_timeout=20
    Run and return rc and output     sudo sysctl -w net.sctp.rto_min=100
    Run and return rc and output     sudo sysctl -w net.sctp.rto_initial=200
    Run and return rc and output     sudo sysctl -w net.sctp.rto_max=800
    Run Keyword If    '${AP_Update_Flag}' == 'True'    Modify UTE SCTP Timeout on AP    ${AP_IP}    ${AP_Username}
    ...    ${AP_Password}

Modify UTE SCTP Timeout on AP
    [Arguments]    ${AP_IP}    ${AP_Username}    ${AP_Password}
    ssh.Connect To    ${AP_IP}    ${AP_Username}    ${AP_Password}
    ...               alias=AP
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...               sysctl -w net.sctp.rto_min=200 &&
    ...               sysctl -w net.sctp.rto_initial=200 &&
    ...               sysctl -w net.sctp.rto_max=800
    ssh.Execute       ${command}    AP
    [Teardown]    ssh.Disconnect    AP

File Should Be Present
    [Arguments]    ${file_name}    ${timeout}=5 sec    ${retry}=1 sec
    [Documentation]    This Keyword  checks for the ${timeout} time which will retried every ${retry} value
    ...                Last Modified : Gopalakrishnan N (gopalakrishnan.n@nokia.com)
    ...                Date Modified : 14 -May- 2020
    Wait Until Keyword Succeeds    ${timeout}    ${retry}    File Should Exist    ${file_name}

Teardown Edaemon And Egate Process
    [Documentation]    This Keyword  tears down all aliases created fo Edaemon and Egate aliases created
    ...                using ute_wtssim
    ...                Last Modified : Gopalakrishnan N (gopalakrishnan.n@nokia.com)
    ...                Date Modified : 14 -May- 2020
    Run Keyword And Ignore Error    teardown_all_aliases_for_edaemon
    Run Keyword And Ignore Error    teardown_all_aliases_for_egate

Prepare Environment Based On Run Type
    [Documentation]    This keyword configures the IP needed for WTS functioning
    ...                It also copies setup.cfg and airphone.xml files to /opt/wts/lastest
    ...                By default, files from /airphone_cfg path will be copied
    ...                If user needs custom files, cfg_type variable should be set to custom
    ...                RUN_TYPE is defined in testsuite/AIRPHONE/Resources/Variables/Common_Variables.robot
    ...                and indicates the type of configuration : Ex: FDD/TDD, Full Stack/L1ByPass etc
    ...                Modified Date: 02-Jun-2020
    ...                Last Modified by: ramya.2.k@nokia.com
    [Arguments]    ${cfg_type}=default
    Configure VM interfaces
    Download Default Configuration From WTS
    Run Keyword If     '${cfg_type}' != 'default'   Overwrite With Configuration From Feature Folder

Download Default Configuration From WTS
    [Documentation]    This keyword copies default setup.cfg and airphone.xml files
    ...                from /airphone_cfg to /opt/wts/lastest
    ...                Modified Date: 02-Jun-2020
    ...                Last Modified by: ramya.2.k@nokia.com
    Run    rm -f ${WTS_INSTALL_PATH}/AirPhoneConfig*.xml
    Run    rm -f ${WTS_INSTALL_PATH}/basic*.xml
    Setup Edaemon    edaemon_port=${edaemon_port}    tool_dir=${WTS_INSTALL_PATH}    alias=edaemon
    Start Edaemon Process    alias=edaemon
    Setup Egate    egate_port=${egate_port}    tool_dir=${WTS_INSTALL_PATH}
    Start Egate Process
    Execute Egate Command    cp ${SETUP_CFG_DEF_FILE} ${WTS_INSTALL_PATH}    pass_regexp=Copied file
    File Should Be Present    file_name=${WTS_INSTALL_PATH}/${SETUP_CFG_NAME}
    Execute Egate Command    cp ${AP_XML_DEF_FILE} ${WTS_INSTALL_PATH}    pass_regexp=Copied file
    File Should Be Present    file_name=${WTS_INSTALL_PATH}/${AP_XML_NAME}
    [Teardown]    Teardown Edaemon And Egate Process

Create BSR Package Folder on VM
    [Documentation]    This keyword copies BSR Package files for P1 from entity test repo
    ...                to a new directory on VM
    [Arguments]    ${bsr_path}
    ${WORKSPACE}    Get Environment Variable    WORKSPACE
    Run    rm -rf ${bsr_path}
    Run    mkdir ${bsr_path}
    Run    cp ${WORKSPACE}/entitytests/tools/scripts/misc/BSR_Package_P1/* ${bsr_path}/

Overwrite With Configuration From Feature Folder
    [Documentation]    This keyword copies custom setup.cfg and airphone.xml files to /opt/wts/latest
    ...                Custom files should be stored in <Feature_folder>/cfg path
    ...                ${WTS_CFG_PATH} should be set to <Feature_folder>/cfg in the test suite/ test case.
    ...                Modified Date: 02-Jun-2020
    ...                Last Modified by: ramya.2.k@nokia.com
    Copy File And Display Warning    ${SETUP_CFG_CUST_FILE}     ${WTS_INSTALL_PATH}
    ...    Using default cfg file since ${SETUP_CFG_CUST_FILE} does not exist
    Copy File And Display Warning    ${AP_XML_CUST_FILE}     ${WTS_INSTALL_PATH}
    ...    Using default xml file since ${AP_XML_CUST_FILE} does not exist

Copy File And Display Warning
    [Arguments]    ${src}    ${dst}    ${msg}=File ${src} does not exist
    ${status}    Run Keyword And Return Status    File Should be Present    ${src}
    Run Keyword If    ${status}    Run    cp ${src} ${dst}
    ...    ELSE    Log    ${msg}    WARN

Update Config File in WTS
    [Documentation]    This keyword copies the input config file to /opt/wts/latest
    ...                Filename will be set to basic_fullstack_nsa_call_tdd_cmwv.cfg or basic_fullstack_nsa_call_fdd_cmwv.cfg
    ...                based on ${RUN_TYPE}
    ...                Modified Date: 02-Jun-2020
    ...                Last Modified by: ramya.2.k@nokia.com
    [Arguments]    ${file}
    Run    cp ${file} ${WTS_INSTALL_PATH}/${SETUP_CFG_NAME}

Configure VM interfaces for handover
    FOR    ${ip}    IN    @{HO_eth3_VM_interfaces}
         Run and return rc and output     sudo ip addr add ${ip}/24 dev eth3
    END
    FOR    ${ip}    IN    @{HO_eth4_VM_interfaces}
         Run and return rc and output     sudo ip addr add ${ip}/24 dev eth4
    END

Configure Inter RAT handover interfaces
    Configure VM interfaces for handover
    FOR    ${ip}    IN    @{HO_eth3_InterRatHO_interfaces}
         Run and return rc and output     sudo ip addr add ${ip}/24 dev eth3
    END
    FOR    ${ip}    IN    @{HO_eth4_InterRatHO_interfaces}
         Run and return rc and output     sudo ip addr add ${ip}/24 dev eth4
    END

Configure LOKI interfaces
    Configure VM interfaces for handover
    FOR    ${ip}    IN    @{HO_eth3_VM_LOKI_interfaces}
         Run and return rc and output     sudo ip addr add ${ip}/24 dev eth3
    END
    FOR    ${ip}    IN    @{HO_eth4_InterRatHO_interfaces}
         Run and return rc and output     sudo ip addr add ${ip}/24 dev eth4
    END

Configure Custom eth3 interfaces
    [Arguments]    ${Custom_eth3_interfaces}=${EMPTY}
    FOR    ${ip}    IN    @{Custom_eth3_interfaces}
         Run and return rc and output     sudo ip addr add ${ip}/24 dev eth3
    END

Configure Custom eth4 interfaces
    [Arguments]    ${Custom_eth4_interfaces}=${EMPTY}
    FOR    ${ip}    IN    @{Custom_eth4_interfaces}
         Run and return rc and output     sudo ip addr add ${ip}/24 dev eth4
    END
