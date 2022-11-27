### Usage

### Start at boot
set prod set of config files

```sh
sed "/COMPOSE_FILE/d" .env
echo COMPOSE_FILE=docker-compose.yml:docker-compose-prod.yml>>.env
```

Remember that you can also make a systemd unit to autoreboot your service, see [this example](./sys/{{cookiecutter.lname}}.service)

