import re
import random
import math
import datetime

power_basic = {
    302: {'start': 150, 'end': 151},
    304: {'start': 147, 'end': 150},
}

sinr_basic = {
    302: {'start': 189, 'end': 190},
    304: {'start': 188, 'end': 191},
}

table1 = [
    {"SRS bandwidth for SB BF": 4, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 0,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 4, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 0,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 4, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 0,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 4, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 0,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 8, "Number of SRS subband per symbol": 1, "SRS subband size": 8, "cSRS": 1,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 8, "Number of SRS subband per symbol": 2, "SRS subband size": 4, "cSRS": 1,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 8, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 1,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 8, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 1,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 12, "Number of SRS subband per symbol": 1, "SRS subband size": 12, "cSRS": 2,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 12, "Number of SRS subband per symbol": 3, "SRS subband size": 4, "cSRS": 2,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 12, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 2,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 12, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 2,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 16, "Number of SRS subband per symbol": 1, "SRS subband size": 16, "cSRS": 3,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 16, "Number of SRS subband per symbol": 4, "SRS subband size": 4, "cSRS": 3,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 16, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 3,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 16, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 3,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 16, "Number of SRS subband per symbol": 1, "SRS subband size": 16, "cSRS": 4,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 16, "Number of SRS subband per symbol": 2, "SRS subband size": 8, "cSRS": 4,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 16, "Number of SRS subband per symbol": 2, "SRS subband size": 4, "cSRS": 4,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 16, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 4,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 20, "Number of SRS subband per symbol": 1, "SRS subband size": 20, "cSRS": 5,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 20, "Number of SRS subband per symbol": 5, "SRS subband size": 4, "cSRS": 5,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 20, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 5,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 20, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 5,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 24, "Number of SRS subband per symbol": 1, "SRS subband size": 24, "cSRS": 6,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 24, "Number of SRS subband per symbol": 6, "SRS subband size": 4, "cSRS": 6,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 24, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 6,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 24, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 6,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 24, "Number of SRS subband per symbol": 1, "SRS subband size": 24, "cSRS": 7,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 24, "Number of SRS subband per symbol": 2, "SRS subband size": 12, "cSRS": 7,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 24, "Number of SRS subband per symbol": 3, "SRS subband size": 4, "cSRS": 7,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 24, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 7,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 28, "Number of SRS subband per symbol": 1, "SRS subband size": 28, "cSRS": 8,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 28, "Number of SRS subband per symbol": 7, "SRS subband size": 4, "cSRS": 8,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 28, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 8,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 28, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 8,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 32, "Number of SRS subband per symbol": 1, "SRS subband size": 32, "cSRS": 9,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 32, "Number of SRS subband per symbol": 2, "SRS subband size": 16, "cSRS": 9,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 32, "Number of SRS subband per symbol": 2, "SRS subband size": 8, "cSRS": 9,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 32, "Number of SRS subband per symbol": 2, "SRS subband size": 4, "cSRS": 9,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 36, "Number of SRS subband per symbol": 1, "SRS subband size": 36, "cSRS": 10,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 36, "Number of SRS subband per symbol": 3, "SRS subband size": 12, "cSRS": 10,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 36, "Number of SRS subband per symbol": 3, "SRS subband size": 4, "cSRS": 10,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 36, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 10,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 40, "Number of SRS subband per symbol": 1, "SRS subband size": 40, "cSRS": 11,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 40, "Number of SRS subband per symbol": 2, "SRS subband size": 20, "cSRS": 11,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 40, "Number of SRS subband per symbol": 5, "SRS subband size": 4, "cSRS": 11,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 40, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 11,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 48, "Number of SRS subband per symbol": 1, "SRS subband size": 48, "cSRS": 12,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 48, "Number of SRS subband per symbol": 3, "SRS subband size": 16, "cSRS": 12,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 48, "Number of SRS subband per symbol": 2, "SRS subband size": 8, "cSRS": 12,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 48, "Number of SRS subband per symbol": 2, "SRS subband size": 4, "cSRS": 12,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 48, "Number of SRS subband per symbol": 1, "SRS subband size": 48, "cSRS": 13,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 48, "Number of SRS subband per symbol": 2, "SRS subband size": 24, "cSRS": 13,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 48, "Number of SRS subband per symbol": 2, "SRS subband size": 12, "cSRS": 13,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 48, "Number of SRS subband per symbol": 3, "SRS subband size": 4, "cSRS": 13,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 52, "Number of SRS subband per symbol": 1, "SRS subband size": 52, "cSRS": 14,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 52, "Number of SRS subband per symbol": 13, "SRS subband size": 4, "cSRS": 14,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 52, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 14,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 52, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 14,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 56, "Number of SRS subband per symbol": 1, "SRS subband size": 56, "cSRS": 15,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 56, "Number of SRS subband per symbol": 2, "SRS subband size": 28, "cSRS": 15,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 56, "Number of SRS subband per symbol": 7, "SRS subband size": 4, "cSRS": 15,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 56, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 15,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 60, "Number of SRS subband per symbol": 1, "SRS subband size": 60, "cSRS": 16,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 60, "Number of SRS subband per symbol": 3, "SRS subband size": 20, "cSRS": 16,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 60, "Number of SRS subband per symbol": 5, "SRS subband size": 4, "cSRS": 16,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 60, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 16,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 64, "Number of SRS subband per symbol": 1, "SRS subband size": 64, "cSRS": 17,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 64, "Number of SRS subband per symbol": 2, "SRS subband size": 32, "cSRS": 17,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 64, "Number of SRS subband per symbol": 2, "SRS subband size": 16, "cSRS": 17,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 64, "Number of SRS subband per symbol": 4, "SRS subband size": 4, "cSRS": 17,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 72, "Number of SRS subband per symbol": 1, "SRS subband size": 72, "cSRS": 18,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 72, "Number of SRS subband per symbol": 3, "SRS subband size": 24, "cSRS": 18,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 72, "Number of SRS subband per symbol": 2, "SRS subband size": 12, "cSRS": 18,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 72, "Number of SRS subband per symbol": 3, "SRS subband size": 4, "cSRS": 18,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 72, "Number of SRS subband per symbol": 1, "SRS subband size": 72, "cSRS": 19,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 72, "Number of SRS subband per symbol": 2, "SRS subband size": 36, "cSRS": 19,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 72, "Number of SRS subband per symbol": 3, "SRS subband size": 12, "cSRS": 19,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 72, "Number of SRS subband per symbol": 3, "SRS subband size": 4, "cSRS": 19,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 76, "Number of SRS subband per symbol": 1, "SRS subband size": 76, "cSRS": 20,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 76, "Number of SRS subband per symbol": 19, "SRS subband size": 4, "cSRS": 20,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 76, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 20,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 76, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 20,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 80, "Number of SRS subband per symbol": 1, "SRS subband size": 80, "cSRS": 21,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 80, "Number of SRS subband per symbol": 2, "SRS subband size": 40, "cSRS": 21,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 80, "Number of SRS subband per symbol": 2, "SRS subband size": 20, "cSRS": 21,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 80, "Number of SRS subband per symbol": 5, "SRS subband size": 4, "cSRS": 21,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 88, "Number of SRS subband per symbol": 1, "SRS subband size": 88, "cSRS": 22,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 88, "Number of SRS subband per symbol": 2, "SRS subband size": 44, "cSRS": 22,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 88, "Number of SRS subband per symbol": 11, "SRS subband size": 4, "cSRS": 22,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 88, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 22,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 1, "SRS subband size": 96, "cSRS": 23,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 3, "SRS subband size": 32, "cSRS": 23,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 2, "SRS subband size": 16, "cSRS": 23,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 4, "SRS subband size": 4, "cSRS": 23,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 1, "SRS subband size": 96, "cSRS": 24,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 2, "SRS subband size": 48, "cSRS": 24,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 2, "SRS subband size": 24, "cSRS": 24,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 6, "SRS subband size": 4, "cSRS": 24,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 104, "Number of SRS subband per symbol": 1, "SRS subband size": 104, "cSRS": 25,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 104, "Number of SRS subband per symbol": 2, "SRS subband size": 52, "cSRS": 25,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 104, "Number of SRS subband per symbol": 13, "SRS subband size": 4, "cSRS": 25,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 104, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 25,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 112, "Number of SRS subband per symbol": 1, "SRS subband size": 112, "cSRS": 26,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 112, "Number of SRS subband per symbol": 2, "SRS subband size": 56, "cSRS": 26,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 112, "Number of SRS subband per symbol": 2, "SRS subband size": 28, "cSRS": 26,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 112, "Number of SRS subband per symbol": 7, "SRS subband size": 4, "cSRS": 26,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 1, "SRS subband size": 120, "cSRS": 27,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 2, "SRS subband size": 60, "cSRS": 27,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 3, "SRS subband size": 20, "cSRS": 27,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 5, "SRS subband size": 4, "cSRS": 27,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 1, "SRS subband size": 120, "cSRS": 28,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 3, "SRS subband size": 40, "cSRS": 28,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 5, "SRS subband size": 8, "cSRS": 28,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 2, "SRS subband size": 4, "cSRS": 28,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 1, "SRS subband size": 120, "cSRS": 29,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 5, "SRS subband size": 24, "cSRS": 29,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 2, "SRS subband size": 12, "cSRS": 29,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 3, "SRS subband size": 4, "cSRS": 29,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 1, "SRS subband size": 128, "cSRS": 30,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 2, "SRS subband size": 64, "cSRS": 30,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 2, "SRS subband size": 32, "cSRS": 30,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 8, "SRS subband size": 4, "cSRS": 30,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 1, "SRS subband size": 128, "cSRS": 31,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 2, "SRS subband size": 64, "cSRS": 31,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 4, "SRS subband size": 16, "cSRS": 31,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 4, "SRS subband size": 4, "cSRS": 31,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 1, "SRS subband size": 128, "cSRS": 32,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 8, "SRS subband size": 16, "cSRS": 32,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 2, "SRS subband size": 8, "cSRS": 32,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 2, "SRS subband size": 4, "cSRS": 32,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 132, "Number of SRS subband per symbol": 1, "SRS subband size": 132, "cSRS": 33,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 132, "Number of SRS subband per symbol": 3, "SRS subband size": 44, "cSRS": 33,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 132, "Number of SRS subband per symbol": 11, "SRS subband size": 4, "cSRS": 33,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 132, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 33,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 136, "Number of SRS subband per symbol": 1, "SRS subband size": 136, "cSRS": 34,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 136, "Number of SRS subband per symbol": 2, "SRS subband size": 68, "cSRS": 34,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 136, "Number of SRS subband per symbol": 17, "SRS subband size": 4, "cSRS": 34,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 136, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 34,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 1, "SRS subband size": 144, "cSRS": 35,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 2, "SRS subband size": 72, "cSRS": 35,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 2, "SRS subband size": 36, "cSRS": 35,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 9, "SRS subband size": 4, "cSRS": 35,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 1, "SRS subband size": 144, "cSRS": 36,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 3, "SRS subband size": 48, "cSRS": 36,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 2, "SRS subband size": 24, "cSRS": 36,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 2, "SRS subband size": 12, "cSRS": 36,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 1, "SRS subband size": 144, "cSRS": 37,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 3, "SRS subband size": 48, "cSRS": 37,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 3, "SRS subband size": 16, "cSRS": 37,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 4, "SRS subband size": 4, "cSRS": 37,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 1, "SRS subband size": 144, "cSRS": 38,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 9, "SRS subband size": 16, "cSRS": 38,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 2, "SRS subband size": 8, "cSRS": 38,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 2, "SRS subband size": 4, "cSRS": 38,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 152, "Number of SRS subband per symbol": 1, "SRS subband size": 152, "cSRS": 39,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 152, "Number of SRS subband per symbol": 2, "SRS subband size": 76, "cSRS": 39,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 152, "Number of SRS subband per symbol": 19, "SRS subband size": 4, "cSRS": 39,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 152, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 39,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 1, "SRS subband size": 160, "cSRS": 40,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 2, "SRS subband size": 80, "cSRS": 40,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 2, "SRS subband size": 40, "cSRS": 40,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 10, "SRS subband size": 4, "cSRS": 40,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 1, "SRS subband size": 160, "cSRS": 41,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 2, "SRS subband size": 80, "cSRS": 41,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 4, "SRS subband size": 20, "cSRS": 41,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 5, "SRS subband size": 4, "cSRS": 41,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 1, "SRS subband size": 160, "cSRS": 42,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 5, "SRS subband size": 32, "cSRS": 42,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 2, "SRS subband size": 16, "cSRS": 42,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 4, "SRS subband size": 4, "cSRS": 42,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 168, "Number of SRS subband per symbol": 1, "SRS subband size": 168, "cSRS": 43,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 168, "Number of SRS subband per symbol": 2, "SRS subband size": 84, "cSRS": 43,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 168, "Number of SRS subband per symbol": 3, "SRS subband size": 28, "cSRS": 43,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 168, "Number of SRS subband per symbol": 7, "SRS subband size": 4, "cSRS": 43,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 176, "Number of SRS subband per symbol": 1, "SRS subband size": 176, "cSRS": 44,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 176, "Number of SRS subband per symbol": 2, "SRS subband size": 88, "cSRS": 44,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 176, "Number of SRS subband per symbol": 2, "SRS subband size": 44, "cSRS": 44,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 176, "Number of SRS subband per symbol": 11, "SRS subband size": 4, "cSRS": 44,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 184, "Number of SRS subband per symbol": 1, "SRS subband size": 184, "cSRS": 45,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 184, "Number of SRS subband per symbol": 2, "SRS subband size": 92, "cSRS": 45,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 184, "Number of SRS subband per symbol": 23, "SRS subband size": 4, "cSRS": 45,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 184, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 45,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 1, "SRS subband size": 192, "cSRS": 46,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 2, "SRS subband size": 96, "cSRS": 46,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 2, "SRS subband size": 48, "cSRS": 46,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 12, "SRS subband size": 4, "cSRS": 46,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 1, "SRS subband size": 192, "cSRS": 47,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 2, "SRS subband size": 96, "cSRS": 47,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 4, "SRS subband size": 24, "cSRS": 47,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 6, "SRS subband size": 4, "cSRS": 47,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 1, "SRS subband size": 192, "cSRS": 48,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 3, "SRS subband size": 64, "cSRS": 48,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 4, "SRS subband size": 16, "cSRS": 48,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 4, "SRS subband size": 4, "cSRS": 48,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 1, "SRS subband size": 192, "cSRS": 49,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 8, "SRS subband size": 24, "cSRS": 49,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 3, "SRS subband size": 8, "cSRS": 49,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 2, "SRS subband size": 4, "cSRS": 49,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 208, "Number of SRS subband per symbol": 1, "SRS subband size": 208, "cSRS": 50,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 208, "Number of SRS subband per symbol": 2, "SRS subband size": 104, "cSRS": 50,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 208, "Number of SRS subband per symbol": 2, "SRS subband size": 52, "cSRS": 50,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 208, "Number of SRS subband per symbol": 13, "SRS subband size": 4, "cSRS": 50,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 216, "Number of SRS subband per symbol": 1, "SRS subband size": 216, "cSRS": 51,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 216, "Number of SRS subband per symbol": 2, "SRS subband size": 108, "cSRS": 51,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 216, "Number of SRS subband per symbol": 3, "SRS subband size": 36, "cSRS": 51,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 216, "Number of SRS subband per symbol": 9, "SRS subband size": 4, "cSRS": 51,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 224, "Number of SRS subband per symbol": 1, "SRS subband size": 224, "cSRS": 52,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 224, "Number of SRS subband per symbol": 2, "SRS subband size": 112, "cSRS": 52,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 224, "Number of SRS subband per symbol": 2, "SRS subband size": 56, "cSRS": 52,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 224, "Number of SRS subband per symbol": 14, "SRS subband size": 4, "cSRS": 52,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 1, "SRS subband size": 240, "cSRS": 53,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 2, "SRS subband size": 120, "cSRS": 53,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 2, "SRS subband size": 60, "cSRS": 53,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 15, "SRS subband size": 4, "cSRS": 53,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 1, "SRS subband size": 240, "cSRS": 54,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 3, "SRS subband size": 80, "cSRS": 54,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 4, "SRS subband size": 20, "cSRS": 54,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 5, "SRS subband size": 4, "cSRS": 54,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 1, "SRS subband size": 240, "cSRS": 55,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 5, "SRS subband size": 48, "cSRS": 55,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 3, "SRS subband size": 16, "cSRS": 55,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 2, "SRS subband size": 8, "cSRS": 55,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 1, "SRS subband size": 240, "cSRS": 56,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 10, "SRS subband size": 24, "cSRS": 56,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 2, "SRS subband size": 12, "cSRS": 56,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 3, "SRS subband size": 4, "cSRS": 56,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 1, "SRS subband size": 256, "cSRS": 57,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 2, "SRS subband size": 128, "cSRS": 57,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 2, "SRS subband size": 64, "cSRS": 57,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 16, "SRS subband size": 4, "cSRS": 57,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 1, "SRS subband size": 256, "cSRS": 58,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 2, "SRS subband size": 128, "cSRS": 58,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 4, "SRS subband size": 32, "cSRS": 58,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 8, "SRS subband size": 4, "cSRS": 58,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 1, "SRS subband size": 256, "cSRS": 59,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 16, "SRS subband size": 16, "cSRS": 59,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 2, "SRS subband size": 8, "cSRS": 59,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 2, "SRS subband size": 4, "cSRS": 59,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 264, "Number of SRS subband per symbol": 1, "SRS subband size": 264, "cSRS": 60,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 264, "Number of SRS subband per symbol": 2, "SRS subband size": 132, "cSRS": 60,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 264, "Number of SRS subband per symbol": 3, "SRS subband size": 44, "cSRS": 60,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 264, "Number of SRS subband per symbol": 11, "SRS subband size": 4, "cSRS": 60,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 1, "SRS subband size": 272, "cSRS": 61,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 2, "SRS subband size": 136, "cSRS": 61,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 2, "SRS subband size": 68, "cSRS": 61,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 17, "SRS subband size": 4, "cSRS": 61,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 1, "SRS subband size": 272, "cSRS": 62,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 4, "SRS subband size": 68, "cSRS": 62,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 17, "SRS subband size": 4, "cSRS": 62,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 1, "SRS subband size": 4, "cSRS": 62,
     "bSRS": 3},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 1, "SRS subband size": 272, "cSRS": 63,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 17, "SRS subband size": 16, "cSRS": 63,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 2, "SRS subband size": 8, "cSRS": 63,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 2, "SRS subband size": 4, "cSRS": 63,
     "bSRS": 3},
]

table2 = [
    {"SRS bandwidth for SB BF": 16, "Number of SRS subband per symbol": 1, "SRS subband size": 16, "cSRS": 3,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 20, "Number of SRS subband per symbol": 1, "SRS subband size": 20, "cSRS": 5,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 24, "Number of SRS subband per symbol": 1, "SRS subband size": 24, "cSRS": 6,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 28, "Number of SRS subband per symbol": 1, "SRS subband size": 28, "cSRS": 8,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 32, "Number of SRS subband per symbol": 1, "SRS subband size": 32, "cSRS": 9,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 32, "Number of SRS subband per symbol": 2, "SRS subband size": 16, "cSRS": 9,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 36, "Number of SRS subband per symbol": 1, "SRS subband size": 36, "cSRS": 10,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 40, "Number of SRS subband per symbol": 1, "SRS subband size": 40, "cSRS": 11,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 40, "Number of SRS subband per symbol": 2, "SRS subband size": 20, "cSRS": 11,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 48, "Number of SRS subband per symbol": 1, "SRS subband size": 48, "cSRS": 12,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 48, "Number of SRS subband per symbol": 2, "SRS subband size": 24, "cSRS": 13,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 48, "Number of SRS subband per symbol": 3, "SRS subband size": 16, "cSRS": 12,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 52, "Number of SRS subband per symbol": 1, "SRS subband size": 52, "cSRS": 14,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 56, "Number of SRS subband per symbol": 1, "SRS subband size": 56, "cSRS": 15,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 56, "Number of SRS subband per symbol": 2, "SRS subband size": 28, "cSRS": 15,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 60, "Number of SRS subband per symbol": 1, "SRS subband size": 60, "cSRS": 16,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 60, "Number of SRS subband per symbol": 3, "SRS subband size": 20, "cSRS": 16,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 64, "Number of SRS subband per symbol": 1, "SRS subband size": 64, "cSRS": 17,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 64, "Number of SRS subband per symbol": 2, "SRS subband size": 32, "cSRS": 17,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 64, "Number of SRS subband per symbol": 4, "SRS subband size": 16, "cSRS": 17,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 72, "Number of SRS subband per symbol": 1, "SRS subband size": 72, "cSRS": 18,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 72, "Number of SRS subband per symbol": 2, "SRS subband size": 36, "cSRS": 19,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 72, "Number of SRS subband per symbol": 3, "SRS subband size": 24, "cSRS": 18,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 76, "Number of SRS subband per symbol": 1, "SRS subband size": 76, "cSRS": 20,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 80, "Number of SRS subband per symbol": 1, "SRS subband size": 80, "cSRS": 21,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 80, "Number of SRS subband per symbol": 2, "SRS subband size": 40, "cSRS": 21,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 80, "Number of SRS subband per symbol": 4, "SRS subband size": 20, "cSRS": 21,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 88, "Number of SRS subband per symbol": 1, "SRS subband size": 88, "cSRS": 22,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 88, "Number of SRS subband per symbol": 2, "SRS subband size": 44, "cSRS": 22,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 1, "SRS subband size": 96, "cSRS": 23,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 2, "SRS subband size": 48, "cSRS": 24,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 3, "SRS subband size": 32, "cSRS": 23,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 4, "SRS subband size": 24, "cSRS": 24,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 96, "Number of SRS subband per symbol": 6, "SRS subband size": 16, "cSRS": 23,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 104, "Number of SRS subband per symbol": 1, "SRS subband size": 104, "cSRS": 25,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 104, "Number of SRS subband per symbol": 2, "SRS subband size": 52, "cSRS": 25,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 112, "Number of SRS subband per symbol": 1, "SRS subband size": 112, "cSRS": 26,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 112, "Number of SRS subband per symbol": 2, "SRS subband size": 56, "cSRS": 26,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 112, "Number of SRS subband per symbol": 4, "SRS subband size": 28, "cSRS": 26,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 1, "SRS subband size": 120, "cSRS": 27,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 2, "SRS subband size": 60, "cSRS": 27,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 3, "SRS subband size": 40, "cSRS": 28,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 5, "SRS subband size": 24, "cSRS": 29,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 120, "Number of SRS subband per symbol": 6, "SRS subband size": 20, "cSRS": 27,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 1, "SRS subband size": 128, "cSRS": 30,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 2, "SRS subband size": 64, "cSRS": 30,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 4, "SRS subband size": 32, "cSRS": 30,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 128, "Number of SRS subband per symbol": 8, "SRS subband size": 16, "cSRS": 32,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 132, "Number of SRS subband per symbol": 1, "SRS subband size": 132, "cSRS": 33,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 132, "Number of SRS subband per symbol": 3, "SRS subband size": 44, "cSRS": 33,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 136, "Number of SRS subband per symbol": 1, "SRS subband size": 136, "cSRS": 34,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 136, "Number of SRS subband per symbol": 2, "SRS subband size": 68, "cSRS": 34,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 1, "SRS subband size": 144, "cSRS": 35,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 2, "SRS subband size": 72, "cSRS": 35,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 3, "SRS subband size": 48, "cSRS": 36,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 4, "SRS subband size": 36, "cSRS": 35,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 6, "SRS subband size": 24, "cSRS": 36,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 144, "Number of SRS subband per symbol": 9, "SRS subband size": 16, "cSRS": 38,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 152, "Number of SRS subband per symbol": 1, "SRS subband size": 152, "cSRS": 39,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 152, "Number of SRS subband per symbol": 2, "SRS subband size": 76, "cSRS": 39,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 1, "SRS subband size": 160, "cSRS": 40,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 2, "SRS subband size": 80, "cSRS": 40,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 4, "SRS subband size": 40, "cSRS": 40,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 5, "SRS subband size": 32, "cSRS": 42,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 8, "SRS subband size": 20, "cSRS": 41,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 160, "Number of SRS subband per symbol": 10, "SRS subband size": 16, "cSRS": 42,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 168, "Number of SRS subband per symbol": 1, "SRS subband size": 168, "cSRS": 43,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 168, "Number of SRS subband per symbol": 2, "SRS subband size": 84, "cSRS": 43,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 168, "Number of SRS subband per symbol": 6, "SRS subband size": 28, "cSRS": 43,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 176, "Number of SRS subband per symbol": 1, "SRS subband size": 176, "cSRS": 44,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 176, "Number of SRS subband per symbol": 2, "SRS subband size": 88, "cSRS": 44,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 176, "Number of SRS subband per symbol": 4, "SRS subband size": 44, "cSRS": 44,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 184, "Number of SRS subband per symbol": 1, "SRS subband size": 184, "cSRS": 45,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 184, "Number of SRS subband per symbol": 2, "SRS subband size": 92, "cSRS": 45,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 1, "SRS subband size": 192, "cSRS": 46,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 2, "SRS subband size": 96, "cSRS": 46,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 3, "SRS subband size": 64, "cSRS": 48,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 4, "SRS subband size": 48, "cSRS": 46,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 8, "SRS subband size": 24, "cSRS": 49,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 192, "Number of SRS subband per symbol": 12, "SRS subband size": 16, "cSRS": 48,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 208, "Number of SRS subband per symbol": 1, "SRS subband size": 208, "cSRS": 50,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 208, "Number of SRS subband per symbol": 2, "SRS subband size": 104, "cSRS": 50,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 208, "Number of SRS subband per symbol": 4, "SRS subband size": 52, "cSRS": 50,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 216, "Number of SRS subband per symbol": 1, "SRS subband size": 216, "cSRS": 51,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 216, "Number of SRS subband per symbol": 2, "SRS subband size": 108, "cSRS": 51,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 216, "Number of SRS subband per symbol": 6, "SRS subband size": 36, "cSRS": 51,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 224, "Number of SRS subband per symbol": 1, "SRS subband size": 224, "cSRS": 52,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 224, "Number of SRS subband per symbol": 2, "SRS subband size": 112, "cSRS": 52,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 224, "Number of SRS subband per symbol": 4, "SRS subband size": 56, "cSRS": 52,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 1, "SRS subband size": 240, "cSRS": 53,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 2, "SRS subband size": 120, "cSRS": 53,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 3, "SRS subband size": 80, "cSRS": 54,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 4, "SRS subband size": 60, "cSRS": 53,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 5, "SRS subband size": 48, "cSRS": 55,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 10, "SRS subband size": 24, "cSRS": 56,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 12, "SRS subband size": 20, "cSRS": 54,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 240, "Number of SRS subband per symbol": 15, "SRS subband size": 16, "cSRS": 55,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 1, "SRS subband size": 256, "cSRS": 57,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 2, "SRS subband size": 128, "cSRS": 57,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 4, "SRS subband size": 64, "cSRS": 57,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 8, "SRS subband size": 32, "cSRS": 58,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 256, "Number of SRS subband per symbol": 16, "SRS subband size": 16, "cSRS": 59,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 264, "Number of SRS subband per symbol": 1, "SRS subband size": 264, "cSRS": 60,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 264, "Number of SRS subband per symbol": 2, "SRS subband size": 132, "cSRS": 60,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 264, "Number of SRS subband per symbol": 6, "SRS subband size": 44, "cSRS": 60,
     "bSRS": 2},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 1, "SRS subband size": 272, "cSRS": 61,
     "bSRS": 0},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 2, "SRS subband size": 136, "cSRS": 61,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 4, "SRS subband size": 68, "cSRS": 62,
     "bSRS": 1},
    {"SRS bandwidth for SB BF": 272, "Number of SRS subband per symbol": 17, "SRS subband size": 16, "cSRS": 63,
     "bSRS": 1},
]

table3 = [
    {"CellBW": "20MHz", "MaxCellPRB": 51},
    {"CellBW": "30MHz", "MaxCellPRB": 78},
    {"CellBW": "40MHz", "MaxCellPRB": 106},
    {"CellBW": "50MHz", "MaxCellPRB": 133},
    {"CellBW": "60MHz", "MaxCellPRB": 162},
    {"CellBW": "70 MHz", "MaxCellPRB": 189},
    {"CellBW": "70MHz", "MaxCellPRB": 189},
    {"CellBW": "70MHz", "MaxCellPRB": 189},
    {"CellBW": "80MHz", "MaxCellPRB": 217},
    {"CellBW": "90MHz", "MaxCellPRB": 245},
    {"CellBW": "100MHz", "MaxCellPRB": 273},
]


def format_spark_xml_log(file_path):
    file = open(file=file_path, mode="r")
    lines = file.readlines()
    file.close()
    if len(lines) == 1:
        content = lines[0]
        pattern = r'.*(<OneMessage Name="SIP.*</OneMessage>).*'
        while "SIP" in content:
            result = re.findall(pattern=pattern, string=content)
            if len(result) == 0:
                break
            else:
                content = content.replace(result[0], "")
        file = open(file=file_path, mode="w")
        file.write(content)
        file.close()
    else:
        for i in range(len(lines)):
            if "<OneMessage Name=\"SIP " in lines[i]:
                for m in range(i, len(lines)):
                    if "</OneMessage>" in lines[m]:
                        break
                for k in range(i, m + 1):
                    lines[k] = ""
        file = open(file=file_path, mode="w")
        file.writelines(lines)
        file.close()
    file = open(file=file_path, mode="r")
    lines = file.readlines()
    file.close()
    for i in range(len(lines)):
        pattern = r'(.*)\s*: (.*)'
        result = re.match(pattern=pattern, string=lines[i])
        if result is not None:
            if "OneMessage" in result.group(0):
                new = lines[i].split(">")[-1]
                lines[i] = lines[i].replace(new, "")
            else:
                lines[i] = ""
    for i in range(len(lines)):
        lines[i] = lines[i].strip("\r\n")
    file = open(file=file_path, mode="w")
    file.writelines(lines)
    file.close()


def get_cSRS_bSRS_from_pointed_table(chBw, numOfSrsSubbandInput):
    cSRS = 0
    bSRS = 0
    if chBw == '100MHz' and int(numOfSrsSubbandInput) == 1:
        cSRS = 61
        bSRS = 0
    elif chBw == '100MHz' and int(numOfSrsSubbandInput) == 2:
        cSRS = 61
        bSRS = 1
    elif chBw == '100MHz' and int(numOfSrsSubbandInput) == 4:
        cSRS = 62
        bSRS = 0
    elif chBw == '100MHz' and int(numOfSrsSubbandInput) == 17:
        cSRS = 63
        bSRS = 1
    return cSRS, bSRS


def add_or_modify_flag_in_swconfig(flag_0x5901BD, swconfig_path):
    file = open(swconfig_path, "r")
    lines = file.readlines()
    flag_0x5901BD_exist = False
    for i in range(len(lines)):
        if not lines[i].startswith("#"):
            if lines[i].startswith("0x5901BD"):
                lines[i] = "0x5901BD=" + str(flag_0x5901BD) + "\n"
                flag_0x5901BD_exist = True
    file = open(swconfig_path, "w")
    file.writelines(lines)
    file.close()
    file = open(swconfig_path, "a")
    if not flag_0x5901BD_exist:
        file.write("0x5901BD=" + str(flag_0x5901BD) + "\n")
    file.close()


def get_cell_id_by_ue_index(ue_index, tput):
    for key in tput.keys():
        if tput[key]['ue_index'] == ue_index:
            break
    return key


def get_cell_ue_mapping(tput_define):
    cells = tput_define.keys()
    random_cells = random.sample(cells, 2)
    cell_1 = random_cells[0]
    cell_2 = random_cells[1]
    detail = tput_define[cell_1]
    ue_indexes = detail['ue_index']
    indexes = random.sample(ue_indexes, 2)
    cell_ue_mapping = dict()
    cell_ue_mapping[cell_1] = indexes
    for ue_index in indexes:
        if ue_index in ue_indexes:
            ue_indexes.remove(ue_index)
    cell_ue_mapping[cell_2] = ue_indexes
    return cell_ue_mapping


def get_cell_ue_mapping_for_1cc_2ues(tput_define):
    cells = tput_define.keys()
    random_cells = random.sample(cells, 2)
    cell = random_cells[0]
    detail = tput_define[cell]
    ue_indexes = detail['ue_index']
    indexes = random.sample(ue_indexes, 2)
    cell_ue_mapping = dict()
    cell_ue_mapping[cell] = indexes
    return cell_ue_mapping


def get_maxcellprb_by_chbw_from_table3(chBw):
    for item in table3:
        if chBw == item['CellBW']:
            return int(item['MaxCellPRB'])


def get_rest_prb_num_by_maxcellprb_and_bfSubbandSize(maxcellprb, bfSubbandSize):
    maxcellprb = int(maxcellprb)
    bfSubbandSize = int(bfSubbandSize)
    rest_prb_num = maxcellprb % bfSubbandSize
    return rest_prb_num


def get_unavailable_prb_low(nbrOfBlankedPRBsLowEdgeUL, bfSubbandSize):
    nbrOfBlankedPRBsLowEdgeUL = int(nbrOfBlankedPRBsLowEdgeUL)
    bfSubbandSize = int(bfSubbandSize)
    unavailable_prb_low = math.ceil(nbrOfBlankedPRBsLowEdgeUL / bfSubbandSize) * bfSubbandSize
    return unavailable_prb_low


def get_unavailable_prb_high(nbrOfBlankedPRBsHighEdgeUL, rest_prb_num, bfSubbandSize):
    nbrOfBlankedPRBsHighEdgeUL = int(nbrOfBlankedPRBsHighEdgeUL)
    rest_prb_num = int(rest_prb_num)
    bfSubbandSize = int(bfSubbandSize)
    if nbrOfBlankedPRBsHighEdgeUL < rest_prb_num:
        unavailable_prb_high = nbrOfBlankedPRBsHighEdgeUL
    else:
        unavailable_prb_high = math.ceil(
            (nbrOfBlankedPRBsHighEdgeUL - rest_prb_num) / bfSubbandSize) * bfSubbandSize + rest_prb_num
    return unavailable_prb_high


def get_available_prb_num(maxcellprb, unavailable_prb_up, unavailable_prb_down):
    available_prb_num = maxcellprb - unavailable_prb_up - unavailable_prb_down
    return available_prb_num


def get_available_prb_num_during_counter_check(chBw, bfSubbandSize, nbrOfBlankedPRBsLowEdgeUL,
                                               nbrOfBlankedPRBsHighEdgeUL):
    bfSubbandSize = bfSubbandSize.replace("PRBs", "").strip()
    unavailable_prb_low = get_unavailable_prb_low(nbrOfBlankedPRBsLowEdgeUL=nbrOfBlankedPRBsLowEdgeUL,
                                                  bfSubbandSize=bfSubbandSize)
    maxcellprb = get_maxcellprb_by_chbw_from_table3(chBw=chBw)
    rest_prb_num = get_rest_prb_num_by_maxcellprb_and_bfSubbandSize(maxcellprb=maxcellprb, bfSubbandSize=bfSubbandSize)
    unavailable_prb_high = get_unavailable_prb_high(nbrOfBlankedPRBsHighEdgeUL=nbrOfBlankedPRBsHighEdgeUL,
                                                    rest_prb_num=rest_prb_num, bfSubbandSize=bfSubbandSize)
    available_prb_num = get_available_prb_num(maxcellprb=maxcellprb, unavailable_prb_up=unavailable_prb_low,
                                              unavailable_prb_down=unavailable_prb_high)
    return available_prb_num


def get_cSRS_bSRS_and_numOfSrsSubbandOutput_during_call(chBw, bfSubbandSize,
                                                        nbrOfBlankedPRBsLowEdgeUL, nbrOfBlankedPRBsHighEdgeUL,
                                                        numOfSrsSubbandInput):
    numOfSrsSubbandInput = int(numOfSrsSubbandInput)
    list = []
    bfSubbandSize = bfSubbandSize.replace("PRBs", "").strip()
    maxcellprb = get_maxcellprb_by_chbw_from_table3(chBw=chBw)
    print("maxcellprb is: " + str(maxcellprb))
    unavailable_prb_low = get_unavailable_prb_low(nbrOfBlankedPRBsLowEdgeUL=nbrOfBlankedPRBsLowEdgeUL,
                                                  bfSubbandSize=bfSubbandSize)
    print("unavailable_prb_low is: " + str(unavailable_prb_low))
    rest_prb_num = get_rest_prb_num_by_maxcellprb_and_bfSubbandSize(maxcellprb=maxcellprb, bfSubbandSize=bfSubbandSize)
    print("rest_prb_num is: " + str(rest_prb_num))
    unavailable_prb_high = get_unavailable_prb_high(nbrOfBlankedPRBsHighEdgeUL=nbrOfBlankedPRBsHighEdgeUL,
                                                    rest_prb_num=rest_prb_num, bfSubbandSize=bfSubbandSize)
    print("unavailable_prb_high is: " + str(unavailable_prb_high))
    available_prb_num = get_available_prb_num(maxcellprb=maxcellprb, unavailable_prb_up=unavailable_prb_low,
                                              unavailable_prb_down=unavailable_prb_high)
    print("available_prb_num is: " + str(available_prb_num))
    for item in table2:
        if int(item['SRS bandwidth for SB BF']) <= available_prb_num and \
                int(item['Number of SRS subband per symbol']) <= numOfSrsSubbandInput:
            list.append(item)
    list_tmp = []
    max = list[0]['SRS bandwidth for SB BF']
    for item in list:
        if int(item['SRS bandwidth for SB BF']) > max:
            max = item['SRS bandwidth for SB BF']
    for item in list:
        if int(item['SRS bandwidth for SB BF']) == max:
            list_tmp.append(item)
    print(list_tmp)
    if list_tmp:
        result = math_numOfSrsSubbandOutput_cSRS_and_bSRS(numOfSrsSubbandInput=numOfSrsSubbandInput, list=list_tmp)
        return result['Number of SRS subband per symbol'], result['cSRS'], result['bSRS']
    else:
        return []


def math_numOfSrsSubbandOutput_cSRS_and_bSRS(numOfSrsSubbandInput, list):
    for item in list:
        if int(item['Number of SRS subband per symbol']) % numOfSrsSubbandInput == 0:
            return item
    else:
        numOfSrsSubbandInput = get_next_number_of_srs_subband_per_symbol(current=numOfSrsSubbandInput)
        return math_numOfSrsSubbandOutput_cSRS_and_bSRS(numOfSrsSubbandInput=numOfSrsSubbandInput, list=list)


def get_next_number_of_srs_subband_per_symbol(current):
    if current == 4:
        return 2
    elif current == 2:
        return 1
    else:
        return 1


def get_cSRS_by_ue_index(info_list, ue_index):
    for item in info_list:
        if item['ue_index'] == ue_index:
            return item['cSRS_attach']


def get_bSRS_by_ue_index(info_list, ue_index):
    for item in info_list:
        if item['ue_index'] == ue_index:
            return item['bSRS_attach']


def get_cSRS_and_bSRS_by_rule(bfSubbandSize, is_1070, csrs, bsrs, comb):
    if bfSubbandSize != '4 PRBs' or is_1070 is False:
        return csrs, bsrs
    else:
        SRS_bandwidth_for_SB_BF = get_srs_bandwidth_for_sb_bf_from_table1(csrs=csrs, bsrs=bsrs)
        SRS_subband_size = get_srs_subband_size_from_table1(csrs=csrs, bsrs=bsrs)
        if SRS_bandwidth_for_SB_BF > 136 and SRS_subband_size > 16:
            csrs_bsrs = get_csrs_bsrs_from_table_by_csrs(csrs=csrs)
            if csrs_bsrs:
                return csrs_bsrs
            else:
                csrs_less = csrs - 1
                csrs_bsrs = get_csrs_bsrs_from_table_by_csrs(csrs=csrs_less)
                if csrs_bsrs:
                    return csrs_bsrs
                else:
                    return get_csrs_bsrs_from_table_by_csrs_and_comb(csrs=csrs_less, comb=comb)


def get_srs_bandwidth_for_sb_bf_from_table1(csrs, bsrs):
    for item in table1:
        if item['cSRS'] == csrs and item['bSRS'] == bsrs:
            return item['SRS bandwidth for SB BF']


def get_srs_subband_size_from_table1(csrs, bsrs):
    for item in table1:
        if item['cSRS'] == csrs and item['bSRS'] == bsrs:
            return item['SRS subband size']


def get_csrs_bsrs_from_table_by_csrs(csrs):
    csrs_bsrs = None
    for item in table1:
        if item['cSRS'] == csrs and item['SRS subband size'] == 16:
            return item['cSRS'], item['bSRS']
    return csrs_bsrs


def get_csrs_bsrs_from_table_by_csrs_and_comb(csrs, comb):
    result = []
    if comb == 'comb2':
        for item in table1:
            if item['cSRS'] == csrs and 4 <= item['SRS subband size'] < 16:
                result.append(item)
        if len(result) == 2:
            for item in result:
                if item['SRS subband size'] == 4:
                    result.remove(item)
    elif comb == 'comb4':
        for item in table1:
            if item['cSRS'] == csrs and 8 <= item['SRS subband size'] < 16:
                result.append(item)
    return result[0]['cSRS'], result[0]['bSRS']


def get_counter_value(counter_info, counter_id):
    counter_info = counter_info[counter_id]
    max_key = max(counter_info.keys())
    return counter_info[max_key]


def add_or_modify_flag_in_swconfig_for_snapshot_trigger(flag_0x5806D9, flag_0x5806D8, swconfig_path):
    file = open(swconfig_path, "r")
    lines = file.readlines()
    file.close()
    flag_0x5806D9_exist = False
    flag_0x5806D8_exist = False
    for i in range(len(lines)):
        if not lines[i].startswith("#"):
            if lines[i].startswith("0x5806D9"):
                lines[i] = "0x5806D9=" + str(flag_0x5806D9) + "\n"
                flag_0x5806D9_exist = True
            if lines[i].startswith("0x5806D8"):
                lines[i] = "0x5806D8=" + str(flag_0x5806D8) + "\n"
                flag_0x5806D8_exist = True
    file = open(swconfig_path, "w")
    file.writelines(lines)
    if not flag_0x5806D9_exist:
        file.write("0x5806D9=" + str(flag_0x5806D9) + "\n")
    if not flag_0x5806D8_exist:
        file.write("0x5806D8=" + str(flag_0x5806D8) + "\n")
    file.close()


def remove_flag_in_swconfig(swconfig_path):
    file = open(swconfig_path, "r")
    lines = file.readlines()
    for i in range(len(lines)):
        if lines[i].startswith("0x5806D9") or lines[i].startswith("0x5806D8"):
            lines[i] = ""
    file = open(swconfig_path, "w")
    file.writelines(lines)
    file.close()


def get_start_time_after_a_period_time(addminute, addhour=0):
    addminute = int(addminute)
    now = datetime.datetime.now()
    week_day = now.strftime("%a")
    hour = now.hour
    minute = now.minute
    hour = hour + addhour
    minute = minute + addminute
    if minute >= 60:
        hour = hour + 1
        minute = minute - 60
    if hour >= 24:
        hour = hour - 24
        tomorrow = now + datetime.timedelta(days=1)
        week_day = datetime.datetime.date(tomorrow).strftime("%a")
    hour = str(hour)
    minute = str(minute)
    return week_day, hour, minute


def get_counter_value_dict(counter_info, counter_id):
    counter_info = counter_info[counter_id]
    max_key = max(counter_info.keys())
    value = counter_info[max_key]
    dict_counter = {}
    if value != 0:
        dict = {}
        dict['count'] = value
        dict_counter[counter_id] = dict
    return dict_counter


def get_count_with_not_zero_value(counter_info, counter_prefix, counter_start, counter_end):
    result = []
    for id in range(counter_start, counter_end):
        counter_id = counter_prefix + str(id)
        counter = get_counter_value_dict(counter_info=counter_info, counter_id=counter_id)
        if counter:
            result.append(counter)
    sum = 0
    for item in result:
        key = list(item.keys())[0]
        value = item[key]['count']
        sum = sum + value
    result_lt_2_percent = []
    for item in result:
        key = list(item.keys())[0]
        value = item[key]
        count = value['count']
        percent = count / sum
        if percent >= 0.02:
            result_lt_2_percent.append(item)
    return result_lt_2_percent


def get_percent_by_counter_id(details, counter_id):
    for item in details:
        key = list(item.keys())[0]
        if key == counter_id:
            percent = item[key]['percent']
            return percent


def check_counter_percentage(counter_basic, counter_log):
    flag_error = 0
    counter_start = counter_basic['start']
    counter_end = counter_basic['end']
    keys_log = []
    for item in counter_log:
        keys_log.append(list(item.keys())[0])
    for key in keys_log:
        key_ends = int(key[-3:])
        if key_ends > counter_end or key_ends < counter_start:
            print("counter "+key+" is not expected!!!")
            flag_error = 1
            break
    return flag_error


def get_cell_belonged_ru(cells_info, cell_id):
    for cell in cells_info:
        cell_index = cell['globalCellId']
        if cell_id == cell_index:
            break
    carrierList = cell['carrierList']
    rmod_id = carrierList[0]['antennaLineId']['configuration'].split('RMOD-')[1].split('/')[0]
    return rmod_id


def generate_counter_list_by_start_counter(start_counter, num):
    start_id = int(start_counter[-3:])
    start_prefix = start_counter[:-3]
    counter_id_list = []
    counter_id_list.append(start_counter)
    for i in range(1, num):
        counter_id = start_prefix+str(start_id+i)
        counter_id_list.append(counter_id)
    return counter_id_list


def format_str_to_int_list(str):
    str_list = str.split(",")
    int_list = []
    for item in str_list:
        tmp = int(item.strip(""))
        int_list.append(tmp)
    return int_list


def get_syslog_name(syslog_name_info):
    syslog_name_list = syslog_name_info.split("\n")
    min = 1000000
    for item in syslog_name_list:
        if item:
            index = int(item.split(".LOG")[0].split("SYSLOG_")[1])
            if index < min:
                min = index
    return "SYSLOG_"+str(min)+".LOG"


def get_maxTxPowerPerCCmW_from_bts_log(loginfo):
    result = re.match(r'.*maxTxPowerPerCCmW:(.*), timeAveragingWindowStepSize.*', loginfo)
    return float(result.group(1))


def get_maxBeamGain_from_bts_log(loginfo):
    result = re.match(r'.*,"maxBeamGain":(.*),"maxBe.*', loginfo)
    return float(result.group(1))


def get_dutyCyclefrom_bts_log(loginfo):
    result = re.match(r'.* dutyCycle:(.*) numOfDlSymbols:.*', loginfo)
    return float(result.group(1))


def check_counter_list(counter_list):
    flag = False
    for item in counter_list:
        if int(item) != 0:
            flag = True
            break
    return flag


def get_tput_for_2cc_together(tput1, tput2):
    if str(tput1).endswith("MKbits/sec"):
        tput_1 = int(tput1.split("MKbits/sec")[0])
    else:
        tput_1 = int(tput1)
    if str(tput2).endswith("MKbits/sec"):
        tput_2 = int(tput2.split("MKbits/sec")[0])
    else:
        tput_2 = int(tput2)
    tput_all = tput_1 + tput_2
    if str(tput1).endswith("MKbits/sec"):
        return str(tput_all)+"MKbits/sec"
    else:
        return tput_all
