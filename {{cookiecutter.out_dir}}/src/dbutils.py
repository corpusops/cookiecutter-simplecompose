#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, print_function

import os
import common

from sqlalchemy import (
    create_engine,
    MetaData,
    Table, Column,
    Integer, String, FLOAT, DateTime, Numeric, DECIMAL,
)
from sqlalchemy.ext.declarative import declarative_base


L = common.L
O = os.environ

DB_URI = (f"mysql+pymysql://"
          f"{O['MYSQL_USER']}:{O['MYSQL_PWD']}"
          f"@{O['MYSQL_HOST']}:{O['MYSQL_PORT']}/"
          f"{O['MYSQL_DATABASE']}")

engine = create_engine(DB_URI, echo = True)
session = Session(engine)
meta = MetaData()
Base = declarative_base(metadata=meta)
# vim:set et sts=4 ts=4 tw=120:
