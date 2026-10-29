*** Settings ***

Documentation
...	    [Procedure]	        	    "NCDR Test Execution"
... 	[Date]		        	    "27-03-2024"
...	    [Author]	        	    "Malika"
...     [Scrum]                     "TRS VRF-2"
...     [Config_Comments]           "IPSEC should be established"
...     [Precondition]              "ENodeB should be integrated to Netact"


Resource         ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource         ${CURDIR}/../resources/common_keywords.robot


Library          taf.sbts.oam.coam.admin

Suite Setup     Setup Oamops
Suite Teardown   Teardown Oamops

*** Test Cases ***
[1][1.0] [1.0]_Verification_of_Multiple_iterations_of_BTS_Upgrade_and_Rollback
     perform software upgrade

*** Keywords ***

Perform Software Upgrade
   FOR    ${i}    IN RANGE    0	10
     Setup Oamops       dut=mplane      alias=mplane
     taf.sbts.oam.coam.admin.update_software   sw_package=/home/ute/builds/${profile}   should_activate=True   timeout=2600
     taf.sbts.oam.coam.admin.get_cell_list    timeout=100   connection=default   detailed_output=False
     BuiltIn.Sleep  800
     Verify Ipsec Tunnels Status
     Check on-air status
     Perform Recommissioning     type=delta      delta_file=${ssh_disabled}        skip_parameter_relation_errors=True     timeout=300
     Perform Recommissioning     type=delta      delta_file=${ssh_enabled}        skip_parameter_relation_errors=True     timeout=300
     verify Unexpected alarms should not exist
     Setup Oamops       dut=mplane      alias=mplane
     taf.sbts.oam.coam.admin.rollback_software    detailed_output=False              timeout=2600
     BuiltIn.Sleep  900
     Teardown Oamops        alias=mplane
     Setup Oamops
   END

verify Unexpected alarms should not exist
    Verify Alarm    unexpected_alarm=${unexpected_alarm}        should_exist=${False}

Check on-air status
    Verify Bts Status        should_be_onair=${True}

