*** Settings ***
Documentation
...     [Procedure]                    "Verification_of_concurrent_support_of_cpri_and_ecpri_Rus_confiruation"
...     [Author]       				   "jyotsna"
...     [Maintenance]                  "TRS I & V Tools Bangalore Team"
...     [QC_Path]                      "QC_Path in Test Plan"
...     [QC_ID]                        "QC_ID in Test Lab for reporting"
...     [Feature_ID]                   "CB009420"
...     [Funtion_Hash_Tags]            "checking configurations"
...     [Validation_status]            "Validated and Passed"
...     [Validated_TestLine]           "ASIM_TL001_10.58.143.122"

#Force Tags          CA_E2ET_BTSTRSPZ        SBTS00        [SBTS23R1]     RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT
Force Tags       CLOUD_R4P  CA_E2ET_BTSTRSPZ        SBTS00        [SBTS23R1]     RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops

*** Variables ***
${connection}       config_check
${cmd_exe}      ifconfig -a  | grep rfoe2

*** Test Cases ***

[1][1.0] TRS_Management Plane Connection Establishment between RU and RAU
#[1][1.0] TRS_Verification of concurrent support of cpri and ecpri Rus confiruation
   Login to FCT Board
   Login to baseband ssh
   Login netns componet inside the baseband where ports are enabled
   check user configured vlans
   Verify the RADIO IP’s

*** keywords ***
Login to FCT Board
    Setup Remote Access     remote_device=bts     alias=${connection}

Login to baseband ssh
    Execute Interactive Remote Command     command=bsh 1:1    alias=${connection}

Login netns componet inside the baseband where ports are enabled
    Execute Interactive Remote Command     command=ip netns exec radions bash     alias=${connection}

check user configured vlans
    ${output}     Execute Interactive Remote Command     command=${cmd_exe}      alias=${connection}
    Should Not Be Empty    ${output}

Verify the RADIO IP’s
    ${output}     Execute Interactive Remote Command     command=cat /ffs/run/config/FRIps.txt    alias=${connection}
    Should Not Be Empty    ${output}
