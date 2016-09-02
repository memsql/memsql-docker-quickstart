#!/bin/bash
set -e
set -x

# Expects this file to export $OPS_VERSION and $MEMSQL_VERSION
source /tmp/VERSIONS

VERSION_URL="http://versions.memsql.com/memsql-ops/$OPS_VERSION"
MEMSQL_VOLUME_PATH="/memsql"
OPS_URL=$(curl -s "$VERSION_URL" | jq -r .tar)

# setup memsql user
groupadd -r memsql --gid 1000
useradd -r -g memsql -s /bin/false --uid 1000 \
    -d /var/lib/memsql-ops -c "MemSQL Service Account" \
    memsql

# download ops
curl -s $OPS_URL -o /tmp/memsql_ops.tar.gz

# install ops
mkdir /tmp/memsql-ops
tar -xzf /tmp/memsql_ops.tar.gz -C /tmp/memsql-ops --strip-components 1
/tmp/memsql-ops/install.sh \
    --host 127.0.0.1 \
    --no-cluster \
    --ops-datadir /memsql-ops \
    --memsql-installs-dir /memsql-ops/installs

DEPLOY_EXTRA_FLAGS=
if [[ $MEMSQL_VERSION != "community" ]]; then
    DEPLOY_EXTRA_FLAGS="--version-hash $MEMSQL_VERSION"
fi

memsql-ops memsql-deploy --role master --community-edition $DEPLOY_EXTRA_FLAGS
memsql-ops memsql-deploy --role leaf --community-edition --port 3307 $DEPLOY_EXTRA_FLAGS

MASTER_ID=$(memsql-ops memsql-list --memsql-role=master -q)
MASTER_PATH=$(memsql-ops memsql-path $MASTER_ID)

LEAF_ID=$(memsql-ops memsql-list --memsql-role=leaf -q)
LEAF_PATH=$(memsql-ops memsql-path $LEAF_ID)

# symlink leaf's static directories to master
for tgt in objdir lib; do
    rm -rf $LEAF_PATH/$tgt
    ln -s $MASTER_PATH/$tgt $LEAF_PATH/$tgt
done

# setup mutable directories in the volume
function setup_node_dirs {
    local node_name=$1
    local node_id=$2
    local node_path=$3

    # update socket file
    memsql-ops memsql-update-config --key "socket" --value $node_path/memsql.sock $node_id

    mkdir -p /memsql/$node_name

    for tgt in data plancache tracelogs; do
        # update the volume template
        cp -r $node_path/$tgt /memsql/$node_name

        # symlink the dir
        rm -rf $node_path/$tgt
        ln -s $MEMSQL_VOLUME_PATH/$node_name/$tgt $node_path/$tgt
    done
}

setup_node_dirs master $MASTER_ID $MASTER_PATH
setup_node_dirs leaf $LEAF_ID $LEAF_PATH

chown -R memsql:memsql /memsql /memsql-ops

# cleanup
rm -rf /tmp/memsql-ops*
rm -rf /memsql-ops/data/cache/*
