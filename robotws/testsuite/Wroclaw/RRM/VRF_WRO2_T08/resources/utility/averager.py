"""
dict subclass useful for calculating common statistics such as average, sum and min/max values on the fly, as the
records are added to Averager

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

from collections import defaultdict


class Averager(defaultdict):
    def __init__(self):
        super(Averager, self).__init__(ParamStats)

    def update(self, params=None, **kwargs):
        if params is None:
            params = {}
        params.update(kwargs)
        for param, value in params.items():
            super(Averager, self).__getitem__(param).add_value(value)

    def __getitem__(self, item):
        value = super(Averager, self).__getitem__(item)
        return value['avg']

    def min(self, param):
        value = super(Averager, self).__getitem__(param)
        return value['min']

    def max(self, param):
        value = super(Averager, self).__getitem__(param)
        return value['max']

    def sum(self, param):
        value = super(Averager, self).__getitem__(param)
        return value['sum']

    def count(self, param):
        value = super(Averager, self).__getitem__(param)
        return value['count']

    def avg(self, param):
        return self[param]

    def var(self, param):
        value = super(Averager, self).__getitem__(param)
        return value['var']


class ParamStats(dict):
    _keys_supported = ['count', 'sum', 'min', 'max', 'avg', 'var']

    def __init__(self, *args, **kwargs):
        super(ParamStats, self).__init__(*args, **kwargs)
        self['count'] = 0
        self['sum'] = 0
        self['min'] = float('inf')
        self['max'] = float('-inf')
        self['avg'] = float('nan')
        self['var'] = float('nan')

    def __setitem__(self, key, value):
        if key not in ParamStats._keys_supported:
            raise KeyError("key '{}' not supported".format(key))
        super(ParamStats, self).__setitem__(key, value)

    def add_value(self, value):
        if value is None:
            return
        current_sum_of_squares = 0 if self['count'] == 0 else (self['count'] * (self['var'] + self['avg']**2))
        self['count'] += 1
        self['sum'] += value
        self['avg'] = self['sum'] / float(self['count'])
        self['var'] = ((current_sum_of_squares + (value**2)) / self['count']) - (self['avg']**2)
        self['min'] = value if value < self['min'] else self['min']
        self['max'] = value if value > self['max'] else self['max']
