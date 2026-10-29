*** Settings ***
Documentation
...    copyright: Nokia

Library      taf.collectors.pmcounters
#Library      counters_vdu.py

***Keywords***

Collect_coam_vdu_pm_counters
    ${oam_vm}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=Nokia@123
    create Coam VDU PM collector
    ...  name=gnb_pm_counters
    ...  webservice=${oam_vm}
    ...  for_last=5 minutes
    ...  intervals=5
    taf.collectors.pmcounters.setup_collectors
    ...  names=gnb_pm_counters
    taf.collectors.pmcounters.collect_collectors
    ...  names=gnb_pm_counters
    taf.collectors.pmcounters.teardown_collectors
    ...  names=gnb_pm_counters
