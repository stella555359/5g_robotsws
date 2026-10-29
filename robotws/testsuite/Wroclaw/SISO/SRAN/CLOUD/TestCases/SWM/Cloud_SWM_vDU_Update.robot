*** Settings ***
Documentation  TODO
...  Author: szymon.przybylak@nokia.com
...  Maintainer: szymon.przybylak@nokia.com

Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.transport.ssh  WITH NAME  tafssh
Library    ../../../resources/artifactory.py  WITH NAME  artifactory
Library    ../../../CLOUD/resources/python/common.py
Resource   ../../resources/Robot/vdu_oam_operations.robot

*** Variables ***
${ARTIFACTORY_URL}  https://artifactory-espoo1.int.net.nokia.com/artifactory/radio-factory-btssw-knives-local/cran_sw_update_tools/
${TRUNK}    vDUCNF26R1
${SW_ARTI}  https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${CCR_LOCATION}   # wg or wl
@{VDU_SWM_UPDATE_ALLOWED_ALARMS}=  faultId=23, severity=critical
@{VCU_SWM_UPDATE_ALLOWED_ALARMS}=  faultId=7104, severity=critical
${EXECUTE_CCR}  False  #If there is no ccr on server, this variable has to be set by tester to True
*** Keywords ***
TC__Cloud_SWM_vDU_Update
  [Arguments]  ${scfc_file_path}  ${build_name}=${EMPTY}
  [Documentation]
  ...  Description:
  ...  Test for Vdu Software Update. Can be also used as a separate keyword.
  ...
  ...  Tester has to set ${CCR_LOCATION} to wg/wl in testsuite.
  ...  Tester can set the target vdu software in TC using argument ${build_name} in teststuite, e.g. build_name=vDUCNF00_0.300.24408
  ...  If not set or the target software version is the same as current on vdu, the test will first do downgrade
  ...  to ensure that the target software is the one that is checked (RUs have to be updated in order to check all functions).
  ...
  ...  For this TC/KW to work, tester has to prepare override files. The files (each named values-override.yaml) can be taken from
  ...  kuafu deployment, from corresponding folders for aic-vdu, aic-vdu-prerequisites, aic-vdu-cluster-preparations. Files should be stored in e.g.
  ...  /home/ute/testline_configuration/10_16_UTESRANSISO705/values_override/vDU
  ...  Names of the files should be:
  ...  main.yaml (for aic-vdu), preparation.yaml (for aic-vdu-cluster-preparations), prerequisites.yaml (for aic-vdu-prerequisites).
  ...
  ...  Step 1: Preconditions
  ...         1) Preparing commonly used variables needed in vdu udpate
  ...         2) Downloading and downgrading vDU software to older (if necessary)
  ...         3) Checking if vDU is onAir
  ...  Step 2: Update software to tested version
  ...         1) Downloading and uploading to server software build, conversionApp and onBoardingApp
  ...         2) Unpacking required software files
  ...         3) Onboarding image
  ...         4) Converting values override files
  ...         5) Installing or upgrading charts
  ...         6) Uploading SCFC after deployment and waiting for all cells onAir
  ...
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | build_name             | No   | Target Build name to be tested.  e.g. vDUCNF00_0.300.24408                 |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: szymon.przybylak@nokia.com
  ...  Maintainer: szymon.przybylak@nokia.com
  Set Test Variable  ${SCFC_FILE_PATH}  ${scfc_file_path}
  Set Test Variable  ${IS_PASSED}  False
  Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_SWM_UPDATE_ALLOWED_ALARMS}
  Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_SWM_UPDATE_ALLOWED_ALARMS}
  Step 1: Preconditions vDU Update  build_name=${build_name}
  Step 2: Update software to tested version
  [Teardown]  Software Update Teardown

Software Update Teardown
  Log  ${start_prefix_green}Software Update Teardown  console=${log_to_console}
  IF  ${RECOVERY_NEEDED}
    Perform vDU Update  build_name=${BASE_BUILD}
  END
  IF  ${IS_PASSED}
    tafssh.Connect To  hostname=${cloud_server_ip}
    ...  username=core
    ...  password=system123
    ...  alias=${ssh_conn}
    tafssh.Send Command  rm -r /var/home/core/${tl.tl_cloud_topology}    connection=${ssh_conn}
  END
  Log  ${ok_prefix_green}Software Update Teardown  console=${log_to_console}

Step 1: Preconditions vDU Update
    [Arguments]  ${build_name}  ${log_to_console}=True
    [Documentation]
    ...  Step 1: Preconditions
    ...  Keyword for preparing commonly used variables needed in vdu udpate and downgrading vDU software to older.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    Log  ${start_prefix_green}Step 1: Preconditions vDU Update  console=${log_to_console}
    Software Update Preconditions  ${build_name}
    # Downgrade vdu build if necessary
    IF  '${VDU_CONV_RUNNING_BUILD}'=='${base_build}'
      Log  ${info_prefix}Downgrade necessary.  console=${log_to_console}
      Perform vDU Update  build_name=${DOWNGRADE_BUILD}  downgrade=True
    ELSE
      Log  ${info_prefix}Vdu Downgrade skipped.  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 1: Preconditions vDU Update  console=${log_to_console}

Step 2: Update software to tested version
    [Documentation]
    ...  Step 2: Update software to tested version
    ...  Keyword for upgrading vdu software to tested version
    ...
    ...  Author:
    Log  ${info_prefix}Step 2: Update software to tested version  console=${log_to_console}
    Log  ${info_prefix}Performing vDU update to ${BASE_BUILD}  console=${log_to_console}
    Perform vDU Update  build_name=${BASE_BUILD}
    Set Test Variable  ${IS_PASSED}  True

Software Update Preconditions
    [Arguments]    ${build_name}
    ${ssh_conn}  vDU Rest Login
    ${hostname}=  Fetch From Right  ${tl.tl_cloud_topology}  CLOUD_AIC_
    Set Test Variable  ${HOSTNAME}  ${hostname}
    Set Test Variable  ${default_main_chart}  /home/ute/testline_configuration/${hostname}/values_override/vDU/main.yaml
    Set Test Variable  ${default_prep_chart}  /home/ute/testline_configuration/${hostname}/values_override/vDU/preparation.yaml
    Set Test Variable  ${default_prereq_chart}  /home/ute/testline_configuration/${hostname}/values_override/vDU/prerequisites.yaml
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=False
    Set Test Variable  ${MRBTS}  ${mrbts_id}
    Set Test Variable  ${SSH_CONN}  ${ssh_conn}
    Set Test Variable  ${RECOVERY_NEEDED}  False
    Set Test Variable  ${DU_k8s_addr}  ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    Set Test Variable  ${DU_k8s_user}  ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    Set Test Variable  ${DU_k8s_pwd}  ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    Set Test Variable  ${DU_k8s_port}  ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    Set Test Variable  ${DU_namespace}  ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}  #namespace

    @{charts_to_convert}=  Create List  ${default_main_chart}  ${default_prep_chart}  ${default_prereq_chart}
    Set Test Variable  ${charts_to_convert}
    ${charts_names}=  Create List  ${MRBTS}-cluster-preparation  ${MRBTS}-prerequisite  ${MRBTS}
    Set Test Variable  ${charts_names}
    ${vdu_current_build}    vDU Get Running Software Version    vdu_login=False
    ${running_release}  Fetch From Left  string=${vdu_current_build}  marker=_
    ${running_release}  Set Variable If  '${running_release}' == '${TRUNK}'  vDUCNF00  ${running_release}
    ${vdu_current_build_ver}  Fetch From Right  string=${vdu_current_build}  marker=_
    Set Test Variable  ${VDU_CONV_RUNNING_BUILD}  ${running_release}_${vdu_current_build_ver}
    Set Test Variable  ${vdu_current_build}  ${vdu_current_build}
    Log  ${build_name}
    ${build_not_set}  Run Keyword And Return Status  Should Be Empty  ${build_name}
    IF  ${build_not_set}
      ${base_build}  Set Variable  ${vdu_current_build}
    ELSE
      ${base_build}  Set Variable  ${build_name}
    END
    ${release}=  Fetch From Left  string=${base_build}  marker=_
    ${release}=  Set Variable If  '${release}' == '${TRUNK}'  vDUCNF00  ${release}
    ${build_version}=  Fetch From Right  string=${base_build}
    ...  marker=_
    Set Test Variable    ${BASE_BUILD}    ${release}_${build_version}
    Set Test Variable  ${RELEASE}  ${release}
    ${last_builds_list}  Get Latest Promoted Builds For Branch    ${release}  30
    ${current_build_index}  Get Index From List  ${last_builds_list}  ${base_build}
    ${go_to_index}  Evaluate  ${current_build_index} + 1
    Set Test Variable  ${DOWNGRADE_BUILD}  ${last_builds_list}[${go_to_index}]
    @{parts}=  Split String  ${DOWNGRADE_BUILD}  _
    ${build_prefix}=  Get From List  ${parts}  0
    ${short_build_name}=  Get From List  ${parts}  1
    ${pkg_suffix}  Set Variable  -amd64
    Set Test Variable  ${PKG_SUFFIX}  ${pkg_suffix}
    Set Test Variable  ${SHORT_BUILD_NAME}  ${short_build_name}

    Set Test Variable  ${LOG_TO_CONSOLE}  True

    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    Set Test Variable  ${CELLS_COUNT}  ${cells_count}

    ${vdu_k8s_connection_params}  Get vDU K8s Master Node Connection Parameters From Init File
    Set Test Variable  ${CLOUD_SERVER_IP}  ${vdu_k8s_connection_params['ip_addr']}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Check All Tools On Server

Download Required Files
    [Arguments]  ${build_name}
    [Documentation]
    ...  Keyword for downloading to server software build, conversionApp and onBoardingApp.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | build_name             | Yes  | Build name to be downloaded.  e.g. vDUCNF00_0.300.24408                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${release}=  Fetch From Left  string=${build_name}
    ...  marker=_
    ${release}=  Set Variable If  '${release}' == '${TRUNK}'  vDUCNF00  ${release}
    ${build_version}=  Fetch From Right  string=${build_name}
    ...  marker=_
    Set Test Variable  ${target_path}  /var/home/core/${tl.tl_cloud_topology}/${release}_${build_version}
    ${url_soft}  Set Variable  ${SW_ARTI}/${release}/${release}_${build_version}/${release}_${build_version}${pkg_suffix}.zip
    ${url_conv_app}  Set Variable  ${SW_ARTI}/${release}/${release}_${build_version}/artifacts/conversionApp-${build_version}${pkg_suffix}.tar.gz
    ${url_onboard_app}  Set Variable  ${SW_ARTI}/${release}/${release}_${build_version}/artifacts/onBoardingApp.tgz

    tafssh.Connect To  hostname=${cloud_server_ip}
    ...  username=core
    ...  password=system123
    ...  alias=${ssh_conn}
    tafssh.Send Command  mkdir --parents ${target_path}  connection=${ssh_conn}
    #Download Software
#    TODO: ustawic poprawny download
    Log  ${info_prefix}Download build ${build_name} to server  console=${log_to_console}
    ${output_package_download}  tafssh.Execute
    ...  curl -u ca_vrf_wro4_ta:WRO4pass! -o ${target_path}/${release}_${build_version}${pkg_suffix}.zip ${url_soft}  connection=${ssh_conn}
    Log  ${output_package_download}  console=${true}
#    tafssh.Send Command  cp /var/home/core/${release}_${build_version}${pkg_suffix}.zip ${target_path}/${release}_${build_version}${pkg_suffix}.zip
#    ...  connection=${ssh_conn}
    Wait Until Keyword Succeeds  30  5  Check File Downloaded  file=${target_path}/${release}_${build_version}${pkg_suffix}.zip

    #Download onboardingApp
    Log  ${info_prefix}Download onBoardingApp to server  console=${log_to_console}
    ${status}  tafssh.Execute  curl -u ca_vrf_wro4_ta:WRO4pass! -o ${target_path}/onBoardingApp.tgz ${url_onboard_app}  connection=${ssh_conn}
    Log  ${status}  console=${true}
    Wait Until Keyword Succeeds  5  1  Check File Downloaded  file=${target_path}/onBoardingApp.tgz

    # Download conversionApp
    Log  ${info_prefix}Download conversionApp-${build_version}${pkg_suffix}.tar.gz to server  console=${log_to_console}
    ${status}  tafssh.Execute
    ...  curl -u ca_vrf_wro4_ta:WRO4pass! -o ${target_path}/conversionApp-${build_version}${pkg_suffix}.tar.gz ${url_conv_app}  connection=${ssh_conn}
    Log  ${status}  console=${true}
    Wait Until Keyword Succeeds  5  1  Check File Downloaded  file=${target_path}/conversionApp-${build_version}${pkg_suffix}.tar.gz
    ${package_path}  Set Variable  ${target_path}/${release}_${build_version}${pkg_suffix}.zip
    ${conversionApp_path}  Set Variable  ${target_path}/conversionApp-${build_version}${pkg_suffix}.tar.gz
    ${onboardingApp_path}  Set Variable  ${target_path}/onBoardingApp.tgz
    Log  ${info_prefix}Build, conversionApp and onBoardingApp are on server  console=${log_to_console}

  [Return]  ${package_path}  ${conversionApp_path}  ${onboardingApp_path}

Check File Downloaded
    [Arguments]  ${file}
    [Documentation]
    ...  Keyword for checking if file exists
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | file                   | Yes  | File localization                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    ${file_exists}  tafssh.File Exists  ${file}  connection=${ssh_conn}
    Should Be True  ${file_exists}
    Log  ${file} exists    console=True

Perform vDU Update
    [Arguments]    ${build_name}  ${downgrade}=False
    [Documentation]
    ...  Keyword for performing full vDU update
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | build_name             | Yes  | vDU build name to be downloaded.  e.g. vDUCNF00_0.300.24408                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | downgrade              | No   | If True, recovery will be activated                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${start_prefix_green}Performing vDU update to ${build_name}  console=${log_to_console}
    Set Test Variable  ${TARGET_PATH}  /var/home/core/${tl.tl_cloud_topology}/${build_name}
    Set Test Variable  ${helm_chart_dir}  ${target_path}/HelmChart
    Set Test Variable  ${conversionApp_dir}  ${target_path}/conversionApp
    Set Test Variable  ${converted_prep_path}  ${conversionApp_dir}/prep_new.yaml
    Set Test Variable  ${converted_preq_path}  ${conversionApp_dir}/prereq_new.yaml
    Set Test Variable  ${converted_main_path}  ${conversionApp_dir}/main_new.yaml

    ${package_path}  ${conversionApp_path}  ${onboardingApp_path}  Download Required Files  build_name=${build_name}
    Set Test Variable  ${package_path}
    Set Test Variable  ${conversionApp_path}
    Set Test Variable  ${onboardingApp_path}
    Unpack required software files  ${package_path}  ${conversionApp_path}  ${onboardingApp_path}  ${target_path}  ${ssh_conn}  ${build_name}
    IF  ${EXECUTE_CCR}
        Images Onboarding  hw_type=vdu  ccr_location=${CCR_LOCATION}
    ELSE
        Log  ${info_prefix}Images Onboarding Skipped!  console=${log_to_console}
    END
    Convert Values Override For Different Clusters  vDU  ${ssh_conn}
    ${charts_to_be_installed}=  Get Required Charts From HelmChart Directory  hw_type=vdu  helm_chart_path=${helm_chart_dir}  connection=${ssh_conn}
    IF  ${downgrade}
        Set Test Variable  ${RECOVERY_NEEDED}  True
    ELSE
        Set Test Variable  ${RECOVERY_NEEDED}  False
    END
    Remove Existing Charts   hw_type=vdu  chart_name=all  conn=${ssh_conn}
    Install Or Upgrade Charts
    ...  hw=vdu
    ...  cran=${DU_namespace}
    ...  helm_dir_path=${helm_chart_dir}
    ...  chart_name=${charts_names[0]}
    ...  helm_chart_path=${charts_to_be_installed[0]}
    ...  path_to_yaml_file=${converted_prep_path}
    ...  conn=${ssh_conn}
    Install Or Upgrade Charts
    ...  hw=vdu
    ...  cran=${DU_namespace}
    ...  helm_dir_path=${helm_chart_dir}
    ...  chart_name=${charts_names[1]}
    ...  helm_chart_path=${charts_to_be_installed[1]}
    ...  path_to_yaml_file=${converted_preq_path}
    ...  conn=${ssh_conn}
    Install Or Upgrade Charts
    ...  hw=vdu
    ...  cran=${DU_namespace}
    ...  helm_dir_path=${helm_chart_dir}
    ...  chart_name=${charts_names[2]}
    ...  helm_chart_path=${charts_to_be_installed[2]}
    ...  path_to_yaml_file=${converted_main_path}
    ...  conn=${ssh_conn}
    ...  timeout=900
    ${build_version}=  Fetch From Right  string=${build_name}
    ...  marker=_
    tafssh.Send Command  kubectl get pods -n ${DU_namespace}  connection=${ssh_conn}
    ${output}  tafssh.Read Output  connection=${ssh_conn}
    should Contain    ${output}    healing-controller
    tafssh.Send Command  helm list -n ${DU_namespace}  connection=${ssh_conn}
    ${result}  tafssh.Read Output  connection=${ssh_conn}
    Should Contain  ${result}  ${build_version}
    Upload SCFC After Deployment And Wait For All Cells OnAir


Images Onboarding
    [Arguments]  ${hw_type}  ${ccr_location}
    [Documentation]
    ...  Description:
    ...  KW load images, for vCU/vDU depends on hw_type argument.
    ...  Tags loaded images and push them to chosen ccr depends on ccr_location argument.
    ...  **Example of simple usage:**
    ...  Images Onboarding  hw_type=vcu/vdu  ccr_location=wl/wg
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | hw_type                | Yes  |  Hardware type (vdu or vcu).                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ccr_location           | Yes  |  Location of CCR (wl or wg).                                               |
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${ccr}=  Set Variable  ccr-${ccr_location}-vrf-${hw_type}-01.wroclaw.nsn-rdnet.net:443/${hw_type}/
    ${ccr_url}=  Set Variable  https://ccr-${ccr_location}-vrf-${hw_type}-01.wroclaw.nsn-rdnet.net:443/${hw_type}/
    ${certs_dir_path}=  Set Variable  /var/home/core/vrfrepos/
    ${image_path}=  Set Variable  ${target_path}/Image/${hw_type}-image.tar
    ${output}=  tafssh.Execute  podman load -i ${image_path}  connection=${ssh_conn}  timeout=300
    Log  ${output}  console=${true}
    tafssh.Assert Exit Status  0  connection=${ssh_conn}
    Create CCR Certs On Core
    Login To CCR  ccr_url=${ccr_url}  certs_dir=${certs_dir_path}  ccr_location=${ccr_location}  hw_type=${hw_type}
    ${output}=  tafssh.Execute  podman image list --format "{{.Repository}} {{.Tag}} {{.ID}}"  connection=${ssh_conn}
    ${cleaned_output}=  Strip String  ${output}
    ${images_data}=  Split String  ${cleaned_output}  \r\n
    ${grouped_images}=  Create List
    FOR  ${image}  IN  @{images_data}
        ${parts}=  Split String  ${image}
        ${repo}=  Set Variable  ${parts}[0]
        ${repo}=  Replace String  ${repo}  localhost/  ${EMPTY}
        IF  ${ccr} in ${repo}
            ${repo}=  Replace String  ${repo}  ${ccr}  ${EMPTY}
        END
        ${tag}=  Set Variable  ${parts}[1]
        ${image_id}=  Set Variable  ${parts}[2]
        ${image_dict}=  Create Dictionary  repo=${repo}  tag=${tag}  image_id=${image_id}
        Append To List  ${grouped_images}  ${image_dict}
      END
    FOR  ${image}  IN  @{grouped_images}
        ${output}=  tafssh.Execute  podman tag ${image}[image_id] ${ccr}${image}[repo]:${image}[tag]  connection=${ssh_conn}
        Log  podman tag ${image}[image_id] ${ccr}${image}[repo]:${image}[tag]  console=${true}
        Log  ${output}  console=${true}
        tafssh.Assert Exit Status  0  connection=${ssh_conn}
        ${output}=  tafssh.Execute  podman push ${ccr}${image}[repo]:${image}[tag] --cert-dir=${certs_dir_path}  connection=${ssh_conn}
        Log  ${output}  console=${true}
        tafssh.Assert Exit Status  0  connection=${ssh_conn}
    END
    ${output}=  tafssh.Execute  podman image rm -a  connection=${ssh_conn}
    Log  ${output}  console=${true}
    tafssh.Assert Exit Status  0  connection=${ssh_conn}
    [Teardown]  tafssh.Execute  podman image rm -a  connection=${ssh_conn}

Create CCR Certs On Core
    [Documentation]  Description: KW uploads ccrAuthorization.sh, ca_vrf_wg_vcu, ca_vrf_wg_vcu, ca_vrf_wl_vcu, ca_vrf_wl_vdu files to core. \
    ...              Ensures ccrAuthorization.sh is executable. And execute it.

    ${cert_script}=  Set Variable  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/CLOUD/resources/ccr/ccrAuthorization.sh
    ${wg_vcu}=  Set Variable  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/CLOUD/resources/ccr/ca_vrf_wg_vcu.txt
    ${wg_vdu}=  Set Variable  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/CLOUD/resources/ccr/ca_vrf_wg_vdu.txt
    ${wl_vcu}=  Set Variable  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/CLOUD/resources/ccr/ca_vrf_wl_vcu.txt
    ${wl_vdu}=  Set Variable  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/CLOUD/resources/ccr/ca_vrf_wl_vdu.txt

    ${output}=  tafssh.Upload File  ${cert_script}  /var/home/core/ccrAuthorization.sh  connection=${ssh_conn}
    Log   ${output}  console=${true}
    ${output}=  tafssh.Upload File  ${wg_vcu}  /var/home/core/ca_vrf_wg_vcu.txt  connection=${ssh_conn}
    Log   ${output}  console=${true}
    ${output}=  tafssh.Upload File  ${wg_vdu}  /var/home/core/ca_vrf_wg_vdu.txt  connection=${ssh_conn}
    Log   ${output}  console=${true}
    ${output}=  tafssh.Upload File  ${wl_vcu}  /var/home/core/ca_vrf_wl_vcu.txt  connection=${ssh_conn}
    Log   ${output}  console=${true}
    ${output}=  tafssh.Upload File  ${wl_vdu}  /var/home/core/ca_vrf_wl_vdu.txt  connection=${ssh_conn}
    Log   ${output}  console=${true}

    ${file_exist}=  tafssh.Execute  test -f "/var/home/core/ccrAuthorization.sh" && echo OK || echo FAIL  connection=${ssh_conn}
    ${file_exist}=  Strip String  ${file_exist}
    Should Be Equal  ${file_exist}  OK
    ${file_exist}=  tafssh.Execute  test -f "/var/home/core/ca_vrf_wg_vcu.txt" && echo OK || echo FAIL  connection=${ssh_conn}
    ${file_exist}=  Strip String  ${file_exist}
    Should Be Equal  ${file_exist}  OK
    ${file_exist}=  tafssh.Execute  test -f "/var/home/core/ca_vrf_wg_vdu.txt" && echo OK || echo FAIL  connection=${ssh_conn}
    ${file_exist}=  Strip String  ${file_exist}
    Should Be Equal  ${file_exist}  OK
    ${file_exist}=  tafssh.Execute  test -f "/var/home/core/ca_vrf_wl_vcu.txt" && echo OK || echo FAIL  connection=${ssh_conn}
    ${file_exist}=  Strip String  ${file_exist}
    Should Be Equal  ${file_exist}  OK
    ${file_exist}=  tafssh.Execute  test -f "/var/home/core/ca_vrf_wl_vdu.txt" && echo OK || echo FAIL  connection=${ssh_conn}
    ${file_exist}=  Strip String  ${file_exist}
    Should Be Equal  ${file_exist}  OK

    tafssh.Execute  chmod +x ccrAuthorization.sh   connection=${ssh_conn}
    ${output}=  tafssh.Execute  ./ccrAuthorization.sh ca_vrf_wg_vcu.txt ca_vrf_wg_vdu.txt ca_vrf_wl_vcu.txt ca_vrf_wl_vdu.txt
    ...  connection=${ssh_conn}
    tafssh.Assert Exit Status  0  connection=${ssh_conn}
    Log  ${output}  console=${true}

Login To CCR
    [Arguments]  ${ccr_url}  ${certs_dir}  ${ccr_location}  ${hw_type}
    [Documentation]
    ...  Description:
    ...  KW logins to chosen ccr based on ccr_location and hw_type arguments.
    ...
    ...   Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ccr_url                | Yes  |  URL of CCR.                                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | certs_dir              | Yes  |  Path to the directory with certs.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ccr_location           | Yes  |  Location of CCR (wl or wg).                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_type                | Yes  |  Hardware type (vdu or vcu).                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${ccr_wl_vdu_pass}=  Set Variable  ObCV0W80KGzzazO1aCRKDU25DozYU338
    ${ccr_wg_vdu_pass}=  Set Variable  zS8IxZm4R6H8Heu2NWFmd8wQMCRDv3b9
    ${ccr_wl_vcu_pass}=  Set Variable  biG31GZUCZ0XCUIWVGp8eaKsHBzH8nIR
    ${ccr_wg_vcu_pass}=  Set Variable  swqgJTZSPBt4XHcfgeyz8DErRyXjgj5R
    Run Keyword If  '${ccr_location}'=='wl' and '${hw_type}'=='vcu'
    ...  tafssh.Execute  podman login ${ccr_url} --cert-dir=${certs_dir} --username=robot\\$vrf --password=${ccr_wl_vcu_pass}  connection=${ssh_conn}
    ...  ELSE IF  '${ccr_location}'=='wl' and '${hw_type}'=='vdu'
    ...  tafssh.Execute  podman login ${ccr_url} --cert-dir=${certs_dir} --username=robot\\$vrf --password=${ccr_wl_vdu_pass}  connection=${ssh_conn}
    ...  ELSE IF  '${ccr_location}'=='wg' and '${hw_type}'=='vcu'
    ...  tafssh.Execute  podman login ${ccr_url} --cert-dir=${certs_dir} --username=robot\\$vrf --password=${ccr_wg_vcu_pass}  connection=${ssh_conn}
    ...  ELSE IF  '${ccr_location}'=='wg' and '${hw_type}'=='vdu'
    ...  tafssh.Execute  podman login ${ccr_url} --cert-dir=${certs_dir} --username=robot\\$vrf --password=${ccr_wg_vdu_pass}  connection=${ssh_conn}
    tafssh.Assert Exit Status  0  connection=${ssh_conn}

Get Names And Status From Helm List
    [Arguments]  ${output}
    [Documentation]
    ...  Description:
    ...  KW getting actual chart names and statuses
    ...  Input:          Input should be as json: helm list -A -a --output json.
    ...  Output:         Return list of dictionaries exmp. [{Name:'vcu8780-prerequisite', Status:'deployed'}]
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | output                 | Yes  |  Output from helm list -A -a --output json.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${cleaned_output}=  Strip String  ${output}
    ${charts_json_data}=  Evaluate  json.loads('${cleaned_output}')
    ${deployed_charts}=  Create List
    FOR  ${item}  IN  @{charts_json_data}
        ${name}=  Get From Dictionary  ${item}  name
        ${status}=  Get From Dictionary  ${item}  status
        ${chart}=  Get From Dictionary  ${item}  chart
        ${dict_item}=  Create Dictionary  Name=${name}  Status=${status}  Chart=${chart}
        Append To List  ${deployed_charts}  ${dict_item}
    END
    [Return]  ${deployed_charts}

Check If Charts Deployed
    [Arguments]  ${charts_list}
    [Documentation]
    ...  Description:
    ...  KW checks if all charts are deployed
    ...  **Example of simple usage:**
    ...  Check If Charts Deployed  ${deployed_charts}
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | charts_list            | Yes  |  List of dictionaries with chart names and statuses.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${all_deployed}=  Set Variable  True
    FOR  ${chart}  IN  @{charts_list}
        ${name}=  Get From Dictionary  ${chart}  Name
        ${status}=  Get From Dictionary  ${chart}  Status
        Should Be Equal  ${status}  deployed
        Log  ${name}: deployed  console=${true}
    END

Convert Values Override For Different Clusters
    [Arguments]  ${hw_type}  ${conn}
    [Documentation]
    ...  Description:
    ...  KW copy default values override from repo, convert it and stores on the core
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | hw_type                | Yes  |  Hardware type (vdu or vcu).                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | conn                  | Yes  |  Connection to ssh.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

#   Unpack cnf_userinput_conversion
    ${list_of_files_1}=  tafssh.Execute  cd ${target_path}/conversionApp && ls  connection=${conn}
    @{list_of_files}=  Split String  ${list_of_files_1}
    ${tar_gz_files}=  Evaluate  [file for file in ${list_of_files} if file.endswith('.tar.gz')]
    Log  ${tar_gz_files}  console=${true}
    ${unpack_cnf_user_inpt}=  tafssh.Execute  cd ${target_path}/conversionApp && tar -xvzf ${tar_gz_files[0]}  connection=${conn}
    tafssh.Assert Exit Status  0  connection=${conn}
#   Upload values-override from repo to core
    tafssh.Execute  mkdir ${target_path}/valuesToBeConverted  connection=${conn}
    ${output}=  tafssh.Upload File  ${charts_to_convert}  ${target_path}/valuesToBeConverted   connection=${conn}
#    tafssh.Assert Exit Status  0  connection=${conn}
    ${file_exists}  tafssh.File Exists  ${target_path}/valuesToBeConverted/main.yaml  connection=${ssh_conn}
    IF  not ${file_exists}
        Log  ${info_prefix}${tool_name} exists on server.  console=${log_to_console}
    END
    ${file_exists}  tafssh.File Exists  ${target_path}/valuesToBeConverted/preparation.yaml  connection=${ssh_conn}
    IF  not ${file_exists}
        Fail
    END
        ${file_exists}  tafssh.File Exists  ${target_path}/valuesToBeConverted/prerequisites.yaml  connection=${ssh_conn}
    IF  not ${file_exists}
        Fail
    END
#    Upload values-override from repo to core END
    Set Test Variable  ${main_chart}  ${target_path}/valuesToBeConverted/main.yaml
    Set Test Variable  ${prep_chart}  ${target_path}/valuesToBeConverted/preparation.yaml
    Set Test Variable  ${prereq_chart}  ${target_path}/valuesToBeConverted/prerequisites.yaml
    ${conv_main_cm}=  Run Keyword If  '${hw_type}'=='vCU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${main_chart} -t values-override.aic-vcu.tpl -o main_new.yaml
    ...  ELSE IF  '${hw_type}'=='vDU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${main_chart} -t values-override.aic-vdu.tpl -o main_new.yaml
    ${conv_prep_cm}=  Run Keyword If  '${hw_type}'=='vCU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${prep_chart} -t values-override.aic-vcu-cluster-preparation.tpl -o prep_new.yaml
    ...  ELSE IF  '${hw_type}'=='vDU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${prep_chart} -t values-override.aic-vdu-cluster-preparation.tpl -o prep_new.yaml
    ${conv_preq_cm}=  Run Keyword If  '${hw_type}'=='vCU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${prereq_chart} -t values-override.aic-vcu-prerequisite.tpl -o prereq_new.yaml
    ...  ELSE IF  '${hw_type}'=='vDU'
    ...  Set Variable  ./cnf_userinput_conversion -s ${prereq_chart} -t values-override.aic-vdu-prerequisite.tpl -o prereq_new.yaml
    ${commands_for_convertion}=  Create List  ${conv_main_cm}  ${conv_prep_cm}  ${conv_preq_cm}
    Log  ${commands_for_convertion}  console=${true}
    Log   Converting Of Values Override
    FOR  ${command}  IN  @{commands_for_convertion}
        tafssh.Execute  cd ${target_path}/conversionApp && ${command}  connection=${conn}
        Log  Executing ${command}  console=${true}
        tafssh.Assert Exit Status  0  connection=${conn}
    END

Get Required Charts From HelmChart Directory
    [Arguments]  ${hw_type}  ${helm_chart_path}  ${connection}=admin
    [Documentation]
    ...  Description:
    ...  KW get required .tgz chart files that will be installed from HelmChart folder
    ...                Input:          helm_chart_path=/var/home/core/0.250.26816_upgrade/HelmChart/
    ...                                connection=admin
    ...                Output:         Ordered list of charts files .tgz (order: prep; prereq; main)
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | hw_type                | Yes  |  Hardware type (vdu or vcu).                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | helm_chart_path        | Yes  |  Path to the directory with charts.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             | No   |  Connection to ssh.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${list_helm}=  tafssh.Execute  cd ${helm_chart_path} && ls  ${connection}
    @{ls_helm}=  Split String  ${list_helm}
    ${aic_files}=  Evaluate  [file for file in ${ls_helm} if file.startswith('aic-${hw_type}')]
    ${needed_charts}=  Get Slice From List  ${aic_files}  0  3
    ${last_two_charts}=  Get Slice From List  ${needed_charts}  -2
    ${main_chart}=  Get Slice From List  ${needed_charts}  0  -2
    @{charts_to_be_installed}=  Create List  ${last_two_charts[0]}  ${last_two_charts[1]}  @{main_chart}
    Set Test Variable  ${charts_to_be_installed}
    Log  ${charts_to_be_installed}  console=${true}
    [Return]  ${charts_to_be_installed}

Unpack required software files
    [Arguments]  ${package_path}  ${conversionApp_path}  ${onboardingApp_path}  ${storage_dir}  ${conn}  ${build_name}  ${uprg_roll}=upgrade
    [Documentation]
    ...  Description:
    ...  KW unpack sw packages for vcu/vdu, onBoardingApp, convertionApp
    ...                Input:          package_path=/path/to/each/package
    ...                                storage_dir=/path/under/which/zipped/packages/stored
    ...                                SW_PACKAGE:vCUCNF00_0.250.27004
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | package_path           | Yes  | Path to the zipped package.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | conversionApp_path     | Yes  | Path to the conversionApp package.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | onboardingApp_path      | Yes  | Path to the onBoardingApp package.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | storage_dir            | Yes  | Path to the directory where the packages are stored.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | conn                   | Yes  | Connection to ssh.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | build_name             | Yes  | Build name to be downloaded.  e.g. vDUCNF00_0.300.24408                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | uprg_roll              | No   | set to upgrade                                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

   Log   Unpacking Of Downloaded Files Started  console=${true}
   ${unzip_package_output}=  tafssh.Execute  cd ${storage_dir} && 7za x -y ${package_path}  connection=${conn}
   ${status}  Run Keyword And Return Status  tafssh.Assert Exit Status  0  connection=${conn}
   IF  not ${status}
     tafssh.Execute  cd ${storage_dir}  connection=${conn}
     ${unzip_package_output}=  tafssh.Execute  7za x -y ${package_path}  connection=${conn}
     ${status}  Run Keyword And Return Status  tafssh.Assert Exit Status  0  connection=${conn}
   END
#   tafssh.Disconnect  connection=${conn}
   Log   check   console=${true}
#   tafssh.Connect To  hostname=${cloud_server_ip}
#   ...  username=core
#   ...  password=system123
#   ...  alias=${ssh_conn}
    ${unzip_package_output}=  Run Keyword If  '${release}'=='vCUCNF25R1' and '${uprg_roll}'=='rollaback'
    ...  tafssh.Execute  cd ${storage_dir} && unzip -q ${rollback_sw}-amd64.zip  connection=${conn}
    ...  ELSE IF  ('${release}'=='vCUCNF00' or '${release}'=='vCUCNF25R2') and '${uprg_roll}'=='rollaback'
    ...  tafssh.Execute  cd ${storage_dir} && unzip -q ${rollback_sw}-amd64.zip  connection=${conn}
    ...  ELSE IF  '${release}'=='vDUCNF25R1' and '${uprg_roll}'=='rollaback'
    ...  tafssh.Execute  cd ${storage_dir} && unzip -q ${rollback_sw}-amd64.zip  connection=${conn}
    ...  ELSE IF  ('${release}'=='vDUCNF00' or '${release}'=='vDUCNF25R2') and '${uprg_roll}'=='rollaback'
    ...  tafssh.Execute  cd ${storage_dir} && unzip -q ${rollback_sw}-amd64.zip  connection=${conn}
    ...  ELSE IF  ('${release}'=='vDUCNF00' or '${release}'=='vDUCNF25R2') and '${uprg_roll}'=='upgrade'
    ...  tafssh.Execute  cd ${storage_dir} && 7za x -y ${build_name}-amd64.zip  connection=${conn}
    ...  ELSE IF  ('${release}'=='vCUCNF00' or '${release}'=='vCUCNF25R2') and '${uprg_roll}'=='upgrade'
    ...  tafssh.Execute  cd ${storage_dir} && 7za x -y ${SW_VCU}-amd64.zip  connection=${conn}
    tafssh.Assert Exit Status  0  connection=${conn}
    Log  ${storage_dir}: UNZIPPED  console=${true}
    ${unpack_convertionApp_output}=  tafssh.Execute  cd ${storage_dir} && tar -xvzf ${conversionApp_path}  connection=${conn}
    tafssh.Assert Exit Status  0  connection=${conn}
    Log  ${conversionApp_path}: UNPACKED   console=${true}
    ${unpack_onBoardingApp_output}=  tafssh.Execute  cd ${storage_dir} && tar -xvzf ${onboardingApp_path}  connection=${conn}
    tafssh.Assert Exit Status  0  connection=${conn}
    Log  ${onboardingApp_path}: UNPACKED  console=${true}

Install Or Upgrade Charts
    [Arguments]  ${hw}  ${cran}  ${helm_dir_path}  ${chart_name}  ${helm_chart_path}
    ...          ${path_to_yaml_file}  ${operation}=install  ${conn}=admin  ${timeout}=200
    [Documentation]
    ...  Description:
    ...  KW Install Or Upgrade Charts Depends On *operation* Argument
    ...                 **Example of simple usage:**
    ...                 Install Or Upgrade Charts  ${helm_dir_path}  ${chart_name}  ${helm_chart_path}  ${path_to_yaml_file}  ${operation}
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | hw                     | Yes  |  Hardware type (vdu or vcu).                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cran                   | Yes  |  Namespace where the chart will be installed.                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | helm_dir_path          | Yes  |  Path to the directory with charts.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | chart_name             | Yes  |  Name of the chart to be installed.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | helm_chart_path        | Yes  |  Path to the chart file.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | path_to_yaml_file      | Yes  |  Path to the yaml file.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | operation              | No   |  Operation to be performed (install or upgrade).                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | conn                   | No   |  Connection to ssh.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                | No   |  Timeout for the command.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${operation} ${hw}${chart_name}  console=${true}
    Sleep  60s
    ${output}=  tafssh.Execute
    ...  command=cd ${helm_dir_path} && helm ${operation} ${hw}${chart_name} ${helm_chart_path} -f ${path_to_yaml_file} -n ${cran}
    ...  connection=${conn}
    ...  timeout=${timeout}
    Log  cd ${helm_dir_path} && helm ${operation} ${hw}${chart_name} ${helm_chart_path} -f ${path_to_yaml_file} -n ${cran}  console=${true}
    Log  ${output}  console=${true}
    tafssh.Assert Exit Status  0  connection=${conn}

Remove Existing Charts
    [Arguments]  ${hw_type}  ${chart_name}  ${conn}
    [Documentation]
    ...  Description:
    ...  KW get charts names, set them in apropriate order (main, prereq, prep) and removes charts
    ...  Input:          hw_type=vCU
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | hw_type                | Yes  |  Hardware type (vdu or vcu).                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | chart_name             | Yes  |  Name of the chart to be removed.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | conn                   | No   |  Connection to ssh.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  Removing Existing Charts  console=${true}
    ${ordred_charts}=  Create List
    ${charts_output}=  tafssh.Execute  helm list -A -a --output json  connection=${conn}
    ${deployed_charts}=  Get Names And Status From Helm List  ${charts_output}
    ${charts}=  Evaluate  [chart['Name'] for chart in @{deployed_charts} if chart['Name'].startswith('${hw_type}')]
    FOR  ${i}  IN  @{charts}
        Run Keyword If  not '${i}'.endswith('preparation') and not '${i}'.endswith('prerequisite')  Insert Into List  ${ordred_charts}  0  ${i}
        Run Keyword If  '${i}'.endswith('prerequisite')  Insert Into List  ${ordred_charts}  1  ${i}
        Run Keyword If  '${i}'.endswith('preparation')  Insert Into List  ${ordred_charts}  2  ${i}
    END
    Set Test Variable  ${ordred_charts}
    ${helm_uninstall_output}=  Run Keyword If  '${chart_name}'=='main' and '${hw_type}'=='vcu'
    ...  tafssh.Execute  helm uninstall ${ordred_charts[0]} -n ${CRAN_VCU}  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='preparation' and '${hw_type}'=='vcu'
    ...  tafssh.Execute  helm uninstall ${ordred_charts[2]} -n ${CRAN_VCU}  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='prerequisite' and '${hw_type}'=='vcu'
    ...  tafssh.Execute  helm uninstall ${ordred_charts[1]} -n ${CRAN_VCU}  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='main' and '${hw_type}'=='vdu'
    ...  tafssh.Execute  helm uninstall ${ordred_charts[0]} -n ${DU_namespace}  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='preparation' and '${hw_type}'=='vdu'
    ...  tafssh.Execute  helm uninstall ${ordred_charts[2]} -n ${DU_namespace}  connection=${conn}
    ...  ELSE IF  '${chart_name}'=='prerequisite' and '${hw_type}'=='vdu'
    ...  tafssh.Execute  helm uninstall ${ordred_charts[1]} -n ${DU_namespace}  connection=${conn}
    Log   ${helm_uninstall_output}  console=${true}
#    tafssh.Assert Exit Status  0  connection=${conn}
    ${helm_uninstall_output}=  Run Keyword If  '${chart_name}'=='all' and '${hw_type}'=='vcu'
    ...  Delete All Charts  ${CRAN_VCU}  ${ordred_charts}  ${conn}
    ...  ELSE IF  '${chart_name}'=='all' and '${hw_type}'=='vdu'
    ...  Delete All Charts  ${DU_namespace}  ${ordred_charts}  ${conn}
    Run Keyword If  '${hw_type}'=='vdu'  Delete And Create Back Namespace  ${DU_namespace}  ${conn}

Delete And Create Back Namespace
    [Arguments]  ${cran}  ${conn}
    [Documentation]
    ...  Description:
    ...  KW deletes and creates back namespace
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cran                   | Yes  |  Namespace which will be deleted.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | conn                   | Yes  |  Connection to ssh.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${helm_delete_namespace_output}=  tafssh.Execute  kubectl delete namespace ${cran}  connection=${conn}
    Log  ${helm_delete_namespace_output}  console=${true}
    ${helm_create_namespace_output}=  tafssh.Execute  kubectl create namespace ${cran}  connection=${conn}
    Log  ${helm_create_namespace_output}  console=${true}

Delete All Charts
    [Arguments]  ${cran}  ${list_of_charts}  ${conn}
    [Documentation]
    ...  Description:
    ...  KW delete all charts from the list
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cran                   | Yes  |  Namespace where the chart will be uninstalled.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_charts         | Yes  |  List of charts to be uninstalled.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | conn                   | Yes  |  Connection to ssh.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    FOR  ${chart}  IN  @{list_of_charts}
        Continue For Loop If  '${chart}'=='vdu'
        ${helm_uninstall_output}=  tafssh.Execute  helm uninstall ${chart} -n ${cran}  connection=${conn}
        Log  ${helm_uninstall_output}  console=${true}
#        tafssh.Assert Exit Status  0  connection=${conn}
    END

Upload SCFC After Deployment And Wait For All Cells OnAir
    [Documentation]
    ...  Keyword for uploading scfc to vdu and waiting for all cells on air
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    ${status}  ${restapi_version}=  Run Keyword And Ignore Error
    ...  Get vDU Rest Api Version  gnb_index=0  vdu_index=0
    ${restapi_version}=  Set Variable If  '${status}'=='FAIL'
    ...  ${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}  ${restapi_version}
    ${index}=  Get Index From List  ${VDU_REST_TAF_LIB_SUPPORTED_VERSION}  ${restapi_version}
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ...  gnb_index=0  vdu_index=0
    ${http_password}=  Set Variable If  ${index}>=${4}  nemuuser
    ...  ${oam_http_connection["password"]}
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
    ${port}=  Set Variable  ${oam_http_connection["port"]}
    ${username}=  Set Variable  ${oam_http_connection["username"]}
    ${password}=  Set Variable  ${http_password}
    ${secure}=  Set Variable  True
#    vDU Rest Login
    vdu.Connect To  host=${ip_addr}  port=${port}  username=${username}  password=nemuuser
    ...  vdu_version=${restapi_version}  secure=${secure}
    vdu.disconnect
    Sleep  10
    vdu.Connect To  host=${ip_addr}  port=${port}  username=${username}  password=Nokia@123
    ...  vdu_version=${restapi_version}  secure=${secure}
    ${commisioning_status}  vdu.Perform Commissioning  scf_file=${VDU_SCF_PATH}  timeout=${ACTIVATE_PLAN_TIMEOUT}
    ...  wait_for_completion=True  should_activate=True
    Log  ${commisioning_status}  console=True
    Wait Until All Cells Are OnAir  cells_count=${cells_count}  timeout=20min

Check All Tools On Server
    [Documentation]
    ...  Description:
    ...  KW checks if all tools are installed on the server and sets chmod
    Check Single Tool On Server And Set Chmod  tool_name=wget  chmod=777
    Check Single Tool On Server And Set Chmod  tool_name=7za  chmod=755
    Check Single Tool On Server And Set Chmod  tool_name=sshpass  chmod=755
    Check Single Tool On Server And Set Chmod  tool_name=unzip  chmod=777

Verify Pods/Charts
    ${name_spaces}  tafssh.Execute  helm list -A -a --output json  connection=${ssh_conn}
    ${deployed_charts}  Get Names And Status From Helm List  ${name_spaces}
    Check If Charts Deployed  ${deployed_charts}
    ${all_pods}  tafssh.Execute  kubectl -n ${DU_namespace} get pods  connection=${ssh_conn}
    Log  ${all_pods}

Check Single Tool On Server And Set Chmod
    [Arguments]  ${tool_name}  ${chmod}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  KW checks if tool is installed on the server and sets chmod
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | tool_name              | Yes  |  Name of the tool to be checked.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | chmod                  | Yes  |  Chmod to be set for the tool.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         | No   |  Log to console.                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    tafssh.Connect To  hostname=${cloud_server_ip}
    ...  username=core
    ...  password=system123
#    ...  alias=${ssh_conn}
    ${file_exists}  tafssh.File Exists  /usr/local/bin/${tool_name}
#    connection=${ssh_conn}
    Run Keyword If  ${file_exists}  Run Keywords
    ...  Log  ${info_prefix}${tool_name} exists on server.  console=${log_to_console}
    ...  AND  Return From Keyword
    Log  ${info_prefix}${tool_name} is not on server. Proceed to download.  console=${log_to_console}
    artifactory.Download File From Artifactory  download_path=/home/ute/Downloads  filename=${tool_name}  artifactory_url=${ARTIFACTORY_URL}
    tafssh.Upload File  local_path=/home/ute/Downloads/${tool_name}
    ...  remote_path=/var/home/core/${tool_name}
    ...  timeout=600
    tafssh.Send Command  cd /var/home/core
#    connection=${ssh_conn}
    tafssh.Send Command  chmod ${chmod} ${tool_name}
#    connection=${ssh_conn}
    tafssh.Send Command  sudo mv ${tool_name} /usr/local/bin
#    connection=${ssh_conn}
    ${file_exists}  tafssh.File Exists  /usr/local/bin/${tool_name}
#    connection=${ssh_conn}
    Should Be True  ${file_exists}
