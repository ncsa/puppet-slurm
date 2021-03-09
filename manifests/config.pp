# @summary Manage Slurm config file
#
# TODO - See high performance tweaks at:
# https://computing.llnl.gov/linux/slurm/high_throughput.html
# sampled from:
# https://github.com/cernops/puppet-slurm/blob/master/manifests/config.pp
#
# @param [String] munge_key
#     Contents of Munge key for the cluster.
# @param [Hash] nodes
#     NodeName defs for slurm.conf (key is PartitionName value; value is settings as String).
# @param [Hash] partitions
#     PartitionName defs for slurm.conf (key is PartitionName value; value is settings as String).
# @param [Hash] settings
#     General settings for slurm.conf.
class slurm::config(
    Hash   $cgroupsettings,
    Hash   $dbdsettings,
    String $munge_key,
    Hash   $nodes,
    Hash   $partitions,
    Hash   $settings,
) {

    file { '/etc/munge':
        ensure => directory,
        owner  => 'munge',
        group  => 'munge',
        mode   => '0700',
    }

    $munge_key_sensitive = Sensitive( $munge_key )
    file{ '/etc/munge/munge.key':
        ensure  => file,
        owner   => 'munge',
        group   => 'munge',
        mode    => '0400',
        content => $munge_key_sensitive,
        notify  => Service[ $slurm::service::munge_service_name ],
    }

    file { '/etc/slurm':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

#        content  => epp( "slurm/slurm.conf.epp", { 
#                            'settings' => hiera( 'slurm::config::settings' ),
#                            } ),

    $notifyslurmd = $is_worker_node ? {
        true    => { 'notify' => Service[ $slurm::service::slurmd_service_name ] },
        default => {},
    }

    # NOTE: we will not notify the slurmdbd/slurmctld services of changes
    #       to config files; that way we can perform config changes per best
    #       practices
    #           1. changes to mariadb and/or slurmdbd.conf should happen with
    #              slurmdbd and slurmctld stopped (first slurmctld, then
    #              slurmdbd; restart in opposite order)
    #           1. changes to slurm.conf should happen as follows:
    #              - stop slurmctld
    #              - run Puppet everywhere (i.e., on all slurmd/worker nodes
    #                and probably the slurmctld node) to update slurm.conf
    #                and restart slurmd (via notify)
    #              - run start slurmctld again
    #           2. changes to mariadb and/or slurmdbd.conf should happen with
    #              slurmdbd and slurmctld stopped (first stop slurmctld, then
    #              slurmdbd; make the config change; restart slurmdbd and
    #              then slurmctld; you may want to test the services interactive
    #              as described in ::slurm::install)

    file{ '/etc/slurm/slurm.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => epp( 'slurm/slurm.conf.epp' ),
        *       => $notifyslurmd,
    }

    if $slurm::is_ctld_host {
        $state_save_location = lookup('slurm::config::settings.StateSaveLocation')
        file{ $state_save_location:
            ensure => directory,
            owner  => 'slurm',
            group  => 'slurm',
            mode   => '0700',
        }
    }

    if $slurm::is_dbd_host {
        file{ '/etc/slurm/slurmdbd.conf':
            owner   => 'root',
            group   => 'slurm',
            mode    => '0440',
            content => epp( 'slurm/slurmdbd.conf.epp' ),
        }
    }

    if $slurm::is_worker_node {
        $slurmd_spool_dir = lookup('slurm::config::settings.SlurmdSpoolDir')
        file{ $slurmd_spool_dir:
            ensure => directory,
            owner  => 'root',
            group  => 'root',
            mode   => '0755',
        }
        file{ '/etc/slurm/cgroup.conf':
            owner   => 'root',
            group   => 'root',
            mode    => '0444',
            content => epp( 'slurm/cgroup.conf.epp' ),
            *       => $notifyslurmd,
        }
    }
}
