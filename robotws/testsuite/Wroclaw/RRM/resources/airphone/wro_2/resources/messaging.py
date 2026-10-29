from ta_messaging.message_sources.message_sources_tshark_based import configure_iphy_interfaces, \
    restore_default_iphy_interfaces
from ta_messaging.alias_factory import get_alias_factory
from ta_messaging.message_flows import get_flow
from robot.api.deco import keyword


def enable_ue_capture_on_simulated_enb(enable=True):
    """
    Enable capturing UEs RRC flow (internal messaging) in ta_messaging for AirPhone,
    can be used to capture LTE RRC messages between simulated eNB and simulated UE.
    It changes global variable IPHY_INT containing eth interfaces to be captured from 'eth4' to 'any'.
    This variable is used both in Airphone and Iphy message capturing (both HEX or PDML message sources).
    +------------------+-------+------------+------------+
    |     Example                                        |
    +==================+=======+============+============+
    | Enable UE Capture On Simulated Enb  enable=${True} |
    | Create UEs alias  alias=UE  id_type=wts5g          |
    | Expect Message Flow                                |
    | ...  UE_1:RRC_RRCConnectionReconfiguration         |
    | ...  alias=your_flow_alias                         |
    | ...  overall_timeout=30                            |
    +------------------+-------+------------+------------+
    :param enable: if evaluates to True than turns on capturing UE internal messages,
                   if evaluates to False than turns it off
    :return: None
    """
    if enable:
        configure_iphy_interfaces(['any'])
    else:
        restore_default_iphy_interfaces()


@keyword("Stop Capturing Messages")
def stop_capturing_messages():
    """
    Stops capturing all messages in ta_messaging.
    Normally this is not needed to be called as this is run automatically in teardown,
    but in rare cases can be used (with care!)
    :return:
    """
    get_alias_factory().shutdown()


def get_values_of_parameter_from_message_flow(flow_alias, message_alias, parameter_name):
    msg = get_flow(flow_alias).get_message(message_alias)
    field_values = msg.get_all_values_by_key(parameter_name)
    if len(field_values) > 1:
        return field_values
    else:
        return field_values[0]


def get_index_of_value_from_list(flow_alias, message_alias, parameter_name, value_of_parameter):
    val = int(value_of_parameter)
    list_of_values = get_values_of_parameter_from_message_flow(flow_alias, message_alias, parameter_name)
    index_of_value = list_of_values.index(val)
    return index_of_value


def get_value_from_message_by_index(flow_alias, message_alias, parameter_name, index_of_value):
    index_of_value = int(index_of_value)
    msg = get_flow(flow_alias).get_message(message_alias)
    field_values = msg.get_all_values_by_key(parameter_name)
    return field_values[index_of_value]
