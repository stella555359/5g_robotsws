***Settings ***

Documentation

...   [Procedure]          "IPSEC_REAUTH_KEYING"
...   [Date]               "Date of creation 25-9-2024"
...   [Author]             "Abhishek Baburaj"
...   [QC_Path]            "QC_Path in Test Plan"
...   [QC_ID]              "QC_ID in Test Lab for reporting"
...   [Feature_ID]         "RP000749"
...   [Funtion_Hash_Tags]  "IPSEC_REAUTH_ASIM"
...   [Validation_status]  "Passed"
...   [Testline Status]	   "BTS-2020"
...   [Validation Date]    "22-10-2024

*** Keywords ***
Preconditions
    Perform Commissioning       scf_file=${Master_SCF}     verify_bts_status=True     timeout=1600   alias=default    wait_for_bts_to_be_ready=300
    sleep   300
    Setup Ems  config_device=netact2005   alias=lab2005
    Cm Upload   config_device=netact2005   alias=lab2005

Verify rekeying
    Setup Remote Access   remote_device=bts     alias=session1
    ${stdout_1}          Execute Interactive Remote Command    command=ipsec status | grep -i 10.71.240.151   alias=session1
    Should contain       ${stdout_1}    ESTABLISHED
    ${stdout_2}          Execute Interactive Remote Command    command=ipsec status | grep -i 2a00:8a00:a000:1104::4017   alias=session1
    Should contain       ${stdout_2}    ESTABLISHED

Enable the reauth flag and reauth timer as 3600sec
    Perform Recommissioning     type=param       param_path=${Ikep-5}:ikeReauthEnabled  operation=update     value=${True}      timeout=120
    Perform Recommissioning     type=param       param_path=${Ikep-2}:ikeReauthEnabled  operation=update     value=${True}      timeout=120

Disable the reauth flag
    Perform Recommissioning     type=param       param_path=${Ikep-5}:ikeReauthEnabled  operation=update     value=${false}      timeout=120
    Perform Recommissioning     type=param       param_path=${Ikep-2}:ikeReauthEnabled  operation=update     value=${false}      timeout=120

Configure ike rekey as 3600sec
    Perform Recommissioning     type=param       param_path=${Ikep-5}:ikeMaxLifeTime  operation=update     value=3600     timeout=120
    Perform Recommissioning     type=param       param_path=${Ikep-2}:ikeMaxLifeTime  operation=update     value=3600     timeout=120

