*** Settings ***
Documentation
...     [Author]                    "Shreya Choudhary"
...	    [Maintenance]		        "TRS I&V Tools Bangalore Team"
...     [Date]                      "25-07-2023"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...	    [Feature_ID] 		        "CB008737"
...     [Validated_TestLine]        "IAV-BLR-TL004"
...	    [Procedure]   		        "CB008737_B_09_Listing_the_open_SSH_ports_of_all_RANNIC_connected_to_vDU"
...     [Precondition]              "Service user password should be set for the first time & VDU should be up and running with all the pods"
...     [Config_Comments]           "Verification of service user functionality in VDU"
...     [Domain]                    "Cloud TL"
...     [Function_Hash_Tags]        "VDU"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB008737_common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops     dut=cbts     alias=vdu
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops     dut=cbts     alias=vdu



*** Test Cases ***
[1]CB008737_B_09_Listing_the_open_SSH_ports_of_all_RANNIC_connected_to_vDU
   Enable the feature flag
   Change the service account password		${VDU_USERNAME}		${VDU_PASSWORD}		${VDU_NEW_PASSWORD_1}
   Enable ssh tunnel
   Verify the feature parameter
   Perform vdu reset
   Login into the device
   Check the tunnel state
   Enable ssh tunnel
   SSH login to service user
   Check the session created
   Disable the feature flag
   Run keyword and Expect Error     *Connection timed out thrown*     SSH login to service user
