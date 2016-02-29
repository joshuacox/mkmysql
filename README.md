# mkmysql
Make a persistent mysql container PDQ!


### Usage
`make temp` will make a temporary ephemeral fresh mysql instance

`make grab` will make a `datadir` in the current directory and copy out /var/lib/mysql out 
of the temporary container to be used in a persistent setup

`make clean` will clean up our temporary containers, but will not delete the `datadir`

`make prod` will then use the `datadir` and start up our container in persistent mode

alternative to `make temp` is the `make import` which will mount docker-entrypoint-initdb.d into 
the container, at which point entry-point.sh will execute everything in there that ends in `.sh` or `.sql`
