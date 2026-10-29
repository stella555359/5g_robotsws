*** Settings ***
Documentation
    ...     [Procedure]             "The test case is to verify maximum VLANIF IPIF BFD IPSEC CERT CRL X2 Xn config
    ...                              as part of PET Testing"
    ...     [Date]                  "20-08-25"
    ...     [Author]                "Strikers"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "PET"
    ...     [Feature_ID]            "PET"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "PET_ASIM_STRIKERS_10.71.253.167_10.71.253.162"
	...     [Config]    			"No BFD configurations should have the preloaded scf as BFD configuration are cretaed by delta for this case"

Resource          ${CURDIR}/../resources/Common_BFD.robot
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Resource          ${CURDIR}/resources/CommonKeywords_PET_ASIM.robot
Library           random


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND	    Teardown Oamops


***Test Cases***
[1]Max_VLANIF_IPIF_IPSEC_BFD_CMP_CRL_Verification
#Configure max VLAN IPIF IPRT IPRTv6 IPsec on BTS via delta comm
    Perform Commissioning    scf_file=${PET_ASIM_Full_config}    verify_bts_status=False
    ...                      timeout=600
    Sleep   750
    Verify Alarm    faultid=6450    should_exist=${False}

#Add routes and required IPsec files to VM and start IPsec on VM
    Add routes IPsec conf files and start IPsec on VM

#Configure certificate in BTS if using cert as mode of auth for IPsec
    Certificate Configure       operation=restore_vendor_certificate
    Sleep   30
    Certificate Configure       operation=install_certificate       cert_file=${Ipsec_Cert}        cert_type=BtsTrustChain
    ...     cert_format=P12     password=${Ipsec_Cert_Password}     timeout=300

#Enable IPsec on BTS
    Perform Recommissioning     type=param      param_path=IPSECC-1:ipSecEnabled    operation=update    value=true      timeout=300

#Wait for few minutes for all tunnels to come up
    Sleep   300

#Fetch IPsec status and verify that all tunnels are up
    Get Ipsec Tunnels Status
#Verify IKE authentication failure. (61644)/Alarm not present
    Verify Alarm    faultid=61644    should_exist=${False}

#Verify Dead Peer Detected. (61030)/Alarm not present
    Verify Alarm    faultid=61030    should_exist=${False}

#Verify IKEP SA failure. (61645)/Alarm not present
    Verify Alarm    faultid=61645    should_exist=${False}

#Verify IPSec SA failure. (61646)/Alarm not present
    Verify Alarm    faultid=61646    should_exist=${False}

#Stop IPsec on VM and verify if DPD alarms are generated
    Run     sudo ipsec stop
    Sleep   200
    Verify Alarm    faultid=61030    occurrences=270    should_exist=True
#Restart IPsec on VM and verify above steps and no diagnostic alarm raised
    Run     sudo ipsec start
    Sleep   300
    Verify Alarm    faultid=61030    should_exist=${False}
    Verify Alarm    faultid=6450    should_exist=${False}

#Verify ping test success of IPv4 and IPv6 address
    Verify ping test success of IPv4 address
    Verify ping test success of IPv6 address

#BFD feature verfication
    Start All BFD session on VM
    Verification of Egress Alarm raise and clear
    Verification of Ingress Alarm raise and clear

#max cert crl validation
    Restore all Certificate
    Perform Recommissioning     type=delta      delta_file=${cmp_update}        skip_parameter_relation_errors=${True}      timeout=300
    Sleep   50
    Certificate Configure     operation=install_certificate     cert_file=${Ipsec_Cert}    cert_type=BtsTrustChain     cert_format=P12
    ...     password=${Ipsec_Cert_Password}
    Sleep   100
    Install Max CA/TA certs
    Configure and verify max crl


*** Keywords ***
Add routes IPsec conf files and start IPsec on VM
    Run     for i in {2116..2200}; do sudo ip link add link eth3 name eth3.$i type vlan id $i; done
    Run     for i in {16..100}; do j=$((i + 2100)); sudo ip a a 10.0.$i.1/24 dev eth3.$j; done
    Run     for i in {16..100}; do j=$((i + 2100)); sudo ip -6 a a fc00::$i:1/120 dev eth3.$j; done
    Run     for i in {2116..2200}; do sudo ip link set dev eth3.$i up; done
    Run     for i in {2601..2650}; do sudo ip link add link eth3 name eth3.$i type vlan id $i; done
    Run     for i in {101..150}; do j=$((i + 2500)); sudo ip a a 10.0.$i.1/24 dev eth3.$j; done
    Run     for i in {101..150}; do j=$((i + 2500)); sudo ip -6 a a fc00::$i:1/120 dev eth3.$j; done
    Run     for i in {2601..2650}; do sudo ip link set dev eth3.$i up; done
    Run     for n in {0..84}; do i=$((2 + n)); j=$((16 + n)); k=$((2116 + n)); sudo ip r a 10.0.6.$i via 10.0.$j.2 dev eth3.$k; done
    Run     for n in {0..49}; do i=$((87 + n)); j=$((101 + n)); k=$((2601 + n)); sudo ip r a 10.0.6.$i via 10.0.$j.2 dev eth3.$k; done
    Run     sudo chmod 777 /etc/ipsec.d/private
    Run     sudo cp ${CURDIR}/resources/certificates/cacerts/* /etc/ipsec.d/cacerts/
    Run     sudo cp ${CURDIR}/resources/certificates/certs/* /etc/ipsec.d/certs/
    Run     sudo cp ${CURDIR}/resources/certificates/private/* /etc/ipsec.d/private/
    Run     sudo cp /etc/ipsec.secrets /etc/ipsec_bkp.secrets
    Run     sudo cp ${CURDIR}/resources/certificates/ipsec.secrets /etc/ipsec.secrets
    Run     sudo cp /etc/ipsec.conf /etc/ipsec_bkp.conf
    Run     sudo cp ${CURDIR}/resources/certificates/ipsec.conf /etc/ipsec.conf
    Run     sudo ipsec restart