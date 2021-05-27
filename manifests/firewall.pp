# @summary Manage firewall settings for Slurm
class slurm::firewall {

    ### IPTABLES

    if $slurm::is_ctld_host {
        each($slurm::submit_hosts) | $host_index, $host_value | {
            firewall { "0300 slurmctld from submit host ${host_value}":
                dport  => '6817',
                proto  => tcp,
                action => accept,
                source => $host_value,
            }
        }
        each($slurm::worker_networks) | $network_index, $network_value | {
            firewall { "0300 slurmctld from slurmd hosts: ${network_value}":
                dport  => '6817',
                proto  => tcp,
                action => accept,
                source => $network_value,
            }
        }
    }

    if $slurm::is_dbd_host {
        firewall { "0300 slurmdbd from ctld_host ${slurm::ctld_host}":
            dport  => '6819',
            proto  => tcp,
            action => accept,
            source => $slurm::ctld_host,
        }
        each($slurm::submit_hosts) | $host_index, $host_value | {
            firewall { "0300 slurmdbd from submit host ${host_value}":
                dport  => '6819',
                proto  => tcp,
                action => accept,
                source => $host_value,
            }
        }
        each($slurm::worker_networks) | $network_index, $network_value | {
            firewall { "0300 slurmdbd from slurmd hosts: ${network_value}":
                dport  => '6819',
                proto  => tcp,
                action => accept,
                source => $network_value,
            }
        }
    }

    if $slurm::is_submit_host {
        each($slurm::worker_networks) | $network_index, $network_value | {
            firewall { "0303 slurm srun from slurmd nodes: ${network_value}":
                proto  => tcp,
                dport  => '60001-63000',
                action => accept,
                source => $network_value,
            }
        }
        firewall { "0304 slurm srun from ctld_host ${slurm::ctld_host}":
            dport  => '60001-63000',
            proto  => tcp,
            action => accept,
            source => $slurm::ctld_host,
        }
    }

    if $slurm::is_worker_node {
        firewall { "0300 slurmd from ctld_host ${slurm::ctld_host}":
            dport  => '6818',
            proto  => tcp,
            action => accept,
            source => $slurm::ctld_host,
        }
        each($slurm::submit_hosts) | $host_index, $host_value | {
            firewall { "0300 slurmd from submit_host ${host_value}":
                dport  => '6818',
                proto  => tcp,
                action => accept,
                source => $host_value,
            }
            firewall { "0300 slurm srun from submit_host ${host_value}":
                proto  => tcp,
                dport  => '60001-63000',
                action => accept,
                source => $host_value,
            }
        }
        each($slurm::worker_networks) | $network_index, $network_value | {
            firewall { "0303 slurm srun from slurmd nodes: ${network_value}":
                proto  => tcp,
                dport  => '60001-63000',
                action => accept,
                source => $network_value,
            }
            firewall { "0301 open TCP ports for MPI across slurm nodes: ${network_value}":
                dport  => '1024-65535',
                proto  => tcp,
                action => accept,
                source => $network_value,
            }
            firewall { "0302 open UDP ports for MPI across slurm nodes: ${network_value}":
                dport  => '1024-65535',
                proto  => udp,
                action => accept,
                source => $network_value,
            }
        }
    }

}
