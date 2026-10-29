*** Settings ***
Documentation  Information obtained from the test line configuration file.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    String

*** Keywords ***
######################################################## SBTS #########################################################
PDU Get System Module Parameters From Init File
    [Arguments]  ${smod_index}
    [Documentation]
    ...  Description:
    ...  Keyword gets SMOD PDU parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | smod_index             | Yes  |  Index of SMOD unit.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${version}=  Get Variable Value  ${tl.enbs[${smod_index}-1].system_module.common_units[0].pdu_port.pdu.version}
    @{pdu_parameters_list}=  Set Variable
    ...  ${tl.enbs[${smod_index}-1].system_module.common_units[0].pdu_port.pdu.addr}
    ...  ${tl.enbs[${smod_index}-1].system_module.common_units[0].pdu_port.pdu.__class__.__name__}
    ...  ${version}
    ...  ${tl.enbs[${smod_index}-1].system_module.common_units[0].pdu_port.port_no}
    [Return]  ${pdu_parameters_list}

Get System Module Number From Init File
    [Documentation]
    ...  Description:
    ...  Keyword gets system modules number from TL configuration init file.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${smod_number}=  Get Length  item=${tl.enbs}
    [Return]  ${smod_number}

PDU Get CUS Parameters From Init File
    [Arguments]  ${cus_index}
    [Documentation]
    ...  Description:
    ...  Keyword gets CUS PDU parameters from TL configuration init file.
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

    ${version}=  Get Variable Value  ${tl.ues[${cus_index}-1].l1.common_units[0].pdu_port.pdu.version}
    @{pdu_parameters_list}=  Set Variable
    ...  ${tl.ues[${cus_index}-1].l1.common_units[0].pdu_port.pdu.addr}
    ...  ${tl.ues[${cus_index}-1].l1.common_units[0].pdu_port.pdu.__class__.__name__}
    ...  ${version}
    ...  ${tl.ues[${cus_index}-1].l1.common_units[0].pdu_port.port_no}
    [Return]  ${pdu_parameters_list}

######################################################## CBTS #########################################################
#Host
Get Host Parameters From Init File
    [Arguments]  ${host_index}=1
    [Documentation]
    ...  Description:
    ...  Keyword gets host parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | host_index             | Yes  | Index of host.                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ip_addr}=  Get Variable Value  ${tl.test_pcs[${host_index}-1].default_ssh_connection_details.addr}  ${None}
    ${username}=  Get Variable Value  ${tl.test_pcs[${host_index}-1].default_ssh_connection_details.username}  ${None}
    ${password}=  Get Variable Value  ${tl.test_pcs[${host_index}-1].default_ssh_connection_details.password}  ${None}
    ${host_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}
    [Return]  ${host_parameters}

#vDU
Get vDU Namespace From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU namespace parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${namespace}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]  ${namespace}

Get vDU Oam Http Connection Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU OAM Http connection parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance object list.                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ip_addr}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ${password}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ${port}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.port}
    ${http_connection_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}  port=${port}
    [Return]  ${http_connection_parameters}

Get vDU K8s Master Node Connection Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU K8s master node connection parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ip_addr}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ${username}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ${password}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    ${port}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    ${k8s_connection_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}  port=${port}
    [Return]  ${k8s_connection_parameters}

Get vDU K8s Master Node Ssh Connection Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU K8s master node ssh connection parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ip_addr}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ${ssh_connection_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}
    [Return]  ${ssh_connection_parameters}

Get vDU Number From Init File
    [Arguments]  ${gnb_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU number from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_number}=  Get Length  item=${tl.gnbs[${gnb_index}].dus}
    [Return]  ${vdu_number}

Get vDU Instance Id From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU instance id from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${result}  ${instance_id}=  Run Keyword And Ignore Error
    ...  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].instance_id}
    Return From Keyword If  "${result}"=="PASS"  ${instance_id}
    ${instance_id}=  Set Variable  ${tl.gnbs[${gnb_index}].instance_id}
    [Return]  ${instance_id}

Get vDU Count From Init File
    [Arguments]  ${gnb_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU count from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_vdu}=  Set Variable  ${tl.gnbs[${gnb_index}].dus}
    ${du_count}=  Set Variable  ${all_vdu.__len__()}
    [Return]  ${du_count}

#vCU
Get vCU Namespace From Init File
    [Arguments]  ${gnb_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets vCU namespace parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${namespace}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]  ${namespace}

Get vCU K8s Master Node Ssh Connection Parameters From Init File
    [Arguments]  ${gnb_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets vCU K8s master node ssh connection parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ip_addr}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ${ssh_connection_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}
    [Return]  ${ssh_connection_parameters}

Get VCU NF Type From Init File
    [Arguments]  ${gnb_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets VCU NF type from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${flavors}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.flavors}
    ${nf_type}=  Set Variable If  "${flavors}"=="${None}"  CNF  VNF
    [Return]  ${nf_type}

Get VCU One Click Config Yaml From Init File
    [Arguments]  ${gnb_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets Yaml file name of VCU One Click Config defined in cnf_parameters.yaml
    ...  from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cfg_dir}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ${yaml_file_name}=  OperatingSystem.Join Path  ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/cnf_parameters.yaml
    [Return]   ${yaml_file_name}

Get vCU Instance Id From Init File
    [Arguments]  ${gnb_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets vCU instance id from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${instance_id}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.instance_id}
    [Return]  ${instance_id}

Get vCU Oam Http Connection Parameters From Init File
    [Arguments]  ${gnb_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets vCU OAM Http connection parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ip_addr}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ${username}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ${password}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${port}=  Set Variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.port}
    ${http_connection_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}  port=${port}
    [Return]  ${http_connection_parameters}

#PDU
Get PDU Parameters From Init File
    [Arguments]  ${pdu_index}=0
    [Documentation]
   ...  Description:
    ...  Keyword gets PDU parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | pdu_index              |  No  | Index of PDU (Power Distribution Unit) class list.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ip_addr}=  Set Variable  ${tl.pdus[${pdu_index}].addr}
    ${port_numbers}=  Set Variable  ${tl.pdus[${pdu_index}].port_numbers}
    ${model}=  Set Variable  ${tl.pdus[${pdu_index}].model}
    ${version}=  Set Variable  ${tl.pdus[${pdu_index}].version}
    ${pdu_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  port_numbers=${port_numbers}  model=${model}  version=${version}
    [Return]  ${pdu_parameters}

#Radio Modules PDU
Get FHGW Single Radio Module PDU Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0  ${ru_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets radio module PDU parameters from TL configuration init file based on radio module index.
    ...  Radio module is connected to FHGW.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ru_index               |  No  | Index of RU (Radio Unit) classes list.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of PDU parameters to which the radio module is connected:
    ...  {'ip_addr': '10.44.167.199', 'model': 'EPC', 'version': '8221-1', 'port_no': 1}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ip_addr}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}].pdu_port.pdu.addr}
    ${model}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}].pdu_port.pdu.model}
    ${version}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}].pdu_port.pdu.version}
    ${pdu_port}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${ru_index}].pdu_port.port_no}
    ${pdu_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  model=${model}  version=${version}  port_no=${pdu_port}
    [Return]  ${pdu_parameters}

Get Single FHGW Radio Modules PDU Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets radio modules PDU parameters from TL configuration init file.
    ...  Keyword gets radio modules PDU parameters from one FHGW.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of PDU parameters, where the key is the radio module serial number:
    ...  {'1M190413180': {'ip_addr': '10.44.167.199', 'model': 'EPC', 'version': '8221-1', 'port_no': 1}}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_dict}=  Create Dictionary
    ${rmods_connection}=  Get Single FHGW Radio Module Connection Status From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    Return From Keyword If  not ${rmods_connection}  ${pdu_parameters_dict}

    ${rmods_count}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus}
    FOR  ${rmod_index}  IN RANGE  ${rmods_count}
      ${serial_number}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus[${rmod_index}].serial_number}
      ${pdu_parameters}=  Get FHGW Single Radio Module PDU Parameters From Init File
      ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}  ru_index=${rmod_index}
      Set To Dictionary  ${pdu_parameters_dict}  ${serial_number}=${pdu_parameters}
    END
    [Return]  ${pdu_parameters_dict}

Get FHGWs Radio Modules PDU Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets all radio modules PDU parameters from TL configuration init file.
    ...  Keyword gets radio modules PDU parameters from all FHGWs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of PDU parameters, where the key is the radio module serial number:
    ...  {'1M190413180': {'ip_addr': '10.44.167.199', 'model': 'EPC', 'version': '8221-1', 'port_no': 1}}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_dict}=  Create Dictionary
    ${fhgws_connection}=  Get FHGWs Connection Status From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    Return From Keyword If  not ${fhgws_connection}  ${pdu_parameters_dict}

    ${fhgws_count}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws}
    FOR  ${fhgw_index}  IN RANGE  ${fhgws_count}
      ${fhgw_pdu_parameters}=  Get Single FHGW Radio Modules PDU Parameters From Init File
      ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
      Set To Dictionary  ${pdu_parameters_dict}  &{fhgw_pdu_parameters}
    END
    [Return]  ${pdu_parameters_dict}

Get RANNIC Single Radio Module PDU Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${rannic_index}=0  ${ru_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets radio module PDU parameters from TL configuration init file based on radio module index.
    ...  Radio module is connected to RANNIC.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rannic_index           |  No  | Index of RANNIC class instance object list.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ru_index               |  No  | Index of RU (Radio Unit) classes list.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of PDU parameters to which the radio module is connected:
    ...  {'ip_addr': '10.44.167.199', 'model': 'EPC', 'version': '8221-1', 'port_no': 1}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ip_addr}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${ru_index}].pdu_port.pdu.addr}
    ${model}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${ru_index}].pdu_port.pdu.model}
    ${version}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${ru_index}].pdu_port.pdu.version}
    ${pdu_port}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${ru_index}].pdu_port.port_no}
    ${pdu_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  model=${model}  version=${version}  port_no=${pdu_port}
    [Return]  ${pdu_parameters}

Get Single RANNIC Radio Modules PDU Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${rannic_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets radio modules PDU parameters from TL configuration init file.
    ...  Keyword gets radio modules PDU parameters from one RANNIC.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rannic_index           |  No  | Index of RANNIC class instance object list.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of PDU parameters, where the key is the radio module serial number:
    ...  {'1M190413180': {'ip_addr': '10.44.167.199', 'model': 'EPC', 'version': '8221-1', 'port_no': 1}}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_dict}=  Create Dictionary
    ${rmods_connection}=  Get Single RANNIC Radio Module Connection Status From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  rannic_index=${rannic_index}
    Return From Keyword If  not ${rmods_connection}  ${pdu_parameters_dict}

    ${rmods_count}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus}
    FOR  ${rmod_index}  IN RANGE  ${rmods_count}
      ${serial_number}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus[${rmod_index}].serial_number}
      ${pdu_parameters}=  Get RANNIC Single Radio Module PDU Parameters From Init File
      ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  rannic_index=${rannic_index}  ru_index=${rmod_index}
      Set To Dictionary  ${pdu_parameters_dict}  ${serial_number}=${pdu_parameters}
    END
    [Return]  ${pdu_parameters_dict}

Get RANNICs Radio Modules PDU Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets all radio modules PDU parameters from TL configuration init file.
    ...  Keyword gets radio modules PDU parameters from all RANNICs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of PDU parameters, where the key is the radio module serial number:
    ...  {'1M190413180': {'ip_addr': '10.44.167.199', 'model': 'EPC', 'version': '8221-1', 'port_no': 1}}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pdu_parameters_dict}=  Create Dictionary
    ${rannics_connection}=  Get RANNICs Connection Status From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    Return From Keyword If  not ${rannics_connection}  ${pdu_parameters_dict}

    ${rannics_count}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics}
    FOR  ${rannic_index}  IN RANGE  ${rannics_count}
      ${rannic_pdu_parameters}=  Get Single RANNIC Radio Modules PDU Parameters From Init File
      ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  rannic_index=${rannic_index}
      Set To Dictionary  ${pdu_parameters_dict}  &{rannic_pdu_parameters}
    END
    [Return]  ${pdu_parameters_dict}

Get Radio Modules PDU Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets all radio modules PDU parameters from TL configuration init file.
    ...  Keyword gets all radio modules PDU parameters from all FHGWs and RANNICs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of PDU parameters, where the key is the radio module serial number:
    ...  {'1M190413180': {'ip_addr': '10.44.167.199', 'model': 'EPC', 'version': '8221-1'}}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_pdu_parameters}=  Get FHGWs Radio Modules PDU Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${rannic_pdu_parameters}=  Get RANNICs Radio Modules PDU Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${fhgw_rmods_sn_list}=  Get Dictionary Keys  dictionary=${fhgw_pdu_parameters}
    ${rannic_rmods_sn_list}=  Get Dictionary Keys  dictionary=${rannic_pdu_parameters}
    ${rmods_sn_list}=  Combine Lists  ${fhgw_rmods_sn_list}  ${rannic_rmods_sn_list}
    List Should Not Contain Duplicates  ${rmods_sn_list}
    ...  msg=Error in TL configuration file. The same radio modules are connected to FHGW and RANNIC !
    ${pdu_parameters_dict}=  Create Dictionary  &{fhgw_pdu_parameters}  &{rannic_pdu_parameters}
    [Return]  ${pdu_parameters_dict}

#Object Status
Get FHGWs Connection Status From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword returns status if FHGW objects exist in TL configuration file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_connection}=  Run Keyword And Return Status
    ...  Should Not Be Empty  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws}
    [Return]  ${fhgw_connection}

Get Single FHGW Radio Module Connection Status From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword returns status if radio modules are connected to FHGW given by fhgw index.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_connection}=  Run Keyword And Return Status
    ...  Should Not Be Empty  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus}
    [Return]  ${rmods_connection}

Get FHGWs Radio Module Connection Status From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword returns status if radio modules are connected to any FHGW.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_rmods_connection_list}=  Create List
    ${fhgws_connection}=  Get FHGWs Connection Status From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${fhgws_count}=  Run Keyword If  ${fhgws_connection}
    ...  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws}
    ...  ELSE
    ...  Set Variable  ${0}
    FOR  ${fhgw_index}  IN RANGE  ${fhgws_count}
      ${rmods_connection}=  Get Single FHGW Radio Module Connection Status From Init File
      ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
      Append To List  ${fhgw_rmods_connection_list}  ${rmods_connection}
    END
    ${fhgw_rmods_connection}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${fhgw_rmods_connection_list}  ${True}
    [Return]  ${fhgw_rmods_connection}

Get RANNICs Connection Status From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword returns status if RANNIC objects exist in TL configuration file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rannic_connection}=  Run Keyword And Return Status
    ...  Should Not Be Empty  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics}
    [Return]  ${rannic_connection}

Get Single RANNIC Radio Module Connection Status From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${rannic_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword returns status if radio modules are connected to single RANNIC given by rannic index.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rannic_index           |  No  | Index of RANNIC class instance object list.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_connection}=  Run Keyword And Return Status
    ...  Should Not Be Empty  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].rus}
    [Return]  ${rmods_connection}

Get RANNICs Radio Module Connection Status From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword returns status if radio modules are connected to any RANNIC.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rannic_rmods_connection_list}=  Create List
    ${rannics_connection}=  Get RANNICs Connection Status From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${rannics_count}=  Run Keyword If  ${rannics_connection}
    ...  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics}
    ...  ELSE
    ...  Set Variable  ${0}
    FOR  ${rannic_index}  IN RANGE  ${rannics_count}
      ${rmods_connection}=  Get Single RANNIC Radio Module Connection Status From Init File
      ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  rannic_index=${rannic_index}
      Append To List  ${rannic_rmods_connection_list}  ${rmods_connection}
    END
    ${rannic_rmods_connection}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${rannic_rmods_connection_list}  ${True}
    [Return]  ${rannic_rmods_connection}

#GNB
Get Gnb Count From Init File
    [Documentation]
    ...  Description:
    ...  Keyword gets GNB count from TL configuration init file.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_gnbs}=  Set Variable  ${tl.gnbs}
#    ${gnb_count}=  Set Variable  Get Length  ${all_gnbs}
    ${gnb_count}=  Set Variable  ${all_gnbs.__len__()}
    [Return]  ${gnb_count}

#FHGW
Get FHGW Config File Path
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets FHGW configuration file path from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance object  list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_cfg_file_path}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].user_config_path}
    [Return]  ${fhgw_cfg_file_path}

Get FHGW Config Dir Path
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets FHGW configuration directory path.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance object list.                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_cfg_file_path}=  Get FHGW Config File Path  gnb_index=${gnb_index}
    ...  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${fhgw_cfg_dir}  ${fhgw_cfg_file}=  Split String From Right
    ...  string=${fhgw_cfg_file_path}  separator=/  max_split=1
    [Return]  ${fhgw_cfg_dir}

Get FHGW Extra Config File Path
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets FHGW extra configuration file path.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance object list.                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_cfg_dir}=  Get FHGW Config Dir Path  gnb_index=${gnb_index}
    ...  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${fhgw_extra_cfg_file}=  Set Variable  ${fhgw_cfg_dir}/fhgw_extra_config.yaml
    [Return]  ${fhgw_extra_cfg_file}

Get FHGW Ssh Connection Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets FHGW SSH connection parameters.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance object  list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fhgw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ip_addr}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].default_ssh_connection_details.addr}
    ${username}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].default_ssh_connection_details.username}
    ${port}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].default_ssh_connection_details.port}
    ${password}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].default_ssh_connection_details.password}
    ${ssh_connection_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  port=${port}  password=${password}
    [Return]  ${ssh_connection_parameters}

Get FHGW Number From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword returns the number of FHGWs from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance object  list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_number}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws}
    [Return]  ${fhgw_number}

#RANNIC
Get Rannic Number From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword returns the number of RAN NICs from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance object  list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rannic_number}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics}
    [Return]  ${rannic_number}

Get Rannic Serial Numbers From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword returns list of RAN NICs serial numbers number from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance object  list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rannics_serial_numbers_list}=  Create List
    ${rannic_number}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics}
    FOR  ${rannic_index}  IN RANGE  ${rannic_number}
      Append To List  ${rannics_serial_numbers_list}  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rannics[${rannic_index}].serial_number}
    END
    [Return]  ${rannics_serial_numbers_list}
