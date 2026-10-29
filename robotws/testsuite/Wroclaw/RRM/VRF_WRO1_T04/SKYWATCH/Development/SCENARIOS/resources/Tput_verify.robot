*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Library    CB008367.py

*** Keywords ***

Display Actual Traffic For UEs ${start_ue}-${last_ue}
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${last_ue}+${1}
        Verify Tput On Scell    ue_id=${ue_id}    cc=0     tput_expected=True
    END

Display Actual Uplink Traffic For UEs ${start_ue}-${last_ue}
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${last_ue}+${1}
        Verify Ul Tput On Scell    ue_id=${ue_id}    cc=0     tput_expected=True
    END

Display Actual Traffic NSA For UEs ${start_ue}-${last_ue}
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${last_ue}+${1}
        Verify Tput On Scell    ue_id=${ue_id}    cc=8     tput_expected=True
    END

Display Actual Uplink Traffic NSA For UEs ${start_ue}-${last_ue}
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${last_ue}+${1}
        Verify Ul Tput On Scell    ue_id=${ue_id}    cc=8     tput_expected=True
    END
