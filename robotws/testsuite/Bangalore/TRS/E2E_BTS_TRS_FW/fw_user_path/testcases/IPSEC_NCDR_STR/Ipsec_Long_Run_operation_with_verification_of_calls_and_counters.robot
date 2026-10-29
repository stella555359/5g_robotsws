*** Settings ***
Documentation
...     [Date]                      "22-03-2024"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Procedure]                 "Ipsec Max Tunnels long run profile"
...     [Function_Hash_Tags]        "Ipsec"


Resource        ${CURDIR}/resources/ipsec_ncdr_common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Test Cases ***
[1] Ipsec_Long_Run_operation_with_verification_of_calls_and_counters
	Perform Recommissioning     type=delta        delta_file=${ipsec_configuration}
	Get Ipsec Tunnels Status
    Delta Modification
    Fetch the uptime
	Get Ipsec Tunnels Status
	Configure 8128 configuration and verify no IPsec failure alarms are present
	Verify CB009246 feature and check for alarms
    RDI_23955 coverage gap to check ESN 64 bit
    Attach UE and send ul dl traffic
    Perform three operation loop after every 5 mins
    Verify the counters
    Stop traffic and detach UE
	Perform Software Upgrade
    Fetch the uptime