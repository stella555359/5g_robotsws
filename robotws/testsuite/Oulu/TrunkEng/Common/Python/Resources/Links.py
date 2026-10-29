"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

from robot.libraries.BuiltIn import BuiltIn


class Links:
    """
    Radio and cell links.
    """
    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")

    def update_rmod_cell_links(self):
        rmod_cell_links = {}
        for cell in self.bts.cells:
            for radio in self.bts.radios:
                rmod_cell_links = self._get_rmod_cell_link(cell, radio, rmod_cell_links)
        self.bts.rmod_cell_links = rmod_cell_links
        self.logger.debug("Found rmod-cell links: {}".format(self.bts.rmod_cell_links))

    def find_affected_cells(self, radio_name):
        """
        Get a list of cells that are affected by a radio.

        :param str radio_name: Radio name in FXDB(1.1.1.1) -format.
        :return list[str] affected_cells: Returns a list of cells that are affected by a radio.
        """
        affected_cells = []
        for cell in self.bts.rmod_cell_links:
            for radio in self.bts.rmod_cell_links[cell]:
                if radio == radio_name:
                    affected_cells.append(cell)
        return affected_cells

    def _get_rmod_cell_link(self, cell, radio, rmod_cell_links):
        """
        Get a list of cells that are affected by a radio.

        :param dict cell: Cell's dictionary from BTS.cells.
        :param obj radio: A radio object from BTS.radios.
        :param dict rmod_cell_links: Dictionary with radios and their linked cells and antennae.

        :return dict rmod_cell_links: Updated version of the dictionary.
        """
        if radio.name not in rmod_cell_links:
            rmod_cell_links[radio.name] = {}
        for link in self.bts.cells[cell]["carrierList"]:
            if f"{radio.scf_dist_name}/" in link["antennaLineId"]["configuration"]:
                if cell not in rmod_cell_links[radio.name]:
                    rmod_cell_links[radio.name][cell] = {}
                antenna = link["antennaLineId"]["configuration"]
                if antenna not in rmod_cell_links[radio.name][cell]:  # only TX or RX between cell and radio
                    rmod_cell_links[radio.name][cell][antenna] = link["direction"]
                else:  # TX and RX between cell and radio
                    rmod_cell_links[radio.name][cell][antenna] = "TXRX"
        return rmod_cell_links
