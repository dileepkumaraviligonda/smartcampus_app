const fs = require('fs');
const path = require('path');

// Defensive metric extractor helper supporting both flat and nested k6 schema models
function getMetricValue(metricObj, key, defaultValue = 0) {
  if (!metricObj) return defaultValue;
  if (metricObj.values && metricObj.values[key] !== undefined) {
    return metricObj.values[key];
  }
  if (metricObj[key] !== undefined) {
    return metricObj[key];
  }
  return defaultValue;
}

function parseK6Summary() {
  const summaryPath = path.join(process.cwd(), 'summary.json');
  if (!fs.existsSync(summaryPath)) {
    console.error(`Error: summary.json not found at ${summaryPath}`);
    process.exit(1);
  }

  const rawData = fs.readFileSync(summaryPath, 'utf8');
  let data;
  try {
    data = JSON.parse(rawData);
  } catch (e) {
    console.error(`Error parsing summary.json: ${e.message}`);
    process.exit(1);
  }

  const metrics = data.metrics || {};
  
  // Extract Throughput & Requests
  const httpReqs = metrics.http_reqs || {};
  const totalRequests = getMetricValue(httpReqs, 'count', 0);
  const rps = getMetricValue(httpReqs, 'rate', 0);

  // Extract Response Times (Durations)
  const reqDuration = metrics.http_req_duration || {};
  const avgResponseTime = getMetricValue(reqDuration, 'avg', 0);
  const minResponseTime = getMetricValue(reqDuration, 'min', 0);
  const maxResponseTime = getMetricValue(reqDuration, 'max', 0);
  const p95ResponseTime = getMetricValue(reqDuration, 'p(95)', 0);

  // Extract Failures & Checks
  const reqFailed = metrics.http_req_failed || {};
  const failureRate = (getMetricValue(reqFailed, 'rate', 0) * 100).toFixed(2);

  const checks = metrics.checks || {};
  const passRate = (getMetricValue(checks, 'rate', 1) * 100).toFixed(2);

  const failureNum = parseFloat(failureRate);
  const passNum = parseFloat(passRate);
  const failureStatus = failureNum < 5.00 ? '🟢 PASS' : '🔴 FAIL';
  const checksStatus = passNum > 95.00 ? '🟢 PASS' : '🔴 FAIL';
  const p95Status = p95ResponseTime < 1500 ? '🟢 PASS' : '🔴 FAIL';
  const avgStatus = avgResponseTime < 500 ? '🟢 PASS' : '🔴 FAIL';
  const maxStatus = maxResponseTime < 3000 ? '🟢 PASS' : '🔴 FAIL';

  // Format Markdown Executive Summary
  const summaryMarkdown = `
# 📈 SmartCampus API Load Test Executive Summary

**Test Configuration:** 100 Virtual Users (VUs) | Duration: 1 Minute Baseline

| Metric | Measured Value | Threshold / Target | Status |
| :--- | :--- | :--- | :--- |
| **Throughput (RPS)** | \`${rps.toFixed(2)} req/sec\` | Baseline Target | 🟢 PASS |
| **Total Requests Sent** | \`${totalRequests}\` | N/A | ℹ️ INFO |
| **Avg Response Time** | \`${avgResponseTime.toFixed(2)}ms\` | < 500ms | ${avgStatus} |
| **Min Response Time** | \`${minResponseTime.toFixed(2)}ms\` | N/A | ℹ️ INFO |
| **Max Response Time** | \`${maxResponseTime.toFixed(2)}ms\` | < 3000ms | ${maxStatus} |
| **p95 Response Time** | \`${p95ResponseTime.toFixed(2)}ms\` | < 1500ms | ${p95Status} |
| **Request Failure Rate** | \`${failureRate}%\` | < 5.00% | ${failureStatus} |
| **Checks Pass Rate** | \`${passRate}%\` | > 95.00% | ${checksStatus} |

---

### Response Time Breakdown:
- **Fastest Response:** \`${minResponseTime.toFixed(2)}ms\`
- **Average Latency:** \`${avgResponseTime.toFixed(2)}ms\`
- **95th Percentile:** \`${p95ResponseTime.toFixed(2)}ms\`
- **Slowest Response:** \`${maxResponseTime.toFixed(2)}ms\`
`;

  console.log(summaryMarkdown);

  // Write to GITHUB_STEP_SUMMARY if env var present
  const stepSummaryFile = process.env.GITHUB_STEP_SUMMARY;
  if (stepSummaryFile) {
    fs.appendFileSync(stepSummaryFile, summaryMarkdown);
    console.log(`Summary written to GITHUB_STEP_SUMMARY file: ${stepSummaryFile}`);
  }
}

parseK6Summary();
