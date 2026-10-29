*** Settings ***
Documentation
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case is planned to check Ipsec tunnel status and corresponding alarms are rasied and cleared as expected"
...     [Date]      "20-03-24"
...     [Author]        "Chiranjeevi V "
...     [QC_Path]   "Root\Test_Sets\Trunk\VRF_BLR2\BB_TRS_VRF_ET\CRT\NF_Automated_Regression\TRSIV_NFTR_vRAN4.0"
...     [QC_ID]     "347014"
...     [Funtion_Hash_Tags] "SWN CLOUD"
...     [Feature_ID]            "CB010265"
...     [Validated_TestLine]    "trs-cran1 vCU"
...     [Requirements]  "WBTS_SEC_55225;WBTS_SEC_61952"


Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/resources/CB010265_common_keyword.robot

Suite Setup     Setup Oamops    dut=vcu_user    alias=vcu
Suite Teardown  Run Keywords    Setup Oamops    dut=vcu_user      alias=vcu   AND     Collect Snapshot
...     dut=vcu_user  operation_timeout=300   alias=vcu   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vcu_user     alias=vcu


*** Test Cases ***
[1][2.0] TRS_Security-IPSec_Alarms-RP000356
    Perform Commissioning      scf_file=${vcu_CB010265_base_scf_1}      timeout=300      dut=vcu_user    alias=vcu

    Triger CMP IR to install certificates on vCU    RSA     ECDSA

    Restore default certificates and check ipsec status

    Verify alarms should not exist in vCU

    Triger CMP IR to install certificates on vCU    RSA     ECDSA

    Check Ipsec tunnel status in vCU

    Verify alarms should not exist in vCU

    Delete and configure different certificates with Alarm verification

*** Keywords ***
Delete and configure different certificates with Alarm verification
    Run     sudo ip a d 10.0.11.1/24 dev eth7
    Sleep   30
    Wait Until Keyword Succeeds     20 min      30 sec    Verify Alarm    alias=vcu    faultid=61030    should_exist=${True}    dut=vcu_user
    Run     sudo ip a a 10.0.11.1/24 dev eth7
    Wait Until Keyword Succeeds     20 min      30 sec    Verify Alarm    alias=vcu    faultid=61030    should_exist=${False}    dut=vcu_user
    Certificate Configure   dut=vcu_user     operation=restore_vendor_certificate      alias=vcu
    Perform Commissioning      scf_file=${Configure_wrong_certificate}      timeout=300      dut=vcu_user
    ...     alias=vcu
    Sleep   30
    Certificate Configure   dut=vcu_user    operation=install_cmp_certificate     timeout=120
    ...     key_pool_type=${keypoolType}  alias=vcu
    Sleep   30
    Verify Alarm    alias=vcu    faultid=61644    should_exist=${True}    dut=vcu_user
    Triger CMP IR to install certificates on vCU    RSA     ECDSA


