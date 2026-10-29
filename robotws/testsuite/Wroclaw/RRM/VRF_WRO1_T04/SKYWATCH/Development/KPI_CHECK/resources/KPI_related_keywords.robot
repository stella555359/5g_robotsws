*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com


*** Keywords ***
Send RrcReestablish To Random ${no} Ues among all ${ues} Ues
    ${numbers}=    Evaluate    random.sample(range(1, ${ues}), ${no})    random
    FOR    ${item}     IN      @{numbers}
        Execute Egate Command And Wait For Data
        ...  cmd=ue_rrc_reestablish id=${item}
        ...  pass_regexp=
    END
    RETURN  ${numbers}


Send RrcResume To Random ${no} Ues among all ${ues} Ues With Cause ${cause}
    ${numbers}=    Evaluate    random.sample(range(1, ${ues}), ${no})    random
    FOR    ${item}     IN      @{numbers}
        Execute Egate Command And Wait For Data
        ...  cmd=ue_assistance_send_nr ue_id=${item} PreferredRRCState=inactive
        ...  pass_regexp=
        Sleep    5s
        Execute Egate Command And Wait For Data
        ...  cmd=ue_nr_rrc_resume_request_param id=${item} cause=${cause}
        ...  pass_regexp=
        Execute Egate Command And Wait For Data
        ...  cmd=ue_nr_rrc_resume id=${item}
        ...  pass_regexp=
    END
    RETURN  ${numbers}

Get Sum Of ${counter} Counter Values From ${no_of_cells} Cells From ${PM_COUNTERS}
    ${counter_sum}    Set Variable    ${0}
    FOR  ${cell}  IN RANGE  ${1}  ${no_of_cells}
        ${counter_value}=    Get Latest Pm Counter Value
    ...    counter_id=${counter}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell}
    ...    filepath=${PM_COUNTERS}
        ${counter_sum}=    Evaluate    ${counter_sum} + ${counter_value}
    END
    RETURN  ${counter_sum}
