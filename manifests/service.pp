# @summary:
class slurm::service (

    String $slurmd_service_name,

) {

    # Only worker nodes need to start the slurm daemons.
    if $slurm::is_worker_node {
        service { $slurmd_service_name :
            ensure     => running,
            hasstatus  => true,
            hasrestart => true,
            enable     => false, # Puppet (not systemd) should start slurmd
            require    => Class['slurm::config'];
        }
    }

    # NOTE: The slurmctld/slurmdbd daemons/services are tricky and
    #       we need to be careful when we update Slurm configs and/or
    #       update Slurm RPMs. The interactions with GPFS, between daemons,
    #       during schema updates, etc. make it too risky (in Jake's opinion)
    #       to have Puppet start these services. As a result, we will NOT
    #       start them at boot or via Slurm. They should be started manually,
    #       first slurmdbd, then slurmctld.
    #
    #       For a bit more info, see ::slurm::config and ::slurm::install .

    # Only slurmctld hosts should have slurmctld
    if $slurm::is_ctld_host {
        service { 'slurmctld':
            enable  => false, # Puppet (not systemd) should start slurmctld
            require => Class['slurm::config'];
        }
    }

    # Only slurmdbd hosts should have slurmdbd
    if $slurm::is_dbd_host {
        service { 'slurmdbd':
            enable  => false, # Puppet (not systemd) should start slurmdbd
            require => Class['slurm::config'];
        }
    }

}
