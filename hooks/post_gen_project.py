#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

from distutils.dir_util import remove_tree
import os
import subprocess


DEPLOY_BR = os.environ.get('DEPLOY_BR', 'stable')
# Workaround cookiecutter no support of symlinks
TEMPLATE = 'cookiecutter-simplecompose'
SYMLINKS = {
    'tox.ini': 'setup.cfg',
    'package.json': 'requirements/package.json',
    'package-lock.json': 'requirements/package-lock.json',
}
GITSCRIPT = """
set -ex
if [ ! -e ../.git ] && [ ! -e .git ];then git init;fi
if [ ! -e ../.git ];then
git remote rm origin || /bin/true
git remote add origin {{cookiecutter.git_project_url}}
fi
git add .
git add -f local/regen.sh
"""
GITSCRIPT += """
""".format(**locals())
EGITSCRIPT = """
sed="sed";if (uname | grep -E -iq "darwin|bsd");then sed="gsed";fi
if !($sed --version >/dev/null 2>&1);then echo $sed not avalaible;exit 1;fi
set -x
# strip whitespaces from compose
$sed -i -re 's/\s+$//g' docker-compose*.yml
$sed -i -r '/^\s*$/d' docker-compose*.yml

# block to sync with regen.sh
{% if not cookiecutter.with_githubactions %}
rm -rf .github
{% endif %}
{% if not cookiecutter.with_node %}
rm -rf node_module* .nvmrc package*json requirements/package*json
{% endif %}
{% if not cookiecutter.db_image %}
rm -rf src/dbutils.py
{% endif %}
{% if not cookiecutter.with_pyapp %}
rm -rf setup.* tox* requirements/*txt release.sh src lib
{% endif %}


"""

MOTD = '''
After reviewing all changes
do not forget to commit and push your new/regenerated project
'''


def remove_path(i):
    if os.path.exists(i) or os.path.islink(i):
        if os.path.islink(i):
            os.unlink(i)
        elif os.path.isdir(i):
            remove_tree(i)
        elif os.path.islink(i):
            os.unlink(i)


def sym(i, target):
    print('* Symlink: {0} -> {1}'.format(i, target))
    d = os.path.dirname(i)
    if d and not os.path.exists(d):
        os.makedirs(d)
    remove_path(i)
    os.symlink(target, i)


def main():
    s = GITSCRIPT
    for i in SYMLINKS:
        sym(i, SYMLINKS[i])
    s += EGITSCRIPT
    subprocess.check_call(["bash", "-c", s.format(template=TEMPLATE)])
    print(MOTD)


if __name__ == '__main__':
    main()
# vim:set et sts=4 ts=4 tw=0:
