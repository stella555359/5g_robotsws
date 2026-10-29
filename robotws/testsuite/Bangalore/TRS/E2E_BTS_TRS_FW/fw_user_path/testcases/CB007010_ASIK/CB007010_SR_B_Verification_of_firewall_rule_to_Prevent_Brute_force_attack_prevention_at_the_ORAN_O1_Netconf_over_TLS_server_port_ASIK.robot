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


Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for test teardown

*** Test Cases ***
[1][1.0] CB007010_SR_B_Verification_of_firewall_rule_to_Prevent_Brute_force_attack_prevention_at_the_ORAN_O1

    Perform Commissioning       scf_file=${CB007010_Configuration}   verify_bts_status=True     timeout=400
    ...     alias=default
    Sleep       400
    Certificate Configure   operation=install_certificate   cert_file=${ca_cert}    cert_type=BtsTrustChain
    ...             cert_format=P12     password=${cert_password}
    Sleep   200
    Run     sudo chmod 777 /etc/hosts
    Run     sudo echo ${NetConf_IP} >> /etc/hosts
    Run     sudo apt-get install -y netopeer2
    Check netopeer package is install or not
    Check netconf port
    Check ves port
    Verify ves functionality
    Run     sudo apt install hping3
    Verify Wireshark
    [Teardown]     Keywords to run at end

***Keywords***
Check netopeer package is install or not
      Run     chmod +x ${CURDIR}/resources/test.sh
        Run        sh ${CURDIR}/resources/test.sh

Check netconf port
    Setup Remote Access         remote_device=bts
    Execute Interactive Remote Command     
    ...     command=sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129     alias=default
    ${out1}=    Execute Interactive Remote Command     
    ...     command=netstat -alnp | grep 6513        alias=default
    Log To Console       ${out1}
    Should contain      ${out1}      LISTEN

Check ves port
    Run     pano start-ves > pano.log 2>&1 &
    Sleep   60
    Run     pano stop-ves
    ${out3}=     Run    grep -i LISTEN pano.log

    Should contain      ${out3}      LISTEN

Verify ves functionality
    Run     pano start-ves > pano.log 2>&1 &
    Sleep   60
    Perform Recommissioning     type=path_param      rat=all_rat     parameter=CRLH-1:usageEnabled
    ...     value=Disabled    timeout=300
    Sleep    120
    Run     pano stop-ves


    ${out4}=      Run       cat pano.log | Certificate_extension 2>&1 &

    Should contain      ${out4}     Certificate_extension

Verify Wireshark
    Traffic Capture Start         capture_device=vm_eth3_interface      alias=hping
    Sleep   60
    Run     sudo hping3 -V -S -I eth3 10.0.1.2 -p 6513 -i u200000 -c 300
    Sleep   120

    ${capture_file_name} =      Traffic Capture Stop        alias=hping
    Analyse pcap    pcap_filename=${capture_file_name}      analysis=hping     filter_file_name=${hping_Filter}

Keywords to run at end
    ${pid_ves}=    Run    ps -eaf |grep -i ves |awk '{ print $2 }'|head -1
    Run    sudo kill -9 ${pid_ves}






