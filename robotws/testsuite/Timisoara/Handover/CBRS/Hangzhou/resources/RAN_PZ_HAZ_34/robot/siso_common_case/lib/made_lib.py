# NR Frequencies Tool
from collections import namedtuple

# variable
NR_Frequencies_Band = {
    'n78': {
        'Min_Band': 3300,
        'Max_Band': 3800,
    },
    'n41': {
        'Min_Band': 2496,
        'Max_Band': 2690,
    },
    'n40': {
        'Min_Band': 2300,
        'Max_Band': 2400,
    },
    'n53': {
        'Min_Band': 2483.5,
        'Max_Band': 2495,
    },
    'n77': {
        'Min_Band': 3300,
        'Max_Band': 4200,
    }
}


global_frequency_raster = namedtuple('global_frequency_raster',
                                     'Delta_F_Global, F_REF_Offs, N_REF_Offs, Min_GSCN, GSCN_Fomular')

# 3*(ss_ref*1000-50*M)//1200+(M-3)/2'],
# 3*((ss_ref*1000-M*50)/1200)+(M-3)/2
global_frequency_raster_list = [
    [5, 0, 0, 2, '1'],
    [15, 3000, 600000, 7499, '7499+(ss_ref-3000)/1.44'],
    [60, 24250.08, 2016667, 22256, '']
]


def calculate_gscn(ss_ref, fomular, M=3):
    return int(eval(fomular))


def get_frequency_parameters(band):
    Min_Band = NR_Frequencies_Band[band]['Min_Band']
    Max_Band = NR_Frequencies_Band[band]['Max_Band']
    if Min_Band < 3000:
        index = 0
    elif Min_Band >= 3000 and Max_Band < 24250:
        index = 1
    else:
        index = 2
    frequency_parameters = global_frequency_raster._make(global_frequency_raster_list[index])
    return Min_Band, Max_Band, frequency_parameters


def calculate_F(N_REF, global_frequency_raster):
    return global_frequency_raster.F_REF_Offs + \
           global_frequency_raster.Delta_F_Global * (N_REF - global_frequency_raster.N_REF_Offs) / 1000.0


def calculate_N(F_REF, global_frequency_raster):
    return global_frequency_raster.N_REF_Offs + \
           (F_REF - global_frequency_raster.F_REF_Offs) * 1000.0 / global_frequency_raster.Delta_F_Global


# 1: c_tx_low + bandwidth /2 < n < c_tx_high - bandwidth /2
# 2: c_tx_low+ NRB*12*SCS/2 + Minimum guardband < f_tx[n] < c_tx_high-NRB*12*SCS/2 - Minimum guardband,
# (bottomFrequency >= current->limits.bottomFrequency - margin) &&
# (topFrequency <= current->limits.topFrequency + margin))
# 3:others: c_tx_low+ NRB*12*SCS/2 + Minimum guardband < f_tx[n] < c_tx_high-NRB*12*SCS/2 - Minimum guardband
calculate_type = {
    1: ['AZHA', 'AZNA'],
    2: ['AQQA'],
    3: ['AWHQN'],
}


def calculate_maxfreq_and_minfreq(ru_type, MinFreq_bpf, MaxFreq_bpf, NRB, scs, Min_guard, bandwidth):
    MinFreq_bpf, MaxFreq_bpf, NRB, scs, Min_guard = int(MinFreq_bpf), int(MaxFreq_bpf), int(NRB), \
                                                    int(scs), int(Min_guard),
    for key, value in calculate_type.items():
        if ru_type in value:
            if key == 1:
                MinFreq = MinFreq_bpf + bandwidth / 2
                MaxFreq = MaxFreq_bpf - bandwidth / 2
                return MinFreq, MaxFreq
            elif key == 2:
                MinFreq = (MinFreq_bpf * 1000 + NRB * 12 * scs / 2 + Min_guard - 30) / 1000.0
                MaxFreq = (MaxFreq_bpf * 1000 - NRB * 12 * scs / 2 - Min_guard + 30) / 1000.0
                return MinFreq, MaxFreq
            elif key == 3:
                MinFreq = MinFreq_bpf + int(bandwidth) / 2 - 0.03
                MaxFreq = MaxFreq_bpf - int(bandwidth) / 2 + 0.03
                return MinFreq, MaxFreq
    MinFreq = (MinFreq_bpf * 1000 + NRB * 12 * scs / 2 + Min_guard) / 1000.0
    MaxFreq = (MaxFreq_bpf * 1000 - NRB * 12 * scs / 2 - Min_guard) / 1000.0
    return MinFreq, MaxFreq
