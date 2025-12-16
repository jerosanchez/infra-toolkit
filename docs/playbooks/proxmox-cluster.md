# Proxmox Cluster Playbook

Setting up a Proxmox cluster enables you to manage multiple nodes as a single, unified environment. This playbook provides clear, step-by-step instructions to help you build a reliable and scalable cluster.

---

## Requirements

Before you start, ensure you have:

- At least two Proxmox nodes, fully installed and updated (see the [single node playbook](./proxmox-node.md))
- Static IPs assigned to each node
- Reliable wired network connectivity between all nodes
- Hostnames set (FQDN recommended, e.g., `pve1.jerosanchez.com`, `pve2.jerosanchez.com`)
- SSH access to each node
- A main node chosen to initiate the cluster (usually the first one you set up)

---

## Cluster Initialization: The First Node

On your main node, log in via the Proxmox web UI. Navigate to **Datacenter > Cluster** and click **Create Cluster**. Assign a name to your cluster and confirm the network settings—ensure your management interface and IP are correct.

Click **Create**. Once the cluster is created, click the **Join Information** button to copy the join information needed for other nodes to join the cluster.

---

## Joining Additional Nodes

On each additional node, in the Proxmox web UI, go to **Datacenter > Cluster** and click **Join Cluster**. Paste the join information from your main node, enter the root password of the main node, and confirm.

Once joined, your nodes will appear in the cluster view. You can now manage VMs, containers, and storage across all nodes from a single interface.

**Note:** After joining, the node may lose connection in the browser. Refresh the page and log in again to see the updated cluster status.

---

## Post-Cluster Checks

- **Test migration:** Move a VM or container from one node to another to verify cluster functionality.
- **Check quorum:** Ensure all nodes are online and the cluster status is healthy.
- **Update hosts files:** On each node, add entries for all cluster members to `/etc/hosts` for easier management.
- **Review storage:** Decide if you want shared storage (NFS, Ceph, etc.) or keep storage local.

---

## Troubleshooting & Tips

- If a node fails to join, check network connectivity and firewall/network settings.
- Ensure time is synchronized across all nodes (use NTP).
- For advanced setups, review fencing, HA, and shared storage options in the [Proxmox documentation](https://pve.proxmox.com/wiki/Main_Page).

---

With your cluster operational, you are ready to scale and manage your infrastructure efficiently. Add nodes as needed and take advantage of the flexibility and resilience that clustering provides.
