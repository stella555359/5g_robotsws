*** Settings ***
Documentation    Information obtained from the test line configuration file.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    OperatingSystem
Library    String

*** Keywords ***
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

    ${cnf}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}

#    ${vnf}=  Set Variable
#    ...  ${tl.cloud_hostings[0].control_nodes[0].default_ssh_connection_details.username}
#    Run Keyword If  '${cnf}'=='None'
#    ...  Log  \nIt's VNF.\n  console=True
    ${namespace}=  Set Variable If  '${cnf}'=='None'  ${vnf}  ${cnf}
    [Return]  ${namespace}

Get Host Parameters From Init File
    [Documentation]
    ...  Description:
    ...  Keyword gets host parameters from TL configuration init file.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ip_addr}=  Set Variable  ${tl.test_pc.default_ssh_connection_details.addr}
    ${username}=  Set Variable  ${tl.test_pc.default_ssh_connection_details.username}
    ${password}=  Set Variable  ${tl.test_pc.default_ssh_connection_details.password}
    ${host_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  username=${username}  password=${password}
    [Return]  ${host_parameters}

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
    ...  | pdu_index              |  No  | Index of Pdu (Power Distribution Unit) class list.                         |
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

Get RMOD PDU Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${ru_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets RMOD PDU parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ru_index               |  No  | Index of RU (Radio Unit) classes list.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${serial_number}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}].serial_number}
    ${pdu_port}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}].pdu_port.port_no}
    ${ru_hw_group}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}].ru_hw_group}
    ${rmod_parameters}=  Create Dictionary
    ...  serial_number=${serial_number}  pdu_port=${pdu_port}  ru_hw_group=${ru_hw_group}
    ${ip_addr}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}].pdu_port.pdu.addr}
    ${model}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}].pdu_port.pdu.model}
    ${version}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}].pdu_port.pdu.version}
    ${pdu_parameters}=  Create Dictionary
    ...  ip_addr=${ip_addr}  model=${model}  version=${version}
    [Return]  ${rmod_parameters}  ${pdu_parameters}

Get RMOD Parameters From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${ru_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets RMOD parameters from TL configuration init file.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ru_index               |  No  | Index of RU (Radio Unit) classes list.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${serial_number}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}].serial_number}
    ${pdu_port}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}].pdu_port}
    ${ru_hw_group}=  Set Variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus[${ru_index}].ru_hw_group}
    ${rmod_parameters}=  Create Dictionary
    ...  serial_number=${serial_number}  pdu_port=${pdu_port}  ru_hw_group=${ru_hw_group}
    [Return]  ${rmod_parameters}

Get RMOD Count From Init File
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets RMODs count from TL configuration init file.
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

    ${rmods_count}=  Get Length  item=${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus}
    [Return]  ${rmods_count}

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

Get FHGW Config File Path
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fghw_index}=0
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
    ...  | fghw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_cfg_file_path}=  Set Variable
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fghw_index}].user_config_path}
    [Return]  ${fhgw_cfg_file_path}

Get FHGW Config Dir Path
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fghw_index}=0
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
    ...  | fghw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_cfg_file_path}=  Get FHGW Config File Path  gnb_index=${gnb_index}
    ...  vdu_index=${vdu_index}  fghw_index=${fghw_index}
    ${fhgw_cfg_dir}  ${fhgw_cfg_file}=  Split String From Right
    ...  string=${fhgw_cfg_file_path}  separator=/  max_split=1
    [Return]  ${fhgw_cfg_dir}

Get FHGW Extra Config File Path
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${fghw_index}=0
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
    ...  | fghw_index             |  No  | Index of FHGW class instance object list.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fhgw_cfg_dir}=  Get FHGW Config Dir Path  gnb_index=${gnb_index}
    ...  vdu_index=${vdu_index}  fghw_index=${fghw_index}
    ${fhgw_extra_cfg_file}=  Set Variable  ${fhgw_cfg_dir}/fhgw_extra_config.yaml
    [Return]  ${fhgw_extra_cfg_file}

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
