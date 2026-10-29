def get_parameter(connection):
    sw_build = connection.get_sw_release_name()
    return "ntpServerIpAddrList" if sw_build == "SBTS23R4" else "ntpServerIpAddrOrFqdnList"


def set_ntp_server_ip_address(ip_addr, dist_name, connection):
    parameter = get_parameter(connection)
    structure = [ip_addr, ]
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=parameter,
                                                 operation="update", value=structure)


def unset_ntp_server_ip_address(dist_name, connection):
    parameter = get_parameter(connection)
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=parameter,
                                                 operation="update", value=[])
