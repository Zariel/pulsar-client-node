#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

set -e

cat /var/crash/mounted
cp "$(which node)" /var/crash/

ROOT_DIR=$(git rev-parse --show-toplevel)
cd $ROOT_DIR

# install pulsar cpp client pkg
VERSION="${VERSION:-`cat ./pulsar-version.txt`}"
PULSAR_PKG_DIR="/tmp/pulsar-test-pkg"
rm -rf $PULSAR_PKG_DIR
for pkg in apache-pulsar-client-dev.deb apache-pulsar-client.deb;do
  curl -L --create-dir "https://archive.apache.org/dist/pulsar/pulsar-${VERSION}/DEB/${pkg}" -o $PULSAR_PKG_DIR/$pkg
done;
apt-get -y update
apt-get install -y software-properties-common
add-apt-repository ppa:ubuntu-toolchain-r/test && apt-get -y update
apt-get -y install gcc-4.9 && apt-get upgrade -y libstdc++6
apt install $PULSAR_PKG_DIR/apache-pulsar-client*.deb
apt install -y libunwind-dev

./pulsar-test-service-start.sh
npm install --debug && npm run lint && npm run dtslint && npm run build:debug && npm run test
RES=$?
./pulsar-test-service-stop.sh

exit $RES
