# -*- coding: utf-8 -*-
"""
Software version wrapping classes.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""


import logging
import urllib


class SwVersion:
    """ Represents BTS software version """

    __MISSING_IMPLEMENTATION_ERROR_MSG = '{} class has no implementation ' \
                                         'of {} attribute'
    __bts_type = None

    def __init__(self, raw):
        self._raw = raw
        self._nominal = None
        self._simplified = None
        self._package = None
        self._url = None
        self._size = None

    def __repr__(self):
        return "{}('{}')".format(self.__class__.__name__, self.raw)

    @classmethod
    def from_nominal(cls, nominal):
        """
        Alternative constructor allowing SwVersion class instance based
        on nominal
        software version definition
        """
        raise NotImplementedError(
            cls.__MISSING_IMPLEMENTATION_ERROR_MSG.format(cls.__name__,
                                                          'package'))

    @property
    def raw(self):
        """
        Returns SW version in raw format, i.e. '5G21A_GNB_0011_000800_000315'

        :rtype: str
        """
        return self._raw

    @property
    def nominal(self):
        """
        Returns SW version in nominal format, i.e. '5G21A_11.800.315'

        :rtype: str
        """
        if self._nominal is None:
            parts = [part.lstrip('0') for part in self._raw.split('_')]
            parts[-3] = '0' if parts[-3] == '' else parts[-3]
            self._nominal = parts[0] + '_' + '.'.join(parts[-3:])
        return self._nominal

    @property
    def simplified(self):
        """
        Returns SW version in simplified format, i.e. '11.800.315'

        :rtype: str
        """
        if self._simplified is None:
            self._simplified = self.nominal.split('_')[1]
        return self._simplified

    def get_package(self):
        """
        Returns SW version in package name format, i.e. '
        AirScale-11.800.315.zip'

        :rtype: str
        """
        raise NotImplementedError(
            self.__MISSING_IMPLEMENTATION_ERROR_MSG.
            format(self.__class__.__name__, 'package'))

    @property
    def url(self):
        """
        Returns SW version in URL format, i.e.
        'https://artifactory-espoo1.int.net.nokia.com/artifactory/
        System_Release/11.800.315/AirScale-11.800.315.zip'

        :rtype: str
        """
        raise NotImplementedError(
            self.__MISSING_IMPLEMENTATION_ERROR_MSG.
            format(self.__class__.__name__, 'url'))

    @property
    def with_t1_suffix(self):
        """
        Returns SwVersion instance with same raw number but with added T1
        suffix (if not present already).

        :rtype: SwVersion
        """
        if self.has_t1_suffix:
            return self
        elif self.has_t2_suffix:
            return self.__class__(raw=self.raw.replace('T2', 'T1'))
        else:
            return self.__class__(raw='{}T1'.format(self.raw))

    @property
    def with_t2_suffix(self):
        """
        Returns SwVersion instance with same raw number but with added T2
        suffix (if not present already).

        :rtype: SwVersion
        """
        if self.has_t2_suffix:
            return self
        elif self.has_t1_suffix:
            return self.__class__(raw=self.raw.replace('T1', 'T2'))
        else:
            return self.__class__(raw='{}T2'.format(self.raw))

    @property
    def without_t_suffix(self):
        """
        Returns SwVersion instance with same raw number but without
        T1 nor T2 suffix (if present).

        :rtype: SwVersion
        """
        return self.__class__(raw=self.raw[:-2]) \
            if self.has_t1_suffix or self.has_t2_suffix else self

    @property
    def has_t1_suffix(self):
        """
        Returns True if SW version has T1 suffix, False otherwise.

        :rtype: bool
        """
        return self.raw.endswith('T1')

    @property
    def has_t2_suffix(self):
        """
        Returns True if SW version has T2 suffix, False otherwise.

        :rtype: bool
        """
        return self.raw.endswith('T2')

    @property
    def size(self):
        """
        Returns size of SW version (in bytes) read from remote repository.

        :rtype: int
        """
        if self._size is None:
            self._size = int(urllib.urlopen(self.url).info().
                             getheader('content-length'))
        return self._size


class GnbSwVersion(SwVersion):
    """ Represents 5G BTS software version """

    __bts_type = 'GNB'

    def get_package(self):
        """
        Returns SW version in package name format, i.e'AirScale-11.800.315.zip'

        :rtype: str
        """
        if self._package is None:
            self._package = 'AirScale-{}.zip'.format(self.simplified)
        return self._package

    @property
    def url(self):
        """
        Returns SW version in URL format, i.e.
        'https://artifactory-espoo1.int.net.nokia.com/artifactory/
        System_Release/11.800.315/AirScale-11.800.315.zip'

        :rtype: str
        """
        if self._url is None:
            self._url = 'https://artifactory-espoo1.int.net.nokia.com/' \
                        'artifactory' \
                        '/mnp5g-central-public-local/' \
                        'System_Release/{}/{}'.\
                         format(self.without_t_suffix.simplified,
                                self.get_package())
        return self._url

    @classmethod
    def from_nominal(cls, nominal):
        """
        Alternative constructor allowing creation GnbSwVersion class instance
         based on nominal software
        version definition
        """
        branch, streamline, version = nominal.split('.')
        raw = '_'.join([branch.split('_')[0],
                        cls.__bts_type,
                        branch.split('_')[1].zfill(4),
                        streamline.zfill(6),
                        version.zfill(6)])
        return cls(raw)


class SbtsSwVersion(SwVersion):
    """ Represents SBTS software version. Variable __sbts_branches needs to be
    update with each SBTS release"""

    __bts_type = 'ENB'
    __sbts_branches = ['SBTS21B']
    __sbts_trunk = 'SBTS00'

    @property
    def release(self):
        """
        Returns release of given software, in case of trunk it will be SBTS00

        :rtype: str
        """
        release = self._nominal.split('.')[0]
        if release in self.__sbts_branches:
            return release
        return self.__sbts_trunk

    @property
    def simplified(self):
        """
        Returns SW version in simplified format, i.e. '11.800.315'

        :rtype: str
        """
        if self._simplified is None:
            self._simplified = '.'.join(self.nominal.split('.')[1:])
        return self._simplified

    def get_package(self, package_variant='A54'):
        """
        Returns SW version in package name format, i.e.
        'SBTS00_ENB_9999_210318_000011_release_BTSSM_downloadable_A54.zip'

        :rtype: str
        """
        if self._package is None:
            head, mid, tail = self.simplified.split('.')
            test = ''

            if self.raw.endswith('T1'):
                tail = tail.replace('T1', '')
                test = '_testpackage_T1'
            elif self.raw.endswith('T2'):
                tail = tail.replace('T2', '')
                test = '_testpackage_T2'

            tail = tail.zfill(6)

            if package_variant:
                package_variant = '_{}'.format(package_variant)
            else:
                package_variant = ''
            self._package = '{}_ENB_{}_{}_{}_release_' \
                            'BTSSM_downloadable{}{}.zip'.\
                format(self.release, head, mid, tail, test, package_variant)
        return self._package

    @property
    def url(self):
        """
        Returns SW version in URL format, i.e.
        In case of trunk release:
        'https://lterel.es-si-s3-z4.eecloud.nsn-net/SBTS0/
        SBTS00_ENB_9999_210318_000011_release_BTSSM_downloadable.zip'

        :rtype: str
        """

        if self._url is None:
            self._url = 'https://lterel.es-si-s3-z4.eecloud.nsn-net.' \
                        'net/build/{}/{}'.format(
                         self.release, self.get_package(package_variant='A54'))
        return self._url

    @property
    def nominal(self):
        """
        Returns SW version in nominal format, i.e. '5G21A_11.800.315'

        :rtype: str
        """
        if self._nominal is None:
            release, hw, num1, num2, num3 = self._raw.split('_')
            self._nominal = '.'.join([release, num1, num2, num3])
        return self._nominal

    @property
    def raw_with_release(self):
        """
        Returns raw version of sw string with SBTS00 on trunk and proper
        prefix for branches

        :rtype: str
        """
        return '{}_{}'.format(self.release, '_'.join(self.raw.split('_')[1:]))


class SwVersionFactory:
    """ Creates SwVersion instances. """

    @classmethod
    def create_sw_version(cls, raw_sw_version):
        """
        Creates SwVersion with given raw number.

        :param raw_sw_version: raw SW version number, i.e.
        '5G21A_GNB_0011_000800_000315'
        :type raw_sw_version: str
        :return: SwVersion instance
        :rtype: SwVersion
        """
        if not RawSwValidator.any(raw_sw_version):
            raise ValueError("Given software version does not match any of "
                             "supported builds")

        if RawSwValidator.gnb(raw_sw_version):
            logging.info('Creating GnbSwVersion {}'.format(raw_sw_version))
            return GnbSwVersion(raw=raw_sw_version)
        elif RawSwValidator.sbts(raw_sw_version):
            logging.info('Creating SbtsSwVersion {}'.format(raw_sw_version))
            return SbtsSwVersion(raw=raw_sw_version)

    @classmethod
    def create_sw_version_from_nominal(cls, nominal_sw_version):
        """
        Creates SwVersion with given nominal string
        NOTE: in case of SBTS releases nominal is same as raw
        :param nominal_sw_version: raw SW version number, i.e.
        '5G21A_GNB_0011_000800_000315'
        :type nominal_sw_version: str
        :return: SwVersion instance
        :rtype: SwVersion
        """
        if not RawSwValidator.any(nominal_sw_version):
            raise ValueError("Given software version does not match "
                             "any of supported builds")

        if RawSwValidator.gnb(nominal_sw_version):
            logging.info('Creating GnbSwVersion {}'.
                         format(nominal_sw_version))
            return GnbSwVersion.from_nominal(nominal=nominal_sw_version)
        elif RawSwValidator.sbts(nominal_sw_version):
            logging.info('Creating SbtsSwVersion {}'.
                         format(nominal_sw_version))
            return SbtsSwVersion(raw=nominal_sw_version)


class RawSwValidator:
    """ Validates raw software version strings """

    @classmethod
    def sbts(cls, raw_sw_version):
        """
        Validate if given raw sw string is in correct format for SBTS
        :param raw_sw_version: eg: SBTS00_ENB_9999_210318_000011
        :return: bool
        """
        return raw_sw_version.startswith('SBTS')

    @classmethod
    def gnb(cls, raw_sw_version):
        """
        Validate if given raw sw string is in correct format for 5G
        :param raw_sw_version: eg: 5G21A_GNB_0011_000800_000315
        :return: bool
        """
        return raw_sw_version.startswith('5G')

    @classmethod
    def any(cls, raw_sw_version):
        """
        Check if given raw sw string matches any of the supported
        software formats
        :param raw_sw_version:
        :return: bool
        """
        validators = (cls.sbts, cls.gnb)
        return any([validator(raw_sw_version) for validator in validators])
