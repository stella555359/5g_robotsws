*** Settings ***
Documentation
...    author: Guo Zhenzhen
...    contact: yuanyuan.liu@nokia-sbell.com
...    squad group: MMW_HZ_SG_03

Library    OperatingSystem
Library    Collections
Library    taf.stc.config
Library    String
Library    BuiltIn
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
#Resource    ../../../../../testsuite/Wroclaw/OAM/cOAM/resources/admin.robot
Library    taf.analyzer.pcap

*** Variables ***
${asik_addr}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${asik_username}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

*** Keywords ***
Suite setup
    admin_cli.connect to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    Send precondition SCF

Suite teardown
    admin_cli.teardown    connection=default

Send precondition SCF
    Log To Console    active feature flag
    admin_cli.Perform Parameter Recommissioning
    ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
    ...       parameter=vlanAwarenessEnabled
    ...       value=true
    ...       operation=update
    ...       skip_parameter_relation_errors=skip
    ...       connection=default
    admin_cli.Perform Parameter Recommissioning
    ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
    ...       parameter=l2QoSEnabled
    ...       value=true
    ...       operation=update
    ...       skip_parameter_relation_errors=skip
    ...       connection=default
    admin_cli.Perform Parameter Recommissioning
    ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
    ...       parameter=l2SwitchingEnabled

    ...       value=true
    ...       operation=update
    ...       skip_parameter_relation_errors=skip
    ...       connection=default
    Log To Console    BRGPRT setting
    admin_cli.Perform Parameter Recommissioning
    ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1
    ...       parameter=acceptableFrameTypes
    ...       value=ADMIT_ALL
    ...       operation=update
    ...       skip_parameter_relation_errors=skip
    ...       connection=default
    admin_cli.Perform Parameter Recommissioning
    ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2
    ...       parameter=acceptableFrameTypes
    ...       value=ADMIT_ALL
    ...       operation=update
    ...       skip_parameter_relation_errors=skip
    ...       connection=default
    admin_cli.Perform Parameter Recommissioning
    ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1
    ...       parameter=l2ShaperRate
    ...       value=5000000
    ...       operation=update
    ...       skip_parameter_relation_errors=skip
    ...       connection=default
    admin_cli.Perform Parameter Recommissioning
    ...       dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-3
    ...       parameter=l2ShaperRate
    ...       value=50000
    ...       operation=update
    ...       skip_parameter_relation_errors=skip
    ...       connection=default







