var promBundle = require('express-prom-bundle');
var promClient = promBundle.promClient;

exports.initCounterImpl = function (name, desc, labels) {
  return function () {
    return new promClient.Counter({
      name: name,
      help: desc,
      labelNames: labels
    });
  };
};

exports.incrementCounterImpl = function (counter, labels) {
  return function () {
    return counter.inc(labels);
  };
};

exports.addLabelsImpl = function (histogram, labels) {
  return function () {
    return histogram.set(labels);
  };
};

exports.initHistogramImpl = function (name, desc, labels, bucket_start, bucket_end, factor) {
  return function () {
    return new promClient.Histogram({
      name: name,
      help: desc,
      labelNames: labels,
      buckets: promClient.exponentialBuckets(bucket_start, factor, bucket_end)
    });
  };
};

exports.startTimerImpl = function (histogram, labels) {
  return function () {
    return histogram.startTimer(labels);
  };
};


exports.endTimerImpl = function (histogram, labels, execTimer) {
  return function () {
    execTimer(labels);
    return {};
  };
};

exports.emptyTimer = function () { return {}; };

exports.promClusterMetrics = promBundle.clusterMetrics();