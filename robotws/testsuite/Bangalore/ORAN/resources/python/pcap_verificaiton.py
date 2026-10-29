import logging
import testsuite.RRM.Krakow.resources.pcap_verification.\
    tsharkWithLuaVerifier as tshark
from testsuite.RRM.Krakow.resources.pcap_verification.\
    message_to_tree import message_to_tree


class MissingPCI(Exception):
    """Missing Physical Cell Id parameter (PCI) in messagess"""
    pass


class WrongSourceCell(Exception):
    """The exception is raised when UE is attached to wrong source cell."""
    pass


class WrongTargetCell(Exception):
    """The exception is raised when UE is attached to wrong target cell."""
    pass


class MissingResponse(Exception):
    """Missing response in source messages"""
    pass


def verify_UE_Context(pcap_file, expected_source_cell, expected_target_cell):
    frames = tshark.get_filtered_tshark_output_as_frames(
        pcap_file,
        tshark_filter='f1ap.UEContextModificationRequest_element or\
         f1ap.UEContextModificationResponse_element'
    )
    logging.info(
        "Caught frames fulfilling following query:\n"
        "f1ap.UEContextModificationRequest_element "
        "or f1ap.UEContextModificationResponse_element \n "
    )
    trees = [message_to_tree(message) for message in frames]
    for index, message in enumerate(trees):
        physcellId = message.find(b"physCellId")
        if physcellId:
            logging.info(physcellId)
            source_cell_id = int(physcellId[0]['val'])
            msg = "Physical cell id of source cell is {}, and expected is {}".\
                format(source_cell_id, expected_source_cell)
            logging.info(msg)
            if source_cell_id != expected_source_cell:
                raise WrongSourceCell(msg)
            target_cell_id = int(physcellId[1]['val'])
            msg = "Physical cell id of target cell is {} and expected is {}".\
                format(target_cell_id, expected_target_cell)
            logging.info(msg)
            if target_cell_id != expected_target_cell:
                raise WrongTargetCell(msg)
            message_no = index
            break
    else:
        raise MissingPCI("Missing Physical Cell Id parameter (PCI) in message")
    try:
        first_response = trees[message_no+1]
        msg = "Physical cell Id of attached cell is {}"
        logging.info(msg)
        if int(first_response.find(b"physCellId")[0]['val']) !=\
                expected_target_cell:
            raise WrongTargetCell(msg)
    except IndexError:
        raise MissingResponse("Missing response in source messages")
