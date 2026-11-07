-- Synthetic chats for the isolated PR 1 preview only.
-- These rows are fixtures. They are not a copy of anyone's saved chats.
-- Safe to run more than once.

UPDATE services
SET installed = 1, installation_status = 'idle'
WHERE service_name = 'nomad_ollama';

INSERT INTO kv_store (`key`, value, created_at, updated_at)
SELECT 'rag.enabled', 'false', UTC_TIMESTAMP(), UTC_TIMESTAMP()
WHERE NOT EXISTS (SELECT 1 FROM kv_store WHERE `key` = 'rag.enabled');

UPDATE kv_store SET value = 'false', updated_at = UTC_TIMESTAMP() WHERE `key` = 'rag.enabled';

-- Points this preview at the existing inference server. Does not change that server.
INSERT INTO kv_store (`key`, value, created_at, updated_at)
SELECT 'ai.remoteOllamaUrl', 'http://10.72.72.89:8080', UTC_TIMESTAMP(), UTC_TIMESTAMP()
WHERE NOT EXISTS (SELECT 1 FROM kv_store WHERE `key` = 'ai.remoteOllamaUrl');

UPDATE kv_store
SET value = 'http://10.72.72.89:8080', updated_at = UTC_TIMESTAMP()
WHERE `key` = 'ai.remoteOllamaUrl';

INSERT INTO kv_store (`key`, value, created_at, updated_at)
SELECT 'autoUpdate.enabled', 'false', UTC_TIMESTAMP(), UTC_TIMESTAMP()
WHERE NOT EXISTS (SELECT 1 FROM kv_store WHERE `key` = 'autoUpdate.enabled');
UPDATE kv_store SET value = 'false', updated_at = UTC_TIMESTAMP() WHERE `key` = 'autoUpdate.enabled';

INSERT INTO kv_store (`key`, value, created_at, updated_at)
SELECT 'appAutoUpdate.enabled', 'false', UTC_TIMESTAMP(), UTC_TIMESTAMP()
WHERE NOT EXISTS (SELECT 1 FROM kv_store WHERE `key` = 'appAutoUpdate.enabled');
UPDATE kv_store SET value = 'false', updated_at = UTC_TIMESTAMP() WHERE `key` = 'appAutoUpdate.enabled';

INSERT INTO chat_sessions (title, model, created_at, updated_at)
SELECT 'Synthetic: Water treatment', 'preview', UTC_TIMESTAMP(), UTC_TIMESTAMP()
WHERE NOT EXISTS (SELECT 1 FROM chat_sessions WHERE title = 'Synthetic: Water treatment');

INSERT INTO chat_messages (session_id, role, content, created_at, updated_at)
SELECT s.id, 'user', 'Synthetic fixture: how do I make drinking water safer?', UTC_TIMESTAMP(), UTC_TIMESTAMP()
FROM chat_sessions s
WHERE s.title = 'Synthetic: Water treatment'
  AND NOT EXISTS (
    SELECT 1 FROM chat_messages m
    WHERE m.session_id = s.id AND m.role = 'user' AND m.content LIKE 'Synthetic fixture: how do I make drinking water safer%'
  );

INSERT INTO chat_messages (session_id, role, content, created_at, updated_at)
SELECT s.id, 'assistant', 'Synthetic fixture answer: boil it, then cool it. This text was inserted for the preview.', UTC_TIMESTAMP(), UTC_TIMESTAMP()
FROM chat_sessions s
WHERE s.title = 'Synthetic: Water treatment'
  AND NOT EXISTS (
    SELECT 1 FROM chat_messages m
    WHERE m.session_id = s.id AND m.role = 'assistant' AND m.content LIKE 'Synthetic fixture answer: boil it%'
  );

INSERT INTO chat_sessions (title, model, created_at, updated_at)
SELECT 'Synthetic: Field notes', 'preview', UTC_TIMESTAMP(), UTC_TIMESTAMP()
WHERE NOT EXISTS (SELECT 1 FROM chat_sessions WHERE title = 'Synthetic: Field notes');

INSERT INTO chat_messages (session_id, role, content, created_at, updated_at)
SELECT s.id, 'user', 'Synthetic fixture: what should I write down after a hike?', UTC_TIMESTAMP(), UTC_TIMESTAMP()
FROM chat_sessions s
WHERE s.title = 'Synthetic: Field notes'
  AND NOT EXISTS (
    SELECT 1 FROM chat_messages m WHERE m.session_id = s.id AND m.role = 'user'
  );

INSERT INTO chat_messages (session_id, role, content, created_at, updated_at)
SELECT s.id, 'assistant', 'Synthetic fixture answer: weather, water, and the route. Preview text only.', UTC_TIMESTAMP(), UTC_TIMESTAMP()
FROM chat_sessions s
WHERE s.title = 'Synthetic: Field notes'
  AND NOT EXISTS (
    SELECT 1 FROM chat_messages m WHERE m.session_id = s.id AND m.role = 'assistant'
  );

INSERT INTO chat_sessions (title, model, created_at, updated_at)
SELECT 'Synthetic: Radio check', 'preview', UTC_TIMESTAMP(), UTC_TIMESTAMP()
WHERE NOT EXISTS (SELECT 1 FROM chat_sessions WHERE title = 'Synthetic: Radio check');

INSERT INTO chat_messages (session_id, role, content, created_at, updated_at)
SELECT s.id, 'user', 'Synthetic fixture: remind me how to call for a radio check.', UTC_TIMESTAMP(), UTC_TIMESTAMP()
FROM chat_sessions s
WHERE s.title = 'Synthetic: Radio check'
  AND NOT EXISTS (
    SELECT 1 FROM chat_messages m WHERE m.session_id = s.id AND m.role = 'user'
  );

INSERT INTO chat_messages (session_id, role, content, created_at, updated_at)
SELECT s.id, 'assistant', 'Synthetic fixture answer: say the station name and "radio check". Preview text only.', UTC_TIMESTAMP(), UTC_TIMESTAMP()
FROM chat_sessions s
WHERE s.title = 'Synthetic: Radio check'
  AND NOT EXISTS (
    SELECT 1 FROM chat_messages m WHERE m.session_id = s.id AND m.role = 'assistant'
  );
