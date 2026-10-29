from ta5g_tshark import ta5g_tshark
from ta5g_global_var import DEFAULT_NG_XN_TSHARK_ALIAS
from robot.libraries.BuiltIn import BuiltIn


def get_mcc_and_mnc(packet_filter, alias=DEFAULT_NG_XN_TSHARK_ALIAS, pcap_file_path=None):
    tshark_instance = ta5g_tshark()
    output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
    mcc_elements = tshark_instance.get_attribute_values_from_tshark_messages(
        alias=alias,
        filter=packet_filter,
        output_pdml_filepath="{}/converted_pcap.pdml".format(output_dir),
        element_xpath="//*[@name='nr-rrc.mcc']/*/*[@name='nr-rrc.MCC_MNC_Digit']",
        attribute_xpath=".",
        attribute="show",
        pcap_file_path=pcap_file_path
    )
    mnc_elements = tshark_instance.get_attribute_values_from_tshark_messages(
        alias=alias,
        filter=packet_filter,
        output_pdml_filepath="{}/converted_pcap.pdml".format(output_dir),
        element_xpath="//*[@name='nr-rrc.mnc']/*/*[@name='nr-rrc.MCC_MNC_Digit']",
        attribute_xpath=".",
        attribute="show",
        pcap_file_path=pcap_file_path
    )
    mcc = ''.join(mcc_elements)
    mnc = ''.join(mnc_elements)
    return mcc, mnc
