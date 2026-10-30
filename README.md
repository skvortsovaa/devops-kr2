# DevOps KR2 — вариант 2

Скворцов Александр Александрович, ЭФБО-07-24, номер по списку 26.

Приложение Flask и Redis 7 публикуются через Nginx по адресу
`https://notes.devops.local`. Приложение слушает порт 8002 внутри контейнера;
Docker публикует его только как `127.0.0.1:8002:8002`. Redis не публикует порт.

## Запуск на devops-vm

```bash
cd ~/kr2
unset REDIS_PASSWORD
bash scripts/init-secret.sh
docker compose up -d --build --wait
bash scripts/setup-https.sh
```

Секрет генерируется только на сервере. Существующий `.env` не перезаписывается.
Не копируйте `.env` из исходного шаблона: опубликованный пароль не является секретом.

На клиенте добавьте `192.168.56.101 notes.devops.local` в hosts, скопируйте
открытый сертификат `/etc/ssl/certs/kr2.crt` и проверьте:

```bash
curl --cacert ~/kr2.crt https://notes.devops.local/
curl --cacert ~/kr2.crt https://notes.devops.local/whoami
curl -I http://notes.devops.local/
curl -m 3 http://notes.devops.local:8002/health
```

Последняя команда должна завершиться ошибкой подключения.
Самоподписанный сертификат требует явного доверия. Не используйте `curl -k`
вместо проверки сертификата при сдаче работы.

## Проверка

```bash
sudo -v
bash scripts/audit.sh
docker compose ps
docker compose top
docker compose port app 8002
docker compose exec redis redis-cli ping  # ожидается NOAUTH
```

`scripts/audit.sh` сохраняет проверки ПР7 и добавляет раздел 6 для КР2.
Для проверки сохранности данных используйте `docker compose down`, затем
`docker compose up -d --wait`. **Не используйте `down -v`**: он удаляет том.

## Доставка

```bash
rsync -avz --delete --exclude=.env --exclude=.git --dry-run ./ devops:kr2/
rsync -avz --delete --exclude=.env --exclude=.git ./ devops:kr2/
```

Конфигурация существующего `devops-site` и правила UFW не изменяются.
Исходный шаблон: https://gitverse.ru/dgimatdinov/kr2-template
Основная ветка содержит исходный шаблон. Решение находится в
`kr2/variant-2`; Pull Request оставляется открытым до защиты.
