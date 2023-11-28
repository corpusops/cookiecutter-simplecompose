#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, print_function
import re
from pkg_resources import parse_version as V
from cookiecutter.utils import simple_filter


@simple_filter
def version_compare(x, y, op):
    assert op in ['>', '>=', '==', '<', '<=']
    test = f'V("{x}") {op} V("{y}")'
    return eval(test)


@simple_filter
def regex_replace(value, regex, replacement):
        return re.sub(regex, replacement, value)
