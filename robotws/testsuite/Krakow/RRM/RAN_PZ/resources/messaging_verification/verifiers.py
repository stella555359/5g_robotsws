from ta_messaging.message_flows import get_flow


def verify_dl_and_ul_config_common(flow_alias, msg_alias, dl_cells, ul_cells):
    msg = get_flow(flow_alias).get_message(msg_alias)
    if len(msg.get_all_values_by_key('downlinkConfigCommon')) != int(dl_cells):
        raise Exception("Expected to find {} cells with downlinkConfigCommon object but found {} instead".format(
            dl_cells, len(msg.get_all_values_by_key('downlinkConfigCommon'))))
    if len(msg.get_all_values_by_key('uplinkConfigCommon')) != int(ul_cells):
        raise Exception("Expected to find {} cells with uplinkConfigCommon object but found {} instead".format(
            ul_cells, len(msg.get_all_values_by_key('uplinkConfigCommon'))))
