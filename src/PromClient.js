var promBundle = require('express-prom-bundle');
var promClient = promBundle.promClient;

exports["initCounter'"] = function (name, desc, labels) {
	return function () {
		return new promClient.Counter({
			name: name,
			help: desc,
			labelNames: labels
		});
	};
};

exports["incrementCounter'"] = function (counter, labels) {
  return function () {
    return counter.inc(labels);
  };
};

exports.promMetricsHandler = promBundle({
  httpDurationMetricName: 'euler_http_request_duration',
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, 20, 30],
  includeMethod: true,
  includePath: true,
  autoRegister: false,
  customLabels: {
    host: null,
    instance: null,
    pid: null,
    merchant_id: null
  },
  transformLabels: function (labels) {
    var _a = arguments[1] || {};
    return Object.assign(labels, {
      pid: process.pid,
      instance: os.hostname(),
      host: _a.hostname,
      merchant_id: _a.body.merchantId || _a.body.merchant_id || _a.params.merchantId
        || _a.params.merchant_id || _a.query.merchantId || _a.query.merchant_id
        || _a.userData.merchantId || _a.userData.merchant_id || null
    });
  },
  promClient: {
    collectDefaultMetrics: {
      timeout: 1000
    }
  },
  urlValueParser: {
    minHexLength: 5,
    extraMasks: [
      "^[0-9]+\\.[0-9]+\\.[0-9]+$" // replace dot-separated dates with #val
    ]
  },
  normalizePath: [
    ['\\?(.*)', '']
  ]
});

exports.promClusterMetrics = promBundle.clusterMetrics(); 