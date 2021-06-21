local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.machineset_egress_cidr_operator;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('machineset-egress-cidr-operator', params.namespace);

{
  'machineset-egress-cidr-operator': app,
}
