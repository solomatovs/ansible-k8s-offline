### Загрузка в buildah
```bash
# загрузка образа astra-linux
buildah pull docker-archive:astra_linux_ce_2.12-rootfs
buildah tag astra_linux_ce_2.12-rootfs:latest astra-linux:2.12
buildah images

# запуск образа с /bin/bash
buildah run --tty "$(buildah from astra_linux_ce_2.12-rootfs:latest)" -- /bin/bash

# удаление контейнера после использования
buildah containers
buildah rm <container_ID>
```

### Теперь можно делать так в Dockerfile
```Dockerfile
FROM localhost/astra-linux:2.12
```
