# security-profiles-operator

A Giant Swarm App for security-profiles-operator, managing Seccomp, AppArmor, and SELinux profiles for Kubernetes workloads.

**Homepage:** <https://github.com/giantswarm/security-profiles-operator-app>

## Source Code

* <https://github.com/kubernetes-sigs/security-profiles-operator>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
|  | security-profiles-operator | 1.1.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kyvernoPolicyExceptions.enabled | bool | `true` |  |
| kyvernoPolicyExceptions.namespace | string | `"giantswarm"` |  |
| kyvernoPolicyExceptions.legacy.enabled | bool | `true` | Render the kyverno.io/v2 PolicyException, which only applies to ClusterPolicies. Turn it off once the cluster runs the CEL policies. |
| kyvernoPolicyExceptions.cel.enabled | bool | `true` | Render the policies.kyverno.io/v1 PolicyException, which only applies to CEL policies (ValidatingPolicy). |
| security-profiles-operator | object | See [values.yaml](./values.yaml#L17) | Values passed through to the upstream chart. For available options, see the [upstream values.yaml](https://github.com/kubernetes-sigs/security-profiles-operator/blob/v1.1.2/deploy/helm/values.yaml). |
