docker-compose.master_only load test. most of the request faild for too many clients already error in single database

FATAL:  pgpool is not accepting any new connections


default_pool_size = 80  # 50 before, increased for high load
reserve_pool_size = 30  # 20 before, increased for high load



docker exec -it pgpool psql -h 127.0.0.1 -p 9999 -U postgres -d postgres -c "SHOW pool_nodes;"  


chmod 600 ./pgpool/ssh/id_rsa  # need to change permisiion on host machine