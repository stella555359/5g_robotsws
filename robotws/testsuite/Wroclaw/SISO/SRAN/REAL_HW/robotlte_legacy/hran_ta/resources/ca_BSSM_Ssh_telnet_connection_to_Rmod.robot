*** Settings ***

Documentation  Maintainer: mateusz.kawka@nokia.com

Library                 SSHLibrary  timeout=10
Variables               ca_BSRF_radio_operation.py

*** Variables ***
${REL_4}                ['473095A', '473764A', '474767A', '474021A', '475765A']
${REL_3}                472181A
${TELNET_RMODS}         ['FRMA', 'FXFC', 'FXFB', 'FXFA', 'FRGT', 'FRGS', 'FRGP', 'FRGQ', 'FHGB', 'FRHB', 'FRHA', 'FRHG',
                        ...  'FRHE', 'FRHD', 'FXCA', 'FXCB', 'FHDB', 'FRLB', 'FRMB', 'FHDA', 'FRIE', 'FRIG', 'FXDA', 'FXDB',
                        ...  'FXDJ', 'FXJB', 'FHEB', 'FHEA', 'FHEF', 'FHEG', 'FXEB', 'FXEA', 'FXJC', 'FRIJ', 'FRGY', 'FHEL',
                        ...  'FHDI', 'FRGU', 'FRGX', 'FRGB', 'FRPB', 'FRHC', 'FHGA', 'FRHF', 'FRME', 'FRMF', 'FRMC', 'FHDG',
                        ...  'FRPA', 'FHED', 'FXEF', 'FXED', 'FXEE', 'FHEI', 'FRBE', 'FRBG', 'FRBF', 'FXDD', 'UHMB', 'UHEF',
                        ...  'UHED', 'UHHA', 'UHEC', 'UHEA']

&{SMOD1}  IP=192.168.255.1  USERNAME=toor4nsn  PASSWORD=oZPS0POrRieRtu
${REMOTE_HOST}

*** Keywords ***
Open Connection To Radio Module With Serial Number
    [Documentation]
    ...  Opens connection to RF modue by serialnumber
    ...  **Author:** robert.susz@nokia.com
    ...  **Input Parameters:**
    ...
    ...    +-------------------------+--------+-------------------------------------------+
    ...    | Input Parameters        | Man.   | Description                               |
    ...    +====================+========+================================================+
    ...    | rmod_serial_number      | Yes    |  Serial number of RF module               |
    ...    +------------------+--------+--------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...      Open Connection To Radio Module With Serial Number  K9173100424
    [Arguments]  ${rmod_serial_number}  ${alias}=default

    _Parameter Constructor  ${rmod_serial_number}  ${alias}
    Run Keyword If  '${SM_PROD_CODE}'=='${REL_3}'  _Set SSH session Rmod Connected To Rel3 System Module
    ${REL_4}  Evaluate  ${REL_4}
    ${ifrel_4}  Run Keyword And Return Status  List Should Contain Value  ${REL4}  ${SM_PROD_CODE}  msg= Unknown system module product code
    Run Keyword If  ${ifrel4}  _Set SSH session Rmod Connected To Rel4 System Module
    Run Keyword If  ${ifrel4}==False and '${SM_PROD_CODE}'!='${REL_3}'  FAIL  Unknown system module product code ${SM_PROD_CODE}

Send Command Force
    [Documentation]
    ...  Send Command  to RF module and wait untill prompt
    ...  **Author:** robert.susz@nokia.com
    ...  **Input Parameters:**
    ...
    ...  **Author:** robert.susz@nokia.com
    ...    +-------------------------+--------+-------------------------------------------+
    ...    | Input Parameters        | Man.   | Description                               |
    ...    +====================+========+================================================+
    ...    | command                 | Yes    |  Command that you want to sent            |
    ...    +------------------+--------+--------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...      Send Command Force  ls -all

    [Arguments]  ${command}

    Run Keyword And Ignore Error  SSHLibrary.Write  ${command}
    ${response}  SSHLibrary.Read  delay=2s
    Log To Console  ${response}


Send Command
    [Documentation]
    ...  Send Command  to RF module and wait untill prompt
    ...  **Author:** robert.susz@nokia.com
    ...  **Input Parameters:**
    ...
    ...  **Author:** robert.susz@nokia.com
    ...    +-------------------------+--------+-------------------------------------------+
    ...    | Input Parameters        | Man.   | Description                               |
    ...    +====================+========+================================================+
    ...    | command                 | Yes    |  Command that you want to sent            |
    ...    +------------------+--------+--------------------------------------------------+
     ...   | prompt                  | No     |  propmt with default value @              |
    ...    +------------------+--------+--------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...      Send Command  ls -all

    [Arguments]  ${command}  ${prompt}=@
    SSHLibrary.Write  ${command}
    SSHLibrary.Read Until  ${prompt}

Send Command and return output
    [Documentation]
    ...  Send Command  to RF module, wait until desired prompr and return output from console as
    ...  ${output} variable
    ...  **Author:** robert.susz@nokia.com
    ...  **Input Parameters:**
    ...
    ...    +-------------------------+--------+-------------------------------------------+
    ...    | Input Parameters        | Man.   | Description                               |
    ...    +====================+========+================================================+
    ...    | command                 | Yes    |  Command that you want to sent            |
    ...    +------------------+--------+--------------------------------------------------+
     ...   | prompt                  | No     |  propmt with default value @              |
    ...    +------------------+--------+--------------------------------------------------+
    ...
    ...    +-------------------------+--------+-------------------------------------------+
    ...    | Output Parameters        | Man.   | Description                              |
    ...    +====================+========+================================================+
    ...    | output                   | Yes    |  Output from console                     |
    ...    +------------------+--------+--------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...      ${output}  Send Command and return output  ls -all

    [Arguments]  ${command}  ${prompt}=@
    SSHLibrary.Write  ${command}
    ${output}  SSHLibrary.Read Until  ${prompt}
    [Return]  ${output}

Close SSH Connection
    SSHLibrary.Close Connection

_Parameter constructor
    [Documentation]
    ...  This KW sets all reuired variables required for ssh/telnet connection
    [Arguments]  ${rmod_serial_number}  ${alias}=default

    ${mrbts_object}  admin.Get parameters for all  BTS  alias=${alias}
    Set test variable  ${MRBTS}  ${mrbts_object[0].btsId}

    ${rmod_object}   admin_im.Query Infomodel
    ...   get object //RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/RMOD_R-* is [serialNumber=${rmod_serial_number}]  alias=${alias}
    ${ref_radio_object}   admin_im.Query Infomodel  get object ${rmod_object.dist_name}/REF-*  alias=${alias}
    ${im_radio_object}    admin_im.Query Infomodel  get object ${ref_radio_object.distName}  alias=${alias}

    Set Test Variable  ${RMOD_IP}  ${im_radio_object.ipAddress}
    Set Test Variable  ${RMOD_PROD_NAME}  ${rmod_object.productName}
    Set Test Variable  ${RMOD_DIST_NAME}  ${rmod_object.dist_name}

    ${ref_radio_object}  admin_im.Query Infomodel  get object ${RMOD_DIST_NAME}/REF-*  alias=${alias}
    ${im_radio_object}   admin_im.Query Infomodel  get object ${ref_radio_object.distName}  alias=${alias}
    ${smod_l}  admin_im.Query Infomodel  get object ${im_radio_object.masterAgentDN}  alias=${alias}
    ${smod}  admin_im.Query Infomodel
    ...  get object //CABINET_R-*/SMOD_R-* is [serialNumber=${smod_l['serialNumber']},productCode=${smod_l['visibleProductCode']}]
    ...  timeout=30  alias=${alias}

    ${active_role}  Convert To String  ${smod.activeRole}
    ${smod_prod_code}  Convert To String  ${smod.productCode}
    ${regexp_smod_prod_code}  Get Regexp Matches  ${smod_prod_code}  ^.{0,7}
    ${regexp_smod_prod_code}  Convert To String  ${regexp_smod_prod_code[0]}

    Set Test Variable  ${ACT_ROLE}  ${active_role}
    Set Test Variable  ${SM_PROD_CODE}  ${regexp_smod_prod_code}
    Set Test Variable  ${SM_PROD_NAME}  ${smod.productName}

    ${TELNET_RMODS}  Evaluate  ${TELNET_RMODS}
    ${iftelnet}  Run Keyword And Return Status
    ...  List Should Contain Value  ${TELNET_RMODS}  ${RMOD_PROD_NAME}  msg= Old Radio Module connection mode changed to Telnet

    Set Test Variable  ${TELNET}  ${iftelnet}

_Set SSH session Rmod Connected To Rel3 System Module
    Run Keyword If  '${ACT_ROLE}'=='None'  _Rel 3 Primary
    Run Keyword If  '${ACT_ROLE}'=="Primary"  _Rel 3 Primary
    Run Keyword If  '${ACT_ROLE}'=="Secondary"  _Rel 3 Secondary

_Set SSH session Rmod Connected To Rel4 System Module
    Run Keyword If  '${ACT_ROLE}'=='None'  _Rel 4 Primary
    Run Keyword If  '${ACT_ROLE}'=="Primary"  _Rel 4 Primary
    Run Keyword If  '${ACT_ROLE}'=="Secondary"  _Rel 4 Secondary

_Rel 3 Primary
    _Open Connection to Primary Core
    _Open Telnet Or SSH Session

_Rel 3 Secondary
    _Open Connection to Primary Core
    _Jump To Secondary Core
    _Open Telnet Or SSH Session

_Rel 4 Primary
    Run Keyword If  '${REMOTE_HOST}'!='${EMPTY}'
    ...  Open Connection To Primary Core Via Remote Host
    ...  ELSE
    ...  _Open Connection to Primary Core
    _LXC Attach
    _Open Telnet Or SSH Session

_Rel 4 Secondary
    Run Keyword If  '${REMOTE_HOST}'!='${EMPTY}'
    ...  Open Connection To Primary Core Via Remote Host
    ...  ELSE
    ...  _Open Connection to Primary Core
    _Jump To Secondary Core
    _LXC Attach
    _Open Telnet Or SSH Session

Open Connection To Primary Core Via Remote Host

    SSHLibrary.Open Connection  ${REMOTE_HOST}  prompt=REGEXP:[$#>]$
    SSHLibrary.Login With Public Key  ute  /home/ute/.ssh/id_rsa
    SSHLibrary.Set Client Configuration  timeout=20s

    SSHLibrary.Write  sshenb
    ${output}  SSHLibrary.Read Until Regexp   fingerprint|Password
    ${fingerprint}  Run Keyword And Return Status   should contain  ${output}  fingerprint
    ${password}  Run Keyword And Return Status   should contain  ${output}  Password
    Run Keyword If  ${fingerprint}  Run Keywords
    ...  SSHLibrary.Write  yes  AND  SSHLibrary.Read Until  Password:  AND  SSHLibrary.Write  ${SMOD1}[PASSWORD]
    Run Keyword If  ${password}  Run Keywords  SSHLibrary.Write  ${SMOD1}[PASSWORD]  AND  SSHLibrary.Read Until Prompt

_Open Connection to Primary Core

    SSHLibrary.Open Connection  ${SMOD1}[IP]  prompt=REGEXP:[$#>]$
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    SSHLibrary.Set Client Configuration  timeout=10s

_Jump To Secondary Core
    Run Keyword If  'ASIL' in '${SM_PROD_NAME}'  SSHLibrary.Write  ssh ${SMOD1}[USERNAME]@fct-4a
    ...  ELSE  SSHLibrary.Write  ssh ${SMOD1}[USERNAME]@192.168.253.32
    ${output}  SSHLibrary.Read Until Regexp   fingerprint|[Pp]assword|>
    ${fingerprint}  Run Keyword And Return Status  Should Contain  ${output}  fingerprint
    ${password}     Run Keyword And Return Status  Should Match Regexp  ${output}  [Pp]assword
    ${prompt}       Run Keyword And Return Status  Should Contain  ${output}  >
    Run Keyword If  ${password}  Run Keywords
    ...  SSHLibrary.Write  ${SMOD1}[PASSWORD]
    ...  AND  SSHLibrary.Read Until Prompt
    ...  AND  Return From Keyword
    ...  ELSE IF  ${fingerprint}
    ...  SSHLibrary.Write  yes
    ...  ELSE IF  ${prompt}
    ...  Return From Keyword

    ${output}  SSHLibrary.Read Until Regexp   [Pp]assword|>
    ${password}  Run Keyword And Return Status  Should Match Regexp  ${output}  [Pp]assword
    Run Keyword If  ${password}  Run Keywords
    ...  SSHLibrary.Write  ${SMOD1}[PASSWORD]
    ...  AND  SSHLibrary.Read Until Prompt


_Open Telnet Or SSH Session
    SSHLibrary.Write  rm /user/toor4nsn/.ssh/known_hosts
    ${custom_login}  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${RMOD_PASSWORDS}  ${RMOD_PROD_NAME}
    Run Keyword If  ${custom_login}  Run Keywords
    ...  _Open SSH Session With Credentials  ${RMOD_PASSWORDS['${RMOD_PROD_NAME}']}[0]  ${RMOD_PASSWORDS['${RMOD_PROD_NAME}']}[1]
    ...  AND  Return From Keyword

    Run Keyword If  ${TELNET}==True  Run Keywords
    ...  SSHLibrary.Write  telnet ${RMOD_IP} 2323
    ...  AND  SSHLibrary.Read Until Regexp  >|$
    ...  AND  Log To Console  Telnet connection established successfully to RMOD ${RMOD_PROD_NAME} with IP ${RMOD_IP}
    ...  AND  Return From Keyword

    SSHLibrary.Write  ssh ${RMOD_IP}
    ${output}  SSHLibrary.Read Until Regexp   fingerprint|Password|#
    ${fingerprint}  Run Keyword And Return Status   Should Contain  ${output}  fingerprint
    ${password}  Run Keyword And Return Status   Should Contain  ${output}  Password
    Run Keyword If  ${fingerprint}  Run Keywords  SSHLibrary.Write  yes  AND  SSHLibrary.Read Until  ~#
    Run Keyword If  ${password}  Run Keywords  SSHLibrary.Write  ${SMOD1}[PASSWORD]  AND  SSHLibrary.Read Until Prompt

    Log To Console  SSH connection established successfully to RMOD ${RMOD_PROD_NAME} with IP ${RMOD_IP}

_Open SSH Session With Credentials
    [Documentation]
    ...  KW connects to Scorpio, Zodiac, Chile, mMIMO etc. RUs
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    [Arguments]  ${rfsw_login}  ${rfsw_password}

    FOR  ${i}  IN RANGE  3
        SSHLibrary.Write  ssh ${rfsw_login}@${RMOD_IP}
        ${output}  SSHLibrary.Read Until Regexp   refused|fingerprint|[Pp]assword|#
        ${is_refused}  Run Keyword And Return Status  Should Contain  ${output}  refused
        ${is_key_failed}  Run Keyword And Return Status  Should Contain  ${output}  man-in-the-middle attack
        Run Keyword If  ${is_key_failed}  Run Keywords
        ...  SSHLibrary.Write  rm /user/toor4nsn/.ssh/known_hosts
        ...  AND  Continue For Loop
        Exit For Loop If  '${is_refused}'=='False'
    END

    ${fingerprint}  Run Keyword And Return Status  Should Contain  ${output}  fingerprint
    ${password}     Run Keyword And Return Status  Should Contain  ${output}  password
    Run Keyword If  ${fingerprint}  Run Keywords
    ...  SSHLibrary.Write  yes
    ...  AND  SSHLibrary.Read Until  password
    ...  AND  SSHLibrary.Write  ${rfsw_password}
    Run Keyword If  ${password}  SSHLibrary.Write  ${rfsw_password}
    SSHLibrary.Read Until Prompt
    Log To Console  Connection established successfully to RMOD ${RMOD_PROD_NAME} with IP ${RMOD_IP}

_LXC Attach
    SSHLibrary.Write  lxc-ls
    ${output}  SSHLibrary.Read Until  >
    ${output}  Remove String  ${output}  \n  \r
    Run Keyword If  '0x1018' in '${output}'
    ...  SSHLibrary.Write  lxc-attach --name 0x1018
    ...  ELSE
    ...  SSHLibrary.Write  lxc-attach --name 0x2018
    SSHLibrary.Read Until  :~ >
