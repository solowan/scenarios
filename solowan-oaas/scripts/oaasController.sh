#!/bin/bash	
sed  -i  '/^service_plugins/cservice_plugins = router,lbaas,optimizer' /etc/neutron/neutron.conf
python /tmp/OaaS/oaas.py -n controller -i
python /tmp/OaaS/oaas.py -n controller
