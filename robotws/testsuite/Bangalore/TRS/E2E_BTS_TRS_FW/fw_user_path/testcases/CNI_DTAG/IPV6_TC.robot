*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CNI_118677"
...     [Funtion_Hash_Tags]     "Verification_of_Overlapping_of_Ipv6_address_with_other_operator_application address"
...     [Procedure]             "Verification_of_Overlapping_of_Ipv6_address_with_other_operator_application address"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_CNI_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***

[1]CNI118677_Verification_of_Overlapping_of_Ipv6_address_with_other_operator_application address

	Perform Commissioning    scf_file=${scf_ipv6}    skip_parameter_relation_errors=${True}      verify_bts_status=${False}     timeout=800
    Sleep    600
    Traffic Capture Start   capture_device=oam_device    mode=file   uplane_capturing=True
    ...   measurement_point=NE_Terminated    timeout=180    alias=CNI
    Sleep      30
    Perform Recommissioning     type=delta       delta_file=${ADD_RULE_v6}      skip_parameter_relation_errors=${True}      timeout=600
    Sleep    200
    Verify Addition Of Rule(1500) in BOARD
    Verify S1Link status is up
    Reset   operation=reset_rat    rat=lte
    Sleep       260
    ${filemode_capture}=    Traffic Capture Stop     mode=file     timeout=120      alias=CNI
    Verify Captured File_IPv6     ${filemode_capture}
    Sleep   300
    Perform Recommissioning     type=delta      delta_file=${DELETE_RULE_v6}      skip_parameter_relation_errors=${True}      timeout=600
    Sleep    300
    Verify Deletion Of Rule(1500) in BOARD
    Verify S1Link status is Down