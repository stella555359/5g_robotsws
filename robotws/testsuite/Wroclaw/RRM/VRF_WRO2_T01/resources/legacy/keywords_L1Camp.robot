*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
Library         taf.hw.rf_attenuator    WITH NAME    att


*** Keywords ***
Turn off attenuation
    ${lines}    Get dictionary keys     ${tl.attenuator.attenuator_ports}
    Set attenuation and check    lines=${lines}    value=${0}

Check cells status
     ${status_1}    coam.get cell specific info   cell_id=/MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-1   connection=bts
     ${cell_status_1}    set variable    ${status_1['status']['availabilityStatus']}
     Should be equal    ${cell_status_1}     Online

     ${status_2}    coam.get cell specific info   cell_id=/MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-2   connection=bts
     ${cell_status_2}    set variable    ${status_2['status']['availabilityStatus']}
     Should be equal    ${cell_status_2}     Online

     ${status_3}    coam.get cell specific info   cell_id=/MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-3   connection=bts
     ${cell_status_3}    set variable    ${status_3['status']['availabilityStatus']}
     Should be equal    ${cell_status_3}     Online
