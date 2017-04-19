#!/bin/bash
# == Fetch proper Observium version

community_http() {
    cd /tmp &&
    wget http://www.observium.org/observium-community-latest.tar.gz &&
    tar xvf observium-community-latest.tar.gz &&
    rm observium-community-latest.tar.gz
}

professional_svn() {
    cd /tmp &&
    svn co --non-interactive \
           --username $SVN_USER \
           --password $SVN_PASS \
           $SVN_REPO observium
}

if [[ "$USE_SVN" == "true" && "$SVN_USER" && "$SVN_PASS" && "$SVN_REPO" ]]
then
    professional_svn
else
    community_http
fi
# I know this seems ridiculous, but since /opt/observium/html is an external
# volume mount, svn throws a fit about it conflicting with the tree. Pulling
# SVN to temp directory and copying contents into /opt/observium was just the
# first way thought of to avoid dealing with the svn conflict resolution from
# script.
cp -r /tmp/observium/* /opt/observium/

# configure observium package
cd /opt/observium && \
cp config.php.default config.php && \
sed -i -e "s/= 'localhost';/= getenv('OBSERVIUM_DB_HOST');/g" config.php && \
sed -i -e "s/= 'USERNAME';/= getenv('OBSERVIUM_DB_USER');/g" config.php && \
sed -i -e "s/= 'PASSWORD';/= getenv('OBSERVIUM_DB_PASS');/g" config.php && \
sed -i -e "s/= 'observium';/= getenv('OBSERVIUM_DB_NAME');/g" config.php

C='$config['\''rrdcached'\''] = "unix:/var/run/rrdcached.sock";'
echo $C >> /opt/observium/config.php

chown nobody:users -R /opt/observium
chmod 755 -R /opt/observium

