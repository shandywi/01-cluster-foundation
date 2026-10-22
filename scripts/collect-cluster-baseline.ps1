[CmdletBinding()]
param(
    [string]$OutputDirectory = "artifacts"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    throw "kubectl was not found in PATH. Install it and configure access before collecting a baseline."
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$destination = Join-Path $OutputDirectory "baseline-$timestamp.md"
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

function Get-Section {
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][scriptblock]$Command
    )

    "## $Title"
    '```text'
    $output = & $Command 2>&1 | Out-String
    # Defense in depth: never persist an IPv4 address in a diagnostic artifact.
    $output -replace '\b(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\b', '[REDACTED-IP]'
    '```'
    ''
}

@(
    "# K3s baseline snapshot ($timestamp)",
    "",
    "> Local diagnostic output. Review and redact it before committing anywhere.",
    "",
    (Get-Section "Current context" { kubectl config current-context }),
    (Get-Section "Kubernetes version" { kubectl version -o yaml }),
    (Get-Section "Nodes (IP addresses redacted)" { kubectl get nodes -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1:].type,K3S_VERSION:.status.nodeInfo.kubeletVersion,OS:.status.nodeInfo.osImage }),
    (Get-Section "Node utilization" { kubectl top nodes }),
    (Get-Section "Namespaces" { kubectl get namespaces }),
    (Get-Section "Storage classes" { kubectl get storageclass }),
    (Get-Section "System workloads (no IP addresses)" { kubectl -n kube-system get pods }),
    (Get-Section "Homelab guardrails" { kubectl -n homelab get resourcequota,limitrange,role })
) | Set-Content -Path $destination -Encoding utf8

Write-Host "Baseline snapshot written to $destination"
