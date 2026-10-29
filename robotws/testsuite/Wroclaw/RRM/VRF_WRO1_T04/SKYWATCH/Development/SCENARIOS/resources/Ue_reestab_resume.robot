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


Send RrcResume To Ue ${ue} With Cause ${cause}
    Execute Egate Command And Wait For Data
    ...  cmd=ue_nr_rrc_resume_request_param id=${ue} cause=${cause}
    ...  pass_regexp=
    Execute Egate Command And Wait For Data
    ...  cmd=ue_nr_rrc_resume id=${ue}
    ...  pass_regexp=UE performed resume procedure
