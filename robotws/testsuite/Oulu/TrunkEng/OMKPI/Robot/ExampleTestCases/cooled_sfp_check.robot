*** Settings ***
Documentation
...    Author:      Terhi Talvitie
...    Contact:     I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Library     testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.CooledSfpCheck

Suite Setup         Common Suite Setup
Suite Teardown      Common Suite Teardown


*** Test Cases ***
Check_cooled_sfp
    [Documentation]  Check which radios has cooled SFPs and check that they are in use.

    Run Keyword And Continue On Failure   Get Bts Configs
    Run Keyword And Continue On Failure   Check Cooled Sfps
