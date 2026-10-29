forw mte SetUEContext 7

#cell indicator - to which connect # if want to default
FORW MTE RRCAPTCONFIGCELLSELECTION 627850 [50]

# NULL i&e
#forw mte NrNasAptConfigCapability 0 [0] [0x80] [0x80]
#NULL + AES
forw mte NrNasAptConfigCapability 0 [3] [0xE0] [0xE0]

#NULL
#forw mte NrNasAptConfigCapability 0 [3] [128] [128]

FORW L1 SETRADIOCONTEXT 0
FORW L1 NRSETPATHDELAY 32
forw mte NrNasConfigRegistration [0] [] [1(1 0 [5GSAWRO])] [] [5G:mnc001.mcc540.3gppnetwork.org]

forw mte Activate -1

WAIT FOR "ACTIVATE" TIMEOUT 60
