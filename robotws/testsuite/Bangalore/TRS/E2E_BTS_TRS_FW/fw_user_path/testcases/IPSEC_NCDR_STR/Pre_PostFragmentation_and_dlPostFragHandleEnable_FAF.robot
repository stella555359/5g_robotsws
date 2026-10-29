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
[1]EDA Verify Pre PostFragmentation and dlPostFragHandleEnable FAF
    Install RAN sharing ipsec certs
    Get Ipsec Tunnels Status
    Sleep     60
    Delta Modification
    Get Ipsec Tunnels Status
    Fetch the uptime
    M Plane test
	Attach UE and send ul dl traffic
	Verify CB009246 feature and check for alarms
	Send Pre fragmented traffic and Verify traffic
	Verify Post fragmented traffic
    Perform three operation loop after every 5 mins
    Stop traffic and detach UE
    Fetch the uptime