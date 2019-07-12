#!/bin/bash
# Script to install PostgreSQL 10 and PostGIS 2.5 on fresh Amazon Linux 2
# Installing from source:
# - GEOS 3.7.1
# - GDAL 2.4.0
# - PostGIS 2.5.1

set -e

sudo amazon-linux-extras install postgresql10 vim epel -y
sudo yum-config-manager --enable epel -y
sudo yum update -y
sudo yum install -y make automake gcc gcc-c++ libcurl-devel proj-devel pcre-devel autoconf automake libxml2-devel
sudo yum install -y postgresql-server postgresql-devel

############################
# Install GEOS from Source #
############################
curl -O http://download.osgeo.org/geos/geos-3.7.1.tar.bz2
tar xvjf geos-3.7.1.tar.bz2
rm -f geos-3.7.1.tar.bz2
cd geos-3.7.1/
./configure
make
sudo make install
cd

############################
# Install GDAL from Source #
############################
curl -O http://download.osgeo.org/gdal/2.4.0/gdal-2.4.0.tar.gz
tar xvzf gdal-2.4.0.tar.gz
rm -f gdal-2.4.0.tar.gz
cd gdal-2.4.0
./configure \
    --prefix=${PREFIX} \
    --with-geos \
    --with-geotiff=internal \
    --with-hide-internal-symbols \
    --with-libtiff=internal \
    --with-libz=internal \
    --with-threads \
    --without-bsb \
    --without-cfitsio \
    --without-cryptopp \
    --with-curl \
    --without-dwgdirect \
    --without-ecw \
    --without-expat \
    --without-fme \
    --without-freexl \
    --without-gif \
    --without-gif \
    --without-gnm \
    --without-grass \
    --without-grib \
    --without-hdf4 \
    --without-hdf5 \
    --without-idb \
    --without-ingres \
    --without-jasper \
    --without-jp2mrsid \
    --without-jpeg \
    --without-kakadu \
    --without-libgrass \
    --without-libkml \
    --without-libtool \
    --without-mrf \
    --without-mrsid \
    --without-mysql \
    --without-netcdf \
    --without-odbc \
    --without-ogdi \
    --without-openjpeg \
    --without-pcidsk \
    --without-pcraster \
    --with-pcre \
    --without-perl \
    --with-pg \
    --without-php \
    --without-png \
    --without-python \
    --without-qhull \
    --without-sde \
    --without-sqlite3 \
    --without-webp \
    --with-xerces \
    --with-xml2
make
sudo make install
cd

###################################
# Install PostGIS 2.5 from source #
###################################
curl -O https://download.osgeo.org/postgis/source/postgis-2.5.1.tar.gz
tar xvzf postgis-2.5.1.tar.gz
rm -f postgis-2.5.1.tar.gz
cd postgis-2.5.1/
./configure --with-address-standardizer
make
sudo make install

###################
# Final Prep Work #
###################
sudo ln -s /usr/local/lib/libgeos_c.so.1 /usr/lib64/pgsql/libgeos_c.so.1
sudo sh -c 'echo /usr/local/lib > /etc/ld.so.conf.d/postgresql.conf'
sudo sh -c 'echo /usr/lib64/pgsql >> /etc/ld.so.conf.d/postgresql.conf'
sudo ldconfig -v

export PGHOME=/var/lib/pgsql/data/
sudo su postgres -c "pg_ctl -D $PGHOME initdb"

sudo systemctl enable postgresql
sudo systemctl start postgresql

echo "
Your system is now running PostgreSQL 10, with PostGIS 2.5. 
You should now run "aws configure" to set up the AWS CLI.   
Afterwards, you should stop this instance and create an AMI. 
"
