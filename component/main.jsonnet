// main template for machineset-egress-cidr-operator
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.machineset_egress_cidr_operator;

// Define outputs below
{
}
