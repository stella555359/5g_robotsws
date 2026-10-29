__author__ = "Sheng Haoyun"


def get_syslog_result_without_unexpected_port(analysis_result, unexpected_port):
    result_list = analysis_result.split('\n')
    port_list = []
    rx_result_list = []
    for each_str in result_list:
        if 'LnCellID' in each_str:
            port_list = each_str.split(' ')
            while u'' in port_list:
                port_list.remove(u'')
        if 'RX' in each_str and 'Ok' in each_str:
            rx_result = each_str.split(' ')
            while u'' in rx_result:
                rx_result.remove(u'')
            rx_result_list.append(rx_result)
    for each_port in unexpected_port:
        if str(each_port) in port_list:
            get_index = port_list.index(str(each_port))
            for index in range(len(rx_result_list)):
                rx_result_list[index].pop(get_index)
            port_list.pop(get_index)
    return rx_result_list
