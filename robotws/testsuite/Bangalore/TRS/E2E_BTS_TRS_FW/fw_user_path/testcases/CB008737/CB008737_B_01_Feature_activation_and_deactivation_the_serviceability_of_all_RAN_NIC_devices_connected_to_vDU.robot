*** Settings ***
Documentation
...     [Author]                    "Shreya Choudhary"
...	    [Maintenance]		        "TRS I&V Tools Bangalore Team"
...     [Date]                      "25-07-2023"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...	    [Feature_ID] 	    	    "CB008737"
...     [Validated_TestLine]        "IAV-BLR-TL004"
...	    [Procedure]   		        "CB008737_B_01_Feature_activation_and_deactivation_the_serviceability_of_all_RAN_NIC_devices_connected_to_vDU"
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
[1]CB008737_B_01_Feature_activation_and_deactivation_the_serviceability_of_all_RAN_NIC_devices_connected_to_vDU
    Enable the feature flag with moc modification and verification
    Change the service account password		${VDU_USERNAME}		${VDU_PASSWORD}		${VDU_NEW_PASSWORD_1}
    Enable ssh tunnel with true state
    SSH login to service user
    Get serviceuser session list and operation history
    Change the service account password		${VDU_USERNAME}		${VDU_PASSWORD}		${VDU_NEW_PASSWORD_2}
    SSH login to service user
    Disable the feature flag
    Enable ssh tunnel with false state
    Run keyword and Expect Error     *Connection timed out thrown*     SSH login to service user
    Enable the feature flag
    SSH login to service user
