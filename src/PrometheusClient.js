/*
 Copyright (c) 2012-2017 "JUSPAY Technologies"
 JUSPAY Technologies Pvt. Ltd. [https://www.juspay.in]
 This file is part of JUSPAY Platform.
 JUSPAY Platform is free software: you can redistribute it and/or modify
 it for only educational purposes under the terms of the GNU Affero General
 Public License (GNU AGPL) as published by the Free Software Foundation,
 either version 3 of the License, or (at your option) any later version.
 For Enterprise/Commerical licenses, contact <info@juspay.in>.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  The end user will
 be liable for all damages without limitation, which is caused by the
 ABUSE of the LICENSED SOFTWARE and shall INDEMNIFY JUSPAY for such
 damages, claims, cost, including reasonable attorney fee claimed on Juspay.
 The end user has NO right to claim any indemnification based on its use
 of Licensed Software. See the GNU Affero General Public License for more details.
 You should have received a copy of the GNU Affero General Public License
 along with this program. If not, see <https://www.gnu.org/licenses/agpl.html>.
*/

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


exports.initGaugeImpl = function (name, desc, labels) {
  return function () {
    return new promClient.Gauge({
      name: name,
      help: desc,
      labelNames: labels
    });
  };
};

exports.setGaugeImpl = function (gauge, labels, value) {
  return function () {
    return gauge.set(labels, value);
  };
};

exports.promClusterMetrics = promBundle.clusterMetrics();
