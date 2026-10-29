from taf.ul.ue.sim.env_setup.devices.bts import bts_admin_access as admin_ctx
import sys

RAD_DU_FAIL_DOMAIN = '59'
RAD_DU_FAIL_DOMAIN_DEC = int(RAD_DU_FAIL_DOMAIN, 16)
RAD_DU_FAIL = '249'
RAD_DU_FAIL_DEC = int(RAD_DU_FAIL, 16)
if len(sys.argv) == 1:
    RAD_DU_ADMIN_VALUE = 0
else:
    RAD_DU_ADMIN_VALUE = 1
print('Setting param to value: {}'.format(RAD_DU_ADMIN_VALUE))
with admin_ctx(alias='rad_change') as admin_ctx_manager:
    admin_ctx_manager.change_bts_rad_parameters(
        RAD_DU_FAIL_DOMAIN_DEC, '{}:{}'.format(RAD_DU_FAIL_DEC, RAD_DU_ADMIN_VALUE), connection='rad_change')
print('Rad param change successfully')
