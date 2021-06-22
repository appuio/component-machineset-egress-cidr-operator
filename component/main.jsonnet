// main template for machineset-egress-cidr-operator
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.machineset_egress_cidr_operator;

local namespace = kube.Namespace(params.namespace);

local serviceAccount = kube.ServiceAccount('machineset-egress-cidr-operator') {
  metadata+: {
    // namespace is required here for kube-libjsonnet to do its rolebinding-magic
    namespace: params.namespace,
  },
};

local clusterRole = kube.ClusterRole('machineset-egress-cidr-operator') {
  rules: params.cluster_role_rules,
};

local clusterRoleBinding = kube.ClusterRoleBinding('machineset-egress-cidr-operators') {
  subjects_: [ serviceAccount ],
  roleRef_: clusterRole,
};

local roleBindnig = kube.RoleBinding('machineset-egress-cidr-operators') {
  subjects_: [ serviceAccount ],
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'Role',
    name: 'leader-election-role',
  },
};

local deployment = kube.Deployment('machineset-egress-cidr-operators') {
  spec+: {
    replicas: 1,
    template+: {
      spec+: {
        serviceAccount: serviceAccount.metadata.name,
        containers_+: {
          operator: kube.Container('operator') {
            image: params.images.operator.image + ':' + params.images.operator.tag,
            resources: params.resources,
          },
        },
      },
    },
  },
};

local labels = {
  metadata+: {
    labels+: params.labels,
  },
};

// Define outputs below
local rbac = [ serviceAccount, clusterRole, clusterRoleBinding, roleBindnig ];
{
  '00_namespace': namespace + labels,
  '10_rbac': [ r + labels for r in rbac ],
  '20_deployment': deployment + labels,
}
