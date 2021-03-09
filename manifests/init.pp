# @summary Install and manage Slurm.
# TODO - rewrite this as a more comprehensive module, 
#        once slurm is understood in more detail
#   Examples:
#   1. https://github.com/cernops/puppet-slurm
#   2. https://forge.puppet.com/chwilk/slurm
# However, both of the above examples appear to make assumptions that aren't valid
# for our site.
# Also, example #2 appears to apply to compute nodes only, while example #1
# provides separate parts for master, compute and database nodes.

# @param [String] ctld_host Hostname of node running slurmctld.
# @param [Boolean] is_ctld_host Is the node the slurmctld host?
# @param [Boolean] is_dbd_host Is the node the slurmdbd host?
# @param [Boolean] is_submit_host Is the node a slurm submit host?
# @param [Boolean] is_worker_node Is the node a slurm worker (slurmd) node?
# @param [Array[String]] submit_hosts Hostname(s) of node(s) from where jobs will be submitted.
# @param [Array[String]] worker_networks Network CIDRs for worker (slurmd) nodes.

# @example
#     include ::slurm
class slurm (
    String        $ctld_host,
    Boolean       $is_ctld_host,
    Boolean       $is_dbd_host,
    Boolean       $is_submit_host,
    Boolean       $is_worker_node,
    Array[String] $submit_hosts,
    Array[String] $worker_networks,
) {

    include slurm::users
    include slurm::install
    include slurm::firewall
    include slurm::config
    include slurm::service

}
