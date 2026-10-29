*** Settings ***
Documentation
...     [Date]                      "22-03-2024"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Procedure]                 "Ipsec Max Tunnels long run profile"
...     [Function_Hash_Tags]        "Ipsec"


Variables       ta_e2e_bts_trs_fw
Library		    ${CURDIR}/../resources/egate_library.py
Resource        ${CURDIR}/../resources/Common_Traffic_Mirroring.robot
Resource        ${CURDIR}/resources/ipsec_ncdr_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Test Cases ***
[1]Verify anti-replay functionality for window size by setting different values for IPV6 over IPV4 tunnel and IPV6 over IPV6 tunnel_ASIL
	Perform Recommissioning     type=delta        delta_file=${ipsec_configuration}
    Install RAN sharing ipsec certs
    Get Ipsec Tunnels Status
    Sleep     60
    Configure IPsec and verify status
    Fetch the uptime
    M Plane test
	Get Ipsec Tunnels Status
    Configure 8128 configuration and verify no IPsec failure alarms are present
	Attach UE and send ul dl traffic
	Jumbo frame verification
    Verify ARW functionality
	Check the ipsec tunnels after ike and sa rekey
    Get Ipsec Tunnels Status
    Perform three operation loop after every 5 mins
    Stop traffic and detach UE
	Delta Modification
    Fetch the uptime
