# Init a simplecompose project

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

