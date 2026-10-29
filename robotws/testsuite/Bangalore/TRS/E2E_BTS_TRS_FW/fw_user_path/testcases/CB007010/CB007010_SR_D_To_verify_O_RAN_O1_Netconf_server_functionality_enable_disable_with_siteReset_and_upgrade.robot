*** Settings ***
Documentation
...             [Author]         "Spandana N"
...             [Maintenance]    "TRS I & V Tools Bangalore Team"
...             [Scenario]       "To Upload Actual Configuration"

...             [Description]       To Upload Actual Configuration.



Library         ta_emss
Variables       ta_e2e_bts_trs_fw

Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_emssim.robot

Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for test teardown

*** Test Cases ***
[2]CB007010_SR_D_To_verify_O_RAN_O1_Netconf_server_functionality_enable_disable_with_siteReset_and_upgrade
    Perform Commissioning       scf_file=${BTS_Configuration}   verify_bts_status=True     timeout=400
    ...     alias=default
    Sleep       100
    Certificate Configure   operation=install_certificate   cert_file=${ca_cert}    cert_type=BtsTrustChain
    ...             cert_format=P12     password=${cert_password}
    Sleep   100
    Run     sudo chmod 777 /etc/hosts
    Run     sudo echo ${NetConf_IP} >> /etc/hosts
    Run     sudo apt-get install -y netopeer2
    Check netopeer package is install or not
    Check netconf port
    Check ves
    Reset BTS and verify Netconf
    Perform upgrade and verify Netconf
    Perform Config Reset and verify netconf failure
    [Teardown]     Keywords to run at end



*** Keywords ***
Check netconf port
    Setup Remote Access         remote_device=bts       alias=onap
    Execute Interactive Remote Command     
    ...     command=sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129     alias=onap
    ${out1}=    Execute Interactive Remote Command     
    ...     command=netstat -alnp | grep 6513        alias=onap
    Log To Console       ${out1}
    ${out}=     Run     netstat -alnp | grep 6513
    Should contain      ${out1}      LISTEN
    Teardown Remote Access  alias=onap

Check ves port
    Run     python3 /home/ute/ves/VES_simulator.py >${CURDIR}/ves.txt &
    Sleep  60
    ${out2}=     Run     netstat -na | grep 30417
    Should contain      ${out2}      LISTEN
    Log To Console       ${out2}
    Perform Recommissioning         type=delta          rat=lte         delta_file=${netconf_delta_file}
    ...            timeout=300
    Sleep   100
    ${out3}=     Run    grep -i "FSTSCH" /home/ute/ves/log_text.text
    Should contain      ${out3}      FSTSCH
    Log To Console       ${out3}
    [Teardown]     Keywords to run at end


Check ves
    Run     python3 /home/ute/ves/VES_simulator.py >${CURDIR}/ves.txt &
    Sleep  60
    ${out2}=     Run     netstat -na | grep 30417
    Should contain      ${out2}      LISTEN
    Log To Console       ${out2}
    Perform Recommissioning     type=delta      rat=5g     delta_file=${netconf_delta_file}     timeout=300
    Sleep    30
    ${out3}=     Run    grep -i "FSTSCH" /home/ute/ves/log_text.text
    Should contain      ${out3}      FSTSCH
    Log To Console       ${out3}
    [Teardown]     Keywords to run at end


Check netopeer package is install or not
    Run     chmod +x ${CURDIR}/resources/test.sh
        Run        sh ${CURDIR}/resources/test.sh


Reset BTS and verify Netconf
    Reset Bts   req_rat=lte     should_be_onair=False   wait_for=300
    Sleep   300
    Setup Remote Access         remote_device=bts       alias=onap
    ${out1}=    Execute Interactive Remote Command     
    ...     command=netstat -alnp | grep 6513        alias=onap
    Log To Console       ${out1}
    ${out}=     Run     netstat -alnp | grep 6513
    Should contain      ${out1}      LISTEN
    Teardown Remote Access  alias=onap

Perform upgrade and verify Netconf
    Perform software download and update     wft_profile=sbtstrunk_00      package=auto
    ...         activate_sw=true      update_timeout=900
    Sleep   900

    Setup Remote Access         remote_device=bts       alias=onap
    ${out1}=    Execute Interactive Remote Command     
    ...     command=netstat -alnp | grep 6513        alias=onap
    Log To Console       ${out1}
    ${out}=     Run     netstat -alnp | grep 6513
    Should contain      ${out1}      LISTEN
    Teardown Remote Access  alias=onap


Perform Config Reset and verify netconf failure
    Reset   operation=reset_configuration   remove_operator_certificates=False
    ...     remove_user_account_credentials=False       resetType=ConfigurationWithDNRSW        detailed_output=False
    Sleep   120

Keywords to run at end
    ${pid_ves}=    Run    ps -eaf |grep -i ves |awk '{ print $2 }'|head -1
    Run    sudo kill -9 ${pid_ves}


