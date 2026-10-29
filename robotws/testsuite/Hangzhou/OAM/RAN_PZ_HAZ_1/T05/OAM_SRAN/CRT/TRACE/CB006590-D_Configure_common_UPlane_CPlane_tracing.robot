*** Settings ***
Documentation     [PURPOSE]
Library      ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/M2M.py
Library		Collections
Library     DateTime


#*** Variables ***
#${vdu_mplane_ip}   	10.108.195.130      #BTS-11322
#${vdu_mplane_ip}   10.108.194.162         #BTS-11084
#${cu_mplane_ip}   	10.110.83.133       #BTS-11322
#${vdu_mplane_ip}   	10.108.195.82      #BTS-11087
#${vdu_username}     Nemuadmin
#${vdu_password}     N0kia@dmin56
#${vdu_password}     Nokia@123


*** Keywords ***
Configure Common UPlane CPlane Tracing for vDU
    [Documentation]    Short description.
    M2M.configure_common_cplane_uplane_tracing  host=${vdu_mplane_ip}     username=${vdu_username}
        ...     password=${vdu_password}        uplane_ip_address=10.97.92.238      uplane_port=3006    dscp=63
        ...     trace_type=CPlane

Configure Common UPlane CPlane Tracing for CU
    [Documentation]    Short description.
    M2M.configure_common_cplane_uplane_tracing  host=${cu_mplane_ip}    username=${vdu_username}
        ...     password=${vdu_password}        uplane_ip_address=10.97.92.238      uplane_port=3006    dscp=63
        ...     trace_type=UPlane
