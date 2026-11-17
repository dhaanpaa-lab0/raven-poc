// Sample document data. Runs via mongosh on first start of the mongo container.
db = db.getSiblingDB('eval');
db.events.insertMany([
  { type: 'login',    user: 'alice', ts: new Date('2026-11-01T09:00:00Z'), payload: { ip: '10.0.0.1' } },
  { type: 'purchase', user: 'alice', ts: new Date('2026-11-01T09:05:00Z'), payload: { sku: 'A-100', qty: 2 } },
  { type: 'login',    user: 'bob',   ts: new Date('2026-11-02T10:00:00Z'), payload: { ip: '10.0.0.2' } },
  { type: 'purchase', user: 'bob',   ts: new Date('2026-11-02T10:12:00Z'), payload: { sku: 'B-200', qty: 1 } },
  { type: 'logout',   user: 'bob',   ts: new Date('2026-11-02T10:30:00Z'), payload: {} }
]);
