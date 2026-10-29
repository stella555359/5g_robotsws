from cloud5g.hw.radio_params import RadioParamsProvider, RadioNotFound
try:
    radio_params = RadioParamsProvider().get('AHCA')
except RadioNotFound:
    pass
