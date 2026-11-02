-- =====================================================================
-- EduPulse: Instagram-Scale High-Performance Strategic Indexes
-- Target Database: Railway Cloud MySQL
-- =====================================================================

-- 1. Fast likes count without full table scan
CREATE INDEX IF NOT EXISTS idx_post_likes_post_id ON post_likes(post_id);

-- 2. Fast shares count without full table scan
CREATE INDEX IF NOT EXISTS idx_post_shares_post_id ON post_shares(post_id);

-- 3. Fast comments retrieval ordered by id
CREATE INDEX IF NOT EXISTS idx_comments_post_id_id ON comments(post_id, id);

-- 4. Fast global college feed retrieval ordered by newest first
CREATE INDEX IF NOT EXISTS idx_posts_college_id ON posts(college_id, id DESC);

-- 5. Fast branch private feed retrieval
CREATE INDEX IF NOT EXISTS idx_posts_college_branch_id ON posts(college_id, target_branch_id, id DESC);

-- 6. Fast vertical reels feed retrieval
CREATE INDEX IF NOT EXISTS idx_reels_college_id ON event_reels(college_id, id DESC);

-- 7. Fast bookmarks list retrieval
CREATE INDEX IF NOT EXISTS idx_bookmarks_user_id ON bookmarks(user_id, id DESC);

-- 8. Fast notification recipient status lookup
CREATE INDEX IF NOT EXISTS idx_notif_recipient ON notifications(recipient_id, is_read);

-- 9. Fast notification deduplication / reference check
CREATE INDEX IF NOT EXISTS idx_notif_ref_type ON notifications(reference_id, type);