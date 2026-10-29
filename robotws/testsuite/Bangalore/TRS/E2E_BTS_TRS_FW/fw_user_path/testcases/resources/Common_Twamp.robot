*** Settings ***
Documentation
...            [Author]         "Nandini R"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Library        XML    use_lxml=${True}


*** Keywords ***
Start TWAMP Session and reflector traffic
	[Arguments]      ${Dst_IP_addr}=${Dst_IP}		${twamp_dst_port}=${twamp_port}
    Run     chmod 777 ${twamp_exe_file}
    Run     sudo ${twamp_exe_file} ${Dst_IP_addr} ${twamp_dst_port} 1>/dev/null &

Start Twamp reflector
    Perform Delta Commissioning           ${twamp_reflector_file}