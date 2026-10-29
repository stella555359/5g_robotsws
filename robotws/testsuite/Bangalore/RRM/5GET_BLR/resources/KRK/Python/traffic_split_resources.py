from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations as GnbCell
from moler.device import DeviceFactory


def lock_3_out_of_4_nr_cells():
    """
    Lock 3 out of 4 NR cells

    :return: None
    """
    gnb_cells = GnbCell()
    gnb_cells.lock_cell(cell_id=2)
    gnb_cells.lock_cell(cell_id=3)
    gnb_cells.lock_cell(cell_id=4)


def unlock_3_out_of_4_nr_cells():
    """
    Unlock 3 out of 4 NR cells

    :return: None
    """
    gnb_cells = GnbCell()
    gnb_cells.unlock_cell(cell_id=2)
    gnb_cells.unlock_cell(cell_id=3)
    gnb_cells.unlock_cell(cell_id=4)


def verify_gnb_cu_include_poll_bit_in_pdus_on(interface, bts_id=0):
    """
    Verify if gNB-CU include poll bit in PDUs sent to gNB-DU and eNB.

    :param: interface to check
    :return: None
    """
    device_name = "GNB{}".format(bts_id)
    bts = DeviceFactory.get_device(device_name)
    bts.goto_state("FCT")
    tcpdump_cmd = bts.get_cmd(cmd_name="tcpdump",
                              cmd_params={"options": "-i {} -vvv".format(interface),
                                          "break_exec_regex": r"Report polling: Downlink Data Delivery Status report"})
    tcpdump_cmd.start(timeout=100)


def verify_ddds_messages_occur_at_link(interface, bts_id=0):
    """
    Verify DDDS messages occur at proper link.

    :param: interface to check
    :return: None
    """
    device_name = "GNB{}".format(bts_id)
    bts = DeviceFactory.get_device(device_name)
    bts.goto_state("FCT")
    tcpdump_cmd = bts.get_cmd(cmd_name="tcpdump",
                              cmd_params={"options": "-i {} -vvv".format(interface),
                                          "break_exec_regex": r"PDU Type: DL DATA DELIVERY STATUS"})
    tcpdump_cmd.start(timeout=100)
