local base = import "base.json";
local override = import "override.json";


local reformat_resources(obj) = 
	{
		requests: {
			cpu: obj.cpuReq,
			memory: obj.memReq,
		},
		limits: {
			cpu: obj.cpuLimit,
			memory: obj.memLimit,
		},
	}
	;

local override_values(cluster, container) = 
	if std.objectHas(override, container) then
		if std.objectHas(override[container], cluster) then
			{ [cluster]+: { [container]+: { resources: reformat_resources(override[container][cluster]) } }  }
		else
			{ [cluster]+: { [container]+: { resources: reformat_resources(override[container]["default"]) } } }
	else
		{}
	;

local override_cluster_values(cluster) =
	[ override_values(cluster, container) for container in std.objectFields(base[cluster]) ]
	;

local overrides = std.flattenArrays([ override_cluster_values(cluster) for cluster in std.objectFields(base) ]);

local result = std.foldl(function(root, merge) root + merge, overrides, base);

result
# + overrides[0]
# + overrides[1]
# + overrides[2]
# + overrides[3]
# base
# + override
