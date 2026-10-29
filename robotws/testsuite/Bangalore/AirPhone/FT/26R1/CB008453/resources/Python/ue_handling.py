import logging
import ute_wtssim
import utils
from ta_egate_cmd_parser import ta_egate_cmd_parser


class ue_handling:
    @utils.skip_if_dryrun
    def __init__(self):
        self.ta_egate = ta_egate_cmd_parser()
        self.wtssim_instance = ute_wtssim.ute_wtssim()
        self.wtssim_instance.setup_egate(egate_port=20000)

    def check_egate_active_state(func):
        """
        Decorator to check that egate are in active states before executing the keyword
        """
        def wrapper(self, **kwargs):
            self.check_if_egate_is_active()
            func(self, **kwargs)
        return wrapper

    def check_if_egate_is_active(self):
        """
        Executes state command on egate and wait for 'The state is ACTIVE' regexp
        :return:
        """
        try:
            self.wtssim_instance.execute_egate_command(cmd='state', pass_regexp='The state is ACTIVE')
        except Exception:
            raise Exception('EgateNotActiveError: EGATE is not ACTIVE')
        logging.info('EGATE is ACTIVE')

    def ue_register(self, ue_id, pdu):
        """
        ue_register - register single ue
        +------------------+-------+------------+
        |     Example                           |
        +==================+=======+============+
        | self.ue_register(ue_id, pdu) |
        +------------------+-------+------------+

        :return:
        """

        set_pdu = f'set_pdu_param ue={ue_id} pdu={pdu} trf_type=internal'
        register = f'ue_register id={ue_id}'
        register_regexp = f'UE{ue_id}: UE performed Registration type INITIAL_REGISTRATION'
        self.wtssim_instance.execute_egate_command(cmd=set_pdu)
        self.wtssim_instance.execute_egate_command(cmd=register, pass_regexp=register_regexp)

    def pdu_session_establishment(self, ue_id, pdu, nwslice, gw):
        """
        establish_pdu_session - establishes pdu session
        +------------------+-------+------------+------------+
        |     Example                                        |
        +==================+=======+============+============+
        | self.establish_pdu_session(ue_id, pdu, nwslice, gw)|
        +------------------+-------+------------+------------+

        :return:
        """
        ue_pdu = f'ue_pdu_session_setup pdu={pdu} ue={ue_id} nwslice={nwslice} gw={gw}'
        pdu_regexp = f'UE{ue_id}: Established PDU session'
        self.wtssim_instance.execute_egate_command(cmd=ue_pdu, pass_regexp=pdu_regexp)

    def ue_attach(self, ue_id):
        """
        ue_attach - attach single NSA ue
        +------------------+-------+------------+
        |     Example                           |
        +==================+=======+============+
        | UE attach  ue_id=1                    |
        +------------------+-------+------------+

        :return:
        """

        attach = f'ue_attach id={ue_id}'
        attach_regexp = f'UE{ue_id}: === UE IS ACTIVE'
        self.wtssim_instance.execute_egate_command(cmd=attach, pass_regexp=attach_regexp)

    def ue_detach(self, ue_id):
        """
        ue_detach - detach single NSA ue
        +------------------+-------+------------+
        |     Example                           |
        +==================+=======+============+
        | UE detach  ue_id=1                    |
        +------------------+-------+------------+

        :return:
        """

        detach = f'ue_detach id={ue_id}'
        detach_regexp = f'UE{ue_id}: detached'
        self.wtssim_instance.execute_egate_command(cmd=detach, pass_regexp=detach_regexp)

    def ue_deregister(self, ue_id):
        """
        ue_detach - detach single NSA ue
        +------------------+-------+------------+
        |     Example                           |
        +==================+=======+============+
        | UE detach  ue_id=1                    |
        +------------------+-------+------------+

        :return:
        """

        detach = f'ue_deregister id={ue_id} ue_deregister_type=switch_off'
        detach_regexp = f'UE{ue_id}: detached'
        self.wtssim_instance.execute_egate_command(cmd=detach, pass_regexp=detach_regexp)

    def addition_sgnb(self, ue_id, cell_id=1, gnb_id=2, bearer_id=2):
        """
        ue_attach - attach single NSA ue
        +------------------+-------+------------+
        |     Example                           |
        +==================+=======+============+
        | Addition SgNB  ue_id=1  cell_id=2     |
        +------------------+-------+------------+

        :return:
        """

        addition = \
            f'ue_dc_enb_start ue={ue_id} target_gnb={gnb_id} target_cells={cell_id} bearer={bearer_id} type=split_scg'
        addition_regexp = f'Successfully reconfigured dual connectivity'
        self.wtssim_instance.execute_egate_command(cmd=addition, pass_regexp=addition_regexp)

    def attach_multi_ues(self, first_ue_id=1, last_ue_id=2, cell_id=1, gnb_id=2, bearer_id=2):
        """
        attach_multi_ues - registers multiple UEs on given pdu and cell
        +------------------+-------+------------+------------+
        |     Example                                        |
        +==================+=======+============+============+
        | Attach multi ues  first_ue_id=11  last_ue_id=12    |
        +------------------+-------+------------+------------+

        :return:
        """
        for ue_id in range(first_ue_id, last_ue_id + 1):
            self.ue_attach(ue_id)
            self.addition_sgnb(ue_id, cell_id, gnb_id, bearer_id)

    def register_multi_ues(self, first_ue_id=1, last_ue_id=28, pdu=1, nwslice=1, gw=1, cell_id=1):
        """
        register_multi_ues - registers multiple UEs on given pdu and cell
        +------------------+-------+------------+------------+------------+
        |     Example                                                     |
        +==================+=======+============+============+============+
        | Register multi ues   first_ue_id=1  last_ue_id=28  cell_id=2    |
        +------------------+-------+------------+------------+------------+

        :return:
        """
        for ue_id in range(first_ue_id, last_ue_id + 1):
            self.ue_register(ue_id, pdu, cell_id)
            self.establish_pdu_session(ue_id, pdu, nwslice, gw)

    def deregister_multi_ues(self, first_ue_id=1, last_ue_id=28):
        """
        deregister_multi_ues - deregisters multiple UEs on given pdu and cell
        +------------------+-------+------------+------------+
        |     Example                                        |
        +==================+=======+============+============+
        | Deregister multi ues first_ue_id=1  last_ue_id=28  |
        +------------------+-------+------------+------------+

        :return:
        """
        for ue_id in range(first_ue_id, last_ue_id + 1):
            self.ue_deregister(ue_id)

    def detach_multi_ues(self, first_ue_id=107, last_ue_id=212):
        """
        detach_multi_ues - detaches multiple NSA UEs
        +------------------+-------+------------+------------+
        |     Example                                        |
        +==================+=======+============+============+
        | Detach multi ues  first_ue_id=11  last_ue_id=12    |
        +------------------+-------+------------+------------+

        :return:
        """
        for ue_id in range(first_ue_id, last_ue_id + 1):
            self.ue_detach(ue_id)

    def get_ue_crnti(self, ue_id):
        """
        Executes ue_disp command with specified ue id and retrieves UE C-RNTI
        +------------------+-------+------------+------------+
        |     Example                                        |
        +==================+=======+============+============+
        | Get UE crnti  ue_id=1                              |
        +------------------+-------+------------+------------+

        :return: ue_crnti
        """
        cmd = self.ta_egate.get_command('ue_disp')
        ue_crnti = int(cmd(id=ue_id).execute_and_parse()['C-RNTI']['Value'])
        return ue_crnti
