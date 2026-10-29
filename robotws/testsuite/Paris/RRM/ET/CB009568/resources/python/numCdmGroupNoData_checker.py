from tsharkWithLuaVerifier import TSharkCommandAssembler
from pprint import pprint

import re


def generated_pcap_data(pcap_path):
    """Generates PCAP data using TShark."""

    tshark = TSharkCommandAssembler()
    # if using_mcshark:
    output = (
        tshark.with_filter("dldata_pdschsendreq")
        .with_pcap_file(pcap_file=pcap_path)
        .inject_additional_parameters(
            "-T fields -e DlData_PdschGrant.mcs "
            "-e DlData_PdschGrant.numOfDmrsCdmGroupWithoutData"
        )
        .build()
    )
    # print("OUTPUT: ", output)
    return output


def is_correct_mcs(row, Thres):
    """Checks if the MCS and numOfDmrsCdmGroupNoData values in a row are correct.

    Args:
        row: A string containing the MCS and numOfDmrsCdmGroupNoData values.
        Thres: The MCS threshold.

    Returns:
        True if the MCS and numOfDmrsCdmGroupNoData values are correct,
         False otherwise.
    """

    # mcsTxt, dmrsTxt = row.strip().split("\t")
    values = re.split(r"\t|,", row.strip())
    # print(values)

    try:
        mcs, numOfDmrsCdmGroupNoData = map(int, values)

        # print(
        #     "mcs:", mcs,
        #     "numOfDmrsCdmGroupWithoutData:", numOfDmrsCdmGroupNoData,
        # )

        print(f'mcs: {mcs}\t\tnumOfDmrsCdmGroupWithoutData: {numOfDmrsCdmGroupNoData}')

        result = (mcs >= Thres and numOfDmrsCdmGroupNoData == 1) or (mcs < Thres and numOfDmrsCdmGroupNoData == 2)
        # print (result)

        return result

    except ValueError:
        return False


def check_num_cdm_grp(pcap_path, Thres):
    """Checks if the MCS and numCdmGroupNoData values in a PCAP
         file are correct.

    Args:
        pcap_path: The path to the PCAP file.
        Thres: The MCS threshold.

    Returns:
        True if all the MCS and numCdmGroupNoData values are correct,
         False otherwise.
    """
    pcap_data = generated_pcap_data(pcap_path)
    return all((is_correct_mcs(row, Thres) for row in pcap_data))


# def print_header(header_text):
#     """Prints a header with the given text."""
#     print(f"{header_text:-^80}")


# def main():
#     pcap_path = input("Enter path to bip l2l1 file: ")
#     Thres = int(input("Enter dmrs Threshold: "))
#     if check_mcs_dmrs_value(pcap_path, Thres):
#         print_header("\033[92mMCS and numCdmGroupNoData are correct\033[0m")
#     else:
#         print_header("\033[91mMCS and numCdmGroupNoData are Not correct !\033[0m")


# if __name__ == "__main__":
#     main()
