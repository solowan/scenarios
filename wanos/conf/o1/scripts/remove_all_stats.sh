#!/bin/bash
iptables -t mangle -F PREROUTING
iptables -t mangle -F POSTROUTING
