*** Settings ***
Documentation
    ...  If test Fail performs power reset all TL modules and waits for BTS OnAir
    ...  All TL modules should be registered in interfaces.yaml
    ...  Keyword should be added to Teardown after Common Test Teardown

Library  taf.sbts.oam.coam.admin  WITH NAME  coam


*** Keywords ***
CIT Recover Test Line By Power Reset
    Run Keyword If Test Failed
    ...  _BTS_Power_Reset_as_recovery


_BTS_Power_Reset_as_recovery
    Log  Recovery power reset  console=true
    Setup Admin  bts_host=${SMOD1}[IP]
    ${interfaces_module_list}  Admin Get Modules For Interfaces TAF
    FOR  ${module_distname}  IN  @{interfaces_module_list}
        ${off_status}  Run Keyword And Return Status
        ...  Pdu BTS Interface Off  ${module_distname}
        Run Keyword If  ${off_status}
        ...  Log  Power on ${module_distname} is OFF.  console=true
        ...  ELSE
        ...  Log  ${module_distname} not defined in interfaces.yaml  console=true
        Sleep  1s
    END
    Wait For Target To Be Not Reachable  ${SMOD1['IP']}
    Sleep  3s
    FOR  ${module_distname}  IN  @{interfaces_module_list}
        ${on_status}  Run Keyword And Return Status
        ...  Pdu BTS Interface On  ${module_distname}
        Run Keyword If  ${on_status}
        ...  Log  Power on ${module_distname} is On.  console=true
        ...  ELSE
        ...  Log  ${module_distname} not defined in interfaces.yaml  console=true
    END
    Log  Waiting for ping to BTS  console=true
    Wait For Target To Be Reachable  ${SMOD1['IP']}  300
    Log  Waiting for SMODs  console=true
    Sleep  1200s
    Assert Every  SMOD  operationalState=enabled  timeout=2400
    Log  Waiting for RMODs  console=true
    Assert Every  RMOD  operationalState=enabled  timeout=2400
    ${is_lte}  Get Ids For All  LNCEL
    ${is_gsm}  Get Ids For All  GNCEL
    ${is_wcdma}  Get Ids For All  WNCEL
    Log  Waiting for LTE cells  console=true
    Run Keyword If  ${is_lte}
    ...  Assert Every  LNCEL  operationalState=enabled  timeout=2400
    Log  Waiting for WCDMA cells  console=true
    Run Keyword If  ${is_wcdma}
    ...  Assert Every  WNCEL  operationalState=enabled  timeout=2400
    Log  Waiting for GSM cells  console=true
    Run Keyword If  ${is_gsm}
    ...  Assert Every  GNCEL  operationalState=enabled  timeout=2400
    FOR  ${module_distname}  IN  @{interfaces_module_list}
        ${on_status}  Run Keyword And Return Status
        ...  Pdu BTS Interface On  ${module_distname}
    END
    Teardown Admin
