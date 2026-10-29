*** Settings ***
Documentation
...     [Procedure]             "Split-A IPsec for eCPRI M plane Security with SW Vendor certificates on Dual Core"
...     [Author]                "Sahana TC"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 ". . . ."
...     [Feature_ID]            "CB008817-A-SR"
...     [Requirement ID]        ""
...     [Funtion_Hash_Tags]     "Security"
...     [Domain_Hash_Tags]      "Fronthaul IPsec"
...     [Validated_TestLine]    "2322,2204"
...     [Config]                ""
...     [Runtime param]         "bts_id is provided at run time."

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/resources/common_8817SR_keywords.robot

Suite setup    Run Keywords    setup oamops
...            AND    Setup Oamops     dut=chained_bts     alias=secondary
Suite Teardown     Run Keywords     Teardown oamops
...            AND    Teardown Oamops    dut=chained_bts    alias=secondary

*** Test Cases ***
[2]TC01_CB008817_Verify M plane traffic when actEcpriRuMPlaneSecurity config flag is set to RuProtectEnabled

    Run Keywords        Suite Setup Preconditions
#    Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${True}     timeout=1000     alias=default
    Login to sshenb and fronthaul and capture secondary
    Run Keywords     Suite Teardown Postconditions
