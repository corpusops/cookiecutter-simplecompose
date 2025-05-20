
DISCLAIMER - ABANDONED/UNMAINTAINED CODE / DO NOT USE
=======================================================
While this repository has been inactive for some time, this formal notice, issued on **December 10, 2024**, serves as the official declaration to clarify the situation. Consequently, this repository and all associated resources (including related projects, code, documentation, and distributed packages such as Docker images, PyPI packages, etc.) are now explicitly declared **unmaintained** and **abandoned**.

I would like to remind everyone that this project’s free license has always been based on the principle that the software is provided "AS-IS", without any warranty or expectation of liability or maintenance from the maintainer.
As such, it is used solely at the user's own risk, with no warranty or liability from the maintainer, including but not limited to any damages arising from its use.

Due to the enactment of the Cyber Resilience Act (EU Regulation 2024/2847), which significantly alters the regulatory framework, including penalties of up to €15M, combined with its demands for **unpaid** and **indefinite** liability, it has become untenable for me to continue maintaining all my Open Source Projects as a natural person.
The new regulations impose personal liability risks and create an unacceptable burden, regardless of my personal situation now or in the future, particularly when the work is done voluntarily and without compensation.

**No further technical support, updates (including security patches), or maintenance, of any kind, will be provided.**

These resources may remain online, but solely for public archiving, documentation, and educational purposes.

Users are strongly advised not to use these resources in any active or production-related projects, and to seek alternative solutions that comply with the new legal requirements (EU CRA).

**Using these resources outside of these contexts is strictly prohibited and is done at your own risk.**

This project has been transfered to Makina Corpus <freesoftware-corpus.com> ( https://makina-corpus.com ). This project and its associated resources, including published resources related to this project (e.g., from PyPI, Docker Hub, GitHub, etc.), may be removed starting **March 15, 2025**, especially if the CRA’s risks remain disproportionate.

# Init a simplecompose project

DISCLAIMER
============

**UNMAINTAINED/ABANDONED CODE / DO NOT USE**

Due to the new EU Cyber Resilience Act (as European Union), even if it was implied because there was no more activity, this repository is now explicitly declared unmaintained.

The content does not meet the new regulatory requirements and therefore cannot be deployed or distributed, especially in a European context.

This repository now remains online ONLY for public archiving, documentation and education purposes and we ask everyone to respect this.

As stated, the maintainers stopped development and therefore all support some time ago, and make this declaration on December 15, 2024.

We may also unpublish soon (as in the following monthes) any published ressources tied to the corpusops project (pypi, dockerhub, ansible-galaxy, the repositories).
So, please don't rely on it after March 15, 2025 and adapt whatever project which used this code.



Idea is to create it with a wonderful python tool called
[cookiecutter](https://github.com/audreyr/cookiecutter)

##  Install prerequisites
```
if ! ( virtualenv --version 2>&1 >/dev/null );then echo "ERROR: install venv, on debian/ubuntu: apt install -y virtualenv,fi";fi
virtualenv --python=python3 ~/tools/cookiecutter
~/tools/cookiecutter/bin/pip install cookiecutter
```

### For MacOS users

Install gnu-sed with `brew install gsed` and use it as default with `export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"` for the focllowing commands.

## Create back project
- create on gitlab your project
- then locally (replace with your values)

    ```sh
    cd ~/.cookiecutters/cookiecutter-simplecompose \
        && git fetch origin && git reset --hard origin/main \
        && cd -
    cookiecutter --no-input -f -o ~/out_dir \
        https://github.com/corpusops/cookiecutter-simplecompose.git \
        name=foo \
        git_server=git.foo.com \
        git_ns=bar \
    cd ~/out_dir
    # review before commit
    # for relative checkout to work, we need remote objects locally
    git commit local -m "Add deploy"
    ```

- Read [cookiecutter.json](./cookiecutter.json) for all options

## Update project
You can regenerate at a later time the project
```sh
local/regen.sh  # and verify new files and updates
```

