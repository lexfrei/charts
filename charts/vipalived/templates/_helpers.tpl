{{/*
Expand the name of the chart.
*/}}
{{- define "vipalived.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vipalived.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vipalived.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vipalived.labels" -}}
helm.sh/chart: {{ include "vipalived.chart" . }}
{{ include "vipalived.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: control-plane
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vipalived.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vipalived.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate keepalived.conf content
This helper is used by both ConfigMap (for DaemonSet) and Pod (for static pod mode)
*/}}
{{- define "vipalived.keepalivedConfig" -}}
global_defs {
  router_id {{ .Values.keepalived.routerId }}
  vrrp_version {{ .Values.keepalived.vrrpVersion }}
  vrrp_garp_master_delay {{ .Values.keepalived.garp.masterDelay }}
  vrrp_garp_master_refresh {{ .Values.keepalived.garp.masterRefresh }}
  vrrp_garp_master_repeat {{ .Values.keepalived.garp.masterRepeat }}
  vrrp_garp_master_refresh_repeat {{ .Values.keepalived.garp.masterRefreshRepeat }}
}

vrrp_instance {{ .Values.keepalived.vrrpInstance.name }} {
  state {{ .Values.keepalived.vrrpInstance.state }}
  interface {{ .Values.keepalived.vrrpInstance.interface }}
  virtual_router_id {{ .Values.keepalived.vrrpInstance.virtualRouterId }}
  priority {{ .Values.keepalived.vrrpInstance.priority }}
  advert_int {{ .Values.keepalived.vrrpInstance.advertInt }}
  {{- if .Values.keepalived.vrrpInstance.nopreempt }}
  nopreempt
  {{- end }}
  authentication {
    auth_type {{ .Values.keepalived.vrrpInstance.authentication.authType }}
    auth_pass {{ .Values.keepalived.vrrpInstance.authentication.authPass }}
  }
  virtual_ipaddress {
    {{ .Values.keepalived.vrrpInstance.virtualIpAddress }}
  }
  {{- if .Values.keepalived.vrrpInstance.trackInterface }}
  track_interface {
    {{- range .Values.keepalived.vrrpInstance.trackInterface }}
    {{ . }}
    {{- end }}
  }
  {{- end }}
}
{{- end }}
