*** Settings ***
Documentation     [Procedure] "CB005820-A_Auto_Verification of ipsec tunnels authentication when weak sha1 EE cert
...		 installed and ipsecSHA1DigitalSignDisable is modified"
...               [Date] "Date of creation 28-11-2021"
...               [Author] "Pranitha"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB005820-B"
...               [Funtion_Hash_Tags] "CMP IPSEC"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] ASIK-9050
...               [Validation Date] 30-11-2021

variables         ta_e2e_bts_trs_fw
#Resource          setup/framework.robot
Library           Collections
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Library		      SSHLibrary


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]CB005820-Verification of ipsec tunnels authentication when weak sha1 EE cert installed and ipsecSHA1DigitalSignDisable is modified
	Preconditions
    Perform Commissioning       scf_file=${base_scf}     verify_bts_status=False     timeout=400     alias=default
	Sleep   180
    Perform Recommissioning      type=delta      delta_file=${CB005820_delta_config}         timeout=120
    Sleep    30
	Install SHA1 Cerificate on BTS and Strongswan
    Sleep     60
    Perform Recommissioning      type=param      param_path=IPSECC-1:ipSecEnabled   operation=update    value=true  timeout=120
    Sleep   20
	Verify IPSEC Tunnel Status     ESTABLISHED
	Disable IPSEC authentication with SHA1 digital signature certificates and Verify IPSEC Tunnel Status          SHA1
	Enable IPSEC authentication with SHA1 digital signature certificates and Verify IPSEC Tunnel Status           SHA1
	Install SHA256 Cerificate on BTS and Strongswan
	Disable IPSEC authentication with SHA1 digital signature certificates and Verify IPSEC Tunnel Status          SHA256
	Enable IPSEC authentication with SHA1 digital signature certificates and Verify IPSEC Tunnel Status           SHA256
	[TEARDOWN]       Postconditions

*** Keywords ***
Preconditions
    Run	   sudo ip link add link eth3 name eth3.1701 type vlan id 1701
    Run    sudo ip addr add 10.0.1.1/24 dev eth3.1701
    Run	   sudo ip link set dev eth3.1701 up
    Run    sudo ip addr add 10.0.1.32/24 dev eth3.1701
    Run    sudo ip addr add 10.0.1.33/24 dev eth3.1701
	Restore all Certificate


Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}
	Sleep     10

Verify IPSEC tunnel status
	[Arguments]    ${status}
	SSHLibrary.Open connection    ${config.Strongswan_ip}
	SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
    Execute Command     sudo ipsec start
    Sleep   40
    Execute Command     sudo ipsec restart
	Sleep  60
    ${stdout}=      Execute Command     sudo ipsec status
	Run Keyword If     '${status}' == 'ESTABLISHED'      Should Match Regexp		${stdout}	.*ESTABLISHED.*
	...     ELSE       Should Not Match Regexp		${stdout}	.*ESTABLISHED.*

Install SHA1 Cerificate on BTS and Strongswan
    Certificate Configure     operation=install_certificate		cert_file=${SHA1_cert}	   cert_type=BtsTrustChain
	...	   cert_format=P12	   password=Nokia1234!
	SSHLibrary.Open connection    ${config.Strongswan_ip}
	SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
	Execute Command     sudo rm -rf ${cert_PrivateKey}
	Execute Command     sudo rm -rf ${cert_Btspem}
	Execute Command 	sudo ln -s ${SHA1_cert_PrivateKey} ${cert_PrivateKey}
	Execute Command 	sudo ln -s ${SHA1_cert_Btspem} ${cert_Btspem}
	[TEARDOWN] 		SSHLibrary.Close Connection

Disable IPSEC authentication with SHA1 digital signature certificates and Verify IPSEC Tunnel Status
    [Arguments]		${algorithm}
	Perform Recommissioning        type=param           param_path=FEATCADM-1:ipsecSHA1DigitalSignDisable     operation=update
	...    value=true     timeout=300
	Sleep    60
	Run Keyword If    '${algorithm}'=='SHA1'     Verify IPSEC tunnel status       CONNECTING
    ...     ELSE       Verify IPSEC tunnel status       ESTABLISHED

Enable IPSEC authentication with SHA1 digital signature certificates and Verify IPSEC Tunnel Status
	[Arguments]		${algorithm}
	Perform Recommissioning        type=param           param_path=FEATCADM-1:ipsecSHA1DigitalSignDisable     operation=update
	...    value=false     timeout=300
	Sleep    60
	Run Keyword If    '${algorithm}'=='SHA256'     Verify IPSEC tunnel status       CONNECTING
	...     ELSE       Verify IPSEC tunnel status       ESTABLISHED

Install SHA256 Cerificate on BTS and Strongswan
    Certificate Configure     operation=install_certificate     cert_file=${SHA256_cert}     cert_type=BtsTrustChain
	...     cert_format=P12     password=nokia
	SSHLibrary.Open connection    ${config.Strongswan_ip}
	SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
	Execute Command     sudo rm -rf ${cert_PrivateKey}
	Execute Command     sudo rm -rf ${cert_Btspem}
	Execute Command 	sudo ln -s ${SHA256_cert_PrivateKey} ${cert_PrivateKey}
	Execute Command 	sudo ln -s ${SHA256_cert_Btspem} ${cert_Btspem}
	Execute Command 	sudo ipsec restart
	[TEARDOWN] 		SSHLibrary.Close Connection

Install SHA384 Cerificate on BTS and Strongswan
    Certificate Configure     operation=install_certificate     cert_file=${SHA384_cert}     cert_type=BtsTrustChain
	...     cert_format=P12     password=nokia
    SSHLibrary.Open connection    ${config.Strongswan_ip}
    SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
    Execute Command     sudo rm -rf ${cert_PrivateKey}
    Execute Command     sudo rm -rf ${cert_Btspem}
    Execute Command     sudo ln -s ${SHA384_cert_PrivateKey} ${cert_PrivateKey}
    Execute Command     sudo ln -s ${SHA384_cert_Btspem} ${cert_Btspem}
    Execute Command     sudo ipsec restart
    [TEARDOWN]      SSHLibrary.Close Connection

Install SHA512 Cerificate on BTS and Strongswan
    Certificate Configure     operation=install_certificate     cert_file=${SHA512_cert}     cert_type=BtsTrustChain
	...     cert_format=P12     password=nokia
    SSHLibrary.Open connection    ${config.Strongswan_ip}
    SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
    Execute Command     sudo rm -rf ${cert_PrivateKey}
    Execute Command     sudo rm -rf ${cert_Btspem}
    Execute Command     sudo ln -s ${SHA512_cert_PrivateKey} ${cert_PrivateKey}
    Execute Command     sudo ln -s ${SHA512_cert_Btspem} ${cert_Btspem}
    Execute Command     sudo ipsec restart
    [TEARDOWN]      SSHLibrary.Close Connection

Postconditions
	SSHLibrary.Open connection    ${config.Strongswan_ip}
	SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
	Execute Command     sudo ipsec stop
	[TEARDOWN] 		SSHLibrary.Close Connection