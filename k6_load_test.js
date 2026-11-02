import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

// Custom Prometheus & Grafana compatible metrics
const failedRequests = new Rate('edupulse_failed_requests');
const feedDuration = new Trend('edupulse_feed_duration_ms', true);
const cursorFeedDuration = new Trend('edupulse_cursor_feed_duration_ms', true);
const eventsDuration = new Trend('edupulse_events_duration_ms', true);
const reelsDuration = new Trend('edupulse_reels_duration_ms', true);
const authDuration = new Trend('edupulse_auth_duration_ms', true);
const statsDuration = new Trend('edupulse_stats_duration_ms', true);
const totalTransactions = new Counter('edupulse_total_transactions');

// Concurrency Load Test Stages (Simulating Realistic Peak College Traffic)
export const options = {
    stages: [
        { duration: '10s', target: 10 }, // Ramp-up: 10 Concurrent Virtual Users
        { duration: '20s', target: 30 }, // Peak Concurrency: 30 Concurrent Virtual Users
        { duration: '15s', target: 50 }, // Stress Spike: 50 Concurrent Virtual Users
        { duration: '10s', target: 0 },  // Cool-down: Ramp down to 0 VUs
    ],
    thresholds: {
        http_req_failed: ['rate<0.02'],         // Error rate below 2%
        http_req_duration: ['p(95)<3000'],      // 95% of requests completed under 3.0s
        'edupulse_failed_requests': ['rate<0.02'],
    },
};

const BASE_URL = 'http://localhost:8081';

export default function () {
    // Scenario 1: Browse Campus Events Hub
    group('01_Browse_Events', function () {
        const res = http.get(`${BASE_URL}/api/events/all`, {
            headers: { 'Accept': 'application/json' },
            tags: { name: 'GetAllEvents' }
        });
        const success = check(res, {
            'events status is 200': (r) => r.status === 200,
            'events response is array': (r) => {
                try {
                    return Array.isArray(JSON.parse(r.body));
                } catch (e) {
                    return false;
                }
            },
        });
        failedRequests.add(!success);
        eventsDuration.add(res.timings.duration);
        totalTransactions.add(1);
    });

    sleep(0.2);

    // Scenario 2: Search Specific Events
    group('02_Search_Events', function () {
        const res = http.get(`${BASE_URL}/api/events/search?query=Hackathon`, {
            headers: { 'Accept': 'application/json' },
            tags: { name: 'SearchEvents' }
        });
        const success = check(res, {
            'search status is 200': (r) => r.status === 200,
        });
        failedRequests.add(!success);
        totalTransactions.add(1);
    });

    sleep(0.2);

    // Scenario 3: Browse Public College Feed (Cached L1 / Redis)
    group('03_Browse_College_Feed', function () {
        const res = http.get(`${BASE_URL}/api/posts/college-feed?collegeId=1`, {
            headers: { 'Accept': 'application/json' },
            tags: { name: 'GetCollegeFeed' }
        });
        const success = check(res, {
            'feed status is 200': (r) => r.status === 200,
            'feed has posts': (r) => {
                try {
                    return Array.isArray(JSON.parse(r.body));
                } catch (e) {
                    return false;
                }
            }
        });
        failedRequests.add(!success);
        feedDuration.add(res.timings.duration);
        totalTransactions.add(1);
    });

    sleep(0.2);

    // Scenario 4: Query Live Post Social Stats (Cached Running Counters)
    group('04_Social_Interaction_Stats', function () {
        const res = http.get(`${BASE_URL}/api/social/posts/1/stats`, {
            headers: { 'Accept': 'application/json' },
            tags: { name: 'GetSocialStats' }
        });
        const success = check(res, {
            'social stats status is 200': (r) => r.status === 200,
        });
        failedRequests.add(!success);
        statsDuration.add(res.timings.duration);
        totalTransactions.add(1);
    });

    sleep(0.2);

    // Scenario 5: User Notification Feed
    group('05_Notification_Feed', function () {
        const res = http.get(`${BASE_URL}/api/notifications/user/84`, {
            headers: { 'Accept': 'application/json' },
            tags: { name: 'GetNotifications' }
        });
        const success = check(res, {
            'notifications status is 200': (r) => r.status === 200,
        });
        failedRequests.add(!success);
        totalTransactions.add(1);
    });

    sleep(0.2);

    // Scenario 6: Browse Campus Reels & Video Feed (Cached L1 / Redis)
    group('06_Browse_Event_Reels', function () {
        const res = http.get(`${BASE_URL}/api/reels/all?collegeId=1`, {
            headers: { 'Accept': 'application/json' },
            tags: { name: 'GetEventReels' }
        });
        const success = check(res, {
            'reels status is 200': (r) => r.status === 200,
        });
        failedRequests.add(!success);
        reelsDuration.add(res.timings.duration);
        totalTransactions.add(1);
    });

    sleep(0.2);

    // Scenario 7: Instagram Infinite-Scroll Cursor Pagination
    group('07_Infinite_Scroll_Cursor', function () {
        const res = http.get(`${BASE_URL}/api/posts/college-feed?collegeId=1&cursor=10`, {
            headers: { 'Accept': 'application/json' },
            tags: { name: 'GetCursorFeed' }
        });
        const success = check(res, {
            'cursor feed status is 200': (r) => r.status === 200,
        });
        failedRequests.add(!success);
        cursorFeedDuration.add(res.timings.duration);
        totalTransactions.add(1);
    });

    sleep(0.2);

    // Scenario 8: Concurrent Authentication Check
    group('08_Authentication_Login', function () {
        const payload = JSON.stringify({
            identifier: 'manukondach@gmail.com',
            password: 'password123'
        });
        const params = {
            headers: { 'Content-Type': 'application/json' },
            tags: { name: 'PostAuthLogin' }
        };
        const res = http.post(`${BASE_URL}/api/auth/login`, payload, params);
        const success = check(res, {
            'auth status is 200': (r) => r.status === 200,
            'auth message is successful': (r) => {
                try {
                    return JSON.parse(r.body).status === 'SUCCESS';
                } catch (e) {
                    return false;
                }
            }
        });
        failedRequests.add(!success);
        authDuration.add(res.timings.duration);
        totalTransactions.add(1);
    });

    sleep(0.4);
}