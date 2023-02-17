OCP_VERSION=$1
echo "Installing openshift $OCP_VERSION"
ARCH=x86_64
LOCALHOST=linux
rm -r -f ocp
mkdir ocp
cat install-config.yaml secrets.yaml > ocp/install-config.yaml
cd ocp
curl -k https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$OCP_VERSION/openshift-client-$LOCALHOST.tar.gz -o oc.tar.gz
tar zxf oc.tar.gz
chmod +x oc
curl -k https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$OCP_VERSION/openshift-install-$LOCALHOST.tar.gz -o openshift-install.tar.gz
tar xvzf openshift-install.tar.gz
chmod +x ./openshift-install
ISO_URL=$(./openshift-install coreos print-stream-json | grep location | grep $ARCH | grep iso | cut -d\" -f4)
curl -L $ISO_URL -o rhcos-live.iso
cd ..
./ocp/openshift-install --dir=ocp create single-node-ignition-config
alias coreos-installer='podman run --privileged --pull always --rm -v /dev:/dev -v /run/udev:/run/udev -v $PWD:/data -w /data quay.io/coreos/coreos-installer:release'
coreos-installer iso ignition embed -fi ocp/bootstrap-in-place-for-live-iso.ign rhcos-live.iso
