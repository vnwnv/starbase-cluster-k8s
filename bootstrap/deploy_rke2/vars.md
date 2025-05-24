# Ansible Role Variables Documentation

Note: When you override a config field in a structure, you must provide the others! Otherwise, the not provided field will be deleted.

## Default Variables (`defaults/main.yml`)

### Keepalived Settings

| Variable                       | Default                                    | Type    | Description                                                                                                                                                                                                                                                         |
| ------------------------------ | ------------------------------------------ | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `keepalived.priority`          | "" (Auto generate: MASTER=150, BACKUP=100) | string  | Defines the priority value for VRRP election. If left empty, it will be automatically set to 150 for the MASTER node and 100 for BACKUP nodes. Higher priority values win elections. This can be manually overridden if specific priority ordering is required.     |
| `keepalived.virtual_ip`        | ""                                         | string  | **Required**. The floating/VIP (Virtual IP) address that will be shared between nodes for high availability. Example: "192.168.1.100". This IP should be in the same subnet as the node's interface IP and not conflict with any existing IPs.                      |
| `keepalived.virtual_ip_prefix` | 24                                         | integer | The network prefix length for the virtual IP address (CIDR notation). This typically matches your network's subnet mask. For example, 24 corresponds to 255.255.255.0.                                                                                              |
| `keepalived.virtual_router_id` | 51                                         | integer | The VRRP router identifier (1-255). Must be unique for each VRRP instance on the same network. If you're running multiple clusters, each should have a different ID.                                                                                                |
| `keepalived.network_interface` | `ansible_default_ipv4.interface`           | string  | The network interface where the VIP will be assigned. Defaults to the system's default IPv4 interface (eth0, ens192, etc.). Change this if you want to use a different interface (like a dedicated HA interface).                                                   |
| `keepalived.unicast_enabled`   | false                                      | boolean | When true, uses unicast instead of multicast for VRRP communication. Useful in environments where multicast is restricted. When enabled, the `keepalived_unicast_peers` will auto generated. you can also configure `keepalived_unicast_peers` manually with false. |

### HAProxy Settings

| Variable                       | Default      | Type    | Description                                                                                                                                                                                                             |
| ------------------------------ | ------------ | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `haproxy.api_port`             | 6443         | integer | The port where HAProxy will listen for Kubernetes API requests. This should match the default Kubernetes API port unless you have specific routing requirements.                                                        |
| `haproxy.registration_port`    | 9345         | integer | The port used for RKE2 node registration. This is a specific port that RKE2 uses for joining new nodes to the cluster.                                                                                                  |
| `haproxy.balance_algorithm`    | "roundrobin" | string  | The load balancing algorithm used by HAProxy to distribute connections. Options include: "roundrobin" (default, equal distribution), "leastconn" (prefer server with least connections), "source" (client IP affinity). |
| `haproxy.auto_generate_server` | true         | boolean | When true, the server list for HAProxy will be automatically generated from inventory hosts. Set to false if you want to manually define backend servers in `rke2_server` list.                                         |
| `haproxy.use_fqdn`             | true         | boolean | Use the node's FQDN instead of ip address in backend config. Useful in dynamic ip address environment.                                                                                                                  |

### RKE2 Configuration

| Variable                                | Default                          | Type    | Description                                                                                                                                                                                                                                                          |
| --------------------------------------- | -------------------------------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `rke2_config.tls_san`                   | [`keepalived.virtual_ip`]        | list    | List of Subject Alternative Names (SANs) for the API server certificate. Auto generate with `keepalived.virtual_ip` Examples: ["k8s.example.com", "192.168.1.100"]. Important for making the certificate valid when accessed through load balancer IPs or DNS names. |
| `rke2_config.embedded_registry.enabled` | false                            | boolean | Enables RKE2's embedded container registry. Useful for air-gapped environments or when you want to cache images locally.                                                                                                                                             |
| `rke2_config.embedded_registry.mirrors` | ["docker.io", "registry.k8s.io"] | list    | Registry mirrors that will be configured for the embedded registry. These are the repositories the registry will cache/pull from. Add your private registry endpoints here if needed.                                                                                |
| `rke2_config.cni                        | "canal"                          | string  | RKE2 CNI plugin, default is canal, same to RKE2. read the [_RKE2 Network Options_](https://docs.rke2.io/networking/basic_network_options?CNIplugin=Canal+CNI+Plugin) and select which you want.                                                                      |
| `rke2_config.selinux`                   | true                             | boolean | Enable RKE2 selinux support in config file. Needed in default openSUSE MicroOS config                                                                                                                                                                                |
| `rke2_config.disable_charts`            | null                             | list    | List of the server charts bundled with RKE2 to disable. A common use case is replacing the bundled `rke2-ingress-nginx` chart with an alternative.                                                                                                                   |
| `rke2_config.node_labels`               | null                             | list    | List of the node labels to identify. These labels will apply to every node of cluster                                                                                                                                                                                |

### Add Server Switch

| Variable       | Default | Type    | Description                                                                                                                          |
| -------------- | ------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| add_additional | false   | boolean | To add addtional server to current cluster. Should be `false` if you are deploy at first time and you do not have a running cluster. |

### RKE2 Proxy Configuration

| Variable                  | Default                                               | Type    | Description                                                                                                                                                                                                                                                        |
| ------------------------- | ----------------------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `rke2_proxy.enable_proxy` | false                                                 | boolean | Whether to configure RKE2 nodes to use a proxy for internet access. Required in restricted network environments where direct internet access is blocked. When enabled, ensure all proxy URLs (`http_proxy`, `https_proxy`) are reachable from your nodes.          |
| `rke2_proxy.http_proxy`   | "http://192.168.1.1:8080"                             | string  | HTTP proxy address for non-secure connections (HTTP traffic). Must include protocol (`http://`), IP/hostname, and port. Example: `http://proxy.corp.example.com:3128`. Required if `enable_proxy` is true.                                                         |
| `rke2_proxy.https_proxy`  | "http://192.168.1.1:8080"                             | string  | HTTP proxy address for secure connections (HTTPS traffic). Often the same as `http_proxy` for simplicity. Note: Despite HTTPS traffic, the proxy URL itself typically uses `http://`. Required if `enable_proxy` is true.                                          |
| `rke2_proxy.no_proxy`     | "127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16" | string  | Comma-separated list of IP ranges/CIDRs, domains, or hostnames excluded from proxying. Default covers private networks (RFC 1918) and loopback. Add cluster-internal domains/IPs (e.g., `.svc,.cluster.local`) to avoid proxy use for internal Kubernetes traffic. |

## Variable Files (`vars/main.yml`)

**Warning:** These variable designed not to manually modify. Otherwise, the ansible may run in to an error state.

### Common Configuration

| Variable                 | Default                 | Type   | Description                                                                                                                                                                                   |
| ------------------------ | ----------------------- | ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `rke2_common.config_dir` | "/etc/rancher/rke2"     | string | Base directory where RKE2 configuration files are stored. Contains: config.yaml, credentials, etc. Changing this requires updating all corresponding paths in RKE2 configurations.            |
| `rke2_common.data_dir`   | "/var/lib/rancher/rke2" | string | Directory where RKE2 stores its runtime data including: databases, containers, and other persistent state. Ensure this is on a disk with sufficient space (recommended 50GB+ for production). |
| `haproxy_ports`          | [6443, 9345]            | list   | SELinux: List of ports HAProxy actively listens on to adjust SELinux. Typically includes API (6443) and registration (9345) ports. Ensure network accessibility.                              |
