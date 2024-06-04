{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cloudcore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cloudcore.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Generate certificates for kubeedge cloudstream server
*/}}
{{- define "cloudcore.gen-certs" -}}
{{- $CCaltNames := list ("cloudcore") ("apiserver.cluster.local") ( printf "%s.%s" (include "cloudcore.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "cloudcore.name" .) .Release.Namespace ) -}}
{{- $ECaltNames := list ("edgecore") ("apiserver.cluster.local") -}}
{{- $ca := genCA "KubeEdge" 3650 -}}
{{- $cc := genSignedCert "cloudcore" nil $CCaltNames 3650 $ca -}}
{{- $ec := genSignedCert "edgecore" nil $ECaltNames 3650 $ca -}}
rootCA.crt: {{ $ca.Cert | b64enc }}
rootCA.key: {{ $ca.Key | b64enc }}
cloudcore.crt: {{ $cc.Cert | b64enc }}
cloudcore.key: {{ $cc.Key | b64enc }}
edgecore.crt: {{ $ec.Cert | b64enc }}
edgecore.key: {{ $ec.Key | b64enc }}
{{- end -}}
