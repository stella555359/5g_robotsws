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
[1]Verification of IKE Re_Keying_IPSEC SA rekeying and Pre fragmentation in UL and DL_ASIL
	Perform Recommissioning     type=delta        delta_file=${ipsec_configuration}
    Sleep     60
    Toggle IPSec and check tunnel status
    Fetch the uptime
    M Plane test
	Get Ipsec Tunnels Status
    Configure 8128 configuration and verify no IPsec failure alarms are present
	Attach UE and send ul dl traffic
	Verify CB009246 feature and check for alarms
	Send Pre fragmented traffic and Verify traffic
    Verify ARW functionality
	Perform three operation loop after every 5 mins
    Stop traffic and detach UE
	Perform multiple Software Upgrade
    Fetch the uptime

*** Keywords ***

Perform multiple Software Upgrade
   [Documentation]       This test case keyword is to upgrade SW build
   FOR    ${upgrade_iter}    IN RANGE    0     ${upgrade_iter}
     Perform Software Download And Update       package=${profile}      activate_sw=true      update_timeout=3000
     Sleep    800
     Teardown Oamops
     Setup Oamops
     Get Ipsec Tunnels Status
	 M Plane test
     Get Ipsec Tunnels Status
     Attach UE and send ul dl traffic
     Rollback Software               timeout=1200       alias=default
     Sleep  1200
     Teardown Oamops
     Setup Oamops
     Get Ipsec Tunnels Status
    END