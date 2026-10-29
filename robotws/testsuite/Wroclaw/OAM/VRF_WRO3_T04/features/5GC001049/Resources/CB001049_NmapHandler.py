import os
import robot.api.logger as logger


def gather_nmaps(ip_addr_v4, ip_addr_v6):
    nmap_output = list()
    for ip_addr in ip_addr_v4:
        command = f"sudo nmap {ip_addr} -sY -p 38422 -g 38422 -Pn | grep '38422/sctp'"
        output = os.popen(command).read()
        nmap_output.append(output)
        logger.info(output, html=True, also_console=True)

    for ip_addr in ip_addr_v6:
        command = f"sudo nmap {ip_addr} -sY -p 38422 -g 38422 -6 -Pn | grep '38422/sctp'"
        output = os.popen(command).read()
        nmap_output.append(output)
        logger.info(output, html=True, also_console=True)

    logger.info(nmap_output)
    return nmap_output


def check_nmap_results(nmap_list: list) -> bool:
    return all('filtered' in nmap for nmap in nmap_list)
