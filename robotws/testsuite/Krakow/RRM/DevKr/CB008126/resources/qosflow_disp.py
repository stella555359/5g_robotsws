from ta_egate_cmd_parser import ta_egate_cmd_parser

PARSER = ta_egate_cmd_parser()


def get_all_flows_by_qosflow_id():
    return PARSER.get_command('qosflow_disp').without_id_by_qosflow().execute_and_parse()


def get_all_flows_by_fiveqi_id():
    return PARSER.get_command('qosflow_disp').without_id_by_fiveqi().execute_and_parse()


def get_single_flow(flow_id):
    return PARSER.get_command('qosflow_disp').with_id(int(flow_id)).execute_and_parse()


if __name__ == '__main__':
    print(get_all_flows_by_qosflow_id())
    print(get_all_flows_by_fiveqi_id())
    print(get_single_flow(1))
