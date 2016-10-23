Notes about SoloWAN KVM based testbed virtual scenario
------------------------------------------------------

Requirements:
- opennop software located in /home/solowan/opennop

<<<<<<< HEAD
- opennop software is located in /home/solowan/opennop
=======
>>>>>>> master

Starting the scenario:
---------------------

- Start test scenario with:

vnx -f opennop.xml -v -t

Basic commands:
---------------

- Configure and restart WAN emulator:

vi conf/wanem/config
vnx -f opennop.xml -v -x emula

- Copy OpenNOP-SoloWAN code from /home/solowan/OpenNOP/ to /root/OpenNOP directory in optimizers:

vnx -f opennop.xml -v -x copycode

- Option A: Load iptables rules to redirect traffic to OpenNOP:

vnx -f opennop.xml -v -x loadiptables

- Option B: Compile and start opennop module:

vnx -f opennop.xml -v -x reloadmod

#vnx -f opennop.xml -v -x unloadmod
#vnx -f opennop.xml -v -x compmod
#vnx -f opennop.xml -v -x loadmod

- Compile and start opennop daemon:

vnx -f opennop.xml -v -x reloaddaemon

#vnx -f opennop.xml -v -x stopdaemon
#vnx -f opennop.xml -v -x compdaemon
#vnx -f opennop.xml -v -x startdaemon

- Start http server in h2 and generate random test files:

vnx -f opennop.xml -v -x start-http

- Create tunnel between optimizers:

vnx -f opennop.xml -v -x createtunnel

- Add route to send all traffic through tunnels:

vnx -f opennop.xml -v -x addtunnelroute

Compound commands:
-----------------

vnx -f opennop.xml -v -x start-all


NOTAS ADICIONALES:

- iptables useful commands:

Borrar todas las reglas iptables:

iptables -X; iptables -F

Enviar a la cola 0 todos los paquetes reenviados:

iptables -A FORWARD -j NFQUEUE --queue-num 0

Enviar a la cola 0 todos los paquetes TCP reenviados:

iptables -A FORWARD -j NFQUEUE --queue-num 0 -p TCP

Enviar a la cola 0 todos los paquetes TCP reenviados con origen o destino en el puerto 22:

iptables -A FORWARD -j NFQUEUE --queue-num 0 -p TCP --sport 22
iptables -A FORWARD -j NFQUEUE --queue-num 0 -p TCP --dport 22

- netfilter useful commands:

Ver estado de la cola de paquetes:

watch cat /proc/net/netfilter/nfnetlink_queue

Ejemplo:

# cat /proc/net/netfilter/nfnetlink_queue 
    0  10940     0 2  2048     0     0    17991  1


Referencias:

- https://home.regit.org/netfilter-en/using-nfqueue-and-libnetfilter_queue/
