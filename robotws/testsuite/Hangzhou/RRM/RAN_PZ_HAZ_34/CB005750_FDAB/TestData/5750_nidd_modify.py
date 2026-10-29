from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
LNBTS1_NAME = 'LNBTS-' + str(tl.enbs[0].global_bts_id)
LNBTS2_NAME = 'LNBTS-' + str(tl.enbs[1].global_bts_id)
GNB_IP = str(tl.gnbs[0].dus[0].f1_m_ip_addr)
TL_NUM = str(tl.gnbs[0].instance_id)

if TL_NUM == '249':
    LNADJGNB_TO_ADD = LNBTS2_NAME + '/LNADJGNB-5'
    ENB2_ADD_LNADJGNB_VIA_API = [dict(value='locked', dist_name=LNADJGNB_TO_ADD, parameter='administrativeState'),
                                 dict(value=GNB_IP, dist_name=LNADJGNB_TO_ADD, parameter='cPlaneIpAddr'),
                                 dict(value='oamControlled', dist_name=LNADJGNB_TO_ADD,
                                      parameter='cPlaneIpAddrCtrl'),
                                 dict(value='5', dist_name=LNADJGNB_TO_ADD, parameter='lnAdjGnbId')]
elif TL_NUM == '253':
    LNADJGNB_TO_ADD = LNBTS2_NAME + '/LNADJGNB-6'
    ENB2_ADD_LNADJGNB_VIA_API = [dict(value='locked', dist_name=LNADJGNB_TO_ADD, parameter='administrativeState'),
                                 dict(value=GNB_IP, dist_name=LNADJGNB_TO_ADD, parameter='cPlaneIpAddr'),
                                 dict(value='oamControlled', dist_name=LNADJGNB_TO_ADD,
                                      parameter='cPlaneIpAddrCtrl'),
                                 dict(value='6', dist_name=LNADJGNB_TO_ADD, parameter='lnAdjGnbId')]
else:
    LNADJGNB_TO_ADD = LNBTS2_NAME + '/LNADJGNB-7'
    ENB2_ADD_LNADJGNB_VIA_API = [dict(value='locked', dist_name=LNADJGNB_TO_ADD, parameter='administrativeState'),
                                 dict(value=GNB_IP, dist_name=LNADJGNB_TO_ADD, parameter='cPlaneIpAddr'),
                                 dict(value='oamControlled', dist_name=LNADJGNB_TO_ADD,
                                      parameter='cPlaneIpAddrCtrl'),
                                 dict(value='7', dist_name=LNADJGNB_TO_ADD, parameter='lnAdjGnbId')]

ENB1_PDU = str(tl.enbs[0].airscale.common_units[0].pdu_port.pdu.addr)

ENB1_LOCK_VIA_API = [dict(value='locked', dist_name=LNBTS1_NAME + '/LNADJGNB-2', parameter='administrativeState')]

ENB1_UNLOCK_VIA_API = [
    dict(value='unlocked', dist_name=LNBTS1_NAME + '/LNADJGNB-2', parameter='administrativeState')]

GNB_UNLOCK_VIA_API = [dict(value='unlocked', dist_name=MR_NR_BTS_NAME + '/LTEENB-0', parameter='x2LinkLock')]

GNB_LOCK_VIA_API = [dict(value='locked', dist_name=MR_NR_BTS_NAME + '/LTEENB-0', parameter='x2LinkLock')]

ENB2_LOCK_VIA_API = [dict(value='locked', dist_name=LNADJGNB_TO_ADD, parameter='administrativeState')]

ENB2_UNLOCK_VIA_API = [dict(value='unlocked', dist_name=LNADJGNB_TO_ADD, parameter='administrativeState')]

LNADJGNB_OBJ_TO_DELETE = [dict(dist_name=LNADJGNB_TO_ADD)]

PAPRAMS_MODIFY_SCF = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1', list_name='ulPowerControlCommon',
         p_name='p0NominalPucch', value='-78'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1', list_name='ulPowerControlCommon',
         p_name='p0NominalPusch', value='-78'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1', list_name='ulPowerControlCommon',
         p_name='p0NominalSrs', value='-78'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='ssPbchBlockPower', value='5')]
