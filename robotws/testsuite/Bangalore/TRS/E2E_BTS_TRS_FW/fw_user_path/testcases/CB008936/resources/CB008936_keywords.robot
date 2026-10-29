*** Settings ***

Documentation     [Procedure] "[1]TRS_CB008936_Delta validation and provisioning with validation scope as DELTACHECK in NetAct during maintence"
...               [Date] "02-05-2023"
...               [Author] "Vaishnavi"
...               [Feature_ID]  "CB008936"
...               [Maintenance] "TRS I & V Tools Bangalore Team"
...               [Function_Hash_Tags]  "Validation scope,Full check,Delta check"
...               [DELTA_FILE_DEPENDENCY]   "Delta-check"
...               [Validated_TestLine]  "IAV-BLR-TL008-ETERNALS"
...               [Precondition]    "ENodeB should be integrated to Netact"

***Keywords***

Preconditions
     Perform Commissioning       scf_file=${configuration}     verify_bts_status=True     timeout=900     alias=default
     Setup Ems      config_device=netact2005       alias=lab2005_omc_user
     Cm Upload      config_device=netact2005      alias=lab2005_omc_user

disintegrate BTS from Netact
    Deintegrate Mrbts From Netact       config_device=netact2005   dist_name=${Dist}       alias=lab2005_omc_user

Integrate NE
    Enb Configuration Should Be Discovered       config_device=netact2005       release=${release}        mr=${MR}
    ...         mrbts_address=${mrbts_address}     dist_name=${Dist}      ip_version=IPV4     security_mode=${No-TLS}
    ...    mrbts_em_address=None        presentation_name=None     http_port=${http}      https_port=${https}      alias=lab2005_omc_user

Export the plan-1
    export      config_device=netact2005       dist_names=${Dist}     file_name=${file-1}      alias=lab2005_omc_user      class_filter=LNCEL

Import the plan-1
    import   config_device=netact2005      file_name=${file-1}     input_file=${import-plan}     operation_type=plan    alias=lab2005_omc_user
    ...     remote_file_path=${file-path}


Making ProvisionPlan
    Provision Plan    config_device=netact2005         plan_name=DC31      dist_names=${Dist}     provisioning_operation=preactivate
    ...     alias=lab2005_omc_user

Online validation
    Validate Plan    config_device=netact2005         plan_name=DC31    dist_names=${Dist}         alias=lab2005_omc_user     verbose=${False}

    Teardown Ems         config_device=netact2005       alias=lab2005_omc_user
