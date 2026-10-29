# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

supercell_for_1super3sub = {'NRCELL-11': ['Subcell-0 (DL)', 'Subcell-0 (UL)',
                                          'Subcell-1 (DL)', 'Subcell-1 (UL)',
                                          'Subcell-2 (DL)', 'Subcell-2 (UL)']}

supercell_for_1super6sub = {'NRCELL-11': ['Subcell-0 (DL)', 'Subcell-0 (UL)',
                                          'Subcell-1 (DL)', 'Subcell-1 (UL)',
                                          'Subcell-2 (DL)', 'Subcell-2 (UL)',
                                          'Subcell-3 (DL)', 'Subcell-3 (UL)',
                                          'Subcell-4 (DL)', 'Subcell-4 (UL)',
                                          'Subcell-5 (DL)', 'Subcell-5 (UL)']}

supercell_for_2super6sub = {'NRCELL-11': ['Subcell-0 (DL)', 'Subcell-0 (UL)',
                                          'Subcell-1 (DL)', 'Subcell-1 (UL)',
                                          'Subcell-2 (DL)', 'Subcell-2 (UL)'],
                            'NRCELL-12': ['Subcell-3 (DL)', 'Subcell-3 (UL)',
                                          'Subcell-4 (DL)', 'Subcell-4 (UL)',
                                          'Subcell-5 (DL)', 'Subcell-5 (UL)']}

supercell_for_3super6sub = {'NRCELL-1': ['Subcell-0 (DL)', 'Subcell-0 (UL)',
                                         'Subcell-1 (DL)', 'Subcell-1 (UL)'],
                            'NRCELL-2': ['Subcell-2 (DL)', 'Subcell-2 (UL)',
                                         'Subcell-3 (DL)', 'Subcell-3 (UL)'],
                            'NRCELL-3': ['Subcell-4 (DL)', 'Subcell-4 (UL)',
                                         'Subcell-5 (DL)', 'Subcell-5 (UL)',
                                         'Subcell-6 (DL)', 'Subcell-6 (UL)'],
                            'NRCELL-11': ['Subcell-7 (DL)', 'Subcell-7 (UL)',
                                          'Subcell-8 (DL)', 'Subcell-8 (UL)'],
                            'NRCELL-12': ['Subcell-9 (DL)', 'Subcell-9 (UL)',
                                          'Subcell-10 (DL)', 'Subcell-10 (UL)'],
                            'NRCELL-13': ['Subcell-11 (DL)', 'Subcell-11 (UL)',
                                          'Subcell-12 (DL)', 'Subcell-12 (UL)']}

supercell_for_2super24sub = {'NRCELL-11': ['Subcell-0 (DL)', 'Subcell-0 (UL)',
                                           'Subcell-1 (DL)', 'Subcell-1 (UL)'],
                             'NRCELL-12': ['Subcell-2 (DL)', 'Subcell-2 (UL)',
                                           'Subcell-3 (DL)', 'Subcell-3 (UL)',
                                           'Subcell-4 (DL)', 'Subcell-4 (UL)',
                                           'Subcell-5 (DL)', 'Subcell-5 (UL)']}

supercell_for_6nom = {'NRCELL-14': ['Subcell-3 (DL)', 'Subcell-3 (UL)'],
                      'NRCELL-16': ['Subcell-5 (DL)', 'Subcell-5 (UL)'],
                      'NRCELL-11': ['Subcell-0 (DL)', 'Subcell-0 (UL)'],
                      'NRCELL-15': ['Subcell-4 (DL)', 'Subcell-4 (UL)'],
                      'NRCELL-12': ['Subcell-1 (DL)', 'Subcell-1 (UL)'],
                      'NRCELL-13': ['Subcell-2 (DL)', 'Subcell-2 (UL)']}

supercell_for_3nom3sub = {'NRCELL-15': ['Subcell-4 (DL)', 'Subcell-4 (UL)'],
                          'NRCELL-11': ['Subcell-0 (DL)', 'Subcell-0 (UL)',
                                        'Subcell-1 (DL)', 'Subcell-1 (UL)',
                                        'Subcell-2 (DL)', 'Subcell-2 (UL)'],
                          'NRCELL-17': ['Subcell-6 (DL)', 'Subcell-6 (UL)'],
                          'NRCELL-16': ['Subcell-5 (DL)', 'Subcell-5 (UL)'],
                          'NRCELL-18': ['Subcell-7 (DL)', 'Subcell-7 (UL)'],
                          'NRCELL-14': ['Subcell-3 (DL)', 'Subcell-3 (UL)'],
                          'NRCELL-19': ['Subcell-8 (DL)', 'Subcell-8 (UL)']}
