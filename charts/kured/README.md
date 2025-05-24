# Kured

[Kured][1] come from **KU**bernetes **RE**boot **D**aemon.

openSUSE MicroOS is configured auto update and reboot by default, which means the nodes of cluster need to reboot after every update. You can use the MicroOS's `reboormgr` to manage the needed of reboot. It is a common and easy way to handle the reboot requestion. The defualt terraform in this repository use **cycle time slot** to avoid nodes reboot in same time.

Albeit it is useful in common situation and kubernetes can auto recover after node online, there is a more elegant way by using `kured` in kubernetes. In MicroOS, the `transactional-update` will create a reboot flag `/var/run/reboot-needed`. Kured can read this flag and formulate a reboot. The reboot not only reboot the system, but also drain and clean nodes before system shutdown. This avoid accident node shutdown and recover in the cluster.

```bash
helm repo add kubereboot https://kubereboot.github.io/charts
helm install kured kubereboot/kured -f values.yml -n kubesystem
```

And you can use argocd example to deploy kured.

[1]:https://github.com/kubereboot/charts/tree/main