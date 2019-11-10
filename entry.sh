tail /etc/postgres/9.4/main/pg_hba.conf
service postgresql start

until su - postgres -c "PGPASSWORD=password psql"; do
  sleep 5
done
tail -f /var/log/dpkg.log
