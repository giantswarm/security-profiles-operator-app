import logging
import os
import subprocess
from typing import Dict, List

import pykube
import pytest
from pytest_helm_charts.clusters import Cluster
from pytest_helm_charts.k8s.deployment import wait_for_deployments_to_run

logger = logging.getLogger(__name__)

namespace_name = "default"

timeout: int = 360

CERT_MANAGER_VERSION = "v1.19.4"


# The operator needs cert-manager, which ATS cannot install before the chart,
# so .ats/main.yaml sets `app-tests-skip-app-deploy` and this fixture installs
# cert-manager and then the chart under test.
@pytest.fixture(scope="module")
def chart_deployed(kube_cluster: Cluster, chart_path: str) -> None:
    kube_cluster.kubectl(
        "apply",
        filename=f"https://github.com/cert-manager/cert-manager/releases/download/{CERT_MANAGER_VERSION}/cert-manager.yaml",
        output_format="",
    )
    wait_for_deployments_to_run(
        kube_cluster.kube_client,
        ["cert-manager", "cert-manager-cainjector", "cert-manager-webhook"],
        "cert-manager",
        timeout,
    )
    # ATS creates this namespace only when it deploys the chart itself.
    ns = pykube.Namespace(kube_cluster.kube_client, {"metadata": {"name": "policy-exceptions"}})
    if not ns.exists():
        ns.create()
    subprocess.run(
        [
            "helm", "upgrade", "--install", "security-profiles-operator", chart_path,
            "--namespace", namespace_name, "--wait", "--timeout", "5m",
            "--values", os.path.join(os.path.dirname(os.path.abspath(__file__)), "values.yaml"),
        ],
        check=True,
    )


@pytest.mark.smoke
def test_api_working(kube_cluster: Cluster) -> None:
    """Very minimalistic example of using the [kube_cluster](pytest_helm_charts.fixtures.kube_cluster)
    fixture to get an instance of [Cluster](pytest_helm_charts.clusters.Cluster) under test
    and access its [kube_client](pytest_helm_charts.clusters.Cluster.kube_client) property
    to get access to Kubernetes API of cluster under test.
    Please refer to [pykube](https://pykube.readthedocs.io/en/latest/api/pykube.html) to get docs
    for [HTTPClient](https://pykube.readthedocs.io/en/latest/api/pykube.html#pykube.http.HTTPClient).
    """
    assert kube_cluster.kube_client is not None
    assert len(pykube.Node.objects(kube_cluster.kube_client)) >= 1


@pytest.mark.smoke
def test_cluster_info(
    kube_cluster: Cluster, cluster_type: str, test_extra_info: Dict[str, str]
) -> None:
    """Example shows how you can access additional information about the cluster the tests are running on"""
    logger.info(f"Running on cluster type {cluster_type}")
    key = "external_cluster_type"
    if key in test_extra_info:
        logger.info(f"{key} is {test_extra_info[key]}")
    assert kube_cluster.kube_client is not None
    assert cluster_type != ""


# scope "module" means this is run only once, for the first test case requesting! It might be tricky
# if you want to assert this multiple times
@pytest.fixture(scope="module")
def app_deployment(kube_cluster: Cluster, chart_deployed: None) -> List[pykube.Deployment]:
    deployments = wait_for_deployments_to_run(
        kube_cluster.kube_client,
        ["security-profiles-operator"],
        namespace_name,
        timeout,
    )
    return deployments


# when we start the tests on circleci, we have to wait for pods to be available, hence
# this additional delay and retries
@pytest.mark.smoke
@pytest.mark.upgrade
@pytest.mark.flaky(reruns=3, reruns_delay=10)
def test_pods_available(kube_cluster: Cluster, app_deployment: List[pykube.Deployment]):
    for d in app_deployment:
        assert int(d.obj["status"]["readyReplicas"]) > 0
