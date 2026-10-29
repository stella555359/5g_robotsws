from taf.hw.optical_switch import optical_switch
import sys

bbmod = int(sys.argv[1])
switch = optical_switch()
switch.setup_optical_switch(optical_switch='Leoni', model='mol 6x(2x6)', addr='10.45.176.148', port=3001)
print("Before switch >> ", switch.get_optical_switch_channels())

# 1 - ABIP
# 2 - ABIO
switch.set_optical_switch_channels(
     {
         3: bbmod,
         4: bbmod,
         5: bbmod,
         6: bbmod
     }
)

print("After switch >> ", switch.get_optical_switch_channels())

switch.teardown()
