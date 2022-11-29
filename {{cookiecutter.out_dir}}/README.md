# tools for working with {{cookiecutter.name}}

## install as a python lib
```bash
pip install {{cookiecutter.lname}}
```

## Run in dev
### Configure
```bash
cp .env.dist .env
printf "USER_UID=$(id -u)\nUSER_GID=$(id -g)\n">>.env
```

### Build
```bash
eval $(egrep -hv '^#|^\s*$' .env|sed  -e "s/^/export /g"| sed -e "s/=/='/" -e "s/$/'/g"|xargs)
COMPOSE_FILE="docker-compose.yml:docker-compose-build.yml" docker-compose build
```

### Run

```bash
docker-compose run --rm app bash
```

```bash
sed -i -re "/COMPOSE_FILE/d" .env
# either
echo "COMPOSE_FILE=docker-compose.yml:docker-compose-dev.yml">>.env
# or
echo "COMPOSE_FILE=docker-compose.yml:docker-compose-dev.yml:docker-compose-build.yml">>.env
###
docker-compose up -d --force-recreate
docker-compose exec -u app app bash
```

### run tests
```bash
sed -i -re "/COMPOSE_FILE/d" .env
echo "COMPOSE_FILE=docker-compose.yml:docker-compose-dev.yml:docker-compose-test.yml" >>.env
docker-compose exec -U app app tox -e linting,coverage
```

### run prod
```bash
sed -i -re "/COMPOSE_FILE/d" .env
echo "COMPOSE_FILE=docker-compose.yml:docker-compose-prod.yml" >> .env
docker-compose up -d --force-recreate
```

There is a [sample systemd unit](./sys/{{cookiecutter.name}}.service) to handle start at (re)boot and an [installer](./sys/install_systemd.sh) for it.

```sh
sudo -E ./sys/install_systemd.sh
```

## Doc
see also [USAGE](./USAGE.md) (or read below on pypi)

