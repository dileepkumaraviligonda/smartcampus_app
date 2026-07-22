import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '10s', target: 50 },  # Ramp-up to 50 VUs
    { duration: '40s', target: 100 }, # Sustain 100 VUs for baseline load
    { duration: '10s', target: 0 },   # Ramp-down
  ],
  thresholds: {
    http_req_failed: ['rate<0.05'],    # Failure rate under 5%
    http_req_duration: ['p(95)<1500'], # 95% of requests must complete under 1.5s
  },
};

export default function () {
  const baseUrl = __ENV.BACKEND_URL || 'http://localhost:8080';
  
  // 1. Health check & landing page request
  const res1 = http.get(`${baseUrl}/`);
  check(res1, {
    'landing page status is 200': (r) => r.status === 200,
  });

  // 2. Simulate API health / auth status request
  const res2 = http.get(`${baseUrl}/version.json`, {
    headers: { 'Accept': 'application/json' },
  });
  check(res2, {
    'api status is 200 or 404': (r) => r.status === 200 || r.status === 404,
  });

  sleep(0.5);
}
