# frozen_string_literal: true

module DiscourseSubcategories
  class TopController < ::ApplicationController
    requires_plugin "discourse-subcategories"

    def index
      results =
        ActiveRecord::Base.connection.exec_query(
          <<~SQL
            SELECT
              t.id AS topic_id,
              t.title AS topic_title,
              t.slug AS topic_slug,
              v.votes
            FROM topics t
            JOIN (
              SELECT
                topic_id,
                COUNT(*) AS votes
              FROM topic_voting_votes
              GROUP BY topic_id
            ) v ON v.topic_id = t.id
            WHERE t.deleted_at IS NULL
              AND t.closed = FALSE
              AND v.votes > 0
            ORDER BY v.votes DESC, t.created_at DESC
            LIMIT 3
          SQL
        ).to_a

      topics = results.map do |topic|
        {
          id: topic["topic_id"],
          title: topic["topic_title"],
          vote_count: topic["votes"],
          url: "/t/#{topic["topic_slug"]}/#{topic["topic_id"]}",
        }
      end

      render json: { topics: topics }
    end
  end
end