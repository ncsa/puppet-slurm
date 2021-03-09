# @summary Manage users needed for Slurm.
#
# TODO - See high performance tweaks at:
# https://computing.llnl.gov/linux/slurm/high_throughput.html
# sampled from:
# https://github.com/cernops/puppet-slurm/blob/master/manifests/config.pp
#
# @param [Integer] slurm_gid GID of the slurm user (for slurmctld/slurmdbd).
# @param [Integer] slurm_uid UID of the slurm user (for slurmctld/slurmdbd).

class slurm::users (
    Integer $slurm_gid,
    Integer $slurm_uid,
) {

    # Create slurm group/user on slurmctld and slurmdbd host(s).
    # Would like to limit slurm user/group to slurmctld/slurmdbd but
    # cannot. Even submit nodes complain about lack of slurm user:
    #     sinfo: error: Invalid user for SlurmUser slurm, ignored
    #     sinfo: fatal: Unable to process configuration file

    group{'slurm':
        ensure => present,
        gid    => $slurm::users::slurm_gid,
    }
    user{ 'slurm':
        ensure => present,
        uid    => $slurm::users::slurm_uid,
        gid    => 'slurm',
        shell  => '/bin/false',
        home   => '/home/slurm',
    }
}
