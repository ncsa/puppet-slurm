# @summary Install Slurm.
#
# @param [String] yum_url URL for Slurm Yum repo.
# @param [String] version Slurm version
#                 as returned by: rpm -q slurm --qf '%{NAME}-%{VERSION}'
#                 For example: 20.11.2-2.el7
# @param [Array[String]] pkgs_core Core RPMs for Slurm.
# @param [Array[String]] pkgs_deps RPMs that are dependencies for Slurm.
# @param [Array[String]] pkgs_pam RPMs needed for slurm_pam_adopt support.
# @param [Array[String]] pkgs_worker RPMs needed only on worker nodes.
class slurm::install (

    # NOTE: When updating Slurm
    #       1) It is important to update the node
    #       with slurmdbd first, then the node with slurmctld (if
    #       different), then the slurmd nodes.
    #       2) Slurm services on any nodes should be stopped when the
    #          RPMs are updated.
    #       3) After updating the node with slurmdbd, start slurmdbd
    #          interactively+verbosely to check for errors and allow for
    #          DB schema updates (slurmdbd -D -vvvvv). After it looks
    #          good, ^D slurmdbd and start it as service.
    #       4) Then do the same with slurmctld.

    # Define parameters
    Array[String] $pkgs_core,
    Array[String] $pkgs_deps,
    Array[String] $pkgs_pam,
    Array[String] $pkgs_slurmctld,
    Array[String] $pkgs_slurmdbd,
    Array[String] $pkgs_submit,
    Array[String] $pkgs_worker,
    String        $yumurl,
    String        $version,
) {

    # add Yum repo configuration
    yumrepo { 'slurm':
        name     => slurm,
        descr    => 'Slurm Repository',
        enabled  => 1,
        baseurl  => $yumurl,
        gpgcheck => 0,
    }

    # Force slurm to this version
    $version_parts = $version.split( /-/ )
    yum::versionlock { 'slurm':
      ensure  => present,
      version => $version_parts[0],
      release => $version_parts[1],
      epoch   => 0,
      arch    =>  'x86_64',
    }

    # define default attributes for the underlying ensure_resource / package statements
    $ensure_packages_defaults = {'require' => 'Yumrepo[slurm]'}

    # install required packages
    ensure_packages( $pkgs_deps, $ensure_packages_defaults )
    ensure_packages( $pkgs_core, $ensure_packages_defaults )

    # Only worker nodes need these packages.
    if $slurm::is_worker_node {
        ensure_packages( $pkgs_worker, $ensure_packages_defaults )
        ensure_packages( $pkgs_pam, $ensure_packages_defaults)
    }

    # Only the slurmctld host needs these packages.
    if $slurm::is_ctld_host {
        ensure_packages( $pkgs_slurmctld, $ensure_packages_defaults )
    }

    # Only the slurmdbd host needs these packages.
    if $slurm::is_dbd_host {
        ensure_packages( $pkgs_slurmdbd, $ensure_packages_defaults )
    }

    # Only submit hosts need these packages.
    if $slurm::is_submit_host {
        ensure_packages( $pkgs_submit, $ensure_packages_defaults )
    }

}
