from tsharkWithLuaVerifier import TSharkCommandAssembler

import re


def generated_pcap_data(pcap_path):
    """Generates PCAP data using TShark."""

    tshark = TSharkCommandAssembler()
    # if using_mcshark:
    output = (
        tshark.with_filter("dldata_pdschsendreq")
        .with_pcap_file(pcap_file=pcap_path)
        .inject_additional_parameters(
            "-T fields -e DlData_PdschGrant.mcsTable "
            "-e DlData_PdschGrant.spatialMode "
            "-e DlData_PdschGrant.numOfLayers "
            "-e DlData_PdschGrant.i1Codebook4AntPorts_item "
            "-e DlData_PdschGrant.i2Codebook4AntPorts "
            "-e DlData_PdschGrant.numStreamIndex "
            "-e DlData_PdschGrant.openLoopScheme"
        )
        .build()
    )
    print("OUTPUT: ", output)
    return output


def Verify_CLSM_parameters(row):
    """Checks if the 4x4 CL SM parameters values in a row are correct.

    Args:
        row: A string containing the 4x4 CL SM parameters values.

    Returns:
        True if the 4x4 CL SM parameters values are correct,
        False otherwise.
    """

    values = re.split(r"\t|,", row.strip())
    print(values)

    try:
        (
            mcsTable,
            spatialMode,
            numOfLayers,
            i1Codebook4AntPorts_0,
            i1Codebook4AntPorts_1,
            i1Codebook4AntPorts_2,
            i2Codebook4AntPorts,
            numStreamIndex,
            openLoopScheme,
        ) = map(int, values)

        return (
            mcsTable == 0
            and spatialMode == 2
            and numOfLayers == 1
            and i1Codebook4AntPorts_0 == 0
            and i1Codebook4AntPorts_1 == 0
            and i1Codebook4AntPorts_2 == 0
            and i2Codebook4AntPorts == 0
            and numStreamIndex == 4
            and openLoopScheme == 255
        )

    except ValueError:
        return False


def is_CLSM_parameters_correct(pcap_path):
    """Checks if the 4x4 CL SM parameters values in a PCAP
         file are correct.

    Args:
        pcap_path: The path to the PCAP file.

    Returns:
        True if all the 4x4 CL SM parameters values are correct,
        False otherwise.
    """
    pcap_data = generated_pcap_data(pcap_path)
    return all((Verify_CLSM_parameters(row) for row in pcap_data))


# def print_header(header_text):
#     """Prints a header with the given text."""
#     print(f"{header_text:-^80}")


# def main():
#     pcap_path = input("Enter path to bip l2l1 file: ")
#     if is_CLSM_parameters_correct(pcap_path):
#         print_header("\033[92m4x4 CL SM Parameters are correct\033[0m")
#     else:
#         print_header("\033[91m4x4 CL SM Parameters are Not correct !\033[0m")


# if __name__ == "__main__":
#     main()
