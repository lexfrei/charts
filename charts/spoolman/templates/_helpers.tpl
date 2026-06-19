{{- define "spoolman.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "spoolman.fullname" -}}
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

{{- define "spoolman.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "spoolman.labels" -}}
helm.sh/chart: {{ include "spoolman.chart" . }}
{{ include "spoolman.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "spoolman.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spoolman.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "spoolman.basePath" -}}
{{- with .Values.spoolman.basePath | trimAll "/" }}
{{- printf "/%s" . }}
{{- end }}
{{- end }}

{{- define "spoolman.dbPort" -}}
{{- if .Values.database.port }}
{{- .Values.database.port }}
{{- else if eq .Values.database.type "postgres" }}5432
{{- else if eq .Values.database.type "mysql" }}3306
{{- else if eq .Values.database.type "cockroachdb" }}26257
{{- end }}
{{- end }}

{{- define "spoolman.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "spoolman.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
