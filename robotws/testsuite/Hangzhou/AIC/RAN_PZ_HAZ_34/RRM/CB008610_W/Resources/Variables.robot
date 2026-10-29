*** Variables ***
${MRBTS_ID}                             ${tl.gnbs[0].dus[0].instance_id}
${UE_TYPE_0}                            askey_vran20
${UE_index_0}                           ${0}
${UE_TYPE_1}                            qct_dx50
${UE_index_1}                           ${1}
${process_index}                        ${1}
${progress_name}                        ping
${process_index}                        ${2}
${progress_name}                        ping
${TS_CASE_LOG_PATH}                     ${OUTPUT_DIR}
${appserver_addr}                    ${tl.ues[${UE_index_1}].iperf_details.ssh_connection_details.addr}
${appserver_username}                   ${tl.ues[${UE_index_1}].iperf_details.ssh_connection_details.username}
${appserver_password}                   ${tl.ues[${UE_index_1}].iperf_details.ssh_connection_details.password}
#${cpc_ip}   from KW 'Prepare UE-> _Prepare Variables'
#${cpc_username}  from KW 'Prepare UE-> _Prepare Variables'
#${cpc_password}   from KW 'Prepare UE-> _Prepare Variables'
#${serial}    from KW 'Prepare UE-> _Prepare Variables'

