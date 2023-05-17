while ! curl -o - redshift.data.subham.net:5439; do sleep 1; done
until </dev/tcp/localhost/32022; do sleep 1; done
