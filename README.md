# NTUST OAI-CORD scenario for CiaB 4.1 & 5.0

Deploy CiaB (Cord-in-a-Box) with OAI EPC and BBU service

![](https://i.imgur.com/rpvFxXM.png)


![](https://i.imgur.com/r4W3wID.png)


## Related branch

- script to onboard OAI service on M-CORD (private)
    - [NTUST OAI-CORD scenario](https://gitlab.com/NickHoB/NTUST_OAI_CORD)

- script to onboard OAI service on M-CORD (final publish)

    - [oai_scenario with BBU](https://github.com/nick133371/oai_scenario)

- oaiBBU : split version of eNB

    - [oaiBBU synchronizer](https://github.com/nick133371/oaiBBU)

- epc-service : use for setting up everything
	- [epc-service synchronizer](https://github.com/nick133371/epc-service)

- CORD_Automation : fully automation for deployment / installation / debugging
	- [Automation](https://gitlab.com/NickHoB/CORD_Automation)

## Preparation

### Hardware requirement

Before starting the Cord-in-a-Box installation, be sure that your server fit the following requirement

* 64-bit AMD64/x86-64 server
* 96 GB+ RAM
* 16+ CPU cores
* 2 TB+ disk
* Access to internet
* ubuntu 16.04 / 14.04 with fresh update
* sudo less

### Setup sudo without password

use **sudo visudo** to edit the following configuration

Note: ubuntu change to your user name

``` = 
# User privilege specification
root    ALL=(ALL:ALL) ALL
 
# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL
 
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL
 
ubuntu  ALL=(ALL) NOPASSWD:ALL
 
# See sudoers(5) for more information on "#include" directives:
 
#includedir /etc/sudoers.d
```

## CiaB 4.1

For CiaB 5.0 user, please directly go to Ciab-5.0

Download source code from cord github, and modify the property of the bash file.

```=
curl -o ~/cord-bootstrap.sh https://raw.githubusercontent.com/opencord/cord/cord-4.1/scripts/cord-bootstrap.sh
chmod +x cord-bootstrap.sh

./cord-bootstrap -v
```

Problem
```
TASK [prereqs-common : Check here on failure: 'https://guide.opencord.org/troubleshooting.html#prereqs-common-failures'] *********************************************************************************************************************
Thursday 19 July 2018  10:36:08 +0800 (0:00:01.063)       0:00:01.113 *********
Pausing for 10 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: error: (25, 'Inappropriate ioctl for device')
fatal: [localhost]: FAILED! => {"msg": "Unexpected failure during module execution.", "stdout": ""}
```

Due to the ansible version problem, we need to downgrade ansible version first.


```=
sudo apt-get remove ansible -y
sudo pip install --upgrade pip setuptools
sudo pip install ansible==2.5.2
```

If you are having trouble when building CORD at the stage “lxc finished” in case of container connectivity problem.
Some campus network will not allow us to query the result of DNS, so that we need to modify the playbook.

```=
vim ~/cord/build/maas/roles/maas/tasks/config-maas.yml
```
try to add dnssec_validation: 'no' into the file.
```=
# ~/cord/build/maas/roles/maas/tasks/config-maas.yml
- name: Ensure Upstream DNS Server 
  maas:
    key: '{{apikey.stdout}}'
    maas: 'http://{{mgmt_ip_address.stdout}}/MAAS/api/1.0'
    upstream_dns: '{{maas.upstream_dns}}'
    dnssec_validation: 'no'
    state: present
```
:::info
config-maas.yml defines tests/checks for the environment. Setting DNS check to false can avoid the error caused by the internet provider.
:::

Get OAI service
```shell=
cd ~/
git clone https://gitlab.com/NickHoB/NTUST_OAI_CORD.git
cd ~/NTUST_OAI_CORD/
git checkout Ciab-4.1
./start.sh # Make all the custom configuration / VNF / synchronizer in to the cord
```
Build the service

```=
cd ~/cord/build/;
make PODCONFIG=mcord-oai-virtual.yml;
make -j4 build
```
After successfully build the CORD, Check the password for XOS GUI
```=
# check for xos password 
ssh head1 -qt "cat /opt/credentials/xosadmin@opencord.org"
```

And you can get into the web UI from {your_ip}:8080/xos
account :xosadmin@opencord.org
password has checked by the above command
Then you will see the following service graph.

![](https://i.imgur.com/D6STEAB.png)

## Ciab-5.0

Download source code from cord github, and modify the property of the bash file.

```bash=
curl -o ~/cord-bootstrap.sh https://raw.githubusercontent.com/opencord/cord/cord-5.0/scripts/cord-bootstrap.sh
chmod +x cord-bootstrap.sh

./cord-bootstrap -v
```

Problem
```
TASK [prereqs-common : Check here on failure: 'https://guide.opencord.org/troubleshooting.html#prereqs-common-failures'] *********************************************************************************************************************
Thursday 19 July 2018  10:36:08 +0800 (0:00:01.063)       0:00:01.113 *********
Pausing for 10 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: error: (25, 'Inappropriate ioctl for device')
fatal: [localhost]: FAILED! => {"msg": "Unexpected failure during module execution.", "stdout": ""}
```

Due to the ansible version problem, we need to downgrade ansible version first.


```bash=
sudo apt-get remove ansible -y
sudo pip install --upgrade pip setuptools
sudo pip install ansible==2.5.2
```

If you are having trouble when building CORD at the stage “lxc finished” in case of container connectivity problem.
Some campus network will not allow us to query the result of DNS, so that we need to modify the playbook.

```bash=
vim ~/cord/build/maas/roles/maas/tasks/config-maas.yml
```
try to add dnssec_validation: 'no' into the file.
```=
# ~/cord/build/maas/roles/maas/tasks/config-maas.yml
- name: Ensure Upstream DNS Server 
  maas:
    key: '{{apikey.stdout}}'
    maas: 'http://{{mgmt_ip_address.stdout}}/MAAS/api/1.0'
    upstream_dns: '{{maas.upstream_dns}}'
    dnssec_validation: 'no'
    state: present
```
:::info
config-maas.yml defines tests/checks for the environment. Setting DNS check to false can avoid the error caused by the internet provider.
:::

Get OAI service
```bash=
cd ~/
git clone https://gitlab.com/NickHoB/NTUST_OAI_CORD.git
cd ~/NTUST_OAI_CORD/
git checkout Ciab-5.0
./start.sh # Make all the custom configuration / VNF / synchronizer in to the cord
```
Build the service

```bash=
cd ~/cord/build/;
make PODCONFIG=mcord-oai-virtual.yml;
make -j4 build
```
After successfully build the CORD, Check the password for XOS GUI
```bash=
# check for xos password 
ssh head1 -qt "cat /opt/credentials/xosadmin@opencord.org"
```

And you can get into the web UI from {your_ip}:8080/xos
account :xosadmin@opencord.org
password has checked by the above command
Then you will see the following service graph.

## Having trouble with no GUI after sucessfully deployed?

```bash=
ps ax|grep 8080
```
copy the line related to ssh it will like:

```bash=
 9762 ?        S      0:00 ssh -o User=vagrant -o Port=22 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o ForwardX11=no -o IdentityFile="/home/cord/cord/build/scenarios/cord/.vagrant/machines/head1/libvirt/private_key" -L *:8080:192.168.121.157:80 -N 192.168.121.157
```
and then kill that process

```bash=
sudo kill -9 <<process ID>>
```

open a new terminal and paste the command you have copied

```
ssh -o User=vagrant -o Port=22 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o ForwardX11=no -o IdentityFile="/home/cord/cord/build/scenarios/cord/.vagrant/machines/head1/libvirt/private_key" -L *:8080:192.168.121.157:80 -N 192.168.121.157
```

## Clean environment

If you want to re-install CORD or you want to clean all the configuration of M-CORD, try the following script.

```bash=
cd ~/cord/build
make clean-all
```

## Access Openstack Horizon
```bash=
ssh -L 0.0.0.0:9999:10.1.0.11:80 head1
```
User name and password are in the head node 
```bash=
ssh head1 
cat /opt/cord_profile/admin-openrc.sh
```

![](https://i.imgur.com/b1kIYxD.png)

## General OAI service

```bash=
vagrant@head1:~$ source /opt/cord_profile/admin-openrc.sh
vagrant@head1:~$ nova list --all-tenants
+--------------------------------------+------------------+--------+------------+-------------+-----------------------------------------------------------------+
| ID                                   | Name             | Status | Task State | Power State | Networks                                                        |
+--------------------------------------+------------------+--------+------------+-------------+-----------------------------------------------------------------+
| 6a554da9-5144-46ee-a21b-f604ea35d10c | mysite_vhss1-4   | ACTIVE | -          | Running     | management=172.27.0.2; vhss_network=10.0.7.2                    |
| d0e31984-1720-43e6-9dd5-e8409aa8f123 | mysite_vmme1-3   | ACTIVE | -          | Running     | management=172.27.0.3; vmme_network=10.0.6.2                    |
| 1f33a68c-b742-43d2-b06f-9885256401f7 | mysite_vspgwc1-1 | ACTIVE | -          | Running     | management=172.27.0.4; vspgwc_network=10.0.8.2                  |
| 76cb5dc4-8c31-491d-b200-b26d3fcc0448 | mysite_vspgwu1-2 | ACTIVE | -          | Running     | management=172.27.0.5; public=10.8.1.2; vspgwu_network=10.0.9.2 |
+--------------------------------------+------------------+--------+------------+-------------+-----------------------------------------------------------------+
```