package integration

import (
	"testing"

	"github.com/SumoLogic/sumologic-kubernetes-collection/tests/integration/internal"
)

func Test_Helm_Default_OT(t *testing.T) {

	expectedMetrics := internal.DefaultExpectedMetrics
	installChecks := []featureCheck{
		CheckSumologicSecret(11),
		CheckOtelcolMetadataLogsInstall,
		CheckOtelcolMetadataMetricsInstall,
		CheckOtelcolEventsInstall,
		CheckPrometheusInstall,
		CheckOtelcolLogsCollectorInstall,
		CheckTracesInstall,
	}

	featInstall := GetInstallFeature(installChecks)

	featMetrics := GetMetricsFeature(expectedMetrics)

	featLogs := GetLogsFeature()

	featMultilineLogs := GetMultilineLogsFeature()

	featEvents := GetEventsFeature()

	featTraces := GetTracesFeature()

	testenv.Test(t, featInstall, featMetrics, featLogs, featMultilineLogs, featEvents, featTraces)
}
