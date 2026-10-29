# NR Frequencies Tool
from collections import namedtuple

global_frequency_raster = namedtuple(
    "global_frequency_raster",
    "Delta_F_Global, F_REF_Offs, N_REF_Offs, Min_GSCN, GSCN_Fomular",
)

NR_Frequencies_Band = {
    "n28": {
        "ulMin_Band": 703,
        "ulMax_Band": 733,
        "dlMin_Band": 758,
        "dlMax_Band": 788,
    }
}

# 3*(ss_ref*1000-50*M)//1200+(M-3)/2'],
global_frequency_raster_list = [
    [5, 0, 0, 2, "1"],
    [15, 3000, 600000, 7499, "7499+(ss_ref-3000)/1.44"],
    [60, 24250.08, 2016667, 22256, ""],
]


def calculate_list(origin_paramsul, origin_paramsdl):
    iterm = []
    for i in origin_paramsul + origin_paramsdl:
        if i not in iterm:
            iterm.append(i)
    return iterm


def calculate_gscn_AHPF(ss_ref, fomular, M=3):
    return int(eval(fomular))


def get_frequency_parameters_AHPF(band):
    ulMin_Band = NR_Frequencies_Band[band]["ulMin_Band"]
    ulMax_Band = NR_Frequencies_Band[band]["ulMax_Band"]
    dlMin_Band = NR_Frequencies_Band[band]["dlMin_Band"]
    dlMax_Band = NR_Frequencies_Band[band]["dlMax_Band"]
    frequency_parameters = global_frequency_raster._make(
        global_frequency_raster_list[0]
    )
    return ulMin_Band, ulMax_Band, dlMin_Band, dlMax_Band, frequency_parameters


def calculate_F_AHPF(N_REF, global_frequency_raster):
    return (
        global_frequency_raster.F_REF_Offs
        + global_frequency_raster.Delta_F_Global
        * (N_REF - global_frequency_raster.N_REF_Offs)
        / 1000.0
    )


def calculate_N_AHPF(F_REF, global_frequency_raster):
    return (
        global_frequency_raster.N_REF_Offs
        + (F_REF - global_frequency_raster.F_REF_Offs)
        * 1000.0
        / global_frequency_raster.Delta_F_Global
    )
