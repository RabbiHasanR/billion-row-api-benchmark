docker-compose.master_only load test. most of the request faild for too many clients already error in single database

FATAL:  pgpool is not accepting any new connections


default_pool_size = 80  # 50 before, increased for high load
reserve_pool_size = 30  # 20 before, increased for high load



docker exec -it pgpool psql -h 127.0.0.1 -p 9999 -U postgres -d postgres -c "SHOW pool_nodes;"  


pcp_node_info -h localhost -p 9898 -U pgpool  # using tcp for pcp connection in pgpool container

pg_md5 <password>  # for make md5 password




# username:password
postgres:postgres
pgpool_healthcheck:12345
replicator:123456

# pass is: admin123  pcp.conf

# password is 'password' for pcp pgpool
# password is 'admin123'  for pcp admin


pcp_node_count -h localhost -p 9898 -U pgpool -W