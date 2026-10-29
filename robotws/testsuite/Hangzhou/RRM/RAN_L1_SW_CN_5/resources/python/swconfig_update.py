import re


def defined_default_flags():
    return {
        "0x1A0020": "1",  # enable ssh even with TRS
        "0x19000A": "1",
        "0x30000F": "1",  # post-RL70
        "0x10063": "1",  # disable AppDef check
        "0x10041": "5",  # ERadCcs_AaSysLogOutputMode - UDP logging enabled
        "0x200A6": "1",
        "0x10042": "0xC0A8FF7E",  # Set Destination IP address for RF log forwarding
        "0x10043": "0xC739",  # Set UDP port for RF log forwarding
        "0x450027": "1",  # Admin development account
        "247": "1",  # TRUMAG debug
        "252": "2",  # apw prints
        "0x00120004": "1",  # RROM
        "0x00120005": "1",
        "0x00120006": "1",
        "0x110003": "1",  # ENBC
        "0x110004": "1",
        "0x110001": "1",
        "0x110002": "1",
        "0x150001": "1",  # TUPC
        "0x150002": "1",
        "0x150003": "1",
        "0x150004": "1",
        "0x380003": "1",  # MCEC
        "0x380011": "1",
        "0x380001": "1",
        "0x380002": "1",
        "0x00130020": "1",  # UEC
        "0x00130021": "1",
        "0x0013001E": "1",
        "0x0013001F": "1",
        "0xf0010": "1",  # CELLC
        "0xf0011": "1",
        "0xf000e": "1",
        "0xf000f": "1",
        "0x340000": "5",  # Report PM counter every 3 minutes
        "0x10028": "1",  # AaTrace message content dump debug print
        "0x1002A": "1",  # AaTrace SwConfig used flag
        "0x1002F": "0",  # AaTrace messages from range
        "0x1002B": "0x097E",  # AATRBL_FILE_PREPARE_REQ_MSG
        "0x10040": "1",  # ERadCcs_AaSysLogOutputLevel - Severity changed to DEBUG
        "0x1003F": "1",  # ERadCcs_AaSysLogInputLevel - Severity changed to DEBUG
        "0x1005A": "1",
        "0x850007": '1',    # isProcessingOvertimeFatal
    }


def swconfig_update(add_replace_dict=None, output_file="swconfig_new.txt"):
    """
    Update the default flags dictionary by adding or replacing entries, and generate a new swconfig file.

    :param add_replace_dict: Dictionary of flags to add or replace. Default is None.
    :param output_file: Path to the output file (e.g., "swconfig_new.txt").
    """
    # If add_replace_dict is provided, update the default flags
    default_flags = defined_default_flags()
    if add_replace_dict:
        default_flags.update(add_replace_dict)

    # Write the updated flags to the output file
    with open(output_file, "w") as file:
        for key, value in default_flags.items():
            file.write(f"{key} = {value}\n")

    print(f"Updated configuration written to {output_file}")
