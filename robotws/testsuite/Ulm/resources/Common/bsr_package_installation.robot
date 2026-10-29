*** Settings ***
Documentation
    ...     Keywords for BSR package installation.
    ...     It was inspired by a KW provided by BLR team as WA:
    ...     https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/blob/master/testsuite/Bangalore/RRM/5GET_BLR/ASOE_RJIO/L3_call.robot
    ...     It isn't clear if the installation will be done later by ute-ca.
    ...     Discussions are ongoing!

Library     Collections
Library     OperatingSystem

Library     taf.sbts.oam.coam.admin          WITH NAME   admin
Library     python/BsrDownloader.py

Resource    connect.robot
Resource    gnb.robot
Resource    testline.robot

*** Variables ***
${P_console}   ${False}

*** Keywords ***
Install All BSR Packages Found In SCF
    [Documentation]    Identifies and initiates the installation of custom BSR packages
    ...    found within the active SCF (Software Configuration File) of a specified gNB.
    ...    It first verifies if custom beamset configuration is active for the given gNB,
    ...    retrieves the names of custom beam sets from its SCF, and then compares them
    ...    with currently installed beam sets via OAM. If any package is missing it will
    ...    download the package from Artifactory. The names of custom beam sets found
    ...    in SCF are used as archive file name prefix to fetch the matching zip files
    ...    from Artifactory. Sometime we may find several zip files with same prefix but
    ...    different full name, e.g.
    ...    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001.zip
    ...    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    ...    The big issue is that both files will display after installation the SAME (!)
    ...    BSR package name at the WebEM, so it isn't possible to map the SCF value to
    ...    one of both examples.
    ...    That's why we added an optional argument to force the installation of a specific
    ...    zip file to handle ambiguous file name cases as show by the example above.
    ...
    ...
    ...    *Note:* This keyword is designed to work with the provided gNB.
    ...
    ...    *Arguments:*
    ...    - ``node_id``: (Optional) The identifier of the gNB node. Defaults to `0`.
    ...    - ``force_zip``: (Optional) Specific zip file to be installed. Defaults to `None`.
    ...
    ...    *Returns:*
    ...    - `None` if no custom BSR packages are configured or found in the SCF.
    ...    - A status or list of installed packages.
    ...
    ...    *Preconditions:*
    ...    - The `gnb`, `admin`, `connect`, `Collections`, and `OperatingSystem` libraries
    ...      (or their respective resource files) must be imported and configured.
    ...    - The specified gNB (`node_id`) must be accessible and configured to allow SCF retrieval.
    ...    - OAM HTTP session setup must be possible with the gNB.
    ...
    ...    *Example Usage:*
    ...    | Install All BSR Packages Found In SCF | # Uses default node_id=0
    ...    | Install All BSR Packages Found In SCF | node_id=1 |
    ...
    [Arguments]   ${node_id}=0   ${force_zip}=${None}
    # check if we are outside a test case
    ${test_name}   Get Variable Value   ${TEST_NAME}
    IF   $test_name is None
        ${download_dir}   testline.Get Test Suite Config Directory
    ELSE
        ${download_dir}   testline.Get Test Case Log Directory
    END

    ${du_scf}   gnb.Get SCF From GNB   gnb_id=${node_id}
    ${actCustomBsr}   Is Custom Beamset Configuration Activated In SCF   scf_path=${du_scf}
    IF   not ${actCustomBsr}   RETURN   No custom BSR packages in use!

    ${customBeamSetNames}   Get All Custom Beam Set Names From SCF   scf_path=${du_scf}
    Should Not Be Empty   ${customBeamSetNames}
    Collections.List Should Not Contain Duplicates   ${customBeamSetNames}
    ...   msg=KW 'Get All Custom Beam Set Names From SCF' shouldn't return duplications

    ${oam_alias}   connect.Setup OAM Http Session  node_type=gnb  node_id=${node_id}
    ${installed_bsr_sets}   Get Installed Beam Sets   oam_alias=${oam_alias}

    ${used_bsr}    admin.Get Bsr Files   connection=${oam_alias}

    FOR   ${package}   IN   @{customBeamSetNames}
        ${skip_package}   Set Variable   ${False}
        FOR   ${idx}   IN   @{used_bsr['bsrFileInused']}
           IF   '${package}' in '${idx['filename']}'
              Log   ${\n}Skip installation of '${package}', it is already in use!   console=${P_console}
              ${skip_package}   Set Variable   ${True}
           END
        END
        ${archive_prefix}   Set Variable If   $force_zip is None   ${package}   ${force_zip}
        IF   not ${skip_package}   Install BSR   BSR_name=${archive_prefix}
        ...   oam_alias=${oam_alias}   target_dir=${download_dir}
    END
    ${used_bsr}   admin.Get Bsr Files   connection=${oam_alias}
    Get Installed Beam Sets   oam_alias=${oam_alias}


Get Credentials For Espoo1 Artifactory
    [Documentation]    Retrieves the Artifactory API token for a specified user from a local file.
    ...
    ...    This keyword constructs a command to read a user's token from `/etc/token/<user>`
    ...    using `sudo` and executes it via the `OperatingSystem` library.
    ...    The retrieved token is then returned.
    ...
    ...    *Arguments:*
    ...    - ``user``: The username for whom the Artifactory token is to be retrieved.
    ...
    ...    *Returns:*
    ...    The Artifactory API token as a string.
    ...
    ...    *Preconditions:*
    ...    - The `OperatingSystem` library must be imported.
    ...    - The token file must exist at `/etc/token/<user>` on the executing machine.
    ...    - The user running the Robot Framework test must have `sudo` privileges
    ...      to read the specified token file without password prompt.
    ...
    ...    *Example Usage:*
    ...    | ${my_user}= | Set Variable | my_artifactory_user |
    ...    | ${artifactory_token}= | Get Credentials For Espoo1 Artifactory | ${my_user} |
    ...    | Log To Console | Retrieved token: ${artifactory_token} |
    ...
    [Arguments]   ${user}
    ${user_token}   OperatingSystem.Run  sudo cat /etc/token/${user}
    RETURN   ${user_token}


Install BSR
    [Documentation]    Installs a BSR package from an Artifactory repository.
    ...    It takes in arguments such as the BSR name, OAM alias, and user credentials,
    ...    and returns the result of the software update operation. The URL of the Artifactory repository
    ...    defaults to ``https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR``.
    ...
    ...    *Arguments:*
    ...    - ``BSR_name``: The name prefix without extension of the BSR package to be installed.
    ...    - ``oam_alias``: The admin library alias to access the gNB.
    ...    - ``user``: The user credentials for accessing the Artifactory repository. Defaults to ``ca_ute_artifactory_readonly``.
    ...    - ``target_dir``: The directory where the BSR package will be downloaded.
    ...
    ...    *Example Usage:*
    ...    | Install BSR | BSR_name=example_bsr | oam_alias=oam_alias |
    ...
    ...    *Returns:*
    ...    - The result of the software update operation.
    ...
    [Arguments]   ${BSR_name}   ${oam_alias}   ${user}=ca_ute_artifactory_readonly   ${target_dir}=${None}
    IF   $target_dir is None
       ${target_dir}   testline.Get Test Case Log Directory
    END

    ${user_token}   Get Credentials For Espoo1 Artifactory   user=${user}

    ${dl_files}   BsrDownloader.Download Matching Zips
    ...   user=${user}   user_token=${user_token}
    ...   file_name_prefix=${BSR_name}   target_dir=${target_dir}
    IF   ${{ len(${dl_files})==0 }}   Fail   No files were downloaded from Artifactory!
    IF   ${{ len(${dl_files})>1 }}    Fail
    ...   msg=Ambiguous file selection: More than one file matches the given BSR pattern!

    ${zip_files}   OperatingSystem.List Files In Directory   path=${target_dir}   pattern=${BSR_name}*.zip
    IF   ${{ len(${zip_files})==0 }}   Fail   No zip file found in target_dir!

    ${result}  admin.Update Software   ${target_dir}/${zip_files}[0]   connection=${oam_alias}
    RETURN   ${result}


Is Custom Beamset Configuration Activated In SCF
   [Arguments]   ${scf_path}
   ${actCustomBsr}   gnb.Get SCF Value From File By Pattern   scf_path=${scf_path}
   ...   p_name=actCustomBsr   dist_name=.*NRBTS-*

   IF   '${actCustomBsr}'=='true'   RETURN   ${True}   ELSE   RETURN   ${False}


Get All Custom Beam Set Names From SCF
   [Arguments]   ${scf_path}
   ${nr_cells}   gnb.Get DistNames From Local SCF File   scf_path=${scf_path}
   ...   regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+

   ${bsr_package_list}   Create List

   FOR   ${cell}   IN   @{nr_cells}
      ${status}   ${customBeamSetName}   Run Keyword And Ignore Error
      ...   gnb.Get SCF Value From File   p_name=customBeamSetName   scf_path=${scf_path}   dist_name=${cell}
      IF   '${status}'=='PASS'   Collections.Append To List   ${bsr_package_list}   ${customBeamSetName}
   END

   RETURN   ${{ list(dict.fromkeys(${bsr_package_list})) }}


Get Installed Beam Sets
   [Arguments]   ${oam_alias}
   ${status}   ${beamSetInstalled}   Run Keyword And Ignore Error
   ...   admin.Get Parameter By Class   class_name=NRBTS   parameter_list=${{ ['beamSetInstalled'] }}
   ...   include_children=${False}   detailed_output=${False}   connection=${oam_alias}
   IF   '${status}'=='PASS'   RETURN   ${beamSetInstalled}   ELSE   RETURN   ${None}
