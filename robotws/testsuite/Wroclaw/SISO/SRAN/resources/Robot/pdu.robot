*** Settings ***
Documentation  PDU management keywords.
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    taf.hw.pdu.interface.pdu

Resource    ./tl_init.robot

*** Keywords ***
######################################################## SBTS #########################################################
PDU Prepare SMOD Setup
    [Arguments]  ${number_of_smod_units}
    [Documentation]
    ...  Description:
    ...  Keyword turn off/on smod units that will be used during the test based on scfc file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | number_of_smod_units   | Yes  | Number of SMOD units.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${smod_unit}  IN RANGE  ${number_of_smod_units}
      Run Keyword And Ignore Error  PDU Turn On SMOD  smod_index=${smod_unit+1}
    END

PDU Prepare CUS Setup
    [Arguments]  ${list_of_cus_ips}
    [Documentation]
    ...  Description:
    ...  Keyword turn off/on CUS devices that will be used during the test based on cus.ini files.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP addresses.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${cus_index}  IN RANGE  1  13
      ${cus_ip}=  Catenate  SEPARATOR=  192.168.200.  ${cus_index}
      ${cus_status}=  Run Keyword And Return Status  Should Contain  ${list_of_cus_ips}  ${cus_ip}
      Run Keyword If  ${cus_status}
    ...  Run Keyword And Ignore Error  PDU Turn On CUS  cus_index=${cus_index}
    ...  ELSE
    ...  Run Keyword And Ignore Error  PDU Turn Off CUS  cus_index=${cus_index}
    END

PDU Restart SMOD
    [Arguments]  ${smod_index}
    [Documentation]
    ...  Description:
    ...  Keyword restart SMOD unit given by index number.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | smod_index             | Yes  | Index of SMOD unit.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_list}=  PDU Get System Module Parameters From Init File  smod_index=${smod_index}
    PDU Perform Setup  host=${pdu_parameters_list[0]}
    ...  model=${pdu_parameters_list[1]}  version=${pdu_parameters_list[2]}
    Power Off  port=${pdu_parameters_list[3]}  pdu_device=default
    Sleep  30s
    Power On  port=${pdu_parameters_list[3]}  pdu_device=default
#    ${pdu_reset_ports}=  Create List  ${pdu_parameters_list[2]}
#    Wait Until Keyword Succeeds  60  10
#    ...  Reset Ports  ports=${pdu_reset_ports}  pdu_device=default

PDU Restart SMODs
    [Arguments]  ${number_of_smod_units}
    [Documentation]
    ...  Description:
    ...  Keyword restart all SMOD units.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | number_of_smod_units   | Yes  |  Number of SMOD units.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${smod_unit}  IN RANGE  ${number_of_smod_units}
      ${pdu_parameters_list}=  PDU Get System Module Parameters From Init File  smod_index=${smod_unit+1}
      PDU Perform Setup  host=${pdu_parameters_list[0]}
      ...  model=${pdu_parameters_list[1]}  version=${pdu_parameters_list[2]}
      Power Off  port=${pdu_parameters_list[3]}  pdu_device=default
    END
    Sleep  30s
    FOR  ${smod_unit}  IN RANGE  ${number_of_smod_units}
      ${pdu_parameters_list}=  PDU Get System Module Parameters From Init File  smod_index=${smod_unit+1}
      PDU Perform Setup  host=${pdu_parameters_list[0]}
      ...  model=${pdu_parameters_list[1]}  version=${pdu_parameters_list[2]}
      Power On  port=${pdu_parameters_list[3]}  pdu_device=default
    END

PDU Restart CUS
    [Arguments]  ${cus_index}
    [Documentation]
    ...  Description:
    ...  Keyword restart CUS unit based on CUS unit index.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cus_index              | Yes  | Index of CUS unit.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_list}=  PDU Get CUS Parameters From Init File  cus_index=${cus_index}
    PDU Perform Setup  host=${pdu_parameters_list[0]}
    ...  model=${pdu_parameters_list[1]}  version=${pdu_parameters_list[2]}
    ${pdu_reset_ports}=  Create List  ${pdu_parameters_list[3]}
    Reset Ports  ports=${pdu_reset_ports}  pdu_device=default

PDU Turn On SMOD
    [Arguments]  ${smod_index}
    [Documentation]
    ...  Description:
    ...  Keyword turn on smod unit based on smod index.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | smod_index             | Yes  | Index of SMOD unit.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_list}=  PDU Get System Module Parameters From Init File  smod_index=${smod_index}
    PDU Perform Setup  host=${pdu_parameters_list[0]}
    ...  model=${pdu_parameters_list[1]}  version=${pdu_parameters_list[2]}
    Power On  port=${pdu_parameters_list[3]}  pdu_device=default

PDU Turn On CUS
    [Arguments]  ${cus_index}
    [Documentation]
    ...  Description:
    ...  Keyword turn on CUS unit based on CUS unit index.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cus_index              | Yes  | Index of CUS unit.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_list}=  PDU Get CUS Parameters From Init File  cus_index=${cus_index}
    PDU Perform Setup  host=${pdu_parameters_list[0]}
    ...  model=${pdu_parameters_list[1]}  version=${pdu_parameters_list[2]}
    Power On  port=${pdu_parameters_list[3]}  pdu_device=default

PDU Turn Off SMOD
    [Arguments]  ${smod_index}
    [Documentation]
    ...  Description:
    ...  Keyword turn off smod unit based on smod index.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | smod_index             | Yes  | Index of SMOD unit.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_list}=  PDU Get System Module Parameters From Init File  smod_index=${smod_index}
    PDU Perform Setup  host=${pdu_parameters_list[0]}
    ...  model=${pdu_parameters_list[1]}  version=${pdu_parameters_list[2]}
    Power Off  port=${pdu_parameters_list[3]}  pdu_device=default

PDU Turn Off CUS
    [Arguments]  ${cus_index}
    [Documentation]
    ...  Description:
    ...  Keyword turn off CUS unit based on CUS unit index.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cus_index              | Yes  | Index of CUS unit.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_list}=  PDU Get CUS Parameters From Init File  cus_index=${cus_index}
    PDU Perform Setup  host=${pdu_parameters_list[0]}
    ...  model=${pdu_parameters_list[1]}  version=${pdu_parameters_list[2]}
    Power Off  port=${pdu_parameters_list[3]}  pdu_device=default

######################################################## CBTS #########################################################
PDU Perform Setup
    [Arguments]  ${host}  ${model}  ${version}
    [Documentation]
    ...  Description:
    ...  Keyword performs PDU setup.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | host                   | Yes  |  IP address of PDU device.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | model                  | Yes  |  Model of PDU device.                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | version                | Yes  | PDU device version number.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${setup_result}=  Run Keyword If  "${model}"=="EPC" or "${model}"=="Gude"
    ...  Setup Pdu  host=${host}  model=${model}  version=${version}
    ...  ELSE
    ...  Setup Pdu  host=${host}  model=${model}
    [Return]  ${setup_result}

PDU Turn On Radio Module
    [Arguments]  ${rmod_sn}  ${gnb_index}=0  ${vdu_index}=0  ${pdu_device}=default
    [Documentation]
    ...  Description:
    ...  Keyword power on radio module.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | pdu_device             | Yes  | Alias of configured PDU.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_dict}=  Get Radio Modules PDU Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pdu_parameters}=  Get From Dictionary  dictionary=${pdu_parameters_dict}  key=${rmod_sn}
    PDU Perform Setup  host=${pdu_parameters['ip_addr']}
    ...  model=${pdu_parameters['model']}  version=${pdu_parameters['version']}
    Power On  port=${pdu_parameters['port_no']}  pdu_device=${pdu_device}

PDU Turn Off Radio Module
    [Arguments]  ${rmod_sn}  ${gnb_index}=0  ${vdu_index}=0  ${pdu_device}=default
    [Documentation]
    ...  Description:
    ...  Keyword power off radio module unit.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | pdu_device             | Yes  | Alias of configured PDU.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_dict}=  Get Radio Modules PDU Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pdu_parameters}=  Get From Dictionary  dictionary=${pdu_parameters_dict}  key=${rmod_sn}
    PDU Perform Setup  host=${pdu_parameters['ip_addr']}
    ...  model=${pdu_parameters['model']}  version=${pdu_parameters['version']}
    Power Off  port=${pdu_parameters['port_no']}  pdu_device=${pdu_device}

PDU Restart Radio Module
    [Arguments]  ${rmod_sn}  ${gnb_index}=0  ${vdu_index}=0  ${pdu_device}=default
    [Documentation]
    ...  Description:
    ...  Keyword restart radio module.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | pdu_device             | Yes  | Alias of configured PDU.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_dict}=  Get Radio Modules PDU Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pdu_parameters}=  Get From Dictionary  dictionary=${pdu_parameters_dict}  key=${rmod_sn}
    PDU Perform Setup  host=${pdu_parameters['ip_addr']}
    ...  model=${pdu_parameters['model']}  version=${pdu_parameters['version']}
    ${pdu_reset_ports}=  Create List  ${pdu_parameters['port_no']}
    Wait Until Keyword Succeeds  60  10
    ...  Reset Ports  ports=${pdu_reset_ports}  pdu_device=${pdu_device}
