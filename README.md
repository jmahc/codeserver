# codeserver

This project serves as an extension of the [Docker] image, [codercom/codeserver], with added packages and assets that are not included by default.

While a great starting place, the [codercom/codeserver] image does not contain _everything_ and I wanted to make it so that it does!

## Setup

Referencing the `package.json` file included in this repository and assuming that you have [installed Docker] on the machine, you can execute the following commands.

- `npm run build` builds the [Docker] image
- `npm run start` runs the [Docker] image in a new container

## Docker-Compose

To utilize [Docker compose] with this image, you will want a [Docker plugin] called [local-persist]. The documentation for setting up the plugin can be found in that repository, however, if you are using this repository on a Linux machine, execute the following:

- `curl -fsSL https://raw.githubusercontent.com/CWSpear/local-persist/master/scripts/install.sh | sudo bash` will install the plugin
- `docker volume create -d local-persist -o mountpoint=/path/to/volume/codeserver_data --name=codeserver_data` will create the volume named **codeserver_data**

With the newly created `codeserver_data` volume, you are just about there. For permissions reasons, I copied the [letsencrypt] certificates into the same directory as the `docker-compose.yml` and `Dockerfile` files.

A `docker-compose.yml` file might look something like this:

```yml
version '3'

services:
  codeserver:
    build:
      context: .
      dockerfile: Dockerfile
    image: codercom/code-server:latest
    container_name: codeserver
    restart: always
    ports:
      - 8443:8443
    volumes:
      - codeserver_data:/root/project
      # Contains `letsencrypt` certificates with permissions.
      - /path/to/certs:/certs:ro
    command: --allow-http --password=P@ssw0rd123 --data-dir=/path/to/data/directory --cert=/certs/cert.pem --cert-key=/certs/privkey.pem

volumes:
  codeserver_data:
    driver: local-persist
    driver_opts:
      mountpoint: /path/to/volume/codeserver_data
```

With all that in hand, you can spin up the container with `docker-compose up -d`. Enjoy!

---

[codercom/codeserver]: https://github.com/codercom/code-server
[docker]: https://www.docker.com/
[docker plugin]: https://docs.docker.com/engine/extend/plugin_api/
[installed docker]: https://docs.docker.com/install/
[local-persist]: https://github.com/CWSpear/local-persist
[letsencrypt]: https://letsencrypt.org/
