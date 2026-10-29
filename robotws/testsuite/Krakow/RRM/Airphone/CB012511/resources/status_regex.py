import re

cell_state = re.compile(r'configured|onair|(not initialized)')
bts_up_state = re.compile(r'configured|onair|IntegratedToRan')
