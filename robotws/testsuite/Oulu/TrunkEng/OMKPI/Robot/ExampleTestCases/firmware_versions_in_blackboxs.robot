*** Settings ***
Documentation
...    Author:      Terhi Talvitie
...    Contact:     I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.BlackBoxChecks

Suite Setup         Common Suite Setup
Suite Teardown      Common Suite Teardown


*** Test Cases ***
Firmware_versions_in_blackbox
    [Documentation]  Get Firmware versions from blackbox-file from SMOD and BBMOD units
    Run Keyword And Continue On Failure   Get Bts Configs
    Run Keyword And Continue On Failure   Get Blackbox File Content From Bts   before
