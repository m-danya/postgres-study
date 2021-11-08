## Практикум по Postgresql

ERD для заданий 2.x:

![2-1](2-1/2_1.png)

ERD для заданий 3.x:

![3-1](3-1/3_1.png)

Их делал [вот тут](https://online.visual-paradigm.com/diagrams/templates/entity-relationship-diagram/notations-for-traditional-erd/)

Ниже есть 2 инструкции — по установке postgresql на manjaro и по переносу папки с бд на hdd. 

Инструкции, как и лабы, могут содержать ошибки, неточности и т.д., предоставляются по принципу "AS IS" без каких-либо гарантий :)

Удачи! 

## Установка Postgres 11 на Manjaro
Ставится больно,  но работает. 

Ставим AUR-пакет `postgresql-11` (требуют 11.x версию)

postgres работает через отдельного пользователя. Особенность — в него нельзя зайти через пароль. Поэтому сделать это может только рут: `sudo su postgres` (тут уже пароль от рута нужен).

```bash
sudo chown postgres:postgres /var/lib/postgres
sudo su postgres
cd
initdb -D data
echo "pg_ctl -D data/ -l logfile start" > run.sh
chmod +x run.sh
./run.sh
vim data/postgresql.conf # изменить `unix_socket_directories` на '/tmp'
```

#### PgAdmin4
Ставится как pip-пакет. По-другому не работает, я очень долго мучился с этим. 
```bash
sudo mkdir /var/lib/pgadmin /var/log/pgadmin
pip install pgadmin4
sudo chown greedisgood:greedisgood /var/lib/pgadmin

pgadmin4
```

Каждый раз нужно будет запускать сервак так:

```bash
sudo su postgres
cd
./run.sh
<ctrl+D>
pgadmin4
```

В Pgadmin4 подключиться к серверу с хостом `localhost` и дефолтным портом. Пароль у меня был пустой. 

Запросы пишем через query tool к конкретной бд. В теме про транзакции надо использовать два query tool параллельных, выключить auto-commit, выделять мышкой нужные строки. Тогда при нажатии f5 будут выполняться только они. 

## Перенос кластера бд на HDD для лаб 3.x 

Чтобы не создавать 20-50 Гб активно использующихся данных на ssd, можно перенести папку с данными постгреса на hdd. Предполагается, что система у вас на ssd. 

Если жёсткий диск имеет файловую систему **NTFS** и вы на **Linux**, придётся немного повозиться, потому что при дефолтном монтировании NTFS в Linux права тупо не работают, а postgres требует, чтобы права на папку с данными были `0700` — исключительно для владельца (юзера `postgres`) 

В `/etc/fstab` добавьте следующую строку в конец:

`UUID=E8B4580DB457DC9E /mnt/Data ntfs auto,users,permissions 0 0`

Здесь вместо `E8B4580DB457DC9E` надо указать UUID вашего раздела диска. Узнать его можно в GParted (или через какую-нибудь консольную утилиту)

Сохраняем файл, выходим. 

Дальше **перезагружаемся** и пишем в терминале

```bash
sudo mkdir -p /mnt/Data/psql-data
sudo su postgres
cd
echo "pg_ctl -D /mnt/Data/psql-data/ -l logfile start" > run.sh
chmod +x run.sh
./run.sh
```

Если `pg_ctl` не найден, то в `run.sh` меняем `pg_ctl` на полный путь, который можно узнать через `find /usr/lib/postgresql/ -name pg_ctl`. Вообще так делать, [вроде как, не стоит](https://dba.stackexchange.com/questions/156717/command-not-found-pg-ctl-on-ubuntu), но оно работает. 

Если сервер не стартует, читаем `/var/lib/postgres/logfile`. Скорее всего надо будет что-то поправить в `/mnt/Data/psql-data/postgresql.conf`

Каждый раз нужно будет запускать сервак так:

```bash
sudo su postgres
cd
./run.sh
```

Ну и в Pgadmin4 подключиться к localhost:<порт из `/mnt/Data/psql-data/postgresql.conf`>

#### Куда кидать файлы с данными

Чтобы обойти приколы с правами на файл и генерить его из-под обычного юзера, файлы мы будем хранить в `/mnt/Data`: 

```bash
-rw-r--r— 1 greedisgood greedisgood 8340763194 окт 24 19:37 users.csv
```

(это вывод `ls -la`, который показывает, что владелец файла — обычный юзер)

Дальше создадим символическую ссылку внутри `psql-data`:

```bash
sudo su postgres
cd /mnt/Data/psql-data
ln -s ../users.csv users.csv
```

Всё. Теперь символическая ссылка будет указывать на нужный нам файл, и всё будет работать. В аргументах команды `COPY` в скриптах нужно писать просто `'users.csv'`. 
