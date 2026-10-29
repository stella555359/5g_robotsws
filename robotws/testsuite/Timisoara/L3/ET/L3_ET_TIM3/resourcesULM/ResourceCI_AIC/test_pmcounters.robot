*** Settings ***
Resource   ../pmcounters.robot
Resource   ../ute_workarounds.robot

*** Test Cases ***
Test the retrieval of pm counters on AIC
    UTE Cloud Workaround
    # Bring Airphone TL to on Air status with Aic
    ${target_dir}=   Get testcase log directory
    Collect PM Counter on CU    target_dir=${target_dir}
    Collect PM Counter on VDU   target_dir=${target_dir}

