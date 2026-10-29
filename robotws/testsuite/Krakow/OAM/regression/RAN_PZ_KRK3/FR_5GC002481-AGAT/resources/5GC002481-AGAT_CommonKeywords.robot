*** Settings ***
Documentation
...    Author: pawel.wroblewski@nokia.com
...    Maintainer: pawel.wroblewski@nokia.com

Library     Collections
Library     taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library     ./python_keywords.py
Library     taf.rfrl.bts.commissioning
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${DEFAULT_PM_INTERVAL}  5
${SCF_PATH}  commissionings/Krakow/7_7_UTE5GCLOUDT438/SCF_5GC002481-AGAT_base.xml

*** Keywords ***
Set BER alarm thresholds to default values
    [Documentation]  Sets berMajorAlarmThreshold and berMinorAlarmThreshold to default values (-13,-12)
    set_ber_alarm_thresholds

Verify that RMOD SFP monitoring PM counter are visible in WebEM
    [Documentation]  Checks if counter from RMOD SFP monitoring are present in WebEM
    ${counter1}=  get_last_sfp_rmod_counter_value  M55603C00010
    ${counter2}=  get_last_sfp_rmod_counter_value  M55603C00011
    ${counter1_result}=  evaluate  ${counter1}>=0
    ${counter2_result}=  evaluate  ${counter2}>=0
    Should be True  ${counter1_result}
    Should be True  ${counter2_result}

Verify that SMOD SFP monitoring PM counter are visible in WebEM
    [Documentation]  Checks if counter from SMOD SFP monitoring are present in WebEM
    ${counter1}=  get_last_sfp_smod_counter_value  M55602C00010
    ${counter2}=  get_last_sfp_smod_counter_value  M55602C00011
    ${counter1_result}=  evaluate  ${counter1}>=0
    ${counter2_result}=  evaluate  ${counter2}>=0
    Should be True  ${counter1_result}
    Should be True  ${counter2_result}

Reset site and wait for onAir state
    [Documentation]  Performs site reset and waits for onAir state
    admin_cli.Reset Site
    wait until keyword succeeds     10 min  30  Verify gNB is onAir

Try to set BER alarm thresholds and expect validation failure
    [Documentation]  Attempt to set BER alarm thresholds and expect failure
    [Arguments]  ${minor_threshold}    ${major_threshold}
    Run Keyword and Expect Error    *    Set BER alarm thresholds    ${minor_threshold}     ${major_threshold}

Verify BER and LCV values are higher than 0
    [Documentation]  Verifies that current measurements of BER and LCV display non 0 values
    [Arguments]  ${hw}
    ${rmod}=  get_rmod_dist
    ${bbmod}=  get_bbmod_dist
    ${ber}=  get_sfp_statistic  ${rmod}  ${bbmod}  BER
    @{ber_values}=  Get from dictionary  ${ber}  ${hw}
    Should be True  @{ber_values}[0] > 0  BER value equal to 0
    ${lcv}=  get_sfp_statistic  ${rmod}  ${bbmod}  LCV
    @{lcv_values}=  Get from dictionary  ${lcv}  ${hw}
    Should be True  @{lcv_values}[0] > 0  LCV value equal to 0

Verify that BER and BER24hr values are on the same level
    [Documentation]  Verifies that initial measurements of BER and BER24hr are on the same level
    [Arguments]  ${hw}
    ${rmod}=  get_rmod_dist
    ${bbmod}=  get_bbmod_dist
    ${ber}=  get_sfp_statistic  ${rmod}  ${bbmod}  BER
    @{ber_values}=  Get from dictionary  ${ber}  ${hw}
    ${ber24hr}=  get_sfp_statistic  ${rmod}  ${bbmod}  BER24hr
    @{ber24hr_values}=  Get from dictionary  ${ber24hr}  ${hw}
    Should be True  0.01 < @{ber_values}[0] / @{ber24hr_values}[0] < 1000  BER24hr and BER values differ too much

Clear SFP statistics if needed
    [Documentation]  Teardown keyword which in case there is any BER related alarm or any of BER/LCV counter
    ...              is higher 0 performs site reset as cleaup action
    ${rmod}=  get_rmod_dist
    ${bbmod}=  get_bbmod_dist
    ${sfp_status}=  check_if_sfp_ber_lcv_are_cleared  ${rmod}  ${bbmod}
    ${alarm_status}=  check_if_none_of_ber_related_alarms_is_present
    IF    '${sfp_status}' == 'False' or '${alarm_status}' == 'False'
        Reset Site And Wait For Onair State
    END

Perform commissioning and reach onAir
    [Documentation]  Initial testline configuration
    perform_full_commissioning_on_classical_gnb
    wait until keyword succeeds     10 min  30  Verify gNB is onAir


Perform SW upgrade to same build and reach onAir
    [Documentation]  Loading same to prevent Incompatible SW version alarm. This method should be treated as temporary
    ...             workaround and removed in future.
    admin_cli.Perform Commissioning    scf_file=${CURDIR}/GNB0_SCF.xml
    ${alarm_presence}=  gnbalarm.check_if_sw_incompatible_alarm_occurred
    Run Keyword If  ${alarm_presence}  wait until keyword succeeds     15 min  30    Download and update same SW version
    admin_cli.connect_to
    wait until keyword succeeds     15 min  30     Verify gNB is onAir
