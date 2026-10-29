from taf.hw.pdu import pdu


class PduWrapper:
    def __init__(self):
        self.pduobj = pdu()

    def setup_pdu(self, model, alias, timeout):
        self.pduobj.setup_pdu(model=model, alias=alias, timeout=timeout)
