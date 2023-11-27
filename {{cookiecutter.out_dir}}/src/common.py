#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, print_function

import re
import logging
import os
import enum

L = logging.getLogger('{{cookiecutter.lname}}')


def setup_logging():
    logging.basicConfig(
        level=getattr(
            logging, os.environ.get('LOGLEVEL', 'info').upper()))


def as_bool(value):
    if isinstance(value, str):
        return bool(re.match('^(y|o|1|t)', value.lower()))
    else:
        return bool(value)

# vim:set et sts=4 ts=4 tw=120:
