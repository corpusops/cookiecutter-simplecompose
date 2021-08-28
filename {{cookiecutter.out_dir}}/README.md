# tools for working with {{cookiecutter.name}}

## configure
```bash
cp .env.dist .env
cp .env.local.dist .env.local
printf "USER_UID=$(id -u)\nUSER_GID=$(id -g)\n">>.env
```

## build
```bash
eval $(egrep -hv '^#|^\s*$' .env .env.local|sed  -e "s/^/export /g"| sed -e "s/=/='/" -e "s/$/'/g"|xargs)
COMPOSE_FILE="docker-compose.yml:docker-compose-build.yml" docker-compose build
```

## run
```bash
docker-compose run --rm app bash
```

In dev, with scripts mounted as volumes
```bash
COMPOSE_FILE="docker-compose.yml:docker-compose-dev.yml" docker-compose run --rm app
```
